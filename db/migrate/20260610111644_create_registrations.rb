class CreateRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :registrations do |t|
      t.timestamps
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
    end
      add_index :registrations, [ :user_id, :event_id ], unique: true
  end
end
