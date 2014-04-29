class CreateCurrentOrigins < ActiveRecord::Migration
  def change
    create_table :current_origins do |t|
      t.references :user, index: true
      t.float :latitude
      t.float :longitude
      t.timestamp :timestamp

      t.timestamps
    end
  end
end
