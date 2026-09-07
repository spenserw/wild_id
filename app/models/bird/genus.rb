# == Schema Information
#
# Table name: genuses
# Database name: primary
#
#  id              :bigint           not null, primary key
#  common_names    :text             default([]), is an Array
#  scientific_name :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  external_id     :text
#  family_id       :bigint           not null
#
# Indexes
#
#  index_genuses_on_family_id  (family_id)
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#
module Bird
  class Genus < ::Genus
    belongs_to :family,
      class_name: "Bird::Family",
      inverse_of: :genuses

    has_many :species,
      class_name: "Bird::Species",
      inverse_of: :genus
  end
end
