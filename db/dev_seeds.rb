Game.valid_form_options[:number_of_players].each do |number_of_players|
  Game.valid_form_options[:board_size].each do |board_size|
    Game.valid_form_options[:turn_duration].each do |turn_duration|
      [WHITE, BLACK].each do |play_as|
        creator = FactoryBot.create(:user)

        Game.make!(
          creator: creator,
          game_params: {
            number_of_players: number_of_players,
            turn_duration: turn_duration,
            board_size: board_size,
            play_as: play_as,
          },
        )
      end
    end
  end
end
