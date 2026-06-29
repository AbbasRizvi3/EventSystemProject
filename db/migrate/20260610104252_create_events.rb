class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.timestamps
      t.string :title, null: false
      t.text :description
      t.string :location, null: false
      t.timestamp :start_time, null: false
      t.timestamp :end_time, null: false
      t.integer :capacity, null: false
      t.integer :status, null: false, default: 0

      t.references :user, null: false, foreign_key: true
    end

    add_index :events, :title, unique: true
  end
end
