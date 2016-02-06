require_relative 'languages.rb'
require 'mechanize'
require 'pry'

#working..
#original   with euromillones, la-primitiva, gordo-primitiva, bonoloto
#redefined  with loteria-nacional

class Game
  include Languages

  attr_reader :game, :logo_src, :jackpot_str, :jackpot_int, :date_game, :date_game_str, :time_game_utc, :time_limit_utc, :time_left, :price_bet
  attr_accessor :priority

  def initialize(game,lang,zone_time_fix)

    #vars defined by subclass game
    #valids name's games:
    #euromillones, la-primitiva, gordo-primitiva, bonoloto, loteria-nacional, la-quiniela
    @game = game
    @zone_time_fix = zone_time_fix
    #euromillones: 19.30, primitiva: 20.15, gordo: 20.00, bonoloto: 20.00, loteria-nacional: [jueves: 19.30, saturday: 11.30]
    @time_limit_utc = nil
    #euromillones[2,5], primitiva[4,6], gordo[0](special: date_bet is 6), bonoloto(1..6).to_a, loteria-nacional[4,6]
    @wday_games = nil
    #euromillones 2, primitiva 1, gordo 1.5, bonoloto 1, loteria-nacional [thursday: 3, saturday: 6, special: 15 // take with mechanize]
    @price_bet = nil
    #the game quiniela is not available when there is not soccer ligue
    @available = true
    
    @lang = lang

    #mechanize vars
    @agent = Mechanize.new
    @logo_url = 'http://www.selae.es/es/web-corporativa/comunicacion/identidad-corporativa'
    @info_url = 'http://www.loteriasyapuestas.es/es/' + game
    @logo_src = 'http://www.selae.es'
    @page_info = nil
    @jackpot_int = nil
    @jackpot_str = nil

    #calculate vars
    @date_game = nil
    @time_game_utc = nil
    @date_game_str = nil
    @time_left = nil

    #to setter by external class
    @priority = nil
    
  end

  def run
    mechanize
    set_dates_attributes
  end

private

  def mechanize
    get_img_src
    get_info
  end

  def get_info
    @page_info = @agent.get(@info_url)
    get_jackpot_src
  end

  def get_img_src
    title_html = {
      euromillones: 'Euromillones',
      'la-primitiva': 'La Primitiva',
      'gordo-primitiva': 'El Gordo de la Primitiva',
      bonoloto: 'BonoLoto',
      'loteria-nacional': 'Lotería Nacional',
      'la-quiniela': 'La Quiniela'
    }
    page_logo = @agent.get(@logo_url)
    @logo_src += page_logo.search("a[title='#{title_html[@game.to_sym]}']")[0].attr('href')
  end

  def get_jackpot_src
    jackpot_text_all = @page_info.search("div.listado")[0].search('div.bote')[0]
    @jackpot_str = jackpot_text_all ? jackpot_text_all.text.delete("\t") : ""
    @jackpot_int = split_html_text_to_i('jackpot',@jackpot_str)
  end

  def split_html_text_to_i(var,html_text_all)
    html_text_all_to_arr = html_text_all.split(':')
    html_text_with_euro_sym = html_text_all_to_arr[1]
    html_text_with_euro_sym_to_arr = html_text_with_euro_sym.split(' ')
    html_text_number = html_text_with_euro_sym_to_arr[0]
    html_numbers_arr = html_text_number.split('')
    html_numbers_arr.shift if html_text_number[0].to_i == 0    
    if  var == 'jackpot'
      html_text_number = html_numbers_arr.join
      html_numbers_arr = html_text_number.split('.')
    end
    var = html_numbers_arr.join.to_i
  end

  def set_dates_attributes
    @date_game = set_date_game
    @date_game_str = date_to_string
    @time_left = set_time_left
  end

  def set_date_game(fix_days=0)
    week_day = Time.now.wday + fix_days
    week_day = week_day >= 7 ? week_day - 7 : week_day
    if @wday_games.include?(week_day)
      date = Date.today + fix_days
      set_time_limit if !@time_limit_utc
      #fix_days and this code fixs date_game when the game is closed
      date = Time.now > Time.utc(date.year, date.mon, date.mday, @time_limit_utc[:hour], @time_limit_utc[:min]).getlocal ? set_date_game(1) : date
      return date
    else
      fix_days += 1
      set_date_game(fix_days)
    end
  end

  def set_time_limit
    #defined by loteria-nacional
  end

  def date_to_string
    date_str = "#{Languages::DAY_NAMES[@lang.to_sym][@date_game.wday]}, "
    case @lang
      when 'es'
        date_str += "#{@date_game.mday} de #{Languages::MONTH_NAMES[@lang.to_sym][@date_game.mon]} de"
      when 'en'
        date_str += "#{Languages::MONTH_NAMES[@lang.to_sym][@date_game.mon]} #{@date_game.mday},"
    end
    date_str += " #{@date_game.year}"
    return date_str
  end

  def set_time_left
    @time_game_utc = Time.utc(@date_game.year, @date_game.mon, @date_game.mday, @time_limit_utc[:hour], @time_limit_utc[:min])
    time_remaining = calculate_months_weeks_days_hours_or_minutes_remaining
    return time_remaining
  end

  def calculate_months_weeks_days_hours_or_minutes_remaining
    time_game_fixed = @time_game_utc + (@zone_time_fix*60*60)
    return calculate_months_or_below_time_remaining(time_game_fixed)
  end

  def calculate_months_or_below_time_remaining(time_game_fixed)
    months_remaining = time_game_fixed.mon - Time.now.mon
    if months_remaining == 0
      return calculate_weeks_or_below_time_remaining(time_game_fixed)
    else
      #return the bet's month
      return {:month => "#{Languages::MONTH_NAMES[@lang.to_sym][time_game_fixed.mon]}"}
    end
  end

  def calculate_weeks_or_below_time_remaining(time_game_fixed)
    weeks_remaining = time_game_fixed.to_date.cweek - Time.now.to_date.cweek
    if weeks_remaining == 0 
      return calculate_days_or_below_time_remaining(time_game_fixed)
    else
      #not return weeks = days/7, return nº changes of weeks
      return weeks_remaining == 1 ? {:weeks => Languages::MESSAGE[:weeks_remaining][@lang.to_sym]} : {:weeks => weeks_remaining}
    end
  end  

  def calculate_days_or_below_time_remaining(time_game_fixed)
    days_remaining = time_game_fixed.day - Time.now.day
    if days_remaining == 0
      return calculate_hours_or_mins_remaining(time_game_fixed)
    else
      #fix case 'gordo' day_bet is saturday and day_game is sunday
      days_remaining -= 1 if @game == 'gordo-primitiva'
      return {:days => days_remaining, :name => "#{Languages::DAY_NAMES[@lang.to_sym][@date_game.wday]}"}
    end
  end

  def calculate_hours_or_mins_remaining(time_game_fixed)
    hours_remaining = time_game_fixed.hour - Time.now.hour
    if hours_remaining == 0
      return calculate_mins_remaining(time_game_fixed)
    else
      return {:hours => hours_remaining}
    end
  end

  def calculate_mins_remaining(time_game_fixed)
    mins_remaining = time_game_fixed.min - Time.now.min
    return {:mins => mins_remaining}
  end

end