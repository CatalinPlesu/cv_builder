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

ActiveRecord::Schema[8.0].define(version: 2025_09_14_152642) do
  create_table "cv_heading_items", force: :cascade do |t|
    t.integer "cv_heading_id", null: false
    t.string "icon"
    t.string "text"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["cv_heading_id", "position"], name: "index_cv_heading_items_on_cv_heading_id_and_position"
    t.index ["cv_heading_id"], name: "index_cv_heading_items_on_cv_heading_id"
    t.index ["url"], name: "index_cv_heading_items_on_url"
  end

  create_table "cv_headings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "full_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_cv_headings_on_user_id"
  end

  create_table "educations", force: :cascade do |t|
    t.string "institution"
    t.string "location"
    t.string "degree"
    t.date "start_date"
    t.date "end_date"
    t.string "gpa"
    t.text "additional_info"
    t.integer "position"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_educations_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "name"], name: "index_tags_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "tags_templates", id: false, force: :cascade do |t|
    t.integer "tag_id", null: false
    t.integer "template_id", null: false
    t.index ["tag_id", "template_id"], name: "index_tags_templates_on_tag_id_and_template_id"
    t.index ["template_id", "tag_id"], name: "index_tags_templates_on_template_id_and_tag_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "name"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_templates_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "cv_heading_items", "cv_headings"
  add_foreign_key "cv_headings", "users"
  add_foreign_key "educations", "users"
  add_foreign_key "tags", "users"
  add_foreign_key "templates", "users"
end
