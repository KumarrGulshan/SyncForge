package com.syncforge.notification;

import com.syncforge.websocket.WebSocketService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final WebSocketService webSocketService;

    public void sendNotification(String userId, String message, String referenceId) {

        System.out.println("NotificationService triggered");

        Notification notification = Notification.builder()
                .userId(userId)
                .message(message)
                .referenceId(referenceId)
                .isRead(false)
                .createdAt(Instant.now())
                .build();

        Notification saved = notificationRepository.save(notification);

        System.out.println("Saved notification ID: " + saved.getId());

        webSocketService.sendUserNotification(userId, saved);
    }
}