# Docker Build Stage
FROM openjdk:20

WORKDIR /app

COPY ./target/spring-app-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8090 6379 5432 2375

ENTRYPOINT ["java","-jar", "app.jar"]
