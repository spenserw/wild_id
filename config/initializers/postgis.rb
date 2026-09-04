# PostGIS maintains spatial_ref_sys; keep it out of schema.rb.
ActiveRecord::SchemaDumper.ignore_tables |= ["spatial_ref_sys"]
