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

  specify "team" do
    game = Game.make(creator: user, game_params: game_params.merge(play_as: WHITE))
    expect(user.team(game)).to be(TOP)

    game = Game.make(creator: user, game_params: game_params.merge(play_as: BLACK))
    expect(user.team(game)).to be(BOTTOM)
  end

  specify "color" do
    game = Game.make(creator: user, game_params: game_params.merge(play_as: WHITE))
    expect(user.color(game)).to be(WHITE)

    game = Game.make(creator: user, game_params: game_params.merge(play_as: BLACK))
    expect(user.color(game)).to be(BLACK)
  end
end
