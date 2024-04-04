# Example: use the ShinyProxy API using OAuth2

ShinyProxy has an API that can be protected using the OAuth2 authorization
framework. OAuth2 can be combined with any authentication backend and is
independent of using OpenID Connect (which allows authentication users in the
browser). However, in most cases it makes sense to combine OAuth2 with using
OpenID connect.

[Complete API documentation](https://shinyproxy.io/documentation/api/)

## Without OpenID Connect

1. set up an OAuth2 server, in case you don't already have
   one, [Keycloak](https://keycloak.org) is a good option
2. launch ShinyProxy using the following configuration (adapt the OAuth2
   configuration):

      ```yaml
      proxy:
        port: 8080
        authentication: simple
        admin-groups: admins
        users:
          - name: jack
            password: password
            groups: admins
          - name: jeff
            password: password
        specs:
          - id: 01_hello
            display-name: Hello Application
            description: Application which demonstrates the basics of a Shiny app
            container-cmd: [ "R", "-e", "shinyproxy::run_01_hello()" ]
            container-image: openanalytics/shinyproxy-demo
            container-network: sp-example-net
          - id: 06_tabsets
            container-cmd: [ "R", "-e", "shinyproxy::run_06_tabsets()" ]
            container-image: openanalytics/shinyproxy-demo
            container-network: sp-example-net
        oauth2:
          resource-id: shinyproxy
          jwks-url: https://keycloak.example.com/auth/realms/master/protocol/openid-connect/certs
          roles-claim: realm_roles
          username-attribute: preferred_username
      ```

3. create an OAuth2 Access token for your user, for example, using Keycloak and
   the direct authentication flow:

    ```bash
    KC_REALM=master
    KC_USERNAME=jack
    KC_PASSWORD="<password>"
    KC_CLIENT=shinyproxy
    KC_CLIENT_SECRET="<client_Id>"
    KC_SERVER=https://keycloak.example.com
    KC_CONTEXT=auth

    KC_RESPONSE=$(
      curl $CURL_OPTS -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "username=$KC_USERNAME" \
        -d "password=$KC_PASSWORD" \
        -d 'grant_type=password' \
        -d "client_id=$KC_CLIENT" \
        -d "client_secret=$KC_CLIENT_SECRET" \
        "$KC_SERVER/$KC_CONTEXT/realms/$KC_REALM/protocol/openid-connect/token" | jq .


    echo $KC_RESPONSE | jq -r .access_token
    ```

4. use the ShinyProxy API:

    ```bash
    curl -v http://localhost:8080/api/proxyspec \
      -H "Authorization: Bearer <token>" | jq .
    ```

This will output all the specs that are available to the user.

## Together with OpenID Connect

1. set up an OAuth2 server, in case you don't already have
   one, [Keycloak](https://keycloak.org) is a good option
2. launch ShinyProxy using the following configuration (adapt the OAuth2
   configuration, but make sure to use the same client):

      ```yaml
      proxy:
        port: 8080
        authentication: openid
        admin-groups: admins
        specs:
          - id: 01_hello
            display-name: Hello Application
            description: Application which demonstrates the basics of a Shiny app
            container-cmd: [ "R", "-e", "shinyproxy::run_01_hello()" ]
            container-image: openanalytics/shinyproxy-demo
            container-network: sp-example-net
          - id: 06_tabsets
            container-cmd: [ "R", "-e", "shinyproxy::run_06_tabsets()" ]
            container-image: openanalytics/shinyproxy-demo
            container-network: sp-example-net
        oauth2:
          resource-id: shinyproxy
          jwks-url: https://keycloak.example.com/auth/realms/master/protocol/openid-connect/certs
          roles-claim: realm_roles
          username-attribute: preferred_username
        openid:
          auth-url: https://keycloak.example.com/auth/realms/master/protocol/openid-connect/auth
          token-url: https://keycloak.example.com/auth/realms/master/protocol/openid-connect/token
          jwks-url: https://keycloak.example.com/auth/realms/master/protocol/openid-connect/certs
          client-id: shinyproxy
          client-secret: <client_secret>
          roles-claim: realm_roles
          username-attribute: preferred_username
      ```

3. start an application. Every application will automatically get
   the `SHINYPROXY_OIDC_ACCESS_TOKEN` environment variable, which will contain a
   valid access token for the authenticated user.
4. use the ShinyProxy API:

    ```bash
    curl -v http://localhost:8080/api/proxyspec \
      -H "Authorization: Bearer $SHINYPROXY_OIDC_ACCESS_TOKEN" | jq .
    ```

This will output all the specs that are available to the user.

This set up allows your app to seamlessly authenticate with the ShinyProxy API
because it uses the same IDP and client for both authentication the user and for
securing the ShinyProxy API.
