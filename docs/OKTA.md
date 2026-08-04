# Okta Authentication Setup Guide

## Configuration Reference

| Setting | Value |
|---|---|
| Okta Admin Domain | `https://hii-test-admin.oktapreview.com` |
| Okta Issuer URI | `https://hii-test.oktapreview.com/oauth2/default` |
| Audience | `api://default` |
| API Client ID | `0oawygfqavWdJX7Nw1d7` |
| Frontend SPA Client ID | `0oawyh822mSqLuAqu1d7` |

---

## Step 1 — Verify Authorization Server

Before doing anything else, confirm the authorization server is reachable:

```powershell
Invoke-RestMethod "https://hii-test.oktapreview.com/oauth2/default/.well-known/oauth-authorization-server"
```

The response should include `issuer`, `token_endpoint`, and `jwks_uri`. If it does, the server is live.

---

## Step 2 — Create the API Application in Okta

1. Okta admin console → **Applications → Applications → Create App Integration**
2. Select **API Services**
3. Name: `ARA Dev API`
4. After creation note the **Client ID** → save to CLAUDE.md as `Test API Client ID`

---

## Step 3 — Create the Frontend SPA Application in Okta

1. **Applications → Applications → Create App Integration**
2. Select **OIDC - OpenID Connect → Single-Page Application**
3. Name: `ARA Dev Frontend`
4. Set **Sign-in redirect URI**: `http://localhost:5173/login/callback`
5. Set **Sign-out redirect URI**: `http://localhost:5173`
6. Click **Save**
7. Note the **Client ID** from the **General** tab → save to CLAUDE.md as `Test Frontend SPA Client ID`

---

## Step 4 — Configure Trusted Origins

1. **Security → API → Trusted Origins → Add Origin**
2. Name: `ARA Local Dev`
3. Origin URL: `http://localhost:5173`
4. Check both **CORS** and **Redirect**
5. Click **Save**

---

## Step 5 — Enable Application Visibility

1. **Applications → ARA Dev Frontend → General tab**
2. Scroll to **Application Visibility**
3. Check **Display application icon to users**
4. Click **Save**

---

## Step 6 — Configure Grant Types

On the **ARA Dev Frontend** General tab, verify under **Grant type**:
- **Authorization Code** is checked
- **Require PKCE** is checked

---

## Step 7 — Create a Permissive Authentication Policy for Dev

> **WARNING**: Only modify policies assigned to the ARA app.
> Never modify system-level policies (Okta Dashboard, Okta Admin Console).
> Modifying system-level policies can lock you out of the admin console.

1. **Security → Authentication Policies → Add a Policy**
2. Name: `ARA Dev Test`
3. Click **Save**
4. The default catch-all rule is created automatically — click **Edit** on it
5. Set **Access** to **Allow access**
6. Set **Authentication** to **Any 1 factor type**
7. Click **Save**

---

## Step 8 — Assign the Policy to the App

1. **Applications → ARA Dev Frontend → Sign On tab**
2. Under **User Authentication** click **Edit**
3. Change the policy to `ARA Dev Test`
4. Click **Save**

---

## Step 9 — Assign Users to the Application

For each user who needs access:

1. **Applications → ARA Dev Frontend → Assignments tab**
2. Click **Assign → Assign to People**
3. Find the user, click **Assign → Save and Go Back**
4. Click **Done**

---

## Step 10 — Sync Okta User IDs to the Database

Each user in `ara_new` has an `ExternalUserId` column that must match their Okta `sub` claim (the Okta User ID).

### Get a user's Okta User ID
- Okta admin → **Directory → People** → click the user
- The URL contains the ID: `.../admin/user/profile/view/00u...`
- The `00u...` value is the Okta User ID

### Bulk sync via PowerShell (requires Okta API token)

**Get an API token:**
1. **Security → API → Tokens → Create Token**
2. Name: `ARA Dev Sync`
3. Copy the token (shown only once)

**Run the sync script** (to be built):
```powershell
.\Invoke-OktaUserSync.ps1 `
    -OktaApiToken "YOUR_TOKEN" `
    -OktaDomain "https://hii-test-admin.oktapreview.com" `
    -ConnectionString "Server=lhall-ara-dev-westus2.database.windows.net;Database=ara_new;User ID=araapp;Password=...;Encrypt=True;"
```

### Manual single-user update
```sql
UPDATE dbo.[User]
SET ExternalUserId = '00uXXXXXXXXXXXXXX'  -- Okta User ID from admin console
WHERE UserId = <your UserId>;
```

---

## Step 11 — Enable Okta in the Application

### Backend
In `new/backend/src/ARA.Api/appsettings.Development.json`, set the Issuer:

```json
"Okta": {
    "Issuer": "https://hii-test.oktapreview.com/oauth2/default",
    "Audience": "api://default"
}
```

### Frontend
In `new/frontend/src/components/RequireAuth.tsx`, remove the dev bypass lines:
```typescript
// Remove these two lines:
if (import.meta.env.DEV) return;   // in useEffect
if (import.meta.env.DEV) return <>{children}</>;
```

In `new/frontend/src/lib/api-client.ts`, remove the dev bypass line:
```typescript
// Remove this line:
if (import.meta.env.DEV) return {};
```

---

## Dev Bypass (Current State)

Okta is currently **disabled** for local development. Auth is bypassed in both layers:

| Layer | How bypassed |
|---|---|
| Backend | `Okta:Issuer` is empty in `appsettings.Development.json` → `DevAuthenticationHandler` activates |
| Frontend | `import.meta.env.DEV` checks in `RequireAuth.tsx` and `api-client.ts` skip all Okta calls |

All requests are auto-authenticated as `dev-user-00000000` in this mode.

---

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `You are not allowed to access this app` | No matching authentication policy rule | Check **Security → Authentication Policies** → ensure `ARA Dev Test` is assigned to the app and has an Allow rule |
| `no_matching_policy` (System Log) | Policy has no rule matching the user | Edit the catch-all rule in `ARA Dev Test` → set to Allow |
| `VERIFICATION_ERROR` (System Log) | Machine can't satisfy the enrolled factor (e.g. security key registered on another machine) | Remove the Security Key factor from your Okta user profile via **enduser/settings** on a working machine |
| `Unable to sign in` | Policy factor requirement doesn't match enrolled factors | Change policy rule authentication to **Any 1 factor type** |
| Locked out of Okta admin console | System-level policy was modified | Log in from another machine → revert the changed policy |
