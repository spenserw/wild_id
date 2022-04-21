class CreateBirdSpecies < ActiveRecord::Migration[7.0]
  def change
    create_table :bird_species do |t|
      t.string :scientific_name
      t.string :common_names, array: true

      t.timestamps
    end
  end
end
