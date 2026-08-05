-- Extra databases for Solid Cache / Queue / Cable.
-- Runs once on first Postgres container init (empty data volume).
CREATE DATABASE wild_id_production_cache OWNER wild_id;
CREATE DATABASE wild_id_production_queue OWNER wild_id;
CREATE DATABASE wild_id_production_cable OWNER wild_id;
