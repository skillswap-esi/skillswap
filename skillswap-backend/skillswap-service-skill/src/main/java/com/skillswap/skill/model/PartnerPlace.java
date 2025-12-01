package com.skillswap.skill.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.geo.GeoJsonPoint;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document("partnerPlaces")
public class PartnerPlace {
    
    @Id
    private UUID placeId;
    
    private String name;
    private String address;
    private GeoJsonPoint geoPoint;
    private UUID addedBy;
    private Date createdAt;
}
