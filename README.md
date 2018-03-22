# Example: containerized ShinyProxy with a Kubernetes cluster

In this example, ShinyProxy will run inside a Kubernetes cluster. Shiny containers will also be spawned
in the same cluster. To make the application accessible outside the cluster, a NodePort service is created.

## How to run

1. Download the `Dockerfile` from the folder `kube-proxy-sidecar`.
2. Open a terminal, go to the directory containing the Dockerfile, and run the following command to build it:

`sudo docker build . -t kube-proxy-sidecar`

3. Ensure the `kube-proxy-sidecar` image is available on all your kube nodes. E.g. by repeating the above steps on all nodes.
4. Download the `Dockerfile` from the folder `shinyproxy-example`.
5. Open a terminal, go to the directory containing the Dockerfile, and run the following command to build it:

`sudo docker build . -t shinyproxy-example`

6. Ensure the `shinyproxy-example` image is available on all your kube nodes.
7. Open a terminal on a master node (where the `kubectl` command is available).

8. Download the 3 `yaml` files from the folder where this README is located. 
9. Run the following command to deploy a pod containing `shinyproxy-example` and `kube-proxy-sidecar`:

`kubectl create -f sp-deployment.yaml`

10. Run the following command to grant full privileges to the `default` service account which runs the above pod:

`kubectl create -f sp-authorization.yaml`

11. Run the following command to deploy a service exposing ShinyProxy outside the cluster:

`kubectl create -f sp-service.yaml`

## Notes on the configuration

* The `kube-proxy-sidecar` container is used to make the apiserver accessible on `http://localhost:8001` to the `shinyproxy-example` container.

* The service will expose ShinyProxy on all nodes, listening on port `32094`.

* If you do not deploy the service, you can still access ShinyProxy from within the cluster on port `8080`.