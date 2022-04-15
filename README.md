# Secure Angular application using Gravitee Access Management 

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 13.3.3.

## Start Gravitee Access Management

In the `gravitee-am` directory, you can find a Docker Compose descriptor to start AM.

```bash
cd gravitee-am
docker compose up
```

The script `gravitee-am/initialization/sh` allows you to configure AM to secure the application.

```bash
cd gravitee-am
./initialization.sh
```

## How to run the application

First fetch the dependencies with `yarn`.

Create an `environments/environment.local.ts` file with

```typescript
export const environment = {
    production: false,
    auth: {
        clientId: "VALUE PROVIDED BY INITIALIZATION SCRIPT",
        loginUrl: "http://localhost/am/local/oauth/authorize",
        logoutUrl: "http://localhost/am/local/logout",
        tokenEndpoint: "http://localhost/am/local/oauth/token",
        revocationEndpoint: "http://localhost/am/local/oauth/revoke",
        userinfoEndpoint: "http://localhost/am/local/oidc/userinfo",
        issuer: "http://localhost/am/local/oidc",
        redirectUri: `${window.location.origin}`,
        postLogoutRedirectUri: `${window.location.origin}`,
        responseType: "code",
        scope: "openid profile email",
        skipIssuerCheck: false,
        requireHttps: false,
    },
};
```

Run `ng serve` for a dev server. 

Navigate to `http://localhost:4200/`.

You can login with `alice/pass`.
