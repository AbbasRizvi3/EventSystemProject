class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.timestamps
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false, default: ""
      t.text :body, null: false, default: ""
      t.string :notification_type, null: false
      t.boolean :read, default: false
    end
  end
end
