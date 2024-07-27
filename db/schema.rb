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

ActiveRecord::Schema[7.1].define(version: 2024_07_19_174419) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.integer "turn_duration"
    t.integer "current_turn"
    t.bigint "top_white_player_id"
    t.bigint "top_black_player_id"
    t.bigint "bottom_white_player_id"
    t.bigint "bottom_black_player_id"
    t.integer "board_size"
    t.string "pieces"
    t.boolean "processing_moves"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bottom_black_player_id"], name: "index_games_on_bottom_black_player_id"
    t.index ["bottom_white_player_id"], name: "index_games_on_bottom_white_player_id"
    t.index ["top_black_player_id"], name: "index_games_on_top_black_player_id"
    t.index ["top_white_player_id"], name: "index_games_on_top_white_player_id"
  end

  create_table "moves", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "game_id"
    t.integer "turn"
    t.integer "src"
    t.integer "dest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["user_id"], name: "index_moves_on_user_id"
  end

  create_table "pairs", force: :cascade do |t|
    t.bigint "white_player_id"
    t.bigint "black_player_id"
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["black_player_id"], name: "index_pairs_on_black_player_id"
    t.index ["game_id"], name: "index_pairs_on_game_id"
    t.index ["white_player_id"], name: "index_pairs_on_white_player_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
  end

  add_foreign_key "games", "users", column: "bottom_black_player_id"
  add_foreign_key "games", "users", column: "bottom_white_player_id"
  add_foreign_key "games", "users", column: "top_black_player_id"
  add_foreign_key "games", "users", column: "top_white_player_id"
  add_foreign_key "pairs", "users", column: "black_player_id"
  add_foreign_key "pairs", "users", column: "white_player_id"
end
