class UsersController < ApplicationController

  # /user/form
  def form
    @user = User.new
    render 'form', layout: 'clean'
  end

  # /user/create
  def create
    user = User.new(user_params)
    if user.save
      redirect_to login_path(params)
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
