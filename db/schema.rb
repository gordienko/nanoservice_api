# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_201_008_070_243) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'dispatches', force: :cascade do |t|
    t.bigint 'message_id', null: false
    t.string 'phone', null: false
    t.integer 'messenger_type', null: false
    t.datetime 'send_at'
    t.integer 'status', default: 0, null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[message_id phone messenger_type], name: 'index_dispatches_on_message_id_and_phone_and_messenger_type', unique: true
    t.index ['message_id'], name: 'index_dispatches_on_message_id'
    t.index ['messenger_type'], name: 'index_dispatches_on_messenger_type'
    t.index ['status'], name: 'index_dispatches_on_status'
  end

  create_table 'messages', force: :cascade do |t|
    t.string 'body', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['body'], name: 'index_messages_on_body'
  end

  add_foreign_key 'dispatches', 'messages', on_delete: :cascade
end
