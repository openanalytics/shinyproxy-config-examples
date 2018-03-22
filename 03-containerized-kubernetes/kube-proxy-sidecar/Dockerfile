FROM alpine:3.6
ADD https://storage.googleapis.com/kubernetes-release/release/v1.7.4/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl
EXPOSE 8001
ENTRYPOINT ["/usr/local/bin/kubectl", "proxy"]