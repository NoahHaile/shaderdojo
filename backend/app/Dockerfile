# Use OpenJDK 21 LTS slim image as the base
FROM openjdk:23-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file into the container
COPY target/backend-1.0.jar app.jar

# Expose the application's port (default Spring Boot port is 8080)
EXPOSE 8080

# Run the JAR file
ENTRYPOINT ["java", "-jar", "app.jar"]
