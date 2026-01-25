package com.skillswap.mission.repositories;

import com.skillswap.mission.model.PartnerPlace;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PartnerPlaceRepository extends MongoRepository<PartnerPlace, UUID> {
    List<PartnerPlace> findByActiveTrue();
    List<PartnerPlace> findByCity(String city);
}
