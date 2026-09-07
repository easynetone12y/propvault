# Changelog

All notable changes to PropVault are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).  
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### In Progress
- Buyer saved-properties REST endpoints
- Agent notification preferences
- Admin audit log screen

---

## [1.0.0] — 2024-07-01

### Added — Backend
- Spring Boot 3.2 REST API with JWT authentication
- Role-based access control: `SUPER_ADMIN`, `AGENT`, `BUYER`
- Full auth flow: register, login, refresh, logout, email verify, forgot/reset password
- `AuthController` — 8 public endpoints
- `PropertyController` — CRUD, search with full-text + filters, view count, featured toggle
- `LeadController` — enquiry submission (guest + authenticated), agent pipeline, status updates
- `VisitController` — site visit scheduling, agent confirmation, status management
- `AgentController` — public profile, self-edit, logo upload, dashboard stats
- `AdminController` — 16 endpoints: agent approval, listing review, subscription management, revenue, user management, plan editor
- `PaymentController` — Razorpay subscription create/verify/cancel, HMAC webhook, invoices
- `NotificationController` — list, unread count, mark read
- `AnalyticsController` — per-agent 30-day stats, per-property stats
- `SubscriptionPlanController` — public plan listing
- 14 JPA entities with auditing
- 3 Flyway migrations (V1–V3): core schema, visits/notifications/saved properties, password reset tokens
- `EmailServiceImpl` — 10 HTML email templates (verification, lead alerts, visit confirmations, invoices, expiry warnings)
- `S3ServiceImpl` — media upload, delete, presigned URL generation
- `RazorpayServiceImpl` — subscription lifecycle with webhook verification
- `AnalyticsServiceImpl` — daily metric snapshots via `@Scheduled` cron
- `FeaturedListingServiceImpl` — plan-limit-enforced featured slot management
- `SavedProperty` entity + repository for buyer favourites
- `UserAdminResponse`, `SubscriptionAdminResponse`, `RevenueResponse` DTOs
- Full PostgreSQL FTS on property title, locality, city, description

### Added — Frontend (React 18)
- 5,932-line single-file React app (`src/App.jsx`)
- 51 components, 20 authenticated screens, 10 public pages
- `SiteHeader` with sticky address bar showing full office address
- `SiteFooter` with RERA/GSTIN trust bar, social links, department contacts
- `HomePage` — hero search, featured listings, stats, how-it-works, testimonials
- `AboutPage` — office details, leadership team, company timeline
- `ContactPage` — enquiry form with subject selector, office card, Google Maps link, department directory
- `ResourcesPage` — 12 buyer/agent guides, 6 FAQs, tabbed layout
- `PubAgentsPage` — searchable verified agent directory
- `BuyerDashboard` — enquiry history, visits, saved properties, recommendations
- `AgentDashboard` — live stats from mock data, quick actions
- `AdminDash` — live MRR/agent/listing counts, pending approvals panel
- `AdminAgents` — approve/suspend/reinstate with toast + confirmation modal
- `AdminListings` — approve/reject with rejection-reason modal
- `AdminSubs` — cancel/reinstate, search/filter by plan and status
- `AdminRevenueScreen` — 6-month SVG bar chart, plan breakdown, transaction log
- `AdminUsers` — agents + buyers unified view
- `AdminSettings` — inline plan editor, GST %, trial days, danger zone
- `AddPropertyScreen` — fully controlled 5-step create/edit wizard with buyer preview
- `MyPropsScreen` — live state, delete with confirm modal, featured toggle, edit routing
- `LeadsScreen` — mutable state, inline status updates, call/WhatsApp actions
- `VisitManagementScreen` — confirm/decline/status-update, detail panel
- `AgentAnalyticsScreen` — daily bar chart, conversion funnel, top properties
- `FeaturedManagementScreen` — toggle featured, slot usage bar, upgrade prompt
- `SubscriptionScreen` — cancel/undo flow, invoice downloads with toast
- `NotificationCenter` — mark read/all-read, type badges
- `AgentProfileEditScreen` — all fields, specialisations toggle, languages toggle
- `AgentMyProfileScreen` — public preview with edit button
- `AgentPublicProfile` — company hero, stats, property grid
- `PropertyCompareScreen` — up to 3 side-by-side, feature table
- `MapSearchScreen` — SVG map with property pins, side list panel
- `VisitScheduleModal` — date strip, time slot selector, guest form, success state
- `ForgotPasswordScreen` — 3-step email → OTP → reset flow
- `AuthScreen` — login/register with role selector, demo quick-fill
- `PublicLayout` — wraps all public/marketing screens with SiteHeader + SiteFooter
- Full auth gate — unauthenticated users redirected to login for protected screens
- `COMPANY` constant — single source of truth for all contact/address data
- `navigateTo()` with scroll-to-top and screen history stack
- Shared `agentProps` / `editingProp` state lifted to Root App for create/edit sharing

### Added — Mobile (Flutter 3)
- 17 Dart files across `core/` and `features/`
- `ApiClient` with Dio + JWT interceptor + automatic token refresh
- `LoginScreen` / `RegisterScreen`
- `PropertySearchScreen` — filters, infinite scroll
- `PropertyDetailScreen` — gallery, map, enquiry modal, Call/WhatsApp/Visit
- `ContactAgentSheet` — bottom sheet lead form
- `LeadsScreen` — tabbed by status, quick actions
- `AddPropertyScreen` — 4-step wizard
- `AgentDashboardScreen` — stats, listings, leads, plan usage
- `SubscriptionScreen` — plans, Razorpay checkout, invoices
- `AdminDashboardScreen` — overview, agent approval, listings review
- `AppTheme` — Material 3 theme with Inter font
- `AppRouter` — role-based initial screen via `go_router`
- Material 3 design system with Inter font family

### Infrastructure
- `docker-compose.yml` — PostgreSQL 15, Redis 7, backend, frontend
- Multi-stage `Dockerfile` for backend (builder + JRE alpine)
- Multi-stage `Dockerfile` for frontend (Node builder + Nginx)
- `nginx.conf` — SPA routing, API proxy, static asset caching, gzip
- GitHub Actions CI: backend (Maven + PostgreSQL service), frontend (Node build)
- GitHub Actions CD: Docker Hub publish on merge to main
- `scripts/setup.sh` — automated local environment setup
- `scripts/init-db.sql` — PostgreSQL extensions (uuid-ossp, pg_trgm, unaccent)
- `.env.example` for backend, frontend, mobile
- GitHub issue templates (bug report, feature request)
- GitHub PR template

---

## [0.1.0] — 2024-04-01 *(internal prototype)*

### Added
- Initial project scaffolding
- Basic property listing and search
- Agent registration flow

---

[Unreleased]: https://github.com/gajendra-73/propvault/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/gajendra-73/propvault/releases/tag/v1.0.0
[0.1.0]: https://github.com/gajendra-73/propvault/releases/tag/v0.1.0
