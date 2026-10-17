local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Debris=game:GetService("Debris")
local Lighting=game:GetService("Lighting")
local StarterGui=game:GetService("StarterGui")
local Workspace=game:GetService("Workspace")
local player=Players.LocalPlayer
local camera=Workspace.CurrentCamera

local success,WindUI=pcall(function() return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))() end)
if not success or not WindUI then StarterGui:SetCore("SendNotification",{Title="UI加载失败",Text="网络拦截",Duration=10}) return end

local Window=WindUI:CreateWindow({Title="无量空处 V4.0 2D降维版",Icon="eye",Author="电影级",Folder="PowerCrownSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(300,250)})
local MainTab=Window:Tab({Title="领域",Icon="zap"})
local GojoSection=MainTab:Section({Title="释放",Icon="activity"})

local isCasting = false

local function controlArms(char)
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end
    local lShoulder = torso:FindFirstChild("Left Shoulder") or torso:FindFirstChild("LeftShoulder")
    local rShoulder = torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightShoulder")
    if lShoulder and rShoulder then
        local origL, origR = lShoulder.C0, rShoulder.C0
        local tInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back)
        TweenService:Create(lShoulder, tInfo, {C0 = origL * CFrame.Angles(math.rad(-80), math.rad(25), math.rad(-15))}):Play()
        TweenService:Create(rShoulder, tInfo, {C0 = origR * CFrame.Angles(math.rad(-80), math.rad(-25), math.rad(15))}):Play()
        task.delay(7, function()
            TweenService:Create(lShoulder, TweenInfo.new(0.5), {C0 = origL}):Play()
            TweenService:Create(rShoulder, TweenInfo.new(0.5), {C0 = origR}):Play()
        end)
    end
end

local function createInkText(parent, textStr, yPos, size, delayTime, duration)
    task.delay(delayTime, function()
        local lbl = Instance.new("TextLabel", parent)
        lbl.Text = textStr
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        lbl.Size = UDim2.fromOffset(800, size * 2)
        lbl.Position = UDim2.new(0.5, 0, yPos, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.Arcade
        lbl.TextSize = size
        lbl.TextTransparency = 1
        lbl.ZIndex = 105
        
        local stroke = Instance.new("UIStroke", lbl)
        stroke.Color = Color3.fromRGB(0, 0, 0)
        stroke.Thickness = 10
        stroke.Transparency = 1
        
        TweenService:Create(lbl, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
        
        task.delay(duration or 3, function()
            TweenService:Create(lbl, TweenInfo.new(1), {TextTransparency = 1}):Play()
            TweenService:Create(stroke, TweenInfo.new(1), {Transparency = 1}):Play()
            Debris:AddItem(lbl, 1.1)
        end)
    end)
end

local function castDomain()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    controlArms(char)
    
    local ui = Instance.new("ScreenGui", player.PlayerGui)
    ui.Name = "DomainUI"
    ui.IgnoreGuiInset = true
    ui.DisplayOrder = 100
    
    createInkText(ui, "领域展开", 0.2, 80, 0, 2.5)
    createInkText(ui, "“无量空处”", 0.8, 160, 1.5, 6)
    
    local bg = Instance.new("Frame", ui)
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
    bg.BackgroundTransparency = 1
    bg.ZIndex = 1
    TweenService:Create(bg, TweenInfo.new(1), {BackgroundTransparency = 0.2}):Play()
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Saturation = -1
    cc.Contrast = 3
    cc.Brightness = -0.1
    cc.TintColor = Color3.fromRGB(200, 230, 255)
    
    local voidCenter = Instance.new("Frame", ui)
    voidCenter.AnchorPoint = Vector2.new(0.5, 0.5)
    voidCenter.Position = UDim2.fromScale(0.5, 0.5)
    voidCenter.Size = UDim2.fromOffset(10, 10)
    voidCenter.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    voidCenter.ZIndex = 10
    local voidCorner = Instance.new("UICorner", voidCenter)
    voidCorner.CornerRadius = UDim.new(1, 0)
    
    TweenService:Create(voidCenter, TweenInfo.new(2, Enum.EasingStyle.Exponential), {Size = UDim2.fromOffset(700, 700)}):Play()
    
    local whiteCore = Instance.new("Frame", ui)
    whiteCore.AnchorPoint = Vector2.new(0.5, 0.5)
    whiteCore.Position = UDim2.fromScale(0.5, 0.5)
    whiteCore.Size = UDim2.fromOffset(20, 20)
    whiteCore.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    whiteCore.ZIndex = 11
    local coreCorner = Instance.new("UICorner", whiteCore)
    coreCorner.CornerRadius = UDim.new(1, 0)
    local coreGradient = Instance.new("UIGradient", whiteCore)
    coreGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 200, 255))
    
    local shards = {}
    for i = 1, 60 do
        local shard = Instance.new("Frame", ui)
        shard.AnchorPoint = Vector2.new(0.5, 0.5)
        shard.Position = UDim2.fromScale(0.5, 0.5)
        shard.Size = UDim2.fromOffset(math.random(20, 80), math.random(5, 15))
        shard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        shard.ZIndex = 12
        shard.Rotation = math.random(0, 360)
        local corner = Instance.new("UICorner", shard)
        corner.CornerRadius = UDim.new(0.5, 0)
        
        table.insert(shards, {
            frame = shard,
            angle = math.random() * math.pi * 2,
            dist = 0,
            speed = math.random(80, 200),
            rotSpeed = math.random(-5, 5)
        })
    end
    
    local startTime = tick()
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        local dt = tick() - startTime
        
        for _, s in ipairs(shards) do
            local progress = math.min(dt / 2, 1)
            local currentDist = (s.speed * (1 - (1 - progress)^2))
            local x = math.cos(s.angle) * (300 + currentDist)
            local y = math.sin(s.angle) * (300 + currentDist)
            
            s.frame.Position = UDim2.new(0.5, x, 0.5, y)
            s.frame.Rotation = s.frame.Rotation + s.rotSpeed
            s.frame.BackgroundTransparency = math.max(0, dt - 1.5) / 2
        end
        
        local corePulse = 20 + math.sin(dt * 5) * 5
        whiteCore.Size = UDim2.fromOffset(corePulse, corePulse)
        
        if dt > 4 then
            renderConn:Disconnect()
            TweenService:Create(bg, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
            TweenService:Create(cc, TweenInfo.new(1), {Saturation = 0, Contrast = 0, Brightness = 0, TintColor = Color3.new(1,1,1)}):Play()
            TweenService:Create(voidCenter, TweenInfo.new(1), {Size = UDim2.fromOffset(0,0)}):Play()
            TweenService:Create(whiteCore, TweenInfo.new(1), {Size = UDim2.fromOffset(0,0)}):Play()
            task.wait(1.2)
            ui:Destroy()
            cc:Destroy()
        end
    end)
end

GojoSection:Button({Title="释放无量空处", Callback=function()
    if isCasting then return end
    isCasting = true
    castDomain()
    task.delay(8, function() isCasting = false end)
end})