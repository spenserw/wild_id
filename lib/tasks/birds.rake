require "google_drive"
require 'json'
require 'digest'

require_relative './birds/reference_images.rb'

# TODO 3-20-2022: I'm not happy with this form of authentication, but the `google_drive` gem seems fussy with authentication... Perhaps we'll change to another gem in the future.
def get_gsheets_session
  credentials_file_path= "#{File.dirname(__FILE__)}/birds/.gsheets-credentials.json"
  GoogleDrive::Session.from_config(credentials_file_path)
end

def import_gsheets(session)
  spreadsheet_id = '1diYxdX2W9mWuhDZ232G-MJ12AjOymHWdxKOjWadZoLo'

  session.spreadsheet_by_key(spreadsheet_id).worksheets
end

def compute_checksum_for_row(row)
  md5 = Digest::MD5.new
  md5.update(row.to_s)
  md5.hexdigest
end

def import_family(family_record, row, checksum)
  family_record.id = row[0]
  family_record.scientific_name = row[1]
  family_record.common_names = JSON.parse(row[2])
  family_record.species_count = row[3].to_i
  family_record.curation_checksum = checksum
  family_record
end

def pull_families(worksheet)
  puts 'Pulling down newly curated families...'

  worksheet.rows[1..].each do |row|
    sci_name = row[1]

    # Verify family is meant to be published
    published = row[4] == 'TRUE'
    next unless published

    row_checksum = compute_checksum_for_row(row)
    family_record = BirdFamily.find_by(scientific_name: sci_name)
    next unless family_record.nil? || family_record.curation_checksum != row_checksum

    family_record ||= BirdFamily.new
    family = import_family(family_record, row, row_checksum)
    family.save!
    puts "Added family [#{sci_name}]."
  end
end

def import_species(species_record, row, checksum)
  species_record.id = row[0]
  species_record.scientific_name = row[2]
  species_record.common_names = JSON.parse(row[3])

  family = BirdFamily.find_by(scientific_name: row[4])
  if family.nil?
    puts "Cannot find family [#{row[4]}]!"
    exit
  end

  species_record.bird_family_id = family.id.to_i
  species_record.sound_gallery = row[8].empty? and [] or row[8]&.split(',')
  species_record.curation_checksum = checksum
  species_record
end

# Import previously un-imported species and curation data from spreadsheet
def pull_species(worksheet)
  puts 'Pulling down newly curated species...'

  worksheet.rows[1..].each do |row|
    sci_name = row[2]

    # Verify species is meant to be published
    published = row[5] == 'TRUE'
    next unless published

    row_checksum = compute_checksum_for_row(row)
    species_record = BirdSpecies.find_by(scientific_name: sci_name)
    next unless species_record.nil? || species_record.curation_checksum != row_checksum

    species_record ||= BirdSpecies.new
    species = import_species(species_record, row, row_checksum)
    species.save!
    puts "Added species [#{sci_name}]"
  end
end

# Import previously un-imported images and store them properly
def pull_reference_images(worksheet)
  worksheet.rows[1..].each do |row|
    published = row[5] == 'TRUE'
    next unless published

    sci_name = row[2]
    species = BirdSpecies.find_by(scientific_name: sci_name)
    unless species
      puts("Species must first be ingested! Unknown spcies [#{sci_name}].")
      next
    end

    species_was_updated = false
    # Primary image creation
    primary_image_url = row[6]
    unless BirdSpeciesReferenceImage.find_by(source_url: primary_image_url)
      uuid = ReferenceImage.create(primary_image_url)

      species.primary_reference_image_id = uuid
      species_was_updated ||= true
    end

    # Gallery images
    gallery_image_urls_cell = row[7]
    gallery_image_urls_cell.split(',').each do |url|
      next if BirdSpeciesReferenceImage.find_by(source_url: url)

      uuid = ReferenceImage.create(url)

      if species.gallery_reference_image_ids.nil?
        species.gallery_reference_image_ids = [uuid]
      else
        species.gallery_reference_image_ids.push(uuid)
      end
      species_was_updated ||= true
    end

    species.save! if species_was_updated
  end
end

namespace :birds do
  desc 'Import bird taxonomy data.'

  task pull_families: :environment do
    puts 'Pulling bird families from curation sheet...'

    session = get_gsheets_session
    worksheet = import_gsheets(session)[1]
    pull_families(worksheet)
  end

  task pull_species: :environment do
    puts 'Pulling bird species from curation sheet...'

    session = get_gsheets_session
    worksheet = import_gsheets(session)[0]
    pull_species(worksheet)
  end

  task pull_images: :environment do
    puts 'Pulling bird reference images from curation sheet...'

    session = get_gsheets_session
    worksheet = import_gsheets(session)[0]
    pull_reference_images(worksheet)
  end

  task pull: %i[pull_families pull_species pull_images] do
    puts 'Updated all bird taxonomy data.'
  end
end
