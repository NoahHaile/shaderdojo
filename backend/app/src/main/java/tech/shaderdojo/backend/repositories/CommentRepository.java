package tech.shaderdojo.backend.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import tech.shaderdojo.backend.models.Comment;

import java.util.List;

public interface CommentRepository extends JpaRepository<Comment, String> {
    List<Comment> findAllByProblemId(String problemId);
}
