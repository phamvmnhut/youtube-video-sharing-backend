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

ActiveRecord::Schema[7.0].define(version: 2023_06_14_001024) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "shared_id", null: false
    t.boolean "is_like"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shared_id"], name: "index_likes_on_shared_id"
    t.index ["user_id", "shared_id"], name: "index_likes_on_user_id_and_shared_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "shareds", force: :cascade do |t|
    t.string "url"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.text "description"
    t.integer "upvote", default: 0
    t.integer "downvote", default: 0
    t.index ["user_id"], name: "index_shareds_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "likes", "shareds"
  add_foreign_key "likes", "users"
  add_foreign_key "shareds", "users"
end
