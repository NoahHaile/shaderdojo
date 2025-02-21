package com.clickedtools.auth.auth;

import com.clickedtools.auth.user.Account;
import com.clickedtools.auth.user.AccountRepository;
import com.clickedtools.auth.user.LoginRequest;
import com.clickedtools.auth.user.RegisterRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.Optional;

@RestController
public class AuthController {

    @Autowired
    AccountRepository accountRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    TokenService tokenService;


    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody LoginRequest request) throws IOException {
        Optional<Account> optionalAccount = accountRepository.findByUsernameOrEmail(request.username(), request.username());
        if (optionalAccount.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }
        Account account = optionalAccount.get();
        if (passwordEncoder.matches(request.password(), account.getPassword())) {
            String token = tokenService.generateToken(account.getId(), "user");
            return new ResponseEntity<>(token, HttpStatus.OK);
        }
        return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
    }

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterRequest request) {
        String encodedPassword = passwordEncoder.encode(request.password());
        Account account = new Account(request.email(), request.username(), encodedPassword);
        try {
            accountRepository.save(account);
        } catch (Exception e) {
            return new ResponseEntity<>("Username already exists", HttpStatus.CONFLICT);
        }
        String token = tokenService.generateToken(account.getId(), "user");
        return new ResponseEntity<>(token, HttpStatus.OK);
    }


    @GetMapping("/ping")
    public String ping() {
        return "pong";

    }
}
