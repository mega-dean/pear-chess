# frozen_string_literal: true

class Move < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :turn, presence: true
  validates :src_square, presence: true
  validates :dest_square, presence: true
  validate :src_is_valid_piece
  validate :dest_is_valid_target

  class << self
    def make!(game:, user:, params:)
      src_square = (params[:src_square_y].to_i * game.board_size) + params[:src_square_x].to_i
      dest_square = (params[:dest_square_y].to_i * game.board_size) + params[:dest_square_x].to_i

      existing_move = Move.find_by(
        game: game,
        turn: game.current_turn,
        user: user,
        src_square: src_square,
      )

      if existing_move
        existing_move.update!(dest_square: dest_square)
      else
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

  private

  def src_is_valid_piece
    src_x = self.src_square % self.game.board_size
    src_y = self.src_square / self.game.board_size
    team, color, _ = self.get_piece

    if !team
      errors.add(:src_square, "no piece at (#{src_x}, #{src_y})")
    else
      if team != self.user.team(self.game)
        errors.add(:src_square, "not the user's team")
      end

      if self.game.pairs.count == 2
        if color != self.user.color(self.game)
          errors.add(:src_square, "not the user's color")
        end
      end

      if color != self.game.current_color
        errors.add(:src_square, "not the user's turn")
      end
    end
  end

  def get_knight_moves
    src_x = self.src_square % self.game.board_size
    src_y = self.src_square / self.game.board_size

    [
      self.game.square_at(src_x + 1, src_y + 2),
      self.game.square_at(src_x + 1, src_y - 2),
      self.game.square_at(src_x - 1, src_y + 2),
      self.game.square_at(src_x - 1, src_y - 2),
      self.game.square_at(src_x + 2, src_y + 1),
      self.game.square_at(src_x + 2, src_y - 1),
      self.game.square_at(src_x - 2, src_y + 1),
      self.game.square_at(src_x - 2, src_y - 1),
    ]
  end

  def get_rook_moves
    up = get_moves_in_direction({ y: -1 })
    down = get_moves_in_direction({ y: 1 })
    left = get_moves_in_direction({ x: -1 })
    right = get_moves_in_direction({ x: 1 })

    up + down + left + right
  end

  def get_bishop_moves
    up_left = get_moves_in_direction({ x: -1, y: -1 })
    down_left = get_moves_in_direction({ x: -1, y: 1 })
    up_right = get_moves_in_direction({ x: 1, y: -1 })
    down_right = get_moves_in_direction({ x: 1, y: 1 })

    up_left + down_left + up_right + down_right
  end

  def get_king_moves
    src_x = self.src_square % self.game.board_size
    src_y = self.src_square / self.game.board_size

    [
      self.game.square_at(src_x - 1, src_y - 1),
      self.game.square_at(src_x - 1, src_y + 1),
      self.game.square_at(src_x + 1, src_y - 1),
      self.game.square_at(src_x + 1, src_y + 1),
      self.game.square_at(src_x + 0, src_y - 1),
      self.game.square_at(src_x + 0, src_y + 1),
      self.game.square_at(src_x - 1, src_y + 0),
      self.game.square_at(src_x + 1, src_y - 0),
    ]
  end

  def on_board(target)
    0 <= target[:x] && target[:x] < self.game.board_size &&
      0 <= target[:y] && target[:y] < self.game.board_size
  end

  def get_moves_in_direction(delta)
    moves = []
    src_x = self.src_square % self.game.board_size
    src_y = self.src_square / self.game.board_size

    target = {
      x: src_x + (delta[:x] || 0),
      y: src_y + (delta[:y] || 0),
    }

    while on_board(target)
      square = (self.game.board_size * target[:y]) + target[:x]
      moves << square

      target[:x] += (delta[:x] || 0)
      target[:y] += (delta[:y] || 0)
    end

    moves
  end

  def dest_is_valid_target
    _, _, piece_kind = self.get_piece

    valid_target_squares = {
      KNIGHT => -> { self.get_knight_moves },
      ROOK => -> { self.get_rook_moves },
      BISHOP => -> { self.get_bishop_moves },
      QUEEN => -> { self.get_rook_moves + self.get_bishop_moves },
      KING => -> { self.get_king_moves },
    }[piece_kind]&.call() || []

    def on_board_(square)
      0 <= square && square <= self.game.board_size**2
    end

    valid_target_squares_ = valid_target_squares.filter { |square| on_board_(square) }

    if !valid_target_squares_.include?(self.dest_square)
      errors.add(:dest_square, "not a valid target square for a #{piece_kind}")
    end
  end

  def get_piece
    src_x = self.src_square % self.game.board_size
    src_y = self.src_square / self.game.board_size
    fen = Fen.from_s(self.game.pieces)
    char = fen.to_squares[src_y][src_x]

    fen.get_piece(char)
  end
end
