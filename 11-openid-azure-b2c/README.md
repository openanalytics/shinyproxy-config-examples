# Example: integrating ShinyProxy with Azure B2C

ShinyProxy can integrate with any OIDC provider, this example specifically
demonstrates how to integrate ShinyProxy with Azure B2C.

> [!NOTE]  
> We do our best to document the steps in Azure B2C, however, the Azure Portal
> may change and this documentation may get outdated. Please open an issue or PR
> in this case.

It's a good idea to first read the
general [ShinyProxy OpenID documentation](https://shinyproxy.io/documentation/configuration/#openid-connect-oidc).

## Configuring Azure B2C

1. Log into the Azure Portal
2. Go to the `Azure AD B2C` service
3. Click on `App registrations`
4. Click on `New registration`
5. Fill in a name for the registration
6. Choose `Accounts in this organizational directory only`. Do not use the other
   options (not even for testing), unless you are aware of the implications.
7. In the `Redirect URI` section, choose `Web` and use the following value
   (replacing `shinyproxy-demo.local` with your domain name):

   ```
   https://shinyproxy-demo.local/login/oauth2/code/shinyproxy
   ```

8. The filled in form should look like:

   [![](img/01_register.png)](img/01_register.png)

9. Click `Register`
10. Go to `Certificates & secrets`
11. Click `Client secrets`
12. Click `New client secret`
13. Give a description and choose an expire time. You'll have to create a new
    secret and update the ShinyProxy config before the timeout.

    [![](img/02_create_secret.png)](img/02_create_secret.png)

14. On the next page, copy the secret in the `Value` column. Make sure to copy
    it now, since you'll not be able to retrieve it later. Make sure to not use
    the `Secret ID`, you'll not need this value for the configuration.

    [![](img/03_secret.png)](img/03_secret.png)

15. Go back to the `Overview` page copy the `Application (client) ID`. You'll
    need this in the ShinyProxy configuration.

    [![](img/04_info.png)](img/04_info.png)

16. Click on `Endpoints`
17. Copy the `OAuth 2.0 Authorization endpoint (v2)`
    and `OAuth 2.0 token endpoint (v2)` URLs. You'll need this in the ShinyProxy
    configuration.
18. Click on `OpenID Connect metadata document` and copy the `jwks_uri` value.
    You'll need this in the ShinyProxy.

## Configuring ShinyProxy

Now that you configured Azure B2C and you retrieved all parameters, you can
configure ShinyProxy.

1. Add the following configuration to your ShinyProxy config (replace the
   examples with the values you retrieved from the Azure portal):

    ```yaml
    proxy:
      authentication: openid
      openid:
        # see step 17 (of previous section): OAuth 2.0 Authorization endpoint (v2)
        auth-url: https://login.microsoftonline.com/.../oauth2/v2.0/authorize
        # see step 17 (of previous section): OAuth 2.0 token endpoint (v2)
        token-url: https://login.microsoftonline.com/.../oauth2/v2.0/token
        # see step 18 (of previous section)
        jwks-url: https://login.microsoftonline.com/.../discovery/v2.0/keys
        # see step 15 (of previous section)
        client-id: 9edf3fd9-....
        # see step 14 (of previous section)
        client-secret: eB...
        username-attribute: sub
        scopes:
          - offline_access
    ```

2. Restart ShinyProxy

You should now be able to log in on ShinyProxy using an Azure user. You can
create additional users by going to the `Users` page in Azure.

## Configuring the username

The current setup will use the `sub` (subject) of the user to identify it (this
is e.g. shown in the navigation bar of ShinyProxy). This is a generated value
and is not user-friendly. We can configure Azure B2C to send the e-mail address
of the user. The same steps can be used to use a different property.

1. In Azure B2C, go to `Token configuration`
2. Click on `Add optional claim`
3. Choose `ID` as `Token type`
4. Select `email` from the list

   [![](img/05_email.png)](img/05_email.png)

5. Click on `Add`
6. In the pop-up that is opened,
   select `Turn on the Microsfot Graph email permissions` and click `Add`:

   [![](img/06_email.png)](img/06_email.png)

7. Change the `proxy.openid.username-attribute` in ShinyProxy to `email`:

    ```yaml
    proxy:
      openid:
        username-attribute: email
    ```

8. Restart ShinyProxy

When a user now logs in on ShinyProxy, the user is identified by their email
address.

It's possible to see all claims which are being sent to ShinyProxy,
see [the documentation](https://shinyproxy.io/documentation/troubleshooting/#listing-all-claims-sent-by-the-openid-provider).

> [!NOTE]  
> Make sure that every user has an e-mail address configured. Otherwise, the
> user will get an error when logging in.

## Configuring groups

ShinyProxy can use the groups configured in Azure for authorization:

> [!NOTE]  
> Azure B2C will send the id of the group, instead of a human-friendly name.
> As far as we know, there is currently no proper way to send the name of the
> groups.

1. In Azure B2C, go to `Token configuration`
2. Click on `Add groups claim`
3. Select `All groups` (the other options will work as well, this depends on
   your use-case)
4. Click on `Group ID` inside the `ID` section

   [![](img/07_groups.png)](img/07_groups.png)

5. Click `Add`
6. Add the `proxy.openid.roles-claim` property to the ShinyProxy config:

    ```yaml
    proxy:
      openid:
        roles-claim: groups
    ```

7. Restart ShinyProxy

When a user now logs in on ShinyProxy, Azure B2C sends the groups of that user
to ShinyProxy. You can check whether this works by starting an app and
retrieving the `SHINYPROXY_USERGROUPS` environment variable.

## Logout

When clicking the logout button in the current setup, the user will just be
logged out from ShinyProxy. You can configure ShinyProxy to logout the user in
Azure B2C:

1. Go to the `OpenID Connect metadata document` in Azure B2C (see the first
   section) and copy the `end_session_endpoint` value.
2. Add the `proxy.openid.logout-url` property to the ShinyProxy config:

    ```yaml
    proxy:
      openid:
        logout-url: https://login.microsoftonline.com/.../oauth2/v2.0/logout
    ```

3. Restart ShinyProxy

You can optionally add the `post_logout_redirect_uri` parameter if you want to
redirect the user back to ShinyProxy e.g.:

   ```yaml
   proxy:
     openid:
       logout-url: https://login.microsoftonline.com/.../oauth2/v2.0/logout?post_logout_redirect_uri=http%3A%2F%2Fshinyproxy-demo.local/logout-success
   ```

## References

- [Azure AD B2C documentation](https://learn.microsoft.com/en-us/azure/active-directory-b2c/)
- [ShinyProxy OpenID documentation](https://shinyproxy.io/documentation/configuration/#openid-connect-oidc)
- [ShinyProxy SpEL documentation](https://shinyproxy.io/documentation/spel/)
- [ShinyProxy Troubleshooting OpenID documentation](https://shinyproxy.io/documentation/troubleshooting/#openid-connect-oidc)
- [ShinyProxy Docs on using environment variables](https://shinyproxy.io/documentation/configuration/#config-env-var)
