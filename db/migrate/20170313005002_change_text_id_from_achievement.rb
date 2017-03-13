class ChangeTextIdFromAchievement < ActiveRecord::Migration[5.0]
  def change
    rename_column :achievements, 'textId', :text_id
  end
end
