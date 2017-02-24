class CreatePuzzles < ActiveRecord::Migration[5.0]
  def change
    create_table :puzzles do |t|
      t.integer :cgid
      t.string :title
      t.string :description
      t.string :detailsPageUrl
      t.string :level
      t.string :prettyId
      t.integer :solvedCount
      t.string :type
      t.integer :achievementCount

      t.timestamps
    end
  end
end
