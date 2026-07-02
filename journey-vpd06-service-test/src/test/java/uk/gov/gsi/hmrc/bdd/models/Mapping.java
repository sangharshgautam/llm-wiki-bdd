package uk.gov.gsi.hmrc.bdd.models;

import com.google.gson.annotations.Expose;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Mapping {

    @Expose
    private Request request;
    @Expose
    private Response response;

}
