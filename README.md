# ShinyProxy Configuration Examples

ShinyProxy can be configured to run in very different scenarios. Consider the following:

* For your first tryout, maybe you just want to use a single machine with a Java runtime and a docker daemon, and run `java -jar shinyproxy.jar`. And that's perfectly fine!

* But then you'd like to place ShinyProxy *inside* a container itself, because then you don't need to install a Java runtime on the host...

* And next up is a bigger deployment, where you cannot rely on a single docker host but instead need a load-balanced cluster to guarantee enough containers are available for all your users.

* Not wanting to create a _single point of failure_, you also deploy multiple instances of ShinyProxy, load-balanced by a nginx front server.

As you can see, the configuration of ShinyProxy and its surrounding environment can quickly grow from trivial to not-so-trivial!
This repository offers some ready-to-use examples for various setups. Each example folder contains several configuration files, and an instructional README that explains how to go from a download to a running setup.

## Available Examples

This repository contains examples that are divided by several categories, explained below.

### Standalone vs containerized

In a *standalone* setup, ShinyProxy runs as a Java process on the host. In a *containerized* setup, ShinyProxy runs inside a container.

### Docker engine vs docker swarm vs kubernetes

The term *docker engine* refers to a single, non-clustered docker installation. The engine is managed by a 'docker daemon', a process that can be accessed by the `docker` commandline executable, by a HTTP URL or by a Unix socket.

*Docker swarm* is a layer that groups multiple docker installations in a 'swarm' that can offer clustering capabilities, including failover, load balancing, etc.

*Kubernetes* is a container orchestration service that can be used as an alternative to docker swarm. Several major cloud vendors such as Amazon and Google offer ready-to-use kubernetes environments.