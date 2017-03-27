# README

How to launch for first time :

Require : docker-composer version 1.6


TODO : edit .env.web et .env.db

Run into production :

AILS_ENV=production docker-compose up --force-recreate -d
RAILS_ENV=production docker-compose run web rake db:setup


Access to web site, then click on "Seed puzzles"

RAILS_ENV=production ./rails.sh console
> ImportLiveData.new.refresh_language_achievement

TODO : merge these two init steps into a simple one


