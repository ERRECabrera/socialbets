class FakersController < ApplicationController
  require './lib/fakers/faker_games.rb'

  # /games
  def games
    fake_request = Faker_games.new
    render :json => fake_request.games.to_json
  end

end
