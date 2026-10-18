local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local StarterGui=game:GetService("StarterGui")
local Workspace=game:GetService("Workspace")
local player=Players.LocalPlayer
local camera=Workspace.CurrentCamera

for _,v in pairs(game:GetService("CoreGui"):GetChildren())do if v.Name=="PowerCrownUI" or v.Name=="WindUI" or v.Name=="CinematicUI" or v.Name=="LoadingUI"then v:Destroy()end end
for _,v in pairs(player.PlayerGui:GetChildren())do if v.Name=="PowerCrownUI" or v.Name=="WindUI" or v.Name=="CinematicUI" or v.Name=="LoadingUI"then v:Destroy()end end
for _,v in pairs(Workspace:GetChildren())do if v.Name=="CinematicScene" or v.Name=="PrecisionCockpit" or v.Name=="WormholeFX"then v:Destroy()end end
for _,v in pairs(Lighting:GetChildren())do if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect")then v:Destroy()end end

local s,WindUI=pcall(function()return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))()end)
if not s or not WindUI then StarterGui:SetCore("SendNotification",{Title="加载失败",Text="请检查网络",Duration=10})return end

local Window=WindUI:CreateWindow({Title="封存娱乐 V3.1",Icon="film",Author="Cinematic",Folder="SpaceSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(280,180)})
local MainTab=Window:Tab({Title="控制",Icon="play"})
local CgSection=MainTab:Section({Title="极致电影级体验",Icon="video"})

local isPlaying=false
local sceneOrigin=Vector3.new(0,5000,0)

local function makePart(parent,name,size,color,mat,cf,shape,trans)
    local p=Instance.new("Part")
    p.Name=name;p.Size=size;p.Color=color;p.Material=mat or Enum.Material.SmoothPlastic
    p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false;p.Transparency=trans or 0
    if shape then p.Shape=shape end
    if cf then p.CFrame=cf end
    p.Parent=parent
    return p
end

local function startCinematic()
    if isPlaying then return end
    isPlaying=true
    
    local char=player.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored=true end
    
    local origCamType=camera.CameraType
    local origFOV=camera.FieldOfView
    
    local cc=Instance.new("ColorCorrectionEffect",Lighting)
    cc.Contrast=0.2;cc.Saturation=-0.1;cc.Brightness=-0.1
    
    local blur=Instance.new("BlurEffect",Lighting)
    blur.Size=0
    
    local loadingGui=Instance.new("ScreenGui",player.PlayerGui)
    loadingGui.Name="LoadingUI";loadingGui.IgnoreGuiInset=true;loadingGui.DisplayOrder=1000
    
    local whiteBg=Instance.new("Frame",loadingGui)
    whiteBg.Size=UDim2.fromScale(1,1);whiteBg.BackgroundColor3=Color3.fromRGB(10,10,12);whiteBg.BorderSizePixel=0
    
    local loadText=Instance.new("TextLabel",loadingGui)
    loadText.Size=UDim2.fromScale(1,0.4);loadText.Position=UDim2.fromScale(0,0.2);loadText.BackgroundTransparency=1
    loadText.Text="正在建立深空通讯链接 0%";loadText.TextColor3=Color3.fromRGB(0,200,255);loadText.Font=Enum.Font.GothamBold;loadText.TextSize=28
    
    local barBg=Instance.new("Frame",loadingGui)
    barBg.Size=UDim2.fromOffset(300,10);barBg.Position=UDim2.fromScale(0.5,0.5);barBg.AnchorPoint=Vector2.new(0.5,0.5)
    barBg.BackgroundColor3=Color3.fromRGB(30,30,35);barBg.BorderSizePixel=0
    Instance.new("UICorner",barBg).CornerRadius=UDim.new(1,0)
    
    local barFill=Instance.new("Frame",barBg)
    barFill.Size=UDim2.fromScale(0,1);barFill.BackgroundColor3=Color3.fromRGB(0,200,255);barFill.BorderSizePixel=0
    Instance.new("UICorner",barFill).CornerRadius=UDim.new(1,0)
    
    task.spawn(function()
        local successLoad, errLoad = pcall(function()
            local pFolder=Instance.new("Folder",Workspace)
            pFolder.Name="PrecisionCockpit"
            
            local frameCol=Color3.fromRGB(10,12,15)
            local metal=Enum.Material.Metal
            local baseCF = CFrame.new(sceneOrigin + Vector3.new(0, -5, 0))
            
            local dash=makePart(pFolder,"Dash",Vector3.new(24,6,10),frameCol,metal, baseCF * CFrame.new(0, -5, -8) * CFrame.Angles(math.rad(15), 0, 0))
            RunService.Heartbeat:Wait()
            local dashTop=makePart(pFolder,"DashTop",Vector3.new(22,1,8),Color3.fromRGB(15,18,22), Enum.Material.SmoothPlastic, dash.CFrame * CFrame.new(0, 3.5, 0))
            RunService.Heartbeat:Wait()
            local yoke=makePart(pFolder,"Yoke",Vector3.new(1,4,1),Color3.fromRGB(20,20,20),metal, dash.CFrame * CFrame.new(0, 2, -3) * CFrame.Angles(math.rad(15), 0, 0))
            RunService.Heartbeat:Wait()
            local yokeTop=makePart(pFolder,"YokeTop",Vector3.new(4,0.8,1.5),Color3.fromRGB(25,25,25),metal, yoke.CFrame * CFrame.new(0, 2, 0))
            RunService.Heartbeat:Wait()
            local glassL=makePart(pFolder,"GL",Vector3.new(6,10,0.2),Color3.fromRGB(50,100,150),Enum.Material.Glass, baseCF * CFrame.new(-5, -1, -8) * CFrame.Angles(0, math.rad(15), 0), nil, 0.9)
            RunService.Heartbeat:Wait()
            local glassR=makePart(pFolder,"GR",Vector3.new(6,10,0.2),Color3.fromRGB(50,100,150),Enum.Material.Glass, baseCF * CFrame.new(5, -1, -8) * CFrame.Angles(0, math.rad(-15), 0), nil, 0.9)
            RunService.Heartbeat:Wait()
            
            barFill.Size=UDim2.fromScale(0.15,1); loadText.Text="控制台姿态校准完成 15%"
            
            local sceneFolder=Instance.new("Folder",Workspace)
            sceneFolder.Name="CinematicScene"
            local planets={}
            
            loadText.Text="正在渲染大气层，构建地球..."
            RunService.Heartbeat:Wait()
            local earth=makePart(sceneFolder,"Earth",Vector3.new(1000,1000,1000),Color3.fromRGB(20,60,150),Enum.Material.SmoothPlastic,CFrame.new(sceneOrigin+Vector3.new(6000,0,-12000)),Enum.PartType.Ball)
            RunService.Heartbeat:Wait()
            makePart(sceneFolder,"EAtmo",Vector3.new(1030,1030,1030),Color3.fromRGB(50,150,255),Enum.Material.ForceField,earth.CFrame,Enum.PartType.Ball,0.4)
            RunService.Heartbeat:Wait()
            local eCloud = makePart(sceneFolder,"ECloud",Vector3.new(1010,1010,1010),Color3.fromRGB(220,240,255),Enum.Material.SmoothPlastic,earth.CFrame,Enum.PartType.Ball,0.7)
            RunService.Heartbeat:Wait()
            
            barFill.Size=UDim2.fromScale(0.3,1); loadText.Text="地球构建完成 30%"
            
            loadText.Text="正在注入风暴气旋，构建木星..."
            RunService.Heartbeat:Wait()
            local jupiter=makePart(sceneFolder,"Jupiter",Vector3.new(2400,2400,2400),Color3.fromRGB(200,170,140),Enum.Material.SmoothPlastic,CFrame.new(sceneOrigin+Vector3.new(-8000,3000,-25000)),Enum.PartType.Ball)
            RunService.Heartbeat:Wait()
            for i=1,5 do
                makePart(sceneFolder, "Band", Vector3.new(2420, 100, 2420), Color3.fromRGB(150, 110, 90), Enum.Material.Slate, jupiter.CFrame * CFrame.new(0, (i-3)*300, 0) * CFrame.Angles(0,0,math.rad(90)))
                RunService.Heartbeat:Wait()
            end
            
            barFill.Size=UDim2.fromScale(0.5,1); loadText.Text="木星构建完成 50%"
            
            loadText.Text="正在铺设冰晶星环，构建土星..."
            RunService.Heartbeat:Wait()
            local saturn=makePart(sceneFolder,"Saturn",Vector3.new(1800,1800,1800),Color3.fromRGB(220,200,160),Enum.Material.SmoothPlastic,CFrame.new(sceneOrigin+Vector3.new(10000,-4000,-35000)),Enum.PartType.Ball)
            RunService.Heartbeat:Wait()
            for i=1,3 do
                local ring=makePart(sceneFolder,"Ring",Vector3.new(1800*(2+i*0.3),15,1800*(2+i*0.3)),Color3.fromRGB(150-i*10,130-i*10,100-i*10),Enum.Material.Slate,nil,Enum.PartType.Cylinder,0.2+i*0.1)
                ring.CFrame=saturn.CFrame*CFrame.Angles(math.rad(25),0,math.rad(10))*CFrame.Angles(0,0,math.rad(90))
                RunService.Heartbeat:Wait()
            end
            
            planets={earth=earth,jupiter=jupiter,saturn=saturn}
            barFill.Size=UDim2.fromScale(0.7,1); loadText.Text="土星构建完成 70%"
            
            loadText.Text="正在点亮繁星，构建星海..."
            RunService.Heartbeat:Wait()
            local stars=Instance.new("Folder",sceneFolder)
            
            local starTemplate = makePart(stars, "Star", Vector3.new(25,25,25), Color3.white, Enum.Material.Neon, nil, Enum.PartType.Ball)
            starTemplate.Parent = nil
            
            for i=1,100 do
                local clone = starTemplate:Clone()
                clone.Transparency = math.random(10,80)/100
                clone.CFrame = CFrame.new(sceneOrigin + Vector3.new(math.random(-40000,40000), math.random(-40000,40000), math.random(-80000,-10000)))
                clone.Parent = stars
                if i%10==0 then 
                    barFill.Size=UDim2.fromScale(0.7 + (i/100)*0.15, 1)
                    RunService.Heartbeat:Wait() 
                end
            end
            starTemplate:Destroy()
            
            barFill.Size=UDim2.fromScale(0.85,1); loadText.Text="星空构建完成 85%"
            
            loadText.Text="正在撕开虫洞，建立空间通道..."
            RunService.Heartbeat:Wait()
            local wormhole=Instance.new("Folder",Workspace)
            wormhole.Name="WormholeFX"
            local rings={}
            for i=1,30 do
                local r=makePart(wormhole,"Ring",Vector3.new(5,300,300),Color3.fromRGB(30,60,150),Enum.Material.Neon,nil,Enum.PartType.Cylinder,0.6)
                table.insert(rings,{part=r,dist=i*150})
                if i%10==0 then 
                    barFill.Size=UDim2.fromScale(0.85 + (i/30)*0.15, 1)
                    loadText.Text="正在撕开虫洞 " .. math.floor(85 + (i/30)*15) .. "%"
                    RunService.Heartbeat:Wait()
                end
            end
            
            barFill.Size=UDim2.fromScale(1,1); loadText.Text="全部系统就绪，正在跃迁 100%"
            RunService.Heartbeat:Wait()
            RunService.Heartbeat:Wait()
            
            loadingGui:Destroy()
            
            camera.CameraType=Enum.CameraType.Scriptable
            local startCamPos=hrp.CFrame*CFrame.new(0,5,-15)
            camera.CFrame=startCamPos
            
            local eyeGui=Instance.new("ScreenGui",player.PlayerGui)
            eyeGui.Name="CinematicUI";eyeGui.IgnoreGuiInset=true
            
            local topBar=Instance.new("Frame",eyeGui)
            topBar.Size=UDim2.new(1,0,0.5,0);topBar.Position=UDim2.new(0,0,0,0);topBar.BackgroundColor3=Color3.new(0,0,0);topBar.ZIndex=10
            
            local botBar=Instance.new("Frame",eyeGui)
            botBar.Size=UDim2.new(1,0,0.5,0);botBar.Position=UDim2.new(0,0,0.5,0);botBar.BackgroundColor3=Color3.new(0,0,0);botBar.ZIndex=10
            
            blur.Size=30
            cc.Brightness=-0.5
            
            TweenService:Create(topBar,TweenInfo.new(1.5,Enum.EasingStyle.Quart),{Size=UDim2.new(1,0,0.1,0)}):Play()
            TweenService:Create(botBar,TweenInfo.new(1.5,Enum.EasingStyle.Quart),{Size=UDim2.new(1,0,0.1,0),Position=UDim2.new(0,0,0.9,0)}):Play()
            TweenService:Create(blur,TweenInfo.new(1.5),{Size=0}):Play()
            TweenService:Create(cc,TweenInfo.new(1.5),{Brightness=-0.1}):Play()
            
            local startTime=tick()
            local flightT=0
            
            local boardEnd=3
            local taxiEnd=8
            local warpEnd=11
            local cruiseEnd=28
            
            local startCamCF=startCamPos
            local targetCamCF=CFrame.new(sceneOrigin+Vector3.new(0,-4,-2))
            
            local renderConn
            renderConn=RunService.RenderStepped:Connect(function(dt)
                if not isPlaying then return end
                
                local t=tick()-startTime
                flightT=flightT+dt*200
                
                local cockpit=Workspace:FindFirstChild("PrecisionCockpit")
                if cockpit then
                    local Dash=cockpit:FindFirstChild("Dash")
                    if Dash then
                        Dash.CFrame=camera.CFrame*CFrame.new(0,-6,-8)*CFrame.Angles(math.rad(15),0,0)
                        local DashTop=cockpit:FindFirstChild("DashTop")
                        if DashTop then DashTop.CFrame=Dash.CFrame*CFrame.new(0,3.5,0) end
                        local Yoke=cockpit:FindFirstChild("Yoke")
                        if Yoke then
                            Yoke.CFrame=Dash.CFrame*CFrame.new(0,2,-3)*CFrame.Angles(math.rad(15),0,0)
                            local YokeTop=cockpit:FindFirstChild("YokeTop")
                            if YokeTop then YokeTop.CFrame=Yoke.CFrame*CFrame.new(0,2,0) end
                        end
                    end
                    local GL=cockpit:FindFirstChild("GL")
                    if GL then GL.CFrame=camera.CFrame*CFrame.new(-5,-1,-8)*CFrame.Angles(0,math.rad(15),0) end
                    local GR=cockpit:FindFirstChild("GR")
                    if GR then GR.CFrame=camera.CFrame*CFrame.new(5,-1,-8)*CFrame.Angles(0,math.rad(-15),0) end
                end
                
                if t<boardEnd then
                    local alpha=math.min(t/boardEnd,1)
                    local smoothAlpha=alpha*alpha*(3-2*alpha)
                    camera.CFrame=startCamCF:Lerp(targetCamCF,smoothAlpha)
                    camera.FieldOfView=70-smoothAlpha*5
                    
                elseif t<taxiEnd then
                    camera.CFrame=targetCamCF*CFrame.Angles(math.sin(t*3)*0.005,math.sin(t*2)*0.005,0)
                    camera.FieldOfView=65+math.sin(t*2)*2
                    
                    for i,r in ipairs(rings) do
                        local z=-5000-r.dist+(flightT*0.5)
                        r.part.CFrame=CFrame.new(sceneOrigin+Vector3.new(0,0,z))*CFrame.Angles(0,0,math.rad(90))
                        r.part.Size=Vector3.new(5,300*(1+i/10),300*(1+i/10))
                        r.part.Transparency=math.clamp(0.3+(i/40),0,0.9)
                    end
                    
                    if t>5.5 then
                        local warpUp=(t-5.5)/(taxiEnd-5.5)
                        blur.Size=warpUp*20
                        cc.TintColor=Color3.fromRGB(150,170+warpUp*50,200+warpUp*55)
                        camera.FieldOfView=65+warpUp*30
                    end
                    
                elseif t<warpEnd then
                    local warp=(t-taxiEnd)/(warpEnd-taxiEnd)
                    camera.FieldOfView=95+warp*40
                    blur.Size=20+warp*30
                    cc.TintColor=Color3.white
                    cc.Contrast=warp*2
                    
                elseif t<cruiseEnd then
                    blur.Size=0
                    cc.TintColor=Color3.fromRGB(150,170,200)
                    cc.Contrast=0.2
                    
                    local cruiseTime=t-warpEnd
                    local totalCruise=cruiseEnd-warpEnd
                    local progress=math.min(cruiseTime/totalCruise,1)
                    
                    local startPos=sceneOrigin+Vector3.new(0,-4,-2)
                    local pathPos
                    local lookAt
                    
                    if progress<0.33 then
                        local p=progress/0.33
                        pathPos=startPos:Lerp(planets.earth.CFrame.Position+Vector3.new(1000,0,1000),p)
                        lookAt=planets.earth.CFrame.Position
                    elseif progress<0.66 then
                        local p=(progress-0.33)/0.33
                        pathPos=(planets.earth.CFrame.Position+Vector3.new(1000,0,1000)):Lerp(planets.jupiter.CFrame.Position+Vector3.new(2400,0,2400),p)
                        lookAt=planets.jupiter.CFrame.Position
                    else
                        local p=(progress-0.66)/0.34
                        pathPos=(planets.jupiter.CFrame.Position+Vector3.new(2400,0,2400)):Lerp(planets.saturn.CFrame.Position+Vector3.new(1800,0,1800),p)
                        lookAt=planets.saturn.CFrame.Position
                    end
                    
                    local camCF=CFrame.lookAt(pathPos,lookAt)
                    local shake=0.02+math.sin(cruiseTime*8)*0.01
                    camCF=camCF*CFrame.Angles(math.noise(cruiseTime*20,0,0)*shake,math.noise(0,cruiseTime*20,0)*shake,0)
                    
                    camera.CFrame=camCF
                    camera.FieldOfView=70+math.sin(cruiseTime*1.5)*5
                    
                else
                    cc.Saturation=-1
                    cc.Contrast=1
                    blur.Size=20
                    topBar.Size=UDim2.new(1,0,0,0)
                    botBar.Size=UDim2.new(1,0,0,0)
                    
                    if t>cruiseEnd+2 then
                        renderConn:Disconnect()
                        sceneFolder:Destroy()
                        wormhole:Destroy()
                        if cockpit then cockpit:Destroy() end
                        eyeGui:Destroy()
                        cc:Destroy()
                        blur:Destroy()
                        
                        camera.CameraType=origCamType
                        camera.FieldOfView=origFOV
                        if hrp then hrp.Anchored=false end
                        isPlaying=false
                    end
                end
            end)
        end)
        
        if not successLoad then
            warn("Cinematic Error: ", errLoad)
            loadingGui:Destroy()
            if hrp then hrp.Anchored=false end
            isPlaying=false
            StarterGui:SetCore("SendNotification",{Title="生成失败",Text="模型生成超时",Duration=5})
        end
    end)
end

CgSection:Button({Title="启动星际巡航",Callback=function()
    if not isPlaying then
        startCinematic()
    end
end})