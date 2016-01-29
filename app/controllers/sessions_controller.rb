class SessionsController < ApplicationController

  def control
    user = User.find_by(email: user_params[:email])
    if user
      redirect_to login_path(params)
    else
      redirect_to(user_create_path(user: params[:user]))
    end
  end

  def create
    user = User.find_by(email: user_params[:email])
    if user && user.authenticate(user_params[:password])
      session[:user_id] = user.id
      render status: :created, :json => { notice: "sessions open"}
    else
      render status: :unprocessable_entity, :json => { error: "unprocessable"}
    end
  end

  def destroy
    session.clear
    redirect_to(root_path)
  end

private
  
  def user_params
    params.require(:user).permit(
      :email, :password
    )    
  end

end
