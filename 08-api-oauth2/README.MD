# Example: call the ShinyProxy API using OAuth2

ShinyProxy has an API that can be protected using the OAuth2 authorization framework.
This is a complex framework that can be used in many different ways, but in this example the scenario is:

1. The user opens a web application (i.e. this example node.js app).
2. The user is asked to authenticate with an OAuth2 provider, and to consent to the app accessing the ShinyProxy API on their behalf.
3. The OAuth2 provider returns a temporary `authorization code`, which this app will exchange for an `access token`.
4. The access token is used to interact with the ShinyProxy API. As long as the access token is valid, it can be used to create,
access and stop proxies on the user's behalf.

In this example, the OAuth2 provider [Auth0](https://auth0.com) is used.

## How to run

1. Set up a ShinyProxy instance (e.g. by following the _01-standalone-docker-engine_ example).
2. Register the ShinyProxy instance with Auth0 as an `API`.
3. Register this example app with Auth0 as a `Regular Web Application`. Don't forget to specify a valid `callback URL`, e.g. `http://localhost:8081/callback`.
4. Install [node.js](https://nodejs.org).
5. Download the files from this git repository into a local folder.
6. Review the configuration in the file `app.js`, in the variables `oauth2Client`, `oauth2Server` and `oauth2Resource`.
7. Open a command prompt, navigate to the folder containing the downloaded files, and run `node app.js`.
8. If you get any dependency errors, install missing modules using `npm install <module-name>`.
9. Open a browser and navigate to `http://localhost:8081`.

## Notes

* This example assumes that the ShinyProxy instance runs on `http://localhost:8080`. If this is not the case, modify `app.js` accordingly.

* This example assumes that the node.js app runs on `http://localhost:8081`. If this is not the case, modify `app.js` accordingly.

* If _heartbeat_ is enabled (by default, it is), then the launched proxy will automatically shut down after 1 minute if it is not displayed in the iframe. Use the [settings](https://www.shinyproxy.io/configuration/#general) `heartbeat-enabled` and `heartbeat-timeout` to control this behaviour.