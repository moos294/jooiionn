local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)

local src = [==[
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local placeId = game.PlaceId
local running = true
local hopping = false

pcall(function()
	local mt = getrawmetatable(game)
	local oldNamecall = mt.__namecall
	setreadonly(mt, false)
	mt.__namecall = newcclosure(function(self, ...)
		local method = getnamecallmethod()
		if method == "Kick" then
			return nil
		end
		return oldNamecall(self, ...)
	end)
	setreadonly(mt, true)
end)

pcall(function()
	hookfunction(player.Kick, newcclosure(function(...)
		return nil
	end))
end)

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
title.Text = "  自动打人换服 2.0"
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
	pcall(function()
		status.Text = "状态：" .. t
	end)
	print("[SlapUI] " .. t)
end

local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
	local char = getChar()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		hrp = char:WaitForChild("HumanoidRootPart", 5)
	end
	return char, hrp
end

local function isAlive()
	local char = player.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart") ~= nil
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
	local _, hrp = getHRP()
	if not hrp then return false end
	local portal = nil
	for i = 1, 15 do
		if not running or hopping then return false end
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
		setStatus("已触碰传送门: " .. portal.Name)
		return true
	else
		setStatus("触碰传送门失败: " .. tostring(err))
		return false
	end
end

local respawned = false

player.CharacterAdded:Connect(function()
	respawned = true
end)

local function handleRespawnIfNeeded()
	if respawned then
		respawned = false
		setStatus("检测到重生，重新进场...")
		task.wait(1.5)
		enterArena()
		task.wait(3)
	end
	if not isAlive() then
		setStatus("等待角色重生...")
		local t = 0
		while not isAlive() and t < 15 and running and not hopping do
			task.wait(0.5)
			t = t + 0.5
		end
		if isAlive() then
			task.wait(1)
			enterArena()
			task.wait(3)
		end
	end
end

local function slapTarget(remote, tool, target)
	local tChar = target.Character
	if not tChar then return end
	local head = tChar:FindFirstChild("Head")
	local tHrp = tChar:FindFirstChild("HumanoidRootPart")
	local hum = tChar:FindFirstChildOfClass("Humanoid")
	if not (head and tHrp and hum and hum.Health > 0) then return end
	for i = 1, 4 do
		if not running or hopping then break end
		if hum.Health <= 0 then break end
		if not isAlive() then
			handleRespawnIfNeeded()
			if not isAlive() then return end
		end
		local _, hrp = getHRP()
		if not hrp then return end
		hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 2) * CFrame.Angles(0, math.rad(180), 0)
		pcall(function()
			remote:FireServer(head)
		end)
		if tool and tool.Parent then
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
		task.wait(0.2)
	end
end

local function slapEveryone()
	local remote = game:GetService("ReplicatedStorage"):FindFirstChild("b")
	if not remote then
		setStatus("错误：没找到攻击远程 b")
		return 0
	end
	local count = 0
	for _, target in ipairs(Players:GetPlayers()) do
		if not running or hopping then break end
		if target ~= player then
			handleRespawnIfNeeded()
			if isAlive() and not hopping then
				local char = getChar()
				local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
				if tool and tool.Parent ~= char then
					tool.Parent = char
					task.wait(0.2)
				end
				setStatus("正在打: " .. target.Name)
				pcall(function()
					slapTarget(remote, tool, target)
				end)
				count = count + 1
				task.wait(1)
			end
		end
	end
	return count
end

local hopFailed = false

TeleportService.TeleportInitFailed:Connect(function(plr, result, msg)
	if plr == player then
		hopFailed = true
		hopping = false
		setStatus("传送被拒: " .. tostring(result) .. "，换下一个服")
	end
end)

local function getServerList()
	local candidates = {}
	local url = ("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(placeId)
	local ok, res = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(url))
	end)
	if ok and res and res.data then
		for _, s in ipairs(res.data) do
			if s.id ~= game.JobId and s.playing >= 2 and s.playing <= s.maxPlayers - 2 then
				table.insert(candidates, s.id)
			end
		end
	end
	return candidates
end

local function prepareTeleport()
	hopping = true
	setStatus("正在清理，准备传送...")
	task.wait(0.5)
	pcall(function()
		gui.Enabled = false
	end)
	pcall(function()
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.Velocity = Vector3.zero
				hrp.AssemblyLinearVelocity = Vector3.zero
			end
		end
	end)
	task.wait(0.5)
end

local function hopServer()
	setStatus("正在获取服务器列表...")
	local candidates = getServerList()
	if #candidates == 0 then
		setStatus("没有可用服务器，10 秒后重试")
		task.wait(10)
		candidates = getServerList()
		if #candidates == 0 then
			setStatus("仍然没有可用服务器，本轮结束")
			return
		end
	end
	setStatus("找到 " .. #candidates .. " 个可用服务器")
	for i = 1, math.min(10, #candidates) do
		if not running then return end
		hopFailed = false
		prepareTeleport()
		setStatus("尝试传送 " .. i .. "/" .. math.min(10, #candidates))
		pcall(function()
			TeleportService:TeleportToPlaceInstance(placeId, candidates[i], player)
		end)
		task.wait(6)
		if not hopFailed then
			task.wait(6)
			if not hopFailed then
				setStatus("传送无响应，换下一个")
				hopFailed = true
			end
		end
		if hopFailed then
			hopping = false
			pcall(function()
				gui.Enabled = true
			end)
			task.wait(1)
		end
	end
	setStatus("全部传送失败，20 秒后重新获取列表")
	hopping = false
	pcall(function()
		gui.Enabled = true
	end)
	task.wait(20)
	if running then
		hopServer()
	end
end

local function mainLoop()
	while running do
		local ok, err = pcall(function()
			task.wait(3)
			setStatus("正在进入决斗场...")
			enterArena()
			task.wait(4)
			setStatus("正在打人...")
			local n = slapEveryone()
			setStatus("本轮打了 " .. n .. " 人，准备换服")
			task.wait(2)
			hopServer()
		end)
		if not ok then
			setStatus("出错已自动恢复: " .. tostring(err))
			task.wait(3)
		else
			break
		end
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
