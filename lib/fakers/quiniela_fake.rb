require_relative 'game_fake.rb'

class Quiniela < Game

  attr_reader :round, :round_str, :matches

  def initialize(lang="es",zone_time_fix=1)
    super('la-quiniela',lang,zone_time_fix)

    #mechanize vars
    #redefine if not work with default url  
    #@logo_url = '' work with .get_img_src
    #@info_url = '' work with .get_info
    #@logo_src = '' work with .get_img_src
    @round = nil  #work with get_quiniela_info
    @matches = [] #work with set_matches
    @date_game = nil #work with redefined set_date_game

    #set vars
    @time_limit_utc = {hour: 15, min: 00}    
    @price_bet = 1.5
    #fix bet in weekend is the saturday 
    #@condition_to_fix_bet_and_game_date is defined in run method
    @days_to_fix = 1
    
    #calculate vars
    @round_str = nil #work with round_to_string
    #the game quiniela is not available when there is not soccer ligue
    @available = nil #work with set_is_available
      
    #deprecated
    #@wday_games not work with redefined set_date_game here

    run
  end

  def run
    mechanize
    @condition_to_fix_bet_and_game_date = @game == 'la-quiniela' && @date_game.wday == 0
    set_dates_attributes
  end

private

  def get_info
    @page_info = @agent.get(@info_url)
    get_quiniela_info
  end

  def get_quiniela_info(index=0)
    #index fix when game is closed in set_data_game, call recursive this.method
    href_link_vermas = @page_info.search('div.vermas a')[index].attr('href')
    date_game_format = href_link_vermas.split('=')[-1]
    @date_game = set_date_game(date_game_format,index)
    get_jackpot_str(index)
    page_round = @page_info.links_with(href: href_link_vermas)[0].click
    round_text = page_round.search('div.noCelebrados h3')[0].text
    @round = split_round_text_to_i(round_text)
    href_link_mas_informacion = page_round.search('div.noCelebrados a')[2].attr('href')
    page_matches = page_round.links_with(href: href_link_mas_informacion)[0].click
    set_matches(page_matches)
  end

  def set_matches(web)
    teams_hash = get_teams(web)
    dates_arr = get_dates(web)
    times_arr = get_times(web)
    (0..14).each do |index|
      match = {
        "Match_#{index+1}": "#{teams_hash[:local][index]} vs #{teams_hash[:visitor][index]}",
        time_play_utc: Time.parse([dates_arr[index],times_arr[index]].join(' ')).utc
      }
      @matches << match
    end
  end

  def get_times(web)
    match = {
      normal: 'div.cuerpoRegionRight ul',
      special: 'div.cuerpoBloqueInf ul' #pleno al 15
    }
    index = {
      normal: 1,
      special: 4 #pleno al 15 
    }
    times = get_datas_from_table_matches(web,match[:normal],index[:normal])
    times.push(get_datas_from_table_matches(web,match[:special],index[:special]))
  end

  def get_dates(web)
    match = {
      normal: 'div.cuerpoRegionRight ul',
      special: 'div.cuerpoBloqueInf ul' #pleno al 15
    }
    index = {
      normal: 0,
      special: 3 #pleno al 15 
    }
    dates = get_datas_from_table_matches(web,match[:normal],index[:normal])
    dates.push(get_datas_from_table_matches(web,match[:special],index[:special]))
  end

  def get_teams(web)
    teams = {
      local: nil,
      visitor: nil
    }
    match = {
      normal: 'div.cuerpoRegionLeft ul',
      special: 'div.cuerpoBloqueInf ul' #pleno al 15
    }
    index = {
      normal: 1,
      special: 2 #pleno al 15 
    }
    teams[:local] = get_datas_from_table_matches(web,match[:normal],index[:normal])
    teams[:local].push(get_datas_from_table_matches(web,match[:special],index[:normal])[0].sub(' ',''))
    teams[:visitor] = get_datas_from_table_matches(web,match[:normal],index[:special])
    teams[:visitor].push(get_datas_from_table_matches(web,match[:special],index[:special])[0])
    return teams
  end

  def get_datas_from_table_matches(web,html_selector,index)
    datas = []
    web.search(html_selector)[index].search('li').each do |data_li|
      datas.push(data_li.text)
    end
    return datas
  end

  def split_round_text_to_i(round_text)
    round_text_arr = round_text.split(',')
    round_text = round_text_arr[0]
    round_text_chars = round_text.split('')
    round_chars = []
    round_chars.push(round_text_chars[-2])
    round_chars.push(round_text_chars[-1])
    #this fix the first 9 rounds
    round_chars.shift if round_chars[0].to_i == 0
    round = round_chars.join.to_i
  end

  def set_date_game(date_format,index)
    date = Date.parse(date_format)
    game_closed = Time.now > Time.utc(date.year, date.mon, date.mday, @time_limit_utc[:hour], @time_limit_utc[:min]).getlocal
    if game_closed
      index++
      get_quiniela_info(index)
    end
    return date
  end

  def set_dates_attributes
    #@date_game = set_date_game
    @date_game_str = date_to_string
    @time_game_utc = set_time_game_utc
    @time_left = set_time_left
    @round_str = round_to_string
    @available = set_is_available
  end

  def round_to_string
    return "#{Languages::ROUND[@lang]} #{@round}"
  end

  def set_is_available
    return @round ? true : false    
  end

end