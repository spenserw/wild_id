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
#
class Family < ApplicationRecord
end
