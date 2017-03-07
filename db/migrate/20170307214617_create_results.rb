class CreateResults < ActiveRecord::Migration[5.0]
  def change
    create_table :results do |t|
      t.integer :player_id
      t.integer :language_id
      t.integer :puzzle_id
      t.boolean :last
      t.boolean :onboarding

      t.timestamps
    end
  end
end
