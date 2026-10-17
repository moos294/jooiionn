local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Debris=game:GetService("Debris")
local Lighting=game:GetService("Lighting")
local StarterGui=game:GetService("StarterGui")
local SoundService=game:GetService("SoundService")
local Workspace=game:GetService("Workspace")
local player=Players.LocalPlayer
local camera=Workspace.CurrentCamera
local success,WindUI=pcall(function() return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))() end)
if not success or not WindUI then StarterGui:SetCore("SendNotification",{Title="UI加载失败",Text="网络拦截",Duration=10}) return end

local Cfg={AutoTrain=false,TrainAction="Dumbbell",TrainActionCN="哑铃",TrainInterval=0.2,AutoRebirth=false,TargetStrength=10000,RebirthInc=10000,Fly=false,FlySpeed=50,WalkSpeed=16,AntiAfk=true,TotalReps=0,ScriptStartTime=tick()}
local ActionMap={["俯卧撑"]="PushUp",["哑铃"]="Dumbbell",["肩部推举1"]="ShoulderPress_1",["肩部推举2"]="ShoulderPress_2",["肩部推举3"]="ShoulderPress_3",["跑步机1"]="TrendMill_1",["平躺卧推1"]="FlatBench_1",["平躺卧推L1"]="FlatBench_L1",["平躺卧推K1"]="FlatBench_K1",["举石1"]="Rock_1",["举石2"]="Rock_2",["举石3"]="Rock_3",["杠铃架L1"]="BarbellRack_L1",["杠铃架S1"]="BarbellRack_S1",["杠铃架1"]="BarbellRack_1",["杠铃架2"]="BarbellRack_2",["卧推L1"]="BenchPress_L1",["卧推1"]="BenchPress_1",["卧推2"]="BenchPress_2",["红史莱姆"]="Red slime",["天空史莱姆"]="SkySlime"}
local ActionListCN={}
for cn,_ in pairs(ActionMap)do table.insert(ActionListCN,cn)end
table.sort(ActionListCN)

local function corner(p,r)local c=Instance.new("UICorner")c.CornerRadius=UDim.new(0,r or 8)c.Parent=p return c end
local function fmt(n)n=math.floor(tonumber(n)or 0)local s=tostring(n)local out=s:reverse():gsub("(%d%d%d)","%1,"):reverse()if out:sub(1,1)==","then out=out:sub(2)end return out end
local function getCurrentStrength()local str=0 pcall(function()local attr=player:GetAttribute("Strength")or player:GetAttribute("Power")if attr then str=attr return end if player.leaderstats then local ls=player.leaderstats if ls:FindFirstChild("Strength")then str=ls.Strength.Value return end if ls:FindFirstChild("Power")then str=ls.Power.Value return end end end)return str end
local function getCurrentRebirths()local count=0 pcall(function()local attr=player:GetAttribute("Rebirths")or player:GetAttribute("Rebirth")if attr then count=attr return end if player.leaderstats then for _,n in ipairs({"Rebirths","Rebirth","RebirthCount","Prestige"})do if player.leaderstats:FindFirstChild(n)then count=player.leaderstats[n].Value return end end end end)return count end
local function applyAntiIdleKick()if not getconnections then return end pcall(function()for _,conn in next,getconnections(player.Idled)do pcall(function()conn:Disable()end)pcall(function()conn:Disconnect()end)end end)end

local Window=WindUI:CreateWindow({Title="力量之冠 V6.1 终极稳定版",Icon="zap",Author="力量之冠",Folder="PowerCrownSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(460,780)})
local MainTab=Window:Tab({Title="控制面板",Icon="settings"})
local TrainSection=MainTab:Section({Title="🏋️ 自动锻炼",Icon="activity"})
TrainSection:Toggle({Title="自动锻炼",Value=false,Callback=function(state)Cfg.AutoTrain=state end})
TrainSection:Dropdown({Title="选择动作",Values=ActionListCN,Value="哑铃",Callback=function(selected)local en=ActionMap[selected]if en then Cfg.TrainAction=en Cfg.TrainActionCN=selected end end})
local TrainStatus=TrainSection:Paragraph({Title="锻炼状态",Desc="待机中..."})
local RebirthSection=MainTab:Section({Title="💀 自动重生",Icon="refresh-cw"})
RebirthSection:Toggle({Title="开启自动重生",Value=false,Callback=function(state)Cfg.AutoRebirth=state end})
RebirthSection:Input({Title="目标力量",Value="10000",Callback=function(text)Cfg.TargetStrength=tonumber(text)or 10000 end})
local RebirthStatus=RebirthSection:Paragraph({Title="重生状态",Desc="待机中..."})
local MoveSection=MainTab:Section({Title="⚡ 移动与反挂机",Icon="move"})
MoveSection:Toggle({Title="飞行模式",Value=false,Callback=function(state)Cfg.Fly=state end})
MoveSection:Slider({Title="步行速度",Value={Min=16,Max=500,Default=16},Step=1,Callback=function(value)Cfg.WalkSpeed=value local char=player.Character if char then local hum=char:FindFirstChildOfClass("Humanoid")if hum then hum.WalkSpeed=value end end end})
MoveSection:Toggle({Title="强力反挂机",Value=true,Callback=function(state)Cfg.AntiAfk=state end})

local FunTab=Window:Tab({Title="娱乐区",Icon="sparkles"})
local GojoSection=FunTab:Section({Title="五条悟专属 (领域展开)",Icon="sparkles"})
GojoSection:Button({Title="变身五条悟 (获取物品)",Callback=function()if _G.GiveGojoTool then _G.GiveGojoTool() end end})

local SG=Instance.new("ScreenGui")SG.Name="PowerCrownUI"SG.ResetOnSpawn=false SG.IgnoreGuiInset=true
pcall(function()SG.Parent=game:GetService("CoreGui")end)if not SG.Parent then SG.Parent=player.PlayerGui end
local DataHUD=Instance.new("Frame")DataHUD.Size=UDim2.new(0,210,0,105)DataHUD.Position=UDim2.new(0,20,0.3,0)DataHUD.BackgroundColor3=Color3.fromRGB(20,24,34)DataHUD.BackgroundTransparency=0.1 DataHUD.BorderSizePixel=0 DataHUD.Parent=SG corner(DataHUD,10)
local HUDTitle=Instance.new("TextLabel")HUDTitle.Size=UDim2.new(1,0,0,24)HUDTitle.BackgroundTransparency=1 HUDTitle.Text="📊 力量之冠 V6.1"HUDTitle.TextColor3=Color3.fromRGB(60,150,230)HUDTitle.Font=Enum.Font.GothamBold HUDTitle.TextSize=12 HUDTitle.Parent=DataHUD
local LabelReps=Instance.new("TextLabel")LabelReps.Size=UDim2.new(0.5,-10,0,18)LabelReps.Position=UDim2.new(0,10,0,30)LabelReps.BackgroundTransparency=1 LabelReps.Text="总训练: 0"LabelReps.TextColor3=Color3.fromRGB(230,230,235)LabelReps.Font=Enum.Font.Gotham LabelReps.TextSize=11 LabelReps.TextXAlignment=Enum.TextXAlignment.Left LabelReps.Parent=DataHUD
local LabelRebirth=Instance.new("TextLabel")LabelRebirth.Size=UDim2.new(0.5,-10,0,18)LabelRebirth.Position=UDim2.new(0,10,0,50)LabelRebirth.BackgroundTransparency=1 LabelRebirth.Text="总转生: 0"LabelRebirth.TextColor3=Color3.fromRGB(230,230,235)LabelRebirth.Font=Enum.Font.Gotham LabelRebirth.TextSize=11 LabelRebirth.TextXAlignment=Enum.TextXAlignment.Left LabelRebirth.Parent=DataHUD
local dragging,dragInput,dragStart,startPos
DataHUD.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true dragStart=input.Position startPos=DataHUD.Position input.Changed:Connect(function()if input.UserInputState==Enum.UserInputState.End then dragging=false end end)end end)
DataHUD.InputChanged:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end end)
UserInputService.InputChanged:Connect(function(input)if input==dragInput and dragging then local delta=input.Position-dragStart DataHUD.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)end end)

local flying,flyBV,flyBG=false,nil,nil
RunService.RenderStepped:Connect(function()
    if not Cfg.Fly then if flying then flying=false local c=player.Character if c then local h=c:FindFirstChildOfClass("Humanoid")if h then h.PlatformStand=false end end if flyBV then flyBV:Destroy()flyBV=nil end if flyBG then flyBG:Destroy()flyBG=nil end end return end
    if not flying then local c=player.Character if not c then return end local hrp=c:FindFirstChild("HumanoidRootPart")if not hrp then return end local h=c:FindFirstChildOfClass("Humanoid")if h then h.PlatformStand=true end flyBV=Instance.new("BodyVelocity")flyBV.MaxForce=Vector3.new(1e5,1e5,1e5)flyBV.Parent=hrp flyBG=Instance.new("BodyGyro")flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5)flyBG.P=3000 flyBG.D=500 flyBG.Parent=hrp flying=true end
    local c=player.Character if not c then return end local hrp=c:FindFirstChild("HumanoidRootPart")if not hrp or not flyBV or not flyBG then return end
    local dir=Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W)then dir=dir+camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S)then dir=dir-camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A)then dir=dir-camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D)then dir=dir+camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space)then dir=dir+Vector3.new(0,1,0)end
    if dir.Magnitude>0 then dir=dir.Unit*Cfg.FlySpeed end
    flyBV.Velocity=dir flyBG.CFrame=CFrame.new(hrp.Position,hrp.Position+camera.CFrame.LookVector)
end)

task.spawn(function()local trainEvent pcall(function()trainEvent=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TrainEvent")end)while true do task.wait(Cfg.TrainInterval)if Cfg.AutoTrain and trainEvent then pcall(function()trainEvent:FireServer(Cfg.TrainAction)Cfg.TotalReps=Cfg.TotalReps+1 TrainStatus:SetDesc("锻炼: "..Cfg.TrainActionCN)end)end end end)
task.spawn(function()local rebirthEvent pcall(function()rebirthEvent=ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RebirthEvent")end)while true do task.wait(0.1)if Cfg.AutoRebirth and rebirthEvent then pcall(function()if getCurrentStrength()>=Cfg.TargetStrength then rebirthEvent:FireServer("Update")Cfg.TargetStrength=Cfg.TargetStrength+Cfg.RebirthInc RebirthStatus:SetDesc("进度: "..getCurrentRebirths())end end)end end end)
task.spawn(function()while SG.Parent do task.wait(10)if Cfg.AntiAfk then pcall(function()local VIM=game:GetService("VirtualInputManager")VIM:SendKeyEvent(Enum.KeyCode.Space,true,false,game)task.wait(0.05)VIM:SendKeyEvent(Enum.KeyCode.Space,false,false,game)VIM:SendMouseMoveEvent(0,0,game)task.wait(0.05)VIM:SendMouseMoveEvent(1,1,game)end)end end end)
task.spawn(function()while SG.Parent do local et=tick()-Cfg.ScriptStartTime LabelReps.Text="总训练: "..fmt(Cfg.TotalReps)LabelRebirth.Text="总转生: "..fmt(getCurrentRebirths())task.wait(0.5)end end)
if player.Character then local hum=player.Character:FindFirstChildOfClass("Humanoid")if hum then hum.WalkSpeed=Cfg.WalkSpeed end end
applyAntiIdleKick()

task.spawn(function()
local fxFolder=Instance.new("Folder")fxFolder.Name="SpaceCannonFX"fxFolder.Parent=Workspace
local function new(class,props,parent)local inst=Instance.new(class)for k,v in pairs(props)do inst[k]=v end if parent then inst.Parent=parent end return inst end
local function vpart(props,parent)local p=new("Part",{Anchored=true,CanCollide=false,CanQuery=false,CanTouch=false,CastShadow=false,Material=Enum.Material.SmoothPlastic,TopSurface=Enum.SurfaceType.Smooth,BottomSurface=Enum.SurfaceType.Smooth},nil)for k,v in pairs(props)do p[k]=v end p.Parent=parent return p end
local function tween(inst,time,props,style,dir)local tw=TweenService:Create(inst,TweenInfo.new(time,style or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),props)tw:Play()return tw end
local function playSound(id,volume,speed,looped)if type(id)=="table"then id=id.fallback end if not id or id==""then return nil end local s=new("Sound",{SoundId=id,Volume=volume or 1,PlaybackSpeed=speed or 1,Looped=looped or false},SoundService)pcall(function()s:Play()end)if not looped then Debris:AddItem(s,10)end return s end
local state="idle" local lastFire=-1e9
local function setControls(enabled)pcall(function()local pm=require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))local c=pm:GetControls()if enabled then c:Enable()else c:Disable()end end)end
local SOUNDS={charge={file="audio/star_gun.mp3",fallback="rbxasset://sounds/Rocket whoosh 01.wav"},boom={file="audio/star_impact.mp3",fallback="rbxasset://sounds/impact_explosion_03.mp3"}}

_G.GiveGojoTool=function()
    if player.Backpack:FindFirstChild("无量空处") or (player.Character and player.Character:FindFirstChild("无量空处")) then
        WindUI:Notify({Title="提示",Content="已在背包中拥有无量空处！",Duration=3})
        return
    end
    local tool=Instance.new("Tool")
    tool.Name="无量空处"
    tool.RequiresHandle=true
    tool.CanBeDropped=false
    local handle=Instance.new("Part")
    handle.Name="Handle"
    handle.Size=Vector3.new(1.5,1.5,1.5)
    handle.Shape=Enum.PartType.Ball
    handle.Material=Enum.Material.Neon
    handle.Color=Color3.fromRGB(150,0,255)
    handle.CanCollide=false
    handle.Parent=tool
    local light=Instance.new("PointLight",handle)
    light.Color=Color3.fromRGB(150,0,255)
    light.Range=15
    light.Brightness=2
    tool.Activated:Connect(function()
        local char=player.Character
        if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        local humanoid=char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end
        if state=="cinematic" then return end
        state="cinematic"
        setControls(false)
        local startCF=camera.CFrame
        camera.CameraType=Enum.CameraType.Scriptable
        local facePos=char:FindFirstChild("Head") and char.Head.Position or(hrp.Position+Vector3.new(0,1.5,0))
        local faceCF=CFrame.lookAt(facePos+hrp.CFrame.LookVector*4,facePos)
        tween(camera,0.5,{CFrame=faceCF},Enum.EasingStyle.Exponential)
        humanoid.PlatformStand=true
        task.wait(0.6)
        playSound(SOUNDS.charge,2,0.4)
        local castGui=Instance.new("ScreenGui",player.PlayerGui)
        local fullWhite=Instance.new("Frame",castGui)
        fullWhite.Size=UDim2.fromScale(1,1)
        fullWhite.BackgroundColor3=Color3.fromRGB(255,255,255)
        fullWhite.BackgroundTransparency=0
        fullWhite.ZIndex=200
        for i=1,5 do
            fullWhite.BackgroundColor3=Color3.fromRGB(255,50,50)
            task.wait(0.05)
            fullWhite.BackgroundColor3=Color3.fromRGB(255,255,255)
            task.wait(0.05)
        end
        local speedLines=Instance.new("Folder",fxFolder)
        for i=1,200 do
            local line=vpart({Size=Vector3.new(math.random(1,4),math.random(50,150),1),Material=Enum.Material.Neon,Color=math.random(1,3)==1 and Color3.fromRGB(255,255,255)or Color3.fromRGB(255,30,30),Transparency=math.random(0,0.5)},speedLines)
            local angle=math.random()*math.pi*2
            local dist=math.random(200,1000)
            local heightOffset=math.random(-500,500)
            line.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(angle)*dist,heightOffset,math.sin(angle)*dist))*CFrame.lookAt(hrp.Position+Vector3.new(0,heightOffset,0))
            tween(line,1.5,{Position=line.Position+line.CFrame.LookVector*-2000,Transparency=1},Enum.EasingStyle.Linear)
        end
        local savedClock=Lighting.ClockTime
        Lighting.ClockTime=0
        local cc=Instance.new("ColorCorrectionEffect",Lighting)
        cc.Saturation=-1
        cc.Contrast=2
        local blackHole=vpart({Shape=Enum.PartType.Ball,Size=Vector3.new(10,10,10),Position=hrp.Position+hrp.CFrame.LookVector*50+Vector3.new(0,15,0),Material=Enum.Material.SmoothPlastic,Color=Color3.fromRGB(0,0,0)},fxFolder)
        tween(blackHole,1,{Size=Vector3.new(300,300,300)},Enum.EasingStyle.Exponential)
        local nebula=Instance.new("Folder",fxFolder)
        for i=1,60 do
            local cloud=vpart({Shape=Enum.PartType.Ball,Size=Vector3.new(math.random(40,120),math.random(40,120),math.random(40,120)),Material=Enum.Material.Neon,Color=math.random(1,3)==1 and Color3.fromRGB(150,220,255)or Color3.fromRGB(255,255,255),Transparency=math.random(0.5,0.9)},nebula)
            local angle=math.random()*math.pi*2
            local radius=math.random(150,400)
            cloud.Position=blackHole.Position+Vector3.new(math.cos(angle)*radius,math.random(-100,100),math.sin(angle)*radius)
            task.spawn(function()
                local rot=0
                while cloud.Parent do
                    rot+=0.02
                    cloud.Position=blackHole.Position+Vector3.new(math.cos(angle+rot)*radius,cloud.Position.Y-blackHole.Position.Y,math.sin(angle+rot)*radius)
                    RunService.Heartbeat:Wait()
                end
            end)
        end
        local camLookCF=CFrame.lookAt(hrp.Position+Vector3.new(0,5,0),blackHole.Position)
        tween(camera,1,{CFrame=camLookCF},Enum.EasingStyle.Quart)
        local textBg=Instance.new("Frame",castGui)
        textBg.Size=UDim2.fromScale(1,1)
        textBg.BackgroundColor3=Color3.fromRGB(0,0,0)
        textBg.BackgroundTransparency=0.5
        local text1=Instance.new("TextLabel",textBg)
        text1.Size=UDim2.new(0,800,0,100)
        text1.Position=UDim2.new(0.5,-400,0.3,0)
        text1.BackgroundTransparency=1
        text1.Text="发生了什么...\n我的大脑..."
        text1.TextColor3=Color3.fromRGB(255,255,255)
        text1.Font=Enum.Font.GothamBlack
        text1.TextSize=50
        text1.TextStrokeTransparency=0.5
        local t0=os.clock()
        task.spawn(function()
            while os.clock()-t0<3.5 do
                camera.CFrame=camLookCF*CFrame.new(math.random(-15,15),math.random(-15,15),0)
                RunService.RenderStepped:Wait()
            end
        end)
        playSound(SOUNDS.boom,3,0.5)
        task.wait(3.5)
        castGui:Destroy()
        speedLines:Destroy()
        nebula:Destroy()
        blackHole:Destroy()
        cc:Destroy()
        Lighting.ClockTime=savedClock
        camera.CFrame=startCF
        camera.CameraType=Enum.CameraType.Custom
        if humanoid then humanoid.PlatformStand=false end
        setControls(true)
        state="idle"
    end)
    tool.Parent=player.Backpack
    WindUI:Notify({Title="获取成功",Content="已获得『无量空处』，装备后点击屏幕释放！",Duration=5})
end
end)