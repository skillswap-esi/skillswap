FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy parent pom and common module first
COPY pom.xml ../pom.xml
COPY skillswap-common ../skillswap-common

# Copy skill service
COPY skillswap-service-skill/pom.xml .
COPY skillswap-service-skill/src ./src

# Build
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "app.jar"]
