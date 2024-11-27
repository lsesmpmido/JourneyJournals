class CreateJournals < ActiveRecord::Migration[7.2]
  def change
    create_table :journals do |t|
      t.string :journal_name
      t.text :description

      t.timestamps
    end

    unless column_exists?(:images, :journal_id)
      add_reference :images, :journal, foreign_key: true
    end
  end
end
