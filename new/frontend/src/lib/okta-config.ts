import { OktaAuth } from "@okta/okta-auth-js";

const issuer: string = import.meta.env.VITE_OKTA_ISSUER;
const clientId: string = import.meta.env.VITE_OKTA_CLIENT_ID;

if (!issuer || !clientId) {
  throw new Error(
    "Okta configuration missing. Set VITE_OKTA_ISSUER and VITE_OKTA_CLIENT_ID in .env.local for dev, or as build args for production builds. See docs/ship/LOCAL_DEV_SECRETS.md."
  );
}

export const oktaAuth = new OktaAuth({
  issuer,
  clientId,
  redirectUri: `${window.location.origin}/login/callback`,
  scopes: ["openid", "profile", "email"],
  pkce: true,
});
