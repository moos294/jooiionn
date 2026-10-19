local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("GojoSkillUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "GojoSkillUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(220, 310)
panel.Position = UDim2.new(0, 20, 0.3, 0)
panel.BackgroundColor3 = Color3.fromRGB(18, 22, 40)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(75, 130, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.2
stroke.Parent = panel

local header = Instance.new("TextButton")
header.Name = "DragHeader"
header.Size = UDim2.new(1, -42, 0, 42)
header.Position = UDim2.fromOffset(8, 0)
header.BackgroundTransparency = 1
header.Text = "五条悟  |  SKILLS"
header.TextColor3 = Color3.fromRGB(220, 235, 255)
header.Font = Enum.Font.GothamBold
header.TextSize = 15
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(34, 32)
toggle.Position = UDim2.new(1, -38, 0, 5)
toggle.BackgroundColor3 = Color3.fromRGB(45, 65, 115)
toggle.Text = "−"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextSize = 23
toggle.Font = Enum.Font.GothamBold
toggle.Parent = panel

Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

local content = Instance.new("Frame")
content.Name = "SkillButtons"
content.Position = UDim2.fromOffset(10, 48)
content.Size = UDim2.new(1, -20, 1, -58)
content.BackgroundTransparency = 1
content.Parent = panel

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.5, -5, 0, 56)
grid.CellPadding = UDim2.fromOffset(8, 8)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = content

local skills = {
    {"🔵 苍", Color3.fromRGB(35, 115, 220)},
    {"🔴 赫", Color3.fromRGB(190, 48, 65)},
    {"🟣 茈", Color3.fromRGB(125, 65, 205)},
    {"🌀 无量空处", Color3.fromRGB(70, 65, 155)},
    {"⚡ 瞬移特效", Color3.fromRGB(30, 135, 155)},
    {"🛡️ 无下限", Color3.fromRGB(45, 95, 165)},
}

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -20, 0, 22)
status.Position = UDim2.new(0, 10, 1, -28)
status.BackgroundTransparency = 1
status.Text = "READY  •  选择技能"
status.TextColor3 = Color3.fromRGB(160, 200, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = panel

content.Size = UDim2.new(1, -20, 1, -82)

for i, skill in ipairs(skills) do
    local button = Instance.new("TextButton")
    button.Name = "Skill" .. i
    button.LayoutOrder = i
    button.BackgroundColor3 = skill[2]
    button.BackgroundTransparency = 0.08
    button.BorderSizePixel = 0
    button.Text = skill[1]
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.Parent = content

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(180, 210, 255)
    outline.Transparency = 0.7
    outline.Parent = button

    button.Activated:Connect(function()
        status.Text = "已选择：" .. skill[1]
    end)
end

-- 点击缩小 / 展开
local minimized = false

toggle.Activated:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    status.Visible = not minimized

    if minimized then
        panel.Size = UDim2.fromOffset(220, 46)
        toggle.Text = "+"
    else
        panel.Size = UDim2.fromOffset(220, 310)
        toggle.Text = "−"
    end
end)

-- 支持鼠标和手机触屏拖动
local dragging = false
local dragInput
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = panel.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input == dragInput
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)