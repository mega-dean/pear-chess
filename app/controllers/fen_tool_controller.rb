# frozen_string_literal: true

class FenToolController < ApplicationController
  if Rails.env.development?
    def board
      @fen = Fen.new(params[:size].to_i)
    end

    def update
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
end
