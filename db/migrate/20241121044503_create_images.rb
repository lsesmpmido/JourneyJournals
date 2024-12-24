class CreateImages < ActiveRecord::Migration[7.2]
  def change
    create_table :images do |t|
      t.string :image_name
      t.text :memo
      t.float :latitude
      t.float :longitude
      t.datetime :date_of_shooting
      t.references :journal, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
