package tech.shaderdojo.backend.controllers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import tech.shaderdojo.backend.dtos.CreateLessonRequest;
import tech.shaderdojo.backend.dtos.LessonResponse;
import tech.shaderdojo.backend.dtos.LessonSolutionResponse;
import tech.shaderdojo.backend.dtos.UpdateLessonRequest;
import tech.shaderdojo.backend.dtos.VerifyLessonRequest;
import tech.shaderdojo.backend.models.Account;
import tech.shaderdojo.backend.models.Attempt;
import tech.shaderdojo.backend.models.Course;
import tech.shaderdojo.backend.models.Lesson;
import tech.shaderdojo.backend.models.enums.AttemptStatus;
import tech.shaderdojo.backend.repositories.AccountRepository;
import tech.shaderdojo.backend.repositories.AttemptRepository;
import tech.shaderdojo.backend.repositories.CourseRepository;
import tech.shaderdojo.backend.repositories.LessonRepository;
import tech.shaderdojo.backend.services.ShaderValidatorClient;
import tech.shaderdojo.backend.utils.AdminAuth;

import java.util.Optional;

import static tech.shaderdojo.backend.utils.WebsiteUtils.extractUserIdFromJwt;

@RestController
@RequestMapping("/lessons")
public class LessonController {

    private static final Logger logger = LoggerFactory.getLogger(LessonController.class);

    private final LessonRepository lessonRepository;
    private final CourseRepository courseRepository;
    private final AttemptRepository attemptRepository;
    private final AccountRepository accountRepository;
    private final ShaderValidatorClient validatorClient;
    private final String apiKey;

    public LessonController(LessonRepository lessonRepository,
                            CourseRepository courseRepository,
                            AttemptRepository attemptRepository,
                            AccountRepository accountRepository,
                            ShaderValidatorClient validatorClient,
                            @Value("${api.key}") String apiKey) {
        this.lessonRepository = lessonRepository;
        this.courseRepository = courseRepository;
        this.attemptRepository = attemptRepository;
        this.accountRepository = accountRepository;
        this.validatorClient = validatorClient;
        this.apiKey = apiKey;
    }

    @GetMapping("/{id}")
    public ResponseEntity<LessonResponse> get(@PathVariable String id) {
        return lessonRepository.findById(id)
                .map(l -> ResponseEntity.ok(LessonResponse.from(l)))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}/solution")
    public ResponseEntity<LessonSolutionResponse> getSolution(@PathVariable String id) {
        return lessonRepository.findById(id)
                .map(l -> ResponseEntity.ok(new LessonSolutionResponse(
                        l.getId(), l.getTitle(),
                        l.getCanonicalFragmentShader(), l.getStarterVertexShader())))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping("/verify")
    @Transactional
    public ResponseEntity<String> verify(@RequestBody VerifyLessonRequest request,
                                         Authentication authentication) {
        if (request == null || request.lessonId() == null
                || request.vertexShader() == null || request.fragmentShader() == null) {
            return new ResponseEntity<>("Invalid request.", HttpStatus.BAD_REQUEST);
        }

        String userId = extractUserIdFromJwt(authentication);
        Optional<Account> accountOpt = accountRepository.findById(userId);
        if (accountOpt.isEmpty()) {
            return new ResponseEntity<>("Account not found.", HttpStatus.UNAUTHORIZED);
        }

        Optional<Lesson> lessonOpt = lessonRepository.findById(request.lessonId());
        if (lessonOpt.isEmpty()) {
            return new ResponseEntity<>("Lesson not found.", HttpStatus.NOT_FOUND);
        }
        Lesson lesson = lessonOpt.get();

        if (lesson.getHashedAnswer() == null) {
            return new ResponseEntity<>("This lesson is exploratory and cannot be verified.",
                    HttpStatus.BAD_REQUEST);
        }

        var result = validatorClient.executeShader(
                request.vertexShader(), request.fragmentShader(), request.time());

        if (!result.isOk()) {
            if (result.compileError()) {
                return new ResponseEntity<>("Shader compile error.", HttpStatus.BAD_REQUEST);
            }
            logger.warn("Validator error for lesson {}: {}", lesson.getId(), result.error());
            return new ResponseEntity<>("Validator unavailable.", HttpStatus.BAD_GATEWAY);
        }

        boolean correct = AdminAuth.matches(result.imageHash(), lesson.getHashedAnswer());

        attemptRepository.save(new Attempt(lesson, accountOpt.get(),
                correct ? AttemptStatus.SUCCESSFUL : AttemptStatus.FAILED));

        return correct
                ? new ResponseEntity<>("Correct.", HttpStatus.OK)
                : new ResponseEntity<>("Incorrect.", HttpStatus.BAD_REQUEST);
    }

    @PostMapping
    public ResponseEntity<LessonResponse> create(@RequestBody CreateLessonRequest req,
                                                 @RequestHeader("Admin-Authorization") String token) {
        if (!AdminAuth.matches(token, apiKey)) return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        if (req == null || req.courseId() == null || req.slug() == null || req.title() == null) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        Optional<Course> courseOpt = courseRepository.findById(req.courseId());
        if (courseOpt.isEmpty()) return new ResponseEntity<>(HttpStatus.NOT_FOUND);

        Lesson l = new Lesson();
        l.setCourse(courseOpt.get());
        l.setSlug(req.slug());
        l.setDisplayOrder(req.displayOrder() == null ? 0 : req.displayOrder());
        l.setTitle(req.title());
        l.setDescription(req.description());
        l.setStarterVertexShader(req.starterVertexShader());
        l.setStarterFragmentShader(req.starterFragmentShader());
        l.setCanonicalFragmentShader(req.canonicalFragmentShader());
        l.setHashedAnswer(req.hashedAnswer());
        return new ResponseEntity<>(LessonResponse.from(lessonRepository.save(l)), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<LessonResponse> update(@PathVariable String id,
                                                 @RequestBody UpdateLessonRequest req,
                                                 @RequestHeader("Admin-Authorization") String token) {
        if (!AdminAuth.matches(token, apiKey)) return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        Optional<Lesson> existingOpt = lessonRepository.findById(id);
        if (existingOpt.isEmpty()) return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        Lesson existing = existingOpt.get();
        if (req.slug() != null) existing.setSlug(req.slug());
        if (req.displayOrder() != null) existing.setDisplayOrder(req.displayOrder());
        if (req.title() != null) existing.setTitle(req.title());
        if (req.description() != null) existing.setDescription(req.description());
        if (req.starterVertexShader() != null) existing.setStarterVertexShader(req.starterVertexShader());
        if (req.starterFragmentShader() != null) existing.setStarterFragmentShader(req.starterFragmentShader());
        if (req.canonicalFragmentShader() != null) existing.setCanonicalFragmentShader(req.canonicalFragmentShader());
        if (req.hashedAnswer() != null) existing.setHashedAnswer(req.hashedAnswer());
        return ResponseEntity.ok(LessonResponse.from(lessonRepository.save(existing)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable String id,
                                       @RequestHeader("Admin-Authorization") String token) {
        if (!AdminAuth.matches(token, apiKey)) return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        if (!lessonRepository.existsById(id)) return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        lessonRepository.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
