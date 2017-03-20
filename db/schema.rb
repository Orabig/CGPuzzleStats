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

ActiveRecord::Schema.define(version: 20170320135935) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievement_players", force: :cascade do |t|
    t.integer  "achievement_id",  null: false
    t.integer  "player_id",       null: false
    t.integer  "progress"
    t.datetime "completion_time"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["achievement_id", "player_id"], name: "index_achievement_players_on_achievement_id_and_player_id", unique: true, using: :btree
  end

  create_table "achievements", force: :cascade do |t|
    t.string   "text_id"
    t.integer  "puzzle_id"
    t.string   "title"
    t.text     "description"
    t.integer  "points"
    t.bigint   "image_binary_id"
    t.string   "category"
    t.string   "group"
    t.string   "level"
    t.string   "unlock_text"
    t.integer  "weight"
    t.integer  "progress_max"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "unit"
    t.integer  "language_id"
    t.index ["language_id"], name: "index_achievements_on_language_id", using: :btree
    t.index ["puzzle_id"], name: "index_achievements_on_puzzle_id", using: :btree
  end

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_languages_on_name", unique: true, using: :btree
  end

  create_table "players", force: :cascade do |t|
    t.integer  "cgid"
    t.string   "pseudo"
    t.integer  "level"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "rank"
    t.boolean  "refresh_pending"
    t.datetime "last_displayed"
    t.datetime "last_refreshed"
    t.index ["cgid"], name: "index_players_on_cgid", unique: true, using: :btree
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "puzzles", force: :cascade do |t|
    t.integer  "cgid"
    t.string   "title"
    t.string   "description"
    t.string   "detailsPageUrl"
    t.string   "level"
    t.string   "prettyId"
    t.integer  "solvedCount"
    t.string   "puzzleType"
    t.integer  "achievementCount"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "leaderboardId"
    t.index ["cgid"], name: "index_puzzles_on_cgid", unique: true, using: :btree
  end

  create_table "results", force: :cascade do |t|
    t.integer  "player_id",     null: false
    t.integer  "language_id",   null: false
    t.integer  "puzzle_id",     null: false
    t.boolean  "is_last"
    t.boolean  "is_onboarding"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["language_id", "player_id", "puzzle_id"], name: "index_results_on_language_id_and_player_id_and_puzzle_id", unique: true, using: :btree
  end

  add_foreign_key "achievements", "languages"
end
