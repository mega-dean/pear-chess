class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.integer :turn_duration # in seconds
      t.integer :current_turn

      # This assumes width == height, but that might change.
      t.integer :board_size

      t.boolean :processing_moves

      t.timestamps
    end
  end
end
