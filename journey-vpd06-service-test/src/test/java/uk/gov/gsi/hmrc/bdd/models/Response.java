package uk.gov.gsi.hmrc.bdd.models;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Response {

    private Map<String, String> headers;
    private String body;
    private Integer status;
    private List<String> transformers;
}
