module Datasets
  class Plants < Dataset
    PROFILE_PATH = "profile.json".freeze
    US_PLANTS_TAXA_ARTIFACT = "us_plants_taxa".freeze
    US_FUNGI_TAXA_ARTIFACT = "us_fungi_taxa".freeze

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

      def plant?(profile)
        root_ancestor = profile[:Ancestors]&.first
        return false if root_ancestor.nil?

        root_ancestor[:Symbol] == "Plantae"
      end

      def fungi?(profile)
        root_ancestor = profile[:Ancestors]&.first
        return false if root_ancestor.nil?

        root_ancestor[:Symbol] == "Fungi"
      end

      # Builds the +lineage+ argument for Dataset.walk_ranks_to_taxon from a
      # scraped USDA profile. Returns nil when the profile has no usable rank.
      def lineage_for(profile)
        raw_rank = profile[:Rank]&.downcase&.to_sym
        return if raw_rank.nil? # TODO: why are there bad items? possible bad scrape? e.g. COLUM3

        ranks = Datasets::Dataset::RANKS
        lineage = ranks.each_with_object([]) do |rank, nodes|
          if raw_rank == rank.to_plural_sym
            nodes << {
              rank: rank,
              scientific_name: parse_scientific_name(profile[:ScientificName]),
              target: true
            }
            break nodes
          end

          ancestor = profile[:Ancestors].find { |summary| summary[:Rank] == rank.rank_name }
          break nodes if ancestor.nil?

          nodes << {
            rank: rank,
            scientific_name: parse_scientific_name(ancestor[:ScientificName]),
            stub: stub_ancestor(ancestor)
          }
        end

        lineage.presence
      end

      def stub_ancestor(summary)
        sci_name = parse_scientific_name(summary[:ScientificName])

        {
          scientific_name: sci_name,
          symbol: summary[:Symbol],
          common_names: [ summary[:CommonName] || "" ]
        }
      end
    end
  end
end
