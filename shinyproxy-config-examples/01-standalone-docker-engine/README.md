# Example: standalone ShinyProxy with a docker engine

This example represents the most straightforward setup: you run ShinyProxy as a standalone process (as oposed to a 'containerized' process, a ShinyProxy that runs inside a container itself). ShinyProxy accesses a docker engine to spawn containers running the user's Shiny apps.

There is no clustering involved here: everything runs on a single host, or maybe two hosts if you have your Java runtime and docker engine on separate machines.

## How to run

1. Download ShinyProxy from the [website](https://www.shinyproxy.io/downloads "ShinyProxy website")
2. Download the `application.yml` configuration file from this page
3. Place the jar and yml files in the same directory
4. Open a terminal, go to the directory, and run the following command:

`java -jar shinyproxy.jar`