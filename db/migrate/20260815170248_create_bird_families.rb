class CreateBirdFamilies < ActiveRecord::Migration[8.1]
  def change
    create_table :bird_families do |t|
      t.string :scientific_name
      t.string :common_name
      t.integer :count

      t.timestamps
    end
  end
end
