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
    end
  end

  describe "make" do
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
      Game.make(creator: user, game_params: params)
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
end
