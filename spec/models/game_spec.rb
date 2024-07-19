require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:full_attrs) do
    {
      turn_duration: 10,
      board_size: 8,
    }
  end

  describe "validations" do
    [
      :turn_duration,
      :board_size,
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

    describe "pairs" do
      it "is valid when pairs all have unique player ids" do
        game = FactoryBot.create(:game)
        5.times do
          FactoryBot.create(:pair, game: game)
        end

        expect(game.valid?).to be(true)
      end

      it "is invalid when any pairs have the same player id" do
        game = FactoryBot.create(:game)
        5.times do
          FactoryBot.create(:pair, game: game)
        end

        game.reload

        game.pairs.first.update!(white_player_id: game.pairs.last.black_player_id)

        expect(game.valid?).to be(false)
      end
    end
  end
end
