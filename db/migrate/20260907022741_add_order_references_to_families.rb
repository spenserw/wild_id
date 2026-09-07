class AddOrderReferencesToFamilies < ActiveRecord::Migration[8.1]
  def change
    add_reference :families, :order, foreign_key: true
  end
end
