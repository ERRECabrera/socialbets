require_relative 'game_faker.rb'

class Loteria < Game

  attr_reader :title_name, :tickets_numbers

  def initialize(lang="es",zone_time_fix=1)
    super('loteria-nacional',lang,zone_time_fix)

    #redefine if not work with default url  
    #@logo_url = '' work with .get_img_src
    @info_url = 'http://www.loteriasyapuestas.es/es/buscador?gameId=09&type=nextDraws'
    #@logo_src = '' work with .get_img_src
    
    @time_limit_utc = nil
    @wday_games = [4,6] #sunday0..6saturday
    @price_bet = nil # loteria-nacional [thursday: 3, saturday: 6, special: ? /take mechanize]

    #new_var
    @title_name = nil
    @tickets_numbers = []

    run
  end

  def run
    super
    ticket_count = rand(1..5)
    ticket_count.times do |number|
      add_random_ticket_numbers
    end
  end

private

  def get_info
    super
    get_title_name
    get_price_bet
  end

  def get_jackpot_src
    jackpot_text_all = @page_info.search("div.noCelebrados")[2].search('div.bote')[0]
    @jackpot_str = jackpot_text_all ? jackpot_text_all.text : nil
    @jackpot_int = @jackpot_str ? split_html_text_to_i('jackpot',@jackpot_str) : nil
  end

  def get_title_name
    @title_name = @page_info.search("div.noCelebrados")[0].search('div.cuerpoRegionSup p.negrita')[0].text
  end
     
  def get_price_bet
    price_text_all = @page_info.search("div.noCelebrados")[0].search('div.cuerpoRegionIzq p')[0].text
    @price_bet = split_html_text_to_i('price',price_text_all)
  end

  def set_time_limit
    #loteria-nacional: [thursday: 19.30, saturday: 11.30]
    @time_limit_utc = Date.today.wday == @wday_games[0] ? {hour: 19, min: 30} : {hour: 11, min: 30}
  end

  def add_random_ticket_numbers
    number = ""
    5.times {|n| number += rand(0..9).to_s }
    @tickets_numbers << {ticket_number: number, amount: rand(0..7)}
  end

end

loto = Loteria.new
binding.pry