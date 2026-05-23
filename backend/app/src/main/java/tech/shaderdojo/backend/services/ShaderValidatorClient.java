package tech.shaderdojo.backend.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

@Service
public class ShaderValidatorClient {

    private final RestTemplate restTemplate;
    private final String validatorUrl;
    private final String validatorKey;

    public ShaderValidatorClient(
            RestTemplateBuilder builder,
            @Value("${validator.url:http://host.docker.internal:3000/execute-shader}") String validatorUrl,
            @Value("${validator.key:}") String validatorKey,
            @Value("${validator.connect-timeout-ms:2000}") int connectTimeoutMs,
            @Value("${validator.read-timeout-ms:15000}") int readTimeoutMs) {
        this.validatorUrl = validatorUrl;
        this.validatorKey = validatorKey;
        this.restTemplate = builder
                .connectTimeout(Duration.ofMillis(connectTimeoutMs))
                .readTimeout(Duration.ofMillis(readTimeoutMs))
                .build();
    }

    public Result executeShader(String vertexShader, String fragmentShader, double time) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("vertexShader", vertexShader);
        payload.put("fragmentShader", fragmentShader);
        payload.put("time", time);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        if (!validatorKey.isEmpty()) {
            headers.set("X-Validator-Key", validatorKey);
        }

        try {
            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                    validatorUrl,
                    HttpMethod.POST,
                    new HttpEntity<>(payload, headers),
                    new ParameterizedTypeReference<Map<String, Object>>() {});
            Map<String, Object> body = response.getBody();
            if (body == null || !(body.get("imageHash") instanceof String hash) || hash.isEmpty()) {
                return Result.error("Malformed validator response.");
            }
            return Result.ok(hash);
        } catch (HttpStatusCodeException e) {
            int status = e.getStatusCode().value();
            if (status == 400) return Result.compileError(e.getResponseBodyAsString());
            if (status == 504) return Result.error("Shader render timed out.");
            if (status == 429) return Result.error("Validator busy.");
            return Result.error("Validator returned " + status);
        } catch (ResourceAccessException e) {
            return Result.error("Validator unreachable: " + e.getMessage());
        }
    }

    public record Result(String imageHash, String error, boolean compileError) {
        public boolean isOk() { return imageHash != null; }
        public static Result ok(String hash) { return new Result(hash, null, false); }
        public static Result error(String msg) { return new Result(null, msg, false); }
        public static Result compileError(String msg) { return new Result(null, msg, true); }
    }
}
