class AddSearchVectorToTaxonomicModels < ActiveRecord::Migration[8.1]
  def up
    add_column :orders, :search_vector, :tsvector
    add_column :families, :search_vector, :tsvector
    add_column :genera, :search_vector, :tsvector
    add_column :species, :search_vector, :tsvector

    add_index :orders, :search_vector, using: :gin
    add_index :families, :search_vector, using: :gin
    add_index :genera, :search_vector, using: :gin
    add_index :species, :search_vector, using: :gin

    execute <<~SQL
      CREATE FUNCTION taxonomic_search_vector_update() RETURNS trigger AS $$
      BEGIN
        NEW.search_vector :=
          to_tsvector('simple', coalesce(NEW.scientific_name, '') || ' ' || coalesce(array_to_string(NEW.common_names, ' '), ''));
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    %w[orders families genera species].each do |table|
      execute <<~SQL
        CREATE TRIGGER #{table}_search_vector_update
        BEFORE INSERT OR UPDATE ON #{table}
        FOR EACH ROW EXECUTE FUNCTION taxonomic_search_vector_update();
      SQL

      execute <<~SQL
        UPDATE #{table} SET search_vector =
          to_tsvector('simple', coalesce(scientific_name, '') || ' ' || coalesce(array_to_string(common_names, ' '), ''));
      SQL
    end
  end

  def down
    %w[orders families genera species].each do |table|
      execute "DROP TRIGGER IF EXISTS #{table}_search_vector_update ON #{table};"
    end

    execute "DROP FUNCTION IF EXISTS taxonomic_search_vector_update();"

    remove_column :orders, :search_vector
    remove_column :families, :search_vector
    remove_column :genera, :search_vector
    remove_column :species, :search_vector
  end
end
