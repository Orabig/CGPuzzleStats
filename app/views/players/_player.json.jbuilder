json.extract! player, :id, :cgid, :pseudo, :rank, :level, :created_at, :updated_at
json.url player_url(player, format: :json)