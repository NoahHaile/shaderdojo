package tech.shaderdojo.backend.dtos;

import tech.shaderdojo.backend.models.Course;

public record CourseResponse(
        String id,
        String slug,
        String title,
        String description,
        int displayOrder
) {
    public static CourseResponse from(Course c) {
        return new CourseResponse(c.getId(), c.getSlug(), c.getTitle(),
                c.getDescription(), c.getDisplayOrder());
    }
}
