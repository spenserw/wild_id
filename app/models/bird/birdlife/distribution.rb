# == Schema Information
#
# Table name: birdlife_distributions
# Database name: primary
#
#  binomial     :string(50)
#  citation     :string(255)
#  compiler     :string(255)
#  dist_comm    :string(255)
#  objectid     :integer          not null, primary key
#  origin       :integer
#  presence     :integer
#  seasonal     :integer
#  shape        :geometry(MultiPo
#  shape_area   :float
#  shape_length :float
#  sisid        :integer
#  source       :string(255)
#  version      :string(255)
#  yrcompiled   :integer
#
# Indexes
#
#  birdlife_distributions_shape_geom_idx  (shape) USING gist
#
module Bird
  module BirdLife
    class Distribution < ApplicationRecord
      self.table_name = "birdlife_distributions".freeze

      def self.species_in_boundary(boundary)
        where("ST_Intersects(
          birdlife_distributions.shape,
          (SELECT geometry FROM us_boundary WHERE id = '#{boundary}')
          )
          AND origin in (1, 3)")
      end
    end
  end
end
