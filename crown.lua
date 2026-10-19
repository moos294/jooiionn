local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("GojoSkillUI")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "GojoSkillUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(230, 340)
panel.Position = UDim2.new(0, 20, 0.3, 0)
panel.BackgroundColor3 = Color3.fromRGB(15, 19, 35)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel = 0
panel.Active = true
panel.ClipsDescendants = true
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(85, 145, 255)
panelStroke.Thickness = 1.5
panelStroke.Parent = panel

local header = Instance.new("TextButton")
header.Name = "Header"
header.Size = UDim2.new(1, -44, 0, 44)
header.Position = UDim2.fromOffset(10, 0)
header.BackgroundTransparency = 1
header.Text = "GOJO  |  VERSION 1.0"
header.TextColor3 = Color3.fromRGB(225, 238, 255)
header.Font = Enum.Font.GothamBold
header.TextSize = 13
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

local toggle = Instance.new("TextButton")
toggle.Name = "Minimize"
toggle.Size = UDim2.fromOffset(32, 32)
toggle.Position = UDim2.new(1, -38, 0, 6)
toggle.BackgroundColor3 = Color3.fromRGB(45, 65, 110)
toggle.Text = "−"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 22
toggle.Parent = panel

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

local content = Instance.new("Frame")
content.Name = "SkillButtons"
content.Position = UDim2.fromOffset(10, 50)
content.Size = UDim2.new(1, -20, 0, 228)
content.BackgroundTransparency = 1
content.Parent = panel

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.5, -5, 0, 64)
grid.CellPadding = UDim2.fromOffset(8, 8)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = content

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Position = UDim2.new(0, 10, 1, -49)
status.Size = UDim2.new(1, -20, 0, 38)
status.BackgroundColor3 = Color3.fromRGB(27, 35, 58)
status.BackgroundTransparency = 0.15
status.Text = "READY  |  VERSION 1.0"
status.TextColor3 = Color3.fromRGB(170, 205, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true
status.Parent = panel

Instance.new("UICorner", status).CornerRadius = UDim.new(0, 8)

local function getCharacter()
    local character = player.Character
    if not character then
        return nil, nil, nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root or humanoid.Health <= 0 then
        return nil, nil, nil
    end

    return character, humanoid, root
end

local function createOrb(color, size, distance)
    local _, _, root = getCharacter()
    if not root then
        status.Text = "角色尚未准备好"
        return
    end

    local orb = Instance.new("Part")
    orb.Name = "GojoBlueOrb"
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(size, size, size)
    orb.Material = Enum.Material.Neon
    orb.Color = color
    orb.Anchored = true
    orb.CanCollide = false
    orb.CastShadow = false
    orb.CFrame = root.CFrame * CFrame.new(0, 1.5, -distance)
    orb.Parent = workspace

    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = 3
    light.Range = 16
    light.Parent = orb

    local attachment = Instance.new("Attachment")
    attachment.Parent = orb

    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(color)
    particles.LightEmission = 1
    particles.Rate = 45
    particles.Lifetime = NumberRange.new(0.2, 0.55)
    particles.Speed = NumberRange.new(1, 4)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(1, 0)
    })
    particles.Parent = attachment

    local targetCFrame = orb.CFrame * CFrame.new(0, 0, -18)

    TweenService:Create(
        orb,
        TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            CFrame = targetCFrame,
            Size = Vector3.new(size * 1.7, size * 1.7, size * 1.7),
            Transparency = 1
        }
    ):Play()

    TweenService:Create(
        light,
        TweenInfo.new(0.8),
        {Brightness = 0}
    ):Play()

    Debris:AddItem(orb, 1.1)
end

local function createWave(color, maxSize)
    local _, _, root = getCharacter()
    if not root then
        status.Text = "角色尚未准备好"
        return
    end

    local wave = Instance.new("Part")
    wave.Name = "GojoShockwave"
    wave.Shape = Enum.PartType.Ball
    wave.Size = Vector3.new(2, 2, 2)
    wave.Material = Enum.Material.Neon
    wave.Color = color
    wave.Transparency = 0.2
    wave.Anchored = true
    wave.CanCollide = false
    wave.CastShadow = false
    wave.CFrame = root.CFrame
    wave.Parent = workspace

    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = 3
    light.Range = 20
    light.Parent = wave

    TweenService:Create(
        wave,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = Vector3.new(maxSize, maxSize, maxSize),
            Transparency = 1
        }
    ):Play()

    TweenService:Create(
        light,
        TweenInfo.new(0.8),
        {Brightness = 0}
    ):Play()

    Debris:AddItem(wave, 0.9)
end

local function createDomain()
    local _, _, root = getCharacter()
    if not root then
        status.Text = "角色尚未准备好"
        return
    end

    local sphere = Instance.new("Part")
    sphere.Name = "InfiniteVoidVisual"
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(4, 4, 4)
    sphere.Material = Enum.Material.ForceField
    sphere.Color = Color3.fromRGB(100, 70, 255)
    sphere.Transparency = 0.28
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.CastShadow = false
    sphere.CFrame = root.CFrame
    sphere.Parent = workspace

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(115, 100, 255)
    light.Brightness = 4
    light.Range = 35
    light.Parent = sphere

    local attachment = Instance.new("Attachment")
    attachment.Parent = sphere

    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 170, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(170, 90, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    particles.LightEmission = 1
    particles.Rate = 100
    particles.Lifetime = NumberRange.new(0.5, 1.4)
    particles.Speed = NumberRange.new(3, 10)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 0)
    })
    particles.Parent = attachment

    TweenService:Create(
        sphere,
        TweenInfo.new(1.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {
            Size = Vector3.new(55, 55, 55),
            Transparency = 0.82
        }
    ):Play()

    task.delay(1.5, function()
        if sphere.Parent then
            TweenService:Create(
                sphere,
                TweenInfo.new(1),
                {Transparency = 1}
            ):Play()

            TweenService:Create(
                light,
                TweenInfo.new(1),
                {Brightness = 0}
            ):Play()
        end
    end)

    Debris:AddItem(sphere, 2.7)
end

local function createTeleportFlash()
    local _, _, root = getCharacter()
    if not root then
        status.Text = "角色尚未准备好"
        return
    end

    local flash = Instance.new("Part")
    flash.Name = "GojoTeleportVisual"
    flash.Shape = Enum.PartType.Ball
    flash.Size = Vector3.new(4, 4, 4)
    flash.Material = Enum.Material.Neon
    flash.Color = Color3.fromRGB(100, 220, 255)
    flash.Transparency = 0.15
    flash.Anchored = true
    flash.CanCollide = false
    flash.CastShadow = false
    flash.CFrame = root.CFrame
    flash.Parent = workspace

    local light = Instance.new("PointLight")
    light.Color = flash.Color
    light.Brightness = 5
    light.Range = 18
    light.Parent = flash

    TweenService:Create(
        flash,
        TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = Vector3.new(12, 12, 12),
            Transparency = 1
        }
    ):Play()

    TweenService:Create(
        light,
        TweenInfo.new(0.45),
        {Brightness = 0}
    ):Play()

    Debris:AddItem(flash, 0.5)
end

local function createShield()
    local character, _, root = getCharacter()
    if not character then
        status.Text = "角色尚未准备好"
        return
    end

    local oldShield = character:FindFirstChild("GojoLocalShield")
    if oldShield then
        oldShield:Destroy()
        status.Text = "无下限护盾：关闭"
        return
    end

    local shield = Instance.new("Part")
    shield.Name = "GojoLocalShield"
    shield.Shape = Enum.PartType.Ball
    shield.Size = Vector3.new(8, 8, 8)
    shield.Material = Enum.Material.ForceField
    shield.Color = Color3.fromRGB(75, 170, 255)
    shield.Transparency = 0.5
    shield.Anchored = false
    shield.CanCollide = false
    shield.Massless = true
    shield.CastShadow = false
    shield.CFrame = root.CFrame
    shield.Parent = character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = shield
    weld.Parent = shield

    local light = Instance.new("PointLight")
    light.Color = shield.Color
    light.Brightness = 2
    light.Range = 14
    light.Parent = shield

    local attachment = Instance.new("Attachment")
    attachment.Parent = shield

    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(shield.Color)
    particles.LightEmission = 1
    particles.Rate = 22
    particles.Lifetime = NumberRange.new(0.4, 0.9)
    particles.Speed = NumberRange.new(1, 3)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Size = NumberSequence.new(0.18)
    particles.Parent = attachment

    status.Text = "无下限护盾：开启"
end

local function playSkill(index)
    if index == 1 then
        status.Text = "苍：聚集能量"
        createOrb(Color3.fromRGB(45, 145, 255), 3, 5)
    elseif index == 2 then
        status.Text = "赫：释放冲击波"
        createWave(Color3.fromRGB(255, 55, 75), 28)
    elseif index == 3 then
        status.Text = "茈：释放虚式"
        createOrb(Color3.fromRGB(175, 65, 255), 4, 6)
        task.delay(0.2, function()
            createWave(Color3.fromRGB(130, 70, 255), 18)
        end)
    elseif index == 4 then
        status.Text = "无量空处：领域展开"
        createDomain()
    elseif index == 5 then
        status.Text = "瞬移：视觉效果"
        createTeleportFlash()
    elseif index == 6 then
        createShield()
    end
end

local skills = {
    {"苍  |  BLUE", Color3.fromRGB(35, 110, 220)},
    {"赫  |  RED", Color3.fromRGB(190, 45, 60)},
    {"茈  |  PURPLE", Color3.fromRGB(125, 55, 205)},
    {"无量空处", Color3.fromRGB(70, 60, 150)},
    {"瞬移特效", Color3.fromRGB(30, 125, 150)},
    {"无下限", Color3.fromRGB(45, 90, 165)}
}

for i, skill in ipairs(skills) do
    local button = Instance.new("TextButton")
    button.Name = "Skill" .. i
    button.LayoutOrder = i
    button.BackgroundColor3 = skill[2]
    button.BackgroundTransparency = 0.05
    button.BorderSizePixel = 0
    button.Text = skill[1]
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.Parent = content

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 210, 255)
    stroke.Transparency = 0.65
    stroke.Parent = button

    button.Activated:Connect(function()
        playSkill(i)
    end)
end

local minimized = false

toggle.Activated:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    status.Visible = not minimized

    if minimized then
        panel.Size = UDim2.fromOffset(230, 46)
        toggle.Text = "+"
    else
        panel.Size = UDim2.fromOffset(230, 340)
        toggle.Text = "−"
    end
end)

local dragging = false
local dragStart
local startPosition
local activeInput

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = panel.Position
        activeInput = input

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                activeInput = nil
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        if activeInput and activeInput.UserInputType == Enum.UserInputType.Touch
            and input ~= activeInput then
            return
        end

        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)