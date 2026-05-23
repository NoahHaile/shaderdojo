package tech.shaderdojo.backend.dtos;

public record UpdateLessonRequest(
        String slug,
        Integer displayOrder,
        String title,
        String description,
        String starterVertexShader,
        String starterFragmentShader,
        String canonicalFragmentShader,
        String hashedAnswer
) {
}
