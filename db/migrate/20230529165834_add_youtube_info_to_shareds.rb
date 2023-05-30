class AddYoutubeInfoToShareds < ActiveRecord::Migration[7.0]
  def change
    add_column :shareds, :title, :string
    add_column :shareds, :description, :text
    add_column :shareds, :upvote, :integer, default: 0
    add_column :shareds, :downvote, :integer, default: 0
  end
end
