class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.integer :turn_duration # in seconds
      t.integer :current_turn

      t.references :top_white_player, index: true, foreign_key: { to_table: :users }
      t.references :top_black_player, index: true, foreign_key: { to_table: :users }
      t.references :bottom_white_player, index: true, foreign_key: { to_table: :users }
      t.references :bottom_black_player, index: true, foreign_key: { to_table: :users }

      # This assumes width == height, but that might change.
      t.integer :board_size

      # This is the same format as the first field in FEN.
      t.string :pieces

      t.boolean :processing_moves

      t.timestamps
    end
  end
end
