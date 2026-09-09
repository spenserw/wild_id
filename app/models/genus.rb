# == Schema Information
#
# Table name: genera
# Database name: primary
#
#  id              :bigint           not null, primary key
#  common_names    :text             default([]), is an Array
#  scientific_name :text
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  external_id     :text
#  family_id       :bigint           not null
#
# Indexes
#
#  index_genera_on_family_id  (family_id)
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#
class Genus < ApplicationRecord
  self.table_name = "genera"

  def href
    raise NotImplementedError
  end
end
