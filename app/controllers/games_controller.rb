# frozen_string_literal: true

class GamesController < ApplicationController
  def create
    if params[:game] && params_valid?
      @game = Game.make(creator: current_user, game_params: game_params)
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
    @games = Game.where(current_turn: 0)
  end

  if Rails.env.development?
    def fen_tool_board
      @fen = Fen.new(10)
    end

    def fen_tool_update
      @fen = Fen.from_s(params[:fen])

      if params[:color]
        @fen.add_piece(
          params[:team],
          params[:color],
          params[:piece_kind],
          params[:square].to_i,
        )
      else
        @fen.remove_piece(params[:square].to_i)
      end

      Game.new.broadcast_fen({
        fen: @fen,
        selected_color: params[:color],
        selected_team: params[:team],
        selected_piece_kind: params[:piece_kind],
      })

      head :ok
    end
  end

  private

  def game_params
    params.require(:game).permit(:number_of_players, :board_size, :turn_duration, :play_as)
  end
end
