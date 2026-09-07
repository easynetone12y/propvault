# Security Policy — PropVault

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | ✅ Yes     |
| < 1.0   | ❌ No      |

## Reporting a Vulnerability

**Please do NOT open a public GitHub issue for security vulnerabilities.**

Report security issues privately to: **security@propvault.in**

Include in your report:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if you have one)

We will acknowledge receipt within **24 hours** and aim to release a patch
within **7 days** for critical issues.

## Security Practices

### Authentication
- Passwords hashed with BCrypt (strength 12)
- JWT tokens expire after 24 hours; refresh tokens after 7 days
- Refresh tokens are single-use
- Logout blacklists tokens in Redis with TTL matching remaining expiry

### API Security
- All endpoints behind Spring Security — role guards on every route
- Razorpay webhooks verified with HMAC-SHA256 signature
- Rate limiting on auth endpoints (recommended: add Spring Cloud Gateway)
- CORS restricted to known origins only

### Data
- Secrets loaded from environment variables — never hardcoded
- Database credentials not logged
- S3 files accessed via short-lived presigned URLs (1 hour TTL)
- PII fields (phone, email) not included in logs

### Infrastructure
- Docker images run as non-root user
- PostgreSQL accessible only within Docker network
- Redis not exposed publicly

## Responsible Disclosure

We follow responsible disclosure principles. Reporters who follow this policy
will be publicly credited (unless they prefer anonymity) once the issue
is resolved.
