class GamesController < ApplicationController
  def create
    @game = Game.create!(
      board_size: params[:board_size],
      turn_duration: params[:turn_duration],
    )

    redirect_to(game_path(@game))
  end

  def homepage
    @new_game = Game.new

    @games = Game.all
  end
end
