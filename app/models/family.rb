# == Schema Information
#
# Table name: families
# Database name: primary
#
#  id              :bigint           not null, primary key
#  common_names    :text             default([]), is an Array
#  scientific_name :text
#  type            :string
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
class Family < ApplicationRecord
  def href
    raise NotImplementedError
  end
end
