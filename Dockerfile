FROM container-registry.oracle.com/java/jdk-no-fee-term:21.0.1-oraclelinux8
# FROM container-registry.oracle.com/java/openjdk:21.0.1-oraclelinux8

EXPOSE 8080

# For Maven build
COPY target/spring-restclient-0.0.1-SNAPSHOT.jar app.jar

# # For Gradle build
# COPY build/libs/spring-restclient-0.0.1-SNAPSHOT.jar app.jar

CMD ["java","-jar","app.jar"]

# Build and run:
# docker build -t localhost/spring-restclient:jvm .
# docker run --rm -p 8080:8080 localhost/spring-restclient:jvm
