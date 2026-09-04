-- Extra databases for local development / test.
-- Runs once on first Postgres container init (empty data volume).
CREATE DATABASE wild_id_test OWNER wild_id;
CREATE DATABASE wild_id_development_queue OWNER wild_id;

-- Official postgis/postgis image also enables topology + tiger geocoder.
-- This app only needs core PostGIS (enabled via Rails migration).
\c wild_id_development
DROP EXTENSION IF EXISTS postgis_tiger_geocoder CASCADE;
DROP EXTENSION IF EXISTS postgis_topology CASCADE;
DROP EXTENSION IF EXISTS fuzzystrmatch CASCADE;
DROP SCHEMA IF EXISTS tiger CASCADE;
DROP SCHEMA IF EXISTS topology CASCADE;
