class CreateMoves < ActiveRecord::Migration[7.1]
  def change
    create_table :moves do |t|
      t.belongs_to :user
      t.belongs_to :game

      t.integer :turn
      t.integer :src_square
      t.integer :dest_square

      t.timestamps
    end
  end
end
