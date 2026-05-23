package tech.shaderdojo.backend.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import tech.shaderdojo.backend.models.Attempt;

import java.util.List;

public interface AttemptRepository extends JpaRepository<Attempt, String> {
    List<Attempt> findAllByLessonIdAndAccountId(String lessonId, String accountId);
}
