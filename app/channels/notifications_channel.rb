class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    @current_user = AuthenticateHelper.authenticate_user_for_channel params[:jwt]
    if @current_user 
      stream_for @current_user
      # stream_from "some_channel"
      stream_from "NotificationsChannel"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    reject
  end
end
