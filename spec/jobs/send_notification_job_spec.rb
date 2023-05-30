require 'rails_helper'

RSpec.describe SendNotificationJob, type: :job do
  let!(:user) { create(:user) }
  let!(:shared) { create(:shared, user: user) }

  it "broadcasts a notification to NotificationsChannel" do
    expect {
      perform_enqueued_jobs do
        SendNotificationJob.perform_later(shared.id, shared.url, shared.title, user.name, user.email)
      end
    }.to have_broadcasted_to("NotificationsChannel").with({
      id: shared.id,
      url: shared.url,
      title: shared.title,
      name: user.name,
      email: user.email
    })
  end
end
