module Datasets
  module Plants
    class Dataset
      PROFILE_PATH = "profile.json".freeze
      US_TAXA_ARTIFACT = "us_taxa".freeze

      class << self
        def plants_data_dir
          Rails.root.join("data", "plants")
        end

        def artifact_path(name)
          plants_data_dir.join("#{name}.json")
        end

        def scrape_data_dir
          plants_data_dir.join("raw")
        end

        def parse_scientific_name(scientific_name)
          scientific_name.match(/<i>([^<]+)/)[1]
        end

        def build_species_taxon(plants_profile, taxa_data)
        end

        def import_plant_orders(taxa_path)
          puts "Importing plant orders from #{taxa_path}..."
          taxa = load_taxa_dump(taxa_path)

          # TODO: iron out higher-order taxonomic classifications from plants, e.g. class, kingdom, etc.
          Plant::Order.transaction do
            taxa[:orders].each do |order_scientific_name, order|
              puts "Importing order [#{order_scientific_name}]..."
              Plant::Order.find_or_create_by!(scientific_name: order_scientific_name) do |o|
                o.type = Plant::Order
              end
            end
          end
        end

        def import_plant_families(taxa_path)
          puts "Importing plant famlilies from #{taxa_path}..."
          taxa = load_taxa_dump(taxa_path)

          Plant::Family.transaction do
            taxa[:orders].each do |order_scientific_name, order_hash|
              order = Plant::Order.find_by(scientific_name: order_scientific_name)
              order_hash[:families].each do |scientific_name, metadata|
                puts "Importing family [#{scientific_name}]..."
                Plant::Family.find_or_create_by!(scientific_name: scientific_name) do |f|
                  f.type = Plant::Family
                  f.order = order
                  # s.external_id = external_taxon.sisrecid # TODO: symbol
                  # f.common_names = [ metadata[:common_name] ]
                end
              end
            end
          end
        end

        def import_plant_genuses(taxa_path)
          puts "Importing plant genuses from #{taxa_path}..."
          taxa = load_taxa_dump(taxa_path)

          Plant::Genus.transaction do
            taxa[:orders].each do |_, order_hash|
              order_hash[:families].each do |family_scientific_name, family_hash|
                family = Plant::Family.find_by(scientific_name: family_scientific_name)
                family_hash[:genuses].each do |genus_scientific_name, genus_hash|
                  puts "Importing genus [#{genus_scientific_name}]..."
                  Plant::Genus.find_or_create_by!(scientific_name: genus_scientific_name) do |g|
                    g.type = Plant::Genus
                    # s.external_id = external_taxon.sisrecid # TODO: symbol
                    g.family = family
                  end
                end
              end
            end
          end
        end

        def import_plant_species(taxa_path)
          puts "Importing plant species from #{taxa_path}..."
          taxa = load_taxa_dump(taxa_path)

          Plant::Species.transaction do
            taxa[:orders].each do |_, order_hash|
              order_hash[:families].each do |family_scientific_name, family_hash|
                family_hash[:genuses].each do |genus_scientific_name, genus_hash|
                  genus = Plant::Genus.find_by(scientific_name: genus_scientific_name)

                  genus_hash[:species].each do |species_scientific_name, species_hash|
                    puts "Importing species [#{species_scientific_name}]..."

                    Plant::Species.find_or_create_by!(scientific_name: species_scientific_name) do |s|
                      s.type = Plant::Species
                      # s.external_id = external_taxon.sisrecid # TODO: symbol
                      s.common_names = [ species_hash[:common_name] ]
                      s.genus = genus
                    end
                  end
                end
              end
            end
          end
        end

        private

        def load_taxa_dump(path)
          JSON.parse(File.read(path)).with_indifferent_access
        end
      end
    end
  end
end
