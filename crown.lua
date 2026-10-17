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

local Window=WindUI:CreateWindow({Title="力量之冠 V1.0 极致视觉版",Icon="zap",Author="力量之冠",Folder="PowerCrownSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(460,780)})
local FunTab=Window:Tab({Title="五条悟专属",Icon="sparkles"})
local GojoSection=FunTab:Section({Title="全套技能获取",Icon="zap"})

local isCasting = false

local function controlArms(char, pose)
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end
    local lShoulder = torso:FindFirstChild("Left Shoulder") or torso:FindFirstChild("LeftShoulder")
    local rShoulder = torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightShoulder")
    if lShoulder and rShoulder then
        local origL, origR = lShoulder.C0, rShoulder.C0
        local tInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back)
        if pose == "Right" then
            TweenService:Create(rShoulder, tInfo, {C0 = origR * CFrame.Angles(math.rad(-90), 0, 0)}):Play()
        elseif pose == "Left" then
            TweenService:Create(lShoulder, tInfo, {C0 = origL * CFrame.Angles(math.rad(-90), 0, 0)}):Play()
        elseif pose == "Both" then
            TweenService:Create(lShoulder, tInfo, {C0 = origL * CFrame.Angles(math.rad(-80), math.rad(30), math.rad(-20))}):Play()
            TweenService:Create(rShoulder, tInfo, {C0 = origR * CFrame.Angles(math.rad(-80), math.rad(-30), math.rad(20))}):Play()
        end
        task.delay(1.5, function()
            TweenService:Create(lShoulder, TweenInfo.new(0.3), {C0 = origL}):Play()
            TweenService:Create(rShoulder, TweenInfo.new(0.3), {C0 = origR}):Play()
        end)
    end
end

local function createEnergyBall(char, color, isRed)
    local hrp = char.HumanoidRootPart
    local ball = Instance.new("Part")
    ball.Shape = Enum.PartType.Ball
    ball.Size = Vector3.new(4,4,4)
    ball.Material = Enum.Material.Neon
    ball.Color = color
    ball.Anchored = true
    ball.CanCollide = false
    ball.Position = hrp.Position + hrp.CFrame.LookVector * 3 + Vector3.new(0, 2, 0)
    ball.Parent = Workspace
    
    local shell = Instance.new("Part")
    shell.Shape = Enum.PartType.Ball
    shell.Size = Vector3.new(5,5,5)
    shell.Material = Enum.Material.ForceField
    shell.Color = color
    shell.Transparency = 0.3
    shell.Anchored = true
    shell.CanCollide = false
    shell.CFrame = ball.CFrame
    shell.Parent = Workspace
    
    local light = Instance.new("PointLight", ball)
    light.Color = color
    light.Range = 25
    light.Brightness = 8
    
    local emit = Instance.new("ParticleEmitter", ball)
    emit.Texture = "rbxasset://textures/particles/fire_main.dds"
    emit.Color = ColorSequence.new(color)
    emit.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)})
    emit.Speed = NumberRange.new(10, 30)
    emit.Rate = 200
    
    local att0 = Instance.new("Attachment", ball)
    att0.Position = Vector3.new(0, 2, 0)
    local att1 = Instance.new("Attachment", ball)
    att1.Position = Vector3.new(0, -2, 0)
    
    local trail = Instance.new("Trail", ball)
    trail.Attachment0 = att0
    trail.Attachment1 = att1
    trail.Color = ColorSequence.new(color, Color3.new(1,1,1))
    trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
    trail.Lifetime = 0.4
    trail.MinLength = 0.1
    trail.LightEmission = 1
    
    return ball, shell, trail
end

local function launchProjectile(ball, shell, speed, color)
    local direction = camera.CFrame.LookVector
    ball.Anchored = false
    shell.Anchored = false
    
    local bv = Instance.new("BodyVelocity", ball)
    bv.Velocity = direction * speed
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    
    local bvShell = Instance.new("BodyVelocity", shell)
    bvShell.Velocity = direction * speed
    bvShell.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    
    local hit = false
    ball.Touched:Connect(function(h)
        if h:IsDescendantOf(player.Character) or hit then return end
        hit = true
        bv:Destroy()
        bvShell:Destroy()
        
        local boom = Instance.new("Part", Workspace)
        boom.Shape = Enum.PartType.Ball
        boom.Material = Enum.Material.Neon
        boom.Color = color
        boom.Anchored = true
        boom.CanCollide = false
        boom.Size = Vector3.new(2,2,2)
        boom.Position = ball.Position
        
        local light = Instance.new("PointLight", boom)
        light.Color = color
        light.Brightness = 15
        light.Range = 50
        
        TweenService:Create(boom, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = Vector3.new(40,40,40), Transparency = 1}):Play()
        task.wait(0.4)
        ball:Destroy() 
        shell:Destroy() 
        boom:Destroy()
    end)
    
    Debris:AddItem(ball, 3)
    Debris:AddItem(shell, 3)
end

local function castBlue()
    local char = player.Character
    if not char then return end
    controlArms(char, "Right")
    
    local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Intensity = 2
    bloom.Size = 24
    
    local b, s, t = createEnergyBall(char, Color3.fromRGB(0, 150, 255))
    
    local startT = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local time = tick() - startT
        b.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 2, -3) + char.HumanoidRootPart.CFrame.LookVector * (time * 5)
        s.CFrame = b.CFrame
        if time > 0.5 then
            conn:Disconnect()
            launchProjectile(b, s, 150, Color3.fromRGB(0, 150, 255))
        end
    end)
    Debris:AddItem(bloom, 3)
end

local function castRed()
    local char = player.Character
    if not char then return end
    controlArms(char, "Left")
    
    local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Intensity = 2
    bloom.Size = 24
    
    local b, s, t = createEnergyBall(char, Color3.fromRGB(255, 30, 30))
    
    local startT = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local time = tick() - startT
        b.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 2, -3) + char.HumanoidRootPart.CFrame.LookVector * (time * 5)
        s.CFrame = b.CFrame
        if time > 0.5 then
            conn:Disconnect()
            launchProjectile(b, s, 150, Color3.fromRGB(255, 30, 30))
        end
    end)
    Debris:AddItem(bloom, 3)
end

local function castPurple()
    local char = player.Character
    if not char then return end
    controlArms(char, "Both")
    
    local bloom = Instance.new("BloomEffect", Lighting)
    bloom.Intensity = 3
    bloom.Size = 32
    Debris:AddItem(bloom, 5)
    
    local b, s, _ = createEnergyBall(char, Color3.fromRGB(0, 150, 255))
    local r, s2, _ = createEnergyBall(char, Color3.fromRGB(255, 30, 30))
    
    b.Position = char.HumanoidRootPart.Position + char.HumanoidRootPart.CFrame.RightVector * 4 + Vector3.new(0, 2, 0) + char.HumanoidRootPart.CFrame.LookVector * 5
    r.Position = char.HumanoidRootPart.Position - char.HumanoidRootPart.CFrame.RightVector * 4 + Vector3.new(0, 2, 0) + char.HumanoidRootPart.CFrame.LookVector * 5
    
    local centerPos = char.HumanoidRootPart.Position + Vector3.new(0, 2, 0) + char.HumanoidRootPart.CFrame.LookVector * 5
    
    local purpleCore = Instance.new("Part", Workspace)
    purpleCore.Shape = Enum.PartType.Ball
    purpleCore.Size = Vector3.new(1,1,1)
    purpleCore.Material = Enum.Material.Neon
    purpleCore.Color = Color3.fromRGB(180, 0, 255)
    purpleCore.Anchored = true
    purpleCore.CanCollide = false
    purpleCore.Position = centerPos
    
    local purpleLight = Instance.new("PointLight", purpleCore)
    purpleLight.Color = Color3.fromRGB(180, 0, 255)
    purpleLight.Brightness = 20
    purpleLight.Range = 50
    
    TweenService:Create(b, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Position = centerPos}):Play()
    TweenService:Create(s, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Position = centerPos}):Play()
    TweenService:Create(r, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Position = centerPos}):Play()
    TweenService:Create(s2, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Position = centerPos}):Play()
    
    task.wait(0.8)
    
    b.Transparency = 1
    s.Transparency = 1
    r.Transparency = 1
    s2.Transparency = 1
    
    local emitter = Instance.new("ParticleEmitter", purpleCore)
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Color = ColorSequence.new(Color3.fromRGB(200, 0, 255), Color3.new(1,1,1))
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 0)})
    emitter.Speed = NumberRange.new(100, 300)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Rate = 1000
    
    TweenService:Create(purpleCore, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = Vector3.new(15,15,15)}):Play()
    task.wait(0.5)
    
    local beam = Instance.new("Part", Workspace)
    beam.Material = Enum.Material.Neon
    beam.Color = Color3.fromRGB(180, 0, 255)
    beam.Anchored = true
    beam.CanCollide = false
    beam.Size = Vector3.new(20, 20, 300)
    beam.CFrame = CFrame.lookAt(centerPos, centerPos + char.HumanoidRootPart.CFrame.LookVector) * CFrame.Angles(math.rad(-90), 0, 0)
    
    local beamCore = Instance.new("Part", Workspace)
    beamCore.Material = Enum.Material.Neon
    beamCore.Color = Color3.new(1,1,1)
    beamCore.Anchored = true
    beamCore.CanCollide = false
    beamCore.Size = Vector3.new(8, 8, 300)
    beamCore.CFrame = beam.CFrame
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.TintColor = Color3.fromRGB(200, 100, 255)
    cc.Contrast = 0.5
    Debris:AddItem(cc, 2)
    
    local startT = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local t = tick() - startT
        camera.CFrame = camera.CFrame * CFrame.Angles(math.noise(t*200,0,0)*0.05, math.noise(0,t*200,0)*0.05, 0)
        if t > 2 then conn:Disconnect() end
    end)
    
    task.wait(0.5)
    TweenService:Create(beam, TweenInfo.new(1.5), {Transparency = 1}):Play()
    TweenService:Create(beamCore, TweenInfo.new(1.5), {Transparency = 1}):Play()
    TweenService:Create(purpleCore, TweenInfo.new(1.5), {Transparency = 1}):Play()
    
    Debris:AddItem(beam, 2)
    Debris:AddItem(beamCore, 2)
    Debris:AddItem(purpleCore, 2)
end

local skills = {
    {Name="术式顺转·苍", Color=Color3.fromRGB(0,150,255), Func=castBlue},
    {Name="术式反转·赫", Color=Color3.fromRGB(255,50,50), Func=castRed},
    {Name="虚式·茈", Color=Color3.fromRGB(180,0,255), Func=castPurple}
}

GojoSection:Button({Title="获取技能物品",Callback=function()
    local bp = player:WaitForChild("Backpack")
    for _, skill in ipairs(skills) do
        if not bp:FindFirstChild(skill.Name) then
            local tool = Instance.new("Tool")
            tool.Name = skill.Name
            tool.RequiresHandle = true
            tool.CanBeDropped = false
            local handle = Instance.new("Part")
            handle.Size = Vector3.new(1,1,1)
            handle.Shape = Enum.PartType.Ball
            handle.Color = skill.Color
            handle.Material = Enum.Material.Neon
            handle.Parent = tool
            tool.Activated:Connect(function()
                if not isCasting then
                    isCasting = true
                    skill.Func()
                    task.delay(3, function() isCasting = false end)
                end
            end)
            tool.Parent = bp
        end
    end
    StarterGui:SetCore("SendNotification",{Title="获取成功",Text="已获得全套技能，请手持释放",Duration=5})
end})