class CreateTaxonomicClasses < ActiveRecord::Migration[8.1]
  def change
    create_table :taxonomic_classes do |t|
      t.text :scientific_name
      t.text :common_names, array: true, default: []

      t.timestamps
    end
  end
end
