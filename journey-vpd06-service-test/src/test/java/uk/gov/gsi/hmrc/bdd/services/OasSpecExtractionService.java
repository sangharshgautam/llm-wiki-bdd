//package uk.gov.gsi.hmrc.bdd.services;
//
//import java.io.File;
//import java.io.IOException;
//import java.nio.file.Files;
//import org.json.JSONObject;
//import org.springframework.stereotype.Service;
//import org.yaml.snakeyaml.Yaml;
//
//import java.io.InputStream;
//import java.util.ArrayList;
//import java.util.HashMap;
//import java.util.LinkedHashMap;
//import java.util.Map;
//
//
///**
// * Service class responsible for extracting OpenAPI Specification (OAS) details from the 'openapi.yaml' file (located in
// * the public folder). This class provides methods to extract HTTP methods, headers, request bodies and response bodies
// * based on the specified context path and the standard oas schema structure
// * <p>
// * The structure of the OAS file is deeply nested, so we have to cast objects back to nested LinkedHashMaps and other
// * types to access the inner elements.
// */
//@Service
//public class OasSpecExtractionService {
//
//    private String contextPath = "/vpd/vpd06/v1";
//    Map.Entry<Object, Object> oasInfo;
//
//    /**
//     * Construictor to initialise the information from the OAS spec for the given context path
//     */
//    public OasSpecExtractionService() {
//        this.oasInfo = getOasInfo(contextPath);
//    }
//
//    /**
//     * Retrieves the HTTP method (e.g., GET, POST) for the specified context path.
//     *
//     * @return The HTTP method in uppercase as a String.
//     */
//    public String getMethod() {
//        return oasInfo.getKey().toString().toUpperCase();
//    }
//
//    /**
//     * Loads the OpenAPI Specification (OAS) from the 'openapi.yaml' file and extracts the spec information
//     * corresponding to the provided context path.
//     *
//     * @param contextPath - frontend path for your journey
//     * @return A Map.Entry representing the HTTP method and associated details for the given context path
//     */
//    public Map.Entry<Object, Object> getOasInfo(String contextPath) throws OasSpecExtractionException {
//        Yaml yaml = new Yaml();
//        InputStream inputStream;
//        try {
//            File openapiYaml = new File(System.getProperty("user.dir") + "/../public/openapi.yaml");
//            inputStream = Files.newInputStream(openapiYaml.toPath());
//        } catch (IOException e) {
//            throw new OasSpecExtractionException(e.getMessage());
//        }
//        Map<String, Object> OAS = yaml.load(inputStream);
//        Map.Entry<Object, Object> pathEntry = (Map.Entry) ((LinkedHashMap) ((LinkedHashMap) OAS.get("paths")).get(
//            contextPath)).entrySet().iterator().next();
//        return pathEntry;
//    }
//
//    /**
//     * Extracts the HTTP header from the OAS  for the current context path, excluding the 'authorization' header. This
//     * method handles both regex patterns or example values for headers.
//     *
//     * @return A LinkedHashMap containing header names and their corresponding validation criteria
//     */
//    public LinkedHashMap<String, Object> getHeaders() {
//        LinkedHashMap<String, Object> headers = new LinkedHashMap<>();
//        for (Object header : (ArrayList) ((LinkedHashMap) oasInfo.getValue()).get("parameters")) {
//            LinkedHashMap castHeader = (LinkedHashMap) header;
//            Object regex = ((LinkedHashMap) castHeader.get("schema")).get("pattern");
//            HashMap<String, String> headerData = new HashMap<>();
//            if (regex != null) {
//                headerData.put("matches", regex.toString());
//            } else {
//                headerData.put("equalTo", ((LinkedHashMap) castHeader.get("schema")).get("example").toString());
//            }
//            if (!castHeader.get("name").equals("authorization")) {
//                headers.put(castHeader.get("name").toString(), headerData);
//            }
//        }
//        return headers;
//    }
//
//    /**
//     * Extracts the request body example from the OAS for the current context path
//     *
//     * @return A LinkedHashMap representing the request body example
//     */
//    public LinkedHashMap<String, Object> getRequestBody() {
//        LinkedHashMap<String, Object> bodyMap = (LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap) ((Map.Entry) ((LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap)
//            oasInfo.getValue()).get("requestBody")).get("content"))
//            .entrySet().iterator().next()).getValue())
//            .get("examples")).get("request")).get("value");
//        return bodyMap;
//    }
//
//    /**
//     * Extracts the request body schema from the OAS for the current context path
//     *
//     * @return A LinkedHashMap representing the request body schema
//     */
//    public LinkedHashMap<String, Object> getRequestBodySchema() {
//        LinkedHashMap<String, Object> bodyMap = (LinkedHashMap) ((LinkedHashMap) ((Map.Entry) ((LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap)
//            oasInfo.getValue()).get("requestBody")).get("content"))
//            .entrySet().iterator().next()).getValue())
//            .get("schema");
//        return bodyMap;
//    }
//
//    /**
//     * Extracts the response body example from the OAS for a given HTTP status code
//     *
//     * @param httpCode The HTTP status code for which the response body example is to be extracted
//     * @return A JSON-formatted String representing the response body example
//     */
//    public String getResponseBodyString(String httpCode) {
//        LinkedHashMap<String, Object> bodyMap = (LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap) ((Map.Entry) ((LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap)
//            oasInfo.getValue()).get("responses")).get(httpCode)).get("content"))
//            .entrySet().iterator().next()).getValue())
//            .get("examples")).get("response")).get("value");
//        return new JSONObject(bodyMap).toString();
//    }
//
//    /**
//     * Extracts the response body example from the OAS for a given HTTP status code
//     *
//     * @param httpCode The HTTP status code for which the response body example is to be extracted
//     * @return A LinkedHashMap representing the response body example
//     */
//    public LinkedHashMap<String, Object> getResponseBody(String httpCode) {
//        LinkedHashMap<String, Object> bodyMap = (LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap) ((Map.Entry) ((LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap) ((LinkedHashMap)
//            oasInfo.getValue()).get("responses")).get(httpCode)).get("content"))
//            .entrySet().iterator().next()).getValue())
//            .get("examples")).get("response")).get("value");
//        return bodyMap;
//    }
//
//    public static class OasSpecExtractionException extends RuntimeException {
//
//        public OasSpecExtractionException(String message) {
//            super(message);
//        }
//
//    }
//
//}
