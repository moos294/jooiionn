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

local Window=WindUI:CreateWindow({Title="力量之冠 V6.1 终极稳定版",Icon="zap",Author="力量之冠",Folder="PowerCrownSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(460,780)})
local MainTab=Window:Tab({Title="控制面板",Icon="settings"})
local TrainSection=MainTab:Section({Title="🏋️ 自动锻炼",Icon="activity"})
TrainSection:Toggle({Title="自动锻炼",Value=false,Callback=function(state)Cfg.AutoTrain=state end})
TrainSection:Dropdown({Title="选择动作",Values=ActionListCN,Value="哑铃",Callback=function(selected)Cfg.TrainAction=ActionMap[selected] Cfg.TrainActionCN=selected end})
local RebirthSection=MainTab:Section({Title="💀 自动重生",Icon="refresh-cw"})
RebirthSection:Toggle({Title="开启自动重生",Value=false,Callback=function(state)Cfg.AutoRebirth=state end})

local FunTab=Window:Tab({Title="娱乐区",Icon="sparkles"})
local GojoSection=FunTab:Section({Title="五条悟专属 (领域展开)",Icon="sparkles"})

local isCasting = false

local function playDomain()
    if isCasting then return end
    isCasting = true
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then isCasting = false return end
    
    local origCamType = camera.CameraType
    local origFOV = camera.FieldOfView
    
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    local lShoulder = torso and (torso:FindFirstChild("Left Shoulder") or torso:FindFirstChild("LeftShoulder"))
    local rShoulder = torso and (torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightShoulder"))
    local origL, origR
    if lShoulder and rShoulder then
        origL = lShoulder.C0
        origR = rShoulder.C0
        local tInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(lShoulder, tInfo, {C0 = origL * CFrame.Angles(math.rad(-70), math.rad(30), math.rad(-20))}):Play()
        TweenService:Create(rShoulder, tInfo, {C0 = origR * CFrame.Angles(math.rad(-70), math.rad(-30), math.rad(20))}):Play()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "DomainUI"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local flash = Instance.new("Frame")
    flash.Size = UDim2.fromScale(1,1)
    flash.BackgroundColor3 = Color3.new(1,1,1)
    flash.BackgroundTransparency = 1
    flash.BorderSizePixel = 0
    flash.ZIndex = 100
    flash.Parent = gui
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 0.3)
    text.Position = UDim2.fromScale(0, 0.65)
    text.BackgroundTransparency = 1
    text.Text = ""
    text.TextColor3 = Color3.new(1,1,1)
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 80
    text.TextStrokeTransparency = 0
    text.TextTransparency = 1
    text.ZIndex = 101
    text.Parent = gui
    
    local domainFolder = Instance.new("Folder")
    domainFolder.Name = "DomainFX"
    domainFolder.Parent = Workspace
    
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Contrast = 0
    cc.Saturation = 0
    cc.Brightness = 0
    cc.TintColor = Color3.new(1,1,1)
    cc.Parent = Lighting
    
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
    
    camera.CameraType = Enum.CameraType.Scriptable
    
    local dummyPos = hrp.Position + hrp.CFrame.LookVector * 12
    local dummy = Instance.new("Model")
    dummy.Name = "TargetDummy"
    dummy.Parent = domainFolder
    
    local function makeLimb(name, size, color, mat, parent)
        local p = Instance.new("Part")
        p.Name = name
        p.Size = size
        p.Color = color
        p.Material = mat
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.Parent = parent
        return p
    end
    
    local dTorso = makeLimb("Torso", Vector3.new(2, 2, 1), Color3.fromRGB(30, 30, 40), Enum.Material.SmoothPlastic, dummy)
    dTorso.CFrame = CFrame.new(dummyPos)
    
    local dHead = makeLimb("Head", Vector3.new(1.2, 1.2, 1.2), Color3.fromRGB(200, 180, 160), Enum.Material.SmoothPlastic, dummy)
    dHead.Shape = Enum.PartType.Ball
    dHead.CFrame = dTorso.CFrame * CFrame.new(0, 1.6, 0)
    
    local dLArm = makeLimb("LArm", Vector3.new(0.5, 2, 0.5), Color3.fromRGB(30, 30, 40), Enum.Material.SmoothPlastic, dummy)
    dLArm.CFrame = dTorso.CFrame * CFrame.new(-1.3, 0, 0)
    
    local dRArm = makeLimb("RArm", Vector3.new(0.5, 2, 0.5), Color3.fromRGB(30, 30, 40), Enum.Material.SmoothPlastic, dummy)
    dRArm.CFrame = dTorso.CFrame * CFrame.new(1.3, 0, 0)
    
    local tDummy = TweenInfo.new(0.5, Enum.EasingStyle.Bounce)
    TweenService:Create(dLArm, tDummy, {CFrame = dTorso.CFrame * CFrame.new(-0.8, 0.8, 0.5) * CFrame.Angles(math.rad(-90), 0, math.rad(-45))}):Play()
    TweenService:Create(dRArm, tDummy, {CFrame = dTorso.CFrame * CFrame.new(0.8, 0.8, 0.5) * CFrame.Angles(math.rad(-90), 0, math.rad(45))}):Play()
    TweenService:Create(dTorso, TweenInfo.new(0.5), {CFrame = dTorso.CFrame * CFrame.Angles(math.rad(-20), 0, 0)}):Play()
    
    local redLines = Instance.new("Folder")
    redLines.Parent = domainFolder
    local lineParts = {}
    for i = 1, 100 do
        local line = makeLimb("RedLine", Vector3.new(0.05, 0.05, math.random(100, 300)), Color3.fromRGB(255, 20, 20), Enum.Material.Neon, redLines)
        table.insert(lineParts, {part=line, offset=Vector3.new((math.random()-0.5)*40, (math.random()-0.5)*40, (math.random()-0.5)*40), speed=math.random(150, 400)})
    end
    
    text.Text = "领域展开"
    TweenService:Create(flash, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
    TweenService:Create(text, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
    
    local startTime = tick()
    local renderConn
    local phase = 1
    
    renderConn = RunService.RenderStepped:Connect(function()
        local t = tick() - startTime
        
        if t > 0.2 and phase == 1 then
            phase = 2
            text.Text = "“无量空处”"
            flash.BackgroundTransparency = 1
            TweenService:Create(blur, TweenInfo.new(0.3), {Size = 24}):Play()
        end
        
        if t > 1.5 and phase == 2 then
            phase = 3
            text.Text = ""
            TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
            cc.Contrast = 2
            cc.Saturation = -1
            
            for _, l in ipairs(lineParts) do
                TweenService:Create(l.part, TweenInfo.new(0.5), {Transparency = 1}):Play()
            end
            Debris:AddItem(redLines, 0.6)
            
            local void = makeLimb("Void", Vector3.new(1,1,1), Color3.new(0,0,0), Enum.Material.SmoothPlastic, domainFolder)
            void.Shape = Enum.PartType.Ball
            void.CFrame = CFrame.new(dummyPos + Vector3.new(0, 3, -4))
            TweenService:Create(void, TweenInfo.new(2, Enum.EasingStyle.Exponential), {Size = Vector3.new(60,60,60)}):Play()
            
            for i = 1, 150 do
                local shard = makeLimb("Shard", Vector3.new(math.random(20,80)/10, math.random(20,80)/10, 0.1), Color3.new(1,1,1), Enum.Material.Neon, domainFolder)
                local angle = math.random()*math.pi*2
                local dist = math.random(10, 45)
                shard.CFrame = CFrame.new(dummyPos + Vector3.new(math.cos(angle)*dist, math.sin(angle)*dist + 3, -4)) * CFrame.Angles(0,0,angle)
                TweenService:Create(shard, TweenInfo.new(1), {Size = Vector3.new(shard.Size.X*4, shard.Size.Y*4, 0.1)}):Play()
            end
        end
        
        local shake = 0
        if t > 0.2 and t < 1.5 then shake = 1.5
        elseif t >= 1.5 and t < 4 then shake = 0.5 end
        
        local camPos = (hrp.Position + hrp.CFrame.LookVector * -5 + Vector3.new(0, 6, 0))
        local lookAt = dummyPos + Vector3.new(0, 3, 0)
        
        camera.CFrame = CFrame.lookAt(camPos, lookAt) * CFrame.Angles(math.noise(t*80,0,0)*shake, math.noise(0,t*80,0)*shake, math.noise(t*40,t*40,0)*shake)
        camera.FieldOfView = 70 + math.sin(t*30)*15
        
        if phase == 2 then
            for _, l in ipairs(lineParts) do
                local dist = (t * l.speed) % 300
                local pos = dummyPos + l.offset.Unit * dist
                l.part.CFrame = CFrame.lookAt(pos, dummyPos)
            end
        end
    end)
    
    task.delay(4.5, function()
        if renderConn then renderConn:Disconnect() end
        domainFolder:Destroy()
        cc:Destroy()
        blur:Destroy()
        camera.CameraType = origCamType
        camera.FieldOfView = origFOV
        gui:Destroy()
        if lShoulder and rShoulder then
            TweenService:Create(lShoulder, TweenInfo.new(0.3), {C0 = origL}):Play()
            TweenService:Create(rShoulder, TweenInfo.new(0.3), {C0 = origR}):Play()
        end
        isCasting = false
    end)
end

GojoSection:Button({Title="变身五条悟 (获取物品)",Callback=function()
    local bp = player:WaitForChild("Backpack")
    if bp:FindFirstChild("无量空处") or (player.Character and player.Character:FindFirstChild("无量空处")) then
        return
    end
    
    local tool = Instance.new("Tool")
    tool.Name = "无量空处"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Shape = Enum.PartType.Ball
    handle.Color = Color3.new(0,0,0)
    handle.Material = Enum.Material.Neon
    handle.Parent = tool
    
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(100, 150, 255)
    light.Range = 10
    light.Brightness = 2
    light.Parent = handle
    
    tool.Activated:Connect(function()
        playDomain()
    end)
    
    tool.Parent = bp
    StarterGui:SetCore("SendNotification",{Title="获得物品",Text="已获得【无量空处】，请手持并点击屏幕释放",Duration=5})
end})

local SG=Instance.new("ScreenGui")SG.Name="PowerCrownUI"SG.ResetOnSpawn=false SG.IgnoreGuiInset=true
pcall(function()SG.Parent=game:GetService("CoreGui")end)if not SG.Parent then SG.Parent=player.PlayerGui end
local DataHUD=Instance.new("Frame")DataHUD.Size=UDim2.new(0,210,0,105)DataHUD.Position=UDim2.new(0,20,0.3,0)DataHUD.BackgroundColor3=Color3.fromRGB(20,24,34)DataHUD.BackgroundTransparency=0.1 DataHUD.BorderSizePixel=0 DataHUD.Parent=SG
local HUDTitle=Instance.new("TextLabel")HUDTitle.Size=UDim2.new(1,0,0,24)HUDTitle.BackgroundTransparency=1 HUDTitle.Text="📊 力量之冠 V6.1"HUDTitle.TextColor3=Color3.fromRGB(60,150,230)HUDTitle.Font=Enum.Font.GothamBold HUDTitle.TextSize=12 HUDTitle.Parent=DataHUD
local LabelReps=Instance.new("TextLabel")LabelReps.Size=UDim2.new(0.5,-10,0,18)LabelReps.Position=UDim2.new(0,10,0,30)LabelReps.BackgroundTransparency=1 LabelReps.Text="总训练: 0"LabelReps.TextColor3=Color3.fromRGB(230,230,235)LabelReps.Font=Enum.Font.Gotham LabelReps.TextSize=11 LabelReps.TextXAlignment=Enum.TextXAlignment.Left LabelReps.Parent=DataHUD

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