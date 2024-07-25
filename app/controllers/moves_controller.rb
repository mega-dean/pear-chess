class MovesController < ApplicationController
  def create
    game = Game.find(params[:game_id])

    if game.current_color == params[:color]
      Move.make(
        game: game,
        user: current_user,
        params: params.slice(:src_square_x, :src_square_y, :dest_square_x, :dest_square_y)
      )
    end

    head :ok
  end
end
