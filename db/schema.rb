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

ActiveRecord::Schema.define(version: 2021_12_03_013708) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "boleto_settings", force: :cascade do |t|
    t.string "agency_number"
    t.string "account_number"
    t.string "bank_code"
    t.integer "company_id", null: false
    t.integer "payment_method_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "token"
    t.integer "status", default: 5
    t.index ["company_id"], name: "index_boleto_settings_on_company_id"
    t.index ["payment_method_id"], name: "index_boleto_settings_on_payment_method_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "cnpj"
    t.string "legal_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 0
    t.string "billing_email"
    t.text "billing_address"
    t.string "token", default: ""
  end

  create_table "credit_card_settings", force: :cascade do |t|
    t.string "company_code"
    t.integer "company_id", null: false
    t.integer "payment_method_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "token"
    t.integer "status", default: 5
    t.index ["company_id"], name: "index_credit_card_settings_on_company_id"
    t.index ["payment_method_id"], name: "index_credit_card_settings_on_payment_method_id"
  end

  create_table "customer_payment_methods", force: :cascade do |t|
    t.integer "type_of"
    t.string "credit_card_name"
    t.string "credit_card_number"
    t.date "credit_card_expiration_date"
    t.string "credit_card_security_code"
    t.integer "company_id", null: false
    t.integer "customer_id", null: false
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "pix_setting_id"
    t.integer "boleto_setting_id"
    t.integer "credit_card_setting_id"
    t.index ["boleto_setting_id"], name: "index_customer_payment_methods_on_boleto_setting_id"
    t.index ["company_id"], name: "index_customer_payment_methods_on_company_id"
    t.index ["credit_card_setting_id"], name: "index_customer_payment_methods_on_credit_card_setting_id"
    t.index ["customer_id"], name: "index_customer_payment_methods_on_customer_id"
    t.index ["pix_setting_id"], name: "index_customer_payment_methods_on_pix_setting_id"
  end

  create_table "customer_subscriptions", force: :cascade do |t|
    t.string "token"
    t.integer "status", default: 0
    t.decimal "cost"
    t.integer "renovation_date", default: 1
    t.integer "product_id", null: false
    t.integer "customer_payment_method_id", null: false
    t.integer "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "retry_date"
    t.integer "tried_renew_times", default: 0
    t.index ["company_id"], name: "index_customer_subscriptions_on_company_id"
    t.index ["customer_payment_method_id"], name: "index_customer_subscriptions_on_customer_payment_method_id"
    t.index ["product_id"], name: "index_customer_subscriptions_on_product_id"
    t.index ["token"], name: "index_customer_subscriptions_on_token", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "cpf"
    t.string "token"
    t.integer "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_customers_on_company_id"
  end

  create_table "frauds", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "purchase_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["purchase_id"], name: "index_frauds_on_purchase_id", unique: true
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "name"
    t.decimal "fee"
    t.decimal "maximum_fee"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status", default: 5
    t.integer "type_of", default: 0
  end

  create_table "pix_settings", force: :cascade do |t|
    t.string "pix_key"
    t.string "bank_code"
    t.integer "company_id", null: false
    t.integer "payment_method_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "token"
    t.integer "status", default: 5
    t.index ["company_id"], name: "index_pix_settings_on_company_id"
    t.index ["payment_method_id"], name: "index_pix_settings_on_payment_method_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.integer "status", default: 5
    t.integer "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "type_of", default: 0
    t.index ["company_id"], name: "index_products_on_company_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.string "token"
    t.integer "customer_payment_method_id", null: false
    t.integer "product_id", null: false
    t.decimal "cost"
    t.integer "receipt_id"
    t.date "paid_date"
    t.date "expiration_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "company_id", null: false
    t.integer "status", default: 0
    t.index ["company_id"], name: "index_purchases_on_company_id"
    t.index ["customer_payment_method_id"], name: "index_purchases_on_customer_payment_method_id"
    t.index ["product_id"], name: "index_purchases_on_product_id"
    t.index ["receipt_id"], name: "index_purchases_on_receipt_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.integer "purchase_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "authorization_code"
    t.string "token"
    t.index ["purchase_id"], name: "index_receipts_on_purchase_id"
  end

  create_table "rejected_companies", force: :cascade do |t|
    t.integer "company_id", null: false
    t.text "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_rejected_companies_on_company_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "company_id"
    t.boolean "owner"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "boleto_settings", "companies"
  add_foreign_key "boleto_settings", "payment_methods"
  add_foreign_key "credit_card_settings", "companies"
  add_foreign_key "credit_card_settings", "payment_methods"
  add_foreign_key "customer_payment_methods", "boleto_settings"
  add_foreign_key "customer_payment_methods", "companies"
  add_foreign_key "customer_payment_methods", "credit_card_settings"
  add_foreign_key "customer_payment_methods", "customers"
  add_foreign_key "customer_payment_methods", "pix_settings"
  add_foreign_key "customer_subscriptions", "companies"
  add_foreign_key "customer_subscriptions", "customer_payment_methods"
  add_foreign_key "customer_subscriptions", "products"
  add_foreign_key "customers", "companies"
  add_foreign_key "frauds", "purchases"
  add_foreign_key "pix_settings", "companies"
  add_foreign_key "pix_settings", "payment_methods"
  add_foreign_key "products", "companies"
  add_foreign_key "purchases", "companies"
  add_foreign_key "purchases", "customer_payment_methods"
  add_foreign_key "purchases", "products"
  add_foreign_key "purchases", "receipts"
  add_foreign_key "receipts", "purchases"
  add_foreign_key "rejected_companies", "companies"
  add_foreign_key "users", "companies"
end
