export type SkillType = "General" | "Sword" | "Spear" | "Hammer"

function new(Name : string , Desc : string , Icon : number, Type : SkillType)
	return{
		Name = Name,
		Desc = Desc,
		Icon = Icon,
		Type = Type
	}
	
end

local data = {
	Sword = {
		["Sword Beam"] = new("Sword Beam", '<font color="#FF7800">(HOLDABLE)</font> Charge a sword beam into your blade <font color="#FF7800">(Release key)</font> and shoot it out, dealing damage. The speed and damage of the attack is increased once fully charged.', 129697807, "Sword"),
		["Power Leap"] = new("Power Leap", 'Stomp your foot into the ground allow you to leap towards a target. Your next attack will deal more damage. <font color="#FF7800">(If your is not a object your leap will be more precise)</font>.', 6851171266, "Sword"),
		["Fast Strikes"] = new("Fast Strikes", "Fast Swing your blade twice at super speeds.", 560191279, "Sword"),
		["Sword Ki Explosion"] = new("Sword Ki Explosion", "Unleash a great amount of power, sending everything away and dealing damage.", 242323536, "Sword")
	},

	Spear = {
		["Discharge"] = new("Discharge", '<font color="#FF7800">(HOLDABLE, Can be interrupted)</font> Discharge Channel for 2 seconds and then throw the spear towards the target location (Mouse location, Release key). Anything hit will take damage and be stunned for 2 seconds. <font color="#FF7800">(The quicker you pick up the spear the higher its cooldown is reduced)</font>.', 12787893970, "Spear"),
		["Bound"] = new("Bound", '1 charge/dash forward, striking anything in its path, anything <font color="#FF0000">caught in the strike will be “Pierced”</font> <font color="#FF7800">(They become vulnerable to hits/ take more damage for the next 10 seconds, 30-second cooldown)</font>.', 9158731033, "Spear"),
		["Slash and Slice"] = new("Slash and Slice",'Slash and Slice Strike 3 times in a cone shape, each subsequent strike against the same enemy deals increased damage, and <font color="#FF0000">the third strike if hit will inflict “Pierced”</font>', 12988707179, "Spear"),
		["Hidden Technique: Blood Goliath of Xhang"] = new("Hidden Technique: Blood Goliath of Xhang", 'Blood Goliath of Xhang For 20 seconds, any <font color="#FF0000">enemy that’s hit while affected with Pierced will “Bleed”</font>. Gain movement speed while this is active, <font color="#FF0000">Bleed: enemy affected will periodically take damage over time for the next 5 seconds, and can stack up to 3 times</font>.', 12515324258, "Spear")

	},

	Hammer = {
		["Wack'om all"] = new("Wack'om all", '<font color="#FF7800">(HOLDABLE)</font> <font color="#FF0000">Gain 10 Resolve</font>. Slam your hammer down many times, dealing damage per strike in an small area. On the last hit, a Pillar is created ahead of the player.', 6230328976, "Hammer"),
		["Viking Charge"] = new("Viking Charge", '<font color="#FF0000">Gain 5 Resolve</font>. Charge forward in target direction, taking any enemies hit along with you, dealing 5 damage and stunning them at the end for 1 second.  If you hit a wall, gain an additional <font color="#FF0000">10 Resolve</font> and enemies are stunned for an additional 2 seconds. <font color="#FF7800">(Can press key to cancel early / Ground Slam)</font>.', 11759745410, "Hammer"),
		["Champions Bravery"] = new("Champions Bravery", 'Consume all Resolve. Break all Pillars, causing any enemies within the explosion to take damage, and <font color="#FF0000">additional damage equal to the amount of Resolve</font>.', 8980482930, "Hammer"),
		["Fortify"] = new("Fortify", 'Stomp your feet, slowing enemies caught nearby and creating a Pillar, if any player is hit, <font color="#FF0000">gain 5 Resolve</font>. <font color="#FF7800">(3 CHARGES)</font>.', 7354247135, "Hammer")

	},
}

local raw_data = {}

-- Add to raw_data
for _, v in pairs(data) do
	for i, v2 in pairs(v) do
		raw_data[i] = v2
	end
end

return {data, raw_data}
