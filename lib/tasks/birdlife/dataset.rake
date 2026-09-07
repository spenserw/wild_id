namespace :birdlife do
  desc "Destroy all Bird::Species and Bird::Family records"
  task cleanup: :environment do
    Bird::Species.destroy_all
    Bird::Family.destroy_all
  end

  desc "Import US bird orders from the us_taxa artifact"
  task load_us_bird_orders: :environment do
    Datasets::BirdLife::Dataset.load_bird_orders(
      Datasets::BirdLife::Dataset.artifact_path(Datasets::BirdLife::Dataset::US_TAXA_ARTIFACT)
    )
  end

  desc "Import US bird families from the us_taxa artifact"
  task load_us_bird_families: :environment do
    Datasets::BirdLife::Dataset.load_bird_families(
      Datasets::BirdLife::Dataset.artifact_path(Datasets::BirdLife::Dataset::US_TAXA_ARTIFACT)
    )
  end

  desc "Import US bird genuses from the us_taxa artifact"
  task load_us_bird_genuses: :environment do
    Datasets::BirdLife::Dataset.load_bird_genuses(
      Datasets::BirdLife::Dataset.artifact_path(Datasets::BirdLife::Dataset::US_TAXA_ARTIFACT)
    )
  end

  desc "Import US bird species from the us_taxa artifact"
  task load_us_bird_species: :environment do
    Datasets::BirdLife::Dataset.load_bird_species(
      Datasets::BirdLife::Dataset.artifact_path(Datasets::BirdLife::Dataset::US_TAXA_ARTIFACT)
    )
  end

  desc "Cleanup, extract BirdLife data, build us_taxa, and load families/species"
  task import: [
    :cleanup,
    "artifacts:extract",
    "artifacts:us_taxa",
    :load_us_bird_orders,
    :load_us_bird_families,
    :load_us_bird_genuses,
    :load_us_bird_species
  ]

  namespace :artifacts do
    desc "Extract BOTW archive and load taxonomy/distribution into Postgres"
    task extract: :environment do
      data_dir = Datasets::BirdLife::Dataset.birdlife_data_dir
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

      taxonomy_data = {
        orders: {},
        count: 0,
        total_species_count: 0
      }

      us_species.each do |s|
        species_tax = Bird::BirdLife::Taxon.find_by(sisrecid: s.sisid)
        order = species_tax.order_
        family = species_tax.familyname
        sci_name = species_tax.scientificname

        taxonomy_data[:count] += 1 unless taxonomy_data[:orders][order].present?
        order_hash = taxonomy_data[:orders][order] ||= {
          families: {},
          count: 0
        }

        order_hash[:count] += 1 unless order_hash[:families][family].present?
        family_hash = taxonomy_data[:orders][order][:families][family] ||= {
          common_name: species_tax.family,
          genuses: {},
          count: 0
        }

        genus = sci_name.split(" ").first
        family_hash[:count] += 1 unless family_hash[:genuses][genus].present?
        genus_hash = family_hash[:genuses][genus] ||= {
          species: {},
          count: 0
        }

        genus_hash[:count] += 1
        genus_hash[:species][sci_name] = {
          scientific_name: sci_name,
          common_name: species_tax.commonname
        }

        taxonomy_data[:total_species_count] += 1
      end

      Datasets::JsonWriter.write(
        "us_taxa",
        taxonomy_data,
        dest_dir: Datasets::BirdLife::Dataset.birdlife_data_dir
      )
    end
  end
end
