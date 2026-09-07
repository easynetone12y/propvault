-- ============================================================
-- PropVault – PostgreSQL Schema  (Flyway V1)
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";   -- trigram search

-- ── Users ────────────────────────────────────────────────────
CREATE TABLE users (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name             VARCHAR(100)  NOT NULL,
    email            VARCHAR(150)  NOT NULL UNIQUE,
    password_hash    VARCHAR(255)  NOT NULL,
    phone            VARCHAR(15)   UNIQUE,
    role             VARCHAR(20)   NOT NULL CHECK (role IN ('SUPER_ADMIN','AGENT','BUYER')),
    email_verified   BOOLEAN       NOT NULL DEFAULT FALSE,
    active           BOOLEAN       NOT NULL DEFAULT TRUE,
    profile_image_url VARCHAR(500),
    fcm_token        VARCHAR(300),
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email  ON users(email);
CREATE INDEX idx_users_role   ON users(role);
CREATE INDEX idx_users_active ON users(active);

-- ── Agents ───────────────────────────────────────────────────
CREATE TABLE agents (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID  NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    company_name  VARCHAR(200) NOT NULL,
    license_no    VARCHAR(100),
    rera_no       VARCHAR(100),
    description   TEXT,
    website       VARCHAR(300),
    logo_url      VARCHAR(500),
    city          VARCHAR(100),
    state         VARCHAR(100),
    verified      BOOLEAN NOT NULL DEFAULT FALSE,
    featured      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_agents_user     ON agents(user_id);
CREATE INDEX idx_agents_verified ON agents(verified);
CREATE INDEX idx_agents_city     ON agents(LOWER(city));

-- ── Subscription Plans ────────────────────────────────────────
CREATE TABLE subscription_plans (
    id                        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                      VARCHAR(50)  NOT NULL UNIQUE,   -- BASIC, PRO, PREMIUM
    display_name              VARCHAR(100) NOT NULL,
    price_monthly             NUMERIC(10,2) NOT NULL,
    price_yearly              NUMERIC(10,2) NOT NULL,
    max_listings              INT          NOT NULL,           -- -1 = unlimited
    max_featured_listings     INT          DEFAULT 0,
    max_images                INT          DEFAULT 10,
    video_upload              BOOLEAN      DEFAULT FALSE,
    analytics_access          BOOLEAN      DEFAULT FALSE,
    priority_leads            BOOLEAN      DEFAULT FALSE,
    verified_badge            BOOLEAN      DEFAULT FALSE,
    ai_descriptions           BOOLEAN      DEFAULT FALSE,
    whatsapp_integration      BOOLEAN      DEFAULT FALSE,
    razorpay_plan_id_monthly  VARCHAR(100),
    razorpay_plan_id_yearly   VARCHAR(100),
    active                    BOOLEAN      NOT NULL DEFAULT TRUE,
    sort_order                INT          DEFAULT 0,
    CONSTRAINT chk_max_listings CHECK (max_listings >= -1)
);

-- Seed default plans
INSERT INTO subscription_plans
  (name, display_name, price_monthly, price_yearly, max_listings,
   max_featured_listings, max_images, video_upload, analytics_access,
   priority_leads, verified_badge, ai_descriptions, whatsapp_integration, sort_order)
VALUES
  ('BASIC',   'Basic',   999.00,  9990.00,  20,  0, 10, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,  1),
  ('PRO',     'Pro',    2999.00, 29990.00, 100,  5, 20, TRUE,  TRUE,  FALSE, FALSE, FALSE, TRUE,  2),
  ('PREMIUM', 'Premium',5999.00, 59990.00,  -1, -1, 30, TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  TRUE,  3);

-- ── Subscriptions ─────────────────────────────────────────────
CREATE TABLE subscriptions (
    id                       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id                 UUID  NOT NULL UNIQUE REFERENCES agents(id) ON DELETE CASCADE,
    plan_id                  UUID  NOT NULL REFERENCES subscription_plans(id),
    status                   VARCHAR(20) NOT NULL
                                CHECK (status IN ('TRIAL','ACTIVE','PAST_DUE','CANCELLED','EXPIRED')),
    razorpay_subscription_id VARCHAR(100) UNIQUE,
    razorpay_customer_id     VARCHAR(100),
    start_date               DATE,
    current_period_end       DATE,
    trial_end_date           DATE,
    auto_renew               BOOLEAN NOT NULL DEFAULT TRUE,
    yearly                   BOOLEAN NOT NULL DEFAULT FALSE,
    last_payment_amount      NUMERIC(10,2),
    last_payment_at          TIMESTAMPTZ,
    last_payment_id          VARCHAR(100),
    created_at               TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sub_agent  ON subscriptions(agent_id);
CREATE INDEX idx_sub_status ON subscriptions(status);
CREATE INDEX idx_sub_expiry ON subscriptions(current_period_end);

-- ── Properties ────────────────────────────────────────────────
CREATE TABLE properties (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id          UUID         NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
    title             VARCHAR(200) NOT NULL,
    description       TEXT,
    type              VARCHAR(30)  NOT NULL
                        CHECK (type IN ('APARTMENT','VILLA','PLOT','COMMERCIAL','INDEPENDENT_HOUSE','PENTHOUSE')),
    purpose           VARCHAR(10)  NOT NULL CHECK (purpose IN ('SALE','RENT','LEASE')),
    status            VARCHAR(20)  NOT NULL
                        CHECK (status IN ('DRAFT','PENDING_REVIEW','APPROVED','REJECTED','SOLD','RENTED','INACTIVE')),
    price             NUMERIC(15,2) NOT NULL,
    price_label       VARCHAR(50),
    address           VARCHAR(300),
    locality          VARCHAR(150),
    city              VARCHAR(100) NOT NULL,
    state             VARCHAR(100) NOT NULL,
    pincode           VARCHAR(10),
    latitude          DOUBLE PRECISION,
    longitude         DOUBLE PRECISION,
    bedrooms          SMALLINT,
    bathrooms         SMALLINT,
    floor             SMALLINT,
    total_floors      SMALLINT,
    area_sq_ft        NUMERIC(10,2),
    carpet_area_sq_ft NUMERIC(10,2),
    build_year        SMALLINT,
    furnishing_status VARCHAR(20),
    featured          BOOLEAN NOT NULL DEFAULT FALSE,
    featured_homepage BOOLEAN NOT NULL DEFAULT FALSE,
    virtual_tour_url  VARCHAR(500),
    view_count        BIGINT  NOT NULL DEFAULT 0,
    contact_count     BIGINT  NOT NULL DEFAULT 0,
    rejection_reason  TEXT,
    approved_at       TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_prop_agent    ON properties(agent_id);
CREATE INDEX idx_prop_status   ON properties(status);
CREATE INDEX idx_prop_city     ON properties(LOWER(city));
CREATE INDEX idx_prop_type     ON properties(type);
CREATE INDEX idx_prop_purpose  ON properties(purpose);
CREATE INDEX idx_prop_price    ON properties(price);
CREATE INDEX idx_prop_featured ON properties(featured) WHERE featured = TRUE;
CREATE INDEX idx_prop_beds     ON properties(bedrooms);
CREATE INDEX idx_prop_area     ON properties(area_sq_ft);

-- Full-text search index
ALTER TABLE properties ADD COLUMN fts_vector tsvector
  GENERATED ALWAYS AS (
    to_tsvector('english',
      coalesce(title,'') || ' ' ||
      coalesce(locality,'') || ' ' ||
      coalesce(city,'') || ' ' ||
      coalesce(description,''))
  ) STORED;
CREATE INDEX idx_prop_fts ON properties USING GIN(fts_vector);

-- Property amenities
CREATE TABLE property_amenities (
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    amenity     VARCHAR(100) NOT NULL,
    PRIMARY KEY (property_id, amenity)
);

-- ── Property Media ─────────────────────────────────────────────
CREATE TABLE property_media (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id     UUID         NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    media_type      VARCHAR(15)  NOT NULL CHECK (media_type IN ('IMAGE','VIDEO','VIRTUAL_TOUR','FLOOR_PLAN')),
    media_url       VARCHAR(500) NOT NULL,
    thumbnail_url   VARCHAR(500),
    s3_key          VARCHAR(300),
    file_size_bytes BIGINT,
    mime_type       VARCHAR(80),
    is_primary      BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order      INT     NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_media_property  ON property_media(property_id);
CREATE INDEX idx_media_primary   ON property_media(property_id, is_primary) WHERE is_primary = TRUE;

-- ── Leads ─────────────────────────────────────────────────────
CREATE TABLE leads (
    id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id          UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    agent_id             UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
    buyer_user_id        UUID REFERENCES users(id),
    customer_name        VARCHAR(100) NOT NULL,
    customer_phone       VARCHAR(15)  NOT NULL,
    customer_email       VARCHAR(150),
    status               VARCHAR(20)  NOT NULL
                           CHECK (status IN ('NEW','CONTACTED','FOLLOW_UP','VISIT_SCHEDULED','NEGOTIATION','CLOSED_WON','CLOSED_LOST')),
    message              TEXT,
    source               VARCHAR(20) DEFAULT 'FORM',
    notes                TEXT,
    follow_up_at         TIMESTAMPTZ,
    visit_scheduled_at   TIMESTAMPTZ,
    closed_at            TIMESTAMPTZ,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_lead_agent    ON leads(agent_id);
CREATE INDEX idx_lead_property ON leads(property_id);
CREATE INDEX idx_lead_status   ON leads(status);
CREATE INDEX idx_lead_created  ON leads(created_at);

-- ── Invoices ──────────────────────────────────────────────────
CREATE TABLE invoices (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id            UUID         NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
    subscription_id     UUID         NOT NULL REFERENCES subscriptions(id),
    invoice_number      VARCHAR(30)  NOT NULL UNIQUE,
    subtotal            NUMERIC(10,2) NOT NULL,
    gst_percent         NUMERIC(5,2)  NOT NULL DEFAULT 18.00,
    gst_amount          NUMERIC(10,2) NOT NULL,
    total_amount        NUMERIC(10,2) NOT NULL,
    razorpay_payment_id VARCHAR(100),
    razorpay_order_id   VARCHAR(100),
    status              VARCHAR(10) DEFAULT 'PAID',
    invoice_date        DATE,
    due_date            DATE,
    pdf_url             VARCHAR(500),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_invoice_agent  ON invoices(agent_id);
CREATE INDEX idx_invoice_number ON invoices(invoice_number);

-- ── Auto-update updated_at ─────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at        BEFORE UPDATE ON users        FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_agents_updated_at       BEFORE UPDATE ON agents       FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_subscriptions_updated_at BEFORE UPDATE ON subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_properties_updated_at   BEFORE UPDATE ON properties   FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_leads_updated_at        BEFORE UPDATE ON leads        FOR EACH ROW EXECUTE FUNCTION update_updated_at();
