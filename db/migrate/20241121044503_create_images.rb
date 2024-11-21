class CreateImages < ActiveRecord::Migration[7.2]
  def change
    create_table :images do |t|
      t.string :image_name
      t.text :memo
      t.float :latitude
      t.float :longitude
      t.datetime :captured_at

      t.timestamps
    end
  end
end
