local Combinations = {
	{ancient = 2, fortune = 1},
	{ancient = 1, fortune = 1, insight = 1},
	{fortune = 1, insight = 2},
    {insight = 2, sharpness = 1},
    {insight = 1, sharpness = 1, looting = 1},
	{insight = 3},
	{looting = 3},
	{opulence = 3},
	{opulence = 2, sharpness = 1},
	{knockback = 3},
	{thorns = 3},
}

---------------------------- DO NOT TOUCH ANYTHING PAST THIS IF YOU DONT KNOW WHAT YOU ARE DOING
---------------------------- DO NOT TOUCH ANYTHING PAST THIS IF YOU DONT KNOW WHAT YOU ARE DOING

local maxdistance = 30
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local paper = require(ReplicatedStorage.Paper)
local localPlayer = Players.LocalPlayer
local plrscripts = localPlayer:WaitForChild("PlayerScripts")
local username = localPlayer.Name
local character = workspace:FindFirstChild(username) --:MoveTo(workspace:FindFirstChild(username).HumanoidRootPart.Position + Vector3.new(1,1,1))
local bases = workspace:WaitForChild("Bases")
local base = bases:WaitForChild(username)
local sells = base:WaitForChild("SellStation")
local sellsmain = sells:WaitForChild("Main")
local gui = Instance.new("ScreenGui", localPlayer.PlayerGui)
local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0.1, 0, 0.05, 0)
button.Position = UDim2.new(.5, 0, 1, 0)
button.AnchorPoint = Vector2.new(.5,1)
button.Text = "Start"
button.BackgroundColor3 = Color3.new(0, 1, 0)
local enabled = false
button.MouseButton1Click:Connect(function()
	if enabled then
		enabled = false
		button.Text = "Start"
		button.BackgroundColor3 = Color3.new(0, 1, 0)
	else
		enabled = true
		paper.Network.InvokeServer("Teleport In Base", "Sell")
		button.Text = "Stop"
		button.BackgroundColor3 = Color3.new(1, 0, 0)
	end
end)

--antiafk
local VirtualUser = game:GetService('VirtualUser')
localPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)
plrscripts:WaitForChild("Game"):WaitForChild("AutoRejoin").Enabled = false
--
-- ANTI-GAMEPLAY PAUSED SCREEN
local GuiService = game:GetService("GuiService")
GuiService:SetGameplayPausedNotificationEnabled(false)

workspace.Swords.ChildAdded:Connect(function(sword)
	if not enabled then return end
local main
local n = 0
	repeat
main = sword:FindFirstChild("Main")
n+=1
task.wait()
until n>=1000 or main
	local gui = main:WaitForChild("Gui")
	local ItemInfo = gui:WaitForChild("ItemInfo")
	task.wait()
	local swordowner = ItemInfo:WaitForChild("Username")
	if swordowner.Text~=username then return end

	local selling = ItemInfo:WaitForChild("Selling")
	if not selling then return end
	selling:GetPropertyChangedSignal("Text"):Wait()

	local distance = (sellsmain.Position-main.Position).Magnitude
	if distance>maxdistance then print("too far") return end --if sword is not in sell station

	local enchantsfolder = ItemInfo:WaitForChild("Enchants")
	local e1 = enchantsfolder:WaitForChild("Enchant1")
	local e2 = enchantsfolder:WaitForChild("Enchant2")
	local e3 = enchantsfolder:WaitForChild("Enchant3")

	if not e1 or not e2 or not e3 then return end

	local e1t = string.lower(e1.Text):match("^(%S+)")
	local e2t = string.lower(e2.Text):match("^(%S+)")
	local e3t = string.lower(e3.Text):match("^(%S+)")
	if not e1t or not e2t or not e3t then return end

	local allenchants = {}
	allenchants[e1t] = 1
	if allenchants[e2t] then
		allenchants[e2t] += 1
	else
		allenchants[e2t] = 1
	end
	if allenchants[e3t] then
		allenchants[e3t] += 1
	else
		allenchants[e3t] = 1
	end

	for _,Combination in Combinations do
		local result = true
		for enchant, ammount in Combination do
			local nenchant = allenchants[string.lower(tostring(enchant))]
			if ammount~=nenchant then
				result = false
				break
			end
		end


		if result == true and enabled then
			print("combo found")
local gone = false
			repeat
character:MoveTo(main.Position + Vector3.new(0,6,0))
if not sword or sword.Parent==nil then
gone = true
else
task.wait(0.5)
end
until gone==true
			paper.Network.InvokeServer("Teleport In Base", "Sell")
			paper.Network.InvokeServer("Teleport In Base", "Sell")
			break
		end
	end
end)