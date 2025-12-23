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

ActiveRecord::Schema[8.1].define(version: 2025_09_17_222829) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "book_list_entries", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "book_list_id", null: false
    t.datetime "created_at", null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.index ["book_id", "book_list_id"], name: "index_book_list_entries_on_book_id_and_book_list_id"
    t.index ["book_id"], name: "index_book_list_entries_on_book_id"
    t.index ["book_list_id"], name: "index_book_list_entries_on_book_list_id"
  end

  create_table "book_lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "list_type", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["name", "user_id"], name: "index_book_lists_on_name_and_user_id", unique: true
    t.index ["user_id"], name: "index_book_lists_on_user_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "author", null: false
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["title", "author", "user_id"], name: "index_books_on_title_and_author_and_user_id", unique: true
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "book_list_entries", "book_lists"
  add_foreign_key "book_list_entries", "books"
  add_foreign_key "book_lists", "users"
  add_foreign_key "books", "users"
  add_foreign_key "sessions", "users"
end
