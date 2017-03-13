class AddIndices < ActiveRecord::Migration[5.0]
  def change
	add_index(:achievement_players, [:achievement_id, :player_id], unique: true)

	add_index(:achievements, :puzzle_id, unique: false)

	add_index(:languages, :name, unique: true)

	add_index(:players, :cgid, unique: true)	

	add_index(:puzzles, :cgid, unique: true)	

	add_index(:results, [:language_id, :player_id, :puzzle_id], unique: true)	
	
  end
end
