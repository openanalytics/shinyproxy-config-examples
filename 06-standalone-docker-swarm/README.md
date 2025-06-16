# Example: standalone ShinyProxy with Docker Swarm

This example is very similar to example '01-standalone-docker-engine', except
that it connects to a Docker Swarm instead of a single-machine docker engine. As
a result, when you launch a Shiny app, its container may run on any node in the
Docker Swarm, at the swarm's discretion.

## How to run

1. Download [ShinyProxy](https://www.shinyproxy.io/downloads "ShinyProxy website")
2. Download the `application.yml` configuration file from the folder where this README is located.
3. Place the jar and yaml files in the same directory, e.g. `/home/user/sp`
4. Open a terminal, go to the directory `/home/user/sp`, and run the following command:

`java -jar shinyproxy.jar`

## Notes on the configuration

- ShinyProxy will listen for HTTP traffic on port `8080`.
- ShinyProxy connects to the Docker daemon using a Unix socket, make sure the
  user running ShinyProxy has permission
  to [use this socket](https://shinyproxy.io/documentation/getting-started/#access-to-docker-daemon).
