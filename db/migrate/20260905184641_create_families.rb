class CreateFamilies < ActiveRecord::Migration[8.1]
  def change
    create_table :families do |t|
      t.text :scientific_name
      t.text :common_names, array: true, default: []
      t.text :external_id

      t.timestamps
    end
  end
end
