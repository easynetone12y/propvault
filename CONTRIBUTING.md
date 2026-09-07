# Contributing to PropVault

Thank you for your interest in contributing to PropVault!

## Getting Started

1. **Fork** the repository on GitHub
2. **Clone** your fork locally
   ```bash
   git clone https://github.com/YOUR_USERNAME/propvault.git
   cd propvault
   ```
3. **Set up** the project locally
   ```bash
   bash scripts/setup.sh
   ```
4. **Create a branch** for your work
   ```bash
   git checkout -b feat/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

## Branch Naming

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feat/description` | `feat/buyer-wishlist` |
| Bug fix | `fix/description` | `fix/lead-email-null` |
| Docs | `docs/description` | `docs/api-reference` |
| Refactor | `refactor/description` | `refactor/auth-service` |
| Hotfix | `hotfix/description` | `hotfix/payment-webhook` |

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): short description

Optional longer body explaining WHY this change was made.
```

**Types:** `feat` · `fix` · `docs` · `refactor` · `test` · `chore`  
**Scopes:** `backend` · `frontend` · `mobile` · `admin` · `auth` · `payments` · `db`

**Examples:**
```
feat(backend): add buyer saved-properties endpoint
fix(frontend): prevent duplicate AGENTS constant declaration
docs(api): document admin revenue breakdown endpoint
refactor(admin): extract toSubscriptionAdminResponse helper
```

## Code Standards

### Backend (Java)
- Follow existing package structure — never put business logic in controllers
- All new endpoints need `@Operation(summary = "...")` for Swagger
- All new service methods need a Javadoc comment
- Use `ApiException.notFound()` / `.badRequest()` / `.forbidden()` — never throw raw exceptions
- New DB columns go in a new Flyway migration — never modify existing migrations
- Run `mvn checkstyle:check` before committing

### Frontend (React)
- All screens go in `src/App.jsx` as `function ScreenName({ ... })`
- Every screen must be wired in the router's `renderScreen()` switch
- Use existing design tokens from `const C = {...}` — no raw hex values
- Toast feedback for every user-mutating action
- Confirmation modal before every destructive action (delete, cancel, reject)

### Mobile (Flutter)
- Follow the `features/` folder structure — one folder per feature
- Use `ApiClient` (Dio) for all HTTP — no direct `http` package calls
- Handle token refresh in the Dio interceptor, not in individual screens

## Pull Request Process

1. Ensure your branch is up to date with `main`
   ```bash
   git fetch origin
   git rebase origin/main
   ```
2. Run all tests
   ```bash
   # Backend
   cd backend && mvn test

   # Frontend
   cd frontend && npm run build
   ```
3. Push and open a PR against `main`
4. Fill in the PR template completely
5. Wait for CI checks to pass
6. Request review from a maintainer

## Reporting Bugs

Use the [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md) issue template.  
Include logs, screenshots, and steps to reproduce.

## Proposing Features

Use the [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md) issue template.  
Describe the user role it affects and the problem it solves.

---

For questions, email **support@propvault.in** or open a Discussion on GitHub.
