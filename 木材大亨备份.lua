local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/UI.lua"))()
local Window = UI.Window
local WindUI = UI.WindUI

for _, v in ipairs(UI.Gui.Panel:GetDescendants()) do
    if v:IsA("TextLabel") then
        if v.Text == "ORIGAMI" then v.Text = "封存力量 满血版" end
        if v.Text == "BUILD TOOL" then v.Text = "Author: 封存" end
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

local function fmt(n)
    n = math.floor(tonumber(n) or 0)
    local s = tostring(n)
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if out:sub(1, 1) == "," then out = out:sub(2) end
    return out
end

local function getStat(name1, name2)
    local val = 0
    pcall(function()
        if LP.leaderstats then
            local stat = LP.leaderstats:FindFirstChild(name1) or LP.leaderstats:FindFirstChild(name2)
            if stat then val = stat.Value end
        end
        if val == 0 then
            local attr = LP:GetAttribute(name1) or LP:GetAttribute(name2)
            if attr then val = attr end
        end
    end)
    return val
end

local hud = Instance.new("ScreenGui")
hud.Name = "FengCunHUD"
hud.ResetOnSpawn = false
hud.IgnoreGuiInset = true
hud.Parent = LP:WaitForChild("PlayerGui")

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 110, 0, 35)
openBtn.Position = UDim2.new(0, 20, 0.2, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
openBtn.Text = "📊 查看统计"
openBtn.TextColor3 = Color3.fromRGB(60, 150, 230)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 13
openBtn.Parent = hud
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 6)

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 150)
frame.Position = UDim2.new(0, 20, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = hud
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundTransparency = 1
title.Text = "📊 封存数据统计"
title.TextColor3 = Color3.fromRGB(60, 150, 230)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -24, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = frame

local function createLabel(y, txt, col)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 0, 18)
    l.Position = UDim2.new(0, 10, 0, y)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = col or Color3.fromRGB(230, 230, 235)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = frame
    return l
end

local lblStr = createLabel(32, "当前力量: 0")
local lblReb = createLabel(58, "当前转生: 0")

local packBox = Instance.new("TextBox")
packBox.Size = UDim2.new(1, -20, 0, 28)
packBox.Position = UDim2.new(0, 10, 0, 95)
packBox.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
packBox.Text = "设置包数 (1包=2次重生)"
packBox.TextColor3 = Color3.fromRGB(200, 200, 200)
packBox.Font = Enum.Font.Gotham
packBox.TextSize = 11
packBox.Parent = frame
Instance.new("UICorner", packBox).CornerRadius = UDim.new(0, 6)

local currentPacks = 0
packBox.FocusLost:Connect(function()
    local num = tonumber(packBox.Text:match("%d+"))
    if num then
        currentPacks = num
        packBox.Text = "包数: " .. num .. " (额外+" .. (num * 2) .. "重生)"
    else
        currentPacks = 0
        packBox.Text = "设置包数 (1包=2次重生)"
    end
end)

openBtn.MouseButton1Click:Connect(function() openBtn.Visible = false frame.Visible = true end)
closeBtn.MouseButton1Click:Connect(function() openBtn.Visible = true frame.Visible = false end)

local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = frame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

task.spawn(function()
    while hud.Parent do
        task.wait(0.5)
        lblStr.Text = "当前力量: " .. fmt(getStat("Strength", "Power"))
        lblReb.Text = "当前转生: " .. fmt(getStat("Rebirths", "Rebirth"))
    end
end)

LP.Idled:Connect(function()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

local FastTrain
do
    local muscleEvent = LP:WaitForChild("muscleEvent")
    local CONFIG = { Rate = 500, TokenBurst = 20 }
    local state = { running = false, tokens = 0, lastTick = os.clock(), sendRate = CONFIG.Rate, lastControlAt = 0, lastStrength = 0, stalledCount = 0 }
    local function unlockTools()
        local tools = { { name = "Weight", prop = "repTime" }, { name = "Pushups", prop = "repTime" }, { name = "Situps", prop = "repTime" }, { name = "Handstands", prop = "repTime" } }
        local function process(container)
            for _, toolData in ipairs(tools) do
                local tool = container:FindFirstChild(toolData.name)
                if tool then
                    local timeObj = tool:FindFirstChild(toolData.prop)
                    if timeObj then timeObj.Value = 0 end
                end
            end
        end
        local backpack = LP:FindFirstChild("Backpack")
        if backpack then process(backpack) end
        if LP.Character then process(LP.Character) end
    end
    RunService.Heartbeat:Connect(unlockTools)
    local function updateRate(now)
        if now - state.lastControlAt < 0.5 then return end
        state.lastControlAt = now
        local Strength = LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Strength")
        if not Strength then return end
        local currentStr = Strength.Value
        if currentStr > state.lastStrength then
            state.stalledCount = 0
            state.sendRate = math.min(CONFIG.Rate, state.sendRate + 50)
        else
            state.stalledCount = state.stalledCount + 1
        end
        if state.stalledCount >= 2 then
            state.sendRate = math.max(100, state.sendRate - 100)
            state.stalledCount = 0
            state.tokens = 0
        end
        state.lastStrength = currentStr
    end
    RunService.Heartbeat:Connect(function()
        if not state.running or not muscleEvent then return end
        local now = os.clock()
        local dt = now - state.lastTick
        state.lastTick = now
        updateRate(now)
        state.tokens = math.min(CONFIG.TokenBurst, state.tokens + state.sendRate * dt)
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local sent = 0
            while state.tokens >= 1 do
                muscleEvent:FireServer("rep")
                state.tokens = state.tokens - 1
                sent = sent + 1
                if sent >= CONFIG.TokenBurst then break end
            end
        else state.tokens = 0 end
    end)
    FastTrain = {}
    function FastTrain.SetRate(rate) local n = tonumber(rate) if n and n > 0 then CONFIG.Rate = math.floor(n) if state.sendRate > CONFIG.Rate then state.sendRate = CONFIG.Rate end end end
    function FastTrain.Start() if state.running then return end state.running = true state.lastTick = os.clock() state.lastControlAt = os.clock() state.sendRate = CONFIG.Rate state.tokens = 0 local Strength = LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Strength") if Strength then state.lastStrength = Strength.Value end end
    function FastTrain.Stop() state.running = false state.tokens = 0 end
end

local TabBasic = Window:Tab({ Title = "基础与重生" })
local workType = ""
local autowork = false
local autorebirth = false
local rebirthTarget = 0
local rebirthMainThread = nil
TabBasic:Dropdown({ Title = "选择锻炼类型", Values = { "哑铃", "倒立", "仰卧起坐", "俯卧撑", "--" }, Default = "", Callback = function(val) workType = val end })
TabBasic:Toggle({ Title = "自动锻炼", Default = false, Callback = function(state)
    autowork = state
    if state then task.spawn(function() while autowork do pcall(function()
        local player = Players.LocalPlayer
        local char = player.Character
        local backpack = player.Backpack
        if not char then return end
        player.muscleEvent:FireServer("rep")
        local toolName = ""
        if workType == "哑铃" then toolName = "Weight" elseif workType == "倒立" then toolName = "Handstands" elseif workType == "仰卧起坐" then toolName = "Situps" elseif workType == "俯卧撑" then toolName = "Pushups" end
        if toolName ~= "" and backpack:FindFirstChild(toolName) then char.Humanoid:EquipTool(backpack[toolName]) end
    end) task.wait() end end) end
end })
TabBasic:Input({ Title = "自定义重生次数", Placeholder = "输入数值", Default = "", Callback = function(val) rebirthTarget = tonumber(val) or 0 end })
TabBasic:Toggle({ Title = "自动重生", Default = false, Callback = function(state)
    if rebirthMainThread then task.cancel(rebirthMainThread) rebirthMainThread = nil end
    autorebirth = state
    if state then rebirthMainThread = task.spawn(function()
        local player = Players.LocalPlayer
        while autorebirth do pcall(function()
            local rebirthRemote = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("rebirthRemote")
            if rebirthRemote then rebirthRemote:InvokeServer("rebirthRequest") repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
        end)
        if rebirthTarget > 0 and player.leaderstats.Rebirths.Value >= rebirthTarget then autorebirth = false end
        task.wait(0.1) end
    end) end
end })
TabBasic:Input({ Title = "快速锻炼速率", Placeholder = "500", Default = "500", Callback = function(v) FastTrain.SetRate(v) end })
TabBasic:Toggle({ Title = "快速锻炼 (防封)", Default = false, Callback = function(state) if state then FastTrain.Start() else FastTrain.Stop() end end })
local function createMachineToggle(tab, name, cf, machineName)
    local active = false
    tab:Toggle({ Title = name, Default = false, Callback = function(state)
        active = state
        if state then task.spawn(function() while active do pcall(function()
            local player = LP local char = player.Character local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local machineInUse = player:FindFirstChild("machineInUse") local isUsing = machineInUse and machineInUse.Value ~= nil
            if not isUsing then
                root.CFrame = cf task.wait(0.15) VirtualInputManager:SendKeyEvent(true, "E", false, game) task.wait(0.05) VirtualInputManager:SendKeyEvent(false, "E", false, game) task.wait(0.3)
            else local seat = machineInUse.Value if seat and player:FindFirstChild("muscleEvent") then player.muscleEvent:FireServer("rep", seat) end end
        end) task.wait(0.1) end end) else pcall(function() local char = LP.Character if char then char:WaitForChild("Humanoid").Jump = true end end) end
    end })
end
local function createTreadmillToggle(tab, name, cf)
    local running = false local bindName = "Treadmill_" .. name
    tab:Toggle({ Title = name, Default = false, Callback = function(state)
        running = state
        if state then task.spawn(function()
            local char = LP.Character local originalSpeed = 16 if char and char:FindFirstChild("Humanoid") then originalSpeed = char.Humanoid.WalkSpeed end
            while running do pcall(function()
                char = LP.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.Humanoid.WalkSpeed = 10 char.HumanoidRootPart.CFrame = cf
                    RunService:BindToRenderStep(bindName, Enum.RenderPriority.Character.Value + 1, function() if char and char:FindFirstChild("Humanoid") then char.Humanoid:Move(Vector3.new(10000, 0, -1), true) end end)
                end
            end) task.wait() end
            RunService:UnbindFromRenderStep(bindName) pcall(function() char = LP.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = originalSpeed end end)
        end) else RunService:UnbindFromRenderStep(bindName) pcall(function() local char = LP.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = 16 end end) end
    end })
end

local gyms = {
    Hall = { Name = "大厅", Data = {
        { name = "①硬拉1500", cf = CFrame.new(135.838379, 3.30565023, 97.185379, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "①硬拉2500", cf = CFrame.new(138.122299, 3.30565, 66.0853577, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "①硬拉4000", cf = CFrame.new(141.232071, 3.30565, 26.4854164, 0, 0, 1, 0, 1, 0, -1, 0, 0) },
        { name = "②硬拉1500", cf = CFrame.new(182.817261, 3.30565023, 97.1852036, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "②硬拉2500", cf = CFrame.new(180.733276, 3.30565023, 66.0851135, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "②硬拉4000", cf = CFrame.new(177.823456, 3.30565, 26.4850807, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { name = "①仰卧推举", cf = CFrame.new(111.400826, 6.71424437, 352.656433, 0.998808622, 4.62216354e-09, -0.0487988107, -4.46773907e-09, 1, 3.27358518e-09, 0.0487988107, -3.0516647e-09, 0.998808622) }, { name = "①仰卧推举10", cf = CFrame.new(4.74278641, 6.71424484, 46.4786491, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "①仰卧推举150", cf = CFrame.new(-15.1012564, 7.55120468, 45.4072647, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
        { name = "②仰卧推举10", cf = CFrame.new(4.74273682, 6.71424484, -0.592803359, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "②仰卧推举150", cf = CFrame.new(-15.1014681, 7.55120468, -0.921384215, -1, 0, 0, 0, 1, 0, 0, 0, -1) },
        { name = "①深蹲架1000", cf = CFrame.new(234.779938, 3.30564976, 97.0440903, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "①深蹲架1000前", cf = CFrame.new(-42.9242592, 3.30565047, 39.5736923, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "①深蹲架1000左", cf = CFrame.new(-235.653976, 3.30564952, 136.869431, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { name = "①深蹲架1500", cf = CFrame.new(231.255844, 3.30564952, 62.9939117, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "①深蹲架1500左", cf = CFrame.new(-231.32988, 3.30564976, 66.7550735, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { name = "②深蹲架1000前", cf = CFrame.new(-41.9757195, 3.30564976, 3.73980021, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "②深蹲架1000左", cf = CFrame.new(-235.653976, 3.30564904, 103.995522, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { name = "②深蹲架1500", cf = CFrame.new(231.255905, 3.30564976, 24.3584881, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "②深蹲架1500左", cf = CFrame.new(-231.32988, 3.30564952, 23.8196106, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { name = "③深蹲架1000前", cf = CFrame.new(-73.3981934, 3.30565047, 39.5736923, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "④深蹲架1000前", cf = CFrame.new(-72.449646, 3.30564976, 3.73979521, -1, 0, 0, 0, 1, 0, 0, 0, -1) },
        { name = "①引体1000", cf = CFrame.new(-185.000092, 3.30564976, 137.263672, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "①引体2500", cf = CFrame.new(-185.000092, 3.30564976, 67.5385132, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "②引体1000", cf = CFrame.new(-185.000092, 3.30564952, 104.06366, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "②引体2500", cf = CFrame.new(-185.000092, 3.30564976, 24.0887852, 0, 0, 1, 0, 1, 0, -1, 0, 0) },
        { name = "①仰卧起坐150", cf = CFrame.new(74.7987747, 7.55120564, 350.807373, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "②仰卧起坐10", cf = CFrame.new(94.6428375, 6.71424484, 351.878723, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "②仰卧起坐150", cf = CFrame.new(74.7985382, 7.55120564, 304.478668, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "③仰卧起坐10", cf = CFrame.new(111.642921, 6.71424484, 304.80722, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "④仰卧起坐10", cf = CFrame.new(94.6427307, 6.71424484, 304.80722, -1, 0, 0, 0, 1, 0, 0, 0, -1) },
        { name = "①仰卧起坐10左", cf = CFrame.new(-195.914307, 6.71424484, 383.535706, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "①仰卧起坐150左", cf = CFrame.new(-195.585709, 7.55120468, 346.691345, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "①仰卧起坐400左", cf = CFrame.new(-194.551514, 8.82657242, 300.776245, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "②仰卧起坐10左", cf = CFrame.new(-195.914276, 6.71424484, 366.535553, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "②仰卧起坐150左", cf = CFrame.new(-195.585663, 7.55120564, 325.379761, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "②仰卧起坐400左", cf = CFrame.new(-194.551544, 8.82657433, 272.894531, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "③仰卧起坐10左", cf = CFrame.new(-242.985718, 6.71424484, 383.535675, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "③仰卧起坐150左", cf = CFrame.new(-241.914322, 7.55120659, 346.691559, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "③仰卧起坐400左", cf = CFrame.new(-239.748322, 8.82657337, 300.776398, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "④仰卧起坐10左", cf = CFrame.new(-242.985718, 6.71424484, 366.535614, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "④仰卧起坐150左", cf = CFrame.new(-241.914322, 7.55120468, 325.379883, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "④仰卧起坐400左", cf = CFrame.new(-239.748322, 8.82657337, 272.894623, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { name = "①跑步机0", cf = CFrame.new(-27.8830738, 4.41672897, 261.175507, 0.564802229, -5.11192644e-09, -0.825226307, 3.02890241e-10, 1, -5.98727068e-09, 0.825226307, 3.1316707e-09, 0.564802229) }, { name = "①跑步机10", cf = CFrame.new(238.671112, 5.40315914, 387.713165, -0.0160072874, -2.90710176e-08, -0.99987185, -3.3434191e-09, 1, -2.90212157e-08, 0.99987185, 2.87843993e-09, -0.0160072874) }, { name = "①跑步机20", cf = CFrame.new(239.613434, 5.04044819, 358.220367, 0.00401047058, -5.37945333e-08, -0.999991953, -4.41010144e-08, 1, -5.39718314e-08, 0.999991953, 4.43171118e-08, 0.00401047058) }, { name = "①跑步机100", cf = CFrame.new(236.496414, 5.6660099, 324.961945, 0.0235777963, 9.22312338e-10, -0.999722004, -8.43754009e-08, 1, -1.06737041e-09, 0.999722004, 8.43771133e-08, 0.0235777963) }, { name = "①跑步机100左", cf = CFrame.new(-136.306549, 5.6660099, -115.52002, 0.999168098, 2.05816045e-10, 0.0407816805, -2.54893606e-10, 1, 1.19822197e-09, -0.0407816805, -1.20762012e-09, 0.999168098) }, { name = "①跑步机250", cf = CFrame.new(233.572845, 6.50978899, 279.890015, 0.0105351051, 4.99802155e-08, -0.999944508, 1.00854407e-07, 1, 5.10455607e-08, 0.999944508, -1.01386583e-07, 0.0105351051) }, { name = "①跑步机250左", cf = CFrame.new(-176.619217, 6.50978851, -110.555016, 0.992729127, -1.03382369e-08, 0.120369554, 1.06406022e-08, 1, -1.86923632e-09, -0.120369554, 3.13644999e-09, 0.992729127) }, { name = "①跑步机600", cf = CFrame.new(230.512817, 7.79000807, 220.043625, 0.0873519629, 5.28795452e-09, -0.996177495, -1.2905895e-08, 1, 4.17656398e-09, 0.996177495, 1.24917312e-08, 0.0873519629) }, { name = "①跑步机600左", cf = CFrame.new(-229.857269, 7.79000807, -106.370033, 0.997136414, -4.94225176e-08, 0.0756242126, 4.83853846e-08, 1, 1.55464797e-08, -0.0756242126, -1.18428547e-08, 0.997136414) }, { name = "①跑步机1000", cf = CFrame.new(220.189423, 8.9247427, -117.170845, -0.013011341, -1.46350143e-09, -0.999915361, 3.34266694e-08, 1, -1.89858795e-09, 0.999915361, -3.34485399e-08, -0.013011341) }, { name = "②跑步机0", cf = CFrame.new(-35.6689377, 4.98409796, 252.130386, 0.408518851, 7.43816209e-09, -0.912749887, -5.12923428e-08, 1, -1.48077008e-08, 0.912749887, 5.28663051e-08, 0.408518851) }, { name = "②跑步机10", cf = CFrame.new(239.640167, 5.04044819, 372.711761, 0.029969966, -1.28647903e-09, -0.999550819, 1.28739501e-07, 1, 2.57299515e-09, 0.999550819, -1.28758785e-07, 0.029969966) }, { name = "②跑步机20", cf = CFrame.new(239.345917, 5.04044819, 343.10083, 0.0597619638, 2.24676153e-08, -0.998212636, 7.73517694e-09, 1, 2.29709407e-08, 0.998212636, -9.09413966e-09, 0.0597619638) }, { name = "②跑步机100", cf = CFrame.new(236.872421, 5.6660099, 304.633728, 0.0480287559, 2.44919907e-09, -0.998845935, 1.65263216e-08, 1, 3.24668448e-09, 0.998845935, -1.66631846e-08, 0.0480287559) }, { name = "②跑步机100左", cf = CFrame.new(-154.383545, 5.6660099, -116.297073, 0.997724295, 7.15217183e-08, 0.0674260035, -7.50726841e-08, 1, 5.01308079e-08, -0.0674260035, -5.50785764e-08, 0.997724295) }, { name = "②跑步机250", cf = CFrame.new(234.890656, 6.50978899, 252.083389, 0.0101178577, -2.29435333e-08, -0.9999488, -8.55895763e-08, 1, -2.38107347e-08, 0.9999488, 8.58261089e-08, 0.0101178577) }, { name = "②跑步机250左", cf = CFrame.new(-201.69278, 6.50978851, -110.268921, 0.997821212, 8.88301059e-08, 0.0659763142, -8.40411047e-08, 1, -7.53620668e-08, -0.0659763142, 6.96531401e-08, 0.997821212) }, { name = "②跑步机600", cf = CFrame.new(225.811386, 7.79000807, -90.2171707, -0.00239520147, 6.83120192e-08, -0.999997139, -6.62442972e-08, 1, 6.84708894e-08, 0.999997139, 6.64081057e-08, -0.00239520147) }, { name = "③跑步机0", cf = CFrame.new(-42.1799202, 5.69912529, 237.991882, -0.0540122949, -8.45547277e-08, -0.998540282, -2.62576254e-08, 1, -8.32580227e-08, 0.998540282, 2.17223395e-08, -0.0540122949) }
    } },
    Beach = { Name = "沙滩", Data = {
        { name = "①硬拉8000", cf = CFrame.new(-68.4866943, 3.31417942, -494.214325, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "②硬拉8000", cf = CFrame.new(67.0421143, 3.31417942, -494.215057, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { name = "①推举3000", cf = CFrame.new(196.73172, 12.6128159, -317.205231, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "①推举4000", cf = CFrame.new(197.98735, 15.4425354, -374.905212, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "①推举10000", cf = CFrame.new(473.462585, 18.7106667, -257.305542, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "①推举15000", cf = CFrame.new(466.041656, 22.1382141, -328.803345, 0, 0, 1, 0, 1, 0, -1, 0, 0) },
        { name = "①抛掷3000", cf = CFrame.new(-86.1599579, 3.31418014, -293.360443, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "②抛掷3000", cf = CFrame.new(-86.1599426, 3.31417918, -324.26059, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "①抛掷7500", cf = CFrame.new(-75.0598831, 3.31417894, -364.385376, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "②抛掷7500", cf = CFrame.new(-75.0598679, 3.31417942, -408.035553, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "①抛掷15000", cf = CFrame.new(55.6397324, 3.31417942, -281.327942, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "②抛掷15000", cf = CFrame.new(55.6396255, 3.31417942, -343.442596, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "①抛掷25000", cf = CFrame.new(36.9296036, 3.31417942, -411.535248, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { name = "①深蹲4000", cf = CFrame.new(-195.254028, 3.31417942, -354.65448, 0, 0, 1, 0, 1, 0, -1, 0, 0) }, { name = "①深蹲10000", cf = CFrame.new(-203.108704, 3.3141799, -422.33844, 0, 0, 1, 0, 1, 0, -1, 0, 0) },
        { name = "①跑步机1000", cf = CFrame.new(-413.187378, 12.8381319, -263.237732, -0.0668151081, 8.37962375e-08, 0.997765362, -3.2232748e-08, 1, -8.61423644e-08, -0.997765362, -3.79163332e-08, -0.0668151081) }, { name = "①跑步机1500", cf = CFrame.new(-419.057526, 15.5876875, -328.426819, -0.104439825, -7.26821991e-10, 0.994531214, -7.96818611e-08, 1, -7.63690267e-09, -0.994531214, -8.00436979e-08, -0.104439825) }, { name = "①跑步机2000", cf = CFrame.new(-422.635712, 18.7445793, -404.703339, -0.0219939984, -5.53460815e-08, 0.999758124, 7.62561143e-08, 1, 5.7037056e-08, -0.999758124, 7.7492146e-08, -0.0219939984) }, { name = "①跑步机3000", cf = CFrame.new(-391.424866, 23.0493374, -498.073395, -0.00305148936, 5.73683456e-09, 0.999995351, 4.13070893e-08, 1, -5.6108127e-09, -0.999995351, 4.12897769e-08, -0.00305148936) }, { name = "②跑步机2000", cf = CFrame.new(432.956726, 18.7445793, -405.844025, 0.036689911, 7.83524854e-08, -0.999326706, -2.93913676e-08, 1, 7.73261846e-08, 0.999326706, 2.65344884e-08, 0.036689911) }, { name = "③跑步机2000", cf = CFrame.new(425.59726, 18.7445793, -497.523895, 0.0272405371, 1.28495374e-08, -0.999628901, 9.92943239e-09, 1, 1.31248914e-08, 0.999628901, -1.02832765e-08, 0.0272405371) }
    } },
    Frost = { Name = "冰霜", Data = {
        { name = "冰霜推举5000", cf = CFrame.new(-2917.47168, 3.31418037, -209.563873, -1, 0, 0, 0, 1, 0, 0, 0, -1) },
        { name = "①练习凳1000", cf = CFrame.new(-2605.58521, 10.4403896, -176.204895, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "②练习凳1000", cf = CFrame.new(-2641.11401, 10.4403906, -176.204895, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "①练习凳3000", cf = CFrame.new(-2695.14404, 14.0672112, -181.814285, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "②练习凳3000", cf = CFrame.new(-2748.75537, 14.0672121, -181.814285, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "练习凳7500", cf = CFrame.new(-3022.5498, 29.5708885, -197.53894, 0, 0, -1, 0, 1, 0, 1, 0, 0) }, { name = "练习凳15000", cf = CFrame.new(-3008.67017, 39.2158623, -337.746918, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
        { name = "①冰霜深蹲4000", cf = CFrame.new(-2629.13818, 3.36860609, -609.827454, -0.995664716, -2.67296816e-08, -0.0930150598, -1.90042453e-08, 1, -8.39415222e-08, 0.0930150598, -8.18099295e-08, -0.995664716) }, { name = "②冰霜深蹲10000", cf = CFrame.new(-2720.05127, 3.31417942, -591.259155, -1, 0, 0, 0, 1, 0, 0, 0, -1) },
        { name = "①跑步机2000", cf = CFrame.new(-3005.37866, 14.3221855, -464.697876, -0.015773816, -1.38508964e-08, 0.999875605, -5.13225586e-08, 1, 1.30429667e-08, -0.999875605, -5.11104332e-08, -0.015773816) }, { name = "②跑步机3000", cf = CFrame.new(-2953.44556, 29.2772789, -583.006287, -0.0362823829, -9.97339598e-08, 0.999341607, -1.85937332e-09, 1, 9.97321621e-08, -0.999341607, 1.76037129e-09, -0.0362823829) }
    } },
    Myth = { Name = "神话", Data = {
        { name = "①练习凳15000", cf = CFrame.new(2369.70044, 39.2158623, 1243.02173, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
        { name = "①抛掷10000", cf = CFrame.new(2486.01733, 3.67689276, 1237.89331, 0.883595645, -2.06135038e-08, -0.468250751, -3.3286871e-09, 1, -5.03036404e-08, 0.468250751, 4.60067362e-08, 0.883595645) }, { name = "②抛掷18000", cf = CFrame.new(2577.24048, 3.31417942, 1223.67383, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "③抛掷25000", cf = CFrame.new(2667.74072, 3.31417966, 1203.33374, -1, 0, 0, 0, 1, 0, 0, 0, -1) },
        { name = "①引体4000", cf = CFrame.new(2260.698, 3.31417942, 843.888916, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "②引体4000", cf = CFrame.new(2315.82104, 5.81071281, 847.153076, 0.993555248, 6.99809632e-08, 0.113349125, -7.05298859e-08, 1, 8.32554692e-10, -0.113349125, -8.82168916e-09, 0.993555248) }, { name = "①引体8000", cf = CFrame.new(2395.27368, 3.31417918, 848.289124, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "②引体8000", cf = CFrame.new(2487.12085, 3.3141799, 848.289124, -1, 0, 0, 0, 1, 0, 0, 0, -1) },
        { name = "①跑步机2000", cf = CFrame.new(2571.23706, 15.6896839, 898.650391, 0.999968231, 2.23868635e-09, -0.00797206629, -1.73198844e-09, 1, 6.35660768e-08, 0.00797206629, -6.3550246e-08, 0.999968231) }, { name = "②跑步机3000", cf = CFrame.new(2661.05908, 21.2468414, 919.779785, 0.984700143, -4.61772558e-08, 0.174257502, 4.95759522e-08, 1, -1.51510751e-08, -0.174257502, 2.35582451e-08, 0.984700143) }
    } },
    Eternal = { Name = "永恒", Data = { { name = "练习凳15000", cf = CFrame.new(-7173.3418, 45.3941154, -1105.02759, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "跑步机3500", cf = CFrame.new(-7077.79102, 29.6702118, -1457.59961, -0.0322036594, -3.31122768e-10, 0.99948132, -6.44344267e-09, 1, 1.23684493e-10, -0.99948132, -6.43611742e-09, -0.0322036594) } } },
    Legend = { Name = "传奇", Data = {
        { name = "传奇推举", cf = CFrame.new(4532.21777, 987.495056, -4002.71216, 0.642774045, 0, -0.766055822, 0, 1, 0, 0.766055822, 0, 0.642774045) }, { name = "投掷石", cf = CFrame.new(4189.96143, 987.829773, -3903.0166, 0.422592968, 0, 0.906319559, 0, 1, 0, -0.906319559, 0, 0.422592968) }, { name = "深蹲架", cf = CFrame.new(4443.04443, 987.521484, -4061.12988, 0.83309716, 3.33018835e-09, 0.553126693, -2.87759438e-09, 1, -1.68654424e-09, -0.553126693, -1.86619012e-10, 0.83309716) }, { name = "①引体向上", cf = CFrame.new(4510.20752, 987.463623, -3636.71753, -0.766061425, 0, -0.64276737, 0, 1, 0, 0.64276737, 0, -0.766061425) }, { name = "②引体向上", cf = CFrame.new(4304.02393, 987.486267, -4122.27734, -0.984812498, 0, -0.173621133, 0, 1, 0, 0.173621133, 0, -0.984812498) }, { name = "跑步机3000", cf = CFrame.new(4370.82812, 999.358704, -3621.42773, -0.960604727, -8.41949266e-09, -0.27791819, -6.12478646e-09, 1, -9.12496567e-09, 0.27791819, -7.06329528e-09, -0.960604727) }
    } },
    King = { Name = "肌肉之王", Data = {
        { name = "力量之王举重", cf = CFrame.new(-8772.9707, 13.1642103, -5663.5625, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "力量之王长凳", cf = CFrame.new(-8590.23535, 46.0167389, -6044.59521, -0.642763495, 0, 0.766064644, 0, 1, 0, -0.766064644, 0, -0.642763495) }, { name = "力量之王投掷石", cf = CFrame.new(-8935.4384765625, 13.855730056762695, -5693.66748046875) }, { name = "力量之王深蹲架", cf = CFrame.new(-8757.37012, 13.2186356, -6051.24365, -0.902269304, 1.63610299e-08, -0.431172907, 1.71076486e-08, 1, 2.14606288e-09, 0.431172907, -5.44002754e-09, -0.902269304) }
    } },
    Jungle = { Name = "丛林", Data = {
        { name = "①长凳25000", cf = CFrame.new(-8629.88184, 35.6957436, 1897.96667, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "②长凳50000", cf = CFrame.new(-8429.88184, 45.659626, 1902.96667, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "③长凳100000", cf = CFrame.new(-8176.72168, 59.6090698, 1918.18982, -0.999944925, 1.00847783e-08, -0.0104927532, 9.91424365e-09, 1, 1.63046394e-08, 0.0104927532, 1.61997136e-08, -0.999944925) }, { name = "投掷石", cf = CFrame.new(-8620.99, 89.81, 2673.54, -0.902269304, 1.63610299e-08, -0.431172907, 1.71076486e-08, 1, 2.14606288e-09, 0.431172907, -5.44002754e-09, -0.902269304) }, { name = "丛林蹲50000", cf = CFrame.new(-8582.27734, 2.74318409, 2888.69653, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "跑步机20000", cf = CFrame.new(-8138.67919921875, 28.270538330078125, 2833.511474609375, -0.960604727, -8.41949266e-09, -0.27791819, -6.12478646e-09, 1, -9.12496567e-09, 0.27791819, -7.06329528e-09, -0.960604727) }
    } },
    Industrial = { Name = "工业", Data = {
        { name = "工业酒吧升降机", cf = CFrame.new(-5492.70508, 60.4064407, 4643.64209, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "①长椅62.5千", cf = CFrame.new(-5469.71973, 93.3590622, 4452.34717, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "②长椅125千", cf = CFrame.new(-5269.71973, 103.322983, 4457.34717, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "③长椅250千", cf = CFrame.new(-5014.71973, 117.272316, 4467.34717, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "工业巨石187.5千", cf = CFrame.new(-5456.42969, 60.4064407, 5231.53516, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "①深蹲125千", cf = CFrame.new(-5422.11523, 60.4064407, 5443.07715, 1, 0, 0, 0, 1, 0, 0, 0, 1) }, { name = "②深蹲312.5千", cf = CFrame.new(-5217.11523, 60.4064407, 5418.07715, -1, 0, 0, 0, 1, 0, 0, 0, -1) }, { name = "跑步机50千", cf = CFrame.new(-4972.01416, 81.2528229, 5408.52197, -0.999095559, 2.14437339e-08, -0.0425219648, 2.28628174e-08, 1, -3.28866783e-08, 0.0425219648, -3.38291031e-08, -0.999095559) }
    } },
    Zero = { Name = "Zero Degrees", Data = {
        { name = "Zero Bar Lift 1", cf = CFrame.new(-5374.86719, 46.8623886, 10321.7617, -9.46027002e-13, 4.17792769e-08, 1, -1.47090055e-12, 1, -4.17792769e-08, -1, -1.47090066e-12, -9.46027002e-13) }, { name = "①Bench 3", cf = CFrame.new(-5355.4917, 79.8146439, 10132.5752, 0.125147, 2.36685e-08, -0.992138207, -5.17586969e-08, 1, 1.73272792e-08, 0.992138207, 4.91833241e-08, 0.125147) }, { name = "②Bench 2", cf = CFrame.new(-5156.27051, 89.7790527, 10136.9902, 0.189251676, -6.90230948e-08, -0.981928587, -2.74308505e-08, 1, -7.55802674e-08, 0.981928587, 4.1238831e-08, 0.189251676) }, { name = "③Bench 1", cf = CFrame.new(-4901.84521, 103.727707, 10146.2598, -0.624886155, -8.30325817e-08, -0.780715883, -1.88251814e-08, 1, -9.12867151e-08, 0.780715883, -4.23466844e-08, -0.624886155) }, { name = "①Squat 1", cf = CFrame.new(-5304.27734, 46.8623886, 11121.1963, 1, -2.82783486e-09, 4.41309478e-09, 2.82783463e-09, 1, 6.50564402e-09, -4.41309478e-09, -6.50564402e-09, 1) }, { name = "②Squat 2", cf = CFrame.new(-5099.27734, 46.8623886, 11096.1963, 1, -7.22851201e-09, 1.86739202e-09, 7.22851201e-09, 1, -5.82249271e-09, -1.86739202e-09, 5.82249271e-09, 1) }, { name = "Boulder 1", cf = CFrame.new(-5338.5918, 46.8623886, 10909.6543, -0.208028123, 0, 0.97812283, 0, 1, 0, -0.97812283, 0, -0.208028123) }, { name = "Treadmill", cf = CFrame.new(-4856.16455, 71.6982422, 11097.5498, -0.99957341, -1.27177096e-08, -0.029207157, -1.31515803e-08, 1, 1.46628665e-08, 0.029207157, 1.50407313e-08, -0.99957341) }
    } },
    Alien = { Name = "Alien Gym", Data = {
        { name = "①Bar Lift 1", cf = CFrame.new(-2216.64966, 52.8168793, -11220.4893, 0, 1.08151323e-34, 1, 1.05647555e-36, 1, -1.08151323e-34, -1, 1.05647555e-36, -0) }, { name = "②Bar Lift 2", cf = CFrame.new(-2154.71094, 52.8190193, -11332.9111, 0.819254875, -1.80857954e-12, 0.573429585, 5.89915486e-13, 1, 2.31116168e-12, -0.573429585, -1.55515542e-12, 0.819254875) }, { name = "①Bench 1", cf = CFrame.new(-2216.94458, 84.1581802, -10754.709, 0.92403996, 7.25476923e-08, -0.382295877, -8.12139191e-08, 1, -6.53215571e-09, 0.382295877, 3.70837192e-08, 0.92403996) }, { name = "②Bench 2", cf = CFrame.new(-2167.18823, 84.1529388, -10644.1904, 0.895121992, -5.35230393e-09, -0.445821285, -3.76645826e-09, 1, -1.95678052e-08, 0.445821285, 1.919474e-08, 0.895121992) }, { name = "③Bench 3", cf = CFrame.new(-2046.31384, 84.1483078, -10616.2412, 0.48175174, -6.34214956e-08, -0.876307726, 9.53984127e-08, 1, -1.99280912e-08, 0.876307726, -7.3997974e-08, 0.48175174) }, { name = "①Squat 1", cf = CFrame.new(-1603.33679, 52.8019028, -11326.9961, -0.998595417, 0, -0.0529830977, 0, 1, 0, 0.0529830977, 0, -0.998595417) }, { name = "②Squat 2", cf = CFrame.new(-1511.64111, 52.7975121, -11282.3213, -0.68245542, -8.24743935e-08, 0.730927229, -8.24999944e-08, 1, 3.58063339e-08, -0.730927229, -3.58652628e-08, -0.68245542) }, { name = "③Squat 3", cf = CFrame.new(-1490.97559, 52.7935524, -11188.7051, 0.374024808, 1.48040264e-08, 0.927418709, 1.48072532e-08, 1, -2.19343281e-08, -0.927418709, 2.19365059e-08, 0.374024808) }, { name = "Boulder", cf = CFrame.new(-2061.31763, 52.8154984, -11314.2607, 0.86607182, 0, -0.499919623, 0, 1, 0, 0.499919623, 0, 0.86607182) }, { name = "①Treadmill 1", cf = CFrame.new(-1601.46338, 64.8113708, -10615.1094, -0.988528371, 9.56467261e-09, -0.151035443, 1.19025749e-08, 1, -1.45751242e-08, 0.151035443, -1.62056342e-08, -0.988528371) }, { name = "②Treadmill 2", cf = CFrame.new(-1504.79492, 64.8083801, -10650.293, -0.846906245, 9.68903446e-09, -0.531742275, 1.30727233e-08, 1, -2.59963584e-09, 0.531742275, -9.15296727e-09, -0.846906245) }, { name = "③Treadmill 3", cf = CFrame.new(-1459.31921, 64.8118591, -10757.8213, -0.0198461544, 2.89750474e-10, -0.999803066, 6.76230405e-10, 1, 2.7638436e-10, 0.999803066, -6.70612066e-10, -0.0198461544) }
    } }
}
for _, gym in pairs(gyms) do
    local t = Window:Tab({ Title = gym.Name })
    for _, item in ipairs(gym.Data) do
        if string.find(item.name, "跑步机") then createTreadmillToggle(t, item.name, item.cf) else createMachineToggle(t, item.name, item.cf, "Machine") end
    end
end

local TabKill = Window:Tab({ Title = "击杀" })
local autokill = false
TabKill:Button({ Title = "自动击杀全部", Callback = function()
    autokill = not autokill
    if autokill then task.spawn(function()
        while autokill do
            for _, plr in ipairs(Players:GetPlayers()) do
                if not autokill then break end
                if plr ~= LP then
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        LP.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,2.5)
                        RunService.Heartbeat:Wait()
                        local lh = LP.Character:FindFirstChild("LeftHand")
                        if lh and plr.Character:FindFirstChild("Head") then firetouchinterest(plr.Character.Head, lh, 0) firetouchinterest(plr.Character.Head, lh, 1) end
                        if LP:FindFirstChild("muscleEvent") then LP.muscleEvent:FireServer("punch", "leftHand") LP.muscleEvent:FireServer("punch", "rightHand") end
                        task.wait(0.05)
                    end
                end
            end
            task.wait(0.05)
        end
    end) end
end })

local TabRock = Window:Tab({ Title = "石头" })
local rocks = {
    { title = "拳击岩石", dur = 10, tp = Vector3.new(-153, 7, 437), get = function() for _, c in pairs(workspace.machinesFolder:GetChildren()) do local r = c:FindFirstChild("Rock") if r and r:FindFirstChild("rockGui") and r.rockGui:FindFirstChild("rockName") and r.rockGui.rockName.Text == "Punching Rock" then return r end end end },
    { title = "大号岩石", dur = 100, tp = Vector3.new(165, 7, -168), get = function() for _, c in pairs(workspace.machinesFolder:GetChildren()) do local r = c:FindFirstChild("Rock") if r and r:FindFirstChild("rockGui") and r.rockGui:FindFirstChild("rockName") and r.rockGui.rockName.Text == "Large Rock" then return r end end end }
}
for _, r in ipairs(rocks) do
    TabRock:Toggle({ Title = "自动打 " .. r.title, Default = false, Callback = function(s)
        if s then task.spawn(function() while s do pcall(function()
            local c = LP.Character if c and c:FindFirstChild("HumanoidRootPart") then
                local rockPart = r.get()
                if rockPart then
                    c.HumanoidRootPart.CFrame = CFrame.new(r.tp, Vector3.new(rockPart.Position.X, r.tp.Y, rockPart.Position.Z))
                    c.HumanoidRootPart.Anchored = true
                    local p = LP.Backpack:FindFirstChild("Punch") if p then p.Parent = c local at = p:FindFirstChild("attackTime") if at then at.Value = 0 end end
                    if LP:FindFirstChild("muscleEvent") then LP.muscleEvent:FireServer("punch", "rightHand") LP.muscleEvent:FireServer("punch", "leftHand") end
                    local p2 = c:FindFirstChild("Punch") if p2 then p2:Activate() end
                    c.HumanoidRootPart.Anchored = false
                end
            end
        end) task.wait() end end) end
    end })
end

local TabBoss = Window:Tab({ Title = "头目专属" })
TabBoss:Toggle({ Title = "自动击杀Boss", Default = false, Callback = function(state)
    if state then task.spawn(function() while state do pcall(function()
        local c = LP.Character local root = c and c:FindFirstChild("HumanoidRootPart")
        if root then
            local arena = workspace:FindFirstChild("Events") and workspace.Events:FindFirstChild("BossArena")
            local bRoot = nil
            if arena then for _, slot in ipairs(arena:GetChildren()) do local b = slot:FindFirstChild("Boss") if b then bRoot = b:FindFirstChild("HumanoidRootPart") or b.PrimaryPart break end end end
            if bRoot then
                c.Humanoid.AutoRotate = false
                root.CFrame = CFrame.new(bRoot.Position + Vector3.new(0, bRoot.Size.Y/2 + 2, 0))
                local p = c:FindFirstChild("Punch") or LP.Backpack:FindFirstChild("Punch") if p then c.Humanoid:EquipTool(p) p:Activate() end
                if LP:FindFirstChild("muscleEvent") then LP.muscleEvent:FireServer("punch", "leftHand") LP.muscleEvent:FireServer("punch", "rightHand") end
            else c.Humanoid.AutoRotate = true end
        end
    end) task.wait(0.05) end end) end
end })

local TabPet = Window:Tab({ Title = "宠物管家" })
TabPet:Toggle({ Title = "自动抽水晶", Default = false, Callback = function(s)
    if s then task.spawn(function() while s do pcall(function()
        ReplicatedStorage.rEvents.openCrystalRemote:InvokeServer("openCrystal", "Zero Degrees Crystal")
    end) task.wait(0.3) end end) end
end })
TabPet:Toggle({ Title = "自动进化", Default = false, Callback = function(s)
    if s then task.spawn(function() while s do pcall(function()
        ReplicatedStorage.rEvents.petEvolveEvent:FireServer("evolvePet", "Mighty Monster")
    end) task.wait(0.5) end end) end
end })

local TabBeautify = Window:Tab({ Title = "美化" })
local function ensurePetsFolder()
    local pf = LP:FindFirstChild("petsFolder")
    if not pf then pf = Instance.new("Folder") pf.Name = "petsFolder" pf.Parent = LP end
    local u = pf:FindFirstChild("Unique")
    if not u then u = Instance.new("Folder") u.Name = "Unique" u.Parent = pf end
    return u
end
local function AddFakePet(petName, displayName, assetId, str, agi, dur, dmg)
    local unique = ensurePetsFolder()
    local p = Instance.new("StringValue") p.Name = petName p.Value = "rbxassetid://" .. assetId p.Parent = unique
    local perks = Instance.new("Folder") perks.Name = "perksFolder" perks.Parent = p
    Instance.new("IntValue", perks).Name = "strength"; perks.strength.Value = str
    Instance.new("IntValue", perks).Name = "agility"; perks.agility.Value = agi
    Instance.new("IntValue", perks).Name = "durability"; perks.durability.Value = dur
    if dmg > 0 then Instance.new("IntValue", perks).Name = "damage"; perks.damage.Value = dmg end
    Instance.new("StringValue", p).Name = "chosenName"; p.chosenName.Value = displayName
    Instance.new("BoolValue", p).Name = "evolved"; p.evolved.Value = true
end
TabBeautify:Button({ Title = "一键获得所有神宠", Callback = function()
    AddFakePet("Mighty Monster", "强大的怪物", "17601660151", 2250, 1000, 5000, 0)
    AddFakePet("Swift Samurai", "快速武士", "17601657920", 1750, 2500, 3250, 0)
    AddFakePet("Tribal Overlord", "部落霸主", "17601550091", 3750, 0, 2500, 50000)
    AddFakePet("Wild Wizard", "狂野巫师", "17601661532", 0, 750, 4000, 75000)
end })
TabBeautify:Button({ Title = "解锁全部通行证", Callback = function()
    for _, v in ipairs(ReplicatedStorage:WaitForChild("gamepassIds"):GetChildren()) do v.Parent = LP.ownedGamepasses end
end })
local TabTP = Window:Tab({ Title = "传送点" })
local tps = {
    {"大厅", CFrame.new(2.93, 88.93, 243.94)}, {"小岛", CFrame.new(-38.86, 7.53, 1894.03)},
    {"冰霜", CFrame.new(-2623.02, 7.38, -409.07)}, {"神话", CFrame.new(2250.77, 7.38, 1073.22)},
    {"永恒", CFrame.new(-6758.96, 7.38, -1284.91)}, {"传奇", CFrame.new(4603.28, 991.53, -3897.86)},
    {"肌肉之王", CFrame.new(-8749.94, 124.45, -5861.06)}, {"丛林", CFrame.new(-8685.62, 6.81, 2392.32)},
    {"工业", CFrame.new(-5563.23, 60.40, 4942.44)}, {"Zero", CFrame.new(-5400, 46.86, 10622)},
    {"Alien", CFrame.new(-1838.57, 58.71, -10412.09)}, {"转盘岛", CFrame.new(1952.09, 1.86, 6180.28)},
    {"熔岩争斗", CFrame.new(4472.61, 119.96, -8849.90)}, {"沙漠争斗", CFrame.new(987.70, 17.23, -7440.26)},
    {"海滩争斗", CFrame.new(-1863.18, 17.23, -6292.78)}
}
for _, p in ipairs(tps) do
    TabTP:Button({ Title = p[1], Callback = function()
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = p[2] end
    end })
end

local TabAuto = Window:Tab({ Title = "全自动福利" })
TabAuto:Toggle({ Title = "自动参加争斗", Default = false, Callback = function(s)
    if s then task.spawn(function() while s do pcall(function()
        local mr = ReplicatedStorage:WaitForChild("rEvents"):FindFirstChild("machineInteractRemote")
        if mr then mr:InvokeServer("leaveMachine") end
        task.wait(0.1)
        local be = ReplicatedStorage:WaitForChild("rEvents"):FindFirstChild("brawlEvent")
        if be then be:FireServer("joinBrawl") end
    end) task.wait(2) end end) end
end })
TabAuto:Toggle({ Title = "自动转盘抽奖", Default = false, Callback = function(s)
    if s then task.spawn(function() while s do pcall(function()
        local Event = ReplicatedStorage:WaitForChild("rEvents").openFortuneWheelRemote
        Event:InvokeServer("openFortuneWheel", ReplicatedStorage:WaitForChild("shared"):WaitForChild("catalogs"):WaitForChild("fortuneWheelChances"):WaitForChild("Fortune Wheel"))
    end) task.wait(1) end end) end
end })
TabAuto:Toggle({ Title = "自动收集宝箱", Default = false, Callback = function(s)
    if s then task.spawn(function()
        local chests = {
            CFrame.new(-2574.75, 7.25, -556.98), CFrame.new(-138.38, 7.25, -268.45),
            CFrame.new(2214.43, 7.25, 914.58), CFrame.new(-6722.25, 7.25, -1455.96),
            CFrame.new(4660.31, 1000.97, -3699.38), CFrame.new(-7909.55, 6.73, 2968.34),
            CFrame.new(-4747.19, 57.89, 5552.28), CFrame.new(-4605.11, 46.86, 11169.49)
        }
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, cf in ipairs(chests) do
                if not s then break end
                root.CFrame = cf task.wait(0.2) root.CFrame = root.CFrame * CFrame.new(0, 0, -2) task.wait(3.2)
            end
            ReplicatedStorage.rEvents.groupRemote:InvokeServer("groupRewards")
        end
    end) end
end })
TabAuto:Toggle({ Title = "自动吃所有食物", Default = false, Callback = function(s)
    if s then task.spawn(function() while s do pcall(function()
        local c = LP.Character if not c then return end
        local bp = LP:FindFirstChild("Backpack")
        local foods = {["Protein Bar"]="proteinBar", ["Energy Bar"]="energyBar", ["ULTRA Shake"]="ultraShake", ["Protein Shake"]="proteinShake"}
        if bp then for _, t in ipairs(bp:GetChildren()) do
            if foods[t.Name] then c.Humanoid:EquipTool(t) task.wait(0.05)
                for _=1,10 do LP.muscleEvent:FireServer(foods[t.Name], t) end
            end
        end end
    end) task.wait(0.1) end end) end
end })
TabAuto:Toggle({ Title = "自动领在线奖励", Default = false, Callback = function(s)
    if s then task.spawn(function() while s do pcall(function()
        local r = ReplicatedStorage.rEvents:FindFirstChild("freeGiftClaimRemote")
        if r then for i=1,8 do r:InvokeServer("claimGift", i) task.wait(0.1) end end
    end) task.wait(0.8) end end) end
end })
TabAuto:Button({ Title = "一键兑换24个兑换码", Callback = function()
    local codes = {"mightygems2500","ultimate250","spacegems50","megalift50","speedy50","epicreward500","MillionWarriors","frostgems10","Musclestorm50","Skyagility50","galaxycrystal50","supermuscle100","superpunch100","launch250","junglegym500","epicmusle20","musclestorm50","ASCENSION","STRONGBLOXIAN","HALLOWEENPART2","BLOODMOON","FROSTBITE","ZERODEGREES","ALIENINVASION"}
    task.spawn(function()
        local r = ReplicatedStorage.rEvents:FindFirstChild("codeRemote")
        if r then for _, c in ipairs(codes) do pcall(function() r:InvokeServer(c) end) task.wait(0.5) end end
    end)
end })