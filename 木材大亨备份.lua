local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/crown.lua"))()
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

local TabMain = UI.CreateTab("主要")

UI.CreateToggle(TabMain, "快速锻炼", false, function(s)
if s then
task.spawn(function()
while s do
pcall(function() for i=1,20 do me:FireServer("rep") end end)
task.wait(0.1)
end
end)
end
end)

UI.CreateToggle(TabMain, "自动重生", false, function(s)
if s then
task.spawn(function()
while s do
pcall(function() for i=1,20 do me:FireServer("rep") end end)
task.wait(0.1)
end
end)
end
end)

UI.CreateToggle(TabMain, "超载硬拉", false, function(s)
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
end)

UI.CreateToggle(TabMain, "超载深蹲", false, function(s)
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
end)

local TabTP = UI.CreateTab("传送")
local tps = {
{"大厅", Vector3.new(-0.75, 90.61, 242.78)},
{"小岛", Vector3.new(-32.14, 8.51, 1904.41)},
{"冰霜健身房", Vector3.new(-2623.41, 6.99, -409.34)},
{"神话健身房", Vector3.new(2250.39, 6.99, 1072.77)},
{"超载健身房", Vector3.new(-3045.3, 165.41, 4990.69)},
{"boss战斗场", Vector3.new(-18.77, 47.41, -1232.43)}
}

for _, v in ipairs(tps) do
UI.CreateButton(TabTP, v[1], function()
local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if hrp then hrp.CFrame = CFrame.new(v[2]) end
end)
end

local TabPlayer = UI.CreateTab("玩家")

local function getPlr()
local list = {}
for _, p in ipairs(Players:GetPlayers()) do
if p ~= LP then table.insert(list, p.Name) end
end
return list
end

local dropdown = UI.CreateDropdown(TabPlayer, "选择玩家", getPlr(), "", function(v)
targetPlayer = v
end)

UI.CreateButton(TabPlayer, "刷新玩家列表", function()
if dropdown and dropdown.SetOptions then
dropdown.SetOptions(getPlr())
end
end)

UI.CreateButton(TabPlayer, "传送到玩家身边", function()
local t = Players:FindFirstChild(targetPlayer)
if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LP.Character then
LP.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
end
end)

UI.CreateToggle(TabPlayer, "循环锁定传送", false, function(s)
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
end)

local TabOther = UI.CreateTab("其他")

UI.CreateButton(TabOther, "防挂机踢出", function()
pcall(function()
for _, conn in pairs(getconnections(LP.Idled)) do
conn:Disable()
conn:Disconnect()
end
end)
end)

UI.CreateButton(TabOther, "防卡顿", function()
Lighting.Brightness = 0
Lighting.GlobalShadows = false
for _, v in pairs(workspace:GetDescendants()) do
pcall(function() v:Destroy() end)
end
end)