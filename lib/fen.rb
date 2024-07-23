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

  # Returns [color, piece_kind]
  def piece_at(square)
    target_row = square / self.size
    target_col = square % self.size

    squares = self.row_to_squares(self.rows[target_row])
    self.get_piece(squares[target_col])
  end

  def add_piece(color, piece_kind, square)
    new_value = begin
      char = {
        KNIGHT => "n",
        BISHOP => "p",
        ROOK => "r",
        QUEEN => "q",
        KING => "k",
      }[piece_kind]

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

  private

  def get_piece(char)
    {
      "N" => [WHITE, KNIGHT],
      "P" => [WHITE, BISHOP],
      "R" => [WHITE, ROOK],
      "Q" => [WHITE, QUEEN],
      "K" => [WHITE, KING],
      "n" => [BLACK, KNIGHT],
      "p" => [BLACK, BISHOP],
      "r" => [BLACK, ROOK],
      "q" => [BLACK, QUEEN],
      "k" => [BLACK, KING],
    }[char]
  end

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
    row = ""
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
