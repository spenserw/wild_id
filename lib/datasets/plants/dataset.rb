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

        def walk_ranks_to_taxon(taxa_data, profile)
          ranks = [
            ::Order,
            ::Family,
            ::Genus,
            ::Species
          ]

          target_rank = profile[:Rank]&.downcase&.to_sym
          return if target_rank.nil? # TODO: why are there bad items? possible bad scrape? e.g. COLUM3

          current_rank_hash = taxa_data[ranks.first.to_s.pluralize.downcase.to_sym] # TODO: extract to_sym to TaxonomicRank baseclass
          ranks.each_with_index do |rank, index|
            taxon = {}
            next_rank = ranks[index + 1]
            next_rank_sym = next_rank.to_s.pluralize.downcase.to_sym # TODO: genus isn't pluralizing right
            taxon[next_rank_sym] = {} unless next_rank.nil?

            if target_rank == rank.to_s.downcase.to_sym
              sci_name = parse_scientific_name(profile[:ScientificName])

              current_rank_hash[sci_name] = taxon.merge(yield)
            else
              ancestor_summary = profile[:Ancestors].find { |ancestor| ancestor[:Rank] == rank.to_s }
              return unless ancestor_summary.present?

              ancestor_sci_name = parse_scientific_name(ancestor_summary[:ScientificName])
              current_rank_hash[ancestor_sci_name] ||= stub_ancestor(ancestor_summary).merge(taxon)

              current_rank_hash = current_rank_hash[ancestor_sci_name][next_rank_sym]
            end
          end
        end

        def stub_ancestor(summary)
          sci_name = parse_scientific_name(summary[:ScientificName])

          {
            scientific_name: sci_name,
            symbol: summary[:Symbol],
            common_names: [ summary[:CommonName] || "" ]
          }
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
                    s.external_id = genus_hash[:symbol]
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
