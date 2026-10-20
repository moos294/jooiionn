local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)

local src = [==[
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local placeId = game.PlaceId
local running = true

local gui = Instance.new("ScreenGui")
gui.Name = "SlapUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 170)
main.Position = UDim2.new(0.5, -120, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
title.Text = "  自动打人换服 1.0"
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
toggleBtn.Size = UDim2.new(0, 210, 0, 38)
toggleBtn.Position = UDim2.new(0.5, -105, 0, 12)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 170, 80)
toggleBtn.Text = "自动打人换服：开"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = body
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 70)
status.Position = UDim2.new(0, 10, 0, 58)
status.BackgroundTransparency = 1
status.Text = "状态：初始化..."
status.TextColor3 = Color3.fromRGB(255, 220, 100)
status.TextSize = 12
status.Font = Enum.Font.Gotham
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.Parent = body

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
	main.Size = minimized and UDim2.new(0, 240, 0, 30) or UDim2.new(0, 240, 0, 170)
	miniBtn.Text = minimized and "+" or "—"
end)

local function setStatus(t)
	status.Text = "状态：" .. t
	print("[SlapUI] " .. t)
end

local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

local function findPortal()
	local exact = workspace:FindFirstChild("Teleport1", true)
	if exact and exact:IsA("BasePart") then
		return exact
	end
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			local n = v.Name:lower()
			if n:find("teleport") or n:find("portal") then
				return v
			end
		end
	end
	return nil
end

local function enterArena()
	local hrp = getChar():WaitForChild("HumanoidRootPart")
	local portal = nil
	for i = 1, 15 do
		if not running then return false end
		portal = findPortal()
		if portal then break end
		setStatus("搜索传送门中... 第 " .. i .. " 次")
		task.wait(2)
	end
	if not portal then
		setStatus("30 秒未找到传送门，请手动进场")
		return false
	end
	local ok, err = pcall(function()
		firetouchinterest(hrp, portal, 0)
		task.wait(0.1)
		firetouchinterest(hrp, portal, 1)
	end)
	if ok then
		setStatus("已触碰传送门: " .. portal:GetFullName())
		return true
	else
		setStatus("触碰传送门失败: " .. tostring(err))
		return false
	end
end

local function slapTarget(remote, hrp, tool, target)
	local tChar = target.Character
	if not tChar then return end
	local head = tChar:FindFirstChild("Head")
	local tHrp = tChar:FindFirstChild("HumanoidRootPart")
	local hum = tChar:FindFirstChildOfClass("Humanoid")
	if not (head and tHrp and hum and hum.Health > 0) then return end
	for i = 1, 8 do
		if not running then break end
		if hum.Health <= 0 then break end
		hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 2) * CFrame.Angles(0, math.rad(180), 0)
		pcall(function()
			remote:FireServer(head)
		end)
		if tool then
			pcall(function()
				tool:Activate()
			end)
			local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true)
			if handle then
				pcall(function()
					firetouchinterest(handle, tHrp, 0)
					firetouchinterest(handle, tHrp, 1)
				end)
			end
		end
		task.wait(0.05)
	end
end

local function slapEveryone()
	local char = getChar()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
	if tool and tool.Parent ~= char then
		tool.Parent = char
	end
	local remote = game:GetService("ReplicatedStorage"):FindFirstChild("b")
	if not remote then
		setStatus("错误：没找到攻击远程 b")
		return 0
	end
	local count = 0
	for _, target in ipairs(Players:GetPlayers()) do
		if not running then break end
		if target ~= player then
			slapTarget(remote, hrp, tool, target)
			count = count + 1
		end
	end
	return count
end

local function hopServer()
	setStatus("正在换服...")
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
	local ok2, err2 = pcall(function()
		TeleportService:Teleport(placeId, player)
	end)
	if not ok2 then
		setStatus("换服失败: " .. tostring(err2))
	end
end

local function mainLoop()
	task.wait(3)
	setStatus("正在进入决斗场...")
	enterArena()
	task.wait(4)
	while running do
		setStatus("正在打人...")
		local n = slapEveryone()
		if not running then break end
		setStatus("本轮打了 " .. n .. " 人，准备换服")
		task.wait(1.5)
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

task.spawn(mainLoop)
]==]

if qot then
	qot(src)
end

loadstring(src)()
