# frozen_string_literal: true

class Game < ApplicationRecord
  validates :turn_duration, presence: true
  validates :board_size, presence: true
  validates :current_turn, presence: true
  validate :pairs_have_unique_players

  has_many :pairs, dependent: :destroy

  attribute :current_turn, default: 0

  class NotSupportedYet < StandardError; end

  class << self
    def make!(creator:, game_params:)
      game = Game.create!(game_params.slice(:board_size, :turn_duration))

      pair_count = game_params[:number_of_players].to_i / 2
      pair_count.times do |idx|
        pair_params = if idx == 0
          creator_color = if game_params[:play_as] == RANDOM
            [WHITE, BLACK].sample
          else
            game_params[:play_as]
          end
          { "#{creator_color}_player_id" => creator.id }
        else
          {}
        end

        game.pairs.create!(pair_params)
      end

      game
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

  # The two players in a Pair are across from each other diagonally on the board:
  #
  # +-----------------------------+
  # |pair1,white       pair2,black|
  # |            \   /            |
  # |             \ /             |
  # |              X              |
  # |             / \             |
  # |            /   \            |
  # |pair2,white       pair1,black|
  # +-----------------------------+
  #
  # "TOP" and "BOTTOM" are probably not the best team names, because when the game board is rendered, it is flipped
  # vertically and horizontally so the current_user is always in the bottom-left corner.
  def teams
    top_players, bottom_players = {
      1 => [
        [self.pairs.first.white_player_id],
        [self.pairs.first.black_player_id],
      ],
      2 => [
        [self.pairs.first.white_player_id, self.pairs.last.black_player_id],
        [self.pairs.first.black_player_id, self.pairs.last.white_player_id],
      ],
    }[self.pairs.count] || raise(NotSupportedYet, "can't have more than 2 pairs (got #{self.pairs.count})")

    {
      TOP    => top_players.compact,
      BOTTOM => bottom_players.compact,
    }
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
