class IntegerToReferences < ActiveRecord::Migration[5.0]
  def change
	change_column :achievement_players, :achievement_id, :integer, :null => false, references: :achievements
	change_column :achievement_players, :player_id,      :integer, :null => false, references: :players
	
	change_column :achievements, :puzzle_id, :integer, :null => true, references: :puzzles
	
	change_column :results, :player_id,   :integer, :null => false, references: :players
	change_column :results, :language_id, :integer, :null => false, references: :langages
	change_column :results, :puzzle_id,   :integer, :null => false, references: :puzzles
  end
end
