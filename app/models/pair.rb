class Pair < ApplicationRecord
  validates :white_player_id, presence: true
  validates :black_player_id, presence: true

  belongs_to :white_player, class_name: "User"
  belongs_to :black_player, class_name: "User"

  belongs_to :game
end
