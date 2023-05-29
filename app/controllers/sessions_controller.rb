class SessionsController < ApplicationController
  include AuthenticateHelper
  skip_before_action :authenticate_user, only: [:create]

  def create
    @user = User.find_by(email: params[:email])
    puts @user
    if @user && @user.authenticate(params[:password])
      token = JsonWebTokenService.encode({ email: @user.email })
      render json: { auth_token: token, data: @user }
    else
      @user = nil
      render json: { error: "Incorrect Email Or password" }, status: :unauthorized
    end
  end
end
