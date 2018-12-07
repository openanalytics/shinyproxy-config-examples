# Example: embed an app in a website using the API

Shiny apps are often embedded in other, larger contexts. For example, consider a portal-style webpage that shows a dashboard with components from different sources, including one or more Shiny apps.

In such a case, the standard web interface of ShinyProxy may not be very useful, and a more controlled approach is necessary.

In this example, the ShinyProxy "API":http://htmlpreview.github.io/?https://github.com/openanalytics/containerproxy/blob/develop/doc/api/containerproxy-rest.html is used to launch, show, and stop Shiny apps when the user clicks on buttons.

## How to run

1. Set up a ShinyProxy instance (e.g. by following the _01-standalone-docker-engine_ example.
2. Set up an HTTP server. This is not in the scope of this example, but any server that can serve static web content should do.
3. Download the file `index.html` and have the HTTP server host it.
4. Access the `index.html` page from a web browser

## Notes

* This example assumes `authentication: none` is set. With authentication enabled, the API calls must be done in a different way, depending on the authentication method. In some cases (OpenId, Social), an `Authorization` header will be required. In other cases (LDAP, Simple), a separate login must be performed by making a POST request to the `/login` URL.

* When you launch a proxy via the API, you get back a JSON body describing the proxy. This includes its 'endpoints', which are the URLs where you can access the Shiny app's HTTP interface.

* If _heartbeat_ is enabled (by default, it is), then the launched proxy will automatically shut down after 1 minute if it is not displayed in the iframe. Use the "settings":https://www.shinyproxy.io/configuration/#general `heartbeat-enabled` and `heartbeat-timeout` to control this behaviour.