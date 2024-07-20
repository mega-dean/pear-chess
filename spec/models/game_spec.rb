require 'rails_helper'

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

      let!(:pairs) do
        5.times do
          FactoryBot.create(:pair, game: game)
        end

        game.reload.pairs
      end

      it "is valid when pairs all have unique player ids" do
        expect(game.valid?).to be(true)
      end

      it "is invalid when any pairs have the same player id" do
        pairs.first.update!(white_player_id: pairs.last.black_player_id)

        expect(game.valid?).to be(false)
      end
    end
  end
end
