class CreateBirdSpeciesReferenceImages < ActiveRecord::Migration[7.0]
  def change
    create_table :bird_species_reference_images, id: :uuid do |t|
      t.json   :license
      t.string :author
      t.string :source_site
      t.string :source_url
      t.string :asset_url
    end
  end
end
