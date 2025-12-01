package com.skillswap.skill.repositories;

import com.skillswap.skill.model.PartnerPlace;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface PartnerPlaceRepository extends MongoRepository<PartnerPlace, UUID> {
}
