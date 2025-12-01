package com.skillswap.mission.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MeetingPoint {
    private double lat;
    private double lng;
    private UUID partnerPlaceId;
}
