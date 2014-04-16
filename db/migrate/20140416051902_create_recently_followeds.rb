class CreateRecentlyFolloweds < ActiveRecord::Migration
  def change
    create_table :recently_followeds do |t|
      t.integer :followed
      t.references :user, index: true

      t.timestamps
    end
  end
end
