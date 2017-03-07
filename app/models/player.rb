class Player < ApplicationRecord
  has_many :results, dependent: :destroy
end
