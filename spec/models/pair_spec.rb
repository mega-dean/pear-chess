require 'rails_helper'

RSpec.describe Pair, type: :model do
  let(:game) { FactoryBot.create(:game) }
  let(:white_player) { FactoryBot.create(:user) }
  let(:black_player) { FactoryBot.create(:user) }

  let(:full_attrs) do
    {
      game_id: game.id,
      white_player_id: white_player.id,
      black_player_id: black_player.id,
    }
  end

  it "is valid with all fields" do
    pair = Pair.new(full_attrs)

    expect(pair.valid?).to be(true)
  end

  it "is invalid when missing a field" do
    full_attrs.each do |attr, _|
      pair = Pair.new(full_attrs.without(attr))

      expect(pair.valid?).to be(false)
    end
  end

  describe "player ids" do
    it "is invalid when players are the same" do
      pair = Pair.new(full_attrs.merge(white_player_id: black_player.id))

      expect(pair.valid?).to be(false)
    end
  end
end
