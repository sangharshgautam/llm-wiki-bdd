//package uk.gov.gsi.hmrc.bdd.services;
//
//import com.google.gson.Gson;
//import com.google.gson.GsonBuilder;
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
//import org.springframework.stereotype.Service;
//import uk.gov.gsi.hmrc.bdd.models.BodyPatterns;
//import uk.gov.gsi.hmrc.bdd.models.Mapping;
//import uk.gov.gsi.hmrc.bdd.models.Request;
//import uk.gov.gsi.hmrc.bdd.models.Response;
//
//import java.io.FileWriter;
//import java.io.IOException;
//import java.nio.file.Files;
//import java.nio.file.Paths;
//import java.util.*;
//
///**
// * Service class responsible for generating WireMock mappinng files based on the
// * OOpenAPI Specification (OAS) details extracted by the {@link OasSpecExtractionService}
// * The mappings generate simulate successful responses for the backend service
// */
//@Service
//public class WiremockMappingGeneratorService {
//
//    private static final Logger log = LoggerFactory.getLogger(WiremockMappingGeneratorService.class);
//
//    private String backendPath = "RESTAdapter/generic/approval-status";
//
//    private OasSpecExtractionService oasSpec = new OasSpecExtractionService();
//
//    /**
//     * Creates a WireMock mapping file for a successful response based on the OAS
//     * The method generates the request and response mappings, builds the Wiremock mapping object,
//     * and writes it to a JSON file in the classpath 'mocks' directory to be used by the
//     * {@link BeforeAndAfterStepDefinitions}
//     *
//     * @throws IOException if an I/O error occurs during file writing
//     */
//    public void createSuccessMapping() throws IOException {
//        LinkedHashMap<String, Object> headers = oasSpec.getHeaders();
//        LinkedHashMap<String, Object> body = oasSpec.getRequestBody();
//        LinkedHashMap<String, Object> bodySchema = oasSpec.getRequestBodySchema();
//
//        BodyPatterns bodyPatterns = BodyPatterns.builder()
//                .equalToJson(body)
////                .matchesJsonSchema(bodySchema) // TODO: When wiremock upgraded to 3.9.1 (3.4+)
//                .ignoreArrayOrder(true)
//                .build();
//
//        Request request = Request.builder()
//                .headers(headers)
//                .method(oasSpec.getMethod())
//                .urlPathTemplate(backendPath)
//                .bodyPatterns(Collections.singletonList(bodyPatterns))
//                .build();
//
//        Response response = Response.builder()
//                .headers(getResponseHeaders())
//                .body(oasSpec.getResponseBodyString("201"))
//                .status(201)
//                .transformers(Collections.singletonList("response-template")) // required for templating correlation-id
//                .build();
//
//        Mapping mapping = Mapping.builder()
//                .request(request)
//                .response(response)
//                .build();
//
//        Gson gson = new GsonBuilder()
//                .setPrettyPrinting()
//                .create();
//
//        String mockClasspath = WiremockMappingGeneratorService.class.getProtectionDomain().getCodeSource().getLocation().getPath() + "mocks";
//        Files.createDirectories(Paths.get(mockClasspath));
//
//        try(FileWriter writer = new FileWriter(mockClasspath + "/201_Successful.json")) {
//            gson.toJson(mapping, writer);
//        }
//    }
//
//    /**
//     * Generates a set of default headers for the Wiremock response,
//     * including the date, correlation IDs, and content-type
//     *
//     * @return A map containing the default response headers
//     */
//    private Map<String, String> getResponseHeaders() {
//        //TODO: Update headers to match requirements
//        Map<String, String> headers = new HashMap<>();
//        headers.put("date", "Fri, 01 Mar 2019 15:00:00 UTC");
//        headers.put("x-correlation-id", "{{request.headers.x-correlation-id}}");
//        headers.put("Content-Type", "application/json");
//        return headers;
//    }
//
//}
