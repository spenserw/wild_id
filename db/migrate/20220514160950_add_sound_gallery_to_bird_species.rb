class AddSoundGalleryToBirdSpecies < ActiveRecord::Migration[7.0]
  def change
    add_column :bird_species, :sound_gallery, :string, array: true
  end
end
