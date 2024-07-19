class CreatePairs < ActiveRecord::Migration[7.1]
  def change
    create_table :pairs do |t|
      t.belongs_to :white_player, foreign_key: { to_table: :users }
      t.belongs_to :black_player, foreign_key: { to_table: :users }

      t.belongs_to :game

      t.timestamps
    end
  end
end
