class Player < ApplicationRecord
  has_many :results, dependent: :destroy
  has_many :achievement_player, dependent: :destroy
  
  def needsRefresh
    # Explication : le champ last_displayed est mis � jour quand un joueur est demand� � l'affichage
	# Ca permet de ne PAS rafraichir tous les Players qui sont charg�s uniquement lors de la phase
	# de recherche de pseudo
	refresh_pending.nil? or (not last_displayed.nil? and (updated_at + 5.minutes).past? and not refresh_pending)
  end 

  def mustRefresh
	# Explication : Si le joueur vient d'�tre cr��, alors il faut le refresh.
	not last_displayed.nil? and (updated_at == created_at)
  end
end
