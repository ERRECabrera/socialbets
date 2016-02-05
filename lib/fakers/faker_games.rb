class Faker_games

  attr_reader :euro, :quini, :primi, :loto, :gordo

  def initialize
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