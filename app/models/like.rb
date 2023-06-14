class Like < ApplicationRecord
  belongs_to :user
  belongs_to :shared

  after_create :update_shared_votes_after_create
  after_update :update_shared_votes_after_update
  after_destroy :update_shared_votes_after_destroy

  private

  def update_shared_votes_after_create
    if is_like
      shared.increment!(:upvote)
    else
      shared.increment!(:downvote)
    end
  end

  def update_shared_votes_after_update
    return unless saved_change_to_is_like?

    if is_like?
      shared.increment!(:upvote)
      shared.decrement!(:downvote)
    else
      shared.decrement!(:upvote)
      shared.increment!(:downvote)
    end
  end

  def update_shared_votes_after_destroy
    if is_like?
      shared.decrement!(:upvote)
    else
      shared.decrement!(:downvote)
    end
  end
end
