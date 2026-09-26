namespace :birdlife do
  desc "Destroy all Bird::Species and Bird::Family records"
  task cleanup: :environment do
    Bird::Order.delete_all
    Bird::Family.delete_all
    Bird::Genus.delete_all
    Bird::Species.delete_all
  end

  desc "Import US bird orders from the us_taxa artifact"
  task import_us_bird_orders: :environment do
    taxa_path = Datasets::BirdLife.artifact_path(Datasets::BirdLife::US_TAXA_ARTIFACT)
    aves = TaxonomicClass.find_by(scientific_name: "Aves")

    Datasets::BirdLife.import_taxa(taxa_path, Bird::Order, start_rank: ::Order) do |record|
      record.type = Bird::Order
      record.taxonomic_class = aves
    end
  end

  desc "Import US bird families from the us_taxa artifact"
  task import_us_bird_families: :environment do
    taxa_path = Datasets::BirdLife.artifact_path(Datasets::BirdLife::US_TAXA_ARTIFACT)

    Datasets::BirdLife.import_taxa(taxa_path, Bird::Family, start_rank: ::Order) do |record, data, parent|
      record.type = Bird::Family
      record.order = Bird::Order.find_by(scientific_name: parent[:scientific_name])
      record.common_names = [ data[:common_name] ]
    end
  end

  desc "Import US bird genera from the us_taxa artifact"
  task import_us_bird_genera: :environment do
    taxa_path = Datasets::BirdLife.artifact_path(Datasets::BirdLife::US_TAXA_ARTIFACT)

    Datasets::BirdLife.import_taxa(taxa_path, Bird::Genus, start_rank: ::Order) do |record, _data, parent|
      record.type = Bird::Genus
      record.family = Bird::Family.find_by(scientific_name: parent[:scientific_name])
    end
  end

  desc "Import US bird species from the us_taxa artifact"
  task import_us_bird_species: :environment do
    taxa_path = Datasets::BirdLife.artifact_path(Datasets::BirdLife::US_TAXA_ARTIFACT)

    Datasets::BirdLife.import_taxa(taxa_path, Bird::Species, start_rank: ::Order) do |record, data, parent|
      external_taxon = Bird::BirdLife::Taxon.find_by(scientificname: record.scientific_name)

      record.type = Bird::Species
      record.external_id = external_taxon&.sisrecid
      record.common_names = [ data[:common_name] ]
      record.genus = Bird::Genus.find_by(scientific_name: parent[:scientific_name])
    end
  end

  desc "Cleanup, extract BirdLife data, build us_taxa, and load families/species"
  task import: [
    :cleanup,
    "artifacts:extract",
    "artifacts:us_taxa",
    :import_us_bird_orders,
    :import_us_bird_families,
    :import_us_bird_genera,
    :import_us_bird_species
  ]

  namespace :artifacts do
    desc "Extract BOTW archive and load taxonomy/distribution into Postgres"
    task extract: :environment do
      data_dir = Datasets::BirdLife.birdlife_data_dir
      esri_archive = data_dir.join("BOTW.7z")
      esri_db_path = data_dir.join("BOTW.gdb")

      force = ENV["force"].present?

      birdlife_taxon_table = Bird::BirdLife::Taxon.table_name
      birdlife_distribution_table = Bird::BirdLife::Distribution.table_name

      FileUtils.mkdir_p(data_dir)

      if !Dir.exist?(esri_db_path) || force
        system("7z", "x", "-o#{data_dir}", esri_archive.to_s, exception: true)
      else
        # If we've already extracted, skip this step.
        puts("Birdlife already extracted, skipping. Use --force to override...")
      end

      # Extract taxonomic checklist (contains db specific IDs)
      if !ActiveRecord::Base.connection.data_source_exists?(birdlife_taxon_table) || force
        Datasets::OGR.to_postgres(
          esri_db_path,
          table: birdlife_taxon_table,
          layer: "BirdLife_Taxonomic_Checklist_V5"
        )
      else
        puts("Birdlife taxonomy already exported, skipping. Use --force to override...")
      end

      # Extract distribution data ==> Postgres
      if !ActiveRecord::Base.connection.data_source_exists?(birdlife_distribution_table) || force
        Datasets::OGR.to_postgres(
          esri_db_path,
          table: birdlife_distribution_table,
          layer: "All_Species",
          nlt: "MULTIPOLYGON"
        )
      else
        puts("Birdlife distributions already exported, skipping. Use --force to override...")
      end
    end

    desc "Build data/birdlife/us_taxa.json from US distributions"
    task us_taxa: :environment do
      us_species = Bird::BirdLife::Distribution.species_in_boundary("us50")

      taxonomy_data = { orders: {} }

      us_species.each do |s|
        species_tax = Bird::BirdLife::Taxon.find_by(sisrecid: s.sisid)
        order = species_tax.order_
        family = species_tax.familyname
        sci_name = species_tax.scientificname

        order_hash = taxonomy_data[:orders][order] ||= {
          scientific_name: order,
          families: {}
        }

        family_hash = order_hash[:families][family] ||= {
          scientific_name: family,
          common_name: species_tax.family,
          genera: {}
        }

        genus = sci_name.split(" ").first
        genus_hash = family_hash[:genera][genus] ||= {
          scientific_name: genus,
          species: {}
        }

        genus_hash[:species][sci_name] = {
          scientific_name: sci_name,
          common_name: species_tax.commonname
        }
      end

      Datasets::JsonWriter.write(
        "us_taxa",
        taxonomy_data,
        dest_dir: Datasets::BirdLife.birdlife_data_dir
      )
    end
  end
end
