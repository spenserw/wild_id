-- Extra databases for local development / test.
-- Runs once on first Postgres container init (empty data volume).
CREATE DATABASE wild_id_test OWNER wild_id;
CREATE DATABASE wild_id_development_queue OWNER wild_id;
