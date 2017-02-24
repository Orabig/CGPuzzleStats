json.extract! puzzle, :id, :cgid, :title, :description, :detailsPageUrl, :level, :prettyId, :solvedCount, :type, :achievementCount, :created_at, :updated_at
json.url puzzle_url(puzzle, format: :json)