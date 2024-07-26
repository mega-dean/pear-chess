# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "email_#{i}@example.com" }
    sequence(:username) { |i| "username_#{i}" }
    password { "password" }
  end

  factory :game do
    turn_duration { 10 }
    board_size { 8 }
  end

  factory :pair do
    association :game
    association :white_player, factory: :user
    association :black_player, factory: :user
  end

  factory :move do
    association :game
    association :user
    turn { 1 }
    src { 0 }
    dest { 1 }
  end
end
