class AddReferenceImagesToBirdSpecies < ActiveRecord::Migration[7.0]
  def change
    change_table :bird_species do |t|
      t.uuid :primary_reference_image_id
      t.uuid :gallery_reference_image_ids, array: true
    end
  end
end
