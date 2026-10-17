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

local function destroySafe(obj) pcall(function() obj:Destroy() end) end
for _, obj in pairs(game:GetService("CoreGui"):GetChildren()) do if obj.Name == "PowerCrownUI" or obj.Name == "WindUI" then destroySafe(obj) end end
for _, obj in pairs(player.PlayerGui:GetChildren()) do if obj.Name == "PowerCrownUI" or obj.Name == "WindUI" then destroySafe(obj) end end
for _, obj in pairs(Workspace:GetChildren()) do if obj.Name == "JujutsuOrb" or obj.Name == "DomainExpansion" or obj.Name == "CinematicFX" then destroySafe(obj) end end
for _, eff in pairs(Lighting:GetChildren()) do if eff:IsA("BloomEffect") or eff:IsA("ColorCorrectionEffect") or eff:IsA("BlurEffect") then destroySafe(eff) end end

local success,WindUI=pcall(function() return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))() end)
if not success or not WindUI then StarterGui:SetCore("SendNotification",{Title="UI加载失败",Text="网络拦截",Duration=10}) return end

local Window=WindUI:CreateWindow({Title="力量之冠 V1.2 电影级",Icon="zap",Author="力量之冠",Folder="PowerCrownSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(460,780)})
local FunTab=Window:Tab({Title="五条悟专属",Icon="sparkles"})
local GojoSection=FunTab:Section({Title="全套技能获取",Icon="zap"})

local isCasting = false

local function playInkCalligraphy(textStr, yPos, size, delayTime, duration)
    task.delay(delayTime, function()
        local gui = Instance.new("ScreenGui", player.PlayerGui)
        gui.Name = "InkGui"; gui.IgnoreGuiInset = true; gui.DisplayOrder = 100
        
        local lbl = Instance.new("TextLabel", gui)
        lbl.Text = textStr
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        lbl.Size = UDim2.fromOffset(size * #textStr * 1.1, size * 1.4)
        lbl.Position = UDim2.new(0.5, 0, yPos, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
        lbl.Font = Enum.Font.Arcade
        lbl.TextSize = size
        lbl.TextTransparency = 1
        lbl.TextStrokeColor3 = Color3.fromRGB(15, 15, 20)
        lbl.TextStrokeTransparency = 1
        
        local seal = Instance.new("TextLabel", gui)
        seal.Text = "五条"
        seal.AnchorPoint = Vector2.new(1, 0)
        seal.Size = UDim2.fromOffset(size * 0.9, size * 1.3)
        seal.Position = UDim2.new(0.5, size * #textStr * 0.48, yPos + size * 0.5, 0)
        seal.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
        seal.TextColor3 = Color3.fromRGB(240, 220, 200)
        seal.Font = Enum.Font.Arcade
        seal.TextSize = size * 0.5
        seal.TextTransparency = 1
        
        TweenService:Create(lbl, TweenInfo.new(0.2, Enum.EasingStyle.Back), {TextTransparency = 0, TextStrokeTransparency = 0.1}):Play()
        TweenService:Create(seal, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
        
        task.delay(duration or 3, function()
            TweenService:Create(lbl, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
            TweenService:Create(seal, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            Debris:AddItem(gui, 0.6)
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
        local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back)
        if pose == "Right" then
            TweenService:Create(rShoulder, tInfo, {C0 = origR * CFrame.Angles(math.rad(-90), 0, 0)}):Play()
        elseif pose == "Left" then
            TweenService:Create(lShoulder, tInfo, {C0 = origL * CFrame.Angles(math.rad(-90), 0, 0)}):Play()
        elseif pose == "Both" then
            TweenService:Create(lShoulder, tInfo, {C0 = origL * CFrame.Angles(math.rad(-75), math.rad(25), math.rad(-15))}):Play()
            TweenService:Create(rShoulder, tInfo, {C0 = origR * CFrame.Angles(math.rad(-75), math.rad(-25), math.rad(15))}):Play()
        end
        task.delay(4, function()
            if lShoulder and rShoulder then
                TweenService:Create(lShoulder, TweenInfo.new(0.5), {C0 = origL}):Play()
                TweenService:Create(rShoulder, TweenInfo.new(0.5), {C0 = origR}):Play()
            end
        end)
    end
end

local function createComplexOrb(char, baseColor, glowColor)
    local hrp = char.HumanoidRootPart
    local folder = Instance.new("Folder", Workspace); folder.Name = "JujutsuOrb"
    
    local core = Instance.new("Part", folder)
    core.Shape = Enum.PartType.Ball; core.Size = Vector3.new(2.5, 2.5, 2.5)
    core.Material = Enum.Material.Neon; core.Color = Color3.new(1,1,1)
    core.Anchored = true; core.CanCollide = false
    
    local shell = Instance.new("Part", folder)
    shell.Shape = Enum.PartType.Ball; shell.Size = Vector3.new(4.5, 4.5, 4.5)
    shell.Material = Enum.Material.ForceField; shell.Color = baseColor
    shell.Transparency = 0.2; shell.Anchored = true; shell.CanCollide = false
    
    local halo = Instance.new("Part", folder)
    halo.Shape = Enum.PartType.Ball; halo.Size = Vector3.new(8, 8, 8)
    halo.Material = Enum.Material.Neon; halo.Color = glowColor
    halo.Transparency = 0.85; halo.Anchored = true; halo.CanCollide = false
    
    local light = Instance.new("PointLight", core)
    light.Color = glowColor; light.Range = 35; light.Brightness = 15
    
    local emitter = Instance.new("ParticleEmitter", core)
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Color = ColorSequence.new(glowColor, Color3.new(1,1,1))
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 4), NumberSequenceKeypoint.new(1, 0)})
    emitter.Speed = NumberRange.new(50, 120); emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Rate = 500; emitter.LightEmission = 1
    
    local att0 = Instance.new("Attachment", core); att0.Position = Vector3.new(0, 1.5, 0)
    local att1 = Instance.new("Attachment", core); att1.Position = Vector3.new(0, -1.5, 0)
    local trail = Instance.new("Trail", core)
    trail.Attachment0 = att0; trail.Attachment1 = att1
    trail.Color = ColorSequence.new(glowColor, Color3.new(1,1,1))
    trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)})
    trail.Lifetime = 0.8; trail.MinLength = 0.1; trail.LightEmission = 1
    
    return folder, core, shell, halo
end

local function castBlue()
    local char = player.Character
    if not char then return end
    controlArms(char, "Right")
    playInkCalligraphy("术式顺转", 0.4, 50, 0, 2)
    playInkCalligraphy("苍", 0.5, 150, 0.5, 2)
    
    local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Intensity = 3; bloom.Size = 40; bloom.Threshold = 0.7
    Debris:AddItem(bloom, 5)
    
    local folder, core, shell, halo = createComplexOrb(char, Color3.fromRGB(0, 100, 255), Color3.fromRGB(100, 200, 255))
    local hrp = char.HumanoidRootPart
    
    local t0 = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local dt = tick() - t0
        local basePos = hrp.CFrame * CFrame.new(0, 2, -4) + hrp.CFrame.LookVector * (dt * 2)
        core.CFrame = basePos; shell.CFrame = basePos; halo.CFrame = basePos
        if dt > 1.5 then
            conn:Disconnect()
            core.Anchored = false; shell.Anchored = false; halo.Anchored = false
            local bv = Instance.new("BodyVelocity", core); bv.Velocity = camera.CFrame.LookVector * 250; bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            local bvShell = Instance.new("BodyVelocity", shell); bvShell.Velocity = camera.CFrame.LookVector * 250; bvShell.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            local bvHalo = Instance.new("BodyVelocity", halo); bvHalo.Velocity = camera.CFrame.LookVector * 250; bvHalo.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            
            local hit = false
            core.Touched:Connect(function(h)
                if h:IsDescendantOf(char) or hit then return end
                hit = true
                bv:Destroy(); bvShell:Destroy(); bvHalo:Destroy()
                
                local cc = Instance.new("ColorCorrectionEffect", Lighting); cc.TintColor = Color3.fromRGB(200, 220, 255); cc.Contrast = 0.3
                local boom = Instance.new("Part", Workspace)
                boom.Shape = Enum.PartType.Ball; boom.Material = Enum.Material.Neon; boom.Color = Color3.fromRGB(100, 200, 255)
                boom.Size = Vector3.new(5,5,5); boom.Anchored = true; boom.CanCollide = false; boom.Position = core.Position
                TweenService:Create(boom, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Size = Vector3.new(80,80,80), Transparency = 1}):Play()
                TweenService:Create(cc, TweenInfo.new(0.8), {TintColor = Color3.new(1,1,1), Contrast = 0}):Play()
                Debris:AddItem(cc, 1)
                task.wait(1)
                folder:Destroy(); boom:Destroy()
            end)
            Debris:AddItem(folder, 4)
        end
    end)
end

local function castRed()
    local char = player.Character
    if not char then return end
    controlArms(char, "Left")
    playInkCalligraphy("术式反转", 0.4, 50, 0, 2)
    playInkCalligraphy("赫", 0.5, 150, 0.5, 2)
    
    local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Intensity = 3; bloom.Size = 40; bloom.Threshold = 0.7
    Debris:AddItem(bloom, 5)
    
    local folder, core, shell, halo = createComplexOrb(char, Color3.fromRGB(255, 20, 20), Color3.fromRGB(255, 100, 100))
    local hrp = char.HumanoidRootPart
    
    local t0 = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local dt = tick() - t0
        local basePos = hrp.CFrame * CFrame.new(0, 2, -4) + hrp.CFrame.LookVector * (dt * 2)
        core.CFrame = basePos; shell.CFrame = basePos; halo.CFrame = basePos
        if dt > 1.5 then
            conn:Disconnect()
            core.Anchored = false; shell.Anchored = false; halo.Anchored = false
            local bv = Instance.new("BodyVelocity", core); bv.Velocity = camera.CFrame.LookVector * 300; bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            local bvShell = Instance.new("BodyVelocity", shell); bvShell.Velocity = camera.CFrame.LookVector * 300; bvShell.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            local bvHalo = Instance.new("BodyVelocity", halo); bvHalo.Velocity = camera.CFrame.LookVector * 300; bvHalo.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            
            local hit = false
            core.Touched:Connect(function(h)
                if h:IsDescendantOf(char) or hit then return end
                hit = true
                bv:Destroy(); bvShell:Destroy(); bvHalo:Destroy()
                
                local cc = Instance.new("ColorCorrectionEffect", Lighting); cc.TintColor = Color3.fromRGB(255, 180, 180); cc.Contrast = 0.5
                local boom = Instance.new("Part", Workspace)
                boom.Shape = Enum.PartType.Ball; boom.Material = Enum.Material.Neon; boom.Color = Color3.fromRGB(255, 80, 80)
                boom.Size = Vector3.new(5,5,5); boom.Anchored = true; boom.CanCollide = false; boom.Position = core.Position
                TweenService:Create(boom, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Size = Vector3.new(100,100,100), Transparency = 1}):Play()
                TweenService:Create(cc, TweenInfo.new(0.8), {TintColor = Color3.new(1,1,1), Contrast = 0}):Play()
                Debris:AddItem(cc, 1)
                task.wait(1)
                folder:Destroy(); boom:Destroy()
            end)
            Debris:AddItem(folder, 4)
        end
    end)
end

local function castPurple()
    local char = player.Character
    if not char then return end
    controlArms(char, "Both")
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting); cc.TintColor = Color3.fromRGB(200, 150, 255)
    local bloom = Instance.new("BloomEffect", Lighting); bloom.Intensity = 4; bloom.Size = 50; bloom.Threshold = 0.6
    
    local hrp = char.HumanoidRootPart
    local bFolder, bCore, bShell, bHalo = createComplexOrb(char, Color3.fromRGB(0, 150, 255), Color3.fromRGB(100, 200, 255))
    local rFolder, rCore, rShell, rHalo = createComplexOrb(char, Color3.fromRGB(255, 30, 30), Color3.fromRGB(255, 100, 100))
    
    local startCenter = hrp.CFrame * CFrame.new(0, 2, -6)
    bCore.Position = startCenter.Position + hrp.CFrame.RightVector * -5
    bShell.Position = bCore.Position; bHalo.Position = bCore.Position
    rCore.Position = startCenter.Position + hrp.CFrame.RightVector * 5
    rShell.Position = rCore.Position; rHalo.Position = rCore.Position
    
    playInkCalligraphy("术式顺转", 0.25, 40, 0, 2)
    playInkCalligraphy("术式反转", 0.35, 40, 1, 2)
    playInkCalligraphy("苍", 0.2, 80, 0, 2)
    playInkCalligraphy("赫", 0.3, 80, 1, 2)
    
    local t0 = tick()
    local fuseConn
    fuseConn = RunService.RenderStepped:Connect(function()
        local dt = tick() - t0
        local ease = math.min(dt / 1.5, 1)
        bCore.CFrame = startCenter * CFrame.new(-5 + ease * 5, 0, 0)
        bShell.CFrame = bCore.CFrame; bHalo.CFrame = bCore.CFrame
        rCore.CFrame = startCenter * CFrame.new(5 - ease * 5, 0, 0)
        rShell.CFrame = rCore.CFrame; rHalo.CFrame = rCore.CFrame
        if dt > 1.5 then fuseConn:Disconnect() end
    end)
    
    task.wait(1.5)
    playInkCalligraphy("虚式·茈", 0.5, 150, 0, 4)
    
    bCore.Transparency = 1; bShell.Transparency = 1; bHalo.Transparency = 1
    rCore.Transparency = 1; rShell.Transparency = 1; rHalo.Transparency = 1
    bFolder:Destroy(); rFolder:Destroy()
    
    local corePos = startCenter.Position
    local pCore = Instance.new("Part", Workspace)
    pCore.Shape = Enum.PartType.Ball; pCore.Size = Vector3.new(1,1,1); pCore.Material = Enum.Material.Neon; pCore.Color = Color3.fromRGB(255, 255, 255)
    pCore.Anchored = true; pCore.CanCollide = false; pCore.Position = corePos
    
    local pLight = Instance.new("PointLight", pCore); pLight.Color = Color3.fromRGB(200, 0, 255); pLight.Brightness = 40; pLight.Range = 100
    
    TweenService:Create(pCore, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {Size = Vector3.new(25,25,25), Color = Color3.fromRGB(180, 0, 255)}):Play()
    task.wait(0.6)
    
    local beam = Instance.new("Part", Workspace)
    beam.Material = Enum.Material.Neon; beam.Color = Color3.fromRGB(180, 0, 255)
    beam.Anchored = true; beam.CanCollide = false
    beam.Size = Vector3.new(30, 30, 600)
    beam.CFrame = CFrame.lookAt(corePos, corePos + camera.CFrame.LookVector) * CFrame.Angles(math.rad(-90), 0, 0)
    
    local innerBeam = Instance.new("Part", Workspace)
    innerBeam.Material = Enum.Material.Neon; innerBeam.Color = Color3.new(1,1,1)
    innerBeam.Anchored = true; innerBeam.CanCollide = false
    innerBeam.Size = Vector3.new(15, 15, 600); innerBeam.CFrame = beam.CFrame
    
    local emit = Instance.new("ParticleEmitter", beam)
    emit.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emit.Color = ColorSequence.new(Color3.fromRGB(180,0,255), Color3.new(1,1,1))
    emit.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 0)})
    emit.Speed = NumberRange.new(200, 500); emit.SpreadAngle = Vector2.new(15, 15); emit.Rate = 2000
    
    local shakeT0 = tick()
    local shakeConn
    shakeConn = RunService.RenderStepped:Connect(function()
        local dt = tick() - shakeT0
        camera.CFrame = camera.CFrame * CFrame.Angles(math.noise(dt*150,0,0)*0.02, math.noise(0,dt*150,0)*0.02, 0)
        if dt > 2 then shakeConn:Disconnect() end
    end)
    
    TweenService:Create(beam, TweenInfo.new(2), {Transparency = 1}):Play()
    TweenService:Create(innerBeam, TweenInfo.new(2), {Transparency = 1}):Play()
    TweenService:Create(pCore, TweenInfo.new(2), {Transparency = 1}):Play()
    TweenService:Create(cc, TweenInfo.new(2), {TintColor = Color3.new(1,1,1)}):Play()
    
    task.wait(3)
    cc:Destroy(); bloom:Destroy(); beam:Destroy(); innerBeam:Destroy(); pCore:Destroy()
end

local function castDomain()
    local char = player.Character
    if not char then return end
    controlArms(char, "Both")
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Saturation = -1; cc.Contrast = 2; cc.Brightness = -0.1; cc.TintColor = Color3.fromRGB(220, 240, 255)
    
    local bloom = Instance.new("BloomEffect", Lighting); bloom.Intensity = 4; bloom.Size = 50; bloom.Threshold = 0.6
    local blur = Instance.new("BlurEffect", Lighting); blur.Size = 0
    
    playInkCalligraphy("领域展开", 0.2, 100, 0, 3)
    playInkCalligraphy("“无量空处”", 0.7, 180, 1.5, 6)
    
    local hrp = char.HumanoidRootPart
    local folder = Instance.new("Folder", Workspace); folder.Name = "DomainExpansion"
    
    local pos = hrp.Position + hrp.CFrame.LookVector * 20
    
    local void = Instance.new("Part", folder)
    void.Shape = Enum.PartType.Ball; void.Size = Vector3.new(10,10,10)
    void.Material = Enum.Material.SmoothPlastic; void.Color = Color3.fromRGB(2, 2, 5)
    void.Anchored = true; void.CanCollide = false; void.CFrame = CFrame.new(pos)
    
    local ring1 = Instance.new("Part", folder)
    ring1.Shape = Enum.PartType.Cylinder; ring1.Size = Vector3.new(1, 14, 14)
    ring1.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
    ring1.Material = Enum.Material.ForceField; ring1.Color = Color3.new(1,1,1)
    ring1.Transparency = 0.1; ring1.Anchored = true; ring1.CanCollide = false
    
    local inkEmit = Instance.new("ParticleEmitter", ring1)
    inkEmit.Texture = "rbxasset://textures/particles/smoke_main.dds"
    inkEmit.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(100, 150, 255))
    inkEmit.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 35), NumberSequenceKeypoint.new(1, 0)})
    inkEmit.Speed = NumberRange.new(100, 200); inkEmit.SpreadAngle = Vector2.new(180, 180)
    inkEmit.Rate = 800; inkEmit.LightEmission = 1
    
    local orb = Instance.new("Part", folder)
    orb.Shape = Enum.PartType.Ball; orb.Size = Vector3.new(3, 3, 3)
    orb.Material = Enum.Material.Neon; orb.Color = Color3.new(1,1,1)
    orb.Anchored = true; orb.CanCollide = false; orb.CFrame = CFrame.new(pos)
    
    local light = Instance.new("PointLight", orb)
    light.Color = Color3.new(1,1,1); light.Brightness = 30; light.Range = 50
    
    TweenService:Create(void, TweenInfo.new(4, Enum.EasingStyle.Quad), {Size = Vector3.new(150, 150, 150)}):Play()
    TweenService:Create(ring1, TweenInfo.new(4, Enum.EasingStyle.Quad), {Size = Vector3.new(1, 170, 170), Transparency = 1}):Play()
    
    local origType = camera.CameraType
    camera.CameraType = Enum.CameraType.Scriptable
    
    local t0 = tick()
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        local dt = tick() - t0
        
        if dt < 2 then
            blur.Size = math.sin((dt / 2) * math.pi) * 30
            camera.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 10, 15), pos)
            camera.FieldOfView = 70 - (dt / 2) * 20
        else
            blur.Size = 0
            local orbit = (dt - 2) * 0.3
            local offset = Vector3.new(math.cos(orbit) * 25, 8, math.sin(orbit) * 25)
            camera.CFrame = CFrame.lookAt(pos + offset, pos)
            camera.FieldOfView = 50 + math.sin(dt * 2) * 5
        end
        
        orb.CFrame = CFrame.new(pos) * CFrame.Angles(dt * 2, dt * 4, 0) * CFrame.new(0, 0, 35)
        ring1.CFrame = CFrame.new(pos) * CFrame.Angles(dt * 0.1, dt * 0.15, math.rad(90))
        
        if dt > 8 then
            renderConn:Disconnect()
            camera.CameraType = origType; camera.FieldOfView = 70
            folder:Destroy(); cc:Destroy(); bloom:Destroy(); blur:Destroy()
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
            tool.Name = skill.Name; tool.RequiresHandle = true; tool.CanBeDropped = false
            
            local handle = Instance.new("Part")
            handle.Name = "Handle"; handle.Size = Vector3.new(1.5, 1.5, 1.5); handle.Shape = Enum.PartType.Ball
            handle.Color = skill.Color; handle.Material = Enum.Material.Neon; handle.Parent = tool
            
            local light = Instance.new("PointLight", handle)
            light.Color = skill.Color; light.Range = 15; light.Brightness = 3
            
            tool.Activated:Connect(function()
                if not isCasting then
                    isCasting = true
                    skill.Func()
                    task.delay(6, function() isCasting = false end)
                end
            end)
            tool.Parent = bp
        end
    end
    StarterGui:SetCore("SendNotification",{Title="获取成功",Text="已获得全套技能",Duration=5})
end})

local SG=Instance.new("ScreenGui")SG.Name="PowerCrownUI"SG.ResetOnSpawn=false SG.IgnoreGuiInset=true
pcall(function()SG.Parent=game:GetService("CoreGui")end)if not SG.Parent then SG.Parent=player.PlayerGui end
local DataHUD=Instance.new("Frame")DataHUD.Size=UDim2.new(0,210,0,105)DataHUD.Position=UDim2.new(0,20,0.3,0)DataHUD.BackgroundColor3=Color3.fromRGB(20,24,34)DataHUD.BackgroundTransparency=0.1 DataHUD.BorderSizePixel=0 DataHUD.Active = true DataHUD.Parent=SG
local HUDTitle=Instance.new("TextLabel")HUDTitle.Size=UDim2.new(1,0,0,24)HUDTitle.BackgroundTransparency=1 HUDTitle.Text="📊 力量之冠 V1.2"HUDTitle.TextColor3=Color3.fromRGB(60,150,230)HUDTitle.Font=Enum.Font.GothamBold HUDTitle.TextSize=12 HUDTitle.Parent=DataHUD
local LabelReps=Instance.new("TextLabel")LabelReps.Size=UDim2.new(0.5,-10,0,18)LabelReps.Position=UDim2.new(0,10,0,30)LabelReps.BackgroundTransparency=1 LabelReps.Text="总训练: 0"LabelReps.TextColor3=Color3.fromRGB(230,230,235)LabelReps.Font=Enum.Font.Gotham LabelReps.TextSize=11 LabelReps.TextXAlignment=Enum.TextXAlignment.Left LabelReps.Parent=DataHUD

local dragging=false local dragInput,dragStart,startPos
DataHUD.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true dragStart=input.Position startPos=DataHUD.Position input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
DataHUD.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end end)
UserInputService.InputChanged:Connect(function(input) if input==dragInput and dragging then local delta=input.Position-dragStart DataHUD.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end)