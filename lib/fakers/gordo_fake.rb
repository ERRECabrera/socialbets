require_relative 'game_faker.rb'

class Gordo < Game

  def initialize(lang="es",zone_time_fix=1)
    super('gordo-primitiva',lang,zone_time_fix)

    #redefine if not work with default url  
    #@logo_url = '' work with .get_img_src
    #@info_url = '' work with .get_info
    #@logo_src = '' work with .get_img_src 
    
    @time_limit_utc = {hour: 20, min: 00}
    @wday_games = [0] #sunday0..6saturday    
    @price_bet = 1.5
    
    run
  end

end

gordo = Gordo.new
binding.pry