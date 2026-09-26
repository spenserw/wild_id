module Datasets
  class Dataset
    RANKS = [
      ::TaxonomicClass,
      ::Order,
      ::Family,
      ::Genus,
      ::Species
    ].freeze

    class << self
      def import_taxa(taxa_path, rank, start_rank: RANKS.first, &block)
        base_class = rank.base_class
        puts "Importing #{base_class.to_plural_sym} from #{taxa_path}..."
        taxa = load_taxa_dump(taxa_path)

        rank.transaction do
          each_of_rank(taxa, base_class, start_rank: start_rank) do |scientific_name, data, parent|
            puts "Importing #{base_class.to_sym} [#{scientific_name}]..."

            rank.find_or_create_by!(scientific_name: scientific_name) do |record|
              yield record, data, parent
            end
          end
        end
      end

      def each_of_rank(taxa, rank, start_rank: RANKS.first)
        each_of_child_rank(taxa, start_rank.to_plural_sym, target_rank: rank.to_plural_sym) do |sci_name, data, parent|
          yield sci_name, data, parent
        end
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

      private

      def load_taxa_dump(path)
        JSON.parse(File.read(path)).with_indifferent_access
      end
    end
  end
end
