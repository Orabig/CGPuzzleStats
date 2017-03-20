class AddLanguageToAchievements < ActiveRecord::Migration[5.0]
  def up
    add_reference :achievements, :language, foreign_key: true, null: true

	for lang in Language.all
		if lang.name.nil?
			lang.delete
		else
			name = lang.name.downcase
			if name == 'vb.net'
				name = 'vbnet'
			end
			if name == 'swift3'
				name = 'swift'
			end
			execute "UPDATE achievements SET language_id = #{lang.id} WHERE achievements.group = 'coder-#{name}';"
		end
	end
  end
  
  def down
    remove_reference :achievements, :language, foreign_key: true
  end
end
