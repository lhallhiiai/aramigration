import { OktaAuth } from "@okta/okta-auth-js";

export const oktaAuth = new OktaAuth({
  issuer: "https://hii-test.oktapreview.com/oauth2/default",
  clientId: "0oawyh822mSqLuAqu1d7",
  redirectUri: `${window.location.origin}/login/callback`,
  scopes: ["openid", "profile", "email"],
  pkce: true,
});
