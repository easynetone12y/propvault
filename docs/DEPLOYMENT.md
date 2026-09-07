# PropVault — Deployment Guide

## Option 1: Docker Compose (recommended for staging)

```bash
# 1. Clone the repo
git clone https://github.com/gajendra-73/propvault.git
cd propvault

# 2. Set environment variables
cp backend/.env.example backend/.env
# Edit backend/.env with your secrets

# 3. Start all services
docker-compose up -d

# 4. Check health
curl http://localhost:8080/api/v1/actuator/health
# → {"status":"UP"}

# Open: http://localhost:5173
```

## Option 2: Manual (local development)

```bash
# PostgreSQL
psql -U postgres -c "CREATE DATABASE propvault_db;"
bash scripts/setup.sh

# Terminal 1 — Backend
cd backend
mvn spring-boot:run

# Terminal 2 — Frontend
cd frontend
npm run dev
```

## Option 3: Cloud Deployment

### Backend → Railway / Render / EC2
1. Add all environment variables from `backend/.env.example`
2. Set `PORT=8080`
3. Deploy via Docker or Git push

### Frontend → Vercel / Netlify
1. Connect GitHub repo, set `Root Directory: frontend`
2. Build command: `npm run build`
3. Output directory: `dist`
4. Set `VITE_API_BASE_URL` to your backend URL

### Database → Supabase / Neon / RDS
1. Create a PostgreSQL 15 database
2. Update `DB_*` environment variables
3. Flyway will run migrations on startup

## GitHub Secrets (for CI/CD)
Add these in **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub token |
| `DB_PASSWORD` | Production DB password |
| `JWT_SECRET` | JWT signing key |
| `AWS_ACCESS_KEY` | AWS access key |
| `AWS_SECRET_KEY` | AWS secret key |
| `RAZORPAY_KEY_ID` | Razorpay key ID |
| `RAZORPAY_KEY_SECRET` | Razorpay key secret |
