FROM alpine:latest AS builder
RUN apk --no-cache add openjdk17
WORKDIR /tmp
COPY ./ ./
RUN ./mvnw clean ; ./mvnw package -DskipTests

FROM alpine:latest
ENV URL=
RUN apk --no-cache add openjdk17-jre-headless
WORKDIR /home
COPY --from=builder /tmp/target/spring-*.jar  ./
EXPOSE 8080
CMD ["/bin/sh", "-c", "/usr/bin/java -jar /home/spring-*.jar --spring.profiles.active=mysql --spring.datasource.url=jdbc:mysql://${URL}"]