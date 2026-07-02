//package uk.gov.gsi.hmrc.bdd.services;
//
//import com.google.gson.Gson;
//import com.google.gson.GsonBuilder;
//import org.springframework.stereotype.Service;
//
//import java.io.FileWriter;
//import java.io.IOException;
//import java.nio.file.Files;
//import java.nio.file.Paths;
//import java.util.LinkedHashMap;
//
///**
// * Service class responsible for writing the request and response payloads extracted from
// * the OpenAPI Specification (OAS) to JSON files. These JSON files are created from the
// * request and response body definitions withing the OAS, they are stored in the 'requestPayload'
// * and 'responsePayload' classpath directories, respectively. These are to be used within the feature files.
// */
//@Service
//public class PayloadFileWriterService {
//
//    private OasSpecExtractionService oasSpec = new OasSpecExtractionService();
//
//    /**
//     * Writes the request payload extracted from the OAS request body to a JSON file
//     * names ValidRequest.json' in the 'requestPayload' directory.
//     * The directory is created if it does not exist
//     *
//     * @throws IOException If an I/O error occurs during file writing.
//     */
//    public void writeRequestFile() throws IOException {
//        LinkedHashMap<String, Object> request = oasSpec.getRequestBody();
//        String requestClasspath = PayloadFileWriterService.class.getProtectionDomain().getCodeSource().getLocation().getPath() + "requestPayload";
//        Files.createDirectories(Paths.get(requestClasspath));
//
//        Gson gson = new GsonBuilder()
//                .setPrettyPrinting()
//                .create();
//
//        try(FileWriter writer = new FileWriter(requestClasspath + "/ValidRequest.json")) {
//            gson.toJson(request, writer);
//        }
//    }
//
//    /**
//     * Writes the response payload extracted from the OAS for the given success HTTP status code
//     * to a JSON file. The file is named etds-eis-etmp_Response_Example_201.json
//     * The directory is created if it does not exist.
//     *
//     * @throws IOException If an I/O error occurs during file writing.
//     */
//    public void writeSuccessResponseFile() throws IOException {
//        LinkedHashMap<String, Object> response = oasSpec.getResponseBody("201");
//        String responseClasspath = PayloadFileWriterService.class.getProtectionDomain().getCodeSource().getLocation().getPath() + "responsePayload";
//        Files.createDirectories(Paths.get(responseClasspath));
//
//        Gson gson = new GsonBuilder()
//                .setPrettyPrinting()
//                .create();
//
//        try(FileWriter writer = new FileWriter(responseClasspath + "/etds-eis-etmp_Response_Example_201.json")) {
//            gson.toJson(response, writer);
//        }
//
//    }
//
//}
