# frozen_string_literal: true

class Move < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :turn, presence: true
  validates :src_square, presence: true
  validates :dest_square, presence: true

  class << self
    def make(game:, user:, params:)
      src_square = (params[:src_square_y].to_i * game.board_size) + params[:src_square_x].to_i
      dest_square = (params[:dest_square_y].to_i * game.board_size) + params[:dest_square_x].to_i

      Move.create!(
        game: game,
        turn: game.current_turn,
        user: user,
        src_square: src_square,
        dest_square: dest_square,
      )
    end
  end
end
