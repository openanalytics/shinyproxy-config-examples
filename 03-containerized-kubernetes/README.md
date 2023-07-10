# Example: containerized ShinyProxy with a Kubernetes cluster

In this example, ShinyProxy will run inside a Kubernetes cluster. Shiny containers will also be spawned
in the same cluster. To make the application accessible outside the cluster, a NodePort service is created.

**Note: this example is the most basic way to deploy ShinyProxy on Kubernetes
and should not be used in production. Use
the [ShinyProxy Operator](https://github.com/openanalytics/shinyproxy-operator)
for deploying ShinyProxy on Kubernetes.**

## How to run

1. Download the `Dockerfile` and `application.yml` files from the folder `shinyproxy-example`.
2. Open a terminal, go to the directory containing the Dockerfile, and run the following command to build it:

   ```bash
   sudo docker build . -t shinyproxy-example
   ```

3. Ensure the `shinyproxy-example` image is available on all your kube nodes.
4. Open a terminal on a master node (where the `kubectl` command is available).
5. Download the 3 `yaml` files from the folder where this README is located. 
6. Run the following command to deploy a pod containing `shinyproxy-example`:

   ```bash
   kubectl create -f sp-deployment.yaml
   ```

7. Run the following command to grant full privileges to the `default` service account which runs the above pod:

   ```bash
   kubectl create -f sp-authorization.yaml
   ```

8. Run the following command to deploy a service exposing ShinyProxy outside the cluster:

   ```bash
   kubectl create -f sp-service.yaml
   ```

## Notes on the configuration

* The service will expose ShinyProxy on all nodes, listening on port `32094`.

* If you do not deploy the service, you can still access ShinyProxy from within the cluster on port `8080`.

* To keep the example concise, the `cluster-admin` role is granted to the `default` service account.
  Best-practice would be to add a dedicated service account and reference it via `serviceAccountName` in the deployment spec.
  The following role is the minimal set of permissions:

  ```yaml
  kind: Role
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    namespace: example
    name: example
  rules:
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  ```
