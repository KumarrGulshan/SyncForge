package com.syncforge.notification;

import com.syncforge.auth.JwtService;
import com.syncforge.user.User;
import com.syncforge.user.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;
    private final JwtService jwtService;

    @GetMapping
    public List<Notification> getNotifications(HttpServletRequest request) {

        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new RuntimeException("Missing Authorization header");
        }

        String token = authHeader.substring(7);
        String email = jwtService.extractUsername(token);

        System.out.println("EMAIL FROM JWT: " + email);

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        System.out.println("USER ID FROM DB: " + user.getId());

        List<Notification> notifications =
                notificationRepository.findByUserIdOrderByCreatedAtDesc(user.getId());

        System.out.println("NOTIFICATION COUNT: " + notifications.size());

        return notifications;
    }
}