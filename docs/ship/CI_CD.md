# CI / CD — PR Validation

This document covers Item 3 of `docs/SHIP_PLAN.md`: automated PR validation via GitHub Actions.

## Why GitHub Actions

`lhallhiiai/aramigration` is hosted on GitHub. The `gh` CLI is the standard tool for PR work in this project. Azure DevOps was not present anywhere in the repo. GitHub Actions is the natural choice — no new platform, no new credentials, no extra cost.

## Workflow file

`.github/workflows/pr-validation.yml` triggers on every pull request targeting `dev` or `main` (and supports `workflow_dispatch` for manual reruns). It runs three independent jobs in parallel:

### `backend` — .NET 10 build + format check

- `actions/setup-dotnet@v4` with `10.0.x`
- `dotnet restore ARA.slnx`
- `dotnet build ARA.slnx -c Release --no-restore` — fails on any compiler error or warning
- `dotnet format ARA.slnx --verify-no-changes --no-restore` — fails on any formatting violation

### `frontend` — Vite build + ESLint

- `actions/setup-node@v4` with `24` and npm caching keyed off `new/frontend/package-lock.json`
- `npm ci` — uses the lock file, no version drift
- `npm run lint` — fails on any ESLint error
- `npm run build` — TypeScript compile + Vite production bundle. Build-time placeholder env vars (`VITE_OKTA_ISSUER`, `VITE_OKTA_CLIENT_ID`) are set so `import.meta.env.*` substitution succeeds. These are not credentials — production builds inject real values via Docker build args (see `new/frontend/Dockerfile`).

### `commitlint` — Conventional Commits

- `wagoid/commitlint-github-action@v6` validates every commit on the PR against `commitlint.config.cjs` at the repo root.
- The configured `type-enum` exactly matches CLAUDE.md's allowed types: `feat`, `fix`, `data`, `infra`, `refactor`, `test`, `docs`, `chore`, `style`.
- Header max length is 72 characters; subject must be lowercase and not end with a period — also per CLAUDE.md.

## What is **not** gated yet (deferred to Item 7)

- `dotnet test` — backend unit and integration tests
- `npm run test` — frontend Vitest suite
- Coverage thresholds (80% backend / 70% frontend)

These all land in Item 7. Item 3 deliberately ships a build-only gate so PR validation exists before more code lands, without blocking on the test-coverage gap-fill work that's queued for the end of the plan.

## Branch protection (manual GitHub UI step)

After this workflow lands and runs successfully on at least one PR, configure branch protection on `dev` and `main`. The required state is captured below — apply via **Settings → Branches → Branch protection rules** in the GitHub UI. (No `gh api` script for this; branch protection writes need write access to repository settings, which is owner-only.)

For both `dev` and `main`:

- **Require a pull request before merging:** on
  - **Require approvals:** 1 (or per team policy)
- **Require status checks to pass before merging:** on
  - Required checks: `Backend (build + format)`, `Frontend (lint + build)`, `Commit messages (Conventional Commits)`
  - **Require branches to be up to date before merging:** on
- **Do not allow bypassing the above settings:** on for `main`, optional for `dev`
- **Restrict who can push to matching branches:** keep the default (only via PR)

Document the configured state inline here when applied:

| Branch | Protection applied | Date | By |
| ------ | ------------------ | ---- | -- |
| `dev`  | _pending_          | _—_  | _—_ |
| `main` | _pending_          | _—_  | _—_ |

## Local pre-commit checks

The same gates can be run locally before pushing:

```powershell
# Backend
cd new/backend
dotnet build ARA.slnx -c Release
dotnet format ARA.slnx --verify-no-changes

# Frontend
cd ../frontend
npm ci
npm run lint
npm run build
```

Commit-message format is enforced server-side by the workflow, but you can lint locally if you have Node available:

```powershell
npx --yes -p @commitlint/cli -p @commitlint/config-conventional commitlint --from=HEAD~1
```

## When the gate fails

Common failure modes:

- **Backend build fails** — fix the compiler error or warning. CLAUDE.md mandates 0 warnings, 0 errors.
- **`dotnet format --verify-no-changes` fails** — run `dotnet format` locally, commit the result.
- **`npm run lint` fails** — fix the ESLint error. The shadcn `/ui` baseline is exempted from the rules that triggered earlier false positives via `eslint.config.js`.
- **Frontend build fails** — usually a TypeScript error. The build sets placeholder VITE_OKTA_* env vars; if you've added new VITE_-prefixed env vars, declare them in `new/frontend/src/vite-env.d.ts` and provide build-time values.
- **Commit message rejected** — check `commitlint.config.cjs`. Convert your subject to one of the allowed types (`feat`, `fix`, `data`, `infra`, `refactor`, `test`, `docs`, `chore`, `style`) and verify the line is ≤72 chars, lowercase, no trailing period.
