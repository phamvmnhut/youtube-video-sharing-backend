class UsersController < ApplicationController
  include AuthenticateHelper
  skip_before_action :authenticate_user, only: [:show]

  def show
    begin
      @user = User.find(params[:id])
      render json: { data: @user }, include: [:shareds], status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found"}, status: :not_found
    end
  end

end
