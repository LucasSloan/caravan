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

ActiveRecord::Schema.define(version: 20140416051902) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "follow_requests", force: true do |t|
    t.integer  "requester"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follow_requests", ["user_id"], name: "index_follow_requests_on_user_id", using: :btree

  create_table "followers", force: true do |t|
    t.integer  "follower_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "followers", ["user_id"], name: "index_followers_on_user_id", using: :btree

  create_table "positions", force: true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "timestamp"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "positions", ["user_id"], name: "index_positions_on_user_id", using: :btree

  create_table "recently_followeds", force: true do |t|
    t.integer  "followed"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recently_followeds", ["user_id"], name: "index_recently_followeds_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.text     "locations"
    t.boolean  "broadcasting"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "auth_token"
  end

  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end
