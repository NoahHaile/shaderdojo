package com.clickedtools.auth.auth;

import com.clickedtools.auth.user.Account;
import com.clickedtools.auth.user.AccountRepository;
import com.clickedtools.auth.user.LoginRequest;
import com.clickedtools.auth.user.RegisterRequest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
public class AuthController {

    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;

    public AuthController(AccountRepository accountRepository,
                          PasswordEncoder passwordEncoder,
                          TokenService tokenService) {
        this.accountRepository = accountRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenService = tokenService;
    }

    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody LoginRequest request) {
        if (request == null || request.username() == null || request.password() == null) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        Optional<Account> optionalAccount = accountRepository
                .findByUsernameOrEmail(request.username(), request.username());
        if (optionalAccount.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
        Account account = optionalAccount.get();
        if (!passwordEncoder.matches(request.password(), account.getPassword())) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
        return new ResponseEntity<>(tokenService.generateToken(account.getId(), "user"), HttpStatus.OK);
    }

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterRequest request) {
        if (request == null || request.username() == null || request.password() == null) {
            return new ResponseEntity<>("Username and password are required.", HttpStatus.BAD_REQUEST);
        }
        Account account = new Account(
                request.username(),
                passwordEncoder.encode(request.password()),
                request.email());
        try {
            accountRepository.save(account);
        } catch (DataIntegrityViolationException e) {
            return new ResponseEntity<>("Username already exists", HttpStatus.CONFLICT);
        }
        return new ResponseEntity<>(tokenService.generateToken(account.getId(), "user"), HttpStatus.OK);
    }
}
