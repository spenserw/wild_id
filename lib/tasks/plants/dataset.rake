namespace :plants do
  desc "Destroy all Plant::Species and Plant::Family records"
  task cleanup: :environment do
    Plant::Species.delete_all
    Plant::Genus.delete_all
    Plant::Family.delete_all
    Plant::Order.delete_all
  end

  desc "Import US plant classes from the us_taxa artifact"
  task import_us_plant_classes: :environment do
    Datasets::Plants::Dataset.import_plant_classes(
      Datasets::Plants::Dataset.artifact_path(Datasets::Plants::Dataset::US_TAXA_ARTIFACT)
    )
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
  task import_us_plant_genera: :environment do
    Datasets::Plants::Dataset.import_plant_genera(
      Datasets::Plants::Dataset.artifact_path(Datasets::Plants::Dataset::US_TAXA_ARTIFACT)
    )
  end

  desc "Import US plant species from the us_taxa artifact"
  task import_us_plant_species: :environment do
    Datasets::Plants::Dataset.import_plant_species(
      Datasets::Plants::Dataset.artifact_path(Datasets::Plants::Dataset::US_TAXA_ARTIFACT)
    )
  end

  # TODO: Fungi

  namespace :artifacts do
    task us_taxa: :environment do
      raw_data_dir = Datasets::Plants::Dataset.scrape_data_dir

      taxonomy_data = {
        classes: {},
        count: 0
      }

      Dir.each_child(raw_data_dir) do |entry_name|
        profile_path = "#{raw_data_dir}/#{entry_name}/#{Datasets::Plants::Dataset::PROFILE_PATH}"
        profile = JSON.parse(File.read(profile_path)).with_indifferent_access

        next unless Datasets::Plants::Dataset.plantae_child?(profile)

        puts "Building: #{entry_name}..."

        Datasets::Plants::Dataset.walk_ranks_to_taxon(taxonomy_data, profile) do
          {
            scientific_name: Datasets::Plants::Dataset.parse_scientific_name(profile[:ScientificName]),
            symbol: profile[:Symbol],
            common_names: [ profile[:CommonName] || "" ]
          }
        end
      end

      Datasets::JsonWriter.write(
        "us_taxa",
        taxonomy_data,
        dest_dir: Datasets::Plants::Dataset.plants_data_dir
      )
    end
  end
end
