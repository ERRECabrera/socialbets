class Faker_games

  attr_reader :euro, :quini, :primi, :lot_nav, :gordo

  def initialize
    @euro = nil
    @quini = nil
    @primi = nil
    @lot_nav = nil
    @gordo = nil
    @agent = Mechanize.new
  end

private
#aunque casi toda la info está disponible en la misma url(actualmente),
#es preferible para el mantenimiento separarla en distintos métodos y llamadas

#working in connect with ssl certification. problem is not a client ca_certificate
#ex +'/BEGIN CERTIFICATE/,/END CERTIFICATE/p' <(echo | openssl s_client -showcerts -connect juegos.loteriasyapuestas.es:443) -scq > file.crt

  def euromillones
    page_logo = agent.get('http://www.selae.es/es/web-corporativa/comunicacion/identidad-corporativa')
    logo_src = page_logo.search("a[title='Euromillones']")[0].attr('href')
    page_info = agent.get('http://www.loteriasyapuestas.es/es/euromillones')
    jackpot_srt = page.search("div.bote")[0].text.delete("\t")
    #date_game = sorteos martes y jueves
    #hora_límite 
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

{ "result": true, #if objects > 0 
  "objects":[ #select availabre == true
    { "id": 12,
      "draw_name": "Euromillones", #draw_name.es or en..
      "jackpot": "15.000.000 €",
      "prize_distributed": " €",
      "date_time": "14/08/2015", #change to Date_object? this is Date.current?
      "round": "", #possible inheritance
      "priority": "1", #order_by priority
      "available": true,
      "game": { #info game static
        "id": 1,
        "game_name": "Euromillions",
        "minimum_bet": "2.0 €", #change to_f
        "hours_before_closing_draw": "5", #what is the use??
        "created_at": "24/09/2014", #what is the use??
        "updated_at": "24/09/2014" #what is the use??
        },
      "week": "", #possible inheritance, what is the use??
      "tuesday_active": true, #what is the use??
      "original_draw_date": "14/08/2015", #this is Date created_at this_object draw
      "time_left": "0 minutos" #method to return Date.objecto format string?
    },
    { "id": 7,
      "draw_name": "Quiniela",
      "jackpot": "0,00 €",
      "prize_distributed": "0,00 €",
      "date_time": "09/08/2015",
      "round": "1", #jornada?
      "priority": "2",
      "available": true,
      "game": {
        "id": 4,
        "game_name": "Quiniela",
        "minimum_bet": "0.75 €",
        "hours_before_closing_draw": "4",
        "created_at": "02/12/2014",
        "updated_at": "05/08/2015"
        },
      "week": "",
      "tuesday_active": false,
      "original_draw_date": "09/08/2015",
      "time_left": "0 minutos",
      "matches": [
        { "id": 1,
          "match_1": "Athletic-Barcelona",
          "match_2": "Real Madrid-Atletico Madrid",
          "match_3": "Santander-Albacete",
          "match_4": "Valencia-Sevilla",
          "match_5": "Villarreal-Espanyol",
          "match_6": "Coruña-Betis",
          "match_7": "Eibar-Elche",
          "match_8": "Córdoba-Levante",
          "match_9": "Real Sociedad-Málaga",
          "match_10": "Celta-Sporting",
          "match_11": "Alavés-Cádiz",
          "match_12": "Oviedo-Zaragoza",
          "match_13": "Murcia-Jaén",
          "match_14": "Almería-Granada",
          "match_15": "Alcorcón-Leganés",
          "draw_id": 7, #possible data-id_js
          "created_at": "2015-07-06T20:30:45.649+02:00",
          "updated_at": "2015-07-06T20:30:45.649+02:00"
        }
      ]},
    { "id": 13,
      "draw_name": "Primitiva",
      "jackpot": "10.000.000 €",
      "prize_distributed": "10.000.000 €",
      "date_time": "15/08/2015",
      "round": "",
      "priority": "2",
      "available": true,
      "game": {
        "id": 3,
        "game_name": "Primitiva",
        "minimum_bet": "1.0 €",
        "hours_before_closing_draw": "5",
        "created_at": "07/10/2014",
        "updated_at": "04/03/2015"
      },
      "week": "",
      "tuesday_active": true,
      "original_draw_date": "15/08/2015",
      "time_left": "0 minutos"
    },
    { "id": 2,
      "draw_name": "Lotería Navidad",
      "jackpot": "10.000.000 €",
      "prize_distributed": "10.000.000 €",
      "date_time": "22/11/2015",
      "round": "",
      "priority": "3",
      "available": true,
      "game": {
        "id": 2,
        "game_name": "Lottery",
        "minimum_bet": "20.0 €",
        "hours_before_closing_draw": "10",
        "created_at": "07/10/2014",
        "updated_at": "07/10/2014"
      },
      "week": "",
      "tuesday_active": false,
      "original_draw_date": "22/11/2015",
      "time_left": "0 minutos",
      "numbers": [ #select where amount > 0
        { "id": 3,
          "ticket_number": 1203,
          "amount": 0,
          "draw_id": 2,
          "created_at": "2015-09-03T16:23:49.336+02:00",
          "updated_at": "2015-11-10T11:03:54.793+01:00"
        },
        { "id": 4,
          "ticket_number": 86428,
          "amount": 3,
          "draw_id": 2,
          "created_at": "2015-09-03T16:38:21.471+02:00",
          "updated_at": "2015-11-12T19:54:42.652+01:00"
        },
        { "id": 5,
          "ticket_number": 56823,
          "amount": 3,
          "draw_id": 2,
          "created_at": "2015-09-10T16:29:29.331+02:00",
          "updated_at": "2015-11-12T11:27:40.803+01:00"
        },
        { "id": 6,
          "ticket_number": 92034,
          "amount": 4,
          "draw_id": 2,
          "created_at": "2015-09-10T16:29:46.098+02:00",
          "updated_at": "2015-11-12T19:48:03.900+01:00"
        },
        { "id": 7,
          "ticket_number": 75602,
          "amount": 0,
          "draw_id": 2,
          "created_at": "2015-09-10T16:30:04.250+02:00",
          "updated_at": "2015-11-11T19:09:24.979+01:00"
        },
        { "id": 8,
          "ticket_number": 270,
          "amount": 5,
          "draw_id": 2,
          "created_at": "2015-09-10T16:30:21.786+02:00",
          "updated_at": "2015-09-17T17:24:28.094+02:00"
        }
      ]},
    { "id": 8,
      "draw_name": "El Gordo de la Primitiva\t", #tabulador why??
      "jackpot": "10.000.000 €",
      "prize_distributed": "10.000.000 €",
      "date_time": "02/12/2014",
      "round": "",
      "priority": "3",
      "available": true,
      "game": {
        "id": 5,
        "game_name": "Gordo",
        "minimum_bet": "2.0 €",
        "hours_before_closing_draw": "4",
        "created_at": "02/12/2014",
        "updated_at": "02/12/2014"
      },
      "week": "",
      "tuesday_active": true,
      "original_draw_date": "02/12/2014",
      "time_left": "0 minutos"
    }
  ]
}

=end