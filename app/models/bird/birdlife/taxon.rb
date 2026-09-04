# == Schema Information
#
# Table name: birdlife_taxonomy
# Database name: primary
#
#  alternativecommonnames :string(255)
#  authority              :string(255)
#  birdlifetaxonomy       :string(255)
#  commonname             :string(255)
#  family                 :string(255)
#  familyname             :string(255)
#  objectid               :integer          not null, primary key
#  order_                 :string(255)
#  redlistcategory_2020   :string(255)
#  scientificname         :string(255)
#  sequence               :float
#  sisrecid               :float
#  subfamily              :string(255)
#  synonyms               :string(255)
#  taxonomicnotes         :string(255)
#  taxonomicsource        :binary
#  tribe                  :string(255)
#
module Bird
  module BirdLife
    class Taxon < ApplicationRecord
      self.table_name = "birdlife_taxonomy"
    end
  end
end
