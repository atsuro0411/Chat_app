class CreateFriendships < ActiveRecord::Migration[8.0]
  def change
    create_table :friendships do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :addressee, null: false, foreign_key: { to_table: :users }
      t.integer    :status,    null: false, default: 0
      t.index [ :requester_id, :addressee_id ], unique: true
      t.timestamps
    end
  end
end
