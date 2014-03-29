class AddPasswordDigestToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_digest, :string
    remove_column :users, :password
    add_index :users, :username
  end
end
