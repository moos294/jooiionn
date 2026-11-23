local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/UI.lua"))()
local Window = UI.Window
local WindUI = UI.WindUI
    Title = "封存",
    Author = "封存",
    Folder = "FengCun",
    Size = UDim2.fromOffset(520, 420),
    Transparent = false,
    KeySystem = false
})

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local me = LP:WaitForChild("muscleEvent", 15)
local targetPlayer = ""
local loopTP = false

LP.Idled:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
end)

local TabMain = Window:Tab({ Title = "主要", Icon = "zap" })

TabMain:Toggle({
    Title = "快速锻炼",
    Value = false,
    Callback = function(s)
        if s then
            task.spawn(function()
                while s do
                    pcall(function() for i = 1, 20 do me:FireServer("rep") end end)
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
                    pcall(function() for i = 1, 20 do me:FireServer("rep") end end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

TabMain:Toggle({
    Title = "超载硬拉",
    Value = false,
    Callback = function(s)
        if s then
            task.spawn(function()
                while s do
                    pcall(function()
                        if workspace:FindFirstChild("machinesFolder") and workspace.machinesFolder:FindFirstChild("Overcharged Bar Lift") then
                            me:FireServer("rep", workspace.machinesFolder["Overcharged Bar Lift"].interactSeat)
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

TabMain:Toggle({
    Title = "超载深蹲",
    Value = false,
    Callback = function(s)
        if s then
            task.spawn(function()
                while s do
                    pcall(function()
                        if workspace:FindFirstChild("machinesFolder") and workspace.machinesFolder:FindFirstChild("Overcharged Squat") then
                            me:FireServer("rep", workspace.machinesFolder["Overcharged Squat"].interactSeat)
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

local TabTP = Window:Tab({ Title = "传送", Icon = "map-pin" })
local tps = {
    {"大厅", Vector3.new(-0.75, 90.61, 242.78)},
    {"小岛", Vector3.new(-32.14, 8.51, 1904.41)},
    {"冰霜健身房", Vector3.new(-2623.41, 6.99, -409.34)},
    {"神话健身房", Vector3.new(2250.39, 6.99, 1072.77)},
    {"超载健身房", Vector3.new(-3045.3, 165.41, 4990.69)},
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

local TabPlayer = Window:Tab({ Title = "玩家", Icon = "user" })

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
        Dropdown:Refresh(getPlr())
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

local TabOther = Window:Tab({ Title = "其他", Icon = "settings" })

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
    Title = "防卡顿",
    Callback = function()
        Lighting.Brightness = 0
        Lighting.GlobalShadows = false
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function() v:Destroy() end)
        end
        WindUI:Notify({ Title = "成功", Content = "已清理垃圾模型", Duration = 3 })
    end
})