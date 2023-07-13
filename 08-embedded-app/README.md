# Example: embed an app in a website

Shiny apps are often embedded in other, larger contexts. For example, consider a
portal-style webpage that shows a dashboard with components from different
sources, including one or more Shiny apps.

Apps running in ShinyProxy can easily be embedded into other webpages.

1. launch ShinyProxy using the `application.yml` from this directory (e.g. in a similar way as [`01-standalone-docker-engine`](../01-standalone-docker-engine))
2. launch a simple python web server to serve the [`index.html`](index.html) file:
    
    ```bash
    python3 -m http.server
    ```
   
3. open the web page on <http://localhost:8000>

**Notes:**
* The example configuration hides the navigation bar, however, this is not
  required.
* By
  using [`frame-options`](https://shinyproxy.io/documentation/configuration/#frame-options)
  property you can restrict which websites can embed your applications.
