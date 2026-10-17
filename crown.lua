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
GojoSection:Button({Title="领域展开·无量空处",Callback=function()
    if isCasting then return end
    isCasting = true
    
    local success, err = pcall(function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local origCamType = camera.CameraType
        local origFOV = camera.FieldOfView
        
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
        text.TextSize = 64
        text.TextStrokeTransparency = 0.2
        text.TextTransparency = 1
        text.ZIndex = 101
        text.Parent = gui
        
        local domainFolder = Instance.new("Folder")
        domainFolder.Name = "DomainFX"
        domainFolder.Parent = Workspace
        
        local cc = Instance.new("ColorCorrectionEffect")
        cc.Contrast = 1
        cc.Saturation = -1
        cc.Brightness = -0.1
        cc.TintColor = Color3.fromRGB(220,230,255)
        cc.Parent = Lighting
        
        camera.CameraType = Enum.CameraType.Scriptable
        
        local gojoModel = Instance.new("Model")
        gojoModel.Name = "GojoIllusion"
        gojoModel.Parent = domainFolder
        
        local centerPos = hrp.Position + hrp.CFrame.LookVector * 8
        
        local function makePart(name, size, color, mat, parent)
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
        
        local body = makePart("Body", Vector3.new(2.5, 3.5, 1), Color3.fromRGB(20, 20, 25), Enum.Material.SmoothPlastic, gojoModel)
        body.CFrame = CFrame.new(centerPos)
        
        local head = makePart("Head", Vector3.new(1.5, 1.5, 1.5), Color3.fromRGB(255, 230, 210), Enum.Material.SmoothPlastic, gojoModel)
        head.Shape = Enum.PartType.Ball
        head.CFrame = body.CFrame * CFrame.new(0, 2.4, 0)
        
        local hair = makePart("Hair", Vector3.new(1.7, 0.8, 1.7), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, gojoModel)
        hair.Shape = Enum.PartType.Ball
        hair.CFrame = head.CFrame * CFrame.new(0, 0.5, 0)
        
        local blindfold = makePart("Blindfold", Vector3.new(1.6, 0.4, 1.6), Color3.fromRGB(10, 10, 10), Enum.Material.SmoothPlastic, gojoModel)
        blindfold.CFrame = head.CFrame * CFrame.new(0, 0.1, 0)
        
        local leftArm = makePart("LeftArm", Vector3.new(0.6, 2.5, 0.6), Color3.fromRGB(20, 20, 25), Enum.Material.SmoothPlastic, gojoModel)
        leftArm.CFrame = body.CFrame * CFrame.new(-1.5, 0.5, 0)
        
        local rightArm = makePart("RightArm", Vector3.new(0.6, 2.5, 0.6), Color3.fromRGB(20, 20, 25), Enum.Material.SmoothPlastic, gojoModel)
        rightArm.CFrame = body.CFrame * CFrame.new(1.5, 0.5, 0)
        
        local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TweenService:Create(leftArm, tweenInfo, {CFrame = body.CFrame * CFrame.new(-0.4, 1.2, -1) * CFrame.Angles(math.rad(-45), math.rad(-30), math.rad(60))}):Play()
        TweenService:Create(rightArm, tweenInfo, {CFrame = body.CFrame * CFrame.new(0.4, 1.2, -1) * CFrame.Angles(math.rad(-45), math.rad(30), math.rad(-60))}):Play()
        
        local blackHole = makePart("VoidCore", Vector3.new(1,1,1), Color3.new(0,0,0), Enum.Material.SmoothPlastic, domainFolder)
        blackHole.Shape = Enum.PartType.Ball
        blackHole.CFrame = CFrame.new(centerPos + Vector3.new(0, 4, -2))
        
        local rings = {}
        for i = 1, 6 do
            local ringFolder = Instance.new("Folder")
            ringFolder.Parent = domainFolder
            local rParts = {}
            local segments = 36 + (i * 12)
            for j = 1, segments do
                local p = makePart("RingPart", Vector3.new(0.2, 0.1, 1), i % 2 == 0 and Color3.new(1,1,1) or Color3.fromRGB(100, 150, 255), Enum.Material.Neon, ringFolder)
                table.insert(rParts, {part = p, angle = (j-1) * math.pi * 2 / segments})
            end
            table.insert(rings, {folder = ringFolder, parts = rParts, radius = 3 + i * 1.5, speed = (i % 2 == 0 and 1 or -1) * (1 + i * 0.2), rotX = math.random(-20, 20)})
        end
        
        local lines = {}
        for i = 1, 50 do
            local l = makePart("SpeedLine", Vector3.new(0.08, 0.08, 200), i % 3 == 0 and Color3.fromRGB(255, 50, 50) or Color3.new(1,1,1), Enum.Material.Neon, domainFolder)
            table.insert(lines, {part = l, angle = math.random() * math.pi * 2, offset = math.random() * 10, speed = 150 + math.random() * 200})
        end
        
        text.Text = "领域展开"
        TweenService:Create(flash, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
        TweenService:Create(text, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
        
        task.wait(0.15)
        flash.BackgroundTransparency = 1
        text.Text = "“无量空处”"
        
        TweenService:Create(blackHole, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {Size = Vector3.new(24,24,24)}):Play()
        
        local startTime = tick()
        local renderConn
        renderConn = RunService.RenderStepped:Connect(function()
            local t = tick() - startTime
            
            camera.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 6, 15), centerPos + Vector3.new(0, 3, 0)) * CFrame.Angles(math.noise(t*20,0,0)*0.015, math.noise(0,t*20,0)*0.015, 0)
            camera.FieldOfView = 65 + math.sin(t*8)*3
            
            for i, ringData in ipairs(rings) do
                local rotCF = blackHole.CFrame * CFrame.Angles(math.rad(ringData.rotX), 0, 0) * CFrame.Angles(0, t * ringData.speed, 0)
                for j, pData in ipairs(ringData.parts) do
                    local angle = pData.angle + t * ringData.speed
                    local pos = rotCF * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, -ringData.radius)
                    pData.part.CFrame = CFrame.lookAt(pos.Position, blackHole.Position) * CFrame.Angles(0, math.rad(90), 0)
                end
            end
            
            for i, lData in ipairs(lines) do
                local dist = (t * lData.speed) % 150
                local p = blackHole.CFrame * CFrame.Angles(lData.angle, lData.angle, 0) * CFrame.new(0, 0, -dist - 10)
                lData.part.CFrame = CFrame.lookAt(p.Position, blackHole.Position) * CFrame.Angles(math.rad(90), 0, 0)
            end
        end)
        
        task.wait(3.5)
        
        if renderConn then renderConn:Disconnect() end
        domainFolder:Destroy()
        cc:Destroy()
        camera.CameraType = origCamType
        camera.FieldOfView = origFOV
        gui:Destroy()
    end)
    
    if not success then
        warn("技能执行出错: ", err)
        camera.CameraType = Enum.CameraType.Custom
        pcall(function() player.PlayerGui.DomainUI:Destroy() end)
        pcall(function() Workspace.DomainFX:Destroy() end)
        pcall(function() Lighting.ColorCorrectionEffect:Destroy() end)
    end
    isCasting = false
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