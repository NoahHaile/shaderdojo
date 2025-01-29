package tech.shaderdojo.backend.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import tech.shaderdojo.backend.models.Comment;
import tech.shaderdojo.backend.repositories.CommentRepository;
import tech.shaderdojo.backend.repositories.ProblemRepository;

import java.util.List;

@RestController
@RequestMapping("/comments")
public class CommentController {
    @Autowired
    private CommentRepository commentRepository;
    @Autowired
    private ProblemRepository problemRepository;

    @Value("${api.key}")
    private String apiKey;


    @GetMapping("/{problemId}")
    public ResponseEntity<List<Comment>> getComments(@PathVariable String problemId) {
        return new ResponseEntity<>(commentRepository.findAllByProblemId(problemId), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteComment(@PathVariable String id, @RequestHeader("Admin-Authorization") String token) {
        if (!token.equals(apiKey)) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
        commentRepository.deleteById(id);
        return new ResponseEntity<>(HttpStatus.GONE);
    }
}
