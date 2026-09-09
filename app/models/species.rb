# == Schema Information
#
# Table name: species
# Database name: primary
#
#  id              :bigint           not null, primary key
#  common_names    :text             default([]), is an Array
#  scientific_name :text
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  external_id     :text
#  genus_id        :bigint           not null
#
# Indexes
#
#  index_species_on_genus_id  (genus_id)
#
# Foreign Keys
#
#  fk_rails_...  (genus_id => genera.id)
#
class Species < ApplicationRecord
  def href
    raise NotImplementedError
  end
end
