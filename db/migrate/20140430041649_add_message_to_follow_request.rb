class AddMessageToFollowRequest < ActiveRecord::Migration
  def change
    add_column :follow_requests, :message, :string
  end
end
