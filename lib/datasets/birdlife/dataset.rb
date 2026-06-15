US_TAXA_ARTIFACT = "us_taxa".freeze

def write_output(name, data)
  # sub whitespace with '_'
  filename = "#{name.gsub(/[^\w.]/, '_').downcase}.json"
  File.write("#{File.dirname(__FILE__)}/#{filename}", data)
end

def load_taxa_dump
  file = File.open(File.join(File.dirname(__FILE__), "#{US_TAXA_ARTIFACT}.json"))
  JSON.parse(file.read).with_indifferent_access
end

namespace :birdlife do
  namespace :artifact do
    task :us_taxa do
      us_species = Bird::BirdLife::Distribution.species_in_boundary("us50")

      taxonomy_data = {
        species: {},
        families: {},
        count: 0
      }

      us_species.each do |s|
        species_tax = Bird::BirdLife::Taxon.find_by(sisrecid: s.sisid)
        family = species_tax.familyname
        sci_name = species_tax.scientificname

        # Update species family & total family count
        taxonomy_data[:families][family] ||= {
          common_name: species_tax.family,
          species: {},
          count: 0
        }
        taxonomy_data[:families][family][:count] += 1

        taxonomy_data[:families][family][:species][sci_name] = {
          scientific_name: sci_name,
          common_name: species_tax.commonname
        }

        write_output("us_taxa", taxonomy_data)
      end
    end
  end

  task cleanup: :environment do
    BirdSpecies.destroy_all
    BirdFamily.destroy_all
  end

  task extract: :environment do
    data_dir = File.join(File.dirname(__FILE__), "data")
    esri_archive = File.join(File.dirname(__FILE__), "BOTW.7z")
    esri_db_path = File.join(data_dir, "BOTW.gdb")

    force = ENV["force"].present?

    birdlife_taxon_table = Bird::BirdLife::Taxon.table_name
    birdlife_distribution_table = Bird::BirdLife::Distribution.table_name

    if !Dir.exist?(esri_db_path) || force
      `7z x -o#{data_dir} #{esri_archive}`
    else
      # If we've already extracted, skip this step.
      puts("Birdlife already extracted, skipping. Use --force to override...")
    end

    ogr2ogr_cmd = Rails.configuration.x.datasets[:constants][:OGR2OGR_CMD]
    pg_db = Rails.configuration.database_configuration[Rails.env]
    pg_db_name = pg_db[:database]
    pg_db_user = pg_db[:username]
    pg_conn = "dbname='#{pg_db_name}' user='#{pg_db_user}'"
    # Extract taxonomic checklist (contains db specific IDs)
    if !ActiveRecord::Base.connection.data_source_exists?(birdlife_taxon_table) || force
      `#{ogr2ogr_cmd} PG:"#{pg_conn}" #{esri_db_path} -nln #{birdlife_taxon_table} BirdLife_Taxonomic_Checklist_V5`
    else
      puts("Birdlife taxonomy already exported, skipping. Use --force to override...")
    end

    # Extract distribution data ==> Postgres
    if !ActiveRecord::Base.connection.data_source_exists?(birdlife_distribution_table) || force
      `#{ogr2ogr_cmd} PG:"#{pg_conn}" #{esri_db_path} -nln #{birdlife_distribution_table} -nlt 'MULTIPOLYGON' All_Species`
    else
      puts("Birdlife distributions already exported, skipping. Use --force to override...")
    end
  end

  task load_us_bird_families: :environment do
    puts "Importing bird families..."
    taxa = load_taxa_dump

    Bird::Family.transaction do
      taxa[:families].each do |scientific_name, metadata|
        Bird::Family.create!(
          scientific_name: scientific_name,
          common_name: metadata[:common_names],
          count: v[:count]
        )

        puts "Imported #{k}"
      end
    end
  end

  task load_us_bird_species: :environment do
    puts "Importing bird species..."
    taxa = load_taxa_dump

    # TODO: Finish implementing
    Bird::Species.transaction do
      taxa[:families]
    end
  end

  task import: [ :cleanup, :extract, "artifact:us_taxa" ]
end
