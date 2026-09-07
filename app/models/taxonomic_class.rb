# == Schema Information
#
# Table name: taxonomic_classes
# Database name: primary
#
#  id              :bigint           not null, primary key
#  common_names    :text             default([]), is an Array
#  scientific_name :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class TaxonomicClass < ApplicationRecord
end
