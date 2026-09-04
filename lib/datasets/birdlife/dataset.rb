module Datasets
  module BirdLife
    class Dataset
      US_TAXA_ARTIFACT = "us_taxa".freeze

      def self.birdlife_data_dir
        Rails.root.join("data", "birdlife")
      end

      def self.artifact_path(name)
        birdlife_data_dir.join("#{name}.json")
      end

      def self.load_bird_families(taxa_path)
        puts "Importing bird families from #{taxa_path}..."
        taxa = load_taxa_dump(taxa_path)

        Bird::Family.transaction do
          taxa[:families].each do |scientific_name, metadata|
            Bird::Family.create!(
              scientific_name: scientific_name,
              common_name: metadata[:common_name],
              count: metadata[:count]
            )

            puts "Imported #{scientific_name}"
          end
        end
      end

      def self.load_bird_species(taxa_path)
        puts "Importing bird species from #{taxa_path}..."
        taxa = load_taxa_dump(taxa_path)

        Bird::Species.transaction do
          taxa[:families].each do |family_name, family_data|
            family_data[:species].each do |_, value|
              scientific_name = value[:scientific_name]
              puts "Importing species [#{scientific_name}]..."

              taxon = Bird::BirdLife::Taxon.find_by(scientificname: scientific_name)
              Bird::Species.create!(
                external_id: taxon.sisrecid,
                scientific_name: scientific_name,
                common_names: [ value[:common_name] ],
                bird_family: Bird::Family.find_by(scientific_name: family_name)
              )
            end
          end
        end
      end

      class << self
        private

        def load_taxa_dump(path)
          JSON.parse(File.read(path)).with_indifferent_access
        end
      end
    end
  end
end
