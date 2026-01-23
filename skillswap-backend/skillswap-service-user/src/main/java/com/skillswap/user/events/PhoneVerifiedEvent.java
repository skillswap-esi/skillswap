package com.skillswap.user.events;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.UUID;

/**
 * Événement publié sur Kafka lorsqu'un utilisateur vérifie son téléphone.
 * Cet événement peut être consommé par le service de notification
 * pour envoyer une notification de bienvenue.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PhoneVerifiedEvent {
    
    private UUID userId;
    private String email;
    private String phoneNumber;
    private int bonusCredits;
    private Date timestamp;
}
