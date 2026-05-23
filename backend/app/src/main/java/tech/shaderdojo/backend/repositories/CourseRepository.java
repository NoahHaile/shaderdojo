package tech.shaderdojo.backend.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import tech.shaderdojo.backend.models.Course;

import java.util.List;
import java.util.Optional;

public interface CourseRepository extends JpaRepository<Course, String> {
    List<Course> findAllByOrderByDisplayOrderAscTitleAsc();
    Optional<Course> findBySlug(String slug);
}
