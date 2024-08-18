
local player = game.Players.LocalPlayer
local CollectionService = game:GetService("CollectionService")
local SkillData = require(game.ReplicatedStorage.LocalMods.SkillDataMod)
local Raw_SkillData = SkillData[2]
SkillData = SkillData[1]

local skillSlotGui = player.PlayerGui:WaitForChild("SkillSlot").Main_Frame

local GUI = player.PlayerGui:WaitForChild("Skills Menu")
local main_Frame, weaponSkills_Frame, weaponOptions, mainOptions

local skillData = player:WaitForChild("Game Values"):WaitForChild("Skill Data")
local config_SkillSlots = skillData:WaitForChild("Skill Slots")
local UpdateSlotEvent = skillData.UpdateSkillSlotData
local addSkillEvent = skillData.AddSkillToSlot

local selectedButton = Instance.new("ObjectValue")
local skillSlotGui_Children =  skillSlotGui:GetChildren()
local BorderPixelSize = 2

local SkillsMenu_Inspect
local SkillSlots_Inspect = player.PlayerGui.SkillSlot:WaitForChild("Inspect")

local skillToRequest
local updateSelectedButton
local selectedSkillInfo 
local previouslySelectedButton 
local previousFrame, perviousOptionFrame

local function SetValues()
	main_Frame = GUI.Main_Frame
	weaponSkills_Frame = main_Frame.Weapon_Skills
	weaponOptions = main_Frame.Main_Options["Weapon Options"]
	mainOptions = main_Frame.Main_Options
	SkillsMenu_Inspect = weaponSkills_Frame.Inspect
end

SetValues()

player.CharacterAdded:Connect(function()
	print("Player died!")
	SetValues()
end)


function SetSkillSlotBorderColor(Color : Color3)
	for _, frame in pairs(skillSlotGui_Children) do
		frame.BorderColor3 = Color
	end
end

function InspectSkill(inspect : Instance , Info, frame : Instance, down : boolean)
	
	local Name = inspect.NameLabel
	local Type = inspect.Type
	local Desc = inspect.Desc
	
	if Info then
		Name.Text = Info.Name
		Type.Text = Info.Type
		Desc.Text = Info.Desc
	else
		Info = frame.SkillInfo
		Name.Text = Info:GetAttribute("Name")
		Type.Text = Info:GetAttribute("Type")
		Desc.Text = Info:GetAttribute("Desc")
	end
	
	local offset = down and UDim2.new(0, -80, 0, -20) or UDim2.new(0 ,-160 ,0 , 262) --UDim2.new(0, -80, 0, -60)
	
	inspect.Position = frame.Position + offset
	inspect.Visible = true
end

function HideInspect(inspect : Instance)
	inspect.Visible = false
end

function Update_SkillInfo(skillInfo_Config : Instance, skillInfo)
	skillInfo_Config:SetAttribute("Name", skillInfo.Name)
	skillInfo_Config:SetAttribute("Type", skillInfo.Type)
	skillInfo_Config:SetAttribute("Desc", skillInfo.Desc)
end

selectedButton.changed:Connect(function(skillFrame)
	if not skillFrame then return end
	
	if previouslySelectedButton and previouslySelectedButton ~= skillFrame then
		previouslySelectedButton.BorderColor3 = Color3.new(1,1,1)
	end
	
	previouslySelectedButton = skillFrame
	skillFrame.BorderColor3 = Color3.fromRGB(255, 255, 0) 
	SetSkillSlotBorderColor(Color3.fromRGB(255, 255, 0))
	
end)

-- Display the weapon skills option when it is clicked
for _, button in pairs(weaponOptions:GetChildren()) do
	if not button:IsA("TextButton") then continue end
	local Name = button.Name
	button.InputBegan:Connect(function(input)
		local userInput = input.UserInputType
		if userInput == Enum.UserInputType.MouseButton1 then
			weaponSkills_Frame.Visible = true
			local frame = weaponSkills_Frame[Name.."_Frame"]
			
			-- If new frame clicked on, hide previous frame
			if previousFrame and previousFrame ~= frame then 
				previousFrame.Visible = false 
				weaponOptions[string.split(previousFrame.Name, "_")[1]].BorderSizePixel = 0
				
				SetSkillSlotBorderColor(Color3.new(1,1,1))
				selectedSkillInfo = nil
			end
			
			previousFrame = frame
			frame.Visible = true
			button.BorderSizePixel = BorderPixelSize
		end
	end)
end


local General = mainOptions.General
local Weapon_Skills = mainOptions.Weapon_Skills
General.InputBegan:Connect(function(input)
	local userInput = input.UserInputType
	if userInput == Enum.UserInputType.MouseButton1 then
		main_Frame.Weapon_Skills.Visible = false
		main_Frame.General_Frame.Visible = true
		mainOptions["Weapon Options"].Visible = false
		
		Weapon_Skills.BorderSizePixel = 0
		General.BorderSizePixel = BorderPixelSize
	end
end)

Weapon_Skills.InputBegan:Connect(function(input)
	local userInput = input.UserInputType
	if userInput == Enum.UserInputType.MouseButton1 then
		main_Frame.Weapon_Skills.Visible = true
		main_Frame.General_Frame.Visible = false
		mainOptions["Weapon Options"].Visible = true
		
		General.BorderSizePixel = 0
		Weapon_Skills.BorderSizePixel = BorderPixelSize
	end
end)



-- Add skill to slot when clicked
for i, v in pairs(skillSlotGui:GetChildren()) do
	if v:IsA("UIListLayout") then continue end
	v.Button.InputBegan:Connect(function(input)
		local userInput = input.UserInputType
		local frameToChange = "Skill"..i.."_Frame"
		if GUI.Enabled and userInput == Enum.UserInputType.MouseButton1 and previouslySelectedButton and selectedSkillInfo then
			-- Fire Server
			local connection
			connection = config_SkillSlots.AttributeChanged:Connect(function(attribute)
				if attribute == tostring(i) then
					Update_SkillInfo(v.SkillInfo, Raw_SkillData[config_SkillSlots:GetAttribute(i)])
					InspectSkill(SkillSlots_Inspect, nil, skillSlotGui[frameToChange])

					connection:Disconnect()
				else -- For safety though it seems impossible
					task.wait(2)
					connection:Disconnect()
				end
			end)
			
			addSkillEvent:FireServer(i, selectedSkillInfo.Name, selectedSkillInfo.Type)
			
			local frameImage = "rbxassetid://" .. selectedSkillInfo.Icon
			
			previouslySelectedButton.BorderColor3 = Color3.new(1,1,1)
			SetSkillSlotBorderColor(Color3.new(1,1,1))
			previouslySelectedButton = nil
			
			UpdateSlotEvent:Invoke("Icon_Update", frameToChange, frameImage)
			
			--print("Slot"..i, "Clicked!")
		elseif userInput == Enum.UserInputType.MouseMovement then
			local potentialSkillInfo = Raw_SkillData[config_SkillSlots:GetAttribute(i)]
			if potentialSkillInfo then
				Update_SkillInfo(v.SkillInfo, potentialSkillInfo)
				InspectSkill(SkillSlots_Inspect, nil, skillSlotGui[frameToChange])
			end
		end
	end)
	
	v.Button.InputEnded:Connect(function(input)
		local userInput = input.UserInputType
		if userInput == Enum.UserInputType.MouseMovement then
			HideInspect(SkillSlots_Inspect)
		end	
	end)

end

local AvailableSkills = skillData.GetAvailableSkills:InvokeServer() -- get from server to update all icons
local SkillFrameData = {}
local ReplicatedSkillInfo = game.ReplicatedStorage.SkillInfo

-- From the available skills will set each skill frame's frame to the skill icon 
for _, weaponFrame in pairs (weaponSkills_Frame:GetChildren()) do
	if weaponFrame.Name == "Inspect" then continue end
	
	-- Get the available skill type (General, sword, spear etc)
	local skillType = string.split(weaponFrame.Name, "_")[1]
	local Available_SkillType = AvailableSkills[skillType]
		
	-- Loops through the table of the of the Avilable skill type ({Bound, Discharge, etc})
	for i, skillName in pairs (Available_SkillType) do
		
		-- Looks in skill data using the skillType and skillName to attmpt to find skill data
		local skillInfo = SkillData[skillType][skillName]
		
		--IF the found skill has info (name, desc, type) add the data to the frame
		if skillInfo then
			
			--print("Found", skillName, " in skill data from avail table")
			
			-- Add the data to table
			local slotName = "Skill"..i.."_Frame"
			local slotInstance = weaponFrame[slotName]
			SkillFrameData[slotInstance] = skillInfo
			slotInstance.Button.Image = "rbxassetid://" .. skillInfo.Icon			

		else
			--print("Couldn't find", skillName)
		end
		
	end
end


for _, button in pairs (CollectionService:GetTagged("Skills Menu Button")) do
	local skillFrame = button.Parent
	local buttonData = SkillFrameData[skillFrame]

	local function UpdateSelected(selected)
		
		if selectedButton.Value == skillFrame then
			skillFrame.BorderColor3 = Color3.new(1,1,1)
			SetSkillSlotBorderColor(Color3.new(1,1,1))
			selectedSkillInfo = nil
			selectedButton.Value = nil
		else
			selectedButton.Value = skillFrame
			selectedSkillInfo = buttonData
		end
	end

	button.InputBegan:Connect(function(input)
		local userInput = input.UserInputType
		if userInput == Enum.UserInputType.MouseButton1 then
			button.Selected = not button.Selected
			UpdateSelected()
		elseif userInput == Enum.UserInputType.MouseMovement then
			InspectSkill(SkillsMenu_Inspect, buttonData, skillFrame, true)
		end	

	end)
	
	button.InputEnded:Connect(function(input)
		local userInput = input.UserInputType
		if userInput == Enum.UserInputType.MouseMovement then
			HideInspect(SkillsMenu_Inspect)
		end	
	end)
	
end

function SetSkillSlotArrangment(Skill_Slots)
	
end


skillData:WaitForChild("Skill Slots")
for _,v in pairs(skillSlotGui:GetChildren()) do
	repeat task.wait() until v
end
UpdateSlotEvent:Invoke("Icon_UpdateAll")

script.Destroying:Connect(function()
	selectedButton:Destroy()
end)