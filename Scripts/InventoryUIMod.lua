local module = {}

local plr = game.Players.LocalPlayer
local Debris = game:GetService("Debris")

local GameValues = plr["Game Values"] -- Dont need wait child bc PlayerHandle waits for it
local EquipmentFunction = GameValues.Inventory.EquipmentFunction

function module.getItemAmount(Inventory, itemName)
	for i, v in pairs(Inventory) do
		if v.Name == itemName then
			return v.Amount
		end
	end
	
	return 0
end

function module.hasItem(Inventory, Item, Amount)
	local Amount = Amount or 1
	for i, v in pairs(Inventory) do
		if v.Name == Item.Name then
			if Item.GearStats then return true end -- Checks if its a gear, don't compare amount
			if v.Amount >= Amount then
				return true 
			else
				return false -- Return false if amount amount is not met
			end
		end
	end
	
	return false -- Return false if item not found
end

-- Not needed c UpdateUI handles empty slots
function module.RemoveItemFromSlot(player, slotNumber, amount)
end


function module.UpdateUI(Inventory)
	local Gui = plr.PlayerGui.InventoryGui.MainFrame
	local slotsUpdated = {}
	
	-- Set the image of all current Inventory Items
	for key, value in pairs (Inventory) do
		local slot = Gui["Slot"..key]
		local slotName = slot.Name
		local itemData = Inventory[key]
		
		if itemData.Icon ~= 0 then
			slot.TextIcon.Text = ""
			slot.ImageButton.Image =  "rbxassetid://" .. itemData.Icon
		else
			slot.ImageButton.Image =  ""
			slot.TextIcon.Text = itemData.Name
		end
		
		slot.ImageButton.Visible = true
		
		
		if not itemData.GearStats then
			slot.Amount.Text = itemData["Amount"]	

			slot.Amount.Visible = true
			slot.Amount.TextStrokeTransparency = .5 
		else
			slot.Amount.Visible = false
		end
		
		if slot.arrowLabel.Visible then slot.arrowLabel.Visible = false end

		table.insert(slotsUpdated, slotName)
	end
	
	for i, slot in pairs (Gui:GetChildren()) do
		local slotName = slot.Name
		local slotNumber = string.sub(slotName, 5, tonumber(string.len(slotName)))
		-- If the instance is a slot and they are not in the slotsUpdated table then make the slot blank
			if  string.sub(slotName, 1, 4) == "Slot" and not table.find(slotsUpdated, slotName) and (slot.ImageButton.Image ~= "" or slot.TextIcon.Text ~= "") then
			slot.ImageButton.Image = ""
			slot.Amount.Text = ""
			slot.TextIcon.Text = ""
			if slot.arrowLabel.Visible then slot.arrowLabel.Visible = false end
			if slot.ImageButton.Visible then slot.ImageButton.Visible = false end -- This disables the MouseEnter function
		end
	end
	
	module.CompareItems()
end

function module.UpdateUISlot(slot_number, itemData, plr)
	--print(slot_number .. plr.Name)
	local Gui = plr.PlayerGui.InventoryGui.MainFrame
	local slot = Gui["Slot"..slot_number]
	local itemClass = itemData["Class"] 
	
	if itemData.Icon ~= 0 then
		slot.TextIcon.Text = ""
		slot.ImageButton.Image =  "rbxassetid://" .. itemData.Icon
	else
		slot.ImageButton.Image =  ""
		slot.TextIcon.Text = itemData.Name
	end

	
	if itemClass ~= "Gear" then
		slot.Amount.Text = itemData["Amount"]	
		
		slot.Amount.Visible = true
		slot.Amount.TextStrokeTransparency = .5 
	else
		module.CompareItems()
	end
	
	--slot.backgroundImage.Visible = true
	slot.ImageButton.Visible = true
	
	
end

function module.AddItemDropFrame(Name, Icon, Amount)
	local MainFrame = plr.PlayerGui.ScreenGui.ItemDropFrame
	local newFrame = MainFrame:FindFirstChild(Name)

	-- if frame already there
	if newFrame then
		print("Found frame ",Name, "with ", Amount)
		newFrame.Amount.Text = "x"..Amount + newFrame.Amount.Text:sub(2)
		--print("added to amount")
	
		return
	end

	newFrame = game.ReplicatedStorage.ItemDropInfoFrame:Clone()
	newFrame.Name = Name

	newFrame.NameTxt.Text = Name

	if Icon ~= 0 then
		newFrame.Icon.Image = "rbxassetid://" .. Icon
	end

	newFrame.Amount.Text = "x"..Amount

	newFrame.Parent = MainFrame
		
end

function module.AddMiscDropFrame(Name, Icon, Amount)
	local MainFrame = plr.PlayerGui.ScreenGui.MiscDropFrame
	local newFrame = MainFrame:FindFirstChild(Name)
	
	-- if frame already there
	if newFrame then
		--print(newFrame.Amount.Text:sub(2), Amount)
		newFrame.Amount.Text = "+"..Amount + newFrame.Amount.Text:sub(2)
		print("added to amount")

		return
	end

	newFrame = game.ReplicatedStorage.MiscDropInfoFrame:Clone()
	newFrame.Name = Name

	newFrame.NameTxt.Text = Name

	if Icon ~= 0 then
		newFrame.Icon.Image = "rbxassetid://" .. Icon
	end

	newFrame.Amount.Text = "+"..Amount

	newFrame.Parent = MainFrame

end


function module.CompareItems()
	local inventoryGears, equippedGears = EquipmentFunction:InvokeServer("GetGearsFromInventoryAndEquipment")
	if not inventoryGears then 
		print("Cannot compare gears currently, now waiting to try again")
		task.wait(4)
		inventoryGears, equippedGears = EquipmentFunction:InvokeServer("GetGearsFromInventoryAndEquipment")
		if not inventoryGears then
			print("Still cannot compare gears, tries has stopped")
			return 
		else
			print("After waiting, comparing gears was successful")
		end
	end
	
	local function getTypeOfGear(gear)
		local Type : string
		if gear.Type == "Weapon" then 
			Type = "Weapon"
		else
			Type = gear.GearStats.GearType
		end
		
		return Type
	end
	
	-- For later?
	local function compareStats(inveGear, equippedGear, statName)	
	end
	
	local Gui = plr.PlayerGui.InventoryGui.MainFrame
	
	--print("inventory has", #inventoryGears, "gears")

	for slotIndex, invenGear in pairs(inventoryGears) do
		local typeOfGear = getTypeOfGear(invenGear)
		local equippedGearToCompare = equippedGears[typeOfGear]
		
		local invenSlotUI = Gui["Slot"..slotIndex]
		local arrowLabel = invenSlotUI.arrowLabel
		
		-- If the player is equipped with this inventory gear
		if equippedGearToCompare ~= nil then 
			
			local invenGearStats, equippedGearStats = invenGear.GearStats, equippedGearToCompare.GearStats
			local invenBaseStats, equippedBaseStats = invenGearStats.BaseStats, equippedGearStats.BaseStats
			local invenQuality, equippedQuality = invenGearStats.Quality, equippedGearStats.Quality
			
			if typeOfGear == "Weapon" then
				-- inventory's base stat is higher than its equipped counter part OR their base stat is the same, but inventory has a higher quality
				if invenBaseStats.baseATK > equippedBaseStats.baseATK or invenQuality > equippedQuality and invenBaseStats.baseATK == equippedBaseStats.baseATK then
					-- Show its stronger
					arrowLabel.ImageColor3 = Color3.fromRGB(38, 255, 0)
					arrowLabel.Visible = true
					
					--print(slotIndex, "baseATK:",invenBaseStats.baseATK, "is stronger than baseATK:", equippedBaseStats.baseATK)
				else
					-- Show its wweaker 
					arrowLabel.Visible = false
					--print(slotIndex, "baseATK:",invenBaseStats.baseATK, "is weaker than baseATK:", equippedBaseStats.baseATK)
				end
			else
				if invenBaseStats.baseDEF > equippedBaseStats.baseDEF or invenQuality > equippedQuality and invenBaseStats.baseDEF == equippedBaseStats.baseDEF  then
					-- Show its stronger
					arrowLabel.ImageColor3 = Color3.fromRGB(38, 255, 0)
					arrowLabel.Visible = true
					
				else
					-- Show its wweaker 
					arrowLabel.Visible = false
				end
			end
			
			-- Make sure code below is only if it could not find sth to compare with
			continue
			
		end
		

		arrowLabel.ImageColor3 = Color3.fromRGB(38, 255, 0)
		arrowLabel.Visible = true
		
	end
	
end

function module.AddSlotsCode()
	local CollectionService = game:GetService("CollectionService")
	local Tagged = CollectionService:GetTagged("Slot")
	local Gui = plr.PlayerGui.InventoryGui.MainFrame -- re-defined down beloww
	local equipmentInspect = plr.PlayerGui.EquipmentGui.MainFrame.Inspect
	local Character = plr.Character
	local inspectSlotData : number
	
	for _, slot in pairs(Tagged) do
		local inspectEvent, clickedEvent, clickedEquipEvent  = game.ReplicatedStorage["Inspect Item"], game.ReplicatedStorage["Clicked Item"], game.ReplicatedStorage["Clicked Equip Item"]
		local slotName = slot.Name
		local slotNumber = string.sub(slotName, 5, tonumber(string.len(slotName)))

		local mainFrame = slot.Parent
		local Gui = mainFrame.Inspect
		local imageButton = slot:WaitForChild("ImageButton")
		
		-- Tell local to inspect said slot
		imageButton.MouseEnter:Connect(function()
			if slot:GetAttribute("UIParent") == "Inventory" then
				inspectEvent:Fire(slotNumber)
			else
				inspectEvent:Fire(slotName, "Equipment")
			end
			inspectSlotData = slotNumber
		end)

		imageButton.MouseLeave:Connect(function()
			-- Checks if inspecting data matches THIS slots inspect data, if so hide, if not do not hide (prevents annoying dissapearing when not meant to)
			if inspectSlotData == slotNumber then 
				Gui.Visible = false 
				equipmentInspect.Visible = false
			end
		end)
		
		-- Tell local to equip said slot item
		imageButton.MouseButton2Down:Connect(function()
			Character = plr.Character -- For one character respawns
			if Character and Character.Humanoid.Health <= 0 then return end
			if slot:GetAttribute("UIParent") == "Inventory" then
				clickedEquipEvent:Fire(slotNumber)
			else
				if slot.ImageButton.Image ~= "" then
					clickedEquipEvent:Fire(slotName, "Equipment")
				end
			end
		end)
		
		-- Tell local to equip said slot item
		imageButton.MouseButton1Down:Connect(function()
			Character = plr.Character -- For one character respawns
			if Character:FindFirstChild("Humanoid") and Character.Humanoid.Health <= 0 then return end
			if slot:GetAttribute("UIParent") == "Inventory" then
				clickedEvent:Fire(slotNumber)
			else
				if slot.ImageButton.Image ~= "" then
					--clickedEvent:Fire(slotName, "Equipment"
					clickedEquipEvent:Fire(slotName, "Equipment")
				end
			end
		end)

		slot.MouseEnter:Connect(function()
			slot.BorderSizePixel = 1
		end)

		slot.MouseLeave:Connect(function()
			task.wait()
			slot.BorderSizePixel = 0
		end)
	end
	
end

return module