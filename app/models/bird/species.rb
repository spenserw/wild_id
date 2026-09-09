# == Schema Information
#
# Table name: species
# Database name: primary
#
#  id              :bigint           not null, primary key
#  common_names    :text             default([]), is an Array
#  scientific_name :text
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  external_id     :text
#  genus_id        :bigint           not null
#
# Indexes
#
#  index_species_on_genus_id  (genus_id)
#
# Foreign Keys
#
#  fk_rails_...  (genus_id => genera.id)
#
module Bird
  class Species < ::Species
    belongs_to :genus,
      class_name: "Bird::Genus",
      inverse_of: :species

    has_one :family, through: :genus

    def href
      "#{Bird::Constants::BIRDS_PATH}/#{::Constants::SPECIES_PATH}"
    end
  end
end
