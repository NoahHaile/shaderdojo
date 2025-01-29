package tech.shaderdojo.backend.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import tech.shaderdojo.backend.dtos.AccountResponse;
import tech.shaderdojo.backend.dtos.VerifyProblemRequest;
import tech.shaderdojo.backend.models.Attempt;
import tech.shaderdojo.backend.models.Problem;
import tech.shaderdojo.backend.models.enums.AttemptStatus;
import tech.shaderdojo.backend.repositories.AccountRepository;
import tech.shaderdojo.backend.repositories.AttemptRepository;
import tech.shaderdojo.backend.repositories.CommentRepository;
import tech.shaderdojo.backend.repositories.ProblemRepository;

import java.util.List;

import static tech.shaderdojo.backend.utils.WebsiteUtils.extractUserIdFromJwt;

@RestController
@RequestMapping("/problems")
public class ProblemController {
    @Autowired
    private ProblemRepository problemRepository;

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private AttemptRepository attemptRepository;

    @Autowired
    private AccountRepository accountRepository;

    @Value("${api.key}")
    private String apiKey;

    @PostMapping("/verify")
    public ResponseEntity<String> verifyProblem(@RequestBody VerifyProblemRequest request, Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);
        var account = accountRepository.findById(userId).orElseThrow();

        Problem problem = problemRepository.findById(request.problemId()).orElse(null);
        if (problem == null) {
            return new ResponseEntity<>("Problem not found", HttpStatus.NOT_FOUND);
        }
        if (problem.getHashedAnswer().equals(request.hash())) {
            attemptRepository.save(new Attempt(problem, account, AttemptStatus.SUCCESSFUL));
            return new ResponseEntity<>("Correct hash.", HttpStatus.OK);
        }
        attemptRepository.save(new Attempt(problem, account, AttemptStatus.FAILED));
        return new ResponseEntity<>("Incorrect hash.", HttpStatus.BAD_REQUEST);
    }

    @PostMapping
    public ResponseEntity<Problem> createProblem(@RequestBody Problem problem, @RequestHeader("Admin-Authorization") String token) {
        if (!token.equals(apiKey)) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
        problemRepository.save(problem);
        return new ResponseEntity<>(problem, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Problem> updateProblem(@RequestBody Problem problem, @PathVariable String id, @RequestHeader("Admin-Authorization") String token) {
        if (!token.equals(apiKey)) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
        Problem existingProblem = problemRepository.findById(id).orElse(null);
        if (existingProblem == null) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        existingProblem.setHashedAnswer(problem.getHashedAnswer());
        return new ResponseEntity<>(problemRepository.save(existingProblem), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteProblem(@PathVariable String id, @RequestHeader("Admin-Authorization") String token) {

        if (!token.equals(apiKey)) {
            return new ResponseEntity<>("", HttpStatus.UNAUTHORIZED);
        }
        Problem existingProblem = problemRepository.findById(id).orElse(null);
        if (existingProblem == null) {
            return new ResponseEntity<>("", HttpStatus.NOT_FOUND);
        }
        problemRepository.delete(existingProblem);
        return new ResponseEntity<>("", HttpStatus.NO_CONTENT);
    }
}
