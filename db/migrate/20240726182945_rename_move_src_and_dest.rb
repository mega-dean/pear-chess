class RenameMoveSrcAndDest < ActiveRecord::Migration[7.1]
  def change
    rename_column :moves, :src_square, :src
    rename_column :moves, :dest_square, :dest
  end
end
