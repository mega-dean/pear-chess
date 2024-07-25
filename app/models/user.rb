# frozen_string_literal: true

class User < ApplicationRecord
  include Clearance::User

  validates :username, presence: true, uniqueness: true

  def team(game)
    team, _ = game.teams.find do |_, player_ids|
      player_ids.include?(self.id)
    end

    team
  end

  def playing_in?(game)
    !!self.color(game)
  end

  def color(game)
    if game.pairs.count == 1
      # If the game is only 2-player, then each player plays as both white and black.
      WHITE
    else
      game.pairs.each do |pair|
        if pair.white_player_id == self.id
          return WHITE
        elsif pair.black_player_id == self.id
          return BLACK
        end
      end
    end
  end
end
