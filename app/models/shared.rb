class Shared < ApplicationRecord
  belongs_to :user

  yt_regexp = /((http(s)?:\/\/)?)(www\.)?((youtube\.com\/)|(youtu.be\/))[\S]+/
  validates :url, presence: true, format: { with:  yt_regexp }
  validates :title, presence: true
  validates :description, presence: true

  after_create_commit { broadcast_message }

  private

  def broadcast_message
    SendNotificationJob.perform_later(id, url, title, user.name, user.email)
  end

end
