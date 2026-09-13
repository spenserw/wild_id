namespace :plants do
  desc "Destroy all Plant::Species and Plant::Family records"
  task cleanup: :environment do
    # TODO: cleanup taxa
  end

  desc "Import US plant orders from the us_taxa artifact"
  task import_us_plant_orders: :environment do
    Datasets::Plants::Dataset.import_plant_orders(
      Datasets::Plants::Dataset.artifact_path(Datasets::Plants::Dataset::US_TAXA_ARTIFACT)
    )
  end

  desc "Import US plant families from the us_taxa artifact"
  task import_us_plant_families: :environment do
    Datasets::Plants::Dataset.import_plant_families(
      Datasets::Plants::Dataset.artifact_path(Datasets::Plants::Dataset::US_TAXA_ARTIFACT)
    )
  end

  desc "Import US plant genuses from the us_taxa artifact"
  task import_us_plant_genuses: :environment do
    Datasets::Plants::Dataset.import_plant_genuses(
      Datasets::Plants::Dataset.artifact_path(Datasets::Plants::Dataset::US_TAXA_ARTIFACT)
    )
  end

  desc "Import US plant species from the us_taxa artifact"
  task import_us_plant_species: :environment do
    Datasets::Plants::Dataset.import_plant_species(
      Datasets::Plants::Dataset.artifact_path(Datasets::Plants::Dataset::US_TAXA_ARTIFACT)
    )
  end

  namespace :artifacts do
    task us_taxa: :environment do
      raw_data_dir = Datasets::Plants::Dataset.scrape_data_dir

      taxonomy_data = {
        orders: {},
        count: 0,
        total_species_count: 0
      }

      Dir.each_child(raw_data_dir) do |entry_name|
        profile_path = "#{raw_data_dir}/#{entry_name}/#{Datasets::Plants::Dataset::PROFILE_PATH}"
        profile = JSON.parse(File.read(profile_path)).with_indifferent_access

        next unless profile[:Rank] == "Species"

        sci_name = Datasets::Plants::Dataset.parse_scientific_name(profile[:ScientificName])

        ancestors = profile[:Ancestors]
        order = ancestors.find { |ancestor| ancestor[:Rank] == "Order" }
        next unless order.present? # TODO: some are missing order, e.g. THPE7

        order_name = Datasets::Plants::Dataset.parse_scientific_name(order[:ScientificName])

        family = ancestors.find { |ancestor| ancestor[:Rank] == "Family" }
        family_name = Datasets::Plants::Dataset.parse_scientific_name(family[:ScientificName])
        genus = ancestors.find { |ancestor| ancestor[:Rank] == "Genus" }
        genus_name = Datasets::Plants::Dataset.parse_scientific_name(genus[:ScientificName])

        taxonomy_data[:count] += 1 unless taxonomy_data[:orders][order_name].present?
        order_hash = taxonomy_data[:orders][order_name] ||= {
          families: {},
          count: 0
        }

        order_hash[:count] += 1 unless order_hash[:families][family_name].present?
        family_hash = order_hash[:families][family_name] ||= {
          genuses: {},
          count: 0
        }

        genus = sci_name.split(" ").first
        family_hash[:count] += 1 unless family_hash[:genuses][genus_name].present?
        genus_hash = family_hash[:genuses][genus_name] ||= {
          species: {},
          count: 0
        }

        genus_hash[:count] += 1
        genus_hash[:species][sci_name] = {
          scientific_name: sci_name,
          common_name: profile[:CommonName]
        }

        taxonomy_data[:total_species_count] += 1
      end

      Datasets::JsonWriter.write(
        "us_taxa",
        taxonomy_data,
        dest_dir: Datasets::Plants::Dataset.plants_data_dir
      )
    end
  end
end
