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

ActiveRecord::Schema[8.1].define(version: 2026_09_08_024735) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "postgis"

  create_table "bird_families", force: :cascade do |t|
    t.string "common_name"
    t.integer "count"
    t.datetime "created_at", null: false
    t.string "scientific_name"
    t.datetime "updated_at", null: false
  end

  create_table "bird_species", force: :cascade do |t|
    t.bigint "bird_family_id", null: false
    t.string "common_names", array: true
    t.datetime "created_at", null: false
    t.integer "external_id"
    t.string "scientific_name"
    t.datetime "updated_at", null: false
    t.index ["bird_family_id"], name: "index_bird_species_on_bird_family_id"
  end

# Could not dump table "birdlife_distributions" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'shape'


  create_table "birdlife_taxonomy", primary_key: "objectid", id: :serial, force: :cascade do |t|
    t.string "alternativecommonnames", limit: 255
    t.string "authority", limit: 255
    t.string "birdlifetaxonomy", limit: 255
    t.string "commonname", limit: 255
    t.string "family", limit: 255
    t.string "familyname", limit: 255
    t.string "order_", limit: 255
    t.string "redlistcategory_2020", limit: 255
    t.string "scientificname", limit: 255
    t.float "sequence"
    t.float "sisrecid"
    t.string "subfamily", limit: 255
    t.string "synonyms", limit: 255
    t.string "taxonomicnotes", limit: 255
    t.binary "taxonomicsource"
    t.string "tribe", limit: 255
  end

# Could not dump table "counties" because of following StandardError
#   Unknown type 'geometry(MultiPolygon,4326)' for column 'wkb_geometry'


  create_table "families", force: :cascade do |t|
    t.text "common_names", default: [], array: true
    t.datetime "created_at", null: false
    t.text "external_id"
    t.bigint "order_id"
    t.text "scientific_name"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_families_on_order_id"
  end

  create_table "genera", force: :cascade do |t|
    t.text "common_names", default: [], array: true
    t.datetime "created_at", null: false
    t.text "external_id"
    t.bigint "family_id", null: false
    t.text "scientific_name"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_genera_on_family_id"
  end

  create_table "orders", force: :cascade do |t|
    t.text "common_names", default: [], array: true
    t.datetime "created_at", null: false
    t.text "scientific_name"
    t.bigint "taxonomic_class_id", null: false
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["taxonomic_class_id"], name: "index_orders_on_taxonomic_class_id"
  end

  create_table "species", force: :cascade do |t|
    t.text "common_names", default: [], array: true
    t.datetime "created_at", null: false
    t.text "external_id"
    t.bigint "genus_id", null: false
    t.text "scientific_name"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["genus_id"], name: "index_species_on_genus_id"
  end

  create_table "taxonomic_classes", force: :cascade do |t|
    t.text "common_names", default: [], array: true
    t.datetime "created_at", null: false
    t.text "scientific_name"
    t.datetime "updated_at", null: false
  end

# Could not dump table "us_boundary" because of following StandardError
#   Unknown type 'geometry' for column 'geometry'


  add_foreign_key "bird_species", "bird_families"
  add_foreign_key "families", "orders"
  add_foreign_key "genera", "families"
  add_foreign_key "orders", "taxonomic_classes"
  add_foreign_key "species", "genera"
end
