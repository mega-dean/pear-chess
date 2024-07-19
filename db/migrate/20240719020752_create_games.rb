class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      # For 1v1 games, white_player_1 and black_player_1 will be the same user_id. For 2v2 games, they will be
      # different.
      t.bigint :white_player_1_id
      t.bigint :black_player_1_id
      t.bigint :white_player_2_id
      t.bigint :black_player_2_id

      t.integer :turn_duration # in seconds
      t.integer :current_turn

      # This assumes width == height, but that might change.
      t.integer :board_size

      t.boolean :processing_moves

      t.timestamps
    end
  end
end
