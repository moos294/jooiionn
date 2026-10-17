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

local Window=WindUI:CreateWindow({Title="力量之冠 V1.3 电影级真神版",Icon="zap",Author="力量之冠",Folder="PowerCrownSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(460,780)})
local FunTab=Window:Tab({Title="五条悟专属",Icon="sparkles"})
local GojoSection=FunTab:Section({Title="全套技能获取",Icon="zap"})

local isCasting = false

local function playInkText(textStr, yPos, size, delayTime, duration)
    task.delay(delayTime, function()
        local gui = Instance.new("ScreenGui", player.PlayerGui)
        gui.Name = "InkGui"; gui.IgnoreGuiInset = true; gui.DisplayOrder = 100
        
        local lbl = Instance.new("TextLabel", gui)
        lbl.Text = textStr
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        lbl.Size = UDim2.fromOffset(1000, size * 2)
        lbl.Position = UDim2.new(0.5, 0, yPos, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = size
        lbl.TextTransparency = 1
        lbl.ZIndex = 100
        
        local stroke = Instance.new("UIStroke", lbl)
        stroke.Color = Color3.fromRGB(0, 0, 0)
        stroke.Thickness = 4
        stroke.Transparency = 1
        
        TweenService:Create(lbl, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {TextTransparency = 0}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
        
        task.delay(duration or 2, function()
            TweenService:Create(lbl, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
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
        local tInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back)
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

local function createCinematicOrb(char, color, isPurple)
    local folder = Instance.new("Folder", Workspace); folder.Name = "CinematicFX"
    local core = Instance.new("Part", folder)
    core.Shape = Enum.PartType.Ball; core.Size = Vector3.new(1,1,1); core.Color = Color3.new(1,1,1); core.Material = Enum.Material.Neon
    core.Anchored = true; core.CanCollide = false; core.CanQuery = false
    
    local glow = Instance.new("Part", folder)
    glow.Shape = Enum.PartType.Ball; glow.Size = Vector3.new(2,2,2); glow.Color = color; glow.Material = Enum.Material.ForceField
    glow.Transparency = 0.3; glow.Anchored = true; glow.CanCollide = false; glow.CanQuery = false
    
    local light = Instance.new("PointLight", core)
    light.Color = color; light.Brightness = 10; light.Range = 20
    
    local emitter = Instance.new("ParticleEmitter", core)
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Color = ColorSequence.new(color, Color3.new(1,1,1))
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
    emitter.Speed = NumberRange.new(10, 30); emitter.Rate = 100; emitter.LightEmission = 1
    
    return folder, core, glow
end

local function castBlue()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    controlArms(char, "Right")
    playInkText("术式顺转 · 苍", 0.2, 60, 0, 1.5)
    
    local bloom = Instance.new("BloomEffect", Lighting); bloom.Intensity = 1.5; bloom.Size = 20; bloom.Threshold = 0.9
    Debris:AddItem(bloom, 5)
    
    local folder, core, glow = createCinematicOrb(char, Color3.fromRGB(0, 150, 255))
    local hrp = char.HumanoidRootPart
    local startPos = hrp.CFrame * CFrame.new(1, 2, -3)
    core.Position = startPos.Position; glow.Position = startPos.Position
    
    task.wait(0.8)
    
    core.Anchored = false; glow.Anchored = false
    local bv = Instance.new("BodyVelocity", core); bv.Velocity = camera.CFrame.LookVector * 120; bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    local bvG = Instance.new("BodyVelocity", glow); bvG.Velocity = camera.CFrame.LookVector * 120; bvG.MaxForce = Vector3.new(1e5,1e5,1e5)
    
    local hit = false
    core.Touched:Connect(function(h)
        if h:IsDescendantOf(char) or hit then return end
        hit = true
        bv:Destroy(); bvG:Destroy()
        local boom = Instance.new("Part", Workspace); boom.Shape = Enum.PartType.Ball
        boom.Material = Enum.Material.Neon; boom.Color = Color3.fromRGB(0, 150, 255)
        boom.Size = Vector3.new(2,2,2); boom.Anchored = true; boom.CanCollide = false; boom.Position = core.Position
        TweenService:Create(boom, TweenInfo.new(0.4), {Size = Vector3.new(30,30,30), Transparency = 1}):Play()
        Debris:AddItem(boom, 0.5)
        folder:Destroy()
    end)
    Debris:AddItem(folder, 3)
end

local function castRed()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    controlArms(char, "Left")
    playInkText("术式反转 · 赫", 0.2, 60, 0, 1.5)
    
    local bloom = Instance.new("BloomEffect", Lighting); bloom.Intensity = 1.5; bloom.Size = 20; bloom.Threshold = 0.9
    Debris:AddItem(bloom, 5)
    
    local folder, core, glow = createCinematicOrb(char, Color3.fromRGB(255, 30, 30))
    local hrp = char.HumanoidRootPart
    local startPos = hrp.CFrame * CFrame.new(1, 2, -3)
    core.Position = startPos.Position; glow.Position = startPos.Position
    
    task.wait(0.8)
    
    core.Anchored = false; glow.Anchored = false
    local bv = Instance.new("BodyVelocity", core); bv.Velocity = camera.CFrame.LookVector * 150; bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    local bvG = Instance.new("BodyVelocity", glow); bvG.Velocity = camera.CFrame.LookVector * 150; bvG.MaxForce = Vector3.new(1e5,1e5,1e5)
    
    local hit = false
    core.Touched:Connect(function(h)
        if h:IsDescendantOf(char) or hit then return end
        hit = true
        bv:Destroy(); bvG:Destroy()
        local boom = Instance.new("Part", Workspace); boom.Shape = Enum.PartType.Ball
        boom.Material = Enum.Material.Neon; boom.Color = Color3.fromRGB(255, 30, 30)
        boom.Size = Vector3.new(2,2,2); boom.Anchored = true; boom.CanCollide = false; boom.Position = core.Position
        TweenService:Create(boom, TweenInfo.new(0.4), {Size = Vector3.new(40,40,40), Transparency = 1}):Play()
        Debris:AddItem(boom, 0.5)
        folder:Destroy()
    end)
    Debris:AddItem(folder, 3)
end

local function castPurple()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    controlArms(char, "Both")
    
    playInkText("术式顺转", 0.15, 40, 0, 2)
    playInkText("术式反转", 0.25, 40, 0.5, 2)
    playInkText("苍", 0.15, 80, 0, 2)
    playInkText("赫", 0.25, 80, 0.5, 2)
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting); cc.TintColor = Color3.fromRGB(200, 180, 255)
    local bloom = Instance.new("BloomEffect", Lighting); bloom.Intensity = 2; bloom.Size = 30; bloom.Threshold = 0.8
    
    local hrp = char.HumanoidRootPart
    local bF, bC, bG = createCinematicOrb(char, Color3.fromRGB(0, 150, 255))
    local rF, rC, rG = createCinematicOrb(char, Color3.fromRGB(255, 30, 30))
    
    local center = hrp.CFrame * CFrame.new(0, 2, -6)
    bC.Position = center.Position + hrp.CFrame.RightVector * -4; bG.Position = bC.Position
    rC.Position = center.Position + hrp.CFrame.RightVector * 4; rG.Position = rC.Position
    
    local t0 = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local dt = tick() - t0
        local ease = math.min(dt / 1.5, 1)
        bC.CFrame = center * CFrame.new(-4 + ease * 4, 0, 0); bG.CFrame = bC.CFrame
        rC.CFrame = center * CFrame.new(4 - ease * 4, 0, 0); rG.CFrame = rC.CFrame
        if dt > 1.5 then conn:Disconnect() end
    end)
    task.wait(1.5)
    
    playInkText("虚式 · 茈", 0.5, 100, 0, 3)
    bF:Destroy(); rF:Destroy()
    
    local corePos = center.Position
    local pCore = Instance.new("Part", Workspace)
    pCore.Shape = Enum.PartType.Ball; pCore.Size = Vector3.new(1,1,1); pCore.Material = Enum.Material.Neon; pCore.Color = Color3.fromRGB(255, 255, 255)
    pCore.Anchored = true; pCore.CanCollide = false; pCore.Position = corePos
    
    local pLight = Instance.new("PointLight", pCore); pLight.Color = Color3.fromRGB(180, 0, 255); pLight.Brightness = 30; pLight.Range = 40
    TweenService:Create(pCore, TweenInfo.new(0.5), {Size = Vector3.new(10,10,10), Color = Color3.fromRGB(180, 0, 255)}):Play()
    task.wait(0.5)
    
    local beam = Instance.new("Part", Workspace)
    beam.Material = Enum.Material.Neon; beam.Color = Color3.fromRGB(180, 0, 255)
    beam.Anchored = true; beam.CanCollide = false
    beam.Size = Vector3.new(10, 10, 200)
    beam.CFrame = CFrame.lookAt(corePos, corePos + camera.CFrame.LookVector) * CFrame.Angles(math.rad(-90), 0, 0)
    
    local inner = Instance.new("Part", Workspace)
    inner.Material = Enum.Material.Neon; inner.Color = Color3.new(1,1,1)
    inner.Anchored = true; inner.CanCollide = false
    inner.Size = Vector3.new(4, 4, 200); inner.CFrame = beam.CFrame
    
    local shakeT0 = tick()
    local shakeConn
    shakeConn = RunService.RenderStepped:Connect(function()
        local dt = tick() - shakeT0
        camera.CFrame = camera.CFrame * CFrame.Angles(math.noise(dt*100,0,0)*0.02, math.noise(0,dt*100,0)*0.02, 0)
        if dt > 1.5 then shakeConn:Disconnect() end
    end)
    
    TweenService:Create(beam, TweenInfo.new(1.5), {Transparency = 1}):Play()
    TweenService:Create(inner, TweenInfo.new(1.5), {Transparency = 1}):Play()
    TweenService:Create(pCore, TweenInfo.new(1.5), {Transparency = 1}):Play()
    TweenService:Create(cc, TweenInfo.new(1.5), {TintColor = Color3.new(1,1,1)}):Play()
    
    task.wait(2)
    cc:Destroy(); bloom:Destroy(); beam:Destroy(); inner:Destroy(); pCore:Destroy()
end

local function castDomain()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    controlArms(char, "Both")
    
    playInkText("领域展开", 0.2, 80, 0, 3)
    playInkText("“无量空处”", 0.7, 120, 1.5, 6)
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Saturation = -1; cc.Contrast = 2.5; cc.Brightness = -0.1; cc.TintColor = Color3.fromRGB(220, 240, 255)
    
    local bloom = Instance.new("BloomEffect", Lighting); bloom.Intensity = 3; bloom.Size = 40; bloom.Threshold = 0.6
    local blur = Instance.new("BlurEffect", Lighting); blur.Size = 0
    
    local hrp = char.HumanoidRootPart
    local folder = Instance.new("Folder", Workspace); folder.Name = "DomainFX"
    local pos = hrp.Position + hrp.CFrame.LookVector * 18 + Vector3.new(0, 4, 0)
    
    -- 核心：深邃无底的黑洞
    local void = Instance.new("Part", folder)
    void.Shape = Enum.PartType.Ball; void.Size = Vector3.new(10, 10, 10)
    void.Material = Enum.Material.SmoothPlastic; void.Color = Color3.fromRGB(2, 2, 5)
    void.Anchored = true; void.CanCollide = false; void.CFrame = CFrame.new(pos)
    
    -- 边缘不规则撕裂光环（用多层厚度不同的圆柱体叠加模拟水墨感）
    local ring1 = Instance.new("Part", folder)
    ring1.Shape = Enum.PartType.Cylinder; ring1.Size = Vector3.new(1.5, 14, 14)
    ring1.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
    ring1.Material = Enum.Material.Neon; ring1.Color = Color3.new(1, 1, 1)
    ring1.Transparency = 0.1; ring1.Anchored = true; ring1.CanCollide = false
    
    local ring2 = Instance.new("Part", folder)
    ring2.Shape = Enum.PartType.Cylinder; ring2.Size = Vector3.new(1, 16, 16)
    ring2.CFrame = ring1.CFrame * CFrame.Angles(math.rad(5), math.rad(5), 0)
    ring2.Material = Enum.Material.Neon; ring2.Color = Color3.new(1, 1, 1)
    ring2.Transparency = 0.4; ring2.Anchored = true; ring2.CanCollide = false
    
    -- 飞溅的墨汁粒子
    local inkEmit = Instance.new("ParticleEmitter", ring1)
    inkEmit.Texture = "rbxasset://textures/particles/smoke_main.dds"
    inkEmit.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromRGB(150, 180, 255))
    inkEmit.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 8), NumberSequenceKeypoint.new(1, 0)})
    inkEmit.Speed = NumberRange.new(40, 80); inkEmit.SpreadAngle = Vector2.new(180, 180)
    inkEmit.Rate = 300; inkEmit.LightEmission = 1
    
    -- 黑洞中悬浮的小球
    local orb = Instance.new("Part", folder)
    orb.Shape = Enum.PartType.Ball; orb.Size = Vector3.new(1.5, 1.5, 1.5)
    orb.Material = Enum.Material.Neon; orb.Color = Color3.new(1, 1, 1)
    orb.Anchored = true; orb.CanCollide = false; orb.CFrame = CFrame.new(pos)
    local oLight = Instance.new("PointLight", orb); oLight.Color = Color3.new(1,1,1); oLight.Brightness = 10; oLight.Range = 20
    
    -- 极其缓慢的膨胀，保证不糊脸
    TweenService:Create(void, TweenInfo.new(5, Enum.EasingStyle.Quart), {Size = Vector3.new(80, 80, 80)}):Play()
    TweenService:Create(ring1, TweenInfo.new(5, Enum.EasingStyle.Quart), {Size = Vector3.new(1.5, 95, 95), Transparency = 1}):Play()
    TweenService:Create(ring2, TweenInfo.new(5, Enum.EasingStyle.Quart), {Size = Vector3.new(1, 110, 110), Transparency = 1}):Play()
    
    local origType = camera.CameraType
    camera.CameraType = Enum.CameraType.Scriptable
    
    local t0 = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local dt = tick() - t0
        
        -- 缓慢的电影级运镜
        if dt < 2 then
            blur.Size = math.sin((dt / 2) * math.pi) * 15
            camera.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 8, 15), pos)
            camera.FieldOfView = 70 - (dt / 2) * 10
        else
            blur.Size = 0
            local orbit = (dt - 2) * 0.2
            local offset = Vector3.new(math.cos(orbit) * 20, 5, math.sin(orbit) * 20)
            camera.CFrame = CFrame.lookAt(pos + offset, pos)
            camera.FieldOfView = 60
        end
        
        orb.CFrame = CFrame.new(pos) * CFrame.Angles(dt * 1.5, dt * 2, 0) * CFrame.new(0, 0, 20)
        ring1.CFrame = CFrame.new(pos) * CFrame.Angles(dt * 0.2, dt * 0.1, math.rad(90))
        ring2.CFrame = CFrame.new(pos) * CFrame.Angles(dt * 0.1, dt * 0.3, math.rad(90)) * CFrame.Angles(math.rad(5), math.rad(5), 0)
        
        if dt > 10 then
            conn:Disconnect()
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
            handle.Name = "Handle"; handle.Size = Vector3.new(1,1,1); handle.Shape = Enum.PartType.Ball
            handle.Color = skill.Color; handle.Material = Enum.Material.Neon; handle.Parent = tool
            
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
local HUDTitle=Instance.new("TextLabel")HUDTitle.Size=UDim2.new(1,0,0,24)HUDTitle.BackgroundTransparency=1 HUDTitle.Text="📊 力量之冠 V1.3"HUDTitle.TextColor3=Color3.fromRGB(60,150,230)HUDTitle.Font=Enum.Font.GothamBold HUDTitle.TextSize=12 HUDTitle.Parent=DataHUD
local LabelReps=Instance.new("TextLabel")LabelReps.Size=UDim2.new(0.5,-10,0,18)LabelReps.Position=UDim2.new(0,10,0,30)LabelReps.BackgroundTransparency=1 LabelReps.Text="总训练: 0"LabelReps.TextColor3=Color3.fromRGB(230,230,235)LabelReps.Font=Enum.Font.Gotham LabelReps.TextSize=11 LabelReps.TextXAlignment=Enum.TextXAlignment.Left LabelReps.Parent=DataHUD

local dragging=false local dragInput,dragStart,startPos
DataHUD.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true dragStart=input.Position startPos=DataHUD.Position input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
DataHUD.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end end)
UserInputService.InputChanged:Connect(function(input) if input==dragInput and dragging then local delta=input.Position-dragStart DataHUD.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end)