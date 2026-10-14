# Dockerfile for Employee Time Management System
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY target/employee-time-management-1.0.0.jar app.jar
EXPOSE 8080
ENV PORT=8080
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=demo"]
