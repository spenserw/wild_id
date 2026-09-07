class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.text :scientific_name
      t.text :common_names, array: true, default: []
      t.references :taxonomic_class, null: false, foreign_key: true

      t.timestamps
    end
  end
end
