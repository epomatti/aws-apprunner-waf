# syntax=docker/dockerfile:1

### Builder ###
FROM eclipse-temurin:17-jdk-jammy as builder
WORKDIR /opt/app
COPY . .
RUN ./mvnw dependency:go-offline
RUN ./mvnw clean install

### Runtime ###
FROM eclipse-temurin:17-jre-jammy
WORKDIR /opt/app
COPY --from=builder /opt/app/target/*.jar /opt/app/*.jar

# AWS X-Ray
ADD --chown=finanzia https://github.com/aws-observability/aws-otel-java-instrumentation/releases/latest/download/aws-opentelemetry-agent.jar /opt/aws-opentelemetry-agent.jar
ENV JAVA_TOOL_OPTIONS=-javaagent:/opt/aws-opentelemetry-agent.jar
ENV OTEL_PROPAGATORS=xray
ENV OTEL_TRACES_SAMPLER=xray
ENV OTEL_METRICS_EXPORTER=none
# ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
ENV OTEL_SERVICE_NAME=Kompass

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]