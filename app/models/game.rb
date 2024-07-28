# frozen_string_literal: true

class Game < ApplicationRecord
  validates :turn_duration, presence: true
  validates :board_size, presence: true
  validates :current_turn, presence: true
  validate :pairs_have_unique_players

  belongs_to :top_white_player, class_name: "User", optional: true
  belongs_to :top_black_player, class_name: "User", optional: true
  belongs_to :bottom_white_player, class_name: "User", optional: true
  belongs_to :bottom_black_player, class_name: "User", optional: true

  has_many :pairs, dependent: :destroy

  attribute :current_turn, default: 0

  class NotSupportedYet < StandardError; end

  class << self
    def make!(creator:, game_params:)
      creator_color = if game_params[:play_as] == RANDOM
        [WHITE, BLACK].sample
      else
        game_params[:play_as]
      end

      params = {
        "board_size"                     => game_params[:board_size],
        "turn_duration"                  => game_params[:turn_duration],
        "top_#{creator_color}_player_id" => creator.id,
      }

      if game_params[:number_of_players].to_i == 2
        opposite_color = {
          WHITE => BLACK,
          BLACK => WHITE,
        }[creator_color]

        params.merge!({
          "top_#{opposite_color}_player_id" => creator.id,
        })
      end

      Game.create!(params)
    end

    def valid_form_options
      {
        number_of_players: [2, 4],
        board_size: [8, 10, 12],
        turn_duration: [5, 10, 15],
        play_as: [WHITE, BLACK, RANDOM],
      }
    end

    def xy_to_idx(x, y, board_size)
      new(board_size: board_size).xy_to_idx(x, y)
    end

    def idx_to_xy(idx, board_size)
      new(board_size: board_size).idx_to_xy(idx)
    end

    if Rails.env.development?
      def dev_game_ids
        []
      end
    end
  end

  def broadcast_fen(locals)
    broadcast_replace_to(
      "fen-tool-container",
      target: "fen-tool-container",
      partial: "fen_tool/board",
      locals: locals,
    )
  end

  def fen
    if self.pieces
      Fen.from_s(self.pieces)
    end
  end

  def initial_pieces
    {
      8  => "KRN2nrk/IIN2nii/NNN2nnn/8/8/MMM2mmm/JJM2mjj/LSM2msl",
      10 => "KQRN2nrqk/IRNN2nnri/INN4nni/NN6nn/a/a/MM6mm/JMM4mmj/JSMM2mmsj/LUSM2msul",
      12 => "KQIRN2nriqk/IIRNN2nnrii/IINN4nnii/INN6nni/NN8nn/c/c/MM8mm/JMM6mmj/JJMM4mmjj/JJSMM2mmsjj/LUJSM2msjul",
    }[self.board_size]
  end

  def start!
    self.update!(
      current_turn: 1,
      pieces: self.initial_pieces,
    )
  end

  def ids(player)
    [
      (:top_white if top_white_player_id == player.id),
      (:bottom_white if bottom_white_player_id == player.id),
      (:top_black if top_black_player_id == player.id),
      (:bottom_black if bottom_black_player_id == player.id),
    ].compact
  end

  def teams
    {
      TOP    => User.where(id: [top_white_player_id, top_black_player_id]),
      BOTTOM => User.where(id: [bottom_white_player_id, bottom_black_player_id]),
    }
  end

  def players
    User.where(id: [top_white_player, top_black_player, bottom_white_player, bottom_black_player])
  end

  def current_color
    if self.current_turn > 0
      if self.current_turn.odd?
        WHITE
      else
        BLACK
      end
    end
  end

  def idx_to_xy(idx)
    [idx % board_size, idx / board_size]
  end

  def xy_to_idx(x, y)
    (y * board_size) + x
  end

  private

  def pairs_have_unique_players
    player_ids = Set.new

    self.pairs.each do |pair|
      if pair.white_player_id
        if player_ids.include?(pair.white_player_id)
          errors.add(:base, "Pair #{pair.id}: white_player_id #{pair.white_player_id} is already part of this game")
        else
          player_ids.add(pair.white_player_id)
        end
      end

      if pair.black_player_id
        if player_ids.include?(pair.black_player_id)
          errors.add(:base, "Pair #{pair.id}: black_player_id #{pair.black_player_id} is already part of this game")
        else
          player_ids.add(pair.black_player_id)
        end
      end
    end
  end
end
