# frozen_string_literal: true

require "rails_helper"

RSpec.describe Game, type: :model do
  describe "validations" do
    let(:game) { FactoryBot.build(:game) }

    def expect_validation_error(msg)
      expect {
        game.save!
      }.to raise_error(ActiveRecord::RecordInvalid, msg)
    end

    it "is valid with all valid fields" do
      expect(game.valid?).to be(true)
    end

    it "requires turn_duration to be present" do
      game.turn_duration = nil
      expect_validation_error(/Turn duration can't be blank/)
    end

    it "requires turn_duration to be in VALID_TURN_DURATIONS" do
      game.turn_duration = 16
      expect_validation_error(/Turn duration is not included in the list/)
    end

    it "requires board_size to be present" do
      game.board_size = nil
      expect_validation_error(/Board size can't be blank/)
    end

    it "requires board_size to be in VALID_BOARD_SIZES" do
      game.board_size = 13
      expect_validation_error(/Board size is not included in the list/)
    end

    it "defaults current_turn to 0" do
      expect(game.current_turn).to be(0)
    end

    describe "player ids" do
      it "is invalid if the top_white_player is also on BOTTOM" do
        game.top_white_player_id = 1
        game.bottom_white_player_id = 1

        expect_validation_error(/Top white player is also on BOTTOM/)
      end

      it "is invalid if the top_black_player is also on BOTTOM" do
        game.top_black_player_id = 1
        game.bottom_white_player_id = 1

        expect_validation_error(/Top black player is also on BOTTOM/)
      end

      it "is invalid if the bottom_white_player is also on TOP" do
        game.bottom_white_player_id = 1
        game.top_white_player_id = 1

        expect_validation_error(/Bottom white player is also on TOP/)
      end

      it "is invalid if the bottom_black_player is also on TOP" do
        game.bottom_black_player_id = 1
        game.top_white_player_id = 1

        expect_validation_error(/Bottom black player is also on TOP/)
      end
    end
  end

  describe "make!" do
    let(:user) { FactoryBot.create(:user) }
    let(:params) {
      {
        number_of_players: number_of_players,
        board_size: 8,
        turn_duration: 15,
        play_as: play_as,
      }
    }
    let(:game) { Game.make!(creator: user, game_params: params) }

    context "2-player game" do
      let(:number_of_players) { 2 }
      let(:play_as) { nil }

      it "creates a game with the given params" do
        expect(game.board_size).to eq(params[:board_size])
        expect(game.turn_duration).to eq(params[:turn_duration])
      end

      it "sets both of the top player_ids to the creator" do
        expect(game.top_white_player_id).to be(user.id)
        expect(game.top_black_player_id).to be(user.id)
        expect(game.bottom_white_player_id).to be(nil)
        expect(game.bottom_black_player_id).to be(nil)
      end
    end

    context "4-player game" do
      let(:number_of_players) { 4 }
      let(:play_as) { BLACK }

      it "creates a game with the given params" do
        expect(game.board_size).to eq(params[:board_size])
        expect(game.turn_duration).to eq(params[:turn_duration])
      end

      it "sets the top player_id to the creator from the :play_as param" do
        expect(game.top_white_player_id).to be(nil)
        expect(game.top_black_player_id).to be(user.id)
        expect(game.bottom_white_player_id).to be(nil)
        expect(game.bottom_black_player_id).to be(nil)
      end

      it "requires a :play_as param" do
        params[:play_as] = nil
        expect { game }.to raise_error(Game::MissingPlayAsParam)
      end
    end
  end

  describe "current_color" do
    let(:game) { FactoryBot.create(:game) }

    it "is nil when the game hasn't started yet" do
      expect(game.current_color).to be(nil)
    end

    it "is WHITE when the current_turn is odd" do
      game.update!(current_turn: 5)
      expect(game.current_color).to be(WHITE)
    end

    it "is BLACK when the current_turn is even" do
      game.update!(current_turn: 10)
      expect(game.current_color).to be(BLACK)
    end
  end

  describe "start!" do
    let(:game) { FactoryBot.create(:two_player_game) }

    it "sets the initial pieces and sets the current_turn to 1" do
      expect {
        game.start!
      }.to change { game.pieces }.from(nil).to(game.initial_pieces)
        .and change { game.current_turn }.from(0).to(1)
    end

    it "raises an error if not all players are set" do
      game.update!(top_white_player: nil)

      expect {
        game.start!
      }.to raise_error(Game::NotEnoughPlayers)
    end
  end

  describe "teams" do
    let(:user) { FactoryBot.create(:user) }
    let(:teammate) { FactoryBot.create(:user) }
    let(:opponent1) { FactoryBot.create(:user) }
    let(:opponent2) { FactoryBot.create(:user) }

    it "returns two players for 2-player games" do
      game = Game.new(
        top_white_player: user,
        top_black_player: user,
        bottom_white_player: opponent1,
        bottom_black_player: opponent1,
      )

      expect(game.teams).to eq({
        TOP    => [user],
        BOTTOM => [opponent1],
      })
    end

    it "returns four players for 4-player games" do
      game = Game.new(
        top_white_player: opponent1,
        top_black_player: opponent2,
        bottom_white_player: user,
        bottom_black_player: teammate,
      )

      expect(game.teams).to eq({
        TOP    => [opponent1, opponent2],
        BOTTOM => [user, teammate],
      })
    end

    it "returns empty lists when not all players have been set" do
      game = Game.new(bottom_white_player: user)

      expect(game.teams).to eq({
        TOP    => [],
        BOTTOM => [user],
      })
    end
  end
end
