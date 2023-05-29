class SendNotificationJob < ApplicationJob
  queue_as :default

  def perform(id, url, name, email)
    ActionCable.server.broadcast("NotificationsChannel", {
      id:,
      url:,
      name:,
      email:
    })
  end
end
