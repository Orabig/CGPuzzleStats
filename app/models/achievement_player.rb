class AchievementPlayer < ApplicationRecord
	belongs_to :achievement
	belongs_to :player
end
