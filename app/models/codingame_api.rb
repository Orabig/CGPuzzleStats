class CodingameApi
  include HTTParty
  # debug_output $stdout
  
  base_uri "https://www.codingame.com/services"
  
  # Charge le leaderboard d'un puzzle. Ne fonctionne que pour les puzzle qui on un champ leaderboardId !!
  def puzzle_leaderboard (puzzle)
	request = "[\"#{ puzzle.leaderboardId }\",\"\",\"global\"]"
    self.class.post '/LeaderboardsRemoteService/getPuzzleLeaderboard',:body => request
  end
  
  # Charge la liste des langages pour lesquels le joueur J a résolu le puzzle P
  def puzzle_player_langages (puzzle, player)
	request = "[\"#{ puzzle.cgid }\",\"#{ player.cgid }\"]"
    self.class.post '/PuzzleRemoteService/findAvailableProgrammingLanguages',:body => request
  end
end