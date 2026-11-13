local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存木材 V1.3",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Size = UDim2.fromOffset(380, 300),
    Radius = 8,
    Theme = "Dark",
    Transparent = true,
    Background = "rbxasset://b33a43199a0a3f7d776cac641182db83/bg.jpg",
    BackgroundImageTransparency = 0.5
})

Window:EditOpenButton({
    Title = "存",
    Icon = "",
    Enabled = true,
    Draggable = true,
    CornerRadius = UDim.new(0, 10),
    StrokeThickness = 0,
})

task.spawn(function()
    task.wait(1.5)
    if Window.OpenButtonMain and Window.OpenButtonMain.Button then
        local openBtn = Window.OpenButtonMain.Button
        
        openBtn.AutomaticSize = Enum.AutomaticSize.None
        openBtn.Size = UDim2.new(0, 45, 0, 45)
        
        for _, child in pairs(openBtn:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("ImageLabel") or child:IsA("Frame") then
                if child.Name ~= "UserImage" then
                    child.Visible = false
                end
            end
        end

        local img = Instance.new("ImageLabel")
        img.Name = "UserImage"
        img.Parent = openBtn
        img.Size = UDim2.new(1, 0, 1, 0)
        img.BackgroundTransparency = 1
        img.Image = "rbxasset://b33a43199a0a3f7d776cac641182db83/bg.jpg"
        img.ScaleType = Enum.ScaleType.Crop
        img.ZIndex = 1
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = img

        local glass = Instance.new("ImageLabel")
        glass.Parent = img
        glass.Size = UDim2.new(1, 0, 1, 0)
        glass.BackgroundTransparency = 1
        glass.Image = "rbxassetid://9968344227" 
        glass.ImageTransparency = 0.7
        glass.ScaleType = Enum.ScaleType.Tile
        glass.TileSize = UDim2.new(0, 50, 0, 50)
        glass.ZIndex = 2

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.2
        stroke.Parent = img
        
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
        }
        gradient.Rotation = 45
        gradient.Parent = stroke
    end
end)

local Tabs = {}
Tabs.TabExtra = Window:Tab({ Title = "其他功能", Icon = "settings" })
Tabs.TabTree = Window:Tab({ Title = "自动砍树", Icon = "trees" })
Tabs.TabCraft = Window:Tab({ Title = "合成物品", Icon = "flame" })
Tabs.TabItem = Window:Tab({ Title = "物品传送", Icon = "package" })
Tabs.TabTP = Window:Tab({ Title = "安全传送", Icon = "map" })
Tabs.TabServer = Window:Tab({ Title = "服务器", Icon = "server" })

return { Window = Window, WindUI = WindUI, Tabs = Tabs }