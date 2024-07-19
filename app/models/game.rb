class Game < ApplicationRecord
  validates :turn_duration, presence: true
  validates :board_size, presence: true
  validates :current_turn, presence: true
  validates :white_player_1_id, presence: true
  validates :black_player_1_id, presence: true
  validates :white_player_2_id, presence: true
  validates :black_player_2_id, presence: true
  validate :two_or_four_players

  attribute :current_turn, default: 0

  def self.create_two_player!(player_1, player_2, attrs)
    self.create_four_player!(player_1, player_1, player_2, player_2, attrs)
  end

  def self.create_four_player!(player_1, player_2, player_3, player_4, attrs)
    self.create!(attrs.merge(
      white_player_1_id: player_1.id,
      black_player_1_id: player_2.id,
      white_player_2_id: player_3.id,
      black_player_2_id: player_4.id,
    ))
  end

  def players
    User.where(id: player_ids)
  end

  def player_ids
    [
      white_player_1_id,
      black_player_1_id,
      white_player_2_id,
      black_player_2_id,
    ]
  end

  private

  def two_or_four_players
    uniq_ids = player_ids.uniq

    if uniq_ids.count == 2
      if self.white_player_1_id != self.black_player_1_id ||
          self.white_player_2_id != self.black_player_2_id
        errors.add("both player_1 columns should be the same")
      end
    elsif uniq_ids.count != 4
      errors.add("need to have 2 or 4 unique player ids")
    end
  end
end
