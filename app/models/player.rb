class Player < ApplicationRecord
  has_many :results, dependent: :destroy
  has_many :achievement_player, dependent: :destroy
  
  def needsRefresh(timeout)
    # Explication : le champ last_displayed est mis à jour quand un joueur est demandé à l'affichage
	# Ca permet de ne PAS rafraichir tous les Players qui sont chargés uniquement lors de la phase
	# de recherche de pseudo
	refresh_pending.nil? or (not last_displayed.nil? and (last_refreshed.nil? or (last_refreshed + timeout.minutes).past?) and not refresh_pending)
  end 

  def mustRefresh
	# Explication : Si le joueur vient d'être créé, alors il faut le refresh.
	not last_displayed.nil? and last_refreshed.nil?
  end
  
  def isRefreshTimeout
	not refresh_pending.nil? and refresh_pending and (last_refreshed + 5.minutes).past?
  end
  
  def refresh
	self.refresh_pending = true
	self.last_refreshed = Time.now
	save
	ResultRefreshJob.perform_later(self)

  end
end
