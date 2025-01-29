package tech.shaderdojo.backend.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import tech.shaderdojo.backend.dtos.AccountRequest;
import tech.shaderdojo.backend.dtos.AccountResponse;
import tech.shaderdojo.backend.dtos.AttemptResponse;
import tech.shaderdojo.backend.dtos.ProfileRequest;
import tech.shaderdojo.backend.models.Account;
import tech.shaderdojo.backend.models.Attempt;
import tech.shaderdojo.backend.models.Comment;
import tech.shaderdojo.backend.models.enums.AttemptStatus;
import tech.shaderdojo.backend.repositories.AccountRepository;
import tech.shaderdojo.backend.repositories.AttemptRepository;
import tech.shaderdojo.backend.repositories.CommentRepository;
import tech.shaderdojo.backend.repositories.ProblemRepository;

import java.util.Optional;

import static tech.shaderdojo.backend.utils.WebsiteUtils.extractUserIdFromJwt;

@RestController
@RequestMapping("/account")
public class AccountController {

    @Autowired
    private AccountRepository accountRepository;
    @Autowired
    private ProblemRepository problemRepository;
    @Autowired
    private CommentRepository commentRepository;
    @Autowired
    private AttemptRepository attemptRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostMapping("/comment/{problemId}")
    public ResponseEntity<Comment> createComment(@RequestBody Comment comment, @PathVariable String problemId, Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);

        accountRepository.findById(userId).ifPresent(comment::setAccount);
        comment.setProblem(problemRepository.findById(problemId).orElseThrow());
        return new ResponseEntity<>(commentRepository.save(comment), HttpStatus.CREATED);
    }

    @GetMapping("/status/{problemId}")
    public ResponseEntity<AttemptResponse> getProblemAttemptStatus(@PathVariable String problemId, Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);

        var attempts = attemptRepository.findAllByProblemIdAndAccountId(problemId, userId);
        if (attempts.isEmpty() || attempts.get().isEmpty()) {
            return new ResponseEntity<>(new AttemptResponse(0, AttemptStatus.UNATTEMPTED), HttpStatus.OK);
        } else {
            var attemptList = attempts.get();
            Optional<Attempt> checkSuccess = attemptList.stream()
                    .filter(attempt -> attempt.getStatus() == AttemptStatus.SUCCESSFUL)
                    .findFirst();
            if (checkSuccess.isPresent()) {
                return new ResponseEntity<>(new AttemptResponse(attemptList.size(), AttemptStatus.SUCCESSFUL), HttpStatus.OK);
            } else {
                return new ResponseEntity<>(new AttemptResponse(attemptList.size(), AttemptStatus.FAILED), HttpStatus.OK);
            }
        }
    }

    @GetMapping("/verify_account")
    public ResponseEntity<Boolean> verifyAccount(Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);
        return new ResponseEntity<>(accountRepository.existsById(userId), HttpStatus.OK);
    }

    @GetMapping
    public ResponseEntity<AccountResponse> getAccount(Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);
        return new ResponseEntity<>(new AccountResponse(accountRepository.findById(userId).orElseThrow()), HttpStatus.OK);
    }

    @PostMapping("/profile_info")
    public ResponseEntity<String> updateProfile(@RequestBody ProfileRequest account, Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);
        Account existingAccount = accountRepository.findById(userId).orElseThrow();
        existingAccount.setEmail(account.email());
        existingAccount.setBio(account.bio());
        existingAccount.setCountry(account.country());

        accountRepository.save(existingAccount);

        return new ResponseEntity<>("Profile updated", HttpStatus.OK);
    }

    @PostMapping("/account_info")
    public ResponseEntity<String> updateAccount(@RequestBody AccountRequest account, Authentication authentication) {
        String userId = extractUserIdFromJwt(authentication);
        Account existingAccount = accountRepository.findById(userId).orElseThrow();

        if (!passwordEncoder.matches(account.oldPassword(), existingAccount.getPassword())) {
            return new ResponseEntity<>("Incorrect password", HttpStatus.BAD_REQUEST);
        }

        existingAccount.setUsername(account.username());
        existingAccount.setPassword(passwordEncoder.encode(account.password()));

        try {
            accountRepository.save(existingAccount);
        } catch (Exception e) {
            return new ResponseEntity<>("Username already exists", HttpStatus.CONFLICT);
        }
        return new ResponseEntity<>("Account updated", HttpStatus.OK);
    }

}
