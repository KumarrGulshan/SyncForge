package com.syncforge.task;

public record CreateTaskRequest(

        String title,
        String description,
        String assignedTo

) {}