# frozen_string_literal: true

class Pair < ApplicationRecord
  validate :players_are_different

  # These are optional because a Game will be created with empty pairs, which will be populated when players join the
  # game.
  belongs_to :white_player, class_name: "User", optional: true
  belongs_to :black_player, class_name: "User", optional: true

  belongs_to :game

  private

  def players_are_different
    if black_player_id && black_player_id == white_player_id
      errors.add(:base, "players must be different")
    end
  end
end
