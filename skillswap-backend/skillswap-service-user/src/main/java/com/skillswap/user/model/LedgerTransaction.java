package com.skillswap.user.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document("ledgerTransactions")
public class LedgerTransaction {
    
    @Id
    private UUID transactionId;
    
    private UUID fromUserId;
    private UUID toUserId;
    private int amount; // 5 (MVP)
    private UUID missionId;
    private Date timestamp;
}
