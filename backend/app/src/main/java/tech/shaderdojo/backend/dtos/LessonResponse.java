package tech.shaderdojo.backend.dtos;

import tech.shaderdojo.backend.models.Lesson;

public record LessonResponse(
        String id,
        String courseId,
        String courseSlug,
        String courseTitle,
        String slug,
        String title,
        int displayOrder,
        String description,
        String starterVertexShader,
        String starterFragmentShader,
        boolean verified
) {
    public static LessonResponse from(Lesson l) {
        var course = l.getCourse();
        return new LessonResponse(
                l.getId(),
                course != null ? course.getId() : null,
                course != null ? course.getSlug() : null,
                course != null ? course.getTitle() : null,
                l.getSlug(),
                l.getTitle(),
                l.getDisplayOrder(),
                l.getDescription(),
                l.getStarterVertexShader(),
                l.getStarterFragmentShader(),
                l.getHashedAnswer() != null
        );
    }
}
