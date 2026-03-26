package com.syncforge.task;

import com.syncforge.common.security.SecurityUtils;
import com.syncforge.notification.NotificationService;
import com.syncforge.project.ProjectSecurityService;
import com.syncforge.user.User;
import com.syncforge.websocket.SocketEvent;
import com.syncforge.websocket.WebSocketService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;
    private final ProjectSecurityService projectSecurityService;
    private final WebSocketService webSocketService;
    private final NotificationService notificationService;

    public Task createTask(String projectId, CreateTaskRequest request) {

        // 🔐 SECURITY CHECK
        projectSecurityService.validateProjectMember(projectId);

        User currentUser = SecurityUtils.getCurrentUser();

        Task task = Task.builder()
                .projectId(projectId)
                .title(request.title())
                .description(request.description())
                .assignedTo(request.assignedTo())
                .createdBy(currentUser.getId())
                .status(TaskStatus.TODO)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        // 💾 SAVE TASK
        Task savedTask = taskRepository.save(task);

        // ⚡ REAL-TIME EVENT → TASK_CREATED
        SocketEvent event = SocketEvent.builder()
                .type("TASK_CREATED")
                .data(savedTask)
                .build();

        webSocketService.sendProjectEvent(projectId, event);

        // 🔔 NOTIFICATION (assigned user)
        if (request.assignedTo() != null) {
            notificationService.sendNotification(
                    request.assignedTo(),
                    "New task assigned: " + request.title(),
                    savedTask.getId()
            );
        }

        return savedTask;
    }

    public List<Task> getProjectTasks(String projectId) {

        // 🔐 SECURITY CHECK
        projectSecurityService.validateProjectMember(projectId);

        return taskRepository.findByProjectId(projectId);
    }

    public Task updateTaskStatus(String taskId, UpdateTaskStatusRequest request) {

        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found"));

        // 🔐 SECURITY CHECK
        projectSecurityService.validateProjectMember(task.getProjectId());

        task.setStatus(request.status());
        task.setUpdatedAt(Instant.now());

        // 💾 SAVE UPDATED TASK
        Task updatedTask = taskRepository.save(task);

        // ⚡ REAL-TIME EVENT → TASK_STATUS_UPDATED
        SocketEvent event = SocketEvent.builder()
                .type("TASK_STATUS_UPDATED")
                .data(updatedTask)
                .build();

        webSocketService.sendProjectEvent(task.getProjectId(), event);

        // 🔔 NOTIFICATION (assigned user)
        if (task.getAssignedTo() != null) {
            notificationService.sendNotification(
                    task.getAssignedTo(),
                    "Task status updated to " + request.status(),
                    task.getId()
            );
        }

        return updatedTask;
    }
}