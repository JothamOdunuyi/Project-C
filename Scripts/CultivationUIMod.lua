local module = {}
local TweenService = game:GetService("TweenService")--Get Tween Service
local plr = game.Players.LocalPlayer
local EquipmentFunction = plr:WaitForChild("Game Values").Inventory.EquipmentFunction
local isInStudio = game:GetService("RunService"):IsStudio()

local Tiers = {
	Tier1Data = {
		[1] = {["Pity"] = 2, ["SuccessChance"] = 90, ["Destruction Stone"] = 10, ["Protection Stone"] = 8, Currencies = {Cubeoids = 25}},
		[2] = {["Pity"] = 5, ["SuccessChance"] = 85, ["Destruction Stone"] = 12, ["Protection Stone"] = 12, Currencies = {Cubeoids = 30}},
		[3] = {["Pity"] = 6, ["SuccessChance"] = 80, ["Destruction Stone"] = 14, ["Protection Stone"] = 14, Currencies = {Cubeoids = 45}},
		[4] = {["Pity"] = 6, ["SuccessChance"] = 75, ["Destruction Stone"] = 18, ["Protection Stone"] = 15, Currencies = {Cubeoids = 45}},
		[5] = {["Pity"] = 8, ["SuccessChance"] = 70, ["Destruction Stone"] = 20, ["Protection Stone"] = 15, Currencies = {Cubeoids = 45}},
		[6] = {["Pity"] = 8, ["SuccessChance"] = 60, ["Destruction Stone"] = 25, ["Protection Stone"] = 20, Currencies = {Cubeoids = 80}},
		[7] = {["Pity"] = 8, ["SuccessChance"] = 60, ["Destruction Stone"] = 30, ["Protection Stone"] = 20, Currencies = {Cubeoids = 100}},
		[8] = {["Pity"] = 8, ["SuccessChance"] = 55, ["Destruction Stone"] = 40, ["Protection Stone"] = 25, Currencies = {Cubeoids = 120}},
		[9] = {["Pity"] = 8, ["SuccessChance"] = 50, ["Destruction Stone"] = 50, ["Protection Stone"] = 25, Currencies = {Cubeoids = 140}},
		[10] = {["Pity"] = 10, ["SuccessChance"] = 40, ["Destruction Stone"] = 55, ["Protection Stone"] = 25, Currencies = {Cubeoids = 160}},
		[11] = {["Pity"] = 10, ["SuccessChance"] = 35, ["Destruction Stone"] = 60, ["Protection Stone"] = 30, Currencies = {Cubeoids = 350}},
		[12] = {["Pity"] = 12, ["SuccessChance"] = 30, ["Destruction Stone"] = 80, ["Protection Stone"] = 30, Currencies = {Cubeoids = 375}},
		[13] = {["Pity"] = 15, ["SuccessChance"] = 25, ["Destruction Stone"] = 100, ["Protection Stone"] = 30, Currencies = {Cubeoids = 400}},
		[14] = {["Pity"] = 20, ["SuccessChance"] = 25, ["Destruction Stone"] = 175, ["Protection Stone"] = 40, Currencies = {Cubeoids = 550}},
		[15] = {["Pity"] = 30, ["SuccessChance"] = 20, ["Destruction Stone"] = 200, ["Protection Stone"] = 60, ["Weakened Corrupt Core Fragements"] = 2, Currencies = {Cubeoids = 600}},
		[16] = {["Pity"] = 40, ["SuccessChance"] = 5, ["Destruction Stone"] = 350, ["Protection Stone"] = 80, ["Weakened Corrupt Core Fragements"] = 2, Currencies = {Cubeoids = 900}},
		[17] = {["Pity"] = 50, ["SuccessChance"] = 5, ["Destruction Stone"] = 400, ["Protection Stone"] = 90, ["Weakened Corrupt Core Fragements"] = 4, Currencies = {Cubeoids = 1250}},
		[18] = {["Pity"] = 60, ["SuccessChance"] = 5, ["Destruction Stone"] = 600, ["Protection Stone"] = 115, ["Weakened Corrupt Core Fragements"] = 4, Currencies = {Cubeoids = 2500}},
		[19] = {["Pity"] = 70, ["SuccessChance"] = 5, ["Destruction Stone"] = 750, ["Protection Stone"] = 150, ["Weakened Corrupt Core Fragements"] = 5, Currencies = {Cubeoids = 3000}},
		[20] = {["Pity"] = 80, ["SuccessChance"] = 2, ["Destruction Stone"] = 950, ["Protection Stone"] = 200, ["Weakened Corrupt Core Fragements"] = 5, Currencies = {Cubeoids = 3250}},
		[21] = {["Pity"] = 100, ["SuccessChance"] = 2, ["Destruction Stone"] = 1000, ["Protection Stone"] = 250, ["Weakened Corrupt Core Fragements"] = 8, Currencies = {Cubeoids = 3500}},
		[22] = {["Pity"] = 120, ["SuccessChance"] = 2, ["Destruction Stone"] = 1200, ["Protection Stone"] = 300, ["Weakened Corrupt Core Fragements"] = 8, Currencies = {Cubeoids = 3750}},
		[23] = {["Pity"] = 100, ["SuccessChance"] = 2, ["Destruction Stone"] = 1750, ["Protection Stone"] = 350, ["Weakened Corrupt Core Fragements"] = 10, Currencies = {Cubeoids = 4000}},
		[24] = {["Pity"] = 120, ["SuccessChance"] = 2, ["Destruction Stone"] = 2000, ["Protection Stone"] = 400, ["Weakened Corrupt Core Fragements"] = 10, Currencies = {Cubeoids = 4250}},
		[25] = {["Pity"] = 140, ["SuccessChance"] = 1,  ["Destruction Stone"] = 2500, ["Protection Stone"] = 450, ["Weakened Corrupt Core Fragements"] = 10, Currencies = {Cubeoids = 4500}},
	},
}

local Equipment, Inventory, Currencies
local cultivationCloseButtonConnection, cultivationCloseConnection
local cultivationSelectFunction = game.ReplicatedStorage["Cultivation Function"]
local selectedGear
local EquipmentUI = require(script.Parent.EquipmentUIMod)

local Protection_Stone = { 
	["Name"] = "Protection Stone",
	["Class"] = "Item",
	["Desc"] = "It seems to contain a peaceful aura.",
	["Icon"] = 6995306743,
	["Type"] = "Material"
}

local Destruction_Stone = {
	["Name"] = "Destruction Stone",
	["Class"] = "Item",
	["Desc"] = "It seems to contain a raging aura.",
	["Icon"] = 2746747290,
	["Type"] = "Material"
}

local Weakened_Corrupt_Core_Fragements= {
	["Name"] = "Weakened Corrupt Core Fragements",
	["Class"] = "Item", 
	["Desc"] = "There is a little amount strange energy omitting from it", 
	["Icon"] = "Material", 
	["Type"] = 12135709647
}

function HasItem(item, Amount) -- optimize this
	local itemName = item.Name
	local Amount = Amount or 1
	for i, v in pairs(Inventory) do
		if v.Name == itemName then
			if v.Amount >= Amount then
				return v, i
			else
				return nil -- Return false if amount amount is not met
			end
		end
	end

	return nil -- Return false if item not found
end

function GetItemAmount(item)
	local item = HasItem(item)
	return item and item.Amount or 0
end

function RemoveItem(item, amount)
	local amount = amount or 1	
	local found, foundi = HasItem(item)

	if found then
		if found.Amount - amount <= 0 then
			table.remove(Inventory, foundi)
			--print("Removed",func["Name"],"from inventory")
		else
			found.Amount -= amount
			--print("Removed", amount,"from", func["Name"], self[found]["Amount"]+amount)
		end
	else
		print("Coundn't find Item in inventory")
	end

end


function BurnRequirements(Inventory, itemType, stoneRequirement)
	if itemType == "Armour" then
		RemoveItem(Protection_Stone, stoneRequirement)
	else
		RemoveItem(Destruction_Stone, stoneRequirement)
	end
end

local function UpdateCultivationSlot(Gear)
	local cultivationUI = plr.PlayerGui.CultivationGui
	local gearFrame = cultivationUI.MainFrame.GearFrame
	local frame
	local gearStats = Gear.GearStats

	if Gear["Type"] == "Armour" then
		frame = gearFrame[gearStats.GearType]
	else
		frame = gearFrame[Gear["Type"]]
	end

	frame.ImageFrame.ImageLabel.Image = "rbxassetid://" .. Gear["Icon"]

	local itemCultivation = gearStats["Cultivation"]

	if itemCultivation > 0 then
		frame.ItemName.Text = Gear["Name"] .. " +" .. itemCultivation

	else
		frame.ItemName.Text = Gear["Name"]
	end
end

function GetRequirements(itemType, Tier, gearCultivaiton)
	local tierData = Tiers["Tier"..Tier.."Data"]
	local CultivationLevel = tierData[gearCultivaiton+1] 

	if itemType == "Armour" then
		return CultivationLevel["Protection Stone"], CultivationLevel["Weakened Corrupt Core Fragements"], CultivationLevel.Currencies
	else
		return CultivationLevel["Destruction Stone"], CultivationLevel["Weakened Corrupt Core Fragements"], CultivationLevel.Currencies
	end
end

function HasRequirements(Gear, Currencies)
	if not Inventory then
		error("NOT THIS PROBLEM, why is inventory nil?")
		return false
	end
	
	local gearStats = Gear.GearStats

	local Tier, gearCultivation, itemType = gearStats["Tier"], gearStats["Cultivation"], Gear["Type"]
	local stoneRequirement, weakenedCoreRequirement, currenciesRequirement = GetRequirements(itemType, Tier, gearCultivation)
	local hasStone, hasCore, hasCurrencies = false, false, true
	local coreRequirementMet 
	if itemType == "Armour" then
		hasStone = HasItem(Protection_Stone, stoneRequirement)
	else
		hasStone = HasItem(Destruction_Stone, stoneRequirement)
	end
	
	if weakenedCoreRequirement ~= nil then
		hasCore = HasItem(Weakened_Corrupt_Core_Fragements, weakenedCoreRequirement)
		coreRequirementMet = hasCore
	else
		coreRequirementMet = true
	end

	for currency, requirement in pairs(currenciesRequirement) do
		if Currencies[currency] < requirement then
			print("Player doens't have enough cubeoids!")
			hasCurrencies = false
			break
		else
			print("Player has enough cubeioids!")
		end
	end
	print("has core:",hasCore)

	if hasStone and coreRequirementMet and hasCurrencies then
		Currencies -= currenciesRequirement
		if coreRequirementMet then RemoveItem(Weakened_Corrupt_Core_Fragements, weakenedCoreRequirement) end
		
		return true, BurnRequirements(Inventory, itemType, stoneRequirement)
	else
		print("does not have requirements locally")
		return false
	end

end

local function UpdateCultivationRequirementsUI(Gear)
	local requirementsFrame = plr.PlayerGui.CultivationGui.MainFrame.RequirementsFrame
	local stoneFrame = requirementsFrame.StoneFrame
	local coreFrame = requirementsFrame.CorefragmentsFrame
	local pictureID, stone
	local hasStone, hasWeakenedCore
	local requiredStone, requiredCore, requiredCurrencies
	local gearStats = Gear.GearStats

	if not requirementsFrame.Visible then requirementsFrame.Visible = true end

	if Gear.Type == "Armour" then
		stone = Protection_Stone
	else
		stone = Destruction_Stone
	end

	pictureID = stone.Icon
	hasStone = GetItemAmount(stone)
	hasWeakenedCore = GetItemAmount(Weakened_Corrupt_Core_Fragements)
	
	requiredStone, requiredCore, requiredCurrencies = GetRequirements(Gear.Type, gearStats.Tier, gearStats.Cultivation)

	stoneFrame.Stone.Image = "rbxassetid://" ..pictureID
	stoneFrame.Required.Text = hasStone .. "/" .. requiredStone

	-- Updates Colour for stone requirement
	if hasStone < requiredStone then
		stoneFrame.Required.TextColor3 = Color3.new(1, 0, 0)
	else
		stoneFrame.Required.TextColor3 = Color3.new(1, 1, 1)
	end
	
	if requiredCore ~= nil then
		print("Requires core!")
		coreFrame.Required.Text = hasWeakenedCore .. "/" .. requiredCore
		coreFrame.Visible = true
		if hasWeakenedCore < requiredCore then
			coreFrame.Required.TextColor3 = Color3.new(1, 0, 0)
		else
			coreFrame.Required.TextColor3 = Color3.new(1, 1, 1)
		end
	else
		print("Doesn't require core!")
		coreFrame.Visible = false
	end
	

	-- Itrates through needed currencies and updates text and colour 
	for currency, requirement in pairs(requiredCurrencies) do
		local currencyFrame = requirementsFrame[currency .. "Frame"]
		currencyFrame.Required.Text = Currencies[currency] .. "/" .. requirement
		if Currencies[currency] < requiredCurrencies[currency] then
			currencyFrame.Required.TextColor3 = Color3.new(1, 0, 0)
		else
			currencyFrame.Required.TextColor3 = Color3.new(1, 1, 1)
		end
	end

end

function GetSuccessChance(Tier, Cultivation, FailStacks)

	-- Look in the correct Tier table
	local tierData = Tiers["Tier"..Tier.."Data"]

	local CultivationLevel = tierData[Cultivation+1] -- Get pity and chance for upgrade
	if CultivationLevel["Pity"] == nil then return "Limit Reached" 
	elseif FailStacks == CultivationLevel["Pity"] then print("PITY!") return 100, CultivationLevel["Pity"] -- If failstacks have reached pity then gurantee upgrade
	else return CultivationLevel["SuccessChance"], CultivationLevel["Pity"] end  -- return chance
end

function module.UpdateUI(sentEquipment, sentInventory, sentCurrencies, Prompt)
	Equipment = sentEquipment
	Inventory = sentInventory
	Currencies = sentCurrencies
	
	local cultivationUI = plr.PlayerGui.CultivationGui

	-- Close Cultivation UI
	cultivationCloseButtonConnection = cultivationUI.MainFrame.CloseButton.MouseButton1Click:Connect(function()
		cultivationUI.Enabled = false
		Prompt.Enabled = true
		cultivationCloseButtonConnection:Disconnect()
	end)
	
	cultivationCloseConnection = cultivationUI:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not cultivationUI.Enabled then
			EquipmentFunction:InvokeServer("ApplyGearStats") -- WHENEVER UI CLOSES THIS MUST BE ACTIVE
			cultivationCloseConnection:Disconnect()
		end
	end)
	cultivationUI.MainFrame.Pity.Text = ""

	cultivationUI.Enabled = true
	Prompt.Enabled = false

	-- Show Items in cultivation Gui
	local gearFrame = cultivationUI.MainFrame.GearFrame
	print(Equipment)
	for Equip, Gear in pairs(Equipment) do
		if Gear["Name"] then
			UpdateCultivationSlot(Gear)
		end
	end
end

local function UpdateGearName(GearName, Cultivation)
	local mainFrame = plr.PlayerGui.CultivationGui.MainFrame
	if Cultivation > 0 then
		mainFrame.GearName.Text = GearName .. " +" .. Cultivation
	else
		mainFrame.GearName.Text = GearName 

	end
end

local function UpdateCultivationSuccessRateAndPity(Gear)
	local mainFrame = plr.PlayerGui.CultivationGui.MainFrame
	local gearStats = Gear.GearStats
	local sucessRate, pity = GetSuccessChance(gearStats["Tier"], gearStats.Cultivation, gearStats.FailStacks)
	
	if sucessRate < 100 then
		mainFrame.SucessRate.Text = '<font color = "#00FF00">'..sucessRate .. "%</font> Success Chance"
	else
		mainFrame.SucessRate.Text = '<font color = "#00FF00">100% PITY HIT</font>'
	end

	mainFrame.Pity.Text = "Pity: " .. gearStats.FailStacks .. " / " .. pity

end

local function GetLocalAudios()
	return plr.Backpack.localAudios
end

-- Does the cool PauseChamp bar
local function StartCultivationAnim()
	local mainFrame = plr.PlayerGui.CultivationGui.MainFrame
	local EnergyBar = mainFrame.EnergyBar
	
	local waitTime = math.random(250, 450) / 100
	
	if math.random(1,10) == 1 then
		waitTime = 1
	end
	
	local energyRelativeToMax = 1 --Maths
	local info = TweenInfo.new(waitTime,math.random(0,10),Enum.EasingDirection.Out,0,false,0) --Tween Info
	local pauseChampTween = TweenService:Create(EnergyBar.bar,info,{Size = UDim2.fromScale(energyRelativeToMax, 1)})
	
	pauseChampTween:Play()
	
	local complete = false
	
	pauseChampTween.Completed:Once(function()
		EnergyBar.Visible = false
		EnergyBar.bar.Size = UDim2.fromScale(0, 1)
		complete = true

	end)	
	
	repeat task.wait(.2) until complete
	
end

local function ShowCultivationResult(Result)
	local mainFrame = plr.PlayerGui.CultivationGui.MainFrame
	local EnergyBar = mainFrame.EnergyBar
	if Result == "Success" or Result == "Fail" then
		local resultText = mainFrame.ResultText 
		resultText.Text = Result

		if Result == "Success" then 
			resultText.TextColor3  = Color3.new(0, 1, 0.498039)
		else 
			resultText.TextColor3  = Color3.new(1, 0, 0) 
		end
		
		game.ReplicatedStorage[Result .." Audio"]:Play()

		resultText.Visible = true

		coroutine.wrap(function()
			task.wait(1)
			resultText.Visible = false
			EnergyBar.Visible = true
		end)()

	end
end

-- Handles: Gear selection and when "Cultivate" button is pressed
local function SelectGear(Event, slotName)
	local mainFrame = plr.PlayerGui.CultivationGui.MainFrame
	-- When gear selected put Image in selection frame and set variable
	if Event == "GearSelect" then
		local Gear = Equipment[slotName]
		selectedGear = Gear
		mainFrame.SelectedFrame.ImageLabel.Image = mainFrame.GearFrame[slotName].ImageFrame.ImageLabel.Image
		UpdateCultivationSuccessRateAndPity(Gear)
		UpdateCultivationRequirementsUI(Gear)
		UpdateGearName(Gear.Name, Gear.GearStats.Cultivation)


	elseif Event == "Has Requirement" then
		local hasRequirement = HasRequirements(selectedGear, Currencies)
		if hasRequirement then
			
			local isWeapon = selectedGear.Type == "Weapon" and true or false
			local slotToCultivate
			if isWeapon then
				slotToCultivate = selectedGear.Type
			else
				slotToCultivate = selectedGear.GearStats.GearType
			end
			local gearResult, result = EquipmentFunction:InvokeServer("AttemptCultivation", slotToCultivate)
			
			selectedGear = gearResult
			Equipment[slotToCultivate] = gearResult
			
			if not isInStudio then
				StartCultivationAnim()
			end
			
			ShowCultivationResult(result)
			UpdateCultivationSuccessRateAndPity(gearResult)
			UpdateCultivationRequirementsUI(gearResult)
			UpdateCultivationSlot(gearResult)
			UpdateGearName(gearResult.Name, gearResult.GearStats.Cultivation)
			EquipmentUI.UpdateUI(Equipment, gearResult)
			
		end		

		return hasRequirement

		-- When cultivation button clicked, attempt to cultivate, show results and update the gear		
	elseif Event == "Attempt Cultivation" then
		print("Attempted")
	end
end

cultivationSelectFunction.OnInvoke = SelectGear

return module
