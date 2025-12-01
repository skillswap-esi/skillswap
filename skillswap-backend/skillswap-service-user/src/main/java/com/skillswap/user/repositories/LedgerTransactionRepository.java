package com.skillswap.user.repositories;

import com.skillswap.user.model.LedgerTransaction;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface LedgerTransactionRepository extends MongoRepository<LedgerTransaction, UUID> {
    
    List<LedgerTransaction> findByFromUserIdOrToUserId(UUID fromUserId, UUID toUserId);
    
    List<LedgerTransaction> findByMissionId(UUID missionId);
}
