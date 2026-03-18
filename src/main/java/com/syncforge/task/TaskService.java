package com.syncforge.task;

import com.syncforge.common.security.SecurityUtils;
import com.syncforge.project.ProjectSecurityService;
import com.syncforge.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TaskService {

    private final TaskRepository taskRepository;
    private final ProjectSecurityService projectSecurityService;

    public Task createTask(String projectId, CreateTaskRequest request) {

        // 🔐 SECURITY CHECK
        // Ensure the current user belongs to this project
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

        return taskRepository.save(task);
    }

    public List<Task> getProjectTasks(String projectId) {

        // 🔐 SECURITY CHECK
        projectSecurityService.validateProjectMember(projectId);

        return taskRepository.findByProjectId(projectId);
    }
    public Task updateTaskStatus(String taskId, UpdateTaskStatusRequest request) {

        Task task = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Access denied"));

        projectSecurityService.validateProjectMember(task.getProjectId());

        task.setStatus(request.status());
        task.setUpdatedAt(Instant.now());

        return taskRepository.save(task);
    }

}