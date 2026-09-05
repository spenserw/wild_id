class CreateGenus < ActiveRecord::Migration[8.1]
  def change
    create_table :genuses do |t|
      t.text :scientific_name
      t.text :common_names, array: true, default: []
      t.references :family, null: false, foreign_key: true
      t.text :external_id

      t.timestamps
    end
  end
end
