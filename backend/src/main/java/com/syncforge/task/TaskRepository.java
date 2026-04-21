package com.syncforge.task;

import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface TaskRepository extends MongoRepository<Task, String> {

    // Tasks for a specific project
    List<Task> findByProjectId(String projectId);

    // Count tasks by status
    long countByStatus(String status);

    // Count tasks assigned to a user
    long countByAssignedTo(String userId);

    // Count tasks assigned to a user with a specific status
    long countByAssignedToAndStatus(String userId, String status);

    // Get tasks assigned to a user
    List<Task> findByAssignedTo(String userId);

}