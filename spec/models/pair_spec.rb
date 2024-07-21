require "rails_helper"

RSpec.describe Pair, type: :model do
  it "is valid with all fields" do
    pair = FactoryBot.create(:pair)

    expect(pair.valid?).to be(true)
  end

  it "requires game_id to be present" do
    pair = FactoryBot.build(:pair, game_id: nil)

    expect(pair.valid?).to be(false)
  end

  describe "player ids" do
    it "is valid when both players are nil" do
      pair = FactoryBot.build(:pair)

      expect(pair.valid?).to be(true)
    end

    it "is invalid when players are the same" do
      pair = FactoryBot.create(:pair)
      pair.white_player_id = pair.black_player_id

      expect(pair.valid?).to be(false)
    end
  end
end
