package tech.shaderdojo.backend.dtos;

import tech.shaderdojo.backend.models.Lesson;

public record LessonSummary(
        String id,
        String slug,
        String title,
        int displayOrder,
        boolean verified
) {
    public static LessonSummary from(Lesson l) {
        return new LessonSummary(l.getId(), l.getSlug(), l.getTitle(),
                l.getDisplayOrder(), l.getHashedAnswer() != null);
    }
}
