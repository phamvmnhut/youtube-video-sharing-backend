class SharedsController < ApplicationController
  include AuthenticateHelper
  skip_before_action :authenticate_user, only: [:index]

  def index
    begin
      @shared = Shared.all
      render json: { data: @shared } , include: [:user], status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Shared not found"}, status: :not_found
    end
  end

  def create
    @shared = current_user.shareds.new(shared_params)
    if @shared.save
      render json: { success: "successfully created", data: @shared }, status: :ok
    else
      render json: { error: @shared.errors.messages.map { |msg, desc|
      msg.to_s + " " + desc[0] }.join(',') }, status: :not_found
    end
  end

  def show
    begin
      @shared = current_user.shareds.find(params[:id])
      render json: { data: @shared } , include: [:user], status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Shared not found"}, status: :not_found
    end
  end
  
  def destroy
    shared = current_user.shareds.find(params[:id])
    if shared.destroy
      head :no_content
    else
      render json: { error: shared.errors.messages.map { |msg, desc|
      msg.to_s + " " + desc[0] }.join(',') }, status: :not_found
    end
  end

  private
  
  def shared_params
    params.require(:shareds).permit(:url)
  end

end
