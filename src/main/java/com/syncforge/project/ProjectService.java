package com.syncforge.project;

import com.syncforge.common.security.SecurityUtils;
import com.syncforge.user.Role;
import com.syncforge.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProjectService {

    private final ProjectRepository projectRepository;

    public Project createProject(String name, String description) {

        User user = SecurityUtils.getCurrentUser();

        ProjectMember ownerMember = ProjectMember.builder()
                .userId(user.getId())
                .role(Role.ADMIN)
                .build();

        Project project = Project.builder()
                .name(name)
                .description(description)
                .ownerId(user.getId())
                .members(List.of(ownerMember))
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        return projectRepository.save(project);
    }

    public List<Project> getUserProjects() {

        User user = SecurityUtils.getCurrentUser();

        return projectRepository.findByMembersUserId(user.getId());
    }
}