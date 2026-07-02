package uk.gov.gsi.hmrc.bdd.models;

import com.google.gson.annotations.Expose;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.LinkedHashMap;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BodyPatterns {

    @Expose
    private LinkedHashMap<String, Object> equalToJson;
    @Expose
    private LinkedHashMap<String, Object> matchesJsonSchema;
    @Expose
    private Boolean ignoreArrayOrder;
}