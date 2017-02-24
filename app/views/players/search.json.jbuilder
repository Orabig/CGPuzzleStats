json.array! @players do |cguser|
  json.cgid cguser["codingamer"]["userId"]
  json.rank cguser["rank"]
  json.pseudo cguser["pseudo"]
  json.level cguser["codingamer"]["level"]
end