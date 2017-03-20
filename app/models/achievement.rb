class Achievement < ApplicationRecord
  has_many :achievement_player, dependent: :destroy
  belongs_to :puzzle, optional: true
  belongs_to :language, optional: true
  
  # This comes from a CG API flaw, where puzzle_id always equals to 0...
  # We should then look for textId=~/PZ_(\d+)P_P$puzzleId$/
  def compute_puzzle_id
	if groups = /PZ_(\d+)P_P(\d+)/.match(text_id)
		cgid = groups[2]
	else
	    return
	end
	# Another error from CG
	if not /PZ_(\d+)P_P53$/.match(text_id).nil?
		cgid = 55
	end
	if not /PZ_(\d+)P_P52$/.match(text_id).nil?
		cgid = 54
	end
	if not /PZ_(\d+)P_P3$/.match(text_id).nil?
		cgid = 121
	end
	self.update_attributes puzzle_id: Puzzle.find_by(cgid: cgid).id
  end
end
