param(
    [Parameter(Mandatory=$true, HelpMessage="Path to the generated test project (e.g., ./journey-fleetroute-service-test)")]
    [string]$ProjectPath,

    [Parameter(HelpMessage="Path to the wiki directory")]
    [string]$WikiPath = (Join-Path (Split-Path $PSScriptRoot -Parent) "wiki"),

    [Parameter(HelpMessage="Show detailed step matching output")]
    [switch]$Detailed
)

$ErrorActionPreference = "Stop"
$global:passed = 0
$global:failed = 0

function Pass($msg) { $global:passed++; Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $global:failed++; Write-Host "  [FAIL] $msg" -ForegroundColor Red }
function Skip($msg) { Write-Host "  [SKIP] $msg" -ForegroundColor Yellow }

function Section($title) {
    Write-Host ""
    Write-Host "=== $title ===" -ForegroundColor Cyan
}

# ============================================================
# 0. Validate paths
# ============================================================
if (-not (Test-Path $ProjectPath)) { Write-Host "ERROR: ProjectPath '$ProjectPath' not found" -ForegroundColor Red; exit 1 }
if (-not (Test-Path $WikiPath)) { Write-Host "ERROR: WikiPath '$WikiPath' not found" -ForegroundColor Red; exit 1 }

$ProjectPath = Resolve-Path $ProjectPath
$WikiPath = Resolve-Path $WikiPath

Write-Host "Validating: $ProjectPath" -ForegroundColor White
Write-Host "Wiki path:   $WikiPath" -ForegroundColor White

# ============================================================
# 1. Load step dictionary from wiki
# ============================================================
Section "1. Load Step Dictionary"

$dictFiles = Get-ChildItem "$WikiPath/step_dictionary/*.md" -ErrorAction SilentlyContinue
if ($dictFiles.Count -eq 0) { Fail "No step dictionary files found in $WikiPath/step_dictionary/"; exit 1 }

$dictionaryExpressions = New-Object System.Collections.ArrayList
$dictPatterns = New-Object System.Collections.ArrayList  # regex patterns for matching

foreach ($f in $dictFiles) {
    $content = Get-Content $f.FullName -Raw
    # Extract from **Expression:** `...` lines
    $regex = [regex]::new('\*\*Expression:\*\*\s*`([^`]+)`')
    $matches = $regex.Matches($content)
    foreach ($m in $matches) {
        $expr = $m.Groups[1].Value.Trim()
        [void]$dictionaryExpressions.Add($expr)
        # Convert {param} to regex wildcard
        $pattern = [regex]::Escape($expr) -replace '\\\{[^}]+\\\}', '.+'
        [void]$dictPatterns.Add(@{ Expression = $expr; Pattern = "^$pattern$" })
    }
}

if ($Detailed) { Write-Host "  Loaded $($dictionaryExpressions.Count) step expressions from $($dictFiles.Count) files" }
Pass "Step dictionary loaded: $($dictionaryExpressions.Count) expressions from $($dictFiles.Count) files"

if ($Detailed) {
    Write-Host "  Dictionary expressions:" -ForegroundColor Gray
    $dictionaryExpressions | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
}

# ============================================================
# 2. Check directory structure
# ============================================================
Section "2. Directory Structure"

$requiredDirs = @(
    "src/test/resources/features",
    "src/test/resources/requestPayload",
    "src/test/resources/responsePayload",
    "src/test/resources/mocks",
    "src/test/java"
)

$allDirsOk = $true
foreach ($dir in $requiredDirs) {
    $fullPath = Join-Path $ProjectPath $dir
    if (Test-Path $fullPath) {
        Pass "Directory exists: $dir"
    } else {
        Fail "Missing directory: $dir"
        $allDirsOk = $false
    }
}

# Check for optional but expected files
$expectedRootFiles = @("pom.xml", "scenarios.md")
foreach ($file in $expectedRootFiles) {
    $fullPath = Join-Path $ProjectPath $file
    if (Test-Path $fullPath) {
        Pass "File exists: $file"
    } else {
        Fail "Missing file: $file"
    }
}

# Check for config and runner files in src/test/resources/ and src/test/java/
$expectedResourcesFiles = @("junit-platform.properties")
foreach ($file in $expectedResourcesFiles) {
    $fullPath = Join-Path $ProjectPath "src/test/resources/$file"
    if (Test-Path $fullPath) { Pass "File exists: src/test/resources/$file" } else { Fail "Missing file: src/test/resources/$file" }
}

# Look for CucumberTest.java and AppSetup.java (names may vary)
$javaFiles = Get-ChildItem "$ProjectPath/src/test/java" -Recurse -Filter "*.java" -ErrorAction SilentlyContinue
$hasRunner = $false; $hasSetup = $false
foreach ($jf in $javaFiles) {
    $name = $jf.Name
    $content = Get-Content $jf.FullName -Raw
    if ($content -match '@RunWith\(Cucumber\.class\)|@CucumberOptions|class.*Cucumber.*Test') { $hasRunner = $true }
    if ($content -match 'AppSetup|@BeforeAll|@AfterAll|startup|shutdown|WireMock') { $hasSetup = $true }
}
if ($hasRunner) { Pass "Test runner found in src/test/java/" } else { Fail "No Cucumber test runner found in src/test/java/" }
if ($hasSetup) { Pass "Lifecycle setup found in src/test/java/" } else { Fail "No lifecycle setup found in src/test/java/" }

# ============================================================
# 3. Check scenarios.md
# ============================================================
Section "3. scenarios.md"

$scenariosMd = Join-Path $ProjectPath "scenarios.md"
if (Test-Path $scenariosMd) {
    $scContent = Get-Content $scenariosMd -Raw
    if ($scContent -match '\| Tag ') { Pass "scenarios.md has table header row" } else { Fail "scenarios.md is missing table header row (\`| Tag \`)" }
    if ($scContent -match '\|.*H001.*\|') { Pass "scenarios.md references H001" } else { Fail "scenarios.md missing H001 entry" }
    if ($scContent -match '\|.*N001.*\|') { Pass "scenarios.md references N001" } else { Fail "scenarios.md missing N001 entry" }
} else {
    Fail "scenarios.md not found at project root"
}

# ============================================================
# 4. Parse & validate feature files
# ============================================================
Section "4. Feature File Validation"

$featureFiles = Get-ChildItem "$ProjectPath/src/test/resources/features/*.feature" -ErrorAction SilentlyContinue
if ($featureFiles.Count -eq 0) { Fail "No .feature files found"; exit 1 }
Pass "Found $($featureFiles.Count) feature file(s): $($featureFiles.Name -join ', ')"

$allScenarios = New-Object System.Collections.ArrayList
$allStepLines = New-Object System.Collections.ArrayList

foreach ($ff in $featureFiles) {
    $lines = Get-Content $ff.FullName
    $currentTag = $null
    $currentScenario = $null
    $currentSteps = @()
    $inScenario = $false
    $hasMdgHeader = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i].Trim()

        # Detect tag line (e.g., @H001)
        if ($line -match '^@(H\d+|N\d+|B\d+)') {
            $currentTag = $matches[1]
            continue
        }

        if ($line -match '^Scenario:\s*(.+)') {
            if ($inScenario -and $currentTag) {
                [void]$allScenarios.Add(@{
                    Tag = $currentTag
                    Name = $currentScenario
                    Steps = $currentSteps
                    HasMdgHeader = $hasMdgHeader
                    File = $ff.Name
                })
            }
            $currentScenario = $matches[1].Trim()
            $currentSteps = @()
            $inScenario = $true
            $hasMdgHeader = $false
            continue
        }

        if ($inScenario) {
            # Check for Gherkin step lines
            if ($line -match '^(Given|When|Then|And|\*)\s+(sg:.+)') {
                $stepExpr = $matches[2].Trim()
                $currentSteps += $stepExpr

                # Check for mdg_test_scenario header
                if ($line -match 'mdg_test_scenario') {
                    $hasMdgHeader = $true
                }
            }

            # End of scenario on blank line or new tag
            if ([string]::IsNullOrEmpty($line) -and $inScenario -and $currentTag) {
                [void]$allScenarios.Add(@{
                    Tag = $currentTag
                    Name = $currentScenario
                    Steps = $currentSteps
                    HasMdgHeader = $hasMdgHeader
                    File = $ff.Name
                })
                $currentTag = $null
                $currentScenario = $null
                $currentSteps = @()
                $inScenario = $false
                $hasMdgHeader = $false
            }
        }
    }

    # Last scenario
    if ($inScenario -and $currentTag) {
        [void]$allScenarios.Add(@{
            Tag = $currentTag
            Name = $currentScenario
            Steps = $currentSteps
            HasMdgHeader = $hasMdgHeader
            File = $ff.Name
        })
    }
}

Pass "Parsed $($allScenarios.Count) scenario(s)"
foreach ($s in $allScenarios) {
    Write-Host "  [$($s.Tag)] $($s.Name) ($($s.Steps.Count) steps, file: $($s.File))" -ForegroundColor DarkGray
}

# ============================================================
# 5. Check mdg_test_scenario header in every scenario
# ============================================================
Section "5. mdg_test_scenario Header"

foreach ($s in $allScenarios) {
    if (-not $s.HasMdgHeader) {
        Fail "Scenario $($s.Tag) is missing mdg_test_scenario header"
    } else {
        Pass "Scenario $($s.Tag) includes mdg_test_scenario header"
    }
}

# ============================================================
# 6. Check all Gherkin steps exist in step dictionary
# ============================================================
Section "6. Step Dictionary Matching"

$allSteps = @()
foreach ($s in $allScenarios) {
    foreach ($step in $s.Steps) {
        $allSteps += @{ Tag = $s.Tag; Step = $step }
    }
}

foreach ($item in $allSteps) {
    $step = $item.Step
    $tag = $item.Tag
    $matched = $false
    foreach ($dp in $dictPatterns) {
        if ($step -match $dp.Pattern) {
            $matched = $true
            break
        }
    }
    if ($matched) {
        if ($Detailed) { Write-Host "  [MATCH] ${tag}: ${step}" -ForegroundColor Green }
    } else {
        # Try exact match for reporting
        $exactMatch = $dictionaryExpressions -contains $step
        if ($exactMatch) {
            if ($Detailed) { Write-Host "  [MATCH] ${tag}: ${step}" -ForegroundColor Green }
        } else {
            Fail "Step NOT in dictionary: ${tag}: ${step}"
        }
    }
}

# Count total unique steps matched
$matchedCount = 0
foreach ($item in $allSteps) {
    $step = $item.Step
    $isMatch = $false
    foreach ($dp in $dictPatterns) {
        if ($step -match $dp.Pattern) { $isMatch = $true; break }
    }
    if (-not $isMatch -and ($dictionaryExpressions -contains $step)) { $isMatch = $true }
    if ($isMatch) { $matchedCount++ }
}
if ($matchedCount -eq $allSteps.Count) {
    Pass "All $($allSteps.Count) Gherkin step(s) match the step dictionary"
} else {
    $missingCount = $allSteps.Count - $matchedCount
    Fail "$missingCount of $($allSteps.Count) step(s) do not match the step dictionary (listed above)"
}

# ============================================================
# 7. Check payload files referenced in feature files
# ============================================================
Section "7. Payload File References"

$allReqPayloadRefs = New-Object System.Collections.ArrayList
$allResPayloadRefs = New-Object System.Collections.ArrayList

# Look for "from file" references in feature files
foreach ($ff in $featureFiles) {
    $content = Get-Content $ff.FullName -Raw
    # Match: I have request payload from file "{name}"
    $refs = [regex]::Matches($content, 'I have request payload from file "([^"]+)"')
    foreach ($r in $refs) { [void]$allReqPayloadRefs.Add($r.Groups[1].Value) }
    # Match: the response should contain file "{name}"
    $refs = [regex]::Matches($content, 'the response should (?:contain|match) file "([^"]+)"')
    foreach ($r in $refs) { [void]$allResPayloadRefs.Add($r.Groups[1].Value) }
}

# Also scan for scenario-tagged payloads by looking at the tag convention
$allTags = $allScenarios | ForEach-Object { $_.Tag }

# Check requestPayload files
$reqPayloadDir = Join-Path $ProjectPath "src/test/resources/requestPayload"
$existingReqFiles = @()
if (Test-Path $reqPayloadDir) { $existingReqFiles = Get-ChildItem $reqPayloadDir -Filter "*.json" | ForEach-Object { $_.BaseName } }

$allRefs = $allReqPayloadRefs | Select-Object -Unique
foreach ($ref in $allRefs) {
    $filePath = Join-Path $reqPayloadDir "$ref.json"
    if (Test-Path $filePath) {
        if ($Detailed) { Write-Host "  [EXISTS] requestPayload/$ref.json" -ForegroundColor Green }
    } else {
        Fail "requestPayload/$ref.json referenced in feature file but not found on disk"
    }
}

# Also check tag-based payload files exist
foreach ($tag in $allTags) {
    # Check requestPayload/<TAG>.json (only if expected - for happy paths)
    $reqFile = Join-Path $reqPayloadDir "$tag.json"
    $resFile = Join-Path (Join-Path $ProjectPath "src/test/resources/responsePayload") "$tag.json"
    $mockFile = Join-Path (Join-Path $ProjectPath "src/test/resources/mocks") "$tag.json"

    $isHappy = $tag -match '^H'
    $isNegBackend = $tag -match '^N002|N500|N001'  # heuristic based on pattern
    $isBusiness = $tag -match '^B'

    if ($isHappy -or $isBusiness) {
        if (Test-Path $reqFile) { if ($Detailed) { Write-Host "  [EXISTS] requestPayload/$tag.json" } } else { Fail "Missing requestPayload/$tag.json for scenario $tag" }
        if (Test-Path $resFile) { if ($Detailed) { Write-Host "  [EXISTS] responsePayload/$tag.json" } } else { Fail "Missing responsePayload/$tag.json for scenario $tag" }
        if ($isHappy) {
            if (Test-Path $mockFile) { if ($Detailed) { Write-Host "  [EXISTS] mocks/$tag.json" } } else { Fail "Missing mocks/$tag.json for happy path scenario $tag" }
        }
    } elseif ($isNegBackend) {
        if (Test-Path $mockFile) { if ($Detailed) { Write-Host "  [EXISTS] mocks/$tag.json" } } else { Fail "Missing mocks/$tag.json for backend-error scenario $tag" }
    }
}

Pass "Payload file reference check complete"

# ============================================================
# 8. Check mock files have mdg_test_scenario header matching
# ============================================================
Section "8. Mock Header Matching"

$mocksDir = Join-Path $ProjectPath "src/test/resources/mocks"
if (Test-Path $mocksDir) {
    $mockFiles = Get-ChildItem $mocksDir -Filter "*.json"
    if ($mockFiles.Count -eq 0) {
        Skip "No mock files found in mocks/"
    } else {
        foreach ($mf in $mockFiles) {
            $mockContent = Get-Content $mf.FullName -Raw
            if ($mockContent -match 'mdg_test_scenario') {
                # Extract the expected scenario tag from filename
                $baseName = $mf.BaseName
                if ($mockContent -match $baseName) {
                    Pass "$($mf.Name) has mdg_test_scenario header matching tag $baseName"
                } else {
                    Fail "$($mf.Name) has mdg_test_scenario header but tag value may not match '$baseName'"
                }
            } else {
                Fail "$($mf.Name) is missing mdg_test_scenario header matching"
            }
        }
    }
} else {
    Skip "No mocks directory found"
}

# ============================================================
# Summary
# ============================================================
Section "RESULTS"
$total = $global:passed + $global:failed
Write-Host "  Passed: $($global:passed)/$total" -ForegroundColor Green
Write-Host "  Failed: $($global:failed)/$total" -ForegroundColor Red
Write-Host ""

if ($global:failed -eq 0) {
    Write-Host "ALL VALIDATIONS PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "SOME VALIDATIONS FAILED" -ForegroundColor Red
    exit 1
}
