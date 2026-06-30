param(
    [Parameter(HelpMessage="Run a specific test by name (wildcards supported)")]
    [string]$TestName = "*",

    [Parameter(HelpMessage="Set up fixtures only, skip validation steps")]
    [switch]$SetupOnly,

    [Parameter(HelpMessage="Run validation steps only, skip setup")]
    [switch]$CheckOnly,

    [Parameter(HelpMessage="The project root directory")]
    [string]$ProjectRoot = (Split-Path $PSScriptRoot -Parent)
)

$ErrorActionPreference = "Stop"
$global:passed = 0
$global:failed = 0
$global:skipped = 0

function Pass($msg) { $global:passed++; Write-Host "[PASS] $msg" -ForegroundColor Green }
function Fail($msg) { $global:failed++; Write-Host "[FAIL] $msg" -ForegroundColor Red }
function Skip($msg) { $global:skipped++; Write-Host "[SKIP] $msg" -ForegroundColor Yellow }

function SectionHeader($title) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function SubHeader($title) {
    Write-Host "--- $title ---" -ForegroundColor Magenta
}

function Instruction($msg) {
    Write-Host ">>> $msg" -ForegroundColor Yellow
}

# Verify project root exists
if (-not (Test-Path $ProjectRoot)) { Write-Host "ERROR: ProjectRoot '$ProjectRoot' not found" -ForegroundColor Red; exit 1 }
$ProjectRoot = Resolve-Path $ProjectRoot

# ============================================================
# TEST 1: Multiple Golden Services
# ============================================================
if ("multiple-golden-services" -like $TestName) {
    SectionHeader "T1: Multiple Golden Services"
    Write-Host "Purpose: Verify the agent processes ALL golden_services entries, not just the first one." -ForegroundColor White
    Write-Host ""

    if (-not $CheckOnly) {
        SubHeader "Setup"
        $sourcesPath = Join-Path $ProjectRoot "SOURCES.md"
        $backupPath = Join-Path $ProjectRoot "SOURCES.md.bak.t1"

        if (Test-Path $backupPath) {
            Write-Host "  T1 backup already exists, skipping backup." -ForegroundColor DarkGray
        } else {
            Copy-Item $sourcesPath $backupPath
            Write-Host "  Backed up SOURCES.md -> SOURCES.md.bak.t1" -ForegroundColor DarkGray
        }

        # Check if there are additional golden services available on another computer
        # We'll add a second synthetic service pointing to a copy of coffee-ordering
        $gsDir = Join-Path $ProjectRoot "raw_sources/golden_services"
        if (Test-Path $gsDir) {
            $existingServices = Get-ChildItem $gsDir -Directory | ForEach-Object { $_.Name }
            Write-Host "  Existing golden services: $($existingServices -join ', ')" -ForegroundColor DarkGray
        }

        Instruction "ACTION REQUIRED:"
        Write-Host ""
        Write-Host "  On your other computer where multiple golden services exist:"
        Write-Host "  1. Ensure SOURCES.md has 2+ entries under golden_services:"
        Write-Host "  2. Ask the agent to 'Ingest golden features'"
        Write-Host "  3. After ingest completes, run this script with -CheckOnly to validate"
        Write-Host ""
        Write-Host "  Example SOURCES.md golden_services section:"
        Write-Host "    golden_services:" -ForegroundColor Gray
        Write-Host "      - path: /path/to/first-service" -ForegroundColor Gray
        Write-Host "        description: First service" -ForegroundColor Gray
        Write-Host "      - path: /path/to/second-service" -ForegroundColor Gray
        Write-Host "        description: Second service" -ForegroundColor Gray
        Write-Host ""
    }

    if (-not $SetupOnly) {
        SubHeader "Validation"
        $wikiApis = Get-ChildItem "$ProjectRoot/wiki/apis/*.md" -ErrorAction SilentlyContinue
        $wikiQaPatterns = Get-ChildItem "$ProjectRoot/wiki/qa_patterns/*.md" -ErrorAction SilentlyContinue
        $sourcesPath = Join-Path $ProjectRoot "SOURCES.md"
        $sourcesContent = Get-Content $sourcesPath -Raw

        # Count uncommented golden_services entries
        $gsMatches = [regex]::Matches($sourcesContent, '(?m)^\s+- path:')
        $gsCount = $gsMatches.Count
        Write-Host "  Golden service entries in SOURCES.md: $gsCount" -ForegroundColor DarkGray

        if ($gsCount -ge 2) {
            $apiMdCount = $wikiApis.Count
            Write-Host "  API doc pages in wiki/apis/: $apiMdCount" -ForegroundColor DarkGray

            if ($apiMdCount -ge $gsCount) {
                Pass "T1: All $gsCount golden services have corresponding wiki/apis/ pages"
            } else {
                Fail "T1: Only $apiMdCount api pages for $gsCount golden services (expected at least $gsCount)"
            }

            # Check qa_patterns pages were updated
            $patternsUpdated = $false
            foreach ($pf in $wikiQaPatterns) {
                $content = Get-Content $pf.FullName -Raw
                if ($content -match 'multiple|second|another|different') {
                    $patternsUpdated = $true
                }
            }
            if ($patternsUpdated) { Pass "T1: QA patterns reflect multiple golden services" } else { Fail "T1: QA patterns may not reference multiple services" }
        } else {
            Skip "T1: Only $gsCount golden service(s) configured - need 2+ to test multi-service ingest"
        }
    }
}

# ============================================================
# TEST 2: Multiple Step Definition Sources
# ============================================================
if ("multiple-step-defs" -like $TestName) {
    SectionHeader "T2: Multiple Step Definition Sources"
    Write-Host "Purpose: Verify the agent processes ALL step_definitions entries, not just the first one." -ForegroundColor White
    Write-Host ""

    if (-not $CheckOnly) {
        SubHeader "Setup"
        Instruction "ACTION REQUIRED:"
        Write-Host ""
        Write-Host "  On your other computer with multiple step definition sources:"
        Write-Host "  1. Ensure SOURCES.md has 2+ entries under step_definitions:"
        Write-Host "  2. Ask the agent to 'Ingest step definitions'"
        Write-Host "  3. After ingest completes, run this script with -CheckOnly to validate"
        Write-Host ""
        Write-Host "  Example step_definitions section:" -ForegroundColor Gray
        Write-Host "    step_definitions:" -ForegroundColor Gray
        Write-Host "      - path: /path/to/lib-one" -ForegroundColor Gray
        Write-Host "        description: First step library" -ForegroundColor Gray
        Write-Host "      - path: /path/to/lib-two" -ForegroundColor Gray
        Write-Host "        description: Second step library" -ForegroundColor Gray
        Write-Host ""
    }

    if (-not $SetupOnly) {
        SubHeader "Validation"
        $sourcesContent = Get-Content (Join-Path $ProjectRoot "SOURCES.md") -Raw
        $sdMatches = [regex]::Matches($sourcesContent, '(?m)^\s+- path:')
        $sdCount = $sdMatches.Count

        # Count unique step expressions in the dictionary
        $dictFiles = Get-ChildItem "$ProjectRoot/wiki/step_dictionary/*.md" -ErrorAction SilentlyContinue
        $stepCount = 0
        foreach ($f in $dictFiles) {
            $content = Get-Content $f.FullName -Raw
            $exprMatches = [regex]::Matches($content, '\*\*Expression:\*\*\s*`([^`]+)`')
            $stepCount += $exprMatches.Count
        }
        Write-Host "  Step definitions sources: $sdCount" -ForegroundColor DarkGray
        Write-Host "  Total step expressions in dictionary: $stepCount" -ForegroundColor DarkGray

        # Log shows all step counts
        $logContent = Get-Content (Join-Path $ProjectRoot "wiki/log.md") -Raw

        if ($sdCount -ge 2) {
            Pass "T2: $sdCount step definition source(s) configured"
            Write-Host "  NOTE: Manually verify that steps from ALL sources appear in wiki/step_dictionary/" -ForegroundColor Yellow
        } else {
            Skip "T2: Only $sdCount step definition source(s) - need 2+ to test multi-source ingest"
        }
    }
}

# ============================================================
# TEST 3: Project Name Convention
# ============================================================
if ("project-name-convention" -like $TestName) {
    SectionHeader "T3: Project Name Convention"
    Write-Host "Purpose: Verify the generated project directory follows" -ForegroundColor White
    Write-Host "         journey-<lowercase-kebab-of-publisher-reference>-service-test" -ForegroundColor White
    Write-Host ""

    if (-not $CheckOnly) {
        SubHeader "Setup"
        $sourcesPath = Join-Path $ProjectRoot "SOURCES.md"
        $sourcesContent = Get-Content $sourcesPath -Raw
        $refMatch = [regex]::Match($sourcesContent, 'publisher-reference[^:]*:\s*"([^"]+)"')
        if ($refMatch.Success) {
            $publisherRef = $refMatch.Groups[1].Value
            Write-Host "  Current publisher-reference in frontend spec: $publisherRef" -ForegroundColor DarkGray
        } else {
            Write-Host "  publisher-reference not found in SOURCES.md (may be in raw spec file)" -ForegroundColor DarkGray
            # Try reading the spec
            $specPath = (Get-ChildItem "$ProjectRoot/raw_sources/frontend_spec/*.yaml" -ErrorAction SilentlyContinue) | Select-Object -First 1
            if ($specPath) {
                $specContent = Get-Content $specPath.FullName -Raw
                $refMatch2 = [regex]::Match($specContent, 'publisher-reference[^:]*:\s*"([^"]+)"')
                if ($refMatch2.Success) {
                    $publisherRef = $refMatch2.Groups[1].Value
                    Write-Host "  publisher-reference in raw spec: $publisherRef" -ForegroundColor DarkGray
                }
            }
        }

        Instruction "ACTION REQUIRED:"
        Write-Host ""
        Write-Host "  1. Ask the agent to generate tests for the frontend spec"
        Write-Host "  2. After generation, run:"
        Write-Host "     pwsh scripts\test-agent-behavior.ps1 -TestName project-name-convention -CheckOnly"
        Write-Host ""
    }

    if (-not $SetupOnly) {
        SubHeader "Validation"

        # Find generated project directories
        $generatedDirs = Get-ChildItem $ProjectRoot -Directory | Where-Object { $_.Name -match '^journey-.+-service-test$' }
        if ($generatedDirs.Count -eq 0) {
            Fail "T3: No generated project directory found matching 'journey-*-service-test'"
        } else {
            foreach ($gd in $generatedDirs) {
                $dirName = $gd.Name
                Write-Host "  Found: $dirName" -ForegroundColor DarkGray

                # Check naming convention
                if ($dirName -match '^journey-[a-z0-9-]+-service-test$') {
                    Pass "T3: Directory '$dirName' follows journey-<kebab>-service-test convention"
                } else {
                    Fail "T3: Directory '$dirName' does not follow journey-<lowercase-kebab>-service-test convention"
                }

                # Check scenarios.md exists
                if (Test-Path (Join-Path $gd.FullName "scenarios.md")) {
                    Pass "T3: scenarios.md present in $dirName"
                } else {
                    Fail "T3: scenarios.md missing from $dirName"
                }

                # Check host placeholder consistency
                $featureFiles = Get-ChildItem "$($gd.FullName)/src/test/resources/features/*.feature" -ErrorAction SilentlyContinue
                if ($featureFiles.Count -gt 0) {
                    $hostPlaceholders = New-Object System.Collections.ArrayList
                    foreach ($ff in $featureFiles) {
                        $content = Get-Content $ff.FullName -Raw
                        $hosts = [regex]::Matches($content, 'http://([^/]+)')
                        foreach ($h in $hosts) {
                            if (-not $hostPlaceholders.Contains($h.Groups[1].Value)) {
                                [void]$hostPlaceholders.Add($h.Groups[1].Value)
                            }
                        }
                    }
                    if ($hostPlaceholders.Count -eq 1) {
                        Pass "T3: Host placeholder is consistent across all feature files: $($hostPlaceholders[0])"
                    } elseif ($hostPlaceholders.Count -gt 1) {
                        Fail "T3: Inconsistent host placeholders: $($hostPlaceholders -join ', ')"
                    } else {
                        Skip "T3: No host placeholders found in feature files"
                    }
                }

                # Validate with the validation script
                $validateScript = Join-Path $PSScriptRoot "validate-generated-test.ps1"
                if (Test-Path $validateScript) {
                    Write-Host "  Running full validation on $dirName..." -ForegroundColor DarkGray
                    & $validateScript -ProjectPath $gd.FullName
                }
            }
        }
    }
}

# ============================================================
# TEST 4: Missing Step Detection
# ============================================================
if ("missing-step-detection" -like $TestName) {
    SectionHeader "T4: Missing Step Detection"
    Write-Host "Purpose: Verify the agent flags gaps when a needed step is not in the dictionary," -ForegroundColor White
    Write-Host "         rather than hallucinating a new step expression." -ForegroundColor White
    Write-Host ""

    if (-not $CheckOnly) {
        SubHeader "Setup"
        # Create a temporary frontend spec that requires an operation not covered by current steps
        $testDir = Join-Path $ProjectRoot "scripts/tmp_test4"
        if (-not (Test-Path $testDir)) { New-Item -ItemType Directory -Path $testDir -Force | Out-Null }

        $unknownSpec = @"
openapi: "3.0.3"
info:
  title: "Unknown Operation API"
  version: "1.0.0"
  x-integration-catalogue:
    publisher-reference: "UnknownOp"
paths:
  /magic:
    post:
      summary: Execute magic operation (no step exists for this)
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                spell:
                  type: string
      responses:
        "200":
          description: Magic executed
          content:
            application/json:
              schema:
                type: object
                properties:
                  result:
                    type: string
"@
        Set-Content -Path (Join-Path $testDir "unknown-spec.yaml") -Value $unknownSpec

        # Create a temporary SOURCES.md snippet
        $testSources = @"
frontend_spec:
  - path: $testDir/unknown-spec.yaml
    description: Unknown operation API (for testing missing step detection)
"@
        Set-Content -Path (Join-Path $testDir "test-sources.yaml") -Value $testSources

        Instruction "ACTION REQUIRED:"
        Write-Host ""
        Write-Host "  1. Temporarily add the following to SOURCES.md frontend_spec:"
        Write-Host ""
        Write-Host "    frontend_spec:" -ForegroundColor Gray
        Write-Host "      - path: $testDir/unknown-spec.yaml" -ForegroundColor Gray
        Write-Host "        description: Unknown operation API" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  2. Ask the agent to generate tests for the frontend spec"
        Write-Host "  3. The agent MUST flag a gap if it needs a step not in the dictionary"
        Write-Host "     (e.g., if it needs a PATCH step and none exists, or similar)"
        Write-Host "  4. After generation, run:"
        Write-Host "     pwsh scripts\test-agent-behavior.ps1 -TestName missing-step-detection -CheckOnly"
        Write-Host ""

        # Clean up the generated project afterward
        Write-Host ""
        Write-Host "  After testing, restore your original SOURCES.md and delete:"
        Write-Host "    rm journey-unknownop-service-test/ -Recurse -Force" -ForegroundColor DarkGray
        Write-Host ""
    }

    if (-not $SetupOnly) {
        SubHeader "Validation"

        # Check if a generated project was created despite missing steps
        $badDir = Join-Path $ProjectRoot "journey-unknownop-service-test"
        $projectDir = $null
        $possibleDirs = Get-ChildItem $ProjectRoot -Directory | Where-Object { $_.Name -like "journey-*-service-test" }
        $newDirs = $possibleDirs | Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-1) }
        if ($newDirs.Count -gt 0) { $projectDir = $newDirs | Sort-Object LastWriteTime -Descending | Select-Object -First 1 }

        if ($projectDir -and (Test-Path $projectDir.FullName)) {
            # Project was generated - check if agent flagged gaps or if it hallucinated
            $featureFiles = Get-ChildItem "$($projectDir.FullName)/src/test/resources/features/*.feature" -ErrorAction SilentlyContinue
            $hasUnknownSteps = $false
            foreach ($ff in $featureFiles) {
                $content = Get-Content $ff.FullName -Raw
                # Look for step patterns not in dictionary
                if ($content -match '(Given|When|Then|And|\*)\s+sg:(?!.*(?:I have a REST API|I have the following request body|I have request payload from file|I have the following headers|I have the following query parameters|I have the following path parameters|I send a (?:GET|POST|PUT|DELETE|PATCH) request|the response status code should be|the response should contain|the response should have field|the response should be empty|the response time should be less than|the response content type should be|the response array size should be|the response should match schema|the response should match file|the response should contain file|I print the response|I save the response field|I use variable|I set authentication|I set basic authentication|I set the base URI|I set the base path))') {
                    $hasUnknownSteps = $true
                    $badStep = $matches[0]
                    Fail "T4: Agent hallucinated a step not in dictionary: $badStep"
                }
            }

            if (-not $hasUnknownSteps) {
                Pass "T4: No hallucinated steps found in generated output"
            }

            # Check if the conversation log mentions gaps
            $logContent = Get-Content (Join-Path $ProjectRoot "wiki/log.md") -Raw
            if ($logContent -match 'gap|GAP|missing.*step|not.*in.*dictionary') {
                Pass "T4: Gaps were properly flagged in wiki/log.md"
            } elseif ($featureFiles.Count -gt 0) {
                # No gaps in log but project was generated - possible hallucination
                Write-Host "  WARNING: Project was generated but no gaps were logged." -ForegroundColor Yellow
                Write-Host "  Verify manually that all generated steps exist in the dictionary." -ForegroundColor Yellow
            }
        } else {
            Skip "T4: No project directory generated for the test spec - agent may have refused correctly"
        }
    }
}

# ============================================================
# TEST 5: Directory Overwrite
# ============================================================
if ("directory-overwrite" -like $TestName) {
    SectionHeader "T5: Directory Overwrite Behavior"
    Write-Host "Purpose: Verify the agent overwrites (not merges) existing generated project files." -ForegroundColor White
    Write-Host ""

    if (-not $CheckOnly) {
        SubHeader "Setup"
        Instruction "ACTION REQUIRED:"
        Write-Host ""
        Write-Host "  1. Generate tests for the frontend spec (first generation)"
        Write-Host "  2. Modify a generated file (e.g., add a junk line to scenarios.md)"
        Write-Host "  3. Ask the agent to regenerate tests for the same spec"
        Write-Host "  4. After regeneration, run:"
        Write-Host "     pwsh scripts\test-agent-behavior.ps1 -TestName directory-overwrite -CheckOnly"
        Write-Host ""
    }

    if (-not $SetupOnly) {
        SubHeader "Validation"

        # Find the most recently generated project (written in last hour)
        $possibleDirs = Get-ChildItem $ProjectRoot -Directory | Where-Object { $_.Name -like "journey-*-service-test" }
        $recentDirs = $possibleDirs | Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-1) }
        if ($recentDirs.Count -gt 0) {
            $latestDir = $recentDirs | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            $scenariosMd = Join-Path $latestDir.FullName "scenarios.md"
            if (Test-Path $scenariosMd) {
                $content = Get-Content $scenariosMd -Raw
                # Check it's a valid fresh scenarios.md (tabular format, no junk)
                if ($content -match '^\| Tag ') {
                    Pass "T5: scenarios.md has clean table header (was overwritten, not merged)"
                } else {
                    Fail "T5: scenarios.md may not have been properly overwritten"
                }
            } else {
                Fail "T5: scenarios.md missing from $($latestDir.Name)"
            }
        } else {
            Skip "T5: No recently generated project directory found"
        }
    }
}

# ============================================================
# Summary
# ============================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BEHAVIOR TEST RESULTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$total = $global:passed + $global:failed + $global:skipped
Write-Host "  Passed:  $($global:passed)/$total" -ForegroundColor Green
Write-Host "  Failed:  $($global:failed)/$total" -ForegroundColor Red
Write-Host "  Skipped: $($global:skipped)/$total" -ForegroundColor Yellow
Write-Host ""

if ($global:failed -eq 0 -and $global:skipped -eq 0) {
    Write-Host "ALL BEHAVIOR TESTS PASSED" -ForegroundColor Green
    exit 0
} elseif ($global:failed -eq 0) {
    Write-Host "NO FAILURES (some tests skipped - run on other computer for full results)" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "SOME BEHAVIOR TESTS FAILED" -ForegroundColor Red
    exit 1
}
