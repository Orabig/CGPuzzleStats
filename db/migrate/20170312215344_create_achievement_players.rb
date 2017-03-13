class CreateAchievementPlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :achievement_players do |t|
      t.integer :achievement_id
      t.integer :player_id
      t.integer :progress
      t.datetime :completion_time

      t.timestamps
    end
  end
end
