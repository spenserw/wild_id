# == Schema Information
#
# Table name: orders
# Database name: primary
#
#  id                 :bigint           not null, primary key
#  common_names       :text             default([]), is an Array
#  scientific_name    :text
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  taxonomic_class_id :bigint           not null
#
# Indexes
#
#  index_orders_on_taxonomic_class_id  (taxonomic_class_id)
#
# Foreign Keys
#
#  fk_rails_...  (taxonomic_class_id => taxonomic_classes.id)
#
module Bird
  class Order < ::Order
    def href
      "#{Bird::Constants::BIRDS_PATH}/#{::Constants::ORDER_PATH}"
    end
  end
end
