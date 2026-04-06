package com.syncforge.project;

import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface ProjectRepository extends MongoRepository<Project, String> {


    List<Project> findByOwnerId(String ownerId);


    List<Project> findByMembersUserId(String userId);


    List<Project> findByOwnerIdOrMembersUserId(String ownerId, String userId);

}

