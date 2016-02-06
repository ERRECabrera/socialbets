require 'date'

module Languages

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