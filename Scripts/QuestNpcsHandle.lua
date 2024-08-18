local CollectionService = game:GetService("CollectionService")
local ModuleScriptsFolder = game.ServerStorage.ModuleScripts
local NpcDataMod = require(ModuleScriptsFolder.NpcDataMod)
local LoadValues = game.ServerScriptService.LoadValues
local isDungeon = workspace["World Settings"]:GetAttribute("isDungeon")

local QuestMarkersImages = {
	MainQuest = "rbxassetid://5750849995",
	SideQuest = "rbxassetid://139685071",
}

if not isDungeon then
	for _, questGiver in pairs((CollectionService:GetTagged("DialogueNpcs"))) do
		local data = NpcDataMod[questGiver]

		local Event = questGiver.QuestHandle
		local head = questGiver.Head
		local proximityPromt = head.Prompt
		local questMarker = head.QuestMarker

		local DialougeSystemFolder = workspace.DialogueSystem

		local baseDialogue = DialougeSystemFolder.Base
		local questDialouge = DialougeSystemFolder.Quest
		local otherDialouge = DialougeSystemFolder.Other
		local noQuestsDialouge = otherDialouge.NoQuests
		local nilRequirements = otherDialouge.NotMetRequirement

		--print(questGiver.Name)
		local introductionDialogue = data.IntroDialouge
		local characterName = data.Name
		local Quests = data.Quests or {}

		local frontVector = (questGiver.HumanoidRootPart.CFrame * CFrame.new(0,0,-2)).Position
		introductionDialogue.SpeakerModel:SetAttribute("Default_Orientation", frontVector)
		questGiver.Configuration:SetAttribute("Name", characterName)
		head.NameTag.Tag.Text = characterName
		proximityPromt.ObjectText = characterName

		if Quests and #Quests > 0 and not Quests[1].QuestRequirements then
			questMarker.Marker.Image = QuestMarkersImages[Quests[1].QuestType.."Quest"]
		end

		local DialogueParams = {
			Speaker = characterName,
			SpeakerModel = questGiver,
			--QuestInteractionText = ""
		}

		function GetQuestDataForPlayer(plr) -- Could put this function outside of for loop
			local GameValues = plr["Game Values"]
			local EquipmentBinnableFunction = GameValues.Inventory.EquipmentBinnableFunction

			local QuestJournal = GameValues.Quest.QuestJournal

			-- If not Quests this is reached
			if #Quests == 0 then return noQuestsDialouge end

			for i, quest in ipairs (Quests) do

				local dialogue = quest.Dialogue
				if not quest.Name then error("Quest is nill", quest) end

				local questName = quest.FullName
				local CompletedQuest = QuestJournal.CompletedQuests:GetAttribute(questName)

				-- IF quest complete, check next quest
				if CompletedQuest then
					--If the last quest is complete then show noQuestDialogue else cotinue for loop
					if i ~= #Quests  then continue else
						return dialogue
						-- If all quests are completed, show no quests dialouge
						--return noQuestsDialouge
					end
				end

				local HasQuestAttribute = QuestJournal.HasQuests:GetAttribute(questName) or nil
				local HasQuest = HasQuestAttribute or false
				local MetRequirements = HasQuest and HasQuestAttribute == true or false

				-- IF quest active, send dialouge
				if HasQuestAttribute then
					return dialogue, true
				end

				-- IF NOT Completed AND NOT HasQuest, check if quest requirements met
				local questRequirements = quest.QuestRequirements
				local QuestAvailable = EquipmentBinnableFunction:Invoke("QuestJournalRequest","QuestAvailable", questName)

				if QuestAvailable then
					return dialogue, true
				else
					-- Requirement not met for not quest dialouge
					return nilRequirements, true
				end
			end
		end

		Event.OnServerInvoke = GetQuestDataForPlayer

		proximityPromt.Triggered:Connect(function(plr)
			local GameValues = plr["Game Values"]
			local EquipmentBinnable = GameValues.Inventory.EquipmentRequest
			local inDialouge = plr.Character.CombatValues.inDialogue.Value

			if not inDialouge then
				EquipmentBinnable:Fire("Dialogue", "Start", questGiver)
				game.ReplicatedStorage.DialogueEvents.DialogueRemote:FireClient(plr, introductionDialogue, DialogueParams)	
			else
				local NotificationEvent =  plr.Backpack.Events.Notification
				NotificationEvent:FireClient(plr, "You are already in a dialouge!")
			end
		end)

		if questGiver.Name == "Shishin Gate" then
			head.Prompt.Enabled = false
			head.NameTag.Enabled = false
			print("Shishin Gate interaction on server side disabled")
		end
	end
end

task.wait(2)
LoadValues.NPcsLoaded.Value = true