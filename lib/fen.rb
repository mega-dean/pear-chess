# frozen_string_literal: true

class Fen
  attr_accessor :size, :rows

  def initialize(size)
    self.size = size
    self.rows = Array.new(size, size.to_s(16))
  end

  def self.from_s(s)
    rows = s.split("/")
    size = rows.length

    fen = new(size)
    fen.rows = rows
    fen
  end

  def to_squares
    self.rows.map do |row|
      self.row_to_squares(row)
    end
  end

  def add_piece(team, color, piece_kind, square)
    new_value = begin
      char = {
        [TOP, KNIGHT]    => "n",
        [TOP, BISHOP]    => "i",
        [TOP, ROOK]      => "r",
        [TOP, QUEEN]     => "q",
        [TOP, KING]      => "k",
        [BOTTOM, KNIGHT] => "m",
        [BOTTOM, BISHOP] => "j",
        [BOTTOM, ROOK]   => "s",
        [BOTTOM, QUEEN]  => "u",
        [BOTTOM, KING]   => "l",
      }[[team, piece_kind]]

      {
        WHITE => char.capitalize,
        BLACK => char,
      }[color]
    end

    self.change_square(square, new_value)
  end

  def remove_piece(square)
    self.change_square(square, nil)
  end

  def to_s
    self.rows.join("/")
  end

  # Returns [team, color, piece_kind]
  def get_piece(char)
    {
      "N" => [TOP, WHITE, KNIGHT],
      "I" => [TOP, WHITE, BISHOP],
      "R" => [TOP, WHITE, ROOK],
      "Q" => [TOP, WHITE, QUEEN],
      "K" => [TOP, WHITE, KING],
      "n" => [TOP, BLACK, KNIGHT],
      "i" => [TOP, BLACK, BISHOP],
      "r" => [TOP, BLACK, ROOK],
      "q" => [TOP, BLACK, QUEEN],
      "k" => [TOP, BLACK, KING],
      "M" => [BOTTOM, WHITE, KNIGHT],
      "J" => [BOTTOM, WHITE, BISHOP],
      "S" => [BOTTOM, WHITE, ROOK],
      "U" => [BOTTOM, WHITE, QUEEN],
      "L" => [BOTTOM, WHITE, KING],
      "m" => [BOTTOM, BLACK, KNIGHT],
      "j" => [BOTTOM, BLACK, BISHOP],
      "s" => [BOTTOM, BLACK, ROOK],
      "u" => [BOTTOM, BLACK, QUEEN],
      "l" => [BOTTOM, BLACK, KING],
    }[char]
  end

  def get_piece_at(x, y)
    char = self.to_squares[y][x]
    self.get_piece(char)
  end

  private

  def change_square(square, new_value)
    target_row = square / self.size
    target_col = square % self.size

    squares = self.row_to_squares(self.rows[target_row])
    squares[target_col] = new_value
    self.rows[target_row] = self.squares_to_row(squares)
  end

  def row_to_squares(row)
    squares = Array.new(self.size, nil)
    current = 0
    row.chars.each do |char|
      if char.to_i(16) > 0
        current += char.to_i(16)
      else
        squares[current] = char
        current += 1
      end
    end
    squares
  end

  def squares_to_row(squares)
    row = String.new("")
    current_empty_squares = 0

    squares.each do |square|
      if square.nil?
        current_empty_squares += 1
      else
        row << if current_empty_squares > 0
          "#{current_empty_squares.to_s(16)}#{square}"
        else
          square.to_s
        end
        current_empty_squares = 0
      end
    end

    if current_empty_squares > 0
      row << current_empty_squares.to_s(16)
    end

    row
  end
end
