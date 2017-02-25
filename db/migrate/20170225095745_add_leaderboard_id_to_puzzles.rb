class AddLeaderboardIdToPuzzles < ActiveRecord::Migration[5.0]
  def change
    add_column :puzzles, :leaderboardId, :string
  end
end
