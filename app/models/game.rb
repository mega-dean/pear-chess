class Game < ApplicationRecord
  validates :turn_duration, presence: true
  validates :board_size, presence: true
  validates :current_turn, presence: true
  validate :pairs_have_unique_players

  has_many :pairs, dependent: :destroy

  attribute :current_turn, default: 0

  class << self
    def make(creator:, game_params:)
      game = Game.create!(game_params.slice(:board_size, :turn_duration))

      pair_count = game_params[:number_of_players].to_i / 2
      pair_count.times do |idx|
        pair_params = if idx == 0
                        creator_color = if game_params[:play_as] == RANDOM
                                          [WHITE, BLACK].sample
                                        else
                                          game_params[:play_as]
                                        end
                        { "#{creator_color}_player_id" => creator.id }
                      else
                        {}
                      end

        game.pairs.create!(pair_params)
      end

      game
    end

    def valid_form_options
      {
        number_of_players: [2, 4],
        board_size: [8, 10, 12],
        turn_duration: [5, 10, 15],
        play_as: [WHITE, BLACK, RANDOM],
      }
    end
  end

  def broadcast_fen(fen)
    broadcast_replace_to(
      "fen-tool-container",
      target: "fen-tool-container",
      partial: "games/fen_tool_board",
      locals: {
        fen: fen,
      },
    )
  end

  def initial_pieces
    {
      8 => [
        "KRN2nrk",
        "BBN2nbb",
        "NNN2nnn",
        "8",
        "8",
        "NNN2nnn",
        "BBN2nbb",
        "KRN2nrk",
      ].join("/"),
      10 => [
        "KRQN2nqrk",
        "BRN4nrb",
        # "BNN2nnn",
        # "8",
        # "8",
        # "NNN2nnn",
        # "BBN2nbb",
        # "KRN2nrk",
      ].join("/"),
      12 => "",
    }[self.board_size]
  end

  def start
    self.update!(
      current_turn: 1,
      pieces: self.initial_pieces,
    )
  end

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
