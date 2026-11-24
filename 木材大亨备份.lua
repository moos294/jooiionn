local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/UI.lua"))()
local Window = UI.Window
local WindUI = UI.WindUI

for _, v in ipairs(UI.Gui.Panel:GetDescendants()) do
    if v:IsA("TextLabel") then
        if v.Text == "ORIGAMI" then v.Text = "封存力量 V1.1" end
        if v.Text == "BUILD TOOL" then v.Text = "Author: 封存" end
    end
end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local targetPlayer = ""
local loopTP = false

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
    Title = "快速锻炼",
    Value = false,
    Callback = function(s)
        if s then
            task.spawn(function()
                while s do
                    local me = LP:FindFirstChild("muscleEvent")
                    if me then
                        pcall(function() for i = 1, 20 do me:FireServer("rep") end end)
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