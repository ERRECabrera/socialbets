require 'mechanize'
require 'pry'

class Game

  attr_reader :logo_src, :jackpot_srt, :date_game_str, :time_left

  def initialize(game="",lang="es",zone_time_fix)
    #valids name's games:
    #euromillones, la-primitiva, gordo-primitiva, bonoloto, loteria-nacional, la-quiniela
    @game = game
    @lang = lang
    @zone_time_fix = zone_time_fix
    @agent = Mechanize.new
    @logo_url = 'http://www.selae.es/es/web-corporativa/comunicacion/identidad-corporativa'
    @info_url = 'http://www.loteriasyapuestas.es/es/' + game
    @date_game = nil
    @time_game_utc = nil
    @time_limit_utc = {hour: 20, min: 00}
    #euromillones: 19.30, primitiva: 20.15, gordo: 20.00, bonoloto: 20.00
    @wday_games = (1..6).to_a #monday1..7sunday
    #euromillones[2,5], primitiva[4,6], gordo[0](pero se juega hasta el 6), bonoloto[1..6]
    @logo_src = 'http://www.selae.es'
    @jackpot_srt = nil
    @date_game_str = nil
    @time_left = nil
    run
    binding.pry
  end

  def run
    mechanize
    set_dates_attributes
  end

  def mechanize
    get_img_src
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
    page_info = @agent.get(@info_url)
    @jackpot_srt = page_info.search("div.bote")[0].text.delete("\t")
  end

  def set_dates_attributes
    @date_game = set_date_game
    @date_game_str = date_to_string
    @time_left = set_time_left
  end

  def set_date_game(fix_num=0)
    week_day = Time.now.wday + fix_num
    limit_below = @wday_games[0]
    limit_above = @wday_games[1]
    case @game
    when 'others'
      week_day_fix = week_day-fix_num #subtract fix_num to avoid wrong calc
      if @wday_games.size == 1
        limit = limit_below
        date = week_day <= limit ? calculate_date_game(week_day_fix,limit) : calculate_date_game(week_day_fix,nil,limit)
      elsif @wday_games.size == 2
        if week_day <= limit_below
          date = calculate_date_game(week_day_fix,limit_below)
        elsif week_day > limit_above || (week_day > limit_below && week_day <= limit_above)
          date = calculate_date_game(week_day_fix,nil,limit_above)
        end
      end
      #el fix_num y esto soluciona los casos en q estamos en el mismo día del game pero ha pasado el time_game
      date = Time.now > Time.utc(date.year, date.mon, date.mday, @time_limit_utc[:hour], @time_limit_utc[:min]).getlocal ? set_date_game(1) : date
    when 'bonoloto'
      if @wday_games.include?(week_day)

      end
    end
    return date
  end

  def calculate_date_game(week_day,limit_below,limit_above=nil)
    days_to_sum = limit_below ? limit_below - week_day : limit_above - week_day
    days_to_subtrac = (limit_above && week_day > limit_above) ? week_day - limit_above : 0
    date_game = Date.today + days_to_sum - days_to_subtrac
    return date_game
  end

  def date_to_string
    day_names = {
      :en => Date::DAYNAMES,
      :es => %w{Domingo Lunes Martes Miércoles Jueves Viernes}
    }
    month_names = {
      :en => Date::MONTHNAMES,
      :es => %w{nil Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre}
    }
    date_str = "#{day_names[@lang.to_sym][@date_game.wday]}, "
    case @lang
    when 'es'
      date_str += "#{@date_game.mday} de #{month_names[@lang.to_sym][@date_game.mon+1]} de"
    when 'en'
      date_str += "#{month_names[@lang.to_sym][@date_game.mon+1]} #{@date_game.mday}rd,"
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
    time_fixed = @time_game_utc + (@zone_time_fix*60*60)
    months_remaining = time_fixed.mon - Time.now.mon
    if months_remaining == 0
      days_remaining = time_fixed.day - Time.now.day
      days_remaining -= 1 if @game == 'gordo-primitiva'
      if days_remaining > 7
        weeks_remaining = days_remaining/7
        return {:weeks => weeks_remaining}
      elsif days_remaining == 0
        hours_remaining = time_fixed.hour - Time.now.hour
        if hours_remaining == 0
          mins_remaining = time_fixed.min - Time.now.min
          return {:mins => mins_remaining}
        else
          return {:hours => hours_remaining}
        end
      else
        return {:days => days_remaining}
      end
    else
      return {:months => months_remaining}
    end
  end

end

euro = Game.new('gordo-primitiva','en',1)