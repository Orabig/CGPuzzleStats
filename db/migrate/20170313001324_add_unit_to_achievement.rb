class AddUnitToAchievement < ActiveRecord::Migration[5.0]
  def change
    add_column :achievements, :unit, :string
  end
end
