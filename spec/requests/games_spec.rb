# frozen_string_literal: true

require "rails_helper"
require "clearance/rspec"

RSpec.describe "Games", type: :request do
  describe "param validation when creating Game" do
    def sign_in
      user = FactoryBot.create(:user)

      params = {
        session: {
          username: user.username,
          password: user.password,
        },
      }

      post session_path(params)
      user
    end

    let(:game_params) {
      {
        number_of_players: 2,
        board_size: 8,
        turn_duration: 10,
        play_as: WHITE,
      }
    }

    before do
      user = FactoryBot.create(:user)

      params = {
        session: {
          username: user.username,
          password: user.password,
        },
      }

      post session_path(params)
    end

    it "validates number_of_players" do
      post games_path({ game: game_params.merge(number_of_players: 1000) })

      expect(Game.count).to be(0)
    end

    it "validates board_size" do
      post games_path({ game: game_params.merge(board_size: 1000) })

      expect(Game.count).to be(0)
    end

    it "validates turn_duration" do
      post games_path({ game: game_params.merge(turn_duration: 1000) })

      expect(Game.count).to be(0)
    end

    it "validates play_as" do
      post games_path({ game: game_params.merge(play_as: "nobody") })

      expect(Game.count).to be(0)
    end

    it "creates a game when all params are valid" do
      post games_path({ game: game_params })

      game = Game.sole!
      user = User.sole!

      expect(Game.count).to be(1)
      expect(game.pairs.count).to be(1)
      expect(game.board_size).to be(8)
      expect(game.turn_duration).to be(10)
      expect(game.pairs.first.white_player_id).to be(user.id)
    end
  end
end
