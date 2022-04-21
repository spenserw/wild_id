class BirdSpeciesBelongsToBirdFamily < ActiveRecord::Migration[7.0]
  def change
    add_reference :bird_species, :bird_family, foreign_key: true
  end
end
