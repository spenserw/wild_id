module Datasets
  module Plants
    class Dataset
      PROFILE_PATH = "profile.json".freeze
      US_TAXA_ARTIFACT = "us_taxa".freeze

      RANKS = [
        ::TaxonomicClass,
        ::Order,
        ::Family,
        ::Genus,
        ::Species
      ].freeze

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

        def walk_ranks_to_taxon(taxa, profile)
          target_rank = profile[:Rank]&.downcase&.to_sym
          return if target_rank.nil? # TODO: why are there bad items? possible bad scrape? e.g. COLUM3

          current_rank_hash = taxa[RANKS.first.to_plural_sym] # TODO: extract to_sym to TaxonomicRank baseclass
          RANKS.each_with_index do |rank, index|
            taxon = {}
            next_rank = RANKS[index + 1]
            next_rank_sym = next_rank.to_plural_sym
            taxon[next_rank_sym] = {} unless next_rank.nil?

            if target_rank == rank.to_plural_sym
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

        def each_of_child_rank(parent, current_rank, target_rank:, &block)
          index_of_rank = RANKS.find_index { |r| r.to_plural_sym == current_rank }

          parent[current_rank].each do |scientific_name, child_data|
            if current_rank == target_rank
              yield scientific_name, child_data, parent
            else
              next_rank_sym = RANKS[index_of_rank + 1].to_plural_sym
              each_of_child_rank(child_data.with_indifferent_access, next_rank_sym, target_rank: target_rank, &block)
            end
          end
        end

        def each_of_rank(taxa, rank)
          target_rank = rank.to_plural_sym
          each_of_child_rank(taxa, RANKS.first.to_plural_sym, target_rank: target_rank) do |sci_name, data, parent|
            yield sci_name, data, parent
          end
        end

        def import_plant_classes(taxa_path)
          puts "Importing plant classes from #{taxa_path}..."
          taxa = load_taxa_dump(taxa_path)

          ::TaxonomicClass.transaction do
            each_of_rank(taxa, ::TaxonomicClass) do |scientific_name, data, parent|
              puts "Importing class [#{scientific_name}]..."

              ::TaxonomicClass.find_or_create_by!(scientific_name: scientific_name) do |c|
                c.common_names = data[:common_names]
              end
            end
          end
        end

        def import_plant_orders(taxa_path)
          puts "Importing plant orders from #{taxa_path}..."
          taxa = load_taxa_dump(taxa_path)

          Plant::Order.transaction do
            each_of_rank(taxa, ::Order) do |scientific_name, data, parent|
              puts "Importing order [#{scientific_name}]..."

              Plant::Order.find_or_create_by!(scientific_name: scientific_name) do |o|
                o.type = Plant::Order
                o.common_names = data[:common_names]
                o.taxonomic_class = ::TaxonomicClass.find_by(scientific_name: parent[:scientific_name])
              end
            end
          end
        end

        def import_plant_families(taxa_path)
          puts "Importing plant famlilies from #{taxa_path}..."
          taxa = load_taxa_dump(taxa_path)

          Plant::Family.transaction do
            each_of_rank(taxa, ::Family) do |scientific_name, data, parent|
              puts "Importing family [#{scientific_name}]..."

              Plant::Family.find_or_create_by!(scientific_name: scientific_name) do |f|
                f.type = Plant::Family
                f.order = Plant::Order.find_by(scientific_name: parent[:scientific_name])
                f.external_id = data[:symbol]
                f.common_names = data[:common_names]
              end
            end
          end
        end

        def import_plant_genera(taxa_path)
          puts "Importing plant genera from #{taxa_path}..."
          taxa = load_taxa_dump(taxa_path)

          Plant::Genus.transaction do
            each_of_rank(taxa, ::Genus) do |scientific_name, data, parent|
              puts "Importing genus [#{scientific_name}]..."

              Plant::Genus.find_or_create_by!(scientific_name: scientific_name) do |g|
                g.type = Plant::Genus
                g.family = Plant::Family.find_by(scientific_name: parent[:scientific_name])
                g.common_names = data[:common_names]
                g.external_id = data[:symbol]
              end
            end
          end
        end

        def import_plant_species(taxa_path)
          puts "Importing plant species from #{taxa_path}..."
          taxa = load_taxa_dump(taxa_path)

          Plant::Species.transaction do
            each_of_rank(taxa, ::Species) do |scientific_name, data, parent|
              puts "Importing species [#{scientific_name}]..."

              Plant::Species.find_or_create_by!(scientific_name: scientific_name) do |s|
                s.type = Plant::Species
                s.external_id = data[:symbol]
                s.common_names = data[:common_names]
                s.genus = Plant::Genus.find_by(scientific_name: parent[:scientific_name])
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
