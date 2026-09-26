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
    taxa_path = Datasets::Plants.artifact_path(Datasets::Plants::US_PLANTS_TAXA_ARTIFACT)
    Datasets::Plants.import_taxa(taxa_path, ::TaxonomicClass) do |record, data|
      record.common_names = data[:common_names]
    end
  end

  desc "Import US plant orders from the us_taxa artifact"
  task import_us_plant_orders: :environment do
    taxa_path = Datasets::Plants.artifact_path(Datasets::Plants::US_PLANTS_TAXA_ARTIFACT)
    Datasets::Plants.import_taxa(taxa_path, Plant::Order) do |record, data, parent|
      record.type = Plant::Order
      record.common_names = data[:common_names]
      record.taxonomic_class = ::TaxonomicClass.find_by(scientific_name: parent[:scientific_name])
    end
  end

  desc "Import US plant families from the us_taxa artifact"
  task import_us_plant_families: :environment do
    taxa_path = Datasets::Plants.artifact_path(Datasets::Plants::US_PLANTS_TAXA_ARTIFACT)
    Datasets::Plants.import_taxa(taxa_path, Plant::Family) do |record, data, parent|
      record.type = Plant::Family
      record.external_id = data[:symbol]
      record.common_names = data[:common_names]
      record.order = Plant::Order.find_by(scientific_name: parent[:scientific_name])
    end
  end

  desc "Import US plant genuses from the us_taxa artifact"
  task import_us_plant_genera: :environment do
    taxa_path = Datasets::Plants.artifact_path(Datasets::Plants::US_PLANTS_TAXA_ARTIFACT)
    Datasets::Plants.import_taxa(taxa_path, Plant::Genus) do |record, data, parent|
      record.type = Plant::Genus
      record.external_id = data[:symbol]
      record.common_names = data[:common_names]
      record.family = Plant::Family.find_by(scientific_name: parent[:scientific_name])
    end
  end

  desc "Import US plant species from the us_taxa artifact"
  task import_us_plant_species: :environment do
    taxa_path = Datasets::Plants.artifact_path(Datasets::Plants::US_PLANTS_TAXA_ARTIFACT)
    Datasets::Plants.import_taxa(taxa_path, Plant::Species) do |record, data, parent|
      record.type = Plant::Species
      record.external_id = data[:symbol]
      record.common_names = data[:common_names]
      record.genus = Plant::Genus.find_by(scientific_name: parent[:scientific_name])
    end
  end

  desc "Cleanup, extract BirdLife data, build us_taxa, and load families/species"
  task import: [
    :cleanup,
    "artifacts:us_taxa",
    :import_us_plant_classes,
    :import_us_plant_orders,
    :import_us_plant_families,
    :import_us_plant_genera,
    :import_us_plant_species
  ]

  # TODO: Import lichens
  #
  # desc "Import US fungi classes"
  # task import_us_fungi_classes: :environment do
  # end
  #
  # desc "Import US fungi orders"
  # task import_us_plant_orders: :environment do
  # end
  #
  # desc "Import US fungi families"
  # task import_us_plant_families: :environment do
  # end
  #
  # desc "Import US fungi genuses"
  # task import_us_plant_genera: :environment do
  # end
  #
  # desc "Import US fungi species"
  # task import_us_plant_species: :environment do
  # end

  namespace :artifacts do
    task us_taxa: :environment do
      raw_data_dir = Datasets::Plants.scrape_data_dir

      plants_taxonomy_data = {
        classes: {}
      }

      fungi_taxonomy_data = {
        classes: {}
      }

      Dir.each_child(raw_data_dir) do |entry_name|
        profile_path = "#{raw_data_dir}/#{entry_name}/#{Datasets::Plants::PROFILE_PATH}"
        profile = JSON.parse(File.read(profile_path)).with_indifferent_access

        taxonomy_data = nil
        taxonomy_type = nil
        if Datasets::Plants.plant?(profile)
          taxonomy_data = plants_taxonomy_data
          taxonomy_type = "plant"
        elsif Datasets::Plants.fungi?(profile)
          taxonomy_data = fungi_taxonomy_data
          taxonomy_type = "fungi"
        end

        next if taxonomy_data.nil?

        puts "Building #{taxonomy_type} #{entry_name}..."

        Datasets::Plants.walk_ranks_to_taxon(taxonomy_data, profile) do
          {
            scientific_name: Datasets::Plants.parse_scientific_name(profile[:ScientificName]),
            symbol: profile[:Symbol],
            common_names: [ profile[:CommonName] || "" ].concat(profile[:OtherCommonNames])
          }
        end
      end

      Datasets::JsonWriter.write(
        Datasets::Plants::US_PLANTS_TAXA_ARTIFACT,
        plants_taxonomy_data,
        dest_dir: Datasets::Plants.plants_data_dir
      )

      Datasets::JsonWriter.write(
        Datasets::Plants::US_FUNGI_TAXA_ARTIFACT,
        fungi_taxonomy_data,
        dest_dir: Datasets::Plants.plants_data_dir
      )
    end
  end
end
