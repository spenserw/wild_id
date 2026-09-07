# == Schema Information
#
# Table name: families
# Database name: primary
#
#  id              :bigint           not null, primary key
#  common_names    :text             default([]), is an Array
#  scientific_name :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  external_id     :text
#  order_id        :bigint
#
# Indexes
#
#  index_families_on_order_id  (order_id)
#
# Foreign Keys
#
#  fk_rails_...  (order_id => orders.id)
#
module Bird
  class Family < ::Family
    belongs_to :order,
      class_name: "Bird::Order"

    has_many :genuses,
      class_name: "Bird::Genus",
      inverse_of: :family

    has_many :species, through: :genuses
  end
end
