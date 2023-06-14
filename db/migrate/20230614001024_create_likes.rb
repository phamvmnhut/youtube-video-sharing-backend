class CreateLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shared, null: false, foreign_key: true
      t.boolean :is_like

      t.timestamps
    end
    add_index :likes, [:user_id, :shared_id], unique: true
  end
end
