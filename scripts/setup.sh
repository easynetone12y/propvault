#!/usr/bin/env bash
# PropVault — Full local setup script
# Run from the repo root: bash scripts/setup.sh
set -e

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║     PropVault — Local Setup           ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# ─── Check prerequisites ─────────────────────────────────────────
command -v java   >/dev/null 2>&1 || { echo "❌ Java 17+ required. Install from https://adoptium.net"; exit 1; }
command -v mvn    >/dev/null 2>&1 || { echo "❌ Maven 3.8+ required."; exit 1; }
command -v node   >/dev/null 2>&1 || { echo "❌ Node 20+ required."; exit 1; }
command -v psql   >/dev/null 2>&1 || { echo "❌ PostgreSQL required."; exit 1; }

echo "✅ Prerequisites OK"
echo ""

# ─── Backend env ─────────────────────────────────────────────────
if [ ! -f backend/.env ]; then
  cp backend/.env.example backend/.env
  echo "📄 Created backend/.env from .env.example"
  echo "   ⚠️  Edit backend/.env and add your secrets before running."
fi

# ─── Frontend env ────────────────────────────────────────────────
if [ ! -f frontend/.env.local ]; then
  cp frontend/.env.example frontend/.env.local
  echo "📄 Created frontend/.env.local from .env.example"
fi

# ─── Database ────────────────────────────────────────────────────
echo ""
echo "Creating PostgreSQL database..."
psql -U postgres -c "CREATE DATABASE propvault_db;" 2>/dev/null || echo "   ℹ️  Database already exists."
psql -U postgres -d propvault_db -f scripts/init-db.sql 2>/dev/null || true

# ─── Frontend dependencies ───────────────────────────────────────
echo ""
echo "Installing frontend dependencies..."
cd frontend && npm install && cd ..

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║  Setup complete! Start the app:       ║"
echo "║                                       ║"
echo "║  Backend:  cd backend                 ║"
echo "║            mvn spring-boot:run        ║"
echo "║                                       ║"
echo "║  Frontend: cd frontend                ║"
echo "║            npm run dev                ║"
echo "║                                       ║"
echo "║  Open:     http://localhost:5173      ║"
echo "╚═══════════════════════════════════════╝"
