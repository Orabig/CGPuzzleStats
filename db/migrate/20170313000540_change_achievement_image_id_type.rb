class ChangeAchievementImageIdType < ActiveRecord::Migration[5.0]
  def change
    change_column :achievements, :image_binary_id, :integer, limit: 8
  end
end
