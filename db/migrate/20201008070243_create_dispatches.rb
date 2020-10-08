class CreateDispatches < ActiveRecord::Migration[6.0]
  def change
    create_table :dispatches do |t|
      t.belongs_to :message, null: false, foreign_key: { on_delete: :cascade }
      t.string :phone, null: false
      t.integer :messenger_type, null: false, index: true
      t.datetime :send_at
      t.integer :status, null: false, default: 0, index: true

      t.timestamps
    end
    add_index :dispatches, [:message_id, :phone, :messenger_type], unique: true
  end
end
