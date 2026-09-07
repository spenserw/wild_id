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

      def self.load_bird_orders(taxa_path)
        puts "Importing bird orders from #{taxa_path}..."
        taxa = load_taxa_dump(taxa_path)

        aves = TaxonomicClass.find_by(scientific_name: "Aves")
        Bird::Order.transaction do
          taxa[:orders].each do |order_scientific_name, order|
            puts "Importing order [#{order_scientific_name}]..."
            Bird::Order.find_or_create_by!(scientific_name: order_scientific_name) do |o|
              o.taxonomic_class = aves
            end
          end
        end
      end

      def self.load_bird_families(taxa_path)
        puts "Importing bird families from #{taxa_path}..."
        taxa = load_taxa_dump(taxa_path)

        Bird::Family.transaction do
          taxa[:orders].each do |order_scientific_name, order_hash|
            order = Bird::Order.find_by(scientific_name: order_scientific_name)
            order_hash[:families].each do |scientific_name, metadata|
              puts "Importing family [#{scientific_name}]..."
              Bird::Family.find_or_create_by!(scientific_name: scientific_name) do |f|
                f.order = order
                f.common_names = [ metadata[:common_name] ]
              end
            end
          end
        end
      end

      def self.load_bird_genuses(taxa_path)
        puts "Importing bird genuses from #{taxa_path}..."
        taxa = load_taxa_dump(taxa_path)

        Bird::Genus.transaction do
          taxa[:orders].each do |_, order_hash|
            order_hash[:families].each do |family_scientific_name, family_hash|
              family = Bird::Family.find_by(scientific_name: family_scientific_name)
              family_hash[:genuses].each do |genus_scientific_name, genus_hash|
                puts "Importing genus [#{genus_scientific_name}]..."
                Bird::Genus.find_or_create_by!(scientific_name: genus_scientific_name) do |g|
                  g.family = family
                end
              end
            end
          end
        end
      end

      def self.load_bird_species(taxa_path)
        puts "Importing bird species from #{taxa_path}..."
        taxa = load_taxa_dump(taxa_path)

        Bird::Species.transaction do
          taxa[:orders].each do |_, order_hash|
            order_hash[:families].each do |family_scientific_name, family_hash|
              family_hash[:genuses].each do |genus_scientific_name, genus_hash|
                genus = Bird::Genus.find_by(scientific_name: genus_scientific_name)

                genus_hash[:species].each do |species_scientific_name, species_hash|
                  puts "Importing species [#{species_scientific_name}]..."

                  external_taxon = Bird::BirdLife::Taxon.find_by(scientificname: species_scientific_name)
                  Bird::Species.find_or_create_by!(scientific_name: species_scientific_name) do |s|
                    s.external_id = external_taxon.sisrecid
                    s.common_names = [ species_hash[:common_name] ]
                    s.genus = genus
                  end
                end
              end
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
