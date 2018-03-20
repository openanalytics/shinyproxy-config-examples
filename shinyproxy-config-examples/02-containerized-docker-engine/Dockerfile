FROM openjdk:8-jre

## Setup of shinyproxy
RUN mkdir -p /opt/shinyproxy/
RUN useradd -c 'shinyproxy user' -m -d /home/shinyproxy -s /bin/nologin shinyproxy
RUN chown -R shinyproxy.shinyproxy /opt/shinyproxy

## To use the latest release:
RUN wget https://www.shinyproxy.io/downloads/shinyproxy-1.0.2.jar -O /opt/shinyproxy/shinyproxy.jar

## To use the latest development snapshot:
# RUN wget https://nexus.openanalytics.eu/nexus/service/local/route/repo/snapshots/eu.openanalytics/shinyproxy/latest -O /opt/shinyproxy/shinyproxy.jar

COPY application.yml /etc/shinyproxy/application.yml

USER shinyproxy
WORKDIR /opt/shinyproxy/
RUN ln -s /etc/shinyproxy/application.yml /opt/shinyproxy/application.yml
CMD ["java", "-jar", "/opt/shinyproxy/shinyproxy.jar"]
