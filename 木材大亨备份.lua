local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/UI.lua"))()
local Window = UI.Window
local WindUI = UI.WindUI

for _, v in ipairs(UI.Gui.Panel:GetDescendants()) do
    if v:IsA("TextLabel") then
        if v.Text == "ORIGAMI" then v.Text = "封存力量 V1.3" end
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

local totalReps = 0
local startTime = tick()

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

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 110)
frame.Position = UDim2.new(0, 20, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = hud

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundTransparency = 1
title.Text = "📊 封存统计"
title.TextColor3 = Color3.fromRGB(60, 150, 230)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = frame

local lblStr = Instance.new("TextLabel")
lblStr.Size = UDim2.new(1, -10, 0, 18)
lblStr.Position = UDim2.new(0, 10, 0, 28)
lblStr.BackgroundTransparency = 1
lblStr.Text = "力量: 0"
lblStr.TextColor3 = Color3.fromRGB(230, 230, 235)
lblStr.Font = Enum.Font.Gotham
lblStr.TextSize = 11
lblStr.TextXAlignment = Enum.TextXAlignment.Left
lblStr.Parent = frame

local lblReb = Instance.new("TextLabel")
lblReb.Size = UDim2.new(1, -10, 0, 18)
lblReb.Position = UDim2.new(0, 10, 0, 48)
lblReb.BackgroundTransparency = 1
lblReb.Text = "转生: 0"
lblReb.TextColor3 = Color3.fromRGB(230, 230, 235)
lblReb.Font = Enum.Font.Gotham
lblReb.TextSize = 11
lblReb.TextXAlignment = Enum.TextXAlignment.Left
lblReb.Parent = frame

local lblReps = Instance.new("TextLabel")
lblReps.Size = UDim2.new(1, -10, 0, 18)
lblReps.Position = UDim2.new(0, 10, 0, 68)
lblReps.BackgroundTransparency = 1
lblReps.Text = "锻炼次数: 0"
lblReps.TextColor3 = Color3.fromRGB(150, 255, 150)
lblReps.Font = Enum.Font.Gotham
lblReps.TextSize = 11
lblReps.TextXAlignment = Enum.TextXAlignment.Left
lblReps.Parent = frame

local lblTime = Instance.new("TextLabel")
lblTime.Size = UDim2.new(1, -10, 0, 18)
lblTime.Position = UDim2.new(0, 10, 0, 88)
lblTime.BackgroundTransparency = 1
lblTime.Text = "时长: 00:00:00"
lblTime.TextColor3 = Color3.fromRGB(230, 230, 235)
lblTime.Font = Enum.Font.Gotham
lblTime.TextSize = 11
lblTime.TextXAlignment = Enum.TextXAlignment.Left
lblTime.Parent = frame

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

task.spawn(function()
    while hud.Parent do
        local str = getStat("Strength", "Power")
        local reb = getStat("Rebirths", "Rebirth")
        lblStr.Text = "力量: " .. fmt(str)
        lblReb.Text = "转生: " .. fmt(reb)
        lblReps.Text = "锻炼次数: " .. fmt(totalReps)
        
        local elapsed = tick() - startTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = math.floor(elapsed % 60)
        lblTime.Text = string.format("时长: %02d:%02d:%02d", h, m, s)
        
        task.wait(0.5)
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

TabMain:Input({
    Title = "目标次数",
    Placeholder = "自定义目标",
    Value = "",
    Callback = function(state)
    end
})

TabMain:Input({
    Title = "倍率",
    Placeholder = "自己调节",
    Value = "1",
    Callback = function(state)
    end
})

TabMain:Dropdown({
    Title = "选择锻炼类型",
    Values = {"默认", "哑铃", "倒立", "仰卧起坐", "俯卧撑"},
    Value = "默认",
    Callback = function(opt)
    end
})

TabMain:Toggle({
    Title = "自动锻炼",
    Value = false,
    Callback = function(s)
        if s then
            task.spawn(function()
                while s do
                    local me = LP:FindFirstChild("muscleEvent")
                    if me then
                        pcall(function() me:FireServer("rep") end)
                        totalReps = totalReps + 1
                    end
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
                    if me then
                        pcall(function() 
                            for i = 1, 20 do 
                                me:FireServer("rep") 
                            end 
                        end)
                        totalReps = totalReps + 20
                    end
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
                    if me then
                        pcall(function() for i = 1, 20 do me:FireServer("rep") end end)
                        totalReps = totalReps + 20
                    end
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
            if Dropdown.SetOptions then
                Dropdown:SetOptions(plrs)
            elseif Dropdown.Refresh then
                Dropdown:Refresh(plrs)
            end
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