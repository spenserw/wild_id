require "google_drive"
require "json"

require_relative './birds/reference_images.rb'

# TODO 3-20-2022: I'm not happy with this form of authentication, but the `google_drive` gem seems fussy with authentication... Perhaps we'll change to another gem in the future.
def get_gsheets_session()
  credentials_file_path= "#{File.dirname(__FILE__)}/birds/.gsheets-credentials.json"
  session = GoogleDrive::Session.from_config(credentials_file_path)
  return session
end

def import_gsheets(session)
  spreadsheet_id = "1diYxdX2W9mWuhDZ232G-MJ12AjOymHWdxKOjWadZoLo"

  ws = session.spreadsheet_by_key(spreadsheet_id).worksheets
  return ws
end

# Filter the rows that haven't yet been imported to the front-end and are marked for publishing
def filter_new_rows(worksheet)
  worksheet.rows.each do |row|

  end
end

def pull_families(worksheet)
  puts "Pulling down newly curated families..."

  worksheet.rows[1..].each do |row|
    sci_name = row[1]
    if BirdFamily.find_by(scientific_name: sci_name) == nil
      family = BirdFamily.new do |f|
        f.id = row[0]
        f.scientific_name = row[1]
        f.common_names = JSON.parse(row[2])
        f.species_count = row[3].to_i
      end
      family.save
    end
  end
end

# Import previously un-imported species and curation data from spreadsheet
def pull_species(worksheet)
  puts "Pulling down newly curated species..."

  worksheet.rows[1..].each do |row|
    sci_name = row[2]
    if BirdSpecies.find_by(scientific_name: sci_name) == nil
      # Verify species is meant to be published
      published = row[5] == "TRUE"
      next if not published

      species = BirdSpecies.new do |s|
        s.id = row[0]
        s.scientific_name = row[2]
        s.common_names = JSON.parse(row[3])
        s.bird_family_id = BirdFamily.find_by(scientific_name: row[4]).id.to_i
      end
      species.save
    end
  end
end

# Import previously un-imported images and store them properly
def pull_reference_images(worksheet)
  worksheet.rows[1..].each do |row|
    published = row[5] == "TRUE"
    next if not published

    sci_name = row[2]
    species = BirdSpecies.find_by(scientific_name: sci_name)
    if not species
      puts("Species must first be ingested! Unknown spcies [#{sci_name}].")
      next
    end

    species_was_updated = false
    # Primary image creation
    primary_image_url = row[6]
    if not BirdSpeciesReferenceImage.find_by(source_url: primary_image_url)
      uuid = ReferenceImage::create(primary_image_url)

      species.primary_reference_image_id = uuid
      species_was_updated = true if not species_was_updated
    end

    # Gallery images
    gallery_image_urls_cell = row[7]
    gallery_image_urls_cell.split(',').each do |url|
      if not BirdSpeciesReferenceImage.find_by(source_url: url)
        uuid = ReferenceImage::create(url)

        if species.gallery_reference_image_ids == nil
          species.gallery_reference_image_ids = [uuid]
        else
          species.gallery_reference_image_ids.push(uuid)
        end
        species_was_updated = true if not species_was_updated
      end
    end

    species.save if species_was_updated
  end
end

namespace :birds do
  desc "Import bird taxonomy data."

  task :pull_families => :environment do
    puts "Pulling bird families from curation sheet..."

    session = get_gsheets_session()
    worksheet = import_gsheets(session)[1]
    pull_families(worksheet)
  end
  
  task :pull_species => :environment do
    puts "Pulling bird species from curation sheet..."

    session = get_gsheets_session()
    worksheet = import_gsheets(session)[0]
    pull_species(worksheet)
  end

  task pull_images: :environment do
    puts "Pulling bird reference images from curation sheet..."

    session = get_gsheets_session()
    worksheet = import_gsheets(session)[0]
    pull_reference_images(worksheet)
  end

  task pull: [:pull_families, :pull_species, :pull_images] do
    puts "Updated all bird taxonomy data."
  end

end
