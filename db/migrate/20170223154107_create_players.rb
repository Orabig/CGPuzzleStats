class CreatePlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :players do |t|
      t.integer :cgid
      t.string :pseudo
      t.integer :level

      t.timestamps
    end
  end
end
