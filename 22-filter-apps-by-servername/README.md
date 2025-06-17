# Example: filter apps by server name

Since ShinyProxy 3.2.0 it's possible to show specific apps only when accessing
ShinyProxy using a specific hostname.

As an example, assume that we want to show app `app1` only on
`shinyproxy-demo.local` and `app2` only on `shinyproxy-demo2.local`. This can be
achieved using the following configuration:

```yaml
proxy:
  specs:
    - id: app1
      display-name: App 1
      container-image: openanalytics/shinyproxy-demo
      access-strict-expression: "#{serverName == 'shinyproxy-demo.local'}"
    - id: app2
      display-name: App 2
      container-cmd: [ "R", "-e", "shinyproxy::run_06_tabsets()" ]
      container-image: openanalytics/shinyproxy-demo
      access-strict-expression: "#{serverName == 'shinyproxy-demo2.local'}"
```

This uses the [`access-strict-expression`](https://shinyproxy.io/documentation/spel/#access-expression)
feature to limit the apps to specific hostnames. It's important to use the
`access-strict-expression` property and not `access-expression`. In contrast to
the regular `access-expression` property, the strict variant is evaluated and
must return `true` even if other access control settings allow the user to
access the app. For example, to limit the `app1` example to user `jack`:

```yaml
proxy:
  specs:
    - id: app1
      display-name: App 1
      container-image: openanalytics/shinyproxy-demo
      access-strict-expression: "#{serverName == 'shinyproxy-demo.local'}"
      access-users: jack
    - id: app2
      display-name: App 2
      container-cmd: [ "R", "-e", "shinyproxy::run_06_tabsets()" ]
      container-image: openanalytics/shinyproxy-demo
      access-strict-expression: "#{serverName == 'shinyproxy-demo2.local'}"
```

If user `jack` logs into `shinyproxy-demo.local`, they only see the `app1` app.
User `jeff` will see no apps on `shinyproxy-demo.local`. Note that if in this
example `access-expression` was used, `jack` would be able to access `app1` on
`shinyproxy-demo2.local` as well.

## Dynamic title and logo

Together with separating apps between multiple hostnames, you might want to have
a different title or logo depending on the server name. Starting with ShinyProxy
3.2.0 this is possible, because these properties now
support [SpEL](https://shinyproxy.io/documentation/spel/).

For example:

```yaml
proxy:
  title: "#{serverName == 'shinyproxy-demo.local' ? 'ShinyProxy Demo' : 'ShinyProxy Demo 2'}"
  logo-url: "#{serverName == 'shinyproxy-demo.local' ? 'https://www.openanalytics.eu/shinyproxy/logo.png' : null}"
```

When using the `shinyproxy-demo.local` hostname, ShinyProxy shows the title
`ShinyProxy Demo` and the default logo. On `shinyproxy-demo2.local`, the title
`ShinyProxy Demo 2` is shown without a logo.

## Automatically opening an app

You can use the [`landing-page`](https://shinyproxy.io/documentation/configuration/#landing-page)
property to automatically open an app instead of showing the main page.

## How to run

1. Download [ShinyProxy](https://www.shinyproxy.io/downloads "ShinyProxy website")
2. Download the `application.yml` configuration file from the folder where this
   README is located.
3. Place the jar and yaml files in the same directory, e.g. `/home/user/sp`
4. Open a terminal, go to the directory `/home/user/sp`, and run the following
   command:

`java -jar shinyproxy.jar`
