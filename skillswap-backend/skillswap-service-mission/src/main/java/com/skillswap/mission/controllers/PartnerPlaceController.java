package com.skillswap.mission.controllers;

import com.skillswap.mission.model.PartnerPlace;
import com.skillswap.mission.repositories.PartnerPlaceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/missions/partner-places")
@RequiredArgsConstructor
@Slf4j
public class PartnerPlaceController {
    
    private final PartnerPlaceRepository partnerPlaceRepository;
    
    @GetMapping
    public ResponseEntity<List<PartnerPlace>> getActivePartnerPlaces() {
        log.info("GET /partner-places - Active only (for mobile)");
        List<PartnerPlace> places = partnerPlaceRepository.findByActiveTrue();
        return ResponseEntity.ok(places);
    }
    
    @GetMapping("/all")
    public ResponseEntity<List<PartnerPlace>> getAllPartnerPlaces() {
        log.info("GET /partner-places/all - All places (for backoffice)");
        List<PartnerPlace> places = partnerPlaceRepository.findAll();
        return ResponseEntity.ok(places);
    }
    
    @GetMapping("/city/{city}")
    public ResponseEntity<List<PartnerPlace>> getPartnerPlacesByCity(@PathVariable String city) {
        log.info("GET /partner-places/city/{}", city);
        List<PartnerPlace> places = partnerPlaceRepository.findByCity(city);
        return ResponseEntity.ok(places);
    }
    
    @PostMapping
    public ResponseEntity<PartnerPlace> createPartnerPlace(@RequestBody PartnerPlace place) {
        log.info("POST /partner-places - Creating: {}", place.getName());
        if (place.getId() == null) {
            place.setId(UUID.randomUUID());
        }
        PartnerPlace saved = partnerPlaceRepository.save(place);
        return ResponseEntity.ok(saved);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<PartnerPlace> updatePartnerPlace(
            @PathVariable UUID id,
            @RequestBody PartnerPlace place) {
        log.info("PUT /partner-places/{} - Updating: {}", id, place.getName());
        place.setId(id);
        PartnerPlace updated = partnerPlaceRepository.save(place);
        return ResponseEntity.ok(updated);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePartnerPlace(@PathVariable UUID id) {
        log.info("DELETE /partner-places/{}", id);
        partnerPlaceRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }
}
