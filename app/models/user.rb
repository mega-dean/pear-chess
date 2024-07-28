# frozen_string_literal: true

class User < ApplicationRecord
  include Clearance::User

  validates :username, presence: true, uniqueness: true

  def playing_in?(game)
    !!self.team(game)
  end

  def team(game)
    ids = game.ids(self)

    if ids.include?(:top_white) || ids.include?(:top_black)
      TOP
    elsif ids.include?(:bottom_white) || ids.include?(:bottom_black)
      BOTTOM
    end
  end

  def colors(game)
    colors = []
    ids = game.ids(self)

    if ids.include?(:top_white) || ids.include?(:bottom_white)
      colors << WHITE
    end

    if ids.include?(:top_black) || ids.include?(:bottom_black)
      colors << BLACK
    end

    colors
  end
end
