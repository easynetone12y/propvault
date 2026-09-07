# PropVault API Reference

**Base URL:** `http://localhost:8080/api/v1`  
**Auth:** All protected endpoints require `Authorization: Bearer <token>`  
**Swagger UI:** `http://localhost:8080/swagger-ui.html`

## Authentication

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/register` | Public | Register buyer or agent |
| POST | `/auth/login` | Public | Get JWT tokens |
| POST | `/auth/refresh` | Public | Refresh access token |
| POST | `/auth/forgot-password` | Public | Send reset email |
| POST | `/auth/reset-password` | Public | Set new password |
| GET | `/auth/verify-email?token=` | Public | Verify email |
| POST | `/auth/logout` | Any | Invalidate token |

## Properties

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/properties/search` | Public | Paginated search with filters |
| GET | `/properties/{id}` | Public | Single property |
| POST | `/properties` | AGENT | Create listing |
| PUT | `/properties/{id}` | AGENT | Update own listing |
| DELETE | `/properties/{id}` | AGENT | Delete own listing |
| PATCH | `/properties/{id}/featured` | AGENT | Toggle featured |

### Search Parameters
`?q=` `&city=` `&type=APARTMENT` `&purpose=SALE` `&minPrice=` `&maxPrice=` `&beds=` `&page=0` `&size=12`

## Leads

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/leads/property/{id}` | Public | Submit enquiry |
| GET | `/leads/agent` | AGENT | Agent's lead pipeline |
| PATCH | `/leads/{id}/status` | AGENT | Update lead status |

## Visits

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/visits/property/{id}` | Public | Request site visit |
| GET | `/visits/my` | AGENT | Agent's visit requests |
| PATCH | `/visits/{id}/confirm` | AGENT | Confirm with datetime |
| PATCH | `/visits/{id}/status` | AGENT | Update visit status |

## Super Admin

All require `SUPER_ADMIN` role.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/dashboard` | Platform KPIs |
| GET | `/admin/agents` | List agents |
| PATCH | `/admin/agents/{id}/approve` | Verify agent |
| PATCH | `/admin/agents/{id}/suspend` | Suspend agent |
| PATCH | `/admin/agents/{id}/reinstate` | Reinstate agent |
| GET | `/admin/properties/pending` | Approval queue |
| PATCH | `/admin/properties/{id}/approve` | Approve listing |
| PATCH | `/admin/properties/{id}/reject?reason=` | Reject listing |
| GET | `/admin/subscriptions` | All subscriptions |
| DELETE | `/admin/subscriptions/{id}` | Cancel subscription |
| GET | `/admin/users/buyers` | All buyer accounts |
| PATCH | `/admin/users/{id}/suspend` | Suspend user |
| PATCH | `/admin/users/{id}/reinstate` | Reinstate user |
| GET | `/admin/revenue` | MRR breakdown |
| GET | `/admin/plans` | Subscription plans |
| PUT | `/admin/plans/{id}` | Update plan |
