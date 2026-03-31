FROM eclipse-temurin:17-jdk AS build
WORKDIR /workspace

COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN chmod +x ./mvnw
RUN ./mvnw -B dependency:go-offline

COPY src/ src/
RUN ./mvnw -B -DskipTests clean package
RUN jar xf target/*.jar META-INF/MANIFEST.MF \
    && grep -q "Main-Class: org.springframework.boot.loader.launch.JarLauncher" META-INF/MANIFEST.MF

FROM eclipse-temurin:17-jre AS runtime
WORKDIR /app

COPY --from=build /workspace/target/*.jar /app/app.jar

EXPOSE 10000
ENTRYPOINT ["java", "-Dserver.port=10000", "-jar", "/app/app.jar"]
