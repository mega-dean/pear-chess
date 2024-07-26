# frozen_string_literal: true

class MovesController < ApplicationController
  def create
    game = Game.find(move_params[:game_id])

    if current_user.playing_in?(game)
      if game.current_color == move_params[:color]
        Move.make!(
          game: game,
          user: current_user,
          params: move_params.slice(:src_x, :src_y, :dest_x, :dest_y),
        )
      end
    end

    # The move may not be created in the following cases:
    # - current_user is not in this game
    # - src or dest are invalid
    # - not this move color's turn
    #
    # The first two should never be sent by the UI, so they would only happen with hand-written requests. They will
    # raise an error from Move validations, so the response would be non-200. The third one can probably happen to users
    # with unlucky timing: they submit the move right before the deadline, but it arrives at the server right after the
    # deadline. But there's no reason to show an error message in that case since they won't ever see a pending move.
    head :ok
  end

  private

  def move_params
    params.require(:move).permit(:game_id, :color, :src_x, :src_y, :dest_x, :dest_y)
  end
end
