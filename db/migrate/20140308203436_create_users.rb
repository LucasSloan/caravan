class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.text :locations
      t.boolean :broadcasting

      t.timestamps
    end
  end
end
