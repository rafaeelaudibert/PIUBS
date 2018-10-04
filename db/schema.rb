# frozen_string_literal: true

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

ActiveRecord::Schema.define(version: 2018_09_25_164101) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'fuzzystrmatch'
  enable_extension 'pg_trgm'
  enable_extension 'plpgsql'
  enable_extension 'unaccent'

  create_table 'answers', force: :cascade do |t|
    t.text 'question'
    t.text 'answer'
    t.bigint 'category_id'
    t.bigint 'user_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'faq', default: false
    t.string 'keywords'
    t.index ['category_id'], name: 'index_answers_on_category_id'
    t.index ['user_id'], name: 'index_answers_on_user_id'
  end

  create_table 'attachment_links', force: :cascade do |t|
    t.bigint 'answer_id'
    t.bigint 'reply_id'
    t.bigint 'call_id'
    t.integer 'source'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'attachment_id'
    t.index ['answer_id'], name: 'index_attachment_links_on_answer_id'
    t.index ['call_id'], name: 'index_attachment_links_on_call_id'
    t.index ['reply_id'], name: 'index_attachment_links_on_reply_id'
  end

  create_table 'attachments', force: :cascade do |t|
    t.string 'filename'
    t.string 'content_type'
    t.binary 'file_contents'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'calls', force: :cascade do |t|
    t.string 'title'
    t.text 'description'
    t.datetime 'finished_at'
    t.integer 'status'
    t.string 'version'
    t.string 'access_profile'
    t.string 'feature_detail'
    t.string 'answer_summary'
    t.string 'protocol'
    t.bigint 'city_id'
    t.bigint 'category_id'
    t.bigint 'state_id'
    t.integer 'sei'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'user_id'
    t.bigint 'answer_id'
    t.integer 'cnes'
    t.integer 'support_user'
    t.integer 'severity'
    t.index ['answer_id'], name: 'index_calls_on_answer_id'
    t.index ['category_id'], name: 'index_calls_on_category_id'
    t.index ['city_id'], name: 'index_calls_on_city_id'
    t.index ['state_id'], name: 'index_calls_on_state_id'
    t.index ['user_id'], name: 'index_calls_on_user_id'
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.integer "parent_depth", default: 0
    t.integer "severity"
  end

  create_table 'cities', force: :cascade do |t|
    t.string 'name'
    t.bigint 'state_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['state_id'], name: 'index_cities_on_state_id'
  end

  create_table 'companies', id: false, force: :cascade do |t|
    t.integer 'sei'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['sei'], name: 'index_companies_on_sei', unique: true
  end

  create_table 'contracts', force: :cascade do |t|
    t.integer 'contract_number'
    t.bigint 'city_id'
    t.integer 'sei'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'filename'
    t.string 'content_type'
    t.binary 'file_contents'
    t.index ['city_id'], name: 'index_contracts_on_city_id'
  end

  create_table 'replies', force: :cascade do |t|
    t.string 'protocol'
    t.text 'description'
    t.bigint 'user_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'status'
    t.string 'category'
    t.boolean 'faq', default: false
    t.index ['user_id'], name: 'index_replies_on_user_id'
  end

  create_table 'states', force: :cascade do |t|
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'abbr'
  end

  create_table 'unities', id: false, force: :cascade do |t|
    t.integer 'cnes', null: false
    t.string 'name'
    t.bigint 'city_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'address'
    t.string 'neighborhood'
    t.string 'phone'
    t.index ['city_id'], name: 'index_unities_on_city_id'
    t.index ['cnes'], name: 'index_unities_on_cnes', unique: true
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer 'sign_in_count', default: 0, null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.inet 'current_sign_in_ip'
    t.inet 'last_sign_in_ip'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'name'
    t.string 'confirmation_token'
    t.datetime 'confirmed_at'
    t.datetime 'confirmation_sent_at'
    t.string 'unconfirmed_email'
    t.integer 'role'
    t.string 'invitation_token'
    t.datetime 'invitation_created_at'
    t.datetime 'invitation_sent_at'
    t.datetime 'invitation_accepted_at'
    t.integer 'invitation_limit'
    t.string 'invited_by_type'
    t.bigint 'invited_by_id'
    t.integer 'invitations_count', default: 0
    t.integer 'sei'
    t.string 'cpf'
    t.bigint 'city_id'
    t.integer 'cnes'
    t.string 'last_name'
    t.index ['city_id'], name: 'index_users_on_city_id'
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['invitation_token'], name: 'index_users_on_invitation_token', unique: true
    t.index ['invitations_count'], name: 'index_users_on_invitations_count'
    t.index ['invited_by_id'], name: 'index_users_on_invited_by_id'
    t.index %w[invited_by_type invited_by_id], name: 'index_users_on_invited_by_type_and_invited_by_id'
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  add_foreign_key 'answers', 'categories'
  add_foreign_key 'answers', 'users'
  add_foreign_key 'attachment_links', 'attachments'
  add_foreign_key 'calls', 'answers'
  add_foreign_key 'calls', 'categories'
  add_foreign_key 'calls', 'cities'
  add_foreign_key 'calls', 'companies', column: 'sei', primary_key: 'sei'
  add_foreign_key 'calls', 'states'
  add_foreign_key 'calls', 'unities', column: 'cnes', primary_key: 'cnes'
  add_foreign_key 'calls', 'users'
  add_foreign_key 'calls', 'users', column: 'support_user'
  add_foreign_key 'cities', 'states'
  add_foreign_key 'contracts', 'cities'
  add_foreign_key 'contracts', 'companies', column: 'sei', primary_key: 'sei'
  add_foreign_key 'replies', 'users'
  add_foreign_key 'unities', 'cities'
  add_foreign_key 'users', 'cities'
  add_foreign_key 'users', 'companies', column: 'sei', primary_key: 'sei'
  add_foreign_key 'users', 'unities', column: 'cnes', primary_key: 'cnes'
end
