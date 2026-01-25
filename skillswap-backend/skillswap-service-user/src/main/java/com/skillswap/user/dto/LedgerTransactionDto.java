package com.skillswap.user.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LedgerTransactionDto {
    private UUID transactionId;
    private UUID fromUserId;
    private UUID toUserId;
    private int amount;
    private UUID missionId;
    private Date timestamp;
    private String description;
}
