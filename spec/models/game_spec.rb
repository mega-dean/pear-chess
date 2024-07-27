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

    it "creates pairs" do
      expect(game.pairs.count).to be(2)
    end

    it "sets the creator to one of the pair players" do
      expect(game.pairs.first.black_player_id).to be(user.id)
      expect(game.pairs.first.white_player_id).to be(nil)

      expect(game.pairs.last.black_player_id).to be(nil)
      expect(game.pairs.last.white_player_id).to be(nil)
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
    let(:params) {
      {
        board_size: 8,
        turn_duration: 15,
        play_as: BLACK,
      }
    }

    it "returns two players for 2-player games" do
      game = Game.make!(creator: user, game_params: params.merge(number_of_players: 2))
      game.pairs.sole!.update!(white_player: opponent1)

      expect(game.reload.teams).to eq({
        TOP    => [opponent1.id],
        BOTTOM => [user.id],
      })
    end

    it "returns four players for 4-player games" do
      game = Game.make!(creator: user, game_params: params.merge(number_of_players: 4))
      game.pairs.first.update!(white_player: opponent1)

      game.pairs.last.update!(white_player: teammate)
      game.pairs.last.update!(black_player: opponent2)

      expect(game.reload.teams).to eq({
        TOP    => [opponent1.id, opponent2.id],
        BOTTOM => [user.id, teammate.id],
      })
    end

    it "returns empty lists when not all players have been set" do
      game = Game.make!(creator: user, game_params: params.merge(number_of_players: 4))

      expect(game.reload.teams).to eq({
        TOP    => [],
        BOTTOM => [user.id],
      })
    end

    it "raises an error when there are too many pairs" do
      game = Game.make!(creator: user, game_params: params.merge(number_of_players: 4))
      game.pairs.create!

      expect { game.reload.teams }.to raise_error(Game::NotSupportedYet)
    end
  end
end
