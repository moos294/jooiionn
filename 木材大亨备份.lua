local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/UI.lua"))()
local Window = UI.Window
local WindUI = UI.WindUI

for _, v in ipairs(UI.Gui.Panel:GetDescendants()) do
    if v:IsA("TextLabel") then
        if v.Text == "ORIGAMI" then v.Text = "封存力量 V1.5" end
        if v.Text == "BUILD TOOL" then v.Text = "Author: 封存" end
    end
end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local targetPlayer = ""
local loopTP = false

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
frame.Size = UDim2.new(0, 240, 0, 220)
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
title.Text = "📊 封存数据预估"
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
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = frame
    return l
end

local lblStr = createLabel(28, "当前力量: 0")
local lblReb = createLabel(48, "当前转生: 0")
local lblHrStr = createLabel(76, "1小时预估力量: 0", Color3.fromRGB(150, 255, 150))
local lblHrReb = createLabel(96, "1小时预估转生: 0", Color3.fromRGB(150, 255, 150))
local lblDayStr = createLabel(116, "24小时预估力量: 0", Color3.fromRGB(255, 200, 100))
local lblDayReb = createLabel(136, "24小时预估转生: 0", Color3.fromRGB(255, 200, 100))

local packBox = Instance.new("TextBox")
packBox.Size = UDim2.new(1, -20, 0, 28)
packBox.Position = UDim2.new(0, 10, 0, 165)
packBox.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
packBox.Text = "设置包数 (1包=2次重生)"
packBox.TextColor3 = Color3.fromRGB(200, 200, 200)
packBox.Font = Enum.Font.Gotham
packBox.TextSize = 11
packBox.Parent = frame
local c3 = Instance.new("UICorner", packBox)
c3.CornerRadius = UDim.new(0, 6)

local currentPacks = 0
packBox.FocusLost:Connect(function()
    local num = tonumber(packBox.Text:match("%d+"))
    if num then
        currentPacks = num
        packBox.Text = "包数: " .. num .. " (额外+" .. (num * 2) .. "重生/时)"
    else
        currentPacks = 0
        packBox.Text = "设置包数 (1包=2次重生)"
    end
end)

openBtn.MouseButton1Click:Connect(function()
    openBtn.Visible = false
    frame.Visible = true
end)
closeBtn.MouseButton1Click:Connect(function()
    openBtn.Visible = true
    frame.Visible = false
end)

local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local lastStr = getStat("Strength", "Power")
local lastReb = getStat("Rebirths", "Rebirth")
local strRate = 0
local rebRate = 0
local lastUpdate = tick()

task.spawn(function()
    while hud.Parent do
        task.wait(2)
        local curStr = getStat("Strength", "Power")
        local curReb = getStat("Rebirths", "Rebirth")
        local now = tick()
        local dt = now - lastUpdate
        
        if curStr >= lastStr then
            local diff = (curStr - lastStr) / dt
            strRate = strRate * 0.7 + diff * 0.3
        else
            strRate = curStr / dt 
        end
        
        if curReb >= lastReb then
            local diff = (curReb - lastReb) / dt
            rebRate = rebRate * 0.7 + diff * 0.3
        else
            rebRate = 0
        end

        lastStr = curStr
        lastReb = curReb
        lastUpdate = now

        local baseHrRebGain = rebRate * 3600
        local packHrRebGain = currentPacks * 2 
        local hrStrGain = strRate * 3600
        local hrRebGain = baseHrRebGain + packHrRebGain
        
        local dayStrGain = hrStrGain * 24
        local dayRebGain = hrRebGain * 24

        lblStr.Text = "当前力量: " .. fmt(curStr)
        lblReb.Text = "当前转生: " .. fmt(curReb)
        lblHrStr.Text = "1小时预估力量: +" .. fmt(hrStrGain)
        lblHrReb.Text = "1小时预估转生: +" .. fmt(hrRebGain)
        lblDayStr.Text = "24小时预估力量: +" .. fmt(dayStrGain)
        lblDayReb.Text = "24小时预估转生: +" .. fmt(dayRebGain)
    end
end)

LP.Idled:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
end)

local TabMain = Window:Tab({ Title = "主要功能" })
local TabTP = Window:Tab({ Title = "传送地点" })
local TabPlayer = Window:Tab({ Title = "玩家追踪" })
local TabOther = Window:Tab({ Title = "其他设置" })

TabMain:Toggle({
    Title = "自动锻炼",
    Value = false,
    Callback = function(s)
        if s then
            task.spawn(function()
                while s do
                    local me = LP:FindFirstChild("muscleEvent")
                    if me then pcall(function() me:FireServer("rep") end) end
                    task.wait(0.1)
                end
            end)
        end
    end
})

TabMain:Toggle({
    Title = "快速锻炼",
    Value = false,
    Callback = function(s)
        if s then
            task.spawn(function()
                while s do
                    local me = LP:FindFirstChild("muscleEvent")
                    if me then pcall(function() for i = 1, 20 do me:FireServer("rep") end end) end
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
        if s then
            task.spawn(function()
                while s do
                    local me = LP:FindFirstChild("muscleEvent")
                    if me then pcall(function() for i = 1, 20 do me:FireServer("rep") end end) end
                    task.wait(0.1)
                end
            end)
        end
    end
})

local tps = {
    {"大厅", Vector3.new(-0.75, 90.61, 242.78)},
    {"小岛", Vector3.new(-32.14, 8.51, 1904.41)},
    {"冰霜健身房", Vector3.new(-2623.41, 6.99, -409.34)},
    {"神话健身房", Vector3.new(2250.39, 6.99, 1072.77)},
    {"boss战斗场", Vector3.new(-18.77, 47.41, -1232.43)}
}

for _, v in ipairs(tps) do
    TabTP:Button({
        Title = v[1],
        Callback = function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(v[2]) end
        end
    })
end

local function getPlr()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(list, p.Name) end
    end
    return list
end

local Dropdown = TabPlayer:Dropdown({
    Title = "选择玩家",
    Values = getPlr(),
    Value = "",
    Callback = function(v) targetPlayer = v end
})

TabPlayer:Button({
    Title = "刷新玩家列表",
    Callback = function()
        local plrs = getPlr()
        if Dropdown then
            if Dropdown.SetOptions then Dropdown:SetOptions(plrs)
            elseif Dropdown.Refresh then Dropdown:Refresh(plrs) end
        end
    end
})

TabPlayer:Button({
    Title = "传送到玩家身边",
    Callback = function()
        local t = Players:FindFirstChild(targetPlayer)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LP.Character then
            LP.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

TabPlayer:Toggle({
    Title = "循环锁定传送",
    Value = false,
    Callback = function(s)
        loopTP = s
        if s then
            task.spawn(function()
                while loopTP do
                    pcall(function()
                        local t = Players:FindFirstChild(targetPlayer)
                        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LP.Character then
                            LP.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end
})

TabOther:Button({
    Title = "防挂机踢出",
    Callback = function()
        pcall(function()
            for _, conn in pairs(getconnections(LP.Idled)) do
                conn:Disable()
                conn:Disconnect()
            end
        end)
        WindUI:Notify({ Title = "成功", Content = "已开启防挂机", Duration = 3 })
    end
})

TabOther:Button({
    Title = "防卡顿清理",
    Callback = function()
        Lighting.Brightness = 0
        Lighting.GlobalShadows = false
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function() v:Destroy() end)
        end
        WindUI:Notify({ Title = "成功", Content = "已清理垃圾模型", Duration = 3 })
    end
})