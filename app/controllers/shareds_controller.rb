class SharedsController < ApplicationController
  include AuthenticateHelper
  skip_before_action :authenticate_user, only: [:index]

  def index
    begin
      page = params.fetch(:page, 1).to_i
      per_page = params.fetch(:per_page, 10).to_i

      total_records = Shared.count
      total_pages = (total_records.to_f / per_page).ceil

      offset = (page - 1) * per_page
      @shared = Shared.all.order(created_at: :desc).limit(per_page).offset(offset)

      render json: {
        data: @shared,
        pagination: {
          total_pages: total_pages,
          current_page: page,
          total_records: total_records,
          per_page: per_page
        }
      }, include: [:user], status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Shared not found"}, status: :not_found
    end
  end

  def create
    url_input = shared_params[:url]
    result = nil
    begin
      result = HttpRequestHelper.get_youtube_video_info(url_input)
      if result["items"].size != 1
        raise ArgumentError, "url video is invalid"
      end
    rescue
      return render json: { error: "url video is invalid" }, status: :bad_request
    end

    item = result["items"].first
    snippet = item["snippet"]
    title = snippet["title"]
    description = snippet["description"]

    new_shared_params = {
      url: url_input,
      title: title,
      description: description
    }
  
    @shared = current_user.shareds.new(new_shared_params)
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
