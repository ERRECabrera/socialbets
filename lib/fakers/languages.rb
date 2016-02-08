module Languages

  GAME_NAMES = {
    euromillones: {
      :en => 'Euromillions',
      :es => 'Euromillones'
    },
    'la-primitiva': {
      :en => 'Primitiva',
      :es => 'La Primitiva'
    },
    'gordo-primitiva': {
      :en => 'Gordo',
      :es => 'El Gordo de la Primitiva'
    },
    bonoloto: {
      :en => 'BonoLoto',
      :es => 'BonoLoto'
    },
    'loteria-nacional': {
      :en => 'Spanish Lottery',
      :es => 'Lotería Nacional'
    },
    'la-quiniela': {
      :en => 'Football pools',
      :es => 'La Quiniela'
    }
  }

  ROUND = {
    :en => 'Round',
    :es => 'Jornada'
  }

  DAY_NAMES = {
    :en => Date::DAYNAMES,
    :es => %w{Domingo Lunes Martes Miércoles Jueves Viernes Sábado}
  }

  MONTH_NAMES = {
    :en => Date::MONTHNAMES,
    :es => %w{nil Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre}
  }

  MESSAGE = {
    :weeks_remaining => {
      :en => 'The next week',
      :es => 'La próxima semana'
    }
  }

end