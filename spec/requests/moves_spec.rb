# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Moves", type: :request do
  let(:user) { FactoryBot.create(:user) }

  describe "create" do
    let(:pair) { FactoryBot.create(:pair) }
    let(:game) { pair.game }
    let(:move_params) {
      {
        move: {
          game_id: game.id,
          src_x: 0,
          src_y: 0,
          dest_x: 1,
          dest_y: 0,
        }
      }
    }

    before do
      sign_in(user)
      game.start!
    end

    it "does not create a move for a game that the current_user is not playing in" do
      post moves_path(move_params)

      expect(Move.count).to eq(0)
    end

    it "creates a move when params are valid" do
      pair.update!(white_player: user)
      post moves_path(move_params)

      expect(Move.count).to eq(1)
    end
  end
end
