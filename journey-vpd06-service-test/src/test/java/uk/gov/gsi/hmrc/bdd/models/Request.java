package uk.gov.gsi.hmrc.bdd.models;

import com.google.gson.annotations.Expose;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.LinkedHashMap;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Request {

    @Expose
    private LinkedHashMap<String, Object> headers;
    @Expose
    private String method;
    @Expose
    private String urlPathTemplate;
    @Expose
    private List<BodyPatterns> bodyPatterns;
}
