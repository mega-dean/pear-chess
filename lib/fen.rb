class Fen
  attr_accessor :size, :rows

  def initialize(size)
    self.size = size
    self.rows = Array.new(size, size.to_s)
  end

  def add_piece(color, piece_kind, square)
    new_value = begin
      char = {
        KNIGHT => "n",
        BISHOP => "b",
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
    row.split("").each do |char|
      if char.to_i > 0
        current += char.to_i
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
        if current_empty_squares > 0
          row << "#{current_empty_squares}#{square}"
        else
          row << "#{square}"
        end
        current_empty_squares = 0
      end
    end

    if current_empty_squares > 0
      row << "#{current_empty_squares}"
    end

    row
  end
end
