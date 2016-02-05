require_relative 'game_faker.rb'

class Bonoloto < Game

  def initialize(lang="es",zone_time_fix=1)
    super('bonoloto',lang,zone_time_fix)

    #redefine if not work with default url  
    #@logo_url = '' work with .get_img_src
    #@info_url = '' work with .get_info
    #@logo_src = '' work with .get_img_src
    
    @time_limit_utc = {hour: 20, min: 00}
    @wday_games = (1..6).to_a #sunday0..6saturday    
    @price_bet = 1
    
    run
  end

end

bono = Bonoloto.new
binding.pry