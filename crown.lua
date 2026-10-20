local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local placeId = game.PlaceId
local running = false

local gui = Instance.new("ScreenGui")
gui.Name = "SlapUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 220, 0, 120)
main.Position = UDim2.new(0.5, -110, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
title.Text = "  自动打人换服"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.BorderSizePixel = 0
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 24, 0, 24)
miniBtn.Position = UDim2.new(1, -27, 0, 3)
miniBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
miniBtn.Text = "—"
miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBtn.TextSize = 14
miniBtn.Font = Enum.Font.GothamBold
miniBtn.BorderSizePixel = 0
miniBtn.Parent = main
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 6)

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -30)
body.Position = UDim2.new(0, 0, 0, 30)
body.BackgroundTransparency = 1
body.Parent = main

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 190, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -95, 0, 20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.Text = "自动打人换服：关"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = body
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local dragging = false
local dragStart, startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local minimized = false
miniBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	body.Visible = not minimized
	main.Size = minimized and UDim2.new(0, 220, 0, 30) or UDim2.new(0, 220, 0, 120)
	miniBtn.Text = minimized and "+" or "—"
end)

local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

local function equipDefault()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ClickDetector") and v.Parent and v.Parent.Name == "Default" then
			fireclickdetector(v)
			return true
		end
	end
	return getChar():FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
end

local function enterArena()
	local hrp = getChar():WaitForChild("HumanoidRootPart")
	local portal = workspace:FindFirstChild("Teleport1", true) or workspace:FindFirstChild("NormalArenaPortal", true)
	if portal and portal:IsA("BasePart") then
		firetouchinterest(hrp, portal, 0)
		task.wait(0.1)
		firetouchinterest(hrp, portal, 1)
		return true
	end
	return false
end

local function slapEveryone()
	local remote = game:GetService("ReplicatedStorage"):WaitForChild("b")
	for _, target in ipairs(Players:GetPlayers()) do
		if not running then break end
		if target ~= player and target.Character then
			local head = target.Character:FindFirstChild("Head")
			local hum = target.Character:FindFirstChildOfClass("Humanoid")
			if head and hum and hum.Health > 0 then
				remote:FireServer(head)
				task.wait(0.15)
			end
		end
	end
end

local function hopServer()
	local url = ("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(placeId)
	local ok, res = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(url))
	end)
	if ok and res and res.data then
		for _, s in ipairs(res.data) do
			if s.id ~= game.JobId and s.playing > 1 and s.playing < s.maxPlayers then
				TeleportService:TeleportToPlaceInstance(placeId, s.id, player)
				return
			end
		end
	end
	TeleportService:Teleport(placeId, player)
end

local function mainLoop()
	task.wait(3)
	equipDefault()
	task.wait(1)
	enterArena()
	task.wait(3)
	while running do
		slapEveryone()
		if not running then break end
		task.wait(1)
		hopServer()
		break
	end
	running = false
	toggleBtn.Text = "自动打人换服：关"
	toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end

toggleBtn.MouseButton1Click:Connect(function()
	running = not running
	toggleBtn.Text = running and "自动打人换服：开" or "自动打人换服：关"
	toggleBtn.BackgroundColor3 = running and Color3.fromRGB(50, 170, 80) or Color3.fromRGB(200, 50, 50)
	if running then
		task.spawn(mainLoop)
	end
end)
