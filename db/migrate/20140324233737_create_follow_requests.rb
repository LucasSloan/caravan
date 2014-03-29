class CreateFollowRequests < ActiveRecord::Migration
  def change
    create_table :follow_requests do |t|
      t.integer :requester
      t.references :user, index: true

      t.timestamps
    end
  end
end
