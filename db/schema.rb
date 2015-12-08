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

ActiveRecord::Schema.define(version: 20151204234343) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.text     "body",       null: false
    t.integer  "user_id",    null: false
    t.integer  "post_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "markdown",   null: false
  end

  create_table "contributors", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.string   "status",     default: "pending", null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "organization_memberships", force: :cascade do |t|
    t.string   "role",            default: "regular", null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "member_id"
    t.integer  "organization_id"
  end

  add_index "organization_memberships", ["member_id", "organization_id"], name: "index_organization_memberships_on_member_id_and_organization_id", unique: true, using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "slug",       null: false
  end

  add_index "organizations", ["slug"], name: "index_organizations_on_slug", unique: true, using: :btree

  create_table "post_likes", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string   "status",           default: "open"
    t.string   "post_type",        default: "task"
    t.string   "title",                             null: false
    t.text     "body",                              null: false
    t.integer  "user_id",                           null: false
    t.integer  "project_id",                        null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "post_likes_count", default: 0
    t.text     "markdown",                          null: false
    t.integer  "number",                            null: false
  end

  add_index "posts", ["number", "project_id"], name: "index_posts_on_number_and_project_id", unique: true, using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "title",              null: false
    t.string   "description"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.text     "base_64_icon_data"
    t.integer  "contributors_count"
  end

  add_index "projects", ["owner_type", "owner_id"], name: "index_projects_on_owner_type_and_owner_id", using: :btree

  create_table "skill_categories", force: :cascade do |t|
    t.string   "title",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string   "title",             null: false
    t.string   "description"
    t.integer  "skill_category_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "slug_routes", force: :cascade do |t|
    t.string   "slug",       null: false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "slug_routes", ["owner_id", "owner_type"], name: "index_slug_routes_on_owner_id_and_owner_type", unique: true, using: :btree
  add_index "slug_routes", ["slug"], name: "index_slug_routes_on_slug", unique: true, using: :btree

  create_table "team_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "member_id"
    t.integer  "team_id"
  end

  add_index "team_memberships", ["member_id", "team_id"], name: "index_team_memberships_on_member_id_and_team_id", unique: true, using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",            null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "organization_id"
  end

  create_table "user_skills", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "skill_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "email",                                             null: false
    t.string   "encrypted_password",    limit: 128,                 null: false
    t.string   "confirmation_token",    limit: 128
    t.string   "remember_token",        limit: 128,                 null: false
    t.string   "username"
    t.boolean  "admin",                             default: false, null: false
    t.text     "website"
    t.string   "twitter"
    t.text     "biography"
    t.string   "facebook_id"
    t.string   "facebook_access_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "posts", "projects"
  add_foreign_key "posts", "users"
end
