# PropVault — Frontend

React 18 web app for the PropVault real estate marketplace.  
Single-file architecture (`src/App.jsx`) — 51 components, 20 screens, 10 public pages.

## Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| React | 18.2 | UI framework |
| Vite | 5.2 | Dev server + build tool |
| CSS-in-JS | — | Inline styles with design tokens |

## Instant Preview (no install)

```bash
# Open directly in any browser — no server, no npm
open frontend/propvault-preview.html
```

## Dev Server

```bash
npm install
npm run dev
# → http://localhost:5173

# Vite proxies /api calls to localhost:8080 automatically
```

## Production Build

```bash
npm run build
# Output → dist/
# Deploy dist/ to Vercel, Netlify, S3, or any static host
```

## Architecture

All app code lives in `src/App.jsx`, structured as:

```
Design tokens (const C)
Mock data (PROPERTIES, AGENTS, LEADS, PLANS, INVOICES…)
Utility components (Card, Btn, Input, Badge, Table, Alert…)
Feature components (PropertyCard, SiteHeader, SiteFooter…)
Public screens (HomePage, AboutPage, ContactPage, ResourcesPage, PubAgentsPage…)
Buyer screens (BuyerDashboard, SearchScreen, DetailScreen, FavoritesScreen…)
Agent screens (AgentDashboard, AddPropertyScreen, LeadsScreen, VisitManagementScreen…)
Admin screens (AdminDash, AdminAgents, AdminListings, AdminSubs, AdminRevenueScreen,
               AdminUsers, AdminSettings)
Root App (auth gate, router, shared state, navigateTo)
```

## Demo Logins

| Role | Email | Password |
|------|-------|----------|
| Buyer | buyer@propvault.in | password123 |
| Agent | agent@propvault.in | password123 |
| Admin | admin@propvault.in | password123 |

## Connecting to the Backend

Set `VITE_API_BASE_URL` in `.env.local`:

```env
VITE_API_BASE_URL=http://localhost:8080/api/v1
VITE_RAZORPAY_KEY_ID=rzp_test_xxxx
```

Currently the app uses mock data. To switch to real API calls, replace the
mock state mutations in each screen with `fetch()` calls against `VITE_API_BASE_URL`.
The Vite dev proxy handles CORS automatically in development.
