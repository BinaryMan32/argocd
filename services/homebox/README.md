# Homebox

References:

- [homebox](https://github.com/sysadminsmedia/homebox) GitHub project
- [configuration](https://homebox.software/en/quick-start/configure/)

## Secrets

- `create-sealed-secret.sh` creates the API key pepper. It must stay stable,
  since rotating it invalidates every issued API key.

## Authentication

Login is OIDC only via Authelia. Local login and registration are disabled, and
users are created on their first OIDC login.
