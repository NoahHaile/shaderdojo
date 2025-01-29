package tech.shaderdojo.backend.dtos;

public record VerifyProblemRequest(
        String hash,
        String problemId
) {
}
