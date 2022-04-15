import { Injectable } from "@angular/core";
import { OAuthService } from "angular-oauth2-oidc";
import { filter } from "rxjs/operators";
import { environment } from "../environments/environment";

@Injectable({
  providedIn: "root",
})
export class AuthService {
  constructor(private readonly oauthService: OAuthService) {}

  load() {
    this.oauthService.configure(environment.auth);
    return this.oauthService.tryLoginCodeFlow({}).then(() => {
      this.oauthService.events
        .pipe(filter((e) => e.type === "token_received"))
        .subscribe((_) => this.oauthService.loadUserProfile());
    });
  }

  login() {
    this.oauthService.initCodeFlow();
  }

  logout() {
    this.oauthService.logOut();
  }

  refreshToken() {
    return this.oauthService.refreshToken();
  }

  get userName(): string {
    const claims: any = this.oauthService.getIdentityClaims();
    if (!claims) return "";
    return claims["given_name"];
  }
  get idToken(): string {
    return this.oauthService.getIdToken();
  }

  get accessToken(): string {
    return this.oauthService.getAccessToken();
  }
}
