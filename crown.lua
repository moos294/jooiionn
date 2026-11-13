local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Title = "封存木材 V1.4",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Size = UDim2.fromOffset(380, 320),
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
    CornerRadius = UDim.new(0, 10),
    StrokeThickness = 0,
})

-- 【彻底重写悬浮窗，根除穿模】
task.spawn(function()
    task.wait(1.5)
    if Window.OpenButtonMain and Window.OpenButtonMain.Button then
        local openBtn = Window.OpenButtonMain.Button
        
        -- 彻底干掉自带的排版和拉伸
        openBtn.AutomaticSize = Enum.AutomaticSize.None
        openBtn.Size = UDim2.new(0, 45, 0, 45)
        openBtn.ClipsDescendants = true
        openBtn.BackgroundTransparency = 1
        
        for _, child in pairs(openBtn:GetChildren()) do
            if child:IsA("UIListLayout") or child:IsA("UIPadding") then
                child:Destroy()
            elseif child:IsA("GuiObject") then
                child.Visible = false
            end
        end
        
        local thumb = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        
        local img = Instance.new("ImageLabel")
        img.Name = "CustomAvatar"
        img.Parent = openBtn
        img.Size = UDim2.new(1, 0, 1, 0)
        img.BackgroundTransparency = 1
        img.Image = thumb
        img.ScaleType = Enum.ScaleType.Crop
        img.ZIndex = 1
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = img

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
Tabs.TabHome  = Window:Tab({ Title = "个人主页", Icon = "user" })
Tabs.TabTree  = Window:Tab({ Title = "带来树", Icon = "trees" })
Tabs.TabBuy   = Window:Tab({ Title = "自动购买", Icon = "shopping-cart" })
Tabs.TabCraft = Window:Tab({ Title = "快速合成剑", Icon = "flame" })
Tabs.TabTP    = Window:Tab({ Title = "传送", Icon = "map" })
Tabs.TabExtra = Window:Tab({ Title = "其他功能", Icon = "settings" })

return { Window = Window, WindUI = WindUI, Tabs = Tabs }