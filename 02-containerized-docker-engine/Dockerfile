FROM openjdk:8-jre

RUN mkdir -p /opt/shinyproxy/
#RUN wget https://www.shinyproxy.io/downloads/shinyproxy-1.0.2.jar -O /opt/shinyproxy/shinyproxy.jar
COPY shinyproxy.jar /opt/shinyproxy/shinyproxy.jar
COPY application.yml /opt/shinyproxy/application.yml

WORKDIR /opt/shinyproxy/
CMD ["java", "-jar", "/opt/shinyproxy/shinyproxy.jar"]
