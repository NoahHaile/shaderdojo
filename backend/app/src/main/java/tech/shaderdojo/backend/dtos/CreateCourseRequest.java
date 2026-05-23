package tech.shaderdojo.backend.dtos;

public record CreateCourseRequest(
        String slug,
        String title,
        String description,
        Integer displayOrder
) {
}
