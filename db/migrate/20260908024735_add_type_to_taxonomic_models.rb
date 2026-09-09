class AddTypeToTaxonomicModels < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :type, :string
    add_column :families, :type, :string
    add_column :genera, :type, :string
    add_column :species, :type, :string
  end
end
