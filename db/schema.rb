# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_05_14_160950) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "bird_families", force: :cascade do |t|
    t.string "scientific_name"
    t.string "common_names", array: true
    t.integer "species_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "curation_checksum", limit: 32, null: false
  end

  create_table "bird_species", force: :cascade do |t|
    t.string "scientific_name"
    t.string "common_names", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bird_family_id"
    t.uuid "primary_reference_image_id"
    t.uuid "gallery_reference_image_ids", array: true
    t.string "curation_checksum", limit: 32, null: false
    t.string "sound_gallery", array: true
    t.index ["bird_family_id"], name: "index_bird_species_on_bird_family_id"
  end

  create_table "bird_species_reference_images", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.json "license"
    t.string "author"
    t.string "source_site"
    t.string "source_url"
    t.string "asset_url"
  end

  add_foreign_key "bird_species", "bird_families"
end
