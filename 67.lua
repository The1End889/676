-- 🔥 SERVER-SIDED KICK GUI FOR BACKDOORED GAMES 🔥
-- Paste this ENTIRE script into the game's built-in executor
-- It will run on the SERVER and give EVERYONE (including you) a working kick panel

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local REMOTE_NAME = "SS_AdminKickRemote_2026"

-- Create RemoteEvent (server-sided kick handler)
local kickRemote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not kickRemote then
	kickRemote = Instance.new("RemoteEvent")
	kickRemote.Name = REMOTE_NAME
	kickRemote.Parent = ReplicatedStorage
end

-- THIS IS THE SERVER-SIDED PART — actual kicking happens here
kickRemote.OnServerEvent:Connect(function(adminWhoClicked, targetPlayerName, reason)
	if typeof(targetPlayerName) ~= "string" then return end
	
	local target = Players:FindFirstChild(targetPlayerName)
	if target and target:IsA("Player") then
		local kickReason = (reason and reason ~= "") and reason or "Kicked by server-sided admin panel"
		target:Kick(kickReason)
		print("[SS KICK] " .. adminWhoClicked.Name .. " kicked " .. target.Name .. " | Reason: " .. kickReason)
	end
end)

-- Create the GUI template
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SS_KickPanel"
screenGui.ResetOnSpawn = false
screenGui.Enabled = true

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 460, 0, 520)
mainFrame.Position = UDim2.new(0.5, -230, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title bar (draggable)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 55)
titleBar.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔥 SERVER SIDED KICK PANEL 🔥"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Player list
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "PlayerScroll"
scrollFrame.Size = UDim2.new(1, -20, 0.68, -70)
scrollFrame.Position = UDim2.new(0, 10, 0, 65)
scrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 10)
scrollCorner.Parent = scrollFrame

-- Reason box
local reasonBox = Instance.new("TextBox")
reasonBox.Name = "ReasonTextBox"
reasonBox.Size = UDim2.new(1, -20, 0, 45)
reasonBox.Position = UDim2.new(0, 10, 1, -55)
reasonBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
reasonBox.PlaceholderText = "Kick reason (optional)"
reasonBox.Text = ""
reasonBox.TextColor3 = Color3.new(1, 1, 1)
reasonBox.TextScaled = true
reasonBox.Font = Enum.Font.Gotham
reasonBox.ClearTextOnFocus = true
reasonBox.Parent = mainFrame

local reasonCorner = Instance.new("UICorner")
reasonCorner.CornerRadius = UDim.new(0, 10)
reasonCorner.Parent = reasonBox

-- LocalScript (handles the GUI + live list + buttons)
local localScript = Instance.new("LocalScript")
localScript.Name = "KickPanelLogic"
localScript.Parent = screenGui

localScript.Source = [[
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")

	local remote = ReplicatedStorage:WaitForChild("SS_AdminKickRemote_2026")
	local main = script.Parent.MainFrame
	local scroll = main.PlayerScroll
	local reasonBox = main.ReasonTextBox
	local titleBar = main.TitleBar

	-- Draggable (drag from title bar)
	local dragging, dragStart, startPos
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Refresh player list
	local function refresh()
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		local offset = 0
		for _, plr in ipairs(Players:GetPlayers()) do
			local entry = Instance.new("Frame")
			entry.Size = UDim2.new(1, 0, 0, 52)
			entry.Position = UDim2.new(0, 0, 0, offset)
			entry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			entry.BorderSizePixel = 0
			entry.Parent = scroll

			local eCorner = Instance.new("UICorner")
			eCorner.CornerRadius = UDim.new(0, 8)
			eCorner.Parent = entry

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = "   👤 " .. plr.Name .. "   [" .. plr.UserId .. "]"
			nameLabel.TextColor3 = Color3.new(1,1,1)
			nameLabel.TextScaled = true
			nameLabel.Font = Enum.Font.GothamSemibold
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = entry

			local kickBtn = Instance.new("TextButton")
			kickBtn.Size = UDim2.new(0.4, 0, 1, 0)
			kickBtn.Position = UDim2.new(0.6, 0, 0, 0)
			kickBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
			kickBtn.Text = "KICK"
			kickBtn.TextColor3 = Color3.new(1,1,1)
			kickBtn.TextScaled = true
			kickBtn.Font = Enum.Font.GothamBold
			kickBtn.Parent = entry

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 8)
			bCorner.Parent = kickBtn

			kickBtn.MouseButton1Click:Connect(function()
				local reason = reasonBox.Text
				remote:FireServer(plr.Name, reason)
				kickBtn.Text = "KICKED"
				kickBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
				task.wait(1.5)
				if kickBtn then kickBtn.Text = "KICK"; kickBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40) end
			end)

			offset += 57
		end
		scroll.CanvasSize = UDim2.new(0, 0, 0, offset + 10)
	end

	refresh()
	while task.wait(2) do
		if main.Parent then refresh() else break end
	end
]]

-- Put template in StarterGui (new players get it automatically)
screenGui.Parent = StarterGui

-- Give GUI to every player currently in the game
for _, plr in ipairs(Players:GetPlayers()) do
	local pgui = plr:FindFirstChild("PlayerGui")
	if pgui and not pgui:FindFirstChild("SS_KickPanel") then
		local clone = screenGui:Clone()
		clone.Parent = pgui
	end
end

-- Extra safety for future joins
Players.PlayerAdded:Connect(function(plr)
	task.wait(0.8)
	local pgui = plr:FindFirstChild("PlayerGui")
	if pgui and not pgui:FindFirstChild("SS_KickPanel") then
		local clone = screenGui:Clone()
		clone.Parent = pgui
	end
end)

print("✅ SERVER-SIDED KICK GUI LOADED!")
print("A red panel should now be on everyone's screen.")
print("Live player list • Click KICK next to any name • Works for EVERYONE in the server")