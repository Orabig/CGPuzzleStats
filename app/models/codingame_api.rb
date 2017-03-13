class CodingameApi
  include HTTParty
  # debug_output $stdout
  
  base_uri "https://www.codingame.com/services"
  
  # Cherche le/les codingamer par pseudo
  def player_search (pseudo)
    request=[ 1, {'keyword' => pseudo}, '', true, 'global' ]
	@response = self.class.post '/LeaderboardsRemoteService/getGlobalLeaderboard',:body => request.to_s
  end
  
  # Charge le leaderboard d'un puzzle. Ne fonctionne que pour les puzzle qui on un champ leaderboardId !!
  def puzzle_leaderboard (puzzle)
    request = [ puzzle.leaderboardId,'','global' ]
    @response = self.class.post '/LeaderboardsRemoteService/getPuzzleLeaderboard',:body => request.to_s
  end
  
  # Charge tous les achievements d'un joueur
  def player_achievements (player)
	request = [ player.cgid ]
	@response = self.class.post '/AchievementRemoteService/findByCodingamerId',:body => request.to_s
	post_process
  end
  
  # Charge la liste des langages pour lesquels le joueur J a résolu le puzzle P
  def puzzle_player_langages (puzzle, player)
	request = [ puzzle.cgid,player.cgid ]
    @response = self.class.post '/PuzzleRemoteService/findAvailableProgrammingLanguages',:body => request.to_s
	post_process
  end
  
  def post_process
	if @response.message=="OK"
		body = JSON.parse(@response.body)
		if body["success"]
			@error = false
			body["success"]
		else
			@error = body["error"]
		end
	else
		@error = @response
	end
  end
end