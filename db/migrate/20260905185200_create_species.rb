class CreateSpecies < ActiveRecord::Migration[8.1]
  def change
    create_table :species do |t|
      t.text :scientific_name
      t.text :common_names, array: true, default: []
      t.references :genus, null: false, foreign_key: true
      t.text :external_id

      t.timestamps
    end
  end
end
