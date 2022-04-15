import { Component } from "@angular/core";
import { AuthService } from "./auth.service";

@Component({
  selector: "app-root",
  template: `
    <div *ngIf="!idToken">
      <p>
        <button (click)="login()">Login</button>
      </p>
    </div>

    <div *ngIf="idToken">
      <div style="text-align:center">
        <h1>Welcome to {{ title }}!</h1>
      </div>

      <h2>User</h2>
      <p>{{ userName }}</p>

      <h2>Id-Token</h2>
      <p>{{ idToken }}</p>

      <h2>Access Token</h2>
      <p>{{ accessToken }}</p>

      <p>
        <button (click)="refresh()">Refresh</button>
        <button (click)="logout()">Logout</button>
      </p>
    </div>
  `,
  styles: [],
})
export class AppComponent {
  title = "App";

  constructor(private authService: AuthService) {}

  login() {
    return this.authService.login();
  }

  logout() {
    return this.authService.logout();
  }

  refresh() {
    return this.authService.refreshToken();
  }

  get userName(): string {
    return this.authService.userName;
  }

  get idToken(): string {
    return this.authService.idToken;
  }

  get accessToken(): string {
    return this.authService.accessToken;
  }
}
