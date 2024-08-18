local TPS = game:GetService("TeleportService")

local TPRequirementsMod = require(game.ServerStorage.ModuleScripts.TPRequirements)
local event = game.ReplicatedStorage.RemoteEvents.ServerTP

local notifcationMsgs = {
	partyFailed = '<font color="#FF0000">Teleportation Failed!</font> One or more party members do not meet the requirements.',
	soloTPFailed = '<font color="#FF0000">Teleportation Failed!</font> You do not meet the requirements.',
	notPartyLeader = '<font color="#FF0000">Teleportation Failed!</font> You are not the party leader.',
	successTP = '<font color="#00FF00">Teleporting!</font>'
}

local TPEffects = {
	ShishinGate = false
}

local Funcs = {}

function SetShishinGateVisibility(plr : Player, visibility : boolean)
	game.ReplicatedStorage.RemoteEvents.LocalGeneric:FireClient(plr,"ShishinGateEnabled", true)
end

function TeleportEffect(placeID)
	if placeID == 14601320616 and not TPEffects.ShishinGate then
		TPEffects.ShishinGate = true
		local gate = workspace.QuestNpcs["Shishin Gate"]
		local gateRoot = gate.HumanoidRootPart
		
		gateRoot["Gate Open"]:Play()
		gateRoot.Wind:Play()
		gateRoot.Gust:Play()
		
		coroutine.wrap(function()
			local orgVolume = gateRoot.Wind.Volume
			local windVolume = orgVolume
			task.wait(4)
			for i = 1, 10 do
				task.wait(.25)
				windVolume -= orgVolume / 10
				gateRoot.Wind.Volume = windVolume
			end
			gateRoot.Wind:Stop()
			gateRoot.Wind.Volume = orgVolume
			TPEffects.ShishinGate = false
		end)()
	end
end

function NotifyPlayer(plr : Player, msg : string, visibleTime : number)
	local NotificationEvent =  plr.Backpack.Events.Notification
	NotificationEvent:FireClient(plr, msg, visibleTime or nil)
end

function NotifiyAllPlayersInParty(partyFolder : Folder, msg : string, visibleTime : number)
	for _, member in pairs(partyFolder:GetChildren()) do
		local memberPlr = member.Value
		if memberPlr == nil then continue end
		
		local NotificationEvent =  memberPlr.Backpack.Events.Notification
		NotificationEvent:FireClient(memberPlr, msg, visibleTime or nil)
	end
end

function InParty(plr)
	-- For cleaner code, does not return party values
	return plr.InParty.Value ~= nil 
end

function IsPartyLeader(plr)
	-- Assumes player is in party
	return plr.InParty.Value.Name == "Leader"
end

function CheckRequirements(plr, placeID)
	local GameValues = plr["Game Values"]
	local EquipmentBinnableFunction = GameValues.Inventory.EquipmentBinnableFunction

	if EquipmentBinnableFunction:Invoke("QuestJournalRequest", "QuestRequirement", TPRequirementsMod[placeID]()) then
		print(plr.Name, "passed TP requirements")
		return true
	else
		print(plr.Name, "FAILED TP requirements")
		return false
	end
end

function PartyRequirementsMet(plr, placeID)
	
	if InParty(plr) then
		local partyFolder = plr.InParty.Value.Parent
		local partyMembers = {}

		for _, member in pairs(partyFolder:GetChildren()) do
			local memberPlr = member.Value
			
			if not memberPlr then continue end
			if not CheckRequirements(memberPlr, placeID) then return end

			table.insert(partyMembers, memberPlr)

		end

		return true, partyMembers
		
	else
		return CheckRequirements(plr, placeID), {plr}
	end

end

function PartyHasMoreThanOneMember(plr)
	local partyFolder = plr.InParty.Value.Parent
	local partyMembersCount = 0

	for _, member in pairs(partyFolder:GetChildren()) do
		if not member.Value then continue end
		
		partyMembersCount+=1
		
		return true
	end
	
	return false
end

function ReturnAllPartyMembers(plr)
	local partyFolder = plr.InParty.Value.Parent
	local partyMembers = {}
	
	for _, member in pairs(partyFolder:GetChildren()) do
		if not member.Value then continue end
		table.insert(partyMembers, member)
	end
	
	return partyMembers
end

function CheckRequirementsAndTP(plr, placeID)
	local parryMetRequirements, partyMembers = PartyRequirementsMet(plr, placeID)
	
	if parryMetRequirements then
		if #partyMembers == 1 then
			TPS:Teleport(placeID, plr)
			TeleportEffect(placeID)
			NotifyPlayer(plr, notifcationMsgs.successTP)
			print("Teleporting player...")
		else
			TPS:TeleportPartyAsync(placeID, partyMembers)
			TeleportEffect(placeID)
			NotifiyAllPlayersInParty(plr.InParty.Value.Parent, notifcationMsgs.successTP)
			print("Teleporting party...")
		end
	else
		if InParty(plr) then
			NotifiyAllPlayersInParty(plr.InParty.Value.Parent, notifcationMsgs.partyFailed)
		else
			NotifyPlayer(plr, notifcationMsgs.soloTPFailed)
		end
		
		SetShishinGateVisibility(plr, true)
	end
	
end

function Funcs.TP(plr, placeID)
	
	SetShishinGateVisibility(plr, false)
	print("Got TP request from player:", plr, "to place ID:", placeID)
	if InParty(plr) then
		print(plr.Name, "is in party")
		if PartyHasMoreThanOneMember(plr) then
			print(plr.Name, "is in a party with more than one member")
			if IsPartyLeader(plr) then
				print(plr.Name, "is the party leader")
				CheckRequirementsAndTP(plr, placeID)
			else
				print(plr.Name, "is not the party leader")
				NotifyPlayer(plr, notifcationMsgs.notPartyLeader)
				SetShishinGateVisibility(plr, true)
			end
			
		else
			print(plr.Name, "is in party with theirself")
			CheckRequirementsAndTP(plr, placeID)
		end
		
	else
		print(plr.Name, "is NOT in party")
		CheckRequirementsAndTP(plr, placeID)
	end
end

event.OnServerEvent:Connect(function(plr, eventName, ...)
	Funcs[eventName](plr, ...)
end)