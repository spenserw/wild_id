class CreateBirdSpecies < ActiveRecord::Migration[8.1]
  def change
    create_table :bird_species do |t|
      t.integer :external_id
      t.string :scientific_name
      t.string :common_names, array: true
      t.references :bird_family, null: false, foreign_key: true

      t.timestamps
    end
  end
end
