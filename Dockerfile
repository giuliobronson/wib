# syntax=docker/dockerfile:1

# Imagem única: o build do frontend é servido pelo próprio Spring Boot como
# conteúdo estático, então SPA e /api ficam na mesma origem (sem CORS).

# --- Frontend -----------------------------------------------------------------
FROM node:26-alpine AS frontend
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# --- Backend ------------------------------------------------------------------
FROM eclipse-temurin:25-jdk AS backend
WORKDIR /app/backend
COPY backend/mvnw ./
COPY backend/.mvn .mvn
COPY backend/pom.xml ./
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B -q dependency:go-offline
COPY backend/src src
COPY --from=frontend /app/frontend/dist src/main/resources/static
# Os testes precisam do PostgreSQL no ar; eles rodam fora do build da imagem.
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B -q package -DskipTests \
 && mv target/*.jar app.jar \
 && java -Djarmode=tools -jar app.jar extract --layers --launcher --destination extracted

# --- Runtime ------------------------------------------------------------------
FROM eclipse-temurin:25-jre
RUN useradd --system --uid 1001 wib
WORKDIR /app
COPY --from=backend /app/backend/extracted/dependencies/ ./
COPY --from=backend /app/backend/extracted/spring-boot-loader/ ./
COPY --from=backend /app/backend/extracted/snapshot-dependencies/ ./
COPY --from=backend /app/backend/extracted/application/ ./
USER wib
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "org.springframework.boot.loader.launch.JarLauncher"]
