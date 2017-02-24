class AddRankToPlayers < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :rank, :integer
  end
end
