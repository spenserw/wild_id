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

ActiveRecord::Schema[8.1].define(version: 2026_08_15_170249) do
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

  add_foreign_key "bird_species", "bird_families"
end
