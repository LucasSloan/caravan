class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.integer :follower_id
      t.references :user, index: true

      t.timestamps
    end
  end
end
