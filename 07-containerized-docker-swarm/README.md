# Example: containerized ShinyProxy with Docker Swarm

In this example, ShinyProxy will run inside a Docker Swarm cluster. Shiny containers will also be spawned
in the same cluster. To make the app accessible outside the cluster, a NodePort service is created.

## How to run

1. Download the `Dockerfile` from the folder where this README is located.
2. Download the `application.yml` configuration file from the folder where this README is located.
3. Place the files in the same directory, e.g. `/home/user/sp`
4. Open a terminal, go to the directory `/home/user/sp`, and run the following command to build the ShinyProxy image:

   ```bash
   sudo docker build . -t shinyproxy-example
   ```

5. Create a docker network that ShinyProxy will use to communicate with the Shiny containers.

   ```bash
   sudo docker network create -d overlay --attachable sp-example-net
   ```

6. Run the following command to launch the ShinyProxy container:

  ```bash
  sudo docker service create --name sp-test-service --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --publish 8080:8080 --network sp-example-net --group $(getent group docker | cut -d: -f3) shinyproxy-example
  ```

## Notes on the configuration

- ShinyProxy will listen for HTTP traffic on port `8080` of each swarm node.
- The overlay network `sp-example-net` is needed to allow the containers to access each other using
the container ID as hostname.
