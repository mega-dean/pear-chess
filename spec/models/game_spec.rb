require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:full_attrs) do
    {
      white_player_1_id: 1,
      black_player_1_id: 2,
      white_player_2_id: 3,
      black_player_2_id: 4,
      turn_duration: 10,
      board_size: 8,
    }
  end

  describe "validations" do
    [
      :turn_duration,
      :board_size,
      :white_player_1_id,
      :white_player_1_id,
      :white_player_1_id,
      :white_player_1_id,
    ].each do |field|
      it "requires #{field} to be present" do
        game = Game.new(full_attrs.without(field))

        expect(game.valid?).to be(false)
      end
    end

    it "defaults current_turn to 0" do
      game = Game.new

      expect(game.current_turn).to be(0)
    end

    describe "player ids" do
      it "is valid when all four ids are different" do
        game = Game.new(full_attrs)

        expect(game.valid?).to be(true)
      end

      it "is valid when player_1 ids are the same, and player_2 ids are the same" do
        full_attrs_for_two_players = full_attrs.merge(
          black_player_1_id: full_attrs[:white_player_1_id],
          black_player_2_id: full_attrs[:white_player_2_id],
        )
        game = Game.new(full_attrs_for_two_players)

        expect(game.valid?).to be(true)
      end

      it "is invalid when there are 3 players" do
        full_attrs_for_two_players = full_attrs.merge(
          black_player_1_id: full_attrs[:white_player_1_id],
        )
        game = Game.new(full_attrs_for_two_players)

        expect(game.valid?).to be(false)
      end

      it "is invalid when there are 2 players, but the player 1/2 ids aren't the same" do
        full_attrs_for_two_players = full_attrs.merge(
          white_player_1_id: full_attrs[:white_player_2_id],
          black_player_1_id: full_attrs[:black_player_2_id],
        )
        game = Game.new(full_attrs_for_two_players)

        expect(game.valid?).to be(false)
      end
    end
  end
end
