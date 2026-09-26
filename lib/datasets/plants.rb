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

      def walk_ranks_to_taxon(taxa, profile)
        target_rank = profile[:Rank]&.downcase&.to_sym
        return if target_rank.nil? # TODO: why are there bad items? possible bad scrape? e.g. COLUM3

        ranks = Datasets::Dataset::RANKS
        current_rank_hash = taxa[ranks.first.to_plural_sym]
        ranks.each_with_index do |rank, index|
          taxon = {}
          next_rank = ranks[index + 1]
          next_rank_sym = next_rank&.to_plural_sym
          taxon[next_rank_sym] = {} unless next_rank.nil?

          if target_rank == rank.to_plural_sym
            sci_name = parse_scientific_name(profile[:ScientificName])

            current_rank_hash[sci_name] = taxon.merge(yield)
          else
            ancestor_summary = profile[:Ancestors].find { |ancestor| ancestor[:Rank] == rank.rank_name }
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
    end
  end
end
