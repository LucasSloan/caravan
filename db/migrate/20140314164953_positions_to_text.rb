class PositionsToText < ActiveRecord::Migration
  def up
    change_column :users, :locations, :text
  end
  def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :users, :locations, :string
  end
end
