class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.float :latitude
      t.float :longitude
      t.datetime :timestamp
      t.references :user, index: true

      t.timestamps
    end
  end
end
