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

ActiveRecord::Schema.define(version: 20140530130354) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "account_settings", force: true do |t|
    t.string   "admin_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.string   "from_address"
    t.string   "shop_name"
    t.string   "shop_url"
  end

  add_index "account_settings", ["account_id"], name: "index_account_settings_on_account_id", using: :btree

  create_table "accounts", force: true do |t|
    t.string   "insales_id",        null: false
    t.string   "insales_password",  null: false
    t.string   "insales_subdomain", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "sync_settings"
    t.json     "tariff_data"
    t.string   "tariff_id"
  end

  add_index "accounts", ["insales_id"], name: "index_accounts_on_insales_id", unique: true, using: :btree
  add_index "accounts", ["insales_subdomain"], name: "index_accounts_on_insales_subdomain", unique: true, using: :btree

  create_table "categories", force: true do |t|
    t.integer  "insales_id",        null: false
    t.integer  "parent_id"
    t.integer  "insales_parent_id"
    t.integer  "position"
    t.string   "title"
    t.integer  "account_id",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["account_id"], name: "index_categories_on_account_id", using: :btree
  add_index "categories", ["insales_id"], name: "index_categories_on_insales_id", using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree

  create_table "fields", force: true do |t|
    t.integer  "insales_id",       null: false
    t.boolean  "active",           null: false
    t.integer  "destiny",          null: false
    t.boolean  "for_buyer",        null: false
    t.boolean  "obligatory",       null: false
    t.string   "office_title",     null: false
    t.integer  "position",         null: false
    t.boolean  "show_in_checkout", null: false
    t.boolean  "show_in_result",   null: false
    t.string   "system_name"
    t.string   "title"
    t.string   "example"
    t.integer  "account_id",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fields_values", force: true do |t|
    t.integer  "field_id",         null: false
    t.integer  "owner_id",         null: false
    t.integer  "insales_field_id", null: false
    t.string   "name",             null: false
    t.text     "value"
    t.integer  "account_id",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "insales_id",       null: false
  end

  create_table "images", force: true do |t|
    t.integer  "insales_id",         null: false
    t.integer  "product_id",         null: false
    t.integer  "insales_product_id", null: false
    t.string   "title"
    t.integer  "position"
    t.string   "original_url",       null: false
    t.integer  "account_id",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["account_id"], name: "index_images_on_account_id", using: :btree
  add_index "images", ["insales_id"], name: "index_images_on_insales_id", using: :btree
  add_index "images", ["product_id"], name: "index_images_on_product_id", using: :btree

  create_table "orders", force: true do |t|
    t.integer  "insales_id",                  null: false
    t.date     "accepted_at"
    t.text     "comment"
    t.text     "current_location"
    t.date     "delivered_at"
    t.date     "delivery_date"
    t.text     "delivery_description"
    t.integer  "delivery_from_hour"
    t.integer  "delivery_to_hour"
    t.decimal  "delivery_price"
    t.text     "delivery_title"
    t.integer  "insales_delivery_variant_id"
    t.string   "financial_status"
    t.string   "fulfillment_status"
    t.string   "key"
    t.decimal  "margin"
    t.integer  "number",                      null: false
    t.date     "paid_at"
    t.text     "payment_description"
    t.integer  "insales_payment_gateway_id",  null: false
    t.string   "payment_title"
    t.text     "referer"
    t.decimal  "items_price",                 null: false
    t.decimal  "total_price",                 null: false
    t.decimal  "full_delivery_price",         null: false
    t.integer  "account_id",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "cookies"
  end

  create_table "products", force: true do |t|
    t.integer  "insales_id",                  null: false
    t.string   "title",                       null: false
    t.boolean  "available",                   null: false
    t.integer  "canonical_url_collection_id"
    t.integer  "category_id"
    t.integer  "insales_category_id"
    t.text     "description"
    t.text     "html_title"
    t.boolean  "is_hidden",                   null: false
    t.text     "meta_description"
    t.text     "meta_keywords"
    t.string   "permalink"
    t.text     "short_description"
    t.integer  "account_id",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "products", ["account_id"], name: "index_products_on_account_id", using: :btree
  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["insales_id"], name: "index_products_on_insales_id", using: :btree

  create_table "variants", force: true do |t|
    t.string   "title"
    t.string   "sku"
    t.integer  "insales_id",         null: false
    t.integer  "product_id",         null: false
    t.integer  "insales_product_id", null: false
    t.decimal  "cost_price"
    t.decimal  "old_price"
    t.decimal  "price"
    t.integer  "quantity"
    t.decimal  "weight"
    t.integer  "account_id",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "variants", ["account_id"], name: "index_variants_on_account_id", using: :btree
  add_index "variants", ["insales_id"], name: "index_variants_on_insales_id", using: :btree
  add_index "variants", ["product_id"], name: "index_variants_on_product_id", using: :btree

end
