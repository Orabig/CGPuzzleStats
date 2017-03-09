class FixColumnName < ActiveRecord::Migration[5.0]
  def change
	rename_column :results, :last, :is_last
	rename_column :results, :onboarding, :is_onboarding
  end
end
