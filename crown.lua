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

local Window=WindUI:CreateWindow({Title="无量空处 V3.0 极致重构",Icon="eye",Author="电影级",Folder="PowerCrownSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(400,300)})
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
        task.delay(6, function()
            TweenService:Create(lShoulder, TweenInfo.new(0.5), {C0 = origL}):Play()
            TweenService:Create(rShoulder, TweenInfo.new(0.5), {C0 = origR}):Play()
        end)
    end
end

local function createInkText(textStr, yPos, size, delayTime, duration)
    task.delay(delayTime, function()
        local gui = Instance.new("ScreenGui", player.PlayerGui)
        gui.Name = "InkGui"; gui.IgnoreGuiInset = true; gui.DisplayOrder = 100
        
        local lbl = Instance.new("TextLabel", gui)
        lbl.Text = textStr
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        lbl.Size = UDim2.fromOffset(800, size * 2)
        lbl.Position = UDim2.new(0.5, 0, yPos, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.Script
        lbl.TextSize = size
        lbl.TextTransparency = 1
        lbl.ZIndex = 100
        
        local stroke = Instance.new("UIStroke", lbl)
        stroke.Color = Color3.fromRGB(0, 0, 0)
        stroke.Thickness = 6
        stroke.Transparency = 1
        
        TweenService:Create(lbl, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 0}):Play()
        
        task.delay(duration or 3, function()
            TweenService:Create(lbl, TweenInfo.new(1), {TextTransparency = 1}):Play()
            TweenService:Create(stroke, TweenInfo.new(1), {Transparency = 1}):Play()
            Debris:AddItem(gui, 1.1)
        end)
    end)
end

local function castDomain()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    controlArms(char)
    
    createInkText("领域展开", 0.2, 70, 0, 2)
    createInkText("“无量空处”", 0.75, 160, 1.2, 6)
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Saturation = -1
    cc.Contrast = 3
    cc.Brightness = -0.2
    cc.TintColor = Color3.fromRGB(180, 220, 255)
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    local hrp = char.HumanoidRootPart
    local folder = Instance.new("Folder", Workspace); folder.Name = "TrueDomainFX"
    local pos = hrp.Position + hrp.CFrame.LookVector * 20 + Vector3.new(0, 5, 0)
    
    local void = Instance.new("Part", folder)
    void.Shape = Enum.PartType.Ball
    void.Size = Vector3.new(10, 10, 10)
    void.Color = Color3.fromRGB(0, 0, 0)
    void.Material = Enum.Material.SmoothPlastic
    void.Anchored = true
    void.CanCollide = false
    void.CFrame = CFrame.new(pos)
    
    local shell1 = Instance.new("Part", folder)
    shell1.Shape = Enum.PartType.Ball
    shell1.Size = Vector3.new(12, 12, 12)
    shell1.Color = Color3.new(1, 1, 1)
    shell1.Material = Enum.Material.ForceField
    shell1.Transparency = 0.5
    shell1.Anchored = true
    shell1.CanCollide = false
    shell1.CFrame = void.CFrame
    
    local shell2 = Instance.new("Part", folder)
    shell2.Shape = Enum.PartType.Ball
    shell2.Size = Vector3.new(13.5, 13.5, 13.5)
    shell2.Color = Color3.fromRGB(200, 230, 255)
    shell2.Material = Enum.Material.ForceField
    shell2.Transparency = 0.6
    shell2.Anchored = true
    shell2.CanCollide = false
    shell2.CFrame = void.CFrame
    
    local inkEmitter = Instance.new("ParticleEmitter", void)
    inkEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
    inkEmitter.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(150, 200, 255))
    inkEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 15),
        NumberSequenceKeypoint.new(0.5, 30),
        NumberSequenceKeypoint.new(1, 0)
    })
    inkEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    inkEmitter.Speed = NumberRange.new(100, 200)
    inkEmitter.SpreadAngle = Vector2.new(180, 180)
    inkEmitter.Rate = 800
    inkEmitter.Shape = Enum.ParticleEmitterShape.Sphere
    inkEmitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
    inkEmitter.LightEmission = 1
    
    local coreLightPart = Instance.new("Part", folder)
    coreLightPart.Shape = Enum.PartType.Ball
    coreLightPart.Size = Vector3.new(1.2, 1.2, 1.2)
    coreLightPart.Material = Enum.Material.Neon
    coreLightPart.Color = Color3.new(1, 1, 1)
    coreLightPart.Anchored = true
    coreLightPart.CanCollide = false
    coreLightPart.CFrame = CFrame.new(pos)
    
    local cLight = Instance.new("PointLight", coreLightPart)
    cLight.Color = Color3.new(1, 1, 1)
    cLight.Brightness = 10
    cLight.Range = 25
    
    TweenService:Create(void, TweenInfo.new(6, Enum.EasingStyle.Quart), {Size = Vector3.new(100, 100, 100)}):Play()
    TweenService:Create(shell1, TweenInfo.new(6, Enum.EasingStyle.Quart), {Size = Vector3.new(110, 110, 110), Transparency = 1}):Play()
    TweenService:Create(shell2, TweenInfo.new(6, Enum.EasingStyle.Quart), {Size = Vector3.new(125, 125, 125), Transparency = 1}):Play()
    
    local origType = camera.CameraType
    camera.CameraType = Enum.CameraType.Scriptable
    
    local startTime = tick()
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        local dt = tick() - startTime
        
        if dt < 1.5 then
            blur.Size = math.sin((dt / 1.5) * math.pi) * 30
            camera.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 8, 15), pos)
            camera.FieldOfView = 70 - (dt / 1.5) * 20
        else
            blur.Size = 0
            local push = math.min((dt - 1.5) * 2, 10)
            camera.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 5, 20 - push), pos)
            camera.FieldOfView = 50
        end
        
        coreLightPart.CFrame = CFrame.new(pos) * CFrame.Angles(dt * 0.5, dt * 1, 0) * CFrame.new(0, 0, 8)
        
        if dt > 8 then
            renderConn:Disconnect()
            camera.CameraType = origType
            camera.FieldOfView = 70
            folder:Destroy()
            cc:Destroy()
            blur:Destroy()
        end
    end)
end

GojoSection:Button({Title="释放无量空处", Callback=function()
    if isCasting then return end
    isCasting = true
    castDomain()
    task.delay(8.5, function() isCasting = false end)
end})