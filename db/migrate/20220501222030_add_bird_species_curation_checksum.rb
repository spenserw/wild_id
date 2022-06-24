class AddBirdSpeciesCurationChecksum < ActiveRecord::Migration[7.0]
  def change
    add_column :bird_species, :curation_checksum, 'char(32)', null: false
    add_column :bird_families, :curation_checksum, 'char(32)', null: false
  end
end
