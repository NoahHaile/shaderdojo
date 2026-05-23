package tech.shaderdojo.backend.controllers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import tech.shaderdojo.backend.dtos.VerifyProblemRequest;
import tech.shaderdojo.backend.models.Account;
import tech.shaderdojo.backend.models.Attempt;
import tech.shaderdojo.backend.models.Problem;
import tech.shaderdojo.backend.models.enums.AttemptStatus;
import tech.shaderdojo.backend.repositories.AccountRepository;
import tech.shaderdojo.backend.repositories.AttemptRepository;
import tech.shaderdojo.backend.repositories.ProblemRepository;
import tech.shaderdojo.backend.services.ShaderValidatorClient;
import tech.shaderdojo.backend.utils.AdminAuth;

import java.util.Optional;

import static tech.shaderdojo.backend.utils.WebsiteUtils.extractUserIdFromJwt;

@RestController
@RequestMapping("/problems")
public class ProblemController {

    private final ProblemRepository problemRepository;
    private final AttemptRepository attemptRepository;
    private final AccountRepository accountRepository;
    private final ShaderValidatorClient validatorClient;
    private final String apiKey;

    private static final Logger logger = LoggerFactory.getLogger(ProblemController.class);

    public ProblemController(ProblemRepository problemRepository,
                             AttemptRepository attemptRepository,
                             AccountRepository accountRepository,
                             ShaderValidatorClient validatorClient,
                             @Value("${api.key}") String apiKey) {
        this.problemRepository = problemRepository;
        this.attemptRepository = attemptRepository;
        this.accountRepository = accountRepository;
        this.validatorClient = validatorClient;
        this.apiKey = apiKey;
    }

    @PostMapping("/verify")
    @Transactional
    public ResponseEntity<String> verifyProblem(@RequestBody VerifyProblemRequest request, Authentication authentication) {
        if (request == null || request.problemId() == null
                || request.vertexShader() == null || request.fragmentShader() == null) {
            return new ResponseEntity<>("Invalid request.", HttpStatus.BAD_REQUEST);
        }

        String userId = extractUserIdFromJwt(authentication);
        Optional<Account> accountOpt = accountRepository.findById(userId);
        if (accountOpt.isEmpty()) {
            return new ResponseEntity<>("Account not found.", HttpStatus.UNAUTHORIZED);
        }

        Problem problem = problemRepository.findById(request.problemId()).orElse(null);
        if (problem == null) {
            return new ResponseEntity<>("Problem not found.", HttpStatus.NOT_FOUND);
        }

        var result = validatorClient.executeShader(
                request.vertexShader(), request.fragmentShader(), request.time());

        if (!result.isOk()) {
            if (result.compileError()) {
                return new ResponseEntity<>("Shader compile error.", HttpStatus.BAD_REQUEST);
            }
            logger.warn("Validator error for problem {}: {}", problem.getId(), result.error());
            return new ResponseEntity<>("Validator unavailable.", HttpStatus.BAD_GATEWAY);
        }

        boolean correct = problem.getHashedAnswer() != null
                && AdminAuth.matches(result.imageHash(), problem.getHashedAnswer());

        attemptRepository.save(new Attempt(problem, accountOpt.get(),
                correct ? AttemptStatus.SUCCESSFUL : AttemptStatus.FAILED));

        return correct
                ? new ResponseEntity<>("Correct hash.", HttpStatus.OK)
                : new ResponseEntity<>("Incorrect hash.", HttpStatus.BAD_REQUEST);
    }

    @PostMapping
    public ResponseEntity<Problem> createProblem(@RequestBody Problem problem,
                                                 @RequestHeader("Admin-Authorization") String token) {
        if (!AdminAuth.matches(token, apiKey)) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
        problemRepository.save(problem);
        return new ResponseEntity<>(problem, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Problem> updateProblem(@RequestBody Problem problem,
                                                 @PathVariable String id,
                                                 @RequestHeader("Admin-Authorization") String token) {
        if (!AdminAuth.matches(token, apiKey)) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
        Problem existing = problemRepository.findById(id).orElse(null);
        if (existing == null) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        existing.setHashedAnswer(problem.getHashedAnswer());
        return new ResponseEntity<>(problemRepository.save(existing), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteProblem(@PathVariable String id,
                                                @RequestHeader("Admin-Authorization") String token) {
        if (!AdminAuth.matches(token, apiKey)) {
            return new ResponseEntity<>("", HttpStatus.UNAUTHORIZED);
        }
        Problem existing = problemRepository.findById(id).orElse(null);
        if (existing == null) {
            return new ResponseEntity<>("", HttpStatus.NOT_FOUND);
        }
        problemRepository.delete(existing);
        return new ResponseEntity<>("", HttpStatus.NO_CONTENT);
    }
}
