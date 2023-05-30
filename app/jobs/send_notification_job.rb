class SendNotificationJob < ApplicationJob
  queue_as :default

  def perform(id, url, title, name, email)
    ActionCable.server.broadcast("NotificationsChannel", {
      id:,
      url:,
      name:,
      email:,
      title:
    })
  end
end
