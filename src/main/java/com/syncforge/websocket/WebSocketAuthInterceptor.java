package com.syncforge.websocket;

import com.syncforge.auth.JwtService;
import com.syncforge.user.User;
import com.syncforge.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.server.HandshakeInterceptor;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements HandshakeInterceptor {

    private final JwtService jwtService;
    private final UserRepository userRepository;

    @Override
    public boolean beforeHandshake(ServerHttpRequest request,
                                   ServerHttpResponse response,
                                   org.springframework.web.socket.WebSocketHandler wsHandler,
                                   Map<String, Object> attributes) {

        String query = request.getURI().getQuery();

        if (query == null || !query.contains("token=")) {
            return false;
        }

        String token = query.split("token=")[1];

        try {
            String email = jwtService.extractUsername(token);

            User user = userRepository.findByEmail(email).orElse(null);

            if (user == null) {
                return false;
            }

            // Attach user to WebSocket session
            attributes.put("user", user);

            return true;

        } catch (Exception e) {
            return false;
        }
    }

    @Override
    public void afterHandshake(ServerHttpRequest request,
                               ServerHttpResponse response,
                               org.springframework.web.socket.WebSocketHandler wsHandler,
                               Exception exception) {
    }
}