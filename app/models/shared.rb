class Shared < ApplicationRecord
  belongs_to :user

  yt_regexp = /((http(s)?:\/\/)?)(www\.)?((youtube\.com\/)|(youtu.be\/))[\S]+/
  validates :url, presence: true, format: { with:  yt_regexp }
  after_create_commit { broadcast_message }

  private

  def broadcast_message
    SendNotificationJob.perform_later(:id, :url, user.name, user.email)
  end

end
