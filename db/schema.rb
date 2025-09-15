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

ActiveRecord::Schema[8.0].define(version: 2025_09_15_100946) do
  create_table "achievements", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "date"
    t.integer "position"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_achievements_on_user_id"
  end

  create_table "achievements_tags", id: false, force: :cascade do |t|
    t.integer "achievement_id", null: false
    t.integer "tag_id", null: false
    t.index ["achievement_id", "tag_id"], name: "index_achievements_tags_on_achievement_id_and_tag_id"
    t.index ["tag_id", "achievement_id"], name: "index_achievements_tags_on_tag_id_and_achievement_id"
  end

  create_table "certificates", force: :cascade do |t|
    t.string "name"
    t.string "organization"
    t.string "date"
    t.text "description"
    t.integer "position"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_certificates_on_user_id"
  end

  create_table "certificates_tags", id: false, force: :cascade do |t|
    t.integer "certificate_id", null: false
    t.integer "tag_id", null: false
    t.index ["certificate_id", "tag_id"], name: "index_certificates_tags_on_certificate_id_and_tag_id"
    t.index ["tag_id", "certificate_id"], name: "index_certificates_tags_on_tag_id_and_certificate_id"
  end

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

  create_table "educations_tags", id: false, force: :cascade do |t|
    t.integer "education_id", null: false
    t.integer "tag_id", null: false
    t.index ["education_id", "tag_id"], name: "index_educations_tags_on_education_id_and_tag_id"
    t.index ["tag_id", "education_id"], name: "index_educations_tags_on_tag_id_and_education_id"
  end

  create_table "experience_bullets", force: :cascade do |t|
    t.text "content"
    t.integer "position"
    t.integer "experience_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["experience_id"], name: "index_experience_bullets_on_experience_id"
  end

  create_table "experience_bullets_tags", id: false, force: :cascade do |t|
    t.integer "experience_bullet_id", null: false
    t.integer "tag_id", null: false
    t.index ["experience_bullet_id", "tag_id"], name: "idx_on_experience_bullet_id_tag_id_83fffd2f42"
    t.index ["tag_id", "experience_bullet_id"], name: "idx_on_tag_id_experience_bullet_id_fec40f1835"
  end

  create_table "experiences", force: :cascade do |t|
    t.string "company"
    t.string "location"
    t.string "position_title"
    t.date "start_date"
    t.date "end_date"
    t.boolean "current"
    t.integer "position"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_experiences_on_user_id"
  end

  create_table "experiences_tags", id: false, force: :cascade do |t|
    t.integer "experience_id", null: false
    t.integer "tag_id", null: false
    t.index ["experience_id", "tag_id"], name: "index_experiences_tags_on_experience_id_and_tag_id"
    t.index ["tag_id", "experience_id"], name: "index_experiences_tags_on_tag_id_and_experience_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.string "proficiency"
    t.integer "position"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_languages_on_user_id"
  end

  create_table "languages_tags", id: false, force: :cascade do |t|
    t.integer "language_id", null: false
    t.integer "tag_id", null: false
    t.index ["language_id", "tag_id"], name: "index_languages_tags_on_language_id_and_tag_id"
    t.index ["tag_id", "language_id"], name: "index_languages_tags_on_tag_id_and_language_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "role"
    t.date "start_date"
    t.date "end_date"
    t.integer "position"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_organizations_on_user_id"
  end

  create_table "organizations_tags", id: false, force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "tag_id", null: false
    t.index ["organization_id", "tag_id"], name: "index_organizations_tags_on_organization_id_and_tag_id"
    t.index ["tag_id", "organization_id"], name: "index_organizations_tags_on_tag_id_and_organization_id"
  end

  create_table "project_bullets", force: :cascade do |t|
    t.text "content"
    t.integer "position"
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_bullets_on_project_id"
  end

  create_table "project_bullets_tags", id: false, force: :cascade do |t|
    t.integer "project_bullet_id", null: false
    t.integer "tag_id", null: false
    t.index ["project_bullet_id", "tag_id"], name: "index_project_bullets_tags_on_project_bullet_id_and_tag_id"
    t.index ["tag_id", "project_bullet_id"], name: "index_project_bullets_tags_on_tag_id_and_project_bullet_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "link"
    t.string "date"
    t.integer "position"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "link_title"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "projects_tags", id: false, force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "tag_id", null: false
    t.index ["project_id", "tag_id"], name: "index_projects_tags_on_project_id_and_tag_id"
    t.index ["tag_id", "project_id"], name: "index_projects_tags_on_tag_id_and_project_id"
  end

  create_table "references", force: :cascade do |t|
    t.string "name"
    t.string "contact"
    t.string "position_title"
    t.integer "position"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_references_on_user_id"
  end

  create_table "references_tags", id: false, force: :cascade do |t|
    t.integer "reference_id", null: false
    t.integer "tag_id", null: false
    t.index ["reference_id", "tag_id"], name: "index_references_tags_on_reference_id_and_tag_id"
    t.index ["tag_id", "reference_id"], name: "index_references_tags_on_tag_id_and_reference_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections_templates", id: false, force: :cascade do |t|
    t.integer "section_id", null: false
    t.integer "template_id", null: false
    t.index ["section_id", "template_id"], name: "index_sections_templates_on_section_id_and_template_id"
    t.index ["template_id", "section_id"], name: "index_sections_templates_on_template_id_and_section_id"
  end

  create_table "skill_categories", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_skill_categories_on_user_id"
  end

  create_table "skill_categories_tags", id: false, force: :cascade do |t|
    t.integer "skill_category_id", null: false
    t.integer "tag_id", null: false
    t.index ["skill_category_id", "tag_id"], name: "index_skill_categories_tags_on_skill_category_id_and_tag_id"
    t.index ["tag_id", "skill_category_id"], name: "index_skill_categories_tags_on_tag_id_and_skill_category_id"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.integer "skill_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["skill_category_id"], name: "index_skills_on_skill_category_id"
  end

  create_table "skills_tags", id: false, force: :cascade do |t|
    t.integer "skill_id", null: false
    t.integer "tag_id", null: false
    t.index ["skill_id", "tag_id"], name: "index_skills_tags_on_skill_id_and_tag_id"
    t.index ["tag_id", "skill_id"], name: "index_skills_tags_on_tag_id_and_skill_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "position"
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

  add_foreign_key "achievements", "users"
  add_foreign_key "certificates", "users"
  add_foreign_key "cv_heading_items", "cv_headings"
  add_foreign_key "cv_headings", "users"
  add_foreign_key "educations", "users"
  add_foreign_key "experience_bullets", "experiences"
  add_foreign_key "experiences", "users"
  add_foreign_key "languages", "users"
  add_foreign_key "organizations", "users"
  add_foreign_key "project_bullets", "projects"
  add_foreign_key "projects", "users"
  add_foreign_key "references", "users"
  add_foreign_key "skill_categories", "users"
  add_foreign_key "skills", "skill_categories"
  add_foreign_key "tags", "users"
  add_foreign_key "templates", "users"
end
