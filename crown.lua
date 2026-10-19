local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "GojoSkillDemo"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(190, 290)
panel.Position = UDim2.new(0, 15, 0.35, 0)
panel.BackgroundColor3 = Color3.fromRGB(20, 24, 40)
panel.BackgroundTransparency = 0.12
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 38)
title.BackgroundTransparency = 1
title.Text = "五条悟 · 技能演示"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = panel

local function getRoot()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function makeOrb(color, size, distance)
    local root = getRoot()
    if not root then return end

    local orb = Instance.new("Part")
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(size, size, size)
    orb.Material = Enum.Material.Neon
    orb.Color = color
    orb.Anchored = true
    orb.CanCollide = false
    orb.CFrame = root.CFrame * CFrame.new(0, 1.5, -distance)
    orb.Parent = workspace

    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = 3
    light.Range = 14
    light.Parent = orb

    TweenService:Create(
        orb,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = Vector3.new(size * 2, size * 2, size * 2),
            Transparency = 1,
            CFrame = orb.CFrame * CFrame.new(0, 0, -12)
        }
    ):Play()

    Debris:AddItem(orb, 1)
end

local function makeWave(color)
    local root = getRoot()
    if not root then return end

    local wave = Instance.new("Part")
    wave.Shape = Enum.PartType.Ball
    wave.Size = Vector3.new(2, 2, 2)
    wave.Material = Enum.Material.Neon
    wave.Color = color
    wave.Transparency = 0.25
    wave.Anchored = true
    wave.CanCollide = false
    wave.CFrame = root.CFrame
    wave.Parent = workspace

    TweenService:Create(
        wave,
        TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = Vector3.new(24, 24, 24),
            Transparency = 1
        }
    ):Play()

    Debris:AddItem(wave, 0.8)
end

local function makeDomain()
    local root = getRoot()
    if not root then return end

    local sphere = Instance.new("Part")
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(3, 3, 3)
    sphere.Material = Enum.Material.ForceField
    sphere.Color = Color3.fromRGB(100, 80, 255)
    sphere.Transparency = 0.45
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.CFrame = root.CFrame
    sphere.Parent = workspace

    TweenService:Create(
        sphere,
        TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = Vector3.new(45, 45, 45),
            Transparency = 1
        }
    ):Play()

    Debris:AddItem(sphere, 1.3)
end

local function teleportEffect()
    local root = getRoot()
    if not root then return end

    local flash = Instance.new("Part")
    flash.Shape = Enum.PartType.Ball
    flash.Size = Vector3.new(5, 5, 5)
    flash.Material = Enum.Material.Neon
    flash.Color = Color3.fromRGB(100, 200, 255)
    flash.Transparency = 0.25
    flash.Anchored = true
    flash.CanCollide = false
    flash.CFrame = root.CFrame
    flash.Parent = workspace

    TweenService:Create(
        flash,
        TweenInfo.new(0.35),
        {Size = Vector3.new(10, 10, 10), Transparency = 1}
    ):Play()

    Debris:AddItem(flash, 0.4)
end

local skills = {
    {name = "苍 · Blue", color = Color3.fromRGB(50, 150, 255), action = function()
        makeOrb(Color3.fromRGB(50, 150, 255), 3, 5)
    end},
    {name = "赫 · Red", color = Color3.fromRGB(255, 60, 70), action = function()
        makeWave(Color3.fromRGB(255, 60, 70))
    end},
    {name = "茈 · Purple", color = Color3.fromRGB(180, 70, 255), action = function()
        makeOrb(Color3.fromRGB(180, 70, 255), 4, 6)
    end},
    {name = "领域展开", color = Color3.fromRGB(100, 80, 255), action = makeDomain},
    {name = "瞬移特效", color = Color3.fromRGB(80, 220, 255), action = teleportEffect},
    {name = "无下限护盾", color = Color3.fromRGB(80, 180, 255), action = function()
        makeWave(Color3.fromRGB(80, 180, 255))
    end},
}

for i, skill in ipairs(skills) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -16, 0, 35)
    button.Position = UDim2.new(0, 8, 0, 42 + (i - 1) * 40)
    button.BackgroundColor3 = skill.color
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = skill.name
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = panel

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    button.Activated:Connect(skill.action)
end