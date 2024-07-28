# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let(:game_params) {
    {
      board_size: 8,
      turn_duration: 15,
      number_of_players: 2,
    }
  }
  let(:user) { FactoryBot.create(:user) }

  describe "team" do
    it "is the user's team when they are part of the game" do
      game = Game.make!(creator: user, game_params: game_params.merge(play_as: WHITE))
      expect(user.team(game)).to be(TOP)

      game = Game.make!(creator: user, game_params: game_params.merge(play_as: BLACK))
      expect(user.team(game)).to be(BOTTOM)
    end

    it "is nil when the user is not playing in the game" do
      game = Game.new
      expect(user.team(game)).to be(nil)
    end
  end

  describe "colors" do
    it "is [WHITE, BLACK] for a 2-player game" do
      game = Game.make!(creator: user, game_params: game_params)
      expect(user.colors(game)).to be([WHITE, BLACK])
    end

    it "contains the user's color for a 4-player game" do
      game_params[:number_of_players] = 4

      game = Game.make!(creator: user, game_params: game_params.merge(play_as: WHITE))
      expect(user.colors(game)).to be([WHITE])

      game = Game.make!(creator: user, game_params: game_params.merge(play_as: BLACK))
      expect(user.colors(game)).to be([BLACK])
    end
  end
end
