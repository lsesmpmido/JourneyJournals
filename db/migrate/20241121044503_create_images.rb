class CreateImages < ActiveRecord::Migration[7.2]
  def change
    create_table :images do |t|
      t.string :image_name, null: false
      t.text :memo
      t.float :latitude
      t.float :longitude
      t.datetime :date_of_shooting
      t.string :address
      t.json :weather
      t.references :journal, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :images, :image_name, unique: false
  end
end
