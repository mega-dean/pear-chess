# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "email_#{i}@example.com" }
    sequence(:username) { |i| "username_#{i}" }
    password { "password" }
  end

  factory :game do
    turn_duration { Game::VALID_TURN_DURATIONS.first }
    board_size { Game::VALID_BOARD_SIZES.first }

    association :top_white_player, factory: :user
    association :top_black_player, factory: :user
    association :bottom_white_player, factory: :user
    association :bottom_black_player, factory: :user
  end


  factory :move do
    association :game
    association :user
    turn { 1 }
    src { 0 }
    dest { 1 }
  end
end
