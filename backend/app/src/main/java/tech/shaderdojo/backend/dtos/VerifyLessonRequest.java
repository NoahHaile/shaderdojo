package tech.shaderdojo.backend.dtos;

public record VerifyLessonRequest(
        String lessonId,
        String vertexShader,
        String fragmentShader,
        double time
) {
}
