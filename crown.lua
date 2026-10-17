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

local Window=WindUI:CreateWindow({Title="力量之冠 V1.1.1 极致视觉版",Icon="zap",Author="力量之冠",Folder="PowerCrownSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(460,780)})
local FunTab=Window:Tab({Title="五条悟专属",Icon="sparkles"})
local GojoSection=FunTab:Section({Title="全套技能获取",Icon="zap"})

local isCasting = false

local function playInkCalligraphy(domainGui, textStr, yPos, size, isEn, delayTime)
    task.delay(delayTime, function()
        local lbl = Instance.new("TextLabel")
        lbl.Text = textStr
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        lbl.Size = UDim2.fromOffset(size * #textStr * 1.1, size * 1.4)
        lbl.Position = UDim2.new(0.5, 0, yPos, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = isEn and Enum.Font.Garamond or Enum.Font.Arcade
        lbl.TextScaled = false
        lbl.TextSize = size
        lbl.TextTransparency = 1
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        lbl.TextStrokeTransparency = 1
        lbl.ZIndex = 15
        lbl.Parent = domainGui
        
        local shadow = Instance.new("TextLabel")
        shadow.Text = textStr
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.Size = UDim2.fromOffset(size * #textStr * 1.1, size * 1.4)
        shadow.Position = UDim2.new(0.5, 3, yPos, 3)
        shadow.BackgroundTransparency = 1
        shadow.TextColor3 = Color3.fromRGB(10, 10, 15)
        shadow.Font = isEn and Enum.Font.Garamond or Enum.Font.Arcade
        shadow.TextSize = size
        shadow.TextTransparency = 1
        shadow.ZIndex = 14
        shadow.Parent = domainGui
        
        TweenService:Create(lbl, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0, TextStrokeTransparency = 0.1}):Play()
        TweenService:Create(shadow, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0.3}):Play()
        
        local seal = Instance.new("TextLabel")
        seal.Text = "五条"
        seal.AnchorPoint = Vector2.new(1, 0)
        seal.Size = UDim2.fromOffset(size * 0.9, size * 1.3)
        seal.Position = UDim2.new(0.5, size * #textStr * 0.48, yPos + size * 0.5, 0)
        seal.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
        seal.TextColor3 = Color3.fromRGB(230, 200, 180)
        seal.Font = Enum.Font.Arcade
        seal.TextSize = size * 0.5
        seal.TextTransparency = 1
        seal.ZIndex = 16
        seal.Parent = domainGui
        
        TweenService:Create(seal, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
        
        task.delay(2.5, function()
            TweenService:Create(lbl, TweenInfo.new(0.4), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
            TweenService:Create(shadow, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            TweenService:Create(seal, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            Debris:AddItem(lbl, 0.5)
            Debris:AddItem(shadow, 0.5)
            Debris:AddItem(seal, 0.5)
        end)
    end)
end

local function controlArms(char, pose)
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end
    local lShoulder = torso:FindFirstChild("Left Shoulder") or torso:FindFirstChild("LeftShoulder")
    local rShoulder = torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightShoulder")
    if lShoulder and rShoulder then
        local origL, origR = lShoulder.C0, rShoulder.C0
        local tInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        if pose == "Right" then
            TweenService:Create(rShoulder, tInfo, {C0 = origR * CFrame.Angles(math.rad(-90), 0, 0)}):Play()
        elseif pose == "Left" then
            TweenService:Create(lShoulder, tInfo, {C0 = origL * CFrame.Angles(math.rad(-90), 0, 0)}):Play()
        elseif pose == "Both" then
            TweenService:Create(lShoulder, tInfo, {C0 = origL * CFrame.Angles(math.rad(-75), math.rad(25), math.rad(-15))}):Play()
            TweenService:Create(rShoulder, tInfo, {C0 = origR * CFrame.Angles(math.rad(-75), math.rad(-25), math.rad(15))}):Play()
        end
        task.delay(2.5, function()
            if lShoulder and rShoulder then
                TweenService:Create(lShoulder, TweenInfo.new(0.4), {C0 = origL}):Play()
                TweenService:Create(rShoulder, TweenInfo.new(0.4), {C0 = origR}):Play()
            end
        end)
    end
end

local function createStarEnergyOrb(char, baseColor, glowColor)
    local hrp = char.HumanoidRootPart
    local orbFolder = Instance.new("Folder", Workspace)
    orbFolder.Name = "JujutsuOrb"
    
    local core = Instance.new("Part")
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(3.2, 3.2, 3.2)
    core.Material = Enum.Material.Neon
    core.Color = Color3.new(1, 1, 1)
    core.Anchored = true
    core.CanCollide = false
    core.CanQuery = false
    core.CFrame = hrp.CFrame * CFrame.new(0, 2, -3)
    core.Parent = orbFolder
    
    local matrixShell = Instance.new("Part")
    matrixShell.Shape = Enum.PartType.Ball
    matrixShell.Size = Vector3.new(4.8, 4.8, 4.8)
    matrixShell.Material = Enum.Material.ForceField
    matrixShell.Color = baseColor
    matrixShell.Transparency = 0.15
    matrixShell.Anchored = true
    matrixShell.CanCollide = false
    matrixShell.CFrame = core.CFrame
    matrixShell.Parent = orbFolder
    
    local haloGlow = Instance.new("Part")
    haloGlow.Shape = Enum.PartType.Ball
    haloGlow.Size = Vector3.new(6.5, 6.5, 6.5)
    haloGlow.Material = Enum.Material.Neon
    haloGlow.Color = glowColor or baseColor
    haloGlow.Transparency = 0.75
    haloGlow.Anchored = true
    haloGlow.CanCollide = false
    haloGlow.CFrame = core.CFrame
    haloGlow.Parent = orbFolder
    
    local light = Instance.new("PointLight", core)
    light.Color = glowColor or baseColor
    light.Range = 28
    light.Brightness = 10
    
    local sparks = Instance.new("ParticleEmitter", core)
    sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    sparks.Color = ColorSequence.new(baseColor, Color3.new(1,1,1))
    sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(0.5, 1.5), NumberSequenceKeypoint.new(1, 0)})
    sparks.Speed = NumberRange.new(35, 85)
    sparks.SpreadAngle = Vector2.new(180, 180)
    sparks.Rate = 350
    sparks.LightEmission = 1
    sparks.Shape = Enum.ParticleEmitterShape.Sphere
    sparks.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
    
    local ring = Instance.new("Part", orbFolder)
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.15, 6, 6)
    ring.Material = Enum.Material.Neon
    ring.Color = baseColor
    ring.Transparency = 0.25
    ring.Anchored = true
    ring.CanCollide = false
    
    local att0 = Instance.new("Attachment", core)
    att0.Position = Vector3.new(0, 1.5, 0)
    local att1 = Instance.new("Attachment", core)
    att1.Position = Vector3.new(0, -1.5, 0)
    
    local trail = Instance.new("Trail", core)
    trail.Attachment0 = att0
    trail.Attachment1 = att1
    trail.Color = ColorSequence.new(baseColor, Color3.new(1,1,1))
    trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
    trail.Lifetime = 0.5
    trail.MinLength = 0.1
    trail.LightEmission = 1
    
    return orbFolder, core, matrixShell, haloGlow, ring, trail
end

local function castBlue()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    controlArms(char, "Right")
    
    local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Intensity = 2.5
    bloom.Size = 26
    bloom.Threshold = 0.85
    Debris:AddItem(bloom, 4)
    
    local folder, core, shell, halo, ring, _ = createStarEnergyOrb(char, Color3.fromRGB(20, 140, 255), Color3.fromRGB(80, 210, 255))
    local hrp = char.HumanoidRootPart
    
    local t0 = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local dt = tick() - t0
        local offset = hrp.CFrame.LookVector * (dt * 3)
        local basePos = hrp.CFrame * CFrame.new(0, 2, -3) + offset
        core.CFrame = basePos
        shell.CFrame = basePos
        halo.CFrame = basePos
        ring.CFrame = CFrame.new(basePos.Position) * CFrame.Angles(dt * 15, dt * 8, math.rad(90))
        if dt > 0.8 then
            conn:Disconnect()
            core.Anchored = false
            shell.Anchored = false
            halo.Anchored = false
            
            local bv = Instance.new("BodyVelocity", core)
            bv.Velocity = camera.CFrame.LookVector * 160
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            
            local bvShell = Instance.new("BodyVelocity", shell)
            bvShell.Velocity = camera.CFrame.LookVector * 160
            bvShell.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            
            local hit = false
            core.Touched:Connect(function(h)
                if h:IsDescendantOf(char) or hit then return end
                hit = true
                bv:Destroy()
                bvShell:Destroy()
                local boom = Instance.new("Part", Workspace)
                boom.Shape = Enum.PartType.Ball
                boom.Material = Enum.Material.Neon
                boom.Color = Color3.fromRGB(50, 180, 255)
                boom.Size = Vector3.new(4,4,4)
                boom.Anchored = true
                boom.CanCollide = false
                boom.Position = core.Position
                local light = Instance.new("PointLight", boom)
                light.Color = Color3.fromRGB(50, 180, 255)
                light.Brightness = 20
                light.Range = 60
                TweenService:Create(boom, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = Vector3.new(45,45,45), Transparency = 1}):Play()
                task.wait(0.5)
                folder:Destroy()
                boom:Destroy()
            end)
            Debris:AddItem(folder, 3)
        end
    end)
end

local function castRed()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    controlArms(char, "Left")
    
    local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Intensity = 2.5
    bloom.Size = 26
    bloom.Threshold = 0.85
    Debris:AddItem(bloom, 4)
    
    local folder, core, shell, halo, ring, _ = createStarEnergyOrb(char, Color3.fromRGB(255, 25, 25), Color3.fromRGB(255, 120, 90))
    local hrp = char.HumanoidRootPart
    
    local t0 = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local dt = tick() - t0
        local offset = hrp.CFrame.LookVector * (dt * 3)
        local basePos = hrp.CFrame * CFrame.new(0, 2, -3) + offset
        core.CFrame = basePos
        shell.CFrame = basePos
        halo.CFrame = basePos
        ring.CFrame = CFrame.new(basePos.Position) * CFrame.Angles(dt * 15, dt * 8, math.rad(90))
        if dt > 0.8 then
            conn:Disconnect()
            core.Anchored = false
            shell.Anchored = false
            halo.Anchored = false
            
            local bv = Instance.new("BodyVelocity", core)
            bv.Velocity = camera.CFrame.LookVector * 180
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            
            local bvShell = Instance.new("BodyVelocity", shell)
            bvShell.Velocity = camera.CFrame.LookVector * 180
            bvShell.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            
            local hit = false
            core.Touched:Connect(function(h)
                if h:IsDescendantOf(char) or hit then return end
                hit = true
                bv:Destroy()
                bvShell:Destroy()
                local boom = Instance.new("Part", Workspace)
                boom.Shape = Enum.PartType.Ball
                boom.Material = Enum.Material.Neon
                boom.Color = Color3.fromRGB(255, 40, 40)
                boom.Size = Vector3.new(4,4,4)
                boom.Anchored = true
                boom.CanCollide = false
                boom.Position = core.Position
                local light = Instance.new("PointLight", boom)
                light.Color = Color3.fromRGB(255, 40, 40)
                light.Brightness = 20
                light.Range = 60
                TweenService:Create(boom, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = Vector3.new(50,50,50), Transparency = 1}):Play()
                task.wait(0.5)
                folder:Destroy()
                boom:Destroy()
            end)
            Debris:AddItem(folder, 3)
        end
    end)
end

local function castPurple()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    controlArms(char, "Both")
    
    local ui = Instance.new("ScreenGui", player.PlayerGui)
    ui.Name = "FusionGUI"
    ui.IgnoreGuiInset = true
    ui.DisplayOrder = 50
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.TintColor = Color3.fromRGB(200, 180, 255)
    cc.Contrast = 0.4
    
    local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Intensity = 2
    bloom.Size = 30
    bloom.Threshold = 0.8
    
    local hrp = char.HumanoidRootPart
    local bFolder, bCore, bShell, bHalo, _, _ = createStarEnergyOrb(char, Color3.fromRGB(20, 140, 255), Color3.fromRGB(80, 210, 255))
    local rFolder, rCore, rShell, rHalo, _, _ = createStarEnergyOrb(char, Color3.fromRGB(255, 25, 25), Color3.fromRGB(255, 120, 90))
    
    local startCenter = hrp.CFrame * CFrame.new(0, 2, -5)
    bCore.Position = startCenter.Position + hrp.CFrame.RightVector * -4
    bShell.Position = bCore.Position
    bHalo.Position = bCore.Position
    
    rCore.Position = startCenter.Position + hrp.CFrame.RightVector * 4
    rShell.Position = rCore.Position
    rHalo.Position = rCore.Position
    
    playInkCalligraphy(ui, "术式顺转·苍", 0.3, 60, false, 0.2)
    playInkCalligraphy(ui, "术式反转·赫", 0.38, 60, false, 0.9)
    
    local t0 = tick()
    local fuseConn
    fuseConn = RunService.RenderStepped:Connect(function()
        local dt = tick() - t0
        bCore.CFrame = startCenter * CFrame.new(-4 + dt * 5, 0, 0)
        bShell.CFrame = bCore.CFrame
        bHalo.CFrame = bCore.CFrame
        
        rCore.CFrame = startCenter * CFrame.new(4 - dt * 5, 0, 0)
        rShell.CFrame = rCore.CFrame
        rHalo.CFrame = rCore.CFrame
        
        if dt > 0.8 then fuseConn:Disconnect() end
    end)
    
    task.wait(0.85)
    
    playInkCalligraphy(ui, "虚式·茈", 0.5, 110, false, 0)
    
    bCore.Transparency = 1
    bShell.Transparency = 1
    bHalo.Transparency = 1
    rCore.Transparency = 1
    rShell.Transparency = 1
    rHalo.Transparency = 1
    bFolder:Destroy()
    rFolder:Destroy()
    
    local corePos = startCenter.Position
    local purpleSphere = Instance.new("Part", Workspace)
    purpleSphere.Shape = Enum.PartType.Ball
    purpleSphere.Size = Vector3.new(1, 1, 1)
    purpleSphere.Material = Enum.Material.ForceField
    purpleSphere.Color = Color3.fromRGB(185, 10, 255)
    purpleSphere.Transparency = 0.05
    purpleSphere.Anchored = true
    purpleSphere.CanCollide = false
    purpleSphere.Position = corePos
    local pLight = Instance.new("PointLight", purpleSphere)
    pLight.Color = Color3.fromRGB(185, 10, 255)
    pLight.Brightness = 30
    pLight.Range = 80
    
    local pEmit = Instance.new("ParticleEmitter", purpleSphere)
    pEmit.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    pEmit.Color = ColorSequence.new(Color3.fromRGB(185, 10, 255), Color3.new(1,1,1))
    pEmit.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 4), NumberSequenceKeypoint.new(1, 0)})
    pEmit.Speed = NumberRange.new(100, 250)
    pEmit.Rate = 1500
    
    TweenService:Create(purpleSphere, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = Vector3.new(14,14,14)}):Play()
    task.wait(0.4)
    
    local beam = Instance.new("Part", Workspace)
    beam.Material = Enum.Material.Neon
    beam.Color = Color3.fromRGB(185, 10, 255)
    beam.Anchored = true
    beam.CanCollide = false
    beam.Size = Vector3.new(18, 18, 400)
    beam.CFrame = CFrame.lookAt(corePos, corePos + camera.CFrame.LookVector) * CFrame.Angles(math.rad(-90), 0, 0)
    
    local innerBeam = Instance.new("Part", Workspace)
    innerBeam.Material = Enum.Material.Neon
    innerBeam.Color = Color3.new(1, 1, 1)
    innerBeam.Anchored = true
    innerBeam.CanCollide = false
    innerBeam.Size = Vector3.new(8, 8, 400)
    innerBeam.CFrame = beam.CFrame
    
    local shakeT0 = tick()
    local shakeConn
    shakeConn = RunService.RenderStepped:Connect(function()
        local dt = tick() - shakeT0
        camera.CFrame = camera.CFrame * CFrame.Angles(math.noise(dt*250,0,0)*0.06, math.noise(0,dt*250,0)*0.06, 0)
        if dt > 2 then shakeConn:Disconnect() end
    end)
    
    TweenService:Create(beam, TweenInfo.new(1.5), {Transparency = 1}):Play()
    TweenService:Create(innerBeam, TweenInfo.new(1.5), {Transparency = 1}):Play()
    TweenService:Create(purpleSphere, TweenInfo.new(1.5), {Transparency = 1}):Play()
    TweenService:Create(cc, TweenInfo.new(1.5), {TintColor = Color3.new(1,1,1), Contrast = 0}):Play()
    
    task.wait(2)
    ui:Destroy()
    cc:Destroy()
    bloom:Destroy()
    beam:Destroy()
    innerBeam:Destroy()
    purpleSphere:Destroy()
end

local function castDomain()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    controlArms(char, "Both")
    
    local ui = Instance.new("ScreenGui", player.PlayerGui)
    ui.Name = "DomainCinematicUI"
    ui.IgnoreGuiInset = true
    ui.DisplayOrder = 100
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Saturation = -1
    cc.Contrast = 2.5
    cc.Brightness = -0.15
    cc.TintColor = Color3.fromRGB(180, 220, 255)
    
    local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Intensity = 3
    bloom.Size = 32
    bloom.Threshold = 0.7
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    playInkCalligraphy(ui, "领域展开", 0.15, 75, false, 0.1)
    playInkCalligraphy(ui, "“无量空处”", 0.7, 135, false, 0.7)
    
    local hrp = char.HumanoidRootPart
    local domainFolder = Instance.new("Folder", Workspace)
    domainFolder.Name = "DomainExpansion"
    
    local spherePos = hrp.Position + hrp.CFrame.LookVector * 15
    
    local voidSphere = Instance.new("Part", domainFolder)
    voidSphere.Shape = Enum.PartType.Ball
    voidSphere.Size = Vector3.new(8, 8, 8)
    voidSphere.Color = Color3.fromRGB(5, 5, 8)
    voidSphere.Material = Enum.Material.SmoothPlastic
    voidSphere.Reflectance = 0.05
    voidSphere.Anchored = true
    voidSphere.CanCollide = false
    voidSphere.CFrame = CFrame.new(spherePos)
    
    local eyeRing = Instance.new("Part", domainFolder)
    eyeRing.Shape = Enum.PartType.Cylinder
    eyeRing.Size = Vector3.new(0.5, 12, 12)
    eyeRing.CFrame = CFrame.new(spherePos) * CFrame.Angles(0, 0, math.rad(90))
    eyeRing.Material = Enum.Material.ForceField
    eyeRing.Color = Color3.fromRGB(200, 240, 255)
    eyeRing.Transparency = 0.1
    eyeRing.Anchored = true
    eyeRing.CanCollide = false
    
    local inkEmitter = Instance.new("ParticleEmitter", eyeRing)
    inkEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
    inkEmitter.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(120, 180, 255))
    inkEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 25),
        NumberSequenceKeypoint.new(0.6, 45),
        NumberSequenceKeypoint.new(1, 0)
    })
    inkEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    inkEmitter.Speed = NumberRange.new(70, 140)
    inkEmitter.SpreadAngle = Vector2.new(180, 180)
    inkEmitter.Rate = 500
    inkEmitter.LightEmission = 1
    
    local whiteOrb = Instance.new("Part", domainFolder)
    whiteOrb.Shape = Enum.PartType.Ball
    whiteOrb.Size = Vector3.new(2.5, 2.5, 2.5)
    whiteOrb.Material = Enum.Material.Neon
    whiteOrb.Color = Color3.new(1,1,1)
    whiteOrb.Anchored = true
    whiteOrb.CanCollide = false
    whiteOrb.CFrame = CFrame.new(spherePos)
    
    local light = Instance.new("PointLight", whiteOrb)
    light.Color = Color3.new(1,1,1)
    light.Brightness = 25
    light.Range = 35
    
    TweenService:Create(voidSphere, TweenInfo.new(3, Enum.EasingStyle.Quart), {Size = Vector3.new(125, 125, 125)}):Play()
    TweenService:Create(eyeRing, TweenInfo.new(3, Enum.EasingStyle.Quart), {Size = Vector3.new(0.5, 145, 145), Transparency = 1}):Play()
    
    local origType = camera.CameraType
    camera.CameraType = Enum.CameraType.Scriptable
    
    local t0 = tick()
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        local dt = tick() - t0
        
        if dt < 1 then
            blur.Size = math.sin(dt * math.pi) * 25
            camera.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 8, 12), spherePos) * CFrame.Angles(math.noise(dt*150,0,0)*1.5, math.noise(0,dt*150,0)*1.5, 0)
            camera.FieldOfView = 70 - dt * 15
        else
            blur.Size = 0
            local orbitAngle = (dt - 1) * 0.6
            local camOffset = Vector3.new(math.cos(orbitAngle) * 14, 6, math.sin(orbitAngle) * 14)
            camera.CFrame = CFrame.lookAt(spherePos + camOffset, spherePos) * CFrame.Angles(math.noise(dt*80,0,0)*0.8, math.noise(0,dt*80,0)*0.8, 0)
            camera.FieldOfView = 55 + math.sin(dt * 5) * 5
        end
        
        whiteOrb.CFrame = CFrame.new(spherePos) * CFrame.Angles(dt * 4, dt * 7, 0) * CFrame.new(0, 0, 22 + math.sin(dt*3)*2)
        eyeRing.CFrame = CFrame.new(spherePos) * CFrame.Angles(dt * 0.4, dt * 0.2, math.rad(90))
        
        if dt > 5.5 then
            renderConn:Disconnect()
            camera.CameraType = origType
            camera.FieldOfView = 70
            domainFolder:Destroy()
            cc:Destroy()
            bloom:Destroy()
            blur:Destroy()
            ui:Destroy()
        end
    end)
end

local skills = {
    {Name="术式顺转·苍", Color=Color3.fromRGB(0,150,255), Func=castBlue},
    {Name="术式反转·赫", Color=Color3.fromRGB(255,50,50), Func=castRed},
    {Name="虚式·茈", Color=Color3.fromRGB(180,0,255), Func=castPurple},
    {Name="领域展开·无量空处", Color=Color3.fromRGB(200,220,255), Func=castDomain}
}

GojoSection:Button({Title="获取全套技能物品",Callback=function()
    local bp = player:WaitForChild("Backpack")
    for _, skill in ipairs(skills) do
        if not bp:FindFirstChild(skill.Name) and not (player.Character and player.Character:FindFirstChild(skill.Name)) then
            local tool = Instance.new("Tool")
            tool.Name = skill.Name
            tool.RequiresHandle = true
            tool.CanBeDropped = false
            
            local handle = Instance.new("Part")
            handle.Name = "Handle"  -- 这里是修复的关键！
            handle.Size = Vector3.new(1.5, 1.5, 1.5)
            handle.Shape = Enum.PartType.Ball
            handle.Color = skill.Color
            handle.Material = Enum.Material.Neon
            handle.Parent = tool
            
            local light = Instance.new("PointLight", handle)
            light.Color = skill.Color
            light.Range = 15
            light.Brightness = 3
            
            tool.Activated:Connect(function()
                if not isCasting then
                    isCasting = true
                    skill.Func()
                    task.delay(3.5, function() isCasting = false end)
                end
            end)
            tool.Parent = bp
        end
    end
    StarterGui:SetCore("SendNotification",{Title="获取成功",Text="已获得 苍、赫、茈、无量空处 卷轴",Duration=5})
end})

local SG=Instance.new("ScreenGui")SG.Name="PowerCrownUI"SG.ResetOnSpawn=false SG.IgnoreGuiInset=true
pcall(function()SG.Parent=game:GetService("CoreGui")end)if not SG.Parent then SG.Parent=player.PlayerGui end
local DataHUD=Instance.new("Frame")DataHUD.Size=UDim2.new(0,210,0,105)DataHUD.Position=UDim2.new(0,20,0.3,0)DataHUD.BackgroundColor3=Color3.fromRGB(20,24,34)DataHUD.BackgroundTransparency=0.1 DataHUD.BorderSizePixel=0 DataHUD.Active = true DataHUD.Parent=SG
local HUDTitle=Instance.new("TextLabel")HUDTitle.Size=UDim2.new(1,0,0,24)HUDTitle.BackgroundTransparency=1 HUDTitle.Text="📊 力量之冠 V1.1.1"HUDTitle.TextColor3=Color3.fromRGB(60,150,230)HUDTitle.Font=Enum.Font.GothamBold HUDTitle.TextSize=12 HUDTitle.Parent=DataHUD
local LabelReps=Instance.new("TextLabel")LabelReps.Size=UDim2.new(0.5,-10,0,18)LabelReps.Position=UDim2.new(0,10,0,30)LabelReps.BackgroundTransparency=1 LabelReps.Text="总训练: 0"LabelReps.TextColor3=Color3.fromRGB(230,230,235)LabelReps.Font=Enum.Font.Gotham LabelReps.TextSize=11 LabelReps.TextXAlignment=Enum.TextXAlignment.Left LabelReps.Parent=DataHUD

local dragging=false local dragInput,dragStart,startPos
DataHUD.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true dragStart=input.Position startPos=DataHUD.Position input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
DataHUD.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end end)
UserInputService.InputChanged:Connect(function(input) if input==dragInput and dragging then local delta=input.Position-dragStart DataHUD.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end)

task.spawn(function()
    local trainEvent 
    pcall(function() trainEvent=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TrainEvent") end)
    while SG.Parent do 
        task.wait(0.2)
        if Cfg.AutoTrain and trainEvent then 
            pcall(function()
                trainEvent:FireServer("Dumbbell")
                Cfg.TotalReps = Cfg.TotalReps + 1
                LabelReps.Text = "总训练: "..Cfg.TotalReps
            end)
        end 
    end 
end)