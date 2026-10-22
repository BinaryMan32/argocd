# audiobookshelf

References:

- [audiobookshelf](https://github.com/advplyr/audiobookshelf) GitHub project
- [Docker Compose Install Instructions](https://www.audiobookshelf.org/docs/#docker-compose-install)
- [ghcr.io/advplyr/audiobookshelf container image](https://github.com/advplyr/audiobookshelf/pkgs/container/audiobookshelf)
- [OIDC authentication guide](https://www.audiobookshelf.org/guides/oidc_authentication/)
- [Authelia audiobookshelf integration](https://www.authelia.com/integration/openid-connect/clients/audiobookshelf/)

## Authentication

Users can log in with OIDC via Authelia or with their local password. OIDC
logins are matched to existing users by email, so every user with an Authelia
account must have the same email address in audiobookshelf.

Manually configure audiobookshelf [Authentication Settings][audiobookshelf-settings-auth] as below.

To retrieve the client ID and secret:

```sh
kubectl --namespace=media get secret authelia-oidc-audiobookshelf \
  --template='{{printf "id: %s\nsecret: %s\n" (index .data "client-id" | base64decode) (index .data "client-secret" | base64decode)}}'
```

| Setting                         | Value                                  |
| ------------------------------- | -------------------------------------- |
| Password Authentication         | Enabled                                |
| OpenID Connect Authentication   | Enabled                                |
| Issuer URL                      | `https://auth.int.fivebytestudios.com` |
| Authorize/Token/Userinfo/JWKS   | Click Auto-populate                    |
| Client ID                       | From the command above                 |
| Client Secret                   | From the command above                 |
| Signing Algorithm               | `RS256`                                |
| Allowed Mobile Redirect URIs    | `audiobookshelf://oauth`               |
| Subfolder for Redirect URLs     | None                                   |
| Button Text                     | `Login with Authelia`                  |
| Match existing users by         | Match by email                         |
| Auto Launch                     | Disabled                               |
| Auto Register                   | Disabled                               |
| Group Claim                     | Empty                                  |

Password authentication stays enabled for users without an Authelia account and
for third-party apps that don't support OIDC. Auto Register is disabled so an
Authelia account alone doesn't create an audiobookshelf user. The group claim is
left empty so audiobookshelf keeps managing user types and permissions.

[audiobookshelf-settings-auth]: https://audiobookshelf.int.fivebytestudios.com/audiobookshelf/config/authentication
