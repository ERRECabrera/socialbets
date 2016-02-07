require_relative 'bonoloto_fake.rb'
require_relative 'euromillones_fake.rb'
require_relative 'gordo_fake.rb'
require_relative 'loteria_fake.rb'
require_relative 'primitiva_fake.rb'
require_relative 'quiniela_fake.rb'

class Faker_games

  attr_reader :games

  def initialize(lang='es',zone_fix=1)
    @lang = lang
    @zone_fix = zone_fix
    @games = []
    add_games
    sort_by_algorithm_priority
  end

  def add_games
    games = [
      Euromillones.new(@lang,@zone_fix),
      Quiniela.new(@lang,@zone_fix),
      Primitiva.new(@lang,@zone_fix),
      Loteria.new(@lang,@zone_fix),
      Gordo.new(@lang,@zone_fix)
    ]
    games.each { |game| @games.push(game) if game.available }
  end

  def sort_by_algorithm_priority
    pointer_games
    set_priority
    sort_by_priority
  end

private

  def pointer_games
    better_to_user
    better_to_socialbets      
  end

  def better_to_user
    point_by_jackpot
    point_by_price_bet('cheap')
  end

  def better_to_socialbets
    point_by_time
    point_by_price_bet('expensive')
  end

  def set_priority
    @games.sort_by! {|game| game.points}
    @games.reverse!
    @games.each_with_index {|game,index| game.priority = index + 1}
  end

  def sort_by_priority
    @games.sort_by! {|game| game.priority}
  end

  def point_by_time
    @games.sort_by! {|game| game.time_game_utc}
    set_points_priority_game
  end

  def point_by_price_bet(price)
    @games.sort_by! {|game| game.price_bet}
    @games.reverse! if price == 'expensive'
    set_points_priority_game
  end

  def point_by_jackpot
    @games.sort_by! {|game| game.jackpot_int}
    @games.reverse!
    set_points_priority_game
  end

  def set_points_priority_game
    @games.each_with_index {|game,index| game.points += @games.size - index}
  end

end

=begin
REFERNCE_OBJ
objects_attr = {
  "id": 0,
  get "draw_name": "Name", #draw_name.es or en..
  get "jackpot": "00.000.000 €",
  get "date_time": "14/08/2015", #change to Date_object? this is date_game
  get "round": "", #possible inheritance jornada if quiniela game
  "priority": 1, #order_by priority add logarith price + time_game + size_bote
  "available": true,
  "game": { #info game static
    "id": 1,
    "game_name": "Euromillions",
    "minimum_bet": 2.0, #change to_f
  },
  get "matches": [ #if game == quiniela
    { "id": 1,
      "match_1": "Athletic-Barcelona",
      "draw_id": 7, #possible data-id_js
    }
  ],
  "numbers": [ #select where amount > 0
    { "id": 3,
      "ticket_number": 1203,
      "amount": 0, #implementar websocket o llamadas ajax cada cierto tiempo
      "draw_id": 2
    }
  ]
}
=end