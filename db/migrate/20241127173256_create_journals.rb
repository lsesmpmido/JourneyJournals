class CreateJournals < ActiveRecord::Migration[7.2]
  def change
    create_table :journals do |t|
      t.string :journal_name, null: false
      t.text :description
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :journals, :journal_name, unique: false
  end
end
