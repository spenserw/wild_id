# == Schema Information
#
# Table name: families
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
#  order_id        :bigint
#
# Indexes
#
#  index_families_on_order_id       (order_id)
#  index_families_on_search_vector  (search_vector) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#
module Plant
  class Family < ::Family
    belongs_to :order,
      class_name: "Plant::Order"

    has_many :genera,
      class_name: "Plant::Genus",
      inverse_of: :family

    has_many :species, through: :genera

    def href
      "#{Plant::Constants::PLANTS_PATH}/#{::Constants::FAMILY_PATH}"
    end
  end
end
