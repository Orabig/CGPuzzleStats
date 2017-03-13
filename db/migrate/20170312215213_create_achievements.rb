class CreateAchievements < ActiveRecord::Migration[5.0]
  def change
    create_table :achievements do |t|
      t.string :textId
      t.integer :puzzle_id
      t.string :title
      t.text :description
      t.integer :points
      t.integer :image_binary_id
      t.string :category
      t.string :group
      t.string :level
      t.string :unlock_text
      t.integer :weight
      t.integer :progress_max

      t.timestamps
    end
  end
end
