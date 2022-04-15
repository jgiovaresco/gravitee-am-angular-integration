import { APP_INITIALIZER, NgModule } from "@angular/core";
import { HttpClientModule } from "@angular/common/http";
import { BrowserModule } from "@angular/platform-browser";
import { OAuthModule } from "angular-oauth2-oidc";

import { AppComponent } from "./app.component";
import { AuthService } from "./auth.service";

@NgModule({
  declarations: [AppComponent],
  imports: [BrowserModule, HttpClientModule, OAuthModule.forRoot()],
  providers: [
    {
      provide: APP_INITIALIZER,
      useFactory: initApp,
      deps: [AuthService],
      multi: true,
    },
  ],
  bootstrap: [AppComponent],
})
export class AppModule {}

export function initApp(authService: AuthService) {
  return () => authService.load();
}
