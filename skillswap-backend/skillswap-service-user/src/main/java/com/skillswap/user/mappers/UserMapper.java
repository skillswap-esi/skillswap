package com.skillswap.user.mappers;

import com.skillswap.user.dto.LedgerTransactionDto;
import com.skillswap.user.dto.UserDto;
import com.skillswap.user.model.LedgerTransaction;
import com.skillswap.user.model.User;
import org.springframework.stereotype.Component;

@Component
public class UserMapper {
    
    public UserDto toDto(User user) {
        if (user == null) {
            return null;
        }
        
        UserDto dto = new UserDto();
        dto.setUserId(user.getUserId());
        dto.setEmail(user.getEmail());
        dto.setPhoneNumber(user.getPhoneNumber());
        dto.setFullName(user.getFullName());
        dto.setPhoneVerified(user.isPhoneVerified());
        dto.setCreditsBalance(user.getCreditsBalance());
        dto.setHelperScore(user.getHelperScore());
        dto.setAvatar(user.getAvatar());
        dto.setRoles(user.getRoles());
        dto.setFcmTokens(user.getFcmTokens());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setUpdatedAt(user.getUpdatedAt());
        
        return dto;
    }
    
    public LedgerTransactionDto toDto(LedgerTransaction transaction) {
        if (transaction == null) {
            return null;
        }
        
        LedgerTransactionDto dto = new LedgerTransactionDto();
        dto.setTransactionId(transaction.getTransactionId());
        dto.setFromUserId(transaction.getFromUserId());
        dto.setToUserId(transaction.getToUserId());
        dto.setAmount(transaction.getAmount());
        dto.setMissionId(transaction.getMissionId());
        dto.setTimestamp(transaction.getTimestamp());
        dto.setDescription(transaction.getDescription());
        
        return dto;
    }
}
