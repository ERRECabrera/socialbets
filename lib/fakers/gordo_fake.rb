require_relative 'game_fake.rb'

class Gordo < Game

  def initialize(lang="es",zone_time_fix=1)
    super('gordo-primitiva',lang,zone_time_fix)

    #mechanize vars
    #redefine if not work with default url  
    #@logo_url = '' work with .get_img_src
    #@info_url = '' work with .get_info
    #@logo_src = '' work with .get_img_src 
    
    #set vars
    @time_limit_utc = {hour: 20, min: 00}
    @wday_games = [0] #sunday0..6saturday    
    @price_bet = 1.5
    #fix day_bet is saturday and day_game is sunday
    @condition_to_fix_bet_and_game_date = @game == 'gordo-primitiva'
    @days_to_fix = 1
    
    run
  end

end