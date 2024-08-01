class ProcessMoves
  attr_accessor :game, :moves_by_src, :fen, :fen_squares

  def initialize(game)
    self.game = game
    self.fen = game.fen
    self.fen_squares = self.fen.to_squares
    self.moves_by_src = {}

    game.current_moves.each do |move|
      self.moves_by_src[move.src] = move
    end
  end

  def run
    game.update!(processing_moves: true)
    steps = self.get_move_steps
    self.apply_move_steps(steps)

    game.broadcast_move_steps(steps)
  ensure
    game.update!(processing_moves: false)
  end

  private

  def get_move_steps
    steps = Array.new(self.game.board_size, nil)
    bumped = Set.new
    captured = Set.new
    unmoving_pieces = Set.new

    cache = {}
    fen_squares.each.with_index do |fen_row, fen_y|
      fen_row.each.with_index do |fen_char, fen_x|
        src = self.game.xy_to_idx(fen_x, fen_y)
        team, color, piece_kind = fen.get_piece(fen_char)

        if team
          if intermediate_steps = moves_by_src[src]&.get_intermediate_steps
            cache[src] = {
              team: team,
              color: color,
              piece_kind: piece_kind,
              intermediate_steps: intermediate_steps,
            }
          else
            unmoving_pieces.add(src)
          end
        end
      end
    end

    move_steps = game.board_size.times.map do |step_idx|
      step = {}

      # `piece_id` here is really "src that the piece started at this turn", since pieces don't really have an id.
      cache.each do |piece_id, cached|
        current_square = if cached[:intermediate_steps]
          cached[:intermediate_steps][step_idx]
        else
          piece_id
        end

        piece_state = if step_idx == 0
          :moving
        elsif current_square == cached[:intermediate_steps][step_idx - 1]
          :moved
        else
          :moving
        end

        step[current_square] ||= {}

        if piece_state == :moving
          step[current_square][:moving] ||= []
          step[current_square][:moving] << piece_id
        else
          step[current_square].merge!({ piece_state => piece_id })
        end

        if step[current_square].count > 1 || (step[current_square][:moving] && step[current_square][:moving].count > 1)
          # TODO handle captures and bumping
        end
      end

      step
    end

    [move_steps, unmoving_pieces]
  end

  def apply_move_steps(steps)
    # TODO get new fen
    new_fen = game.pieces

    game.update!(
      pieces: new_fen,
      current_turn: game.current_turn + 1,
    )
  end
end
