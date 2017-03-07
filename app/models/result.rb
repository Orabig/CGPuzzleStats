class Result < ApplicationRecord
  belongs_to :player
  belongs_to :puzzle
  belongs_to :language
  
  validates :player, presence: true
  validates :puzzle, presence: true
  validates :language, presence: true
end
