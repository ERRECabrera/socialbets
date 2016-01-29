class UsersController < ApplicationController

  def form
    @user = User.new
    render 'form', layout: 'clean'
  end

  def create
    user = User.new(user_params)
    if user.save
      render status: :created, json: { notice: 'User created'}
    else
      render status: :unprocessable_entity, :json => { error: "unprocessable"}
    end
  end

private
  
  def user_params
    params.require(:user).permit(
      :email, :password
    )    
  end

end
