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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150102152312) do

  create_table "available_queues", :force => true do |t|
    t.integer  "reservation_id", :null => false
    t.integer  "member_id",      :null => false
    t.integer  "library_id",     :null => false
    t.integer  "book_id",        :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "books", :force => true do |t|
    t.integer  "isbn",       :null => false
    t.integer  "quantity",   :null => false
    t.integer  "library_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "lend_queues", :force => true do |t|
    t.integer  "reservation_id", :null => false
    t.integer  "member_id",      :null => false
    t.integer  "library_id",     :null => false
    t.integer  "book_id",        :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "libraries", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "url",        :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "members", :force => true do |t|
    t.integer  "user_id"
    t.integer  "library_id"
    t.string   "name"
    t.string   "email"
    t.string   "hashed_password"
    t.boolean  "admin",           :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "notices", :force => true do |t|
    t.string   "title"
    t.string   "body"
    t.date     "released_at", :null => false
    t.integer  "library_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "reservations", :force => true do |t|
    t.integer  "book_id"
    t.integer  "member_id"
    t.date     "lend_date"
    t.date     "return_date"
    t.integer  "library_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "reserve_queues", :force => true do |t|
    t.integer  "reservation_id",                    :null => false
    t.integer  "member_id",                         :null => false
    t.integer  "library_id",                        :null => false
    t.integer  "book_id",                           :null => false
    t.boolean  "authority",      :default => false, :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

end
