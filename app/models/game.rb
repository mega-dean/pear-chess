class Game < ApplicationRecord
  validates :turn_duration, presence: true
  validates :board_size, presence: true
  validates :current_turn, presence: true

  def players
    User.where(id: [
      self.white_player_1_id,
      self.black_player_1_id,
      self.white_player_2_id,
      self.black_player_2_id,
    ])
  end
end
