class Puzzle < ApplicationRecord
  has_many :achievement
  
  scope :without_community, -> { where("level <> ?", "community") }
  scope :by_level, ->(level) { where(:level => level) }
  scope :order_by_level, -> { order(:level) }
end
