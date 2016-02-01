class SiteController < ApplicationController

  # /
  def index
    if current_user
      @current_user = current_user
    else
      @user = User.new
    end      
    render 'index'
  end
end
