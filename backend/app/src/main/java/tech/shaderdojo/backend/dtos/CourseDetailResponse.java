package tech.shaderdojo.backend.dtos;

import tech.shaderdojo.backend.models.Course;
import tech.shaderdojo.backend.models.Lesson;

import java.util.List;

public record CourseDetailResponse(
        String id,
        String slug,
        String title,
        String description,
        int displayOrder,
        List<LessonSummary> lessons
) {
    public static CourseDetailResponse from(Course c, List<Lesson> lessons) {
        return new CourseDetailResponse(
                c.getId(), c.getSlug(), c.getTitle(), c.getDescription(), c.getDisplayOrder(),
                lessons.stream().map(LessonSummary::from).toList()
        );
    }
}
