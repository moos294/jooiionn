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
    Title = "",
    Icon = "",
    Enabled = true,
    Draggable = true,
    CornerRadius = UDim.new(0, 8),
    Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 0, 255))
})

task.spawn(function()
    task.wait(1.5) 
    if Window.OpenButtonMain and Window.OpenButtonMain.Button then
        local btn = Window.OpenButtonMain.Button
        
        btn.Size = UDim2.new(0, 42, 0, 42)
        
        for _, child in pairs(btn:GetDescendants()) do
            if child:IsA("TextLabel") then
                child.Visible = false
            end
            if child:IsA("ImageLabel") and child.Name ~= "CustomBgImage" then
                child.ImageTransparency = 1
                child.BackgroundTransparency = 1
            end
        end
        
        local bgImg = Instance.new("ImageLabel")
        bgImg.Name = "CustomBgImage"
        bgImg.Parent = btn
        bgImg.Size = UDim2.new(1, 0, 1, 0)
        bgImg.BackgroundTransparency = 1
        bgImg.Image = "rbxasset://b33a43199a0a3f7d776cac641182db83/bg.jpg"
        bgImg.ScaleType = Enum.ScaleType.Crop
        bgImg.ZIndex = 0
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = bgImg

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = bgImg
        
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
        }
        gradient.Rotation = 45
        gradient.Parent = stroke
        
        local glow = Instance.new("ImageLabel")
        glow.Name = "GlowEffect"
        glow.Parent = btn
        glow.Size = UDim2.new(1, 16, 1, 16)
        glow.Position = UDim2.new(0.5, 0, 0.5, 0)
        glow.AnchorPoint = Vector2.new(0.5, 0.5)
        glow.BackgroundTransparency = 1
        glow.Image = "rbxassetid://1316045217"
        glow.ImageColor3 = Color3.fromRGB(255, 0, 255)
        glow.ImageTransparency = 0.5
        glow.ZIndex = -1
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