# Example: background apps in ShinyProxy

This example demonstrate how to configure ShinyProxy to allow apps running in
the background. See the [`application.yml`](application.yml) file for the
details of the examples. This example requires at least ShinyProxy 2.6.0.

## How to run

1. Download [ShinyProxy](https://www.shinyproxy.io/downloads "ShinyProxy website")
2. Download the `application.yml` configuration file from the folder where this README is located.
3. Place the jar and yml files in the same directory, e.g. `/home/user/sp`
4. Open a terminal, go to the directory `/home/user/sp`, and run the following command:

`java -jar shinyproxy.jar`