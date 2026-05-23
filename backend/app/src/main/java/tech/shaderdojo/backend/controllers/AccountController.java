package tech.shaderdojo.backend.controllers;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import tech.shaderdojo.backend.dtos.*;
import tech.shaderdojo.backend.models.Account;
import tech.shaderdojo.backend.models.Attempt;
import tech.shaderdojo.backend.models.Comment;
import tech.shaderdojo.backend.models.Lesson;
import tech.shaderdojo.backend.models.enums.AttemptStatus;
import tech.shaderdojo.backend.repositories.AccountRepository;
import tech.shaderdojo.backend.repositories.AttemptRepository;
import tech.shaderdojo.backend.repositories.CommentRepository;
import tech.shaderdojo.backend.repositories.LessonRepository;

import java.util.List;
import java.util.Optional;

import static tech.shaderdojo.backend.utils.WebsiteUtils.extractUserIdFromJwt;

@RestController
@RequestMapping("/account")
public class AccountController {

    private final AccountRepository accountRepository;
    private final LessonRepository lessonRepository;
    private final CommentRepository commentRepository;
    private final AttemptRepository attemptRepository;
    private final PasswordEncoder passwordEncoder;

    public AccountController(AccountRepository accountRepository,
                             LessonRepository lessonRepository,
                             CommentRepository commentRepository,
                             AttemptRepository attemptRepository,
                             PasswordEncoder passwordEncoder) {
        this.accountRepository = accountRepository;
        this.lessonRepository = lessonRepository;
        this.commentRepository = commentRepository;
        this.attemptRepository = attemptRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping("/comment/{lessonId}")
    public ResponseEntity<CommentResponse> createComment(@RequestBody CommentRequest commentRequest,
                                                         @PathVariable String lessonId,
                                                         Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);

        Optional<Account> accountOpt = accountRepository.findById(userId);
        if (accountOpt.isEmpty()) return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);

        Optional<Lesson> lessonOpt = lessonRepository.findById(lessonId);
        if (lessonOpt.isEmpty()) return new ResponseEntity<>(HttpStatus.NOT_FOUND);

        Comment comment = new Comment();
        comment.setCode(commentRequest.code());
        comment.setContent(commentRequest.content());
        comment.setAccount(accountOpt.get());
        comment.setLesson(lessonOpt.get());

        Comment saved = commentRepository.save(comment);
        return new ResponseEntity<>(CommentResponse.from(saved), HttpStatus.CREATED);
    }

    @GetMapping("/status/{lessonId}")
    public ResponseEntity<AttemptResponse> getLessonAttemptStatus(@PathVariable String lessonId,
                                                                  Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);
        List<Attempt> attempts = attemptRepository.findAllByLessonIdAndAccountId(lessonId, userId);

        if (attempts.isEmpty()) {
            return new ResponseEntity<>(new AttemptResponse(0, AttemptStatus.UNATTEMPTED), HttpStatus.OK);
        }

        boolean anySuccess = attempts.stream().anyMatch(a -> a.getStatus() == AttemptStatus.SUCCESSFUL);
        AttemptStatus status = anySuccess ? AttemptStatus.SUCCESSFUL : AttemptStatus.FAILED;
        return new ResponseEntity<>(new AttemptResponse(attempts.size(), status), HttpStatus.OK);
    }

    @GetMapping("/verify_account")
    public ResponseEntity<Boolean> verifyAccount(Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);
        boolean exists = accountRepository.existsById(userId);
        return new ResponseEntity<>(exists, exists ? HttpStatus.OK : HttpStatus.NOT_FOUND);
    }

    @GetMapping
    public ResponseEntity<AccountResponse> getAccount(Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);
        return accountRepository.findById(userId)
                .map(a -> new ResponseEntity<>(new AccountResponse(a), HttpStatus.OK))
                .orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    @PostMapping("/profile_info")
    @Transactional
    public ResponseEntity<String> updateProfile(@RequestBody ProfileRequest account,
                                                Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);
        Optional<Account> existingOpt = accountRepository.findById(userId);
        if (existingOpt.isEmpty()) {
            return new ResponseEntity<>("Account not found.", HttpStatus.UNAUTHORIZED);
        }
        Account existing = existingOpt.get();
        existing.setEmail(account.email());
        existing.setBio(account.bio());
        existing.setCountry(account.country());
        accountRepository.save(existing);
        return new ResponseEntity<>("Profile updated", HttpStatus.OK);
    }

    @PostMapping("/account_info")
    @Transactional
    public ResponseEntity<String> updateAccount(@RequestBody AccountRequest account,
                                                Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);
        Optional<Account> existingOpt = accountRepository.findById(userId);
        if (existingOpt.isEmpty()) {
            return new ResponseEntity<>("Account not found.", HttpStatus.UNAUTHORIZED);
        }
        Account existing = existingOpt.get();

        if (!passwordEncoder.matches(account.oldPassword(), existing.getPassword())) {
            return new ResponseEntity<>("Incorrect password", HttpStatus.UNAUTHORIZED);
        }

        existing.setUsername(account.username());
        existing.setPassword(passwordEncoder.encode(account.password()));

        try {
            accountRepository.save(existing);
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            return new ResponseEntity<>("Username already exists", HttpStatus.CONFLICT);
        }
        return new ResponseEntity<>("Account updated", HttpStatus.OK);
    }
}
