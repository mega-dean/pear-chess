# frozen_string_literal: true

require "rails_helper"

RSpec.describe Game, type: :model do
  describe "validations" do
    [
      :turn_duration,
      :board_size,
    ].each do |field|
      it "requires #{field} to be present" do
        game = FactoryBot.build(:game, field => nil)

        expect(game.valid?).to be(false)
      end
    end

    it "defaults current_turn to 0" do
      game = Game.new

      expect(game.current_turn).to be(0)
    end

    describe "pairs" do
      let(:game) { FactoryBot.create(:game) }

      let!(:pairs) {
        5.times do
          FactoryBot.create(:pair, game: game)
        end

        game.reload.pairs
      }

      it "is valid when pairs all have unique player ids" do
        expect(game.valid?).to be(true)
      end

      it "is invalid when any pairs have the same player id" do
        pairs.first.update!(white_player_id: pairs.last.black_player_id)

        expect(game.valid?).to be(false)
      end

      it "is valid when pairs have nil players" do
        pairs.first.update!(white_player_id: nil, black_player_id: nil)
        pairs.last.update!(white_player_id: nil, black_player_id: nil)

        expect(game.valid?).to be(true)
      end
    end
  end

  describe "make!" do
    let(:user) { FactoryBot.create(:user) }
    let(:params) {
      {
        number_of_players: 4,
        board_size: 8,
        turn_duration: 15,
        play_as: BLACK,
      }
    }

    let(:game) {
      Game.make!(creator: user, game_params: params)
    }

    it "creates a game with the given params" do
      expect(game.board_size).to eq(params[:board_size])
      expect(game.turn_duration).to eq(params[:turn_duration])
    end

    it "sets one of the top player_ids to the creator" do
      expect(game.top_white_player_id).to be(nil)
      expect(game.top_black_player_id).to be(user.id)
      expect(game.bottom_white_player_id).to be(nil)
      expect(game.bottom_black_player_id).to be(nil)
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
