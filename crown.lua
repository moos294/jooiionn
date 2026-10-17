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

local Cfg={AutoTrain=false,TrainAction="Dumbbell",TrainActionCN="哑铃",TrainInterval=0.2,AutoRebirth=false,TargetStrength=10000,RebirthInc=10000,TotalReps=0}
local ActionMap={["俯卧撑"]="PushUp",["哑铃"]="Dumbbell",["肩部推举1"]="ShoulderPress_1",["跑步机"]="TrendMill_1",["红史莱姆"]="Red slime"}
local ActionListCN={}
for cn,_ in pairs(ActionMap)do table.insert(ActionListCN,cn)end

local Window=WindUI:CreateWindow({Title="力量之冠 V6.1 极致视觉版",Icon="zap",Author="力量之冠",Folder="PowerCrownSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(460,780)})
local MainTab=Window:Tab({Title="控制面板",Icon="settings"})
local TrainSection=MainTab:Section({Title="🏋️ 自动锻炼",Icon="activity"})
TrainSection:Toggle({Title="自动锻炼",Value=false,Callback=function(state)Cfg.AutoTrain=state end})
TrainSection:Dropdown({Title="选择动作",Values=ActionListCN,Value="哑铃",Callback=function(selected)Cfg.TrainAction=ActionMap[selected] Cfg.TrainActionCN=selected end})
local RebirthSection=MainTab:Section({Title="💀 自动重生",Icon="refresh-cw"})
RebirthSection:Toggle({Title="开启自动重生",Value=false,Callback=function(state)Cfg.AutoRebirth=state end})

local FunTab=Window:Tab({Title="五条悟专属",Icon="sparkles"})
local GojoSection=FunTab:Section({Title="全套技能获取",Icon="zap"})

local isCasting = false

local function getTorso(char)
    return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function controlArms(char, pose, duration)
    local torso = getTorso(char)
    if not torso then return end
    local lShoulder = torso:FindFirstChild("Left Shoulder") or torso:FindFirstChild("LeftShoulder")
    local rShoulder = torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightShoulder")
    
    if lShoulder and rShoulder then
        local origL, origR = lShoulder.C0, rShoulder.C0
        local tInfo = TweenInfo.new(duration or 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        if pose == "Right" then
            TweenService:Create(rShoulder, tInfo, {C0 = origR * CFrame.Angles(math.rad(-90), 0, 0)}):Play()
        elseif pose == "Left" then
            TweenService:Create(lShoulder, tInfo, {C0 = origL * CFrame.Angles(math.rad(-90), 0, 0)}):Play()
        elseif pose == "Both" then
            TweenService:Create(lShoulder, tInfo, {C0 = origL * CFrame.Angles(math.rad(-80), math.rad(30), math.rad(-20))}):Play()
            TweenService:Create(rShoulder, tInfo, {C0 = origR * CFrame.Angles(math.rad(-80), math.rad(-30), math.rad(20))}):Play()
        end
        
        task.delay(2.5, function()
            if lShoulder and rShoulder then
                TweenService:Create(lShoulder, TweenInfo.new(0.5), {C0 = origL}):Play()
                TweenService:Create(rShoulder, TweenInfo.new(0.5), {C0 = origR}):Play()
            end
        end)
    end
end

local function createMeshSphere(parent, size, color, transparency, meshScale)
    local p = Instance.new("Part")
    p.Size = Vector3.new(1,1,1) * 2
    p.Color = color
    p.Material = Enum.Material.Neon
    p.Transparency = transparency or 0
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.Parent = parent
    local mesh = Instance.new("SpecialMesh", p)
    mesh.MeshType = Enum.MeshType.Sphere
    mesh.Scale = size / 2
    return p
end

local function castBlue()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    controlArms(char, "Right")
    
    local fx = Instance.new("Folder", Workspace)
    local pos = hrp.Position + hrp.CFrame.LookVector * 6 + Vector3.new(0, 2, 0)
    
    local core = createMeshSphere(fx, Vector3.new(3,3,3), Color3.fromRGB(0, 150, 255), 0.2)
    core.Position = pos
    
    local ring = Instance.new("Part", fx)
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.2, 8, 8)
    ring.CFrame = CFrame.new(pos) * CFrame.Angles(0,0,math.rad(90))
    ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromRGB(100, 200, 255)
    ring.Transparency = 0.4
    ring.Anchored = true
    
    local emitter = Instance.new("ParticleEmitter", core)
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Color = ColorSequence.new(Color3.fromRGB(50, 150, 255))
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)})
    emitter.Speed = NumberRange.new(20, 50)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Lifetime = NumberRange.new(0.2, 0.5)
    emitter.Rate = 200
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    TweenService:Create(cc, TweenInfo.new(0.2), {TintColor = Color3.fromRGB(150, 200, 255), Contrast = 0.2}):Play()
    TweenService:Create(core, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {Size = Vector3.new(20,20,20), Transparency = 1}):Play()
    TweenService:Create(ring, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {Size = Vector3.new(0.2, 40, 40), Transparency = 1, CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(180), math.rad(90))}):Play()
    
    Debris:AddItem(fx, 1)
    Debris:AddItem(cc, 1)
end

local function castRed()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    controlArms(char, "Left")
    
    local fx = Instance.new("Folder", Workspace)
    local pos = hrp.Position + hrp.CFrame.LookVector * 6 + Vector3.new(0, 2, 0)
    
    local core = createMeshSphere(fx, Vector3.new(2,2,2), Color3.fromRGB(255, 30, 30), 0)
    core.Position = pos
    
    local shockwave = createMeshSphere(fx, Vector3.new(2,2,2), Color3.fromRGB(255, 50, 50), 0.2)
    shockwave.Position = pos
    TweenService:Create(shockwave, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = Vector3.new(50,50,50), Transparency = 1}):Play()
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    TweenService:Create(cc, TweenInfo.new(0.1), {TintColor = Color3.fromRGB(255, 150, 150), Contrast = 0.5}):Play()
    TweenService:Create(core, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = Vector3.new(15,15,15), Transparency = 1}):Play()
    
    local s = Instance.new("Sound", fx)
    s.SoundId = "rbxasset://sounds/impact_water.mp3"
    s.Volume = 2
    s.PlaybackSpeed = 0.5
    s:Play()
    
    Debris:AddItem(fx, 1)
    Debris:AddItem(cc, 1)
end

local function castPurple()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    controlArms(char, "Both")
    
    local fx = Instance.new("Folder", Workspace)
    local pos = hrp.Position + hrp.CFrame.LookVector * 8 + Vector3.new(0, 2, 0)
    
    local blue = createMeshSphere(fx, Vector3.new(3,3,3), Color3.fromRGB(0, 100, 255), 0.2)
    local red = createMeshSphere(fx, Vector3.new(3,3,3), Color3.fromRGB(255, 0, 0), 0.2)
    blue.Position = pos + Vector3.new(-1.5, 0, 0)
    red.Position = pos + Vector3.new(1.5, 0, 0)
    
    local purple = createMeshSphere(fx, Vector3.new(1,1,1), Color3.fromRGB(180, 0, 255), 0)
    purple.Position = pos
    purple.Transparency = 1
    
    TweenService:Create(blue, TweenInfo.new(0.5), {Position = pos}):Play()
    TweenService:Create(red, TweenInfo.new(0.5), {Position = pos}):Play()
    task.wait(0.5)
    
    blue.Transparency = 1
    red.Transparency = 1
    purple.Transparency = 0
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Contrast = 1
    cc.TintColor = Color3.fromRGB(200, 100, 255)
    cc.Parent = Lighting
    
    local beam = Instance.new("Part", fx)
    beam.Material = Enum.Material.Neon
    beam.Color = Color3.fromRGB(180, 0, 255)
    beam.Anchored = true
    beam.CanCollide = false
    beam.Size = Vector3.new(1, 1, 300)
    beam.CFrame = CFrame.lookAt(pos, pos + hrp.CFrame.LookVector) * CFrame.Angles(math.rad(-90), 0, 0)
    beam.Transparency = 0.2
    
    TweenService:Create(purple, TweenInfo.new(0.3), {Size = Vector3.new(25,25,25)}):Play()
    TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Size = Vector3.new(60, 60, 300), Transparency = 1}):Play()
    
    local startT = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local t = tick() - startT
        camera.CFrame = camera.CFrame * CFrame.Angles(math.noise(t*100,0,0)*0.05, math.noise(0,t*100,0)*0.05, 0)
        if t > 1.5 then conn:Disconnect() end
    end)
    
    Debris:AddItem(fx, 2)
    Debris:AddItem(cc, 2)
end

local function castTeleport()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local fx = Instance.new("Folder", Workspace)
    local oldPos = hrp.Position
    
    local ghost = createMeshSphere(fx, Vector3.new(4,5,2), Color3.fromRGB(0,0,0), 0.5)
    ghost.Position = oldPos
    
    TweenService:Create(ghost, TweenInfo.new(0.5), {Size = Vector3.new(1,1,1), Transparency = 1}):Play()
    Debris:AddItem(fx, 1)
    
    hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -40)
end

local function castDomain()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    controlArms(char, "Both", 0.5)
    
    local fx = Instance.new("Folder", Workspace)
    local focusPos = hrp.Position + hrp.CFrame.LookVector * 15 + Vector3.new(0, 5, 0)
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Contrast = 2
    cc.Saturation = -1
    cc.Brightness = -0.1
    cc.Parent = Lighting
    
    local void = createMeshSphere(fx, Vector3.new(10,10,10), Color3.new(0,0,0), 0)
    void.Position = focusPos
    
    local eyeRing = Instance.new("Part", fx)
    eyeRing.Shape = Enum.PartType.Cylinder
    eyeRing.Size = Vector3.new(1, 20, 20)
    eyeRing.CFrame = CFrame.new(focusPos) * CFrame.Angles(0,0,math.rad(90))
    eyeRing.Material = Enum.Material.Neon
    eyeRing.Color = Color3.new(1,1,1)
    eyeRing.Anchored = true
    
    local orb = createMeshSphere(fx, Vector3.new(1,1,1), Color3.new(1,1,1), 0)
    orb.Position = focusPos
    
    local emitter = Instance.new("ParticleEmitter", eyeRing)
    emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
    emitter.Color = ColorSequence.new(Color3.new(1,1,1))
    emitter.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 10), NumberSequenceKeypoint.new(1, 0)})
    emitter.Speed = NumberRange.new(50, 100)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Rate = 300
    
    TweenService:Create(void, TweenInfo.new(2, Enum.EasingStyle.Exponential), {Size = Vector3.new(100,100,100)}):Play()
    TweenService:Create(eyeRing, TweenInfo.new(2, Enum.EasingStyle.Elastic), {Size = Vector3.new(1, 120, 120)}):Play()
    
    local startT = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local t = tick() - startT
        camera.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0,8,10), focusPos) * CFrame.Angles(math.noise(t*50,0,0)*1.5, math.noise(0,t*50,0)*1.5, 0)
        orb.CFrame = CFrame.new(focusPos) * CFrame.Angles(t*2, t*3, 0) * CFrame.new(0, 0, 30)
        if t > 4 then conn:Disconnect() end
    end)
    
    Debris:AddItem(fx, 4.5)
    Debris:AddItem(cc, 4.5)
    task.delay(4, function() camera.CameraType = Enum.CameraType.Custom end)
end

local skills = {
    {Name="术式顺转·苍", Color=Color3.fromRGB(0,150,255), Func=castBlue},
    {Name="术式反转·赫", Color=Color3.fromRGB(255,50,50), Func=castRed},
    {Name="虚式·茈", Color=Color3.fromRGB(180,0,255), Func=castPurple},
    {Name="瞬移", Color=Color3.fromRGB(0,0,0), Func=castTeleport},
    {Name="领域展开·无量空处", Color=Color3.fromRGB(255,255,255), Func=castDomain}
}

GojoSection:Button({Title="获取全部技能物品",Callback=function()
    local bp = player:WaitForChild("Backpack")
    for _, skill in ipairs(skills) do
        if not bp:FindFirstChild(skill.Name) then
            local tool = Instance.new("Tool")
            tool.Name = skill.Name
            tool.RequiresHandle = true
            tool.CanBeDropped = false
            
            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(1,1,1)
            handle.Shape = Enum.PartType.Ball
            handle.Color = skill.Color
            handle.Material = Enum.Material.Neon
            handle.Parent = tool
            
            local light = Instance.new("PointLight", handle)
            light.Color = skill.Color
            light.Range = 10
            light.Brightness = 2
            
            tool.Activated:Connect(function()
                if not isCasting then
                    isCasting = true
                    skill.Func()
                    task.delay(2.5, function() isCasting = false end)
                end
            end)
            tool.Parent = bp
        end
    end
    StarterGui:SetCore("SendNotification",{Title="获取成功",Text="已获得 苍、赫、茈、瞬移、无量空处",Duration=5})
end})

local SG=Instance.new("ScreenGui")SG.Name="PowerCrownUI"SG.ResetOnSpawn=false SG.IgnoreGuiInset=true
pcall(function()SG.Parent=game:GetService("CoreGui")end)if not SG.Parent then SG.Parent=player.PlayerGui end
local DataHUD=Instance.new("Frame")DataHUD.Size=UDim2.new(0,210,0,105)DataHUD.Position=UDim2.new(0,20,0.3,0)DataHUD.BackgroundColor3=Color3.fromRGB(20,24,34)DataHUD.BackgroundTransparency=0.1 DataHUD.BorderSizePixel=0 DataHUD.Active = true DataHUD.Parent=SG
local HUDTitle=Instance.new("TextLabel")HUDTitle.Size=UDim2.new(1,0,0,24)HUDTitle.BackgroundTransparency=1 HUDTitle.Text="📊 力量之冠 V6.1"HUDTitle.TextColor3=Color3.fromRGB(60,150,230)HUDTitle.Font=Enum.Font.GothamBold HUDTitle.TextSize=12 HUDTitle.Parent=DataHUD
local LabelReps=Instance.new("TextLabel")LabelReps.Size=UDim2.new(0.5,-10,0,18)LabelReps.Position=UDim2.new(0,10,0,30)LabelReps.BackgroundTransparency=1 LabelReps.Text="总训练: 0"LabelReps.TextColor3=Color3.fromRGB(230,230,235)LabelReps.Font=Enum.Font.Gotham LabelReps.TextSize=11 LabelReps.TextXAlignment=Enum.TextXAlignment.Left LabelReps.Parent=DataHUD

local dragging=false local dragInput,dragStart,startPos
DataHUD.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true dragStart=input.Position startPos=DataHUD.Position input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
DataHUD.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end end)
UserInputService.InputChanged:Connect(function(input) if input==dragInput and dragging then local delta=input.Position-dragStart DataHUD.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end)

task.spawn(function()
    local trainEvent 
    pcall(function() trainEvent=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TrainEvent") end)
    while SG.Parent do 
        task.wait(Cfg.TrainInterval)
        if Cfg.AutoTrain and trainEvent then 
            pcall(function()
                trainEvent:FireServer(Cfg.TrainAction)
                Cfg.TotalReps = Cfg.TotalReps + 1
                LabelReps.Text = "总训练: "..Cfg.TotalReps
            end)
        end 
    end 
end)