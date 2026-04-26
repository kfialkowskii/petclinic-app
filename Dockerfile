# Build
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app
# Copy Maven wrapper and pom first (layer caching)
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline -q

# Copy source and build
COPY src/ src/
RUN ./mvnw package -DskipTests -q

# Runtime
FROM eclipse-temurin:21-jre
WORKDIR /app
RUN groupadd -r petclinic && useradd -r -g petclinic petclinic
USER petclinic
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]