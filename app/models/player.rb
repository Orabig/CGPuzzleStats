class Player < ApplicationRecord
  has_many :results, dependent: :destroy
  
  def needsRefresh
	(updated_at + 5.minutes).past? and not refresh_pending
  end
end
