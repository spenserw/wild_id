# == Schema Information
#
# Table name: species
# Database name: primary
#
#  id              :bigint           not null, primary key
#  common_names    :text             default([]), is an Array
#  scientific_name :text
#  search_vector   :tsvector
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  external_id     :text
#  genus_id        :bigint           not null
#
# Indexes
#
#  index_species_on_genus_id       (genus_id)
#  index_species_on_search_vector  (search_vector) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (genus_id => genera.id)
#
module Fungi
  class Species < ::Species
    belongs_to :genus,
      class_name: "Fungi::Genus",
      inverse_of: :species

    has_one :family, through: :genus

    def href
      "#{Fungi::Constants::FUNGI_PATH}/#{::Constants::SPECIES_PATH}"
    end
  end
end
