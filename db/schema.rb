# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150814214447) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "deliverables", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.integer  "ordering",   default: 0, null: false
    t.string   "name",                   null: false
    t.text     "value"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.uuid     "mission_id"
  end

  add_index "deliverables", ["mission_id"], name: "index_deliverables_on_mission_id", using: :btree
  add_index "deliverables", ["ordering"], name: "index_deliverables_on_ordering", using: :btree

  create_table "missions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "description"
    t.string   "name",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "requirements", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.integer  "ordering",       default: 0, null: false
    t.string   "name",                       null: false
    t.text     "description"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.uuid     "deliverable_id"
  end

  add_index "requirements", ["deliverable_id"], name: "index_requirements_on_deliverable_id", using: :btree
  add_index "requirements", ["ordering"], name: "index_requirements_on_ordering", using: :btree

  add_foreign_key "deliverables", "missions"
  add_foreign_key "requirements", "deliverables"
end
