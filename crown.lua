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
        text.TextSize = 80
        text.TextStrokeTransparency = 0
        text.TextTransparency = 1
        text.ZIndex = 101
        text.Parent = gui
        
        local domainFolder = Instance.new("Folder")
        domainFolder.Name = "DomainFX"
        domainFolder.Parent = Workspace
        
        local cc = Instance.new("ColorCorrectionEffect")
        cc.Contrast = 1.5
        cc.Saturation = -1
        cc.Brightness = -0.15
        cc.TintColor = Color3.fromRGB(240,245,255)
        cc.Parent = Lighting
        
        local origBrightness = Lighting.Brightness
        Lighting.Brightness = 0
        
        camera.CameraType = Enum.CameraType.Scriptable
        
        local dummyPos = hrp.Position + hrp.CFrame.LookVector * 10
        local gojoPos = dummyPos + hrp.CFrame.LookVector * 4
        
        local dummy = Instance.new("Model")
        dummy.Name = "TargetDummy"
        dummy.Parent = domainFolder
        
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
        
        local dBody = makePart("Body", Vector3.new(2, 3, 1), Color3.fromRGB(50, 50, 60), Enum.Material.SmoothPlastic, dummy)
        dBody.CFrame = CFrame.new(dummyPos)
        local dHead = makePart("Head", Vector3.new(1.2, 1.2, 1.2), Color3.fromRGB(200, 180, 160), Enum.Material.SmoothPlastic, dummy)
        dHead.Shape = Enum.PartType.Ball
        dHead.CFrame = CFrame.new(dummyPos + Vector3.new(0, 2.1, 0))
        
        local gojoBody = makePart("Body", Vector3.new(2.5, 3.5, 1), Color3.fromRGB(20, 20, 25), Enum.Material.SmoothPlastic, domainFolder)
        gojoBody.CFrame = CFrame.new(gojoPos)
        local gHead = makePart("Head", Vector3.new(1.5, 1.5, 1.5), Color3.fromRGB(255, 230, 210), Enum.Material.SmoothPlastic, domainFolder)
        gHead.Shape = Enum.PartType.Ball
        gHead.CFrame = gojoBody.CFrame * CFrame.new(0, 2.4, 0)
        local gHair = makePart("Hair", Vector3.new(1.7, 0.8, 1.7), Color3.new(1,1,1), Enum.Material.Neon, domainFolder)
        gHair.Shape = Enum.PartType.Ball
        gHair.CFrame = gHead.CFrame * CFrame.new(0, 0.5, 0)
        local gBlind = makePart("Blindfold", Vector3.new(1.6, 0.4, 1.6), Color3.fromRGB(10,10,10), Enum.Material.SmoothPlastic, domainFolder)
        gBlind.CFrame = gHead.CFrame * CFrame.new(0, 0.1, 0)
        
        local lArm = makePart("LArm", Vector3.new(0.6, 2.5, 0.6), Color3.fromRGB(20, 20, 25), Enum.Material.SmoothPlastic, domainFolder)
        lArm.CFrame = gojoBody.CFrame * CFrame.new(-1.5, 0.5, 0)
        local rArm = makePart("RArm", Vector3.new(0.6, 2.5, 0.6), Color3.fromRGB(20, 20, 25), Enum.Material.SmoothPlastic, domainFolder)
        rArm.CFrame = gojoBody.CFrame * CFrame.new(1.5, 0.5, 0)
        
        local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back)
        TweenService:Create(lArm, tInfo, {CFrame = gojoBody.CFrame * CFrame.new(-0.4, 1.2, -1) * CFrame.Angles(math.rad(-45), math.rad(-30), math.rad(60))}):Play()
        TweenService:Create(rArm, tInfo, {CFrame = gojoBody.CFrame * CFrame.new(0.4, 1.2, -1) * CFrame.Angles(math.rad(-45), math.rad(30), math.rad(-60))}):Play()
        
        local blackHole = makePart("Void", Vector3.new(1,1,1), Color3.new(0,0,0), Enum.Material.SmoothPlastic, domainFolder)
        blackHole.Shape = Enum.PartType.Ball
        blackHole.CFrame = CFrame.new(dummyPos + Vector3.new(0, 2.5, -2))
        
        local shards = {}
        for i = 1, 200 do
            local s = makePart("Shard", Vector3.new(math.random(5,20)/10, math.random(5,20)/10, math.random(1,5)/10), i%2==0 and Color3.new(1,1,1) or Color3.fromRGB(150, 200, 255), Enum.Material.Neon, domainFolder)
            table.insert(shards, {part = s, angle = math.random()*math.pi*2, dist = math.random(5, 15), speed = (math.random() - 0.5) * 5})
        end
        
        local textFolder = Instance.new("Folder")
        textFolder.Parent = domainFolder
        local texts = {}
        for i = 1, 60 do
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.fromOffset(100, 40)
            bb.AlwaysOnTop = true
            bb.Adornee = dHead
            bb.Parent = textFolder
            
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.fromScale(1,1)
            tl.BackgroundTransparency = 1
            tl.Font = Enum.Font.Code
            tl.TextSize = 20
            tl.TextColor3 = i%3==0 and Color3.fromRGB(255,50,50) or Color3.new(1,1,1)
            tl.Text = string.format("%x", math.random(100000, 999999))
            tl.Parent = bb
            table.insert(texts, {gui = bb, label = tl, offset = Vector3.new((math.random()-0.5)*4, (math.random()-0.5)*4, (math.random()-0.5)*4), speed = math.random()*2})
        end
        
        text.Text = "领域展开"
        TweenService:Create(flash, TweenInfo.new(0.05), {BackgroundTransparency = 0}):Play()
        TweenService:Create(text, TweenInfo.new(0.05), {TextTransparency = 0}):Play()
        task.wait(0.1)
        flash.BackgroundTransparency = 1
        text.Text = "“无量空处”"
        
        TweenService:Create(blackHole, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Size = Vector3.new(30,30,30)}):Play()
        
        local startTime = tick()
        local renderConn
        renderConn = RunService.RenderStepped:Connect(function()
            local t = tick() - startTime
            
            local shake = math.max(0, 1 - t) * 1.5
            local camPos = (hrp.Position + hrp.CFrame.LookVector * -5 + Vector3.new(0, 5, 0))
            local lookAt = dummyPos + Vector3.new(0, 2, 0)
            
            camera.CFrame = CFrame.lookAt(camPos, lookAt) * CFrame.Angles(math.noise(t*50,0,0)*shake, math.noise(0,t*50,0)*shake, math.noise(t*30,t*30,0)*shake)
            camera.FieldOfView = 70 + math.sin(t*15)*15
            
            for _, s in ipairs(shards) do
                local currDist = (s.dist - t * 10) % 15 + 2
                local a = s.angle + t * s.speed
                local pos = blackHole.Position + Vector3.new(math.cos(a)*currDist, math.sin(a)*currDist, math.sin(a*2)*currDist)
                s.part.CFrame = CFrame.lookAt(pos, blackHole.Position) * CFrame.Angles(t*10, t*10, 0)
            end
            
            for _, txt in ipairs(texts) do
                local pos = dHead.Position + txt.offset * (1 - (t * txt.speed % 1)) 
                txt.gui.StudsOffsetWorldSpace = pos - dHead.Position
                txt.label.Text = string.format("%x", math.random(100000, 999999))
            end
        end)
        
        task.wait(4)
        
        if renderConn then renderConn:Disconnect() end
        domainFolder:Destroy()
        cc:Destroy()
        Lighting.Brightness = origBrightness
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