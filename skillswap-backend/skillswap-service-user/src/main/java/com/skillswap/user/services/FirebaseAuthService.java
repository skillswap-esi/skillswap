package com.skillswap.user.services;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;

/**
 * Service pour vérifier les tokens Firebase Auth.
 * 
 * Ce service initialise Firebase Admin SDK et vérifie les ID tokens.
 */
@Service
@Slf4j
public class FirebaseAuthService {
    
    @Value("${firebase.credentials-path}")
    private Resource firebaseCredentials;
    
    private boolean firebaseInitialized = false;
    
    /**
     * Initialise Firebase Admin SDK au démarrage de l'application.
     */
    @PostConstruct
    public void initialize() {
        try {
            // Vérifier si Firebase est déjà initialisé
            if (FirebaseApp.getApps().isEmpty()) {
                InputStream serviceAccount = firebaseCredentials.getInputStream();
                
                FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();
                
                FirebaseApp.initializeApp(options);
                firebaseInitialized = true;
                log.info("✓ Firebase Admin SDK initialized successfully");
            } else {
                firebaseInitialized = true;
                log.info("✓ Firebase Admin SDK already initialized");
            }
        } catch (IOException e) {
            log.error("✗ Failed to initialize Firebase Admin SDK", e);
            log.warn("⚠ Firebase authentication will work in DEVELOPMENT MODE only");
            log.warn("⚠ To enable Firebase, add firebase-service-account.json to src/main/resources/");
            firebaseInitialized = false;
        }
    }
    
    /**
     * Vérifie un ID token Firebase et retourne l'UID de l'utilisateur.
     * 
     * @param idToken Le token JWT Firebase
     * @return L'UID Firebase de l'utilisateur, ou null si le token est invalide
     */
    public String verifyIdToken(String idToken) {
        if (idToken == null || idToken.isEmpty()) {
            log.warn("Empty or null ID token provided");
            return null;
        }
        
        // Si Firebase est initialisé, utiliser la vérification réelle
        if (firebaseInitialized) {
            try {
                FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
                String uid = decodedToken.getUid();
                log.info("✓ Token verified successfully for Firebase UID: {}", uid);
                return uid;
            } catch (FirebaseAuthException e) {
                log.error("✗ Error verifying Firebase token: {}", e.getMessage());
                return null;
            }
        } else {
            // Mode développement : accepter tous les tokens non vides
            log.warn("⚠ Using DEVELOPMENT MODE - Firebase not initialized");
            log.warn("⚠ Accepting token without verification (NOT FOR PRODUCTION!)");
            return "dev-firebase-uid-" + System.currentTimeMillis();
        }
    }
    
    /**
     * Extrait l'email du token Firebase.
     * 
     * @param idToken Le token JWT Firebase
     * @return L'email de l'utilisateur, ou null si non disponible
     */
    public String getEmailFromToken(String idToken) {
        if (!firebaseInitialized || idToken == null || idToken.isEmpty()) {
            return null;
        }
        
        try {
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            return decodedToken.getEmail();
        } catch (FirebaseAuthException e) {
            log.error("Error extracting email from token", e);
            return null;
        }
    }
    
    /**
     * Extrait le numéro de téléphone du token Firebase.
     * 
     * @param idToken Le token JWT Firebase
     * @return Le numéro de téléphone de l'utilisateur, ou null si non disponible
     */
    public String getPhoneFromToken(String idToken) {
        if (!firebaseInitialized || idToken == null || idToken.isEmpty()) {
            return null;
        }
        
        try {
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            // Note: Le numéro de téléphone n'est pas toujours dans le token
            // Il faut le récupérer via l'API Firebase Auth si nécessaire
            return (String) decodedToken.getClaims().get("phone_number");
        } catch (FirebaseAuthException e) {
            log.error("Error extracting phone from token", e);
            return null;
        }
    }
    
    /**
     * Vérifie si Firebase est correctement initialisé.
     * 
     * @return true si Firebase est initialisé, false sinon
     */
    public boolean isFirebaseInitialized() {
        return firebaseInitialized;
    }
}
