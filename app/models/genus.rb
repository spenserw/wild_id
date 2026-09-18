# == Schema Information
#
# Table name: genera
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
#  family_id       :bigint           not null
#
# Indexes
#
#  index_genera_on_family_id      (family_id)
#  index_genera_on_search_vector  (search_vector) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (family_id => families.id)
#
class Genus < ApplicationRecord
  self.table_name = "genera"

  include TaxonomicRank

  def href
    raise NotImplementedError
  end
end
