package tech.shaderdojo.backend.dtos;

public record LessonSolutionResponse(
        String id,
        String title,
        String canonicalFragmentShader,
        String starterVertexShader
) {
}
