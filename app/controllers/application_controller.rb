# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Clearance::Controller
  helper_method :get_reflection
  def get_reflection(game, player)
    player_color = if game.players.count == 2
      WHITE
    else
      player.colors(game).first
    end

    reflect_x = player_color != WHITE
    reflect_y = player.team(game) == TOP

    [reflect_x, reflect_y]
  end
end
