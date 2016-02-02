class FakersController < ApplicationController
  require './lib/fakers/faker_games.rb'

  # /games
  def games
    Faker_games.new
  end

end
