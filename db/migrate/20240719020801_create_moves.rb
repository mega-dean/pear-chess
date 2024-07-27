class CreateMoves < ActiveRecord::Migration[7.1]
  def change
    create_table :moves do |t|
      t.belongs_to :user
      t.belongs_to :game

      t.integer :turn
      t.integer :src
      t.integer :dest

      t.timestamps
    end
  end
end
