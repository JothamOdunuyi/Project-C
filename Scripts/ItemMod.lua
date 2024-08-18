export type ItemType = "Material" | "QuestItem"

-- So u can do Apple.Class > "Item"
function new(Name : string , Desc : string, Type : ItemType , Icon : number)
	return setmetatable({
		Name = Name,
		Desc = Desc,
		Icon = Icon or nil,
		Type = Type,
		Class = "Item",
	},
	
	{__call = function(t, amount)
		local newItem = DeepCopyTable(t)
		newItem.Amount = amount or 1
		return newItem
	end,
	
	__index = function(t, i)
		if i == "FullName" then
			return t.Name:gsub(" ", "_")
		end
	end,

	})

end

 function DeepCopyTable(t)
	local copy = {}
	for key, value in pairs(t) do
		if type(value) == "table" then
			copy[key] = DeepCopyTable(value)
		else
			copy[key] = value
		end
	end
	return copy
end

return {
	Wood = new("Wood", "Plain wood.", "Material", 7466356907),
	Apple = new("Apple", "It probably came from a healthy tree.", "Material", 137510460),
	Golden_Apple = new("Golden Apple", "JUICER PULL! 0.1% drop rate", "Material", 6028728414),
	Protection_Stone = new("Protection Stone", "It seems to contain a peaceful aura.", "Material", 6995306743),
	Destruction_Stone = new("Destruction Stone", "It seems to contain a raging aura.", "Material", 2746747290),
	Weakened_Corrupt_Core_Fragements = new("Weakened Corrupt Core Fragements", "There is a little amount strange energy omitting from it", "Material", 12135709647),
	Torn_Journal_Page = new("Torn Journal Page", "Perhaps with more one can make out what it says.", "Material", 0),
	Husk_Shreddings = new("Husk Shreddings", "Remnants of a Husk. Some may find this really useful.", "Material", 0),
	Broken_Balbo_Pebble = new("Broken Balbo Pebble", "It's incredbily sturdy despite being broken.", "Material", 0),
	Broken_Verstecken_Horn = new("Broken Verstecken Horn", "Touching its horn makes you feel off...", "Material", 0),
	Dusk_Claw = new("Dusk Claw", "These things hurt bad!", "Material", 0),
	Corrupt_Finger = new("Corrupt Finger", "A power spilt into 20.", "Material", 0),
	Hollow_Roku_Fragment = new('<font color ="#FF0000">Hollow Roku Fragment</font>', '<stroke color="#FF0000" joins="miter" thickness="2" transparency="0.25">You can hear a slight whisper... "Forgive me... Martial Lo-" "</stroke>.', "Material", 0),
	Broken_Mask = new("Broken Mask", "You can almost hear its rage...", "Material", 0),
	Broken_Teeth = new("Broken Teeth", "The rotten, broken teeth of Husks.", "Material", 0),
	Small_Bones = new("Small Bones", "These seem to be the bones of a small human...", "Material", 0),
	Old_Necklace = new("Old Necklace", "A necklace for one who was once human", "Material", 0),
	Large_Bones = new("Large Bones", "The bones of humans, it seems like they've been gnawed on", "Material", 0),
	Dirty_Rags = new("Dirty Rags", "The dirty rags of clothes", "Material", 0),
	Glowing_Eyes = new("Glowing Eyes", "A pair of glowing eyes.. I wonder why they still emit light?", "Material", 0),
	Worn_Teddy_Bear = new("Worn Teddy Bear", "The worn teddy bear of a child.", "Material", 0),
	Marven_Claws = new("Marven Claws", "The claws of a Marven, they could slice through skin with just a touch", "Material", 0),
	Mysterious_Crystal = new("Mysterious Crystal", "These mysterious crystals seem to shudder in your hands, I should be careful with these.", "Material", 0),
	Ruby = new("Ruby", "This red gemstone fills you with a sense of passion and protection as it shines.", "Material", 0),
	Sapphire = new("Sapphire", "Your health and goodness feels uplifted when you hold this blue gem in your hands.", "Material", 0),
	Emerald = new("Emerald", "The green shine fills you with a sense of eloquence, looking into it causes your head to flash with thoughts", "Material", 0),
	Coal = new("Coal", "Boring old coal. Dont carry it without gloves, unless you want stained hands", "Material", 0),
	Mysterious_Rock = new("Mysterious Rock", "This strange colourful rock is a mystery, you've never seen anything like it", "Material", 0),
	Flimsy_Handle = new("Flimsy Handle", "This handle seems to have come from a weapon, it doesn't look usable", "Material", 0),
	Ragged_Hood = new("Ragged Hood", "A bandits hood. It smells a bit though...", "Material", 0),
	Balbo_Segment = new("Balbo Segment", "A larger piece of a Balbo, why would you hurt them?", "Material", 0),
	Quartz_Crystal = new("Quartz Crystal", "These quartz crystals grow slowly along the sides of Balbos, they're said to sell for a high price", "Material", 0),
	Broken_Chain = new('<font color ="#AA00FF">Broken Chain</font>', '<stroke color="#FF0000" joins="miter" thickness="2" transparency="0.25"></stroke>.', "Material", 0),

}