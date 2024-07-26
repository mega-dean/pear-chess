# frozen_string_literal: true

require "rails_helper"

RSpec.describe Move, type: :model do
  describe "validations" do
    describe "src_square" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:fen) {
        fen = Fen.new(8)
        fen.add_piece(TOP, WHITE, ROOK, 0)
        fen.add_piece(BOTTOM, WHITE, ROOK, 1)
        fen.add_piece(TOP, BLACK, ROOK, 2)
        fen.add_piece(BOTTOM, BLACK, ROOK, 3)
        fen
      }
      let!(:game) {
        FactoryBot.create(:game,
          pieces: fen.to_s,
          current_turn: 1,
          pairs: [FactoryBot.create(:pair, white_player: user)],
        )
      }

      def make_move!(x)
        Move.make!(
          game: game,
          user: user,
          params: {
            src_square_x: x,
            src_square_y: 0,
            dest_square_x: x,
            dest_square_y: 4,
          },
        )
      end

      it "is valid when src is a piece belonging to the user" do
        expect {
          make_move!(0)
        }.to change { Move.count }.by(1)
      end

      it "is invalid when the piece at src belongs to an enemy" do
        expect {
          make_move!(1)
        }.to raise_error(ActiveRecord::RecordInvalid, /not the user's team/)
      end

      it "is invalid when the piece at src belongs to their teammate" do
        game.pairs << FactoryBot.create(:pair)

        expect {
          make_move!(2)
        }.to raise_error(ActiveRecord::RecordInvalid, /not the user's color/)
      end

      it "is invalid it is not the player's turn" do
        game.update!(current_turn: 2)

        expect {
          make_move!(0)
        }.to raise_error(ActiveRecord::RecordInvalid, /not the user's turn/)
      end

      it "is invalid when src is an empty square" do
        expect {
          make_move!(7)
        }.to raise_error(ActiveRecord::RecordInvalid, /no piece at/)
      end
    end

    describe "dest_square" do
      let!(:user) { FactoryBot.create(:user) }
      let!(:game) {
        FactoryBot.create(:game,
          pieces: Fen.new(8).to_s,
          current_turn: 1,
          pairs: [FactoryBot.create(:pair, white_player: user)],
        )
      }

      def add_piece_to_game(piece_kind)
        square = game.square_at(1, 1)
        fen = game.get_fen
        # CLEANUP maybe rename team/color to team_in/color_in
        fen.add_piece(user.team(game), user.color(game), piece_kind, square)
        game.update!(pieces: fen.to_s)
      end

      {
        KNIGHT => {
          valid: [
            { x: 0, y: 3 },
            { x: 2, y: 3 },
            { x: 3, y: 2 },
            { x: 3, y: 0 },
          ],
          invalid: [
            { x: 0, y: 0 },
            { x: 2, y: 1 },
            { x: 2, y: 2 },
            { x: 3, y: 1 },
            { x: 5, y: 5 },
          ],
        },
        ROOK => {
          valid: [
            # up
            { x: 1, y: 0 },
            # left
            { x: 0, y: 1 },
            # right
            { x: 3, y: 1 },
            { x: 4, y: 1 },
            { x: 5, y: 1 },
            { x: 6, y: 1 },
            { x: 7, y: 1 },
            # down
            { x: 1, y: 3 },
            { x: 1, y: 4 },
            { x: 1, y: 5 },
            { x: 1, y: 6 },
            { x: 1, y: 7 },
          ],
          invalid: [
            { x: 0, y: 0 },
            { x: 2, y: 0 },
            { x: 0, y: 2 },
            { x: 2, y: 2 },
            { x: 5, y: 5 },
          ],
        },
        BISHOP => {
          valid: [
            # up-left
            { x: 0, y: 0 },
            # down-left
            { x: 0, y: 2 },
            # up-right
            { x: 2, y: 0 },
            # down-right
            { x: 2, y: 2 },
            { x: 3, y: 3 },
            { x: 4, y: 4 },
            { x: 5, y: 5 },
            { x: 6, y: 6 },
            { x: 7, y: 7 },
          ],
          invalid: [
            { x: 1, y: 0 },
            { x: 0, y: 1 },
            { x: 1, y: 3 },
            { x: 3, y: 1 },
            { x: 5, y: 6 },
          ],
        },
        QUEEN => {
          valid: [
            # up
            { x: 1, y: 0 },
            # left
            { x: 0, y: 1 },
            # right
            { x: 3, y: 1 },
            { x: 4, y: 1 },
            { x: 5, y: 1 },
            { x: 6, y: 1 },
            { x: 7, y: 1 },
            # down
            { x: 1, y: 3 },
            { x: 1, y: 4 },
            { x: 1, y: 5 },
            { x: 1, y: 6 },
            { x: 1, y: 7 },
            # up-left
            { x: 0, y: 0 },
            # down-left
            { x: 0, y: 2 },
            # up-right
            { x: 2, y: 0 },
            # down-right
            { x: 2, y: 2 },
            { x: 3, y: 3 },
            { x: 4, y: 4 },
            { x: 5, y: 5 },
            { x: 6, y: 6 },
            { x: 7, y: 7 },
          ],
          invalid: [
            { x: 0, y: 3 },
            { x: 2, y: 3 },
            { x: 3, y: 2 },
            { x: 3, y: 0 },
            { x: 5, y: 6 },
          ],
        },
        KING => {
          valid: [
            { x: 0, y: 0 },
            { x: 0, y: 1 },
            { x: 0, y: 2 },
            { x: 1, y: 2 },
            { x: 2, y: 2 },
            { x: 2, y: 1 },
            { x: 2, y: 0 },
            { x: 1, y: 0 },
          ],
          invalid: [
            { x: 3, y: 0 },
            { x: 3, y: 1 },
            { x: 3, y: 2 },
            { x: 3, y: 3 },
            { x: 2, y: 3 },
            { x: 1, y: 3 },
            { x: 0, y: 3 },
          ],
        },
      }.each do |piece_kind, targets|
        def make_move!(x, y)
          Move.make!(
            game: game,
            user: user,
            params: {
              src_square_x: 1,
              src_square_y: 1,
              dest_square_x: x,
              dest_square_y: y,
            },
          )
        end

        it "#{piece_kind}: valid when dest is a valid target square" do
          add_piece_to_game(piece_kind)

          targets[:valid].each do |target|
            make_move!(target[:x], target[:y])
            expect(Move.first.dest_square).to eq((target[:y] * game.board_size) + target[:x])
          end
        end

        it "#{piece_kind}: invalid when dest is not a valid target square" do
          add_piece_to_game(piece_kind)

          targets[:invalid].each do |target|
            expect {
              make_move!(target[:x], target[:y])
            }.to raise_error(ActiveRecord::RecordInvalid, /not a valid target square/)
          end
        end
      end
    end
  end

  describe "make!" do
    # CLEANUP duplicated
    let!(:user) { FactoryBot.create(:user) }
    let!(:fen) {
      fen = Fen.new(8)
      fen.add_piece(TOP, WHITE, ROOK, 0)
      fen.add_piece(BOTTOM, WHITE, ROOK, 1)
      fen.add_piece(TOP, BLACK, ROOK, 2)
      fen.add_piece(BOTTOM, BLACK, ROOK, 3)
      fen
    }
    let!(:game) {
      FactoryBot.create(:game,
        pieces: fen.to_s,
        current_turn: 1,
        pairs: [FactoryBot.create(:pair, white_player: user)],
      )
    }

    def make_move!(x, dest_y)
      Move.make!(
        game: game,
        user: user,
        params: {
          src_square_x: x,
          src_square_y: 0,
          dest_square_x: x,
          dest_square_y: dest_y,
        },
      )
    end

    it "creates a new move when none exists for give src square" do
      expect {
        make_move!(0, 4)
      }.to change { Move.count }.by(1)

      expect {
        make_move!(0, 3)
      }.not_to change { Move.count }
    end

    it "updates an existing move for src" do
      make_move!(0, 4)

      expect {
        make_move!(0, 3)
      }.to change { Move.first.dest_square }
        .from(4 * game.board_size)
        .to(3 * game.board_size)
    end
  end
end
