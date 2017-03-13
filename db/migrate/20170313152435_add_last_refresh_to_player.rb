class AddLastRefreshToPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :last_refreshed, :datetime
  end
end
