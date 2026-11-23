local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/crown.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local Window = library:CreateWindow({ Title = "封存" })

local muscleEvent = LocalPlayer:WaitForChild("muscleEvent", 15)
local Globals = { target = "", loopTP = false, autoTrain = false, autoRebirth = false, autoHard = false, autoSquat = false }

LocalPlayer.Idled:Connect(function()
VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
task.wait(0.05)
VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
end)

local TabMain = Window:Tab({ Title = "主要" })

TabMain:Toggle({
Title = "快速锻炼",
Default = false,
Callback = function(state)
Globals.autoTrain = state
if state then
task.spawn(function()
while Globals.autoTrain do
pcall(function() for i = 1, 20 do muscleEvent:FireServer("rep") end end)
task.wait(0.1)
end
end)
end
end
})

TabMain:Toggle({
Title = "自动重生",
Default = false,
Callback = function(state)
Globals.autoRebirth = state
if state then
task.spawn(function()
while Globals.autoRebirth do
pcall(function() for i = 1, 20 do muscleEvent:FireServer("rep") end end)
task.wait(0.1)
end
end)
end
end
})

TabMain:Toggle({
Title = "超载硬拉",
Default = false,
Callback = function(state)
Globals.autoHard = state
if state then
task.spawn(function()
while Globals.autoHard do
pcall(function()
if workspace:FindFirstChild("machinesFolder") and workspace.machinesFolder:FindFirstChild("Overcharged Bar Lift") then
muscleEvent:FireServer("rep", workspace.machinesFolder["Overcharged Bar Lift"].interactSeat)
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
Default = false,
Callback = function(state)
Globals.autoSquat = state
if state then
task.spawn(function()
while Globals.autoSquat do
pcall(function()
if workspace:FindFirstChild("machinesFolder") and workspace.machinesFolder:FindFirstChild("Overcharged Squat") then
muscleEvent:FireServer("rep", workspace.machinesFolder["Overcharged Squat"].interactSeat)
end
end)
task.wait(0.1)
end
end)
end
end
})

local TabTP = Window:Tab({ Title = "传送" })
local tps = {
{ title = "大厅", pos = Vector3.new(-0.75, 90.61, 242.78) },
{ title = "小岛", pos = Vector3.new(-32.14, 8.51, 1904.41) },
{ title = "冰霜健身房", pos = Vector3.new(-2623.41, 6.99, -409.34) },
{ title = "神话健身房", pos = Vector3.new(2250.39, 6.99, 1072.77) },
{ title = "超载健身房", pos = Vector3.new(-3045.3, 165.41, 4990.69) },
{ title = "boss战斗场", pos = Vector3.new(-18.77, 47.41, -1232.43) }
}

for _, item in ipairs(tps) do
TabTP:Button({
Title = item.title,
Callback = function()
local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if hrp then hrp.CFrame = CFrame.new(item.pos) end
end
})
end

local TabPlayer = Window:Tab({ Title = "玩家" })

local function getPlayerList()
local list = {}
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer then table.insert(list, p.Name) end
end
return list
end

local Dropdown = TabPlayer:Dropdown({
Title = "选择玩家",
Values = getPlayerList(),
Value = "",
Callback = function(v) Globals.target = v end
})

TabPlayer:Button({
Title = "刷新玩家列表",
Callback = function()
if Dropdown.SetOptions then Dropdown.SetOptions(getPlayerList()) end
end
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
Default = false,
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

local TabOther = Window:Tab({ Title = "其他" })

TabOther:Button({
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

TabOther:Button({
Title = "防卡顿",
Callback = function()
Lighting.Brightness = 0
Lighting.GlobalShadows = false
for _, v in pairs(workspace:GetDescendants()) do
pcall(function() v:Destroy() end)
end
end
})