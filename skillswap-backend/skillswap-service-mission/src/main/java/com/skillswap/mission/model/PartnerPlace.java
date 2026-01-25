package com.skillswap.mission.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document("partner_places")
public class PartnerPlace {
    
    @Id
    private UUID id;
    private String name;
    private String address;
    private String city;
    private Double latitude;
    private Double longitude;
    private String type; // CAFE, COWORKING, LIBRARY, etc.
    private Boolean active;
    private String phoneNumber;
    private String description;
}
