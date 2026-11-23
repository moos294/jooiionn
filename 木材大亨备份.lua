local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/crown.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Window = library:CreateWindow({
    Title = "封存",
    Author = "",
    Folder = "FengCunHub",
    HideSearchBar = true,
    Icon = "zap",
    KeySystem = false,
    MaxSize = Vector2.new(520, 420),
    MinSize = Vector2.new(520, 420),
    NoResize = true,
    OpenButton = {
        Title = "封存",
        Draggable = true,
        Enabled = true,
        Icon = "zap"
    },
    Resizable = false,
    ScrollBarEnabled = true,
    SideBarWidth = 140,
    Size = UDim2.fromOffset(520, 420)
})

local muscleEvent = LocalPlayer:WaitForChild("muscleEvent", 15)
_G.trainMultiplier = 1
_G.rbTarget = 0

LocalPlayer.Idled:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
end)

local Tab = Window:Tab({ Title = "主要", Icon = "zap" })

Tab:Input({
    Title = "目标次数",
    Placeholder = "自定义目标",
    Value = "",
    Callback = function(state) if state then _G.rbTarget = tonumber(state) end end
})

Tab:Toggle({
    Title = "自动重生",
    Value = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                while state do
                    pcall(function() for i = 1, 20 do muscleEvent:FireServer("rep") end end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

Tab:Toggle({
    Title = "快速锻炼",
    Value = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                while state do
                    pcall(function() for i = 1, 20 do muscleEvent:FireServer("rep") end end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

local Tab2 = Window:Tab({ Title = "器材", Icon = "dumbbell" })
Tab2:Toggle({
    Title = "超载硬拉",
    Value = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                while state do
                    pcall(function() muscleEvent:FireServer("rep", workspace.machinesFolder["Overcharged Bar Lift"].interactSeat) end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

Tab2:Toggle({
    Title = "超载深蹲",
    Value = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                while state do
                    pcall(function() muscleEvent:FireServer("rep", workspace.machinesFolder["Overcharged Squat"].interactSeat) end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

local Tab3 = Window:Tab({ Title = "传送", Icon = "map-pin" })
local tps = {
    { title = "大厅", pos = Vector3.new(-0.75, 90.61, 242.78) },
    { title = "小岛", pos = Vector3.new(-32.14, 8.51, 1904.41) },
    { title = "冰霜健身房", pos = Vector3.new(-2623.41, 6.99, -409.34) },
    { title = "神话健身房", pos = Vector3.new(2250.39, 6.99, 1072.77) },
    { title = "超载健身房", pos = Vector3.new(-3045.3, 165.41, 4990.69) },
    { title = "boss战斗场", pos = Vector3.new(-18.77, 47.41, -1232.43) }
}

for _, item in ipairs(tps) do
    Tab3:Button({
        Title = item.title,
        Callback = function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(item.pos) end
        end
    })
end

local TabPlayer = Window:Tab({ Title = "玩家", Icon = "user" })
local Globals = { target = "", loopTP = false }

local function getPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

local Dropdown = TabPlayer:Dropdown({
    Title = "选择玩家",
    Default = "",
    Values = getPlayerList(),
    Callback = function(v) Globals.target = v end
})

TabPlayer:Button({
    Title = "刷新玩家列表",
    Callback = function() Dropdown:Refresh(getPlayerList(), true) end
})

TabPlayer:Button({
    Title = "传送到玩家身边",
    Callback = function()
        local t = Players:FindFirstChild(Globals.target)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

TabPlayer:Toggle({
    Title = "循环锁定传送",
    Value = false,
    Callback = function(state)
        Globals.loopTP = state
        if state then
            task.spawn(function()
                while Globals.loopTP do
                    pcall(function()
                        local t = Players:FindFirstChild(Globals.target)
                        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end
})

local Tab5 = Window:Tab({ Title = "其他", Icon = "settings" })
Tab5:Button({
    Title = "防挂机踢出",
    Callback = function()
        pcall(function()
            for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
                conn:Disable()
                conn:Disconnect()
            end
        end)
    end
})

Tab5:Button({
    Title = "防卡顿",
    Callback = function()
        Lighting.Brightness = 0
        Lighting.GlobalShadows = false
        for _, v in pairs(workspace:GetDescendants()) do
            pcall(function() v:Destroy() end)
        end
    end
})