class BirdSpecies < ApplicationRecord
  def self.compose_minimal(species)
    resp = {}
    species.each_pair do |key, s|
      family = BirdFamily.find_by(id: s[:family_id])
      family_name = family.scientific_name
      resp[family_name] = {} if not resp[family_name]
      resp[family_name][s[:scientific_name]] = { seasons: s["seasons"] } if not resp[family_name][s[:scientific_name]]
    end

    return resp
  end
end
