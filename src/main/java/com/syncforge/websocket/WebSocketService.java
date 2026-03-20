package com.syncforge.websocket;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class WebSocketService {

    private final SimpMessagingTemplate messagingTemplate;

    public void sendTaskUpdate(String projectId, Object payload) {

        messagingTemplate.convertAndSend(
                "/topic/project/" + projectId,
                payload
        );
    }
}