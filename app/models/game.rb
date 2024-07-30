# frozen_string_literal: true

class Game < ApplicationRecord
  VALID_TURN_DURATIONS = [5, 10, 15].freeze
  VALID_BOARD_SIZES = [8, 10, 12].freeze

  validates :turn_duration, presence: true, inclusion: { in: VALID_TURN_DURATIONS }
  validates :board_size, presence: true, inclusion: { in: VALID_BOARD_SIZES }
  validates :current_turn, presence: true

  belongs_to :top_white_player, class_name: "User", optional: true
  belongs_to :top_black_player, class_name: "User", optional: true
  belongs_to :bottom_white_player, class_name: "User", optional: true
  belongs_to :bottom_black_player, class_name: "User", optional: true

  validate :player_cannot_be_on_opposite_teams

  attribute :current_turn, default: 0

  scope :unstarted, -> { where(current_turn: 0) }
  scope :started, -> { where("current_turn > 0") }

  has_many :moves

  class NotSupportedYet < StandardError; end
  class MissingPlayAsParam < StandardError; end
  class NotEnoughPlayers < StandardError; end

  class << self
    def make!(creator:, game_params:)
      params = {
        board_size: game_params[:board_size],
        turn_duration: game_params[:turn_duration],
      }

      player_ids = if game_params[:number_of_players].to_i == 2
        {
          top_white_player_id: creator.id,
          top_black_player_id: creator.id,
        }
      else
        creator_color = if game_params[:play_as].nil?
          raise(MissingPlayAsParam)
        elsif game_params[:play_as] == RANDOM
          [WHITE, BLACK].sample
        else
          game_params[:play_as]
        end

        {
          :"top_#{creator_color}_player_id" => creator.id,
        }
      end

      Game.create!(params.merge(player_ids))
    end

    def valid_form_options
      {
        number_of_players: [2, 4],
        board_size: VALID_BOARD_SIZES,
        turn_duration: VALID_TURN_DURATIONS,
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
    if top_white_player_id && top_black_player_id && bottom_white_player_id && bottom_black_player_id
      self.update!(
        current_turn: 1,
        pieces: self.initial_pieces,
      )
    else
      missing_players = [
        (:top_white if top_white_player_id.nil?),
        (:bottom_white if bottom_white_player_id.nil?),
        (:top_black if top_black_player_id.nil?),
        (:bottom_black if bottom_black_player_id.nil?),
      ].compact.join(", ")
      raise(NotEnoughPlayers, "#{missing_players} need to be set")
    end
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
    @teams ||= {
      TOP    => User.where(id: [top_white_player_id, top_black_player_id]),
      BOTTOM => User.where(id: [bottom_white_player_id, bottom_black_player_id]),
    }
  end

  def players
    @players ||= User.where(id: [top_white_player, top_black_player, bottom_white_player, bottom_black_player])
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

  def player_cannot_be_on_opposite_teams
    [:top_white_player_id, :top_black_player_id].each do |top_player_id_column|
      player_id = self.send(top_player_id_column)

      if player_id
        if [bottom_white_player_id, bottom_black_player_id].include?(player_id)
          errors.add(top_player_id_column, "is also on BOTTOM")
        end
      end
    end

    [:bottom_white_player_id, :bottom_black_player_id].each do |bottom_player_id_column|
      player_id = self.send(bottom_player_id_column)

      if player_id
        if [top_white_player_id, top_black_player_id].include?(player_id)
          errors.add(bottom_player_id_column, "is also on TOP")
        end
      end
    end
  end
end
