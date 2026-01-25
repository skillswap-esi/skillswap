package com.skillswap.mission.config;

import com.skillswap.mission.model.PartnerPlace;
import com.skillswap.mission.repositories.PartnerPlaceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {
    
    private final PartnerPlaceRepository partnerPlaceRepository;
    
    @Override
    public void run(String... args) {
        // Initialize partner places if empty
        if (partnerPlaceRepository.count() == 0) {
            log.info("Initializing partner places...");
            
            PartnerPlace place1 = new PartnerPlace();
            place1.setId(UUID.randomUUID());
            place1.setName("Café Central");
            place1.setAddress("Boulevard Mohammed V");
            place1.setCity("Casablanca");
            place1.setLatitude(33.5731);
            place1.setLongitude(-7.5898);
            place1.setType("CAFE");
            place1.setActive(true);
            place1.setPhoneNumber("+212 522 123456");
            place1.setDescription("Popular café in city center with WiFi");
            
            PartnerPlace place2 = new PartnerPlace();
            place2.setId(UUID.randomUUID());
            place2.setName("Coworking Space Hub");
            place2.setAddress("Rue Abdelmoumen");
            place2.setCity("Casablanca");
            place2.setLatitude(33.5850);
            place2.setLongitude(-7.6200);
            place2.setType("COWORKING");
            place2.setActive(true);
            place2.setPhoneNumber("+212 522 234567");
            place2.setDescription("Modern coworking space with meeting rooms");
            
            PartnerPlace place3 = new PartnerPlace();
            place3.setId(UUID.randomUUID());
            place3.setName("Bibliothèque Nationale");
            place3.setAddress("Avenue Ibn Sina");
            place3.setCity("Rabat");
            place3.setLatitude(33.9716);
            place3.setLongitude(-6.8498);
            place3.setType("LIBRARY");
            place3.setActive(true);
            place3.setPhoneNumber("+212 537 123456");
            place3.setDescription("National library with quiet study areas");
            
            partnerPlaceRepository.save(place1);
            partnerPlaceRepository.save(place2);
            partnerPlaceRepository.save(place3);
            
            log.info("Partner places initialized successfully");
        }
    }
}
