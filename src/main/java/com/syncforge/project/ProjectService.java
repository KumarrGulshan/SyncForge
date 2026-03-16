package com.syncforge.project;

import com.syncforge.common.security.SecurityUtils;
import com.syncforge.user.Role;
import com.syncforge.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.ArrayList;
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

        List<ProjectMember> members = new ArrayList<>();
        members.add(ownerMember);

        Project project = Project.builder()
                .name(name)
                .description(description)
                .ownerId(user.getId())
                .members(members)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        return projectRepository.save(project);
    }

    public List<Project> getUserProjects() {

        User user = SecurityUtils.getCurrentUser();

        return projectRepository.findByMembersUserId(user.getId());
    }

    public Project addMember(String projectId, AddMemberRequest request) {

        User currentUser = SecurityUtils.getCurrentUser();

        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new RuntimeException("Project not found"));

        // Check if current user is ADMIN of the project
        boolean isAdmin = project.getMembers().stream()
                .anyMatch(member ->
                        member.getUserId().equals(currentUser.getId()) &&
                                member.getRole() == Role.ADMIN
                );

        if (!isAdmin) {
            throw new RuntimeException("Only project admin can add members");
        }

        // Prevent duplicate members
        boolean alreadyMember = project.getMembers().stream()
                .anyMatch(member ->
                        member.getUserId().equals(request.userId())
                );

        if (alreadyMember) {
            throw new RuntimeException("User already a project member");
        }

        ProjectMember newMember = ProjectMember.builder()
                .userId(request.userId())
                .role(Role.MEMBER)
                .build();

        project.getMembers().add(newMember);
        project.setUpdatedAt(Instant.now());

        return projectRepository.save(project);
    }
}