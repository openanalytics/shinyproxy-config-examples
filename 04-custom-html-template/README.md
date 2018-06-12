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

## How it works

* The `application.yml` file contains the setting `template-path: ./templates/2col` which refers to the '2col' template.
You can point it to any folder containing your custom HTML files.

* ShinyProxy uses [Thymeleaf](https://www.thymeleaf.org/) as its HTML templating engine.

* Assets (css, images, etc) can be referred to using the `@{/assets/...}` Thymeleaf syntax. Such references will be resolved against
the `assets` subfolder of the template.

* If a particular HTML file is missing from the template, the 
default HTML file will be used: <https://github.com/openanalytics/shinyproxy/tree/master/src/main/resources/templates>