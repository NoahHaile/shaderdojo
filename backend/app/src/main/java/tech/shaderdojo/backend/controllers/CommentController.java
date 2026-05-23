package tech.shaderdojo.backend.controllers;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import tech.shaderdojo.backend.dtos.CommentResponse;
import tech.shaderdojo.backend.repositories.CommentRepository;
import tech.shaderdojo.backend.utils.AdminAuth;

import java.util.List;

@RestController
@RequestMapping("/comments")
public class CommentController {

    private final CommentRepository commentRepository;
    private final String apiKey;

    public CommentController(CommentRepository commentRepository,
                             @Value("${api.key}") String apiKey) {
        this.commentRepository = commentRepository;
        this.apiKey = apiKey;
    }

    @GetMapping("/{problemId}")
    public ResponseEntity<List<CommentResponse>> getComments(@PathVariable String problemId) {
        List<CommentResponse> comments = commentRepository.findAllByProblemId(problemId)
                .stream()
                .map(CommentResponse::from)
                .toList();
        return new ResponseEntity<>(comments, HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteComment(@PathVariable String id,
                                              @RequestHeader("Admin-Authorization") String token) {
        if (!AdminAuth.matches(token, apiKey)) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
        commentRepository.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
