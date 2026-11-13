local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存木材 V1.4",
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
})

task.spawn(function()
    task.wait(1.5)
    if Window.OpenButtonMain and Window.OpenButtonMain.Button then
        local openBtn = Window.OpenButtonMain.Button
        
        openBtn.AutomaticSize = Enum.AutomaticSize.None
        openBtn.Size = UDim2.new(0, 45, 0, 45)
        
        for _, child in pairs(openBtn:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("ImageLabel") or child:IsA("Frame") or child:IsA("TextButton") then
                if child.Name ~= "CustomImage" and child.Name ~= "CustomStroke" then
                    child.Visible = false
                end
            end
        end

        local img = Instance.new("ImageLabel")
        img.Name = "CustomImage"
        img.Parent = openBtn
        img.Size = UDim2.new(1, 0, 1, 0)
        img.BackgroundTransparency = 1
        img.Image = "rbxasset://b33a43199a0a3f7d776cac641182db83/bg.jpg"
        img.ScaleType = Enum.ScaleType.Crop
        img.ZIndex = 1
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = img

        local stroke = Instance.new("UIStroke")
        stroke.Name = "CustomStroke"
        stroke.Thickness = 2.5
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = img
        
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
        }
        gradient.Parent = stroke
        
        local rotation = 0
        task.spawn(function()
            while img.Parent do
                rotation = rotation + 1
                gradient.Rotation = rotation
                task.wait(0.02)
            end
        end)
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