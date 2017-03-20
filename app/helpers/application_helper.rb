module ApplicationHelper

	def posOrString(val,str)
		if val > 0
			val
		else
			str
		end
	end

	# Extrait d'une liste d'achievement celui qui a la plus grande valeur de "progress_max" inférieure à value
	def getBestAchievement(list, value)
		list.select{ |ach| ach.progress_max <= value }
			.sort{ |a,b| a.progress_max <=> b.progress_max }
			.last
	end
	
	# URL to a CG static file
	def staticFileFromId(id)
		"https://static.codingame.com/servlet/fileservlet?id=#{ id }"
	end
end
