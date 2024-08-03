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
      existing_move = Move.find_by(
        game: game,
        turn: game.current_turn,
        user: user,
        src: params[:src_idx],
      )

      if existing_move
        existing_move.update!(dest: params[:dest_idx])
      else
        Move.create!(
          game: game,
          turn: game.current_turn,
          user: user,
          src: params[:src_idx],
          dest: params[:dest_idx],
        )
      end
    end
  end

  def get_intermediate_steps
    steps = if [KING, KNIGHT].include?(self.piece_kind)
      [self.dest]
    else
      self.get_linear_intermediate_steps
    end

    self.intermediate_step_count.times do |idx|
      if !steps[idx]
        steps[idx] = steps[idx - 1]
      end
    end

    steps
  end

  def team
    @team ||= begin
      self.get_piece
      @team
    end
  end

  def color
    @color ||= begin
      self.get_piece
      @color
    end
  end

  def piece_kind
    @piece_kind ||= begin
      self.get_piece
      @piece_kind
    end
  end

  def intermediate_step_count
    game.board_size
  end

  private

  def get_linear_intermediate_steps
    src_x, src_y = game.idx_to_xy(src)
    dest_x, dest_y = game.idx_to_xy(dest)

    dx = dest_x - src_x
    dy = dest_y - src_y

    direction = if dx == 0
      if dy > 0
        :down
      else
        :up
      end
    elsif dy == 0
      if dx > 0
        :right
      else
        :left
      end
    else
      if dx > 0 && dy > 0
        :down_right
      elsif dx > 0 && dy < 0
        :up_right
      elsif dx < 0 && dy > 0
        :down_left
      elsif dx < 0 && dy < 0
        :up_left
      end
    end

    delta = {
      up_left: -game.board_size - 1,
      up: -game.board_size,
      up_right: -game.board_size + 1,
      left: -1,
      right: 1,
      down_left: game.board_size - 1,
      down: game.board_size,
      down_right: game.board_size + 1,
    }[direction]

    intermediate_squares = []
    current_square = src

    while current_square != dest
      current_square += delta
      intermediate_squares << current_square
    end

    intermediate_squares << dest
    intermediate_squares
  end

  def src_is_valid_piece
    src_x, src_y = self.src_xy

    if !self.team
      errors.add(:src, "no piece at (#{src_x}, #{src_y})")
    else
      if self.team != self.user.team(self.game)
        errors.add(:src, "not the user's team")
      end

      if self.game.players.count == 4
        if !self.user.colors(self.game).include?(self.color)
          errors.add(:src, "not the user's color")
        end
      end

      if self.color != self.game.current_color
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
    valid_target_squares = {
      KNIGHT => -> { self.get_knight_targets },
      ROOK   => -> { self.get_rook_targets },
      BISHOP => -> { self.get_bishop_targets },
      QUEEN  => -> { self.get_rook_targets + self.get_bishop_targets },
      KING   => -> { self.get_king_targets },
    }[self.piece_kind]&.call() || []

    target_squares_on_board = valid_target_squares.filter do |square|
      x, y = self.game.idx_to_xy(square)
      on_board({ x: x, y: y })
    end

    if !target_squares_on_board.include?(self.dest)
      errors.add(:dest, "not a valid target square for a #{self.piece_kind}")
    end
  end

  def src_xy
    game.idx_to_xy(src)
  end

  def get_piece
    src_x, src_y = self.src_xy
    fen = self.game.fen

    team, color, piece_kind = fen.get_piece_at(src_x, src_y)

    @team = team
    @color = color
    @piece_kind = piece_kind
  end
end
