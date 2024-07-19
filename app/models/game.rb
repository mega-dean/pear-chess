class Game < ApplicationRecord
  validates :turn_duration, presence: true
  validates :board_size, presence: true
  validates :current_turn, presence: true
  validate :pairs_have_unique_players

  has_many :pairs

  attribute :current_turn, default: 0

  private

  def pairs_have_unique_players
    player_ids = Set.new

    self.pairs.each do |pair|
      if player_ids.include?(pair.white_player_id)
        errors.add(:base, "Pair #{pair.id} white_player_id #{pair.white_player_id} is already part of this game")
      else
        player_ids.add(pair.white_player_id)
      end

      if player_ids.include?(pair.black_player_id)
        errors.add(:base, "Pair #{pair.id} black_player_id #{pair.black_player_id} is already part of this game")
      else
        player_ids.add(pair.black_player_id)
      end
    end
  end
end
