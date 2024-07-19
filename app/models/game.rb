class Game < ApplicationRecord
  validates :turn_duration, presence: true
  validates :board_size, presence: true
  validates :current_turn, presence: true

  has_many :pairs

  attribute :current_turn, default: 0
end
