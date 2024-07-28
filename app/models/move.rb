# frozen_string_literal: true

class Move < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :turn, presence: true
  validates :src, presence: true
  validates :dest, presence: true

  validate :src_is_valid_piece
  validate :dest_is_valid_target

  class << self
    def make!(game:, user:, params:)
      src_idx = game.xy_to_idx(params[:src_x].to_i, params[:src_y].to_i)
      dest_idx = game.xy_to_idx(params[:dest_x].to_i, params[:dest_y].to_i)

      existing_move = Move.find_by(
        game: game,
        turn: game.current_turn,
        user: user,
        src: src_idx,
      )

      if existing_move
        existing_move.update!(dest: dest_idx)
      else
        Move.create!(
          game: game,
          turn: game.current_turn,
          user: user,
          src: src_idx,
          dest: dest_idx,
        )
      end
    end
  end

  private

  def src_is_valid_piece
    src_x, src_y = self.src_xy
    team, color, _ = self.get_piece

    if !team
      errors.add(:src, "no piece at (#{src_x}, #{src_y})")
    else
      if team != self.user.team(self.game)
        errors.add(:src, "not the user's team")
      end

      if self.game.players.count == 4
        if !self.user.colors(self.game).include?(color)
          errors.add(:src, "not the user's color")
        end
      end

      if color != self.game.current_color
        errors.add(:src, "not the user's turn")
      end
    end
  end

  def get_knight_targets
    src_x, src_y = self.src_xy

    [
      self.game.xy_to_idx(src_x + 1, src_y + 2),
      self.game.xy_to_idx(src_x + 1, src_y - 2),
      self.game.xy_to_idx(src_x - 1, src_y + 2),
      self.game.xy_to_idx(src_x - 1, src_y - 2),
      self.game.xy_to_idx(src_x + 2, src_y + 1),
      self.game.xy_to_idx(src_x + 2, src_y - 1),
      self.game.xy_to_idx(src_x - 2, src_y + 1),
      self.game.xy_to_idx(src_x - 2, src_y - 1),
    ]
  end

  def get_rook_targets
    up = get_targets_in_direction({ y: -1 })
    down = get_targets_in_direction({ y: 1 })
    left = get_targets_in_direction({ x: -1 })
    right = get_targets_in_direction({ x: 1 })

    up + down + left + right
  end

  def get_bishop_targets
    up_left = get_targets_in_direction({ x: -1, y: -1 })
    down_left = get_targets_in_direction({ x: -1, y: 1 })
    up_right = get_targets_in_direction({ x: 1, y: -1 })
    down_right = get_targets_in_direction({ x: 1, y: 1 })

    up_left + down_left + up_right + down_right
  end

  def get_king_targets
    src_x, src_y = self.src_xy

    [
      self.game.xy_to_idx(src_x - 1, src_y - 1),
      self.game.xy_to_idx(src_x - 1, src_y + 1),
      self.game.xy_to_idx(src_x + 1, src_y - 1),
      self.game.xy_to_idx(src_x + 1, src_y + 1),
      self.game.xy_to_idx(src_x + 0, src_y - 1),
      self.game.xy_to_idx(src_x + 0, src_y + 1),
      self.game.xy_to_idx(src_x - 1, src_y + 0),
      self.game.xy_to_idx(src_x + 1, src_y - 0),
    ]
  end

  def on_board(target)
    0 <= target[:x] && target[:x] < self.game.board_size &&
      0 <= target[:y] && target[:y] < self.game.board_size
  end

  def get_targets_in_direction(delta)
    targets = []

    delta_x = delta[:x] || 0
    delta_y = delta[:y] || 0
    src_x, src_y = self.src_xy

    target = { x: src_x + delta_x, y: src_y + delta_y }

    while on_board(target)
      targets << self.game.xy_to_idx(target[:x], target[:y])

      target[:x] += delta_x
      target[:y] += delta_y
    end

    targets
  end

  def dest_is_valid_target
    _, _, piece_kind = self.get_piece

    valid_target_squares = {
      KNIGHT => -> { self.get_knight_targets },
      ROOK   => -> { self.get_rook_targets },
      BISHOP => -> { self.get_bishop_targets },
      QUEEN  => -> { self.get_rook_targets + self.get_bishop_targets },
      KING   => -> { self.get_king_targets },
    }[piece_kind]&.call() || []

    target_squares_on_board = valid_target_squares.filter do |square|
      x, y = self.game.idx_to_xy(square)
      on_board({ x: x, y: y })
    end

    if !target_squares_on_board.include?(self.dest)
      errors.add(:dest, "not a valid target square for a #{piece_kind}")
    end
  end

  def src_xy
    game.idx_to_xy(src)
  end

  def get_piece
    src_x, src_y = self.src_xy
    fen = self.game.fen

    fen.get_piece_at(src_x, src_y)
  end
end
