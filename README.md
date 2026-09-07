<div align="center">

# PropVault
### India's Multi-Vendor Real Estate Marketplace

[![Java](https://img.shields.io/badge/Java-17-orange?logo=openjdk)](https://openjdk.org/projects/jdk/17/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-brightgreen?logo=springboot)](https://spring.io/projects/spring-boot)
[![React](https://img.shields.io/badge/React-18-61DAFB?logo=react)](https://react.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-3-02569B?logo=flutter)](https://flutter.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue?logo=postgresql)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

**Connecting verified agents with serious property buyers across 35+ Indian cities.**

[Live Preview](#instant-preview) · [API Docs](#api-reference) · [Setup Guide](#quick-start) · [Contact](#contact)

</div>

---

## 📍 Company

**PropVault Technologies Pvt. Ltd.**  
Office No. 410, 4th Floor, South Ex Tower, Masjid Moth, NDSE Part 2, New Delhi – 110049  
📞 +91 11 4567 8900 · 📱 +91 98100 00000 · ✉️ hello@propvault.in  
🕐 Mon – Sat, 9:00 AM – 6:00 PM IST · RERA: RERA/DL/AG/2024/0001 · GSTIN: 07AABCP1234F1ZX

---

## 📁 Repository Structure

```
propvault/
├── backend/                        # Spring Boot 3.2 REST API
│   ├── src/main/java/com/propvault/
│   │   ├── controller/             # 5 REST controllers  → 26 endpoints
│   │   ├── service/                # 6 service interfaces + 6 implementations
│   │   ├── entity/                 # 8 JPA entities
│   │   ├── repository/             # 7 Spring Data JPA repositories
│   │   ├── dto/                    # 6 request + 10 response DTOs
│   │   ├── security/               # JWT filter + UserDetailsService
│   │   ├── config/                 # SecurityConfig, AwsConfig, AppConfig
│   │   ├── enums/                  # UserRole, PropertyStatus, LeadStatus…
│   │   └── exception/              # ApiException + GlobalExceptionHandler
│   └── src/main/resources/
│       ├── application.yml         # All environment config
│       └── db/migration/           # V1 Flyway migration (9 tables)
│
├── frontend/                       # React 18 + Vite web app
│   ├── src/App.jsx                 # 5,932 lines · 51 components · 20 screens
│   ├── propvault-preview.html      # Standalone preview (no build needed)
│   ├── index.html
│   ├── vite.config.js
│   └── package.json
│
└── mobile/                         # Flutter 3 (Android + iOS)
    └── lib/
        ├── main.dart
        ├── core/                   # API client, theme, router, widgets
        └── features/               # auth, properties, leads, agent, subscription
```

---

## ✨ Features

### 🏠 Buyer
| Feature | Description |
|---------|-------------|
| Property Search | Filter by city, type, price range, beds, furnishing, amenities |
| Map View | Interactive map with property pins and price labels |
| Side-by-side Compare | Compare up to 3 properties with a detailed feature table |
| Save & Favourites | Save properties, manage saved list |
| Enquiry System | Submit leads via form, call, or WhatsApp |
| Visit Scheduling | Book site visits with date picker, time slots, guest info |
| Buyer Dashboard | Enquiry history, scheduled visits, saved properties, recommendations |
| Agent Profiles | View agent company page, listings, ratings, credentials |

### 🏢 Agent
| Feature | Description |
|---------|-------------|
| Listing Management | Create, edit, preview, delete property listings |
| 5-step Submission Wizard | Basic Info → Location → Details → Media → Buyer Preview |
| Lead Pipeline | Kanban-style lead tracking with status updates and notes |
| Visit Management | Confirm, reschedule, or cancel buyer visits |
| Analytics Dashboard | Views, leads, conversions, WhatsApp/call clicks over time |
| Featured Slots | Promote listings to top of search, slot usage tracked per plan |
| Subscription Management | View plan, usage quota, invoices, upgrade/cancel |
| Agent Profile | Public company page with credentials, reviews, listings |

### ⚙️ Super Admin
| Feature | Description |
|---------|-------------|
| Platform Overview | Live MRR, agent count, listing count, leads this month |
| Agent Management | Approve, suspend, reinstate agents with email notification |
| Listing Approval Queue | Review, approve, or reject listings with reason |
| Subscription Management | View all subs, cancel, reinstate, search/filter by plan+status |
| Revenue Analytics | MRR by plan, GST breakdown, 6-month trend chart |
| User Management | Buyers + agents unified view, suspend/reinstate accounts |
| Platform Settings | Edit plan pricing/limits, GST rate, trial duration inline |

### 🌐 Public Marketing Pages
| Page | Description |
|------|-------------|
| Home | Hero with search, featured listings, stats, how-it-works, testimonials, agent CTA |
| About | Mission, registered office, leadership team, company timeline, values |
| Contact | Enquiry form, full office details, department email directory, map link |
| Resources | 12 buyer + agent guides, 6 FAQs, article-style layout |
| Agents Directory | Searchable/filterable grid of all verified agents |

---

## 🚀 Quick Start

### Instant Preview (zero install)
```
Open frontend/propvault-preview.html in any browser.
```
Self-contained — React is bundled via CDN. Works offline after first load.

---

### Frontend Dev Server
```bash
cd frontend
npm install
npm run dev
# → http://localhost:5173
```
The Vite proxy forwards `/api` calls to `localhost:8080` automatically.

---

### Backend API Server
**Prerequisites:** Java 17+, PostgreSQL 15+, Maven 3.8+

```bash
# 1. Create the database
psql -U postgres -c "CREATE DATABASE propvault;"

# 2. Set your credentials in application.yml (see Environment Variables below)

# 3. Run — Flyway migrates the schema automatically on startup
cd backend
mvn spring-boot:run

# API base: http://localhost:8080/api/v1
# Swagger UI: http://localhost:8080/swagger-ui.html
```

---

### Mobile App (Flutter)
```bash
cd mobile
flutter pub get
flutter run          # Connect a device or start an emulator first
```

---

## 🔑 Demo Logins

| Role        | Email                    | Password    | Lands on          |
|-------------|--------------------------|-------------|-------------------|
| 🏠 Buyer    | buyer@propvault.in       | password123 | Buyer Dashboard   |
| 🏢 Agent    | agent@propvault.in       | password123 | Agent Dashboard   |
| ⚙️ Admin    | admin@propvault.in       | password123 | Admin Overview    |

> Use the role-switcher icons (🏠 🏢 ⚙️) in the top-right corner of the web app to switch between roles instantly without logging out.

---

## 🗄️ Database Schema

**9 core tables** created by Flyway migration `V1__init_schema.sql`:

| Table | Description |
|-------|-------------|
| `users` | All users — buyers, agents, admins |
| `agents` | Agent profile, company info, RERA/license, S3 logo URL |
| `subscription_plans` | Basic / Pro / Premium plan definitions |
| `subscriptions` | Per-agent active subscription with Razorpay IDs |
| `properties` | Full listing data with FTS vector, view/contact counts |
| `property_media` | Images/videos linked to properties (S3 keys) |
| `leads` | Buyer enquiries linked to property + agent |
| `invoices` | Billing records with GST breakdown |
| `subscription_plan_audits` | Plan pricing change history |

**Full-text search** on `properties` using PostgreSQL `tsvector` (title + locality + city + description).

---

## 🔌 API Reference

All endpoints are prefixed `/api/v1`. JWT Bearer token required except where marked `[public]`.

### Authentication
```
POST   /auth/register                  [public] Register buyer or agent
POST   /auth/login                     [public] Get access + refresh tokens
POST   /auth/refresh                   [public] Refresh access token
POST   /auth/forgot-password           [public] Request reset link
POST   /auth/reset-password            [public] Set new password with token
GET    /auth/verify-email?token=…      [public] Verify email address
POST   /auth/resend-verification       [public] Resend verification email
POST   /auth/logout                              Invalidate session
```

### Properties
```
GET    /properties/search              [public] Full-text + filter search (paginated)
GET    /properties/{id}               [public] Single property detail
POST   /properties                    [AGENT]  Create listing → PENDING_REVIEW
PUT    /properties/{id}               [AGENT]  Update own listing
DELETE /properties/{id}               [AGENT]  Delete own listing
PATCH  /properties/{id}/featured      [AGENT]  Toggle featured (plan limit enforced)
```

### Leads & Visits
```
POST   /leads/property/{id}           [public] Submit enquiry (attaches buyer if logged in)
GET    /leads/agent                   [AGENT]  Agent's lead pipeline
PATCH  /leads/{id}/status             [AGENT]  Update lead status + notes
POST   /visits/property/{id}          [public] Request a site visit
GET    /visits/my                     [AGENT]  Agent's visit requests
PATCH  /visits/{id}/confirm           [AGENT]  Confirm with exact datetime
PATCH  /visits/{id}/status            [AGENT]  Update visit status
```

### Agent
```
GET    /agents/{id}/public            [public] Public agent profile
GET    /agents/{id}/properties        [public] Agent's live listings
GET    /agents/me                     [AGENT]  Own profile
PUT    /agents/me                     [AGENT]  Update profile
POST   /agents/me/logo                [AGENT]  Upload company logo (S3)
GET    /agents/me/stats               [AGENT]  Dashboard stats
GET    /agents/me/subscription        [AGENT]  Own subscription
```

### Payments & Subscriptions
```
POST   /payments/create-subscription  [AGENT]  Create Razorpay subscription
POST   /payments/verify               [AGENT]  Verify payment + activate
POST   /payments/webhook              [public] Razorpay webhook (HMAC-verified)
POST   /payments/cancel               [AGENT]  Cancel subscription
GET    /payments/invoices             [AGENT]  Invoice history
GET    /subscription-plans            [public] All available plans
```

### Analytics
```
GET    /analytics/agent/me            [AGENT]  30-day stats (views, leads, conversions)
GET    /analytics/agent/me/property/{id} [AGENT] Per-property analytics
```

### Notifications
```
GET    /notifications                 [auth]   Paginated notification list
GET    /notifications/unread-count    [auth]   Unread badge count
PATCH  /notifications/read-all        [auth]   Mark all read
PATCH  /notifications/{id}/read       [auth]   Mark one read
```

### Super Admin `/admin/**`
```
GET    /admin/dashboard                        Platform KPI snapshot
GET    /admin/agents                           All agents (filterable)
PATCH  /admin/agents/{id}/approve              Verify agent + email
PATCH  /admin/agents/{id}/suspend              Deactivate account
PATCH  /admin/agents/{id}/reinstate            Reactivate account
GET    /admin/properties/pending               Listing approval queue
PATCH  /admin/properties/{id}/approve          Approve listing
PATCH  /admin/properties/{id}/reject           Reject with reason
GET    /admin/subscriptions                    All subscriptions
DELETE /admin/subscriptions/{id}               Cancel subscription
GET    /admin/users/buyers                     All buyer accounts
PATCH  /admin/users/{id}/suspend               Suspend any user
PATCH  /admin/users/{id}/reinstate             Reinstate any user
GET    /admin/revenue                          MRR + GST breakdown
GET    /admin/plans                            Plan definitions
PUT    /admin/plans/{id}                       Update plan pricing/limits
```

---

## ⚙️ Environment Variables

Edit `backend/src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/propvault
    username: YOUR_DB_USER
    password: YOUR_DB_PASSWORD
  mail:
    host: smtp.gmail.com
    port: 587
    username: YOUR_EMAIL@gmail.com
    password: YOUR_APP_PASSWORD

propvault:
  jwt:
    secret: YOUR_JWT_SECRET_AT_LEAST_32_CHARACTERS_LONG
    expiration: 86400000        # 24h in ms
    refresh-expiration: 604800000  # 7 days in ms
  aws:
    access-key: YOUR_AWS_ACCESS_KEY
    secret-key: YOUR_AWS_SECRET_KEY
    bucket: propvault-media
    region: ap-south-1
  razorpay:
    key-id: YOUR_RAZORPAY_KEY_ID
    key-secret: YOUR_RAZORPAY_KEY_SECRET
    webhook-secret: YOUR_WEBHOOK_SECRET
  gst-percent: 18.0
  app:
    url: https://app.propvault.in
```

---

## 🏗️ Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Backend language** | Java | 17 LTS |
| **Backend framework** | Spring Boot | 3.2.3 |
| **Database** | PostgreSQL | 15+ |
| **DB migrations** | Flyway | 9 |
| **Auth** | JWT (JJWT) + BCrypt | — |
| **Payments** | Razorpay Subscriptions API | — |
| **File storage** | AWS S3 + Presigned URLs | — |
| **Email** | Spring Mail (SMTP) | — |
| **API docs** | SpringDoc OpenAPI (Swagger) | 2.x |
| **Frontend** | React | 18.2 |
| **Frontend bundler** | Vite | 5.2 |
| **Mobile** | Flutter | 3.x |
| **HTTP client (mobile)** | Dio | 5.x |

---

## 📧 Contact & Support

| Purpose | Contact |
|---------|---------|
| General enquiries | hello@propvault.in |
| Agent support | support@propvault.in |
| Buyer assistance | buyers@propvault.in |
| Legal & compliance | legal@propvault.in |
| Press & partnerships | press@propvault.in |
| Careers | careers@propvault.in |

**Registered Office:**  
Office No. 410, 4th Floor, South Ex Tower, Masjid Moth, NDSE Part 2, New Delhi – 110049  
Nearest Metro: AIIMS Station (Yellow Line) — 10 min walk

---

## 📄 License

Proprietary — © 2024 PropVault Technologies Pvt. Ltd. All rights reserved.  
Unauthorised copying, distribution, or modification of this code is strictly prohibited.

---

<div align="center">
  Built with ❤️ in New Delhi, India
</div>
