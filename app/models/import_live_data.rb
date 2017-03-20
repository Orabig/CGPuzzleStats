class ImportLiveData  
  
  # Charge tous les résultats de tous les puzzles pour un joueur et stocke en base
  def refresh_player (player)
    puzzles = Puzzle.all.without_community
	api = CodingameApi.new
	# Charge la matrice puzzle/languages pour ce joueur
	refresh_player_puzzles_langages(api,player,puzzles)
	# Charge tous les achievements pour ce joueur
	refresh_player_achievements(api,player)
	# TODO : refresh des infos du player (rank)
	player.refresh_pending = false
	player.last_refreshed = Time.now
	player.save!
  end

  def refresh_player_puzzles_langages (api,player,puzzles)
	for puzzle in puzzles
		# Array of {"id"=>"Bash", "solved"=>true, "last"=>false, "onboarding"=>false}
		results = api.puzzle_player_langages(puzzle,player)
		for result in results
			if result['solved']
				isLast = result['last']
				isOnboarding = result['onboarding']
				lang = Language.find_or_create_by name: result['id']
				r = Result.find_or_create_by( language: lang, puzzle: puzzle, player: player )				
				r.is_last=isLast
				r.is_onboarding=isOnboarding
				r.save!
			end
		end
	end
  end
  
  def refresh_player_achievements (api,player)
	results = api.player_achievements(player)
	for result in results
		achievement = Achievement.find_or_create_by text_id: result.delete('id')
		achievement.compute_puzzle_id
		# Save AchievementPlayer data
		progress = result.delete 'progress'
		completionTime = result.delete 'completionTime'

		# Persist Achievement
		# Maps the keys for update
		result.delete 'puzzleId'
		result['category'] = result.delete 'categoryId'
		result['group'] = result.delete 'groupId'
		# puzzleId => puzzle_id, ...
		result = result.transform_keys{ |key| key.to_s.underscore }
		achievement.update!(result);

		# Persist AchievementPlayer
		if progress > 0
			ap = AchievementPlayer.where(achievement_id: achievement.id, player_id: player.id).first_or_create
			ap.update_attributes(progress: progress, completion_time: completionTime)
		end
	end
	"ok"
  end
  
  def refresh_language_achievement
	connection = ActiveRecord::Base.connection
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
			connection.execute "UPDATE achievements SET language_id = #{lang.id} WHERE achievements.group = 'coder-#{name}';"
    	end
    end
  end
  
end
