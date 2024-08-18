local module = {}

-- Requirements Exmple
local example = {CompletedQuests = {"Slay_Dummies", "Slay_Dummies_2"}, Levels = {Main = 3}, CharacterStats = {PP = 25} }

-- First Dungeon
module[14601320616] = function ()
	print("TP Requirement for dungeons requested")
	return {CharacterStats = {PP = 25} }-- {CompletedQuests = {"Tournament_Prep",}, CharacterStats = {PP = 50} }
end


return module
