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
    @day_names = {
      :en => Date::DAYNAMES,
      :es => %w{Domingo Lunes Martes Miércoles Jueves Viernes Sábado}
    }
    @month_names = {
      :en => Date::MONTHNAMES,
      :es => %w{nil Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre}
    }
    @agent = Mechanize.new
    @logo_url = 'http://www.selae.es/es/web-corporativa/comunicacion/identidad-corporativa'
    @info_url = 'http://www.loteriasyapuestas.es/es/' + game
    @date_game = nil
    @time_game_utc = nil
    @time_limit_utc = {hour: 20, min: 00}
    #euromillones: 19.30, primitiva: 20.15, gordo: 20.00, bonoloto: 20.00, loteria-nacional: [jueves: 19.30, saturday: 11.30]
    @wday_games = [4,6] #monday1..7sunday
    #euromillones[2,5], primitiva[4,6], gordo[0](special: date_bet is 6), bonoloto(1..6).to_a, loteria-nacional[4,6]
    @price_bet = 2
    #euromillones 2, primitiva 1, gordo 1.5, bonoloto 1, loteria-nacional [thursday: 3, saturday: 6, special: 15 /take mechanize]
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

=begin
    if @game == 'loteria-nacional'
      #url = http://www.loteriasyapuestas.es/es/buscador?gameId=09&type=nextDraws
      title_name = page_info.search("div.noCelebrados")[0].search('div.cuerpoRegionSup p.negrita')[0].text

      price_text_all = page_info.search("div.noCelebrados")[0].search('div.cuerpoRegionIzq p')[0].text
      price_text_all_to_arr = price_text_all.split(':')
      price_text_with_euros = price_text_all_to_arr[1]
      price_text_with_euros_to_arr = price_text_with_euros.split(' ')
      price_number_text = price_text_to_arr[0]
      price_chars_arr = price_number_text.split("")
      price_chars_arr.shift
      price = price_chars_arr.join.to_i
      @price_bet = price
      
      jackpot_html = page_info.search("div.noCelebrados")[0].search('div.bote')[0]
      @jackpot_srt = jackpot_html ? jackpot_html.text : ""

      #method add_ticket_number + amount arr
    end
=end
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
      #fix_days and this code fixs date_game when the game is closed
      date = Time.now > Time.utc(date.year, date.mon, date.mday, @time_limit_utc[:hour], @time_limit_utc[:min]).getlocal ? set_date_game(1) : date
      return date
    else
      fix_days += 1
      set_date_game(fix_days)
    end
  end

  def date_to_string
    date_str = "#{@day_names[@lang.to_sym][@date_game.wday]}, "
    case @lang
      when 'es'
        date_str += "#{@date_game.mday} de #{@month_names[@lang.to_sym][@date_game.mon]} de"
      when 'en'
        date_str += "#{@month_names[@lang.to_sym][@date_game.mon]} #{@date_game.mday},"
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
    months_remaining = time_game_fixed.mon - Time.now.mon
    if months_remaining == 0
      weeks_remaining = time_game_fixed.to_date.cweek - Time.now.to_date.cweek
      if weeks_remaining == 0 
        days_remaining = time_game_fixed.day - Time.now.day
        if days_remaining == 0
          hours_remaining = time_game_fixed.hour - Time.now.hour
          if hours_remaining == 0
            mins_remaining = time_game_fixed.min - Time.now.min
            return {:mins => mins_remaining}
          else
            return {:hours => hours_remaining}
          end
        else
          #fix case 'gordo' day_bet is saturday and day_game is sunday
          days_remaining -= 1 if @game == 'gordo-primitiva'
          return {:days => days_remaining}
        end
      else
        #not return weeks = days/7, return nº changes of weeks
        return {:weeks => weeks_remaining}
      end
    else
      #return the bet's month
      return {:month => "#{@month_names[@lang][time_game_fixed.mon]}"}
    end
  end

end

euro = Game.new('la-primitiva','es',1)