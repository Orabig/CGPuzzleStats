class ImportLiveData  
  
  # Charge tous les résultats de tous les puzzles pour un joueur et stocke en base
  def refresh_player (player)
    puzzles = Puzzle.all.without_community
	api = CodingameApi.new
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
				r.save
			end
		end
	end
  end

  def refresh_players (players)
	for player in players
		refresh_player player
	end
  end

end
