# Example: containerized ShinyProxy with a docker engine

This example is similar to the example 'standalone ShinyProxy with a docker engine', with one exception:
ShinyProxy runs in a container itself, in the same container manager (i.e. docker engine) that also hosts
the containers for the users' Shiny apps.

## Requirement

ShinyProxy expects relevant Docker images to be already available on the host. Before running this example, pull the Docker image used in this example with:

```bash
sudo docker pull openanalytics/shinyproxy-demo
```

## How to run

1. Download the `Dockerfile` from the folder where this README is located.
2. Download the `application.yml` configuration file from the folder where this README is located.
3. Place the files in the same directory, e.g. `/home/user/sp`
4. Create a docker network that ShinyProxy will use to communicate with the Shiny containers.

   ```bash
   sudo docker network create sp-example-net
   ```

5. Open a terminal, go to the directory `/home/user/sp`, and run the following command to build the ShinyProxy image:

   ```bash
   sudo docker build . -t shinyproxy-example
   ```

6. Run the following command to launch the ShinyProxy container:

   ```bash
   sudo docker run -v /var/run/docker.sock:/var/run/docker.sock:ro --group-add $(getent group docker | cut -d: -f3) --net sp-example-net -p 8080:8080 shinyproxy-example
   ```

   **Note**: inside the Docker container, ShinyProxy runs as a non-root user, therefore it does not have access to the Docker socket by default.
    By adding the `--group-add $(getent group docker | cut -d: -f3)` option we ensure that the user is part of the `docker` group and thus has access to the Docker daemon.
   **Note**: by adding the `-d` option to the command (just after `docker run`), the Docker container will run in the background.

## Notes on the configuration

* ShinyProxy will listen for HTTP traffic on port `8080`.

* The custom bridge network `sp-example-net` is needed to allow the containers to access each other using
the container ID as hostname.
