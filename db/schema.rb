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

ActiveRecord::Schema.define(version: 20170313005002) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievement_players", force: :cascade do |t|
    t.integer  "achievement_id"
    t.integer  "player_id"
    t.integer  "progress"
    t.datetime "completion_time"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
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
  end

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  create_table "results", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "language_id"
    t.integer  "puzzle_id"
    t.boolean  "is_last"
    t.boolean  "is_onboarding"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
