require "test_helper"

# == Schema Information
#
# Table name: orders
# Database name: primary
#
#  id                 :bigint           not null, primary key
#  common_names       :text             default([]), is an Array
#  scientific_name    :text
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
class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
