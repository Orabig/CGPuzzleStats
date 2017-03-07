class Puzzle < ApplicationRecord
  scope :without_community, -> { where("level <> ?", "community") }
  scope :by_level, ->(level) { where(:level => level) }
  scope :order_by_level, -> { order(:level) }
end
