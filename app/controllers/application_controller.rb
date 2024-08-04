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

  helper_method :get_pending_move_line
  def get_pending_move_line(game, move, reflect_x, reflect_y)
    square_rem = 4

    src_x, src_y = game.idx_to_xy(move.src)
    dest_x, dest_y = game.idx_to_xy(move.dest)

    src_x = (square_rem * src_x) + (square_rem / 2)
    src_y = (square_rem * src_y) + (square_rem / 2)

    dest_x = (square_rem * dest_x) + (square_rem / 2)
    dest_y = (square_rem * dest_y) + (square_rem / 2)

    board_size = game.board_size * square_rem

    diff_x = if reflect_x then src_x - dest_x else dest_x - src_x end
    diff_y = if reflect_y then src_y - dest_y else dest_y - src_y end
    top = if reflect_y then board_size - src_y else src_y end
    left = if reflect_x then board_size - src_x else src_x end

    length = Math.sqrt((diff_x ** 2) + (diff_y ** 2))
    angle = Math.atan2(diff_y, diff_x) * (180 / Math::PI)

    <<STR
width: #{length}rem;
transform: rotate(#{angle}deg);
top: #{top}rem;
left: #{left}rem;
STR
  end

end
