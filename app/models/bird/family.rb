# == Schema Information
#
# Table name: bird_families
# Database name: primary
#
#  id              :bigint           not null, primary key
#  common_name     :string
#  count           :integer
#  scientific_name :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
module Bird
  class Family < ApplicationRecord
    self.table_name = "bird_families"

    has_many :species,
      class_name: "Bird::Species",
      foreign_key: :bird_family_id,
      inverse_of: :bird_family
  end
end
