class AddRefreshToPlayers < ActiveRecord::Migration[5.0]
  def change
	add_column :players, :refresh_pending, :boolean
  end
end
