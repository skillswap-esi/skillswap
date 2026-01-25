package com.skillswap.notification.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI notificationServiceOpenAPI() {
        Server localServer = new Server();
        localServer.setUrl("http://localhost:8084");
        localServer.setDescription("Local Development Server");

        Server gatewayServer = new Server();
        gatewayServer.setUrl("http://localhost:8080");
        gatewayServer.setDescription("API Gateway");

        Contact contact = new Contact();
        contact.setName("SkillSwap Team");
        contact.setEmail("support@skillswap.com");

        Info info = new Info()
                .title("SkillSwap Notification Service API")
                .version("1.0.0")
                .description("Firebase Cloud Messaging (FCM) push notifications via Kafka events")
                .contact(contact);

        return new OpenAPI()
                .info(info)
                .servers(List.of(localServer, gatewayServer));
    }
}
