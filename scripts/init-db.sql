-- PropVault — Database initialisation
-- This script runs once on fresh PostgreSQL container startup.
-- Flyway migrations handle the actual schema.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";     -- for ILIKE performance
CREATE EXTENSION IF NOT EXISTS "unaccent";    -- for accent-insensitive search

-- Confirm extensions
SELECT extname, extversion FROM pg_extension
WHERE extname IN ('uuid-ossp', 'pg_trgm', 'unaccent');
