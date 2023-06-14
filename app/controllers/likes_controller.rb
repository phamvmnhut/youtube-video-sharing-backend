class LikesController < ApplicationController
  def create
    @shared = Shared.find_by(id: params[:shared_id])

    if @shared.nil?
      render json: { error: 'Invalid shared_id' }, status: :unprocessable_entity
      return
    end

    unless params[:is_like].present?
      render json: { error: 'is_like parameter is missing' }, status: :unprocessable_entity
      return
    end

    begin
      @like = @shared.likes.create!(user: current_user, is_like: params[:is_like])
      render json: { success: 'Like created successfully.', data: @like }, status: :created
    rescue ActiveRecord::RecordNotUnique => e
      render json: { error: 'Like already exists. Please use the update method instead.' }, status: :conflict
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: @like.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def show
    @like = current_user.likes.find_by(id: params[:id])

    if @like
      render json: { success: 'Like found', data: @like }, status: :ok
    else
      render json: { error: 'Like not found' }, status: :not_found
    end
  end

  def show_by_shared
    shared_id = params[:shared_id]
    @like = current_user.likes.find_by(shared_id: shared_id)

    if @like
      render json: { success: 'Like found', data: @like }, status: :ok
    else
      render json: { error: 'Like not found' }, status: :not_found
    end
  end

  def update
    @like = Like.find_by(id: params[:id])
    if @like.present?
      begin
        @like.toggle!(:is_like)
        render json: { success: 'Like updated successfully.', data: @like }, status: :ok
      rescue => e
        render json: { error: @like.errors.messages.map { |msg, desc|
          msg.to_s + " " + desc[0] }.join(', ') }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Like not found.' }, status: :not_found
    end
  end

  def destroy
    @like = current_user.likes.find_by(id: params[:id])

    if @like.present?
      @like.destroy
      render json: { success: 'Like deleted successfully' }, status: :ok
    else
      render json: { error: 'Like not found or not owned by current user' }, status: :not_found
    end
  end
end
