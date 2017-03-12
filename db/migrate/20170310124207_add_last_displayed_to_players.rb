class AddLastDisplayedToPlayers < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :last_displayed, :datetime
  end
end
