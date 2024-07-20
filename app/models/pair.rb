class Pair < ApplicationRecord
  validate :players_are_different

  belongs_to :white_player, class_name: "User"
  belongs_to :black_player, class_name: "User"

  belongs_to :game

  private

  def players_are_different
    if black_player_id && black_player_id == white_player_id
      errors.add(:base, "players must be different")
    end
  end
end
