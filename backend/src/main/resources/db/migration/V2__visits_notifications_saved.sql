-- PropVault V2: visits, notifications, saved_properties, analytics

CREATE TABLE visit_requests (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id         UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    agent_id            UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
    buyer_user_id       UUID REFERENCES users(id),
    buyer_name          VARCHAR(100) NOT NULL,
    buyer_phone         VARCHAR(15)  NOT NULL,
    buyer_email         VARCHAR(150),
    preferred_date      DATE         NOT NULL,
    preferred_time_slot VARCHAR(30)  NOT NULL,
    confirmed_datetime  TIMESTAMPTZ,
    status              VARCHAR(20)  NOT NULL DEFAULT 'REQUESTED'
                            CHECK (status IN ('REQUESTED','CONFIRMED','CANCELLED','COMPLETED','NO_SHOW')),
    agent_notes         TEXT,
    buyer_notes         TEXT,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_visit_agent    ON visit_requests(agent_id);
CREATE INDEX idx_visit_property ON visit_requests(property_id);
CREATE INDEX idx_visit_status   ON visit_requests(status);
CREATE INDEX idx_visit_date     ON visit_requests(preferred_date);

CREATE TABLE notifications (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type        VARCHAR(40)  NOT NULL,
    title       VARCHAR(200) NOT NULL,
    body        TEXT         NOT NULL,
    data        JSONB,
    read        BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_notif_user   ON notifications(user_id);
CREATE INDEX idx_notif_unread ON notifications(user_id, read) WHERE read = FALSE;

CREATE TABLE saved_properties (
    buyer_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    property_id   UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (buyer_user_id, property_id)
);

ALTER TABLE agents
    ADD COLUMN IF NOT EXISTS tagline           VARCHAR(200),
    ADD COLUMN IF NOT EXISTS years_experience  SMALLINT,
    ADD COLUMN IF NOT EXISTS specializations   TEXT,
    ADD COLUMN IF NOT EXISTS languages         TEXT,
    ADD COLUMN IF NOT EXISTS facebook_url      VARCHAR(300),
    ADD COLUMN IF NOT EXISTS linkedin_url      VARCHAR(300),
    ADD COLUMN IF NOT EXISTS instagram_url     VARCHAR(300),
    ADD COLUMN IF NOT EXISTS profile_views     BIGINT DEFAULT 0;

ALTER TABLE properties
    ADD COLUMN IF NOT EXISTS whatsapp_count BIGINT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS call_count     BIGINT NOT NULL DEFAULT 0;

CREATE TABLE property_analytics_daily (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID  NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    date        DATE  NOT NULL,
    views       INT   NOT NULL DEFAULT 0,
    leads       INT   NOT NULL DEFAULT 0,
    whatsapp    INT   NOT NULL DEFAULT 0,
    calls       INT   NOT NULL DEFAULT 0,
    UNIQUE (property_id, date)
);
CREATE INDEX idx_analytics_prop_date ON property_analytics_daily(property_id, date DESC);

CREATE TRIGGER trg_visits_updated_at
    BEFORE UPDATE ON visit_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at();
