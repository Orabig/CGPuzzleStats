json.extract! player, :id, :cgid, :pseudo, :rank, :level, :refresh_pending, :last_displayed, :updated_at 
json.url player_url(player, format: :json)