# Example: custom HTML template

By default, ShinyProxy presents available apps in a simple list format. Apps have a name, and optionally a description and a logo.
This presentation can be overridden, however. In the example below, a custom **template** is activated, which changes the appearance
of ShinyProxy in the browser.

## How to run

1. Download [ShinyProxy](https://www.shinyproxy.io/downloads "ShinyProxy website")
2. Download the `application.yml` configuration file from the folder where this README is located.
3. Place the jar and yml files in the same directory, e.g. `/home/user/sp`
4. Download all the files from the `templates` folder and place them in the folder containing your jar and yml files, e.g. `/home/user/sp/templates`
5. Open a terminal, go to the directory `/home/user/sp`, and run the following command:

`java -jar shinyproxy.jar`

**Note**: change the `proxy.template-path` property in `application.yml` to the example you want to use (`1col`, `2col`, `modified_navbar`) .

## How it works

* The `application.yml` file contains the setting `template-path: ./templates/2col` which refers to the '2col' template.
You can point it to any folder containing your custom HTML files.

* ShinyProxy uses [Thymeleaf](https://www.thymeleaf.org/) as its HTML templating engine.

* Assets (css, images, etc) can be referred to using the `@{/assets/...}` Thymeleaf syntax. Such references will be resolved against
the `assets` subfolder of the template.

* If a particular HTML file is missing from the template, the 
default HTML file will be used: <https://github.com/openanalytics/shinyproxy/tree/master/src/main/resources/templates>

## Template properties for an app

Since ShinyProxy 2.6.0, it is possible to specify additional properties for an
app which can be used in templates, but has no other effect.

For example:

```yaml
- id: 01_hello
  display-name: Hello Application
  description: Application which demonstrates the basics of a Shiny app
  container-cmd: ["R", "-e", "shinyproxy::run_01_hello()"]
  container-image: openanalytics/shinyproxy-demo
  template-properties:
    category: production
    maintainer: Tesla
```

These properties can be used in the template as follows:

```html
<!-- This is a fragment used to display a single app. -->
<!-- Modify this in order to change how a single app looks. -->
<th:block th:fragment="app(app)">
    <th:block th:if="${app != null}">
        <li th:if="${!displayAppLogos}">
            <a th:href="${@thymeleaf.getAppUrl(app)}"
               th:text="${app.displayName == null} ? ${app.id} : ${app.displayName}"></a>
            <br th:if="${app.description != null}"/>
            <!-- The next line returns `default-category` when the property is not defined for the app:  -->
            <th-block th:text="${@thymeleaf.getTemplateProperty(app.id, 'dev-category', 'default-category')}"></th-block>
            <!-- The next line returns null when the property is not defined for the app:  -->
            <th-block th:text="${@thymeleaf.getTemplateProperty(app.id, 'maintainer')}"></th-block>
        </li>
        <div th:if="${displayAppLogos}" class="row" style="margin-top:20px;">
            <div class="col-md-6 col-md-offset-3">
                <div class="media">
                    <div class="media-left">
                        <img th:if="${appLogos.get(app) != null}" th:src="${appLogos.get(app)}"></img>
                    </div>
                    <div class="media-body">
                        <a th:href="${@thymeleaf.getAppUrl(app)}"
                           th:text="${app.displayName == null} ? ${app.id} : ${app.displayName}"></a>
                        <br th:if="${app.description != null}"/>
                        <span th:if="${app.description != null}" th:utext="${app.description}"></span>
                    </div>
                </div>
            </div>
        </div>
    </th:block>
</th:block>
<!--End of the template.-->
```

## Where to find the original template files

* `login.html`: <https://github.com/openanalytics/containerproxy/blob/master/src/main/resources/templates/login.html>
* `error.html`: <https://github.com/openanalytics/containerproxy/blob/master/src/main/resources/templates/error.html>
* `logout-success.html`:  <https://github.com/openanalytics/containerproxy/blob/master/src/main/resources/templates/logout-success.html>
* `app-access-denied.html`:  <https://github.com/openanalytics/containerproxy/blob/master/src/main/resources/templates/app-access-denied.html>
* `auth-error.html`:  <https://github.com/openanalytics/containerproxy/blob/master/src/main/resources/templates/auth-error.html>
* `admin.html`: <https://github.com/openanalytics/shinyproxy/blob/master/src/main/resources/templates/admin.html>
* `index.html`: <https://github.com/openanalytics/shinyproxy/blob/master/src/main/resources/templates/index.html>
* `app.html`: <https://github.com/openanalytics/shinyproxy/blob/master/src/main/resources/templates/app.html>
* `navbar.html`: <https://github.com/openanalytics/shinyproxy/blob/master/src/main/resources/fragments/navbar.html>
