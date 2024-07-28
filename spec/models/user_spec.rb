# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }

  describe "team" do
    it "is the user's team when they are part of the game" do
      game = Game.new(top_black_player: user)
      expect(user.team(game)).to be(TOP)

      game = Game.new(bottom_black_player: user)
      expect(user.team(game)).to be(BOTTOM)
    end

    it "is nil when the user is not playing in the game" do
      game = Game.new
      expect(user.team(game)).to be(nil)
    end
  end

  describe "colors" do
    it "is [WHITE, BLACK] for a 2-player game" do
      game = Game.new(bottom_white_player: user, bottom_black_player: user)
      expect(user.colors(game)).to eq([WHITE, BLACK])
    end

    it "contains the user's color for a 4-player game" do
      game = Game.new(bottom_white_player: user)
      expect(user.colors(game)).to eq([WHITE])

      game = Game.new(bottom_black_player: user)
      expect(user.colors(game)).to eq([BLACK])
    end
  end
end
