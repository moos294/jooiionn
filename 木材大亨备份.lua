local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/UI.lua"))()
local Window = UI.Window
local WindUI = UI.WindUI

for _, v in ipairs(UI.Gui.Panel:GetDescendants()) do
    if v:IsA("TextLabel") then
        if v.Text == "ORIGAMI" then v.Text = "封存力量 V0.1" end
        if v.Text == "BUILD TOOL" then v.Text = "Author: 封存" end
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local targetPlayer = ""
local loopTP = false

local muscleEvent = LP:WaitForChild("muscleEvent", 10)

-- 全局状态表
local state = {
    FastTrain = false,
    AutoRebirth = false,
    AutoTPMuscle = false,
    Rock1 = false,
    Rock2 = false,
    Rock3 = false,
    AutoCrystal = false,
    AutoBuyPet = false,
    AutoEvolve = false,
    AutoWheel = false
}

-- 悬浮窗代码
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
local c1 = Instance.new("UICorner", openBtn)
c1.CornerRadius = UDim.new(0, 6)

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 180)
frame.Position = UDim2.new(0, 20, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = hud
local c2 = Instance.new("UICorner", frame)
c2.CornerRadius = UDim.new(0, 8)

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
local lblBossStatus = createLabel(84, "Boss状态: 等待中", Color3.fromRGB(255, 150, 150))
local lblBossTimer = createLabel(110, "Boss倒计时: 0s", Color3.fromRGB(255, 200, 100))

local packBox = Instance.new("TextBox")
packBox.Size = UDim2.new(1, -20, 0, 28)
packBox.Position = UDim2.new(0, 10, 0, 140)
packBox.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
packBox.Text = "设置包数 (1包=2次重生)"
packBox.TextColor3 = Color3.fromRGB(200, 200, 200)
packBox.Font = Enum.Font.Gotham
packBox.TextSize = 11
packBox.Parent = frame
local c3 = Instance.new("UICorner", packBox)
c3.CornerRadius = UDim.new(0, 6)

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
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
end)

-- 标签页
local TabMain = Window:Tab({ Title = "主要功能" })
local TabBoss = Window:Tab({ Title = "bái自动boss" })
local TabTeleport = Window:Tab({ Title = "传送与石头" })
local TabPets = Window:Tab({ Title = "宠物与抽奖" })

-- 主要功能
TabMain:Toggle({
    Title = "快速锻炼",
    Value = false,
    Callback = function(s)
        state.FastTrain = s
        if s then
            task.spawn(function()
                while state.FastTrain do
                    pcall(function() for i = 1, 20 do muscleEvent:FireServer("rep") end end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

TabMain:Toggle({
    Title = "自动重生",
    Value = false,
    Callback = function(s)
        state.AutoRebirth = s
        if s then
            task.spawn(function()
                while state.AutoRebirth do
                    pcall(function()
                        for i = 1, 12 do muscleEvent:FireServer("rep") end
                        task.wait(0.02)
                        for i = 1, 12 do muscleEvent:FireServer("rep") end
                    end)
                    task.wait(0.02)
                end
            end)
        end
    end
})

-- 传送与石头
local MUSCLE_KING_POS = Vector3.new(-8625.4, 16.99, -5730.41)

TabTeleport:Button({
    Title = "传送至肌肉王",
    Callback = function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(MUSCLE_KING_POS) end
    end
})

TabTeleport:Toggle({
    Title = "自动传送肌肉王 (锁定)",
    Value = false,
    Callback = function(s)
        state.AutoTPMuscle = s
        if s then
            task.spawn(function()
                while state.AutoTPMuscle do
                    pcall(function()
                        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.CFrame = CFrame.new(MUSCLE_KING_POS) end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

TabTeleport:Toggle({
    Title = "举石头 1 (Rock_1)",
    Value = false,
    Callback = function(s)
        state.Rock1 = s
        if s then
            task.spawn(function()
                while state.Rock1 do
                    pcall(function()
                        local mf = workspace:FindFirstChild("machinesFolder")
                        local seat = mf and mf:FindFirstChild("Rock_1") and mf.Rock_1:FindFirstChild("interactSeat")
                        if seat then muscleEvent:FireServer("rep", seat) end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

TabTeleport:Toggle({
    Title = "举石头 2 (Rock_2)",
    Value = false,
    Callback = function(s)
        state.Rock2 = s
        if s then
            task.spawn(function()
                while state.Rock2 do
                    pcall(function()
                        local mf = workspace:FindFirstChild("machinesFolder")
                        local seat = mf and mf:FindFirstChild("Rock_2") and mf.Rock_2:FindFirstChild("interactSeat")
                        if seat then muscleEvent:FireServer("rep", seat) end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

TabTeleport:Toggle({
    Title = "举石头 3 (Rock_3)",
    Value = false,
    Callback = function(s)
        state.Rock3 = s
        if s then
            task.spawn(function()
                while state.Rock3 do
                    pcall(function()
                        local mf = workspace:FindFirstChild("machinesFolder")
                        local seat = mf and mf:FindFirstChild("Rock_3") and mf.Rock_3:FindFirstChild("interactSeat")
                        if seat then muscleEvent:FireServer("rep", seat) end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- 宠物与抽奖
TabPets:Paragraph({ Title = "自动宠物与商店", Desc = "原版 29 源码提取" })

TabPets:Toggle({
    Title = "自动抽水晶",
    Value = false,
    Callback = function(s)
        state.AutoCrystal = s
        if s then
            task.spawn(function()
                while state.AutoCrystal do
                    pcall(function()
                        ReplicatedStorage.rEvents.openCrystalRemote:InvokeServer("openCrystal", nil)
                    end)
                    task.wait(0.3)
                end
            end)
        end
    end
})

TabPets:Toggle({
    Title = "自动购买宠物",
    Value = false,
    Callback = function(s)
        state.AutoBuyPet = s
        if s then
            task.spawn(function()
                while state.AutoBuyPet do
                    pcall(function()
                        local cPetShopRemote = ReplicatedStorage.rEvents:FindFirstChild("cPetShopRemote", 3)
                        local cPetShopFolder = ReplicatedStorage.shared.runtime:FindFirstChild("cPetShopFolder", 3)
                        local child = cPetShopFolder:FindFirstChild(nil)
                        cPetShopRemote:InvokeServer(child)
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

TabPets:Toggle({
    Title = "自动进化",
    Value = false,
    Callback = function(s)
        state.AutoEvolve = s
        if s then
            task.spawn(function()
                while state.AutoEvolve do
                    pcall(function()
                        ReplicatedStorage.rEvents.petEvolveEvent:FireServer("evolvePet", false)
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

TabPets:Toggle({
    Title = "自动转盘",
    Value = false,
    Callback = function(s)
        state.AutoWheel = s
        if s then
            task.spawn(function()
                while state.AutoWheel do
                    pcall(function()
                        ReplicatedStorage.rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", ReplicatedStorage.shared.catalogs.fortuneWheelChances["Fortune Wheel"])
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

-- BOSS 功能
local BOSS_HEIGHT = 66
local HOME_POS = Vector3.new(1,44,-1251)
local BACKUP_CHEST_CF = CFrame.new(Vector3.new(-2.2187373638153076, 52.295745849609375, -1272.9957275390625))
local bState = { running=false, fighting=false, bossActive=false, bossIndex=1, conn=nil, thread=nil, lastKillTime=0, cooldown=60 }

local function pressKey(key, delay)
    delay = delay or 0.05
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(delay)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function getBossHealth(name)
    local ev = workspace:FindFirstChild("Events")
    local arena = ev and ev:FindFirstChild("BossArena")
    local folder = arena and arena:FindFirstChild(name)
    if folder then
        local stats = folder:FindFirstChild("stats")
        local hp = stats and stats:FindFirstChild("Health")
        if hp then return hp.Value end
    end
    return 0
end

local function getBossPos()
    local ev = workspace:FindFirstChild("Events")
    local arena = ev and ev:FindFirstChild("BossArena")
    local folder = arena and arena:FindFirstChild("Boss"..(bState.bossIndex or 1))
    local boss = folder and folder:FindFirstChild("Boss")
    if not boss then return nil end
    return boss:IsA("Model") and boss:GetPivot().Position or boss.Position
end

local function setFighting(on)
    if bState.fighting==on then return end
    bState.fighting = on
    if bState.conn then bState.conn:Disconnect() bState.conn=nil end
    if bState.thread then pcall(task.cancel,bState.thread) bState.thread=nil end
    if not on then return end

    bState.conn = RunService.RenderStepped:Connect(function()
        if not bState.running or not bState.fighting then return end
        local bp = getBossPos()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp or not bp then return end
        local target = bp + Vector3.new(0,BOSS_HEIGHT,0)
        local flat = Vector3.new(bp.X-target.X, 0, bp.Z-target.Z)
        if flat.Magnitude<0.1 then flat = Vector3.new(0,0,-1) end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.lookAt(target, target+flat.Unit)*CFrame.Angles(math.rad(-90),0,0)
    end)

    bState.thread = task.spawn(function()
        local ids = {"3638729053","3638767427","507768375","522635514","522638767","182393478","129967390","129967478"}
        local isLeft, leftAnim, rightAnim, counter = true, nil, nil, 0
        while bState.running and bState.fighting do
            if not getBossPos() then task.wait(0.5) else
                counter = counter + 1
                if counter%4==0 then
                    local p = LP.Backpack:FindFirstChild("Punch")
                    local d = p and p:FindFirstChildOfClass("NumberValue")
                    if d then d.Value = 0.01 end
                end
                pcall(function()
                    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                    if not hum then return end
                    local p = LP.Backpack:FindFirstChild("Punch")
                    if p then hum:EquipTool(p) end
                    muscleEvent:FireServer("punch", isLeft and "leftHand" or "rightHand")
                    local anim = isLeft and leftAnim or rightAnim
                    if not anim then
                        local a = Instance.new("Animation")
                        a.AnimationId = "rbxassetid://"..(isLeft and ids[1] or ids[2])
                        anim = hum:FindFirstChildOfClass("Animator"):LoadAnimation(a)
                        if isLeft then leftAnim=anim else rightAnim=anim end
                    end
                    anim:Stop(0); anim:Play(0.1)
                    isLeft = not isLeft
                end)
            end
            task.wait(0.05)
        end
    end)
end

TabBoss:Paragraph({ Title = "自动打BOSS", Desc = "自动检测并挑战BOSS，打完自动开箱子" })
TabBoss:Toggle({
    Title = "开启 bái自动boss",
    Value = false,
    Callback = function(s)
        bState.running = s
        if not s then
            setFighting(false)
            bState.bossActive = false
        end
    end
})

task.spawn(function()
    while task.wait(0.1) do
        if not bState.running then
            bState.bossActive = false
            setFighting(false)
            continue
        end

        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.Y < -100 then
            hrp.CFrame = CFrame.new(HOME_POS)
            task.wait(1)
            continue
        end

        local active, idx = false, nil
        for i=1,5 do
            if getBossHealth("Boss"..i)>0 then active=true idx=i break end
        end
        if not active and getBossHealth("BossRainbow")>0 then active=true idx="Rainbow" end

        if active then
            if not bState.bossActive then
                bState.bossActive = true
                bState.bossIndex = idx
                pressKey(Enum.KeyCode.Space)
                task.wait(0.05)
                pressKey(Enum.KeyCode.Space)
                task.wait(5)
                setFighting(true)
            end
        else
            if bState.bossActive then
                bState.bossActive = false
                setFighting(false)
                bState.lastKillTime = tick()

                local hrp2 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp2 then
                    hrp2.AssemblyLinearVelocity = Vector3.zero
                    hrp2.AssemblyAngularVelocity = Vector3.zero
                    hrp2.CFrame = BACKUP_CHEST_CF
                end
                task.wait(2)
            else
                setFighting(false)
            end
        end
    end
end)