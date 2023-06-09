# Docker Build Stage
FROM openjdk:20

WORKDIR /app

COPY ./target/spring-app-0.0.1-SNAPSHOT.jar app.jar

ENV PORT 8090

EXPOSE $PORT
EXPOSE 6379
EXPOSE 5432
EXPOSE 2375

ENTRYPOINT ["java","-jar", "app.jar"]