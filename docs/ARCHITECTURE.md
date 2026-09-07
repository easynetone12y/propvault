# PropVault — Architecture

## System Overview

```
                        ┌─────────────────┐
                        │   Browser/App   │
                        └────────┬────────┘
                                 │ HTTPS
              ┌──────────────────┼──────────────────┐
              │                  │                  │
     ┌────────▼────────┐  ┌──────▼──────┐  ┌───────▼───────┐
     │  React Web App  │  │ Flutter iOS │  │ Flutter Android│
     │  (Vite, SPA)    │  │             │  │               │
     └────────┬────────┘  └──────┬──────┘  └───────┬───────┘
              │                  │                  │
              └──────────────────┼──────────────────┘
                                 │ REST / JSON
                        ┌────────▼────────┐
                        │  Spring Boot    │
                        │  API Server     │
                        │  :8080/api/v1   │
                        └─────┬──────┬───┘
                              │      │
              ┌───────────────┘      └───────────────┐
              │                                      │
     ┌────────▼────────┐                   ┌─────────▼──────┐
     │   PostgreSQL    │                   │     Redis       │
     │   (primary DB)  │                   │  (JWT blacklist)│
     └─────────────────┘                   └────────────────┘
              │
     ┌────────▼────────┐     ┌──────────────┐     ┌────────────┐
     │    AWS S3        │     │  Razorpay    │     │   SMTP     │
     │  (media storage) │     │  (payments)  │     │  (email)   │
     └─────────────────┘     └──────────────┘     └────────────┘
```

## Request Lifecycle

1. Client sends request with `Authorization: Bearer <JWT>`
2. `JwtAuthenticationFilter` validates token, injects `SecurityContext`
3. `SecurityConfig` checks role against the endpoint's `@PreAuthorize`
4. Controller delegates to Service layer
5. Service uses Repositories (Spring Data JPA) to query PostgreSQL
6. Response DTOs are returned as JSON

## Key Design Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Schema management | Flyway | Versioned migrations, repeatable, CI-friendly |
| Auth | JWT (stateless) | Scales horizontally; Redis blacklist for logout |
| File storage | AWS S3 + presigned URLs | Files never pass through the API server |
| Payments | Razorpay Subscriptions | Native INR support, auto-recurring billing |
| Email | Async Spring Mail | Non-blocking; failures are logged, never thrown |
| API docs | SpringDoc OpenAPI | Auto-generated from annotations |

## Database Schema

```
users ──< agents ──< properties ──< property_media
  │           │           │
  │           │           └──< leads (buyer enquiries)
  │           │
  │           └──< subscriptions ──< subscription_plans
  │           └──< invoices
  │
  └──< notifications
```
