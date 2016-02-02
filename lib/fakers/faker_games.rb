class Faker_games

  attr_reader :euro, :quini, :primi, :loto, :gordo

  def initialize
    @agent = Mechanize.new
    @euro = euromillones
    @quini = nil
    @primi = nil
    @loto = nil
    @gordo = nil
  end

#private
#aunque casi toda la info está disponible en la misma url(actualmente),
#es preferible para el mantenimiento separarla en distintos métodos y llamadas

#working in connect with ssl certification. problem: is not a client ca_certificate
#ex +'/BEGIN CERTIFICATE/,/END CERTIFICATE/p' <(echo | openssl s_client -showcerts -connect juegos.loteriasyapuestas.es:443) -scq > file.crt

  def euromillones   
    page_logo = @agent.get('http://www.selae.es/es/web-corporativa/comunicacion/identidad-corporativa')
    logo_src = 'http://www.selae.es' + page_logo.search("a[title='Euromillones']")[0].attr('href')
    page_info = @agent.get('http://www.loteriasyapuestas.es/es/euromillones')
    jackpot_srt = page_info.search("div.bote")[0].text.delete("\t")
    date_game = set_date_game('euromillones')
    date_game_str = date_to_string(date_game,'es')
    time_left = set_time_left(date_game,'euromillones')
    binding.pry
  end

  def set_time_left(date,type)
    case type
    when 'euromillones'
      time_game = Time.utc(date.year, date.mon, date.mday, 19, 30)
      time_remaining = calculate_months_weeks_days_hours_or_minutes_remaining(time_game)
    end
    return time_remaining
  end

  def calculate_months_weeks_days_hours_or_minutes_remaining(time_game)
    time_fixed = time_game.getlocal
    months_remaining = time_fixed.mon - Time.now.mon
    if months_remaining == 0
      days_remaining = time_fixed.day - Time.now.day
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

  def set_date_game(type,fix_num=0)
    week_day = Time.now.wday + fix_num
    case type
    when 'euromillones'
      if week_day <= 2 || week_day > 5 #0126
        date = calculate_date_game(week_day-fix_num,2,5) #se resta fix_num para evitar cálculo erroneo
      elsif week_day > 2 && week_day <= 5 #345
        date = calculate_date_game(week_day-fix_num,5)
      end
      #el fix_num y esto soluciona los casos en q estamos en el mismo día del game pero ha pasado el time_game
      date = Time.now > Time.utc(date.year, date.mon, date.mday, 19, 30).getlocal ? set_date_game(type,1) : date
    end
    return date
  end

  def calculate_date_game(week_day,limit_below=nil,limit_above=nil)
    days_to_sum = limit_below ? limit_below - week_day : 0
    days_to_subtrac = (limit_above && week_day > limit_above) ? week_day - limit_above : 0
    date_game = Date.today + days_to_sum - days_to_subtrac
    return date_game
  end

  def date_to_string(date,lang)
    day_names = {
      :en => Date::DAYNAMES,
      :es => %w{Domingo Lunes Martes Miércoles Jueves Viernes}
    }
    month_names = {
      :en => Date::MONTHNAMES,
      :es => %w{nil Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre}
    }
    date_str = "#{day_names[lang.to_sym][date.wday]}, "
    case lang
    when 'es'
      date_str += "#{date.mday} de #{month_names[lang.to_sym][date.mon+1]} de"
    when 'en'
      date_str += "#{month_names[lang.to_sym][date.mon+1]} #{date.mday}rd,"
    end
    date_str += " #{date.year}"
    return date_str
  end

end

=begin

games = [
  'Euromillones',
  "Quiniela",
  "Primitiva",
  "Lotería Navidad",
  "El Gordo de la Primitiva"
]

objects_attr = {
  "id": 0,
  get "draw_name": "Name", #draw_name.es or en..
  get "jackpot": "00.000.000 €",
  get "date_time": "14/08/2015", #change to Date_object? this is date_game
  get "round": "", #possible inheritance jornada if quiniela game
  "priority": 1, #order_by priority
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