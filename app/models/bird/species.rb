# == Schema Information
#
# Table name: bird_species
# Database name: primary
#
#  id              :bigint           not null, primary key
#  common_names    :string           is an Array
#  scientific_name :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  bird_family_id  :bigint           not null
#  external_id     :integer
#
# Indexes
#
#  index_bird_species_on_bird_family_id  (bird_family_id)
#
# Foreign Keys
#
#  fk_rails_...  (bird_family_id => bird_families.id)
#
module Bird
  class Species < ApplicationRecord
    self.table_name = "bird_species"

    belongs_to :bird_family,
      class_name: "Bird::Family",
      inverse_of: :species
  end
end
