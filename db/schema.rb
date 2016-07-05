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

ActiveRecord::Schema.define(version: 20160705042501) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "slug",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
  end

  add_index "categories", ["slug"], name: "index_categories_on_slug", unique: true, using: :btree

  create_table "comment_images", force: :cascade do |t|
    t.integer  "user_id",            null: false
    t.integer  "comment_id",         null: false
    t.text     "filename",           null: false
    t.text     "base64_photo_data",  null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "comment_user_mentions", force: :cascade do |t|
    t.integer  "user_id",     null: false
    t.integer  "comment_id",  null: false
    t.integer  "post_id",     null: false
    t.string   "username",    null: false
    t.integer  "start_index", null: false
    t.integer  "end_index",   null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text     "body"
    t.integer  "user_id",    null: false
    t.integer  "post_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "markdown"
    t.string   "aasm_state"
  end

  create_table "github_repositories", force: :cascade do |t|
    t.string   "repository_name", null: false
    t.string   "owner_name",      null: false
    t.integer  "project_id",      null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "import_skill_failures", force: :cascade do |t|
    t.integer  "import_id",  null: false
    t.integer  "skill_id"
    t.json     "data",       null: false
    t.text     "issues",     null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imports", force: :cascade do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "status",            default: 0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "notifiable_id",   null: false
    t.string   "notifiable_type", null: false
    t.integer  "user_id",         null: false
    t.string   "aasm_state"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "notifications", ["user_id", "notifiable_id", "notifiable_type"], name: "index_notifications_on_user_id_and_notifiable", unique: true, using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

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
    t.string   "role",            default: "pending", null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "member_id"
    t.integer  "organization_id"
  end

  add_index "organization_memberships", ["member_id", "organization_id"], name: "index_organization_memberships_on_member_id_and_organization_id", unique: true, using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name",              null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "slug",              null: false
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.text     "base64_icon_data"
    t.text     "description"
  end

  add_index "organizations", ["slug"], name: "index_organizations_on_slug", unique: true, using: :btree

  create_table "post_images", force: :cascade do |t|
    t.integer  "user_id",            null: false
    t.integer  "post_id",            null: false
    t.text     "filename",           null: false
    t.text     "base64_photo_data",  null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "post_likes", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "post_user_mentions", force: :cascade do |t|
    t.integer  "user_id",     null: false
    t.integer  "post_id",     null: false
    t.string   "username",    null: false
    t.integer  "start_index", null: false
    t.integer  "end_index",   null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string   "status",           default: "open"
    t.string   "post_type",        default: "task"
    t.string   "title"
    t.text     "body"
    t.integer  "user_id",                           null: false
    t.integer  "project_id",                        null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "post_likes_count", default: 0
    t.text     "markdown"
    t.integer  "number"
    t.string   "aasm_state"
    t.integer  "comments_count",   default: 0
  end

  create_table "preview_user_mentions", force: :cascade do |t|
    t.integer  "user_id",     null: false
    t.integer  "preview_id",  null: false
    t.string   "username",    null: false
    t.integer  "start_index", null: false
    t.integer  "end_index",   null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "preview_user_mentions", ["preview_id"], name: "index_preview_user_mentions_on_preview_id", using: :btree
  add_index "preview_user_mentions", ["user_id"], name: "index_preview_user_mentions_on_user_id", using: :btree

  create_table "previews", force: :cascade do |t|
    t.text     "body",       null: false
    t.text     "markdown",   null: false
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "previews", ["user_id"], name: "index_previews_on_user_id", using: :btree

  create_table "project_categories", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "project_categories", ["project_id", "category_id"], name: "index_project_categories_on_project_id_and_category_id", unique: true, using: :btree

  create_table "project_roles", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "project_roles", ["project_id", "role_id"], name: "index_project_roles_on_project_id_and_role_id", unique: true, using: :btree

  create_table "project_skills", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "skill_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "project_skills", ["project_id", "skill_id"], name: "index_project_skills_on_project_id_and_skill_id", unique: true, using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "title",                                 null: false
    t.string   "description"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.text     "base64_icon_data"
    t.string   "slug",                                  null: false
    t.integer  "organization_id",                       null: false
    t.string   "aasm_state"
    t.text     "long_description_body"
    t.text     "long_description_markdown"
    t.integer  "open_posts_count",          default: 0, null: false
    t.integer  "closed_posts_count",        default: 0, null: false
  end

  add_index "projects", ["organization_id"], name: "index_projects_on_organization_id", using: :btree

  create_table "role_skills", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "skill_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "cat"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name",       null: false
    t.string   "ability",    null: false
    t.string   "kind",       null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string   "title",        null: false
    t.string   "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "original_row"
    t.string   "slug",         null: false
  end

  add_index "skills", ["slug"], name: "index_skills_on_slug", unique: true, using: :btree

  create_table "slugged_routes", force: :cascade do |t|
    t.string   "slug",       null: false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "slugged_routes", ["owner_id", "owner_type"], name: "index_slugged_routes_on_owner_id_and_owner_type", unique: true, using: :btree
  add_index "slugged_routes", ["slug"], name: "index_slugged_routes_on_slug", unique: true, using: :btree

  create_table "user_categories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "user_categories", ["user_id", "category_id"], name: "index_user_categories_on_user_id_and_category_id", unique: true, using: :btree

  create_table "user_relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "following_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "user_relationships", ["follower_id"], name: "index_user_relationships_on_follower_id", using: :btree
  add_index "user_relationships", ["following_id"], name: "index_user_relationships_on_following_id", using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_skills", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "skill_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "email",                                                   null: false
    t.string   "encrypted_password",    limit: 128,                       null: false
    t.string   "confirmation_token",    limit: 128
    t.string   "remember_token",        limit: 128,                       null: false
    t.string   "username"
    t.boolean  "admin",                             default: false,       null: false
    t.text     "website"
    t.string   "twitter"
    t.text     "biography"
    t.string   "facebook_id"
    t.string   "facebook_access_token"
    t.string   "base64_photo_data"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "aasm_state",                        default: "signed_up", null: false
    t.string   "theme",                             default: "light",     null: false
    t.text     "first_name"
    t.text     "last_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "posts", "projects"
  add_foreign_key "posts", "users"
  add_foreign_key "preview_user_mentions", "previews"
  add_foreign_key "preview_user_mentions", "users"
  add_foreign_key "previews", "users"
  add_foreign_key "project_categories", "categories", on_delete: :cascade
  add_foreign_key "project_categories", "projects", on_delete: :cascade
  add_foreign_key "project_roles", "projects", on_delete: :cascade
  add_foreign_key "project_roles", "roles", on_delete: :cascade
  add_foreign_key "project_skills", "projects", on_delete: :cascade
  add_foreign_key "project_skills", "skills", on_delete: :cascade
  add_foreign_key "projects", "organizations"
  add_foreign_key "user_categories", "categories", on_delete: :cascade
  add_foreign_key "user_categories", "users", on_delete: :cascade
end
