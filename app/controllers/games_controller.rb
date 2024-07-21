class GamesController < ApplicationController
  def create
    if params_valid?
      pair_count = game_params[:number_of_players].to_i / 2
      @game = Game.make(pair_count: pair_count, creator: current_user, game_params: game_params)
      redirect_to(game_path(@game))
    else
      flash[:alert] = "flash.game_create_failure"
      redirect_to(:root)
    end
  end

  def params_valid?
    Game.valid_form_options[:number_of_players].include?(game_params[:number_of_players]&.to_i) &&
      Game.valid_form_options[:board_size].include?(game_params[:board_size]&.to_i) &&
      Game.valid_form_options[:turn_duration].include?(game_params[:turn_duration]&.to_i) &&
      Game.valid_form_options[:play_as].include?(game_params[:play_as])
  end

  def homepage
    @new_game = Game.new

    @games = Game.all
  end

  private

  def game_params
    params.require(:game).permit(:number_of_players, :board_size, :turn_duration, :play_as)
  end
end
