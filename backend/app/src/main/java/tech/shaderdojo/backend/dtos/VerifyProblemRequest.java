package tech.shaderdojo.backend.dtos;

public record VerifyProblemRequest(
        String problemId,
        String vertexShader,
        String fragmentShader,
        double time
) {
}
