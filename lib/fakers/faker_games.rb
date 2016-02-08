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
    @games = self.to_hash
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

  def to_hash
    games_hash = []
    @games.each_with_index do |game,index|
      games_hash << {
        draw_name: game.draw_name,
        logo_src: game.logo_src,
        jackpot_int: game.jackpot_int,
        jackpot_str: game.jackpot_str,
        date_game: game.date_game,
        date_game_str: game.date_game_str,
        time_game_utc: game.time_game_utc,
        time_left: game.time_left,
        price_bet: game.price_bet
      }
      if game.game == 'loteria-nacional'
        games_hash[-1].merge!(
          title_name: game.title_name,
          tickets_numbers: game.tickets_numbers
        )
      end
      if game.game == 'la-quiniela'
        games_hash[-1].merge!(
          round: game.round,
          round_str: game.round_str,
          matches: game.matches
        )
      end      
    end
    return games_hash
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