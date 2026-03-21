package com.syncforge.comment;

import com.syncforge.common.security.SecurityUtils;
import com.syncforge.project.ProjectSecurityService;
import com.syncforge.task.Task;
import com.syncforge.task.TaskRepository;
import com.syncforge.user.User;
import com.syncforge.websocket.WebSocketService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CommentService {

    private final CommentRepository commentRepository;
    private final TaskRepository taskRepository;
    private final ProjectSecurityService projectSecurityService;
    private final WebSocketService webSocketService;

    public Comment addComment(String taskId, AddCommentRequest request) {

        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));

        projectSecurityService.validateProjectMember(task.getProjectId());

        User user = SecurityUtils.getCurrentUser();

        Comment comment = Comment.builder()
                .taskId(taskId)
                .userId(user.getId())
                .message(request.message())
                .createdAt(Instant.now())
                .build();

        Comment saved = commentRepository.save(comment);


        webSocketService.sendTaskUpdate(task.getProjectId(), saved);

        return saved;
    }

    public List<Comment> getComments(String taskId) {

        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));

        projectSecurityService.validateProjectMember(task.getProjectId());

        return commentRepository.findByTaskId(taskId);
    }
}