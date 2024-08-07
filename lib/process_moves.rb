# frozen_string_literal: true

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

    steps, captured_pieces, all_pieces = self.get_move_steps
    self.apply_move_steps(steps, captured_pieces, all_pieces)
    game.broadcast_move_steps(steps)
  ensure
    game.update!(processing_moves: false)
  end

  private

  def get_move_steps
    steps = Array.new(self.game.board_size, nil)
    bumped_pieces = Set.new
    captured_pieces = Set.new
    capturing_pieces = {}
    all_pieces = {}
    unmoving_pieces = {}

    cache = {}
    fen_squares.each.with_index do |fen_row, fen_y|
      fen_row.each.with_index do |fen_char, fen_x|
        src = self.game.xy_to_idx(fen_x, fen_y)
        team, color, piece_kind = fen.get_piece(fen_char)

        if team
          all_pieces[src] = {
            team: team,
            color: color,
            piece_kind: piece_kind,
          }
          if (intermediate_steps = moves_by_src[src]&.get_intermediate_steps)
            cache[src] = {
              team: team,
              color: color,
              piece_kind: piece_kind,
              intermediate_steps: intermediate_steps,
            }
          else
            unmoving_pieces[src] = {
              team: team,
              color: color,
              piece_kind: piece_kind,
            }
          end
        end
      end
    end

    move_steps = []
    game.board_size.times.each do |step_idx|
      step = {}

      # `piece_id` here is really "src that the piece started at this turn", since pieces don't really have an id.
      cache.each do |piece_id, cached|
        if capturing_pieces[piece_id]
          step[capturing_pieces[piece_id]] ||= {}
          step[capturing_pieces[piece_id]].merge!({ moved: piece_id })
        elsif bumped_pieces.include?(piece_id)
          step[piece_id] ||= {}
          step[piece_id].merge!({ bumped: piece_id })
        else
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

          pieces_at_current_square_this_step = [
            *step[current_square][:moving],
            step[current_square][:moved],
            step[current_square][:bumped],
            (current_square if unmoving_pieces[current_square]),
          ].compact

          if pieces_at_current_square_this_step.count > 1
            step[current_square][:moving]&.each do |moving_piece_id|
              piece_id_already_here = (pieces_at_current_square_this_step - [moving_piece_id]).sole!

              moving_piece = all_pieces[moving_piece_id]
              piece_already_here = all_pieces[piece_id_already_here]
              if moving_piece[:color] == piece_already_here[:color] || moving_piece[:team] == piece_already_here[:team]
                bumped_pieces.add(moving_piece_id)
              else
                step[current_square][:captured] = piece_id_already_here
                capturing_pieces[moving_piece_id] = current_square
                captured_pieces.add(piece_id_already_here)
              end
            end
          end
        end
      end

      move_steps << step
    end

    [move_steps, captured_pieces, all_pieces]
  end

  def apply_move_steps(move_steps, captured_pieces, all_pieces)
    new_fen = game.fen

    captured_pieces.each do |square|
      new_fen.remove_piece(square)
    end

    move_steps.last.each do |dest, step|
      if (src = step[:moved])
        piece = all_pieces[src]
        new_fen.remove_piece(src)
        new_fen.add_piece(piece[:team], piece[:color], piece[:piece_kind], dest)
      end
    end

    game.update!(
      pieces: new_fen.to_s,
      current_turn: game.current_turn + 1,
    )
  end
end
