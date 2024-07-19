class Move < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :turn, presence: true
  validates :src_square, presence: true
  validates :dest_square, presence: true
end
