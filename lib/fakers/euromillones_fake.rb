class Euromillones < Game

  def initialize(lang="es",zone_time_fix=1)
    super('euromillones',lang,zone_time_fix)

    #mechanize vars
    #redefine if not work with default url  
    #@logo_url = '' work with .get_img_src
    #@info_url = '' work with .get_info
    #@logo_src = '' work with .get_img_src
    
    #set vars
    @time_limit_utc = {hour: 19, min: 30}
    @wday_games = [2,5] #sunday0..6saturday    
    @price_bet = 2    
    
    run
  end

end