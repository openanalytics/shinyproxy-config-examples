# Example: containerized ShinyProxy with a docker engine

This example is similar to the example 'standalone ShinyProxy with a docker engine', with one exception:
ShinyProxy runs in a container itself, in the same container manager (i.e. docker engine) that also hosts
the containers for the users' Shiny apps.

## How to run

1. Download the `Dockerfile` from the folder where this README is located.
2. Download the `application.yml` configuration file from the folder where this README is located.
3. Place the files in the same directory, e.g. `/home/user/sp`
4. Create a docker network that ShinyProxy will use to communicate with the Shiny containers.

`sudo docker network create sp-example-net`

5. Open a terminal, go to the directory `/home/user/sp`, and run the following command to build the ShinyProxy image:

`sudo docker build . -t shinyproxy-example`

6. Run the following command to launch the ShinyProxy container:

`sudo docker run -d -v /var/run/docker.sock:/var/run/docker.sock --net sp-example-net -p 8080:8080 shinyproxy-example`

## Notes on the configuration

* ShinyProxy will listen for HTTP traffic on port `8080`.

* The custom bridge network `sp-example-net` is needed to allow the containers to access each other using
the container ID as hostname.