# syntax=docker/dockerfile:1.7
FROM eclipse-temurin:23-jdk AS build
WORKDIR /workspace

COPY .mvn .mvn
COPY mvnw mvnw
COPY pom.xml ./
RUN chmod +x mvnw

COPY src src

# Persistent BuildKit cache for the Maven local repo — first build still has
# to download everything once, but subsequent rebuilds reuse the cache and
# finish in seconds. Avoids `dependency:go-offline` which is notoriously slow
# and tends to hang on low-memory hosts.
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B -DskipTests package

FROM eclipse-temurin:23-jre
WORKDIR /app
COPY --from=build /workspace/target/backend-1.0.jar app.jar

# Run as non-root
RUN groupadd --system app && useradd --system --gid app app \
    && chown -R app:app /app
USER app

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
