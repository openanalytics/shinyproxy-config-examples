# Example: standalone ShinyProxy with a docker engine

This example represents the most straightforward setup: you run ShinyProxy as a standalone Java process. ShinyProxy accesses a docker engine to spawn containers running the user's Shiny apps.

There is no clustering involved here: everything runs on a single host, or maybe two hosts if you have your Java runtime and docker engine on separate machines.

## How to run

1. Download [ShinyProxy](https://www.shinyproxy.io/downloads "ShinyProxy website")
2. Download the `application.yml` configuration file from the folder where this README is located.
3. Place the jar and yml files in the same directory, e.g. `/home/user/sp`
4. Open a terminal, go to the directory `/home/user/sp`, and run the following command:

`java -jar shinyproxy.jar`

## Notes on the configuration

*	ShinyProxy will listen for HTTP traffic on port `8080`.

*   Authentication is set to `simple`, which means that the valid logins are defined in the section `shiny.proxy.users`.
Two users are defined: jack (an admin) and jeff (a regular user).

*	The docker URL is set to `http://localhost:2375`. More information about docker URLs can be found [here](TODO).