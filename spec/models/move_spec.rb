# frozen_string_literal: true

require "rails_helper"

RSpec.describe Move, type: :model do
  let(:user) { FactoryBot.create(:user) }

  let(:fen) {
    Fen.new(8).tap do |fen|
      fen.add_piece(TOP, WHITE, ROOK, 0)
      fen.add_piece(BOTTOM, WHITE, ROOK, 1)
      fen.add_piece(TOP, BLACK, ROOK, 2)
      fen.add_piece(BOTTOM, BLACK, ROOK, 3)
    end
  }

  let!(:game) {
    FactoryBot.create(:game,
      pieces: fen.to_s,
      current_turn: 1,
      pairs: [FactoryBot.create(:pair, white_player: user)],
    )
  }

  describe "validations" do
    describe "src" do
      def make_move!(x)
        Move.make!(
          game: game,
          user: user,
          params: {
            src_x: x,
            src_y: 0,
            dest_x: x,
            dest_y: 4,
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

    describe "targets" do
      let(:move) {
        FactoryBot.build(:move,
          game: game,
          src: game.xy_to_idx(4, 4),
        )
      }

      def expect_targets(meth, expected)
        targets = move.send(meth)

        expect(targets.length).to eq(expected.length)
        expected.each do |target|
          expect(targets).to include(Game.xy_to_idx(target[:x], target[:y], 8))
        end
      end

      describe "knight" do
        let(:piece_kind) { KNIGHT }

        specify "get_knight_targets" do
          expect_targets(:get_knight_targets, [
            { x: 2, y: 3 },
            { x: 3, y: 2 },
            { x: 5, y: 2 },
            { x: 6, y: 3 },
            { x: 2, y: 5 },
            { x: 3, y: 6 },
            { x: 5, y: 6 },
            { x: 6, y: 5 },
          ])
        end
      end

      describe "rook" do
        let(:piece_kind) { ROOK }

        specify "get_rook_targets" do
          expect_targets(:get_rook_targets, [
            # up
            { x: 3, y: 4 },
            { x: 2, y: 4 },
            { x: 1, y: 4 },
            { x: 0, y: 4 },
            # down
            { x: 5, y: 4 },
            { x: 6, y: 4 },
            { x: 7, y: 4 },
            # left
            { x: 4, y: 3 },
            { x: 4, y: 2 },
            { x: 4, y: 1 },
            { x: 4, y: 0 },
            # right
            { x: 4, y: 5 },
            { x: 4, y: 6 },
            { x: 4, y: 7 },
          ])
        end
      end

      describe "bishop" do
        let(:piece_kind) { BISHOP }

        specify "get_bishop_targets" do
          expect_targets(:get_bishop_targets, [
            # up-left
            { x: 3, y: 3 },
            { x: 2, y: 2 },
            { x: 1, y: 1 },
            { x: 0, y: 0 },
            # down-left
            { x: 5, y: 5 },
            { x: 6, y: 6 },
            { x: 7, y: 7 },
            # up-right
            { x: 5, y: 3 },
            { x: 6, y: 2 },
            { x: 7, y: 1 },
            # down-right
            { x: 5, y: 5 },
            { x: 6, y: 6 },
            { x: 7, y: 7 },
          ])
        end
      end

      describe "king" do
        let(:piece_kind) { KING }

        specify "get_king_targets" do
          expect_targets(:get_king_targets, [
            { x: 3, y: 3 },
            { x: 4, y: 3 },
            { x: 5, y: 3 },
            { x: 5, y: 4 },
            { x: 5, y: 5 },
            { x: 4, y: 5 },
            { x: 3, y: 5 },
            { x: 3, y: 4 },
          ])
        end
      end
    end

    describe "dest" do
      let(:fen) { Fen.new(8) }

      def add_piece_to_game(piece_kind)
        idx = game.xy_to_idx(1, 1)
        fen = game.fen

        fen.add_piece(user.team(game), user.color(game), piece_kind, idx)
        game.update!(pieces: fen.to_s)
      end

      {
        KNIGHT => {
          valid: { x: 0, y: 3 },
          invalid: { x: 0, y: 0 },
        },
        ROOK   => {
          valid: { x: 1, y: 7 },
          invalid: { x: 0, y: 0 },
        },
        BISHOP => {
          valid: { x: 6, y: 6 },
          invalid: { x: 5, y: 6 },
        },
        QUEEN  => {
          valid: { x: 7, y: 1 },
          invalid: { x: 3, y: 0 },
        },
        KING   => {
          valid: { x: 0, y: 0 },
          invalid: { x: 3, y: 0 },
        },
      }.each do |piece_kind, targets|
        def make_move!(x, y)
          Move.make!(
            game: game,
            user: user,
            params: {
              src_x: 1,
              src_y: 1,
              dest_x: x,
              dest_y: y,
            },
          )
        end

        it "#{piece_kind}: valid when dest is a valid target square" do
          add_piece_to_game(piece_kind)

          target = targets[:valid]
          make_move!(target[:x], target[:y])
          expect(Move.first.dest).to eq((target[:y] * game.board_size) + target[:x])
        end

        it "#{piece_kind}: invalid when dest is not a valid target square" do
          add_piece_to_game(piece_kind)

          target = targets[:invalid]
          expect {
            make_move!(target[:x], target[:y])
          }.to raise_error(ActiveRecord::RecordInvalid, /not a valid target square/)
        end
      end
    end
  end

  describe "make!" do
    def make_move!(x, dest_y)
      Move.make!(
        game: game,
        user: user,
        params: {
          src_x: x,
          src_y: 0,
          dest_x: x,
          dest_y: dest_y,
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
      }.to change { Move.first.dest }
        .from(4 * game.board_size)
        .to(3 * game.board_size)
    end
  end
end
