# frozen_string_literal: true

class GamesController < ApplicationController
  def create
    if params[:game] && params_valid?
      @game = Game.make!(creator: current_user, game_params: game_params)
      redirect_to(game_path(@game))
    else
      flash[:alert] = "flash.game_create_failure"
      redirect_to(:root)
    end
  end

  def show
    @game = Game.find(params[:id])
  end

  def params_valid?
    def param_valid?(param)
      Game.valid_form_options[param].include?(game_params[param]&.to_i)
    end

    [:number_of_players, :board_size, :turn_duration].all? { |p| param_valid?(p) } &&
      Game.valid_form_options[:play_as].include?(game_params[:play_as])
  end

  def homepage
    @new_game = Game.new
    @games = Game.where(current_turn: 0)
  end

  private

  def game_params
    params.require(:game).permit(:number_of_players, :board_size, :turn_duration, :play_as)
  end
end
