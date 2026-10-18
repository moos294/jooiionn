local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local StarterGui=game:GetService("StarterGui")
local Workspace=game:GetService("Workspace")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local camera=Workspace.CurrentCamera

for _,v in pairs(game:GetService("CoreGui"):GetChildren())do if v.Name=="PowerCrownUI" or v.Name=="CinematicUI" or v.Name=="LoadingUI"then v:Destroy()end end
for _,v in pairs(player.PlayerGui:GetChildren())do if v.Name=="PowerCrownUI" or v.Name=="CinematicUI" or v.Name=="LoadingUI"then v:Destroy()end end
for _,v in pairs(Workspace:GetChildren())do if v.Name=="CinematicScene" or v.Name=="PrecisionCockpit" or v.Name=="WormholeFX"then v:Destroy()end end
for _,v in pairs(Lighting:GetChildren())do if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect")then v:Destroy()end end

local gui = Instance.new("ScreenGui")
gui.Name = "PowerCrownUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = player.PlayerGui end

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.fromOffset(260, 120)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 1.5

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Text = "封存娱乐 V4.0"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Active = false

local minimizeBtn = Instance.new("TextButton", mainFrame)
minimizeBtn.Size = UDim2.fromOffset(30, 30)
minimizeBtn.Position = UDim2.new(1, -35, 0, 5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
minimizeBtn.TextSize = 30
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.AutoButtonColor = false

local startBtn = Instance.new("TextButton", mainFrame)
startBtn.Size = UDim2.new(0.8, 0, 0, 40)
startBtn.Position = UDim2.new(0.1, 0, 0, 60)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
startBtn.Text = "启动星际巡航"
startBtn.TextColor3 = Color3.new(1, 1, 1)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 16
startBtn.AutoButtonColor = false
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 8)

local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end

mainFrame.InputBegan:Connect(updateDrag)
minimizeBtn.InputBegan:Connect(updateDrag)
startBtn.InputBegan:Connect(updateDrag)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.fromOffset(40, 40)}):Play()
        TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(startBtn, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        minimizeBtn.Text = "+"
        minimizeBtn.Size = UDim2.fromOffset(40, 40)
        minimizeBtn.Position = UDim2.new(0, 0, 0, 0)
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.fromOffset(260, 120)}):Play()
        TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(startBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        minimizeBtn.Text = "-"
        minimizeBtn.Size = UDim2.fromOffset(30, 30)
        minimizeBtn.Position = UDim2.new(1, -35, 0, 5)
    end
end)

local isPlaying = false
local sceneOrigin = Vector3.new(0, 50000, 0)
local buildQueue = {}
local isBuilding = false

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
    isPlaying = true
    mainFrame.Visible = false
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
    
    local origCamType = camera.CameraType
    local origFOV = camera.FieldOfView
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Contrast = 0.2; cc.Saturation = -0.1; cc.Brightness = -0.1
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    local loadingGui = Instance.new("ScreenGui", player.PlayerGui)
    loadingGui.Name = "LoadingUI"; loadingGui.IgnoreGuiInset = true; loadingGui.DisplayOrder = 1000
    
    local whiteBg = Instance.new("Frame", loadingGui)
    whiteBg.Size = UDim2.fromScale(1,1); whiteBg.BackgroundColor3 = Color3.fromRGB(10,10,12); whiteBg.BorderSizePixel = 0
    
    local loadText = Instance.new("TextLabel", loadingGui)
    loadText.Size = UDim2.fromScale(1,0.4); loadText.Position = UDim2.fromScale(0,0.2); loadText.BackgroundTransparency = 1
    loadText.Text = "系统初始化..."; loadText.TextColor3 = Color3.fromRGB(0,200,255); loadText.Font = Enum.Font.GothamBold; loadText.TextSize = 28
    
    local barBg = Instance.new("Frame", loadingGui)
    barBg.Size = UDim2.fromOffset(300,10); barBg.Position = UDim2.fromScale(0.5,0.5); barBg.AnchorPoint = Vector2.new(0.5,0.5)
    barBg.BackgroundColor3 = Color3.fromRGB(30,30,35); barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1,0)
    
    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.fromScale(0,1); barFill.BackgroundColor3 = Color3.fromRGB(0,200,255); barFill.BorderSizePixel = 0
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1,0)
    
    local pFolder = Instance.new("Folder", Workspace)
    pFolder.Name = "PrecisionCockpit"
    local sceneFolder = Instance.new("Folder", Workspace)
    sceneFolder.Name = "CinematicScene"
    local wormhole = Instance.new("Folder", Workspace)
    wormhole.Name = "WormholeFX"
    
    local baseCF = CFrame.new(sceneOrigin + Vector3.new(0, -5, 0))
    local planets = {}
    
    table.clear(buildQueue)
    
    table.insert(buildQueue, function()
        makePart(pFolder,"Dash",Vector3.new(24,6,10),Color3.fromRGB(10,12,15),Enum.Material.Metal, baseCF * CFrame.new(0, -5, -8) * CFrame.Angles(math.rad(15), 0, 0))
    end)
    table.insert(buildQueue, function()
        local dash = pFolder:FindFirstChild("Dash")
        makePart(pFolder,"DashTop",Vector3.new(22,1,8),Color3.fromRGB(15,18,22), Enum.Material.SmoothPlastic, dash.CFrame * CFrame.new(0, 3.5, 0))
    end)
    table.insert(buildQueue, function()
        local dash = pFolder:FindFirstChild("Dash")
        makePart(pFolder,"Yoke",Vector3.new(1,4,1),Color3.fromRGB(20,20,20),Enum.Material.Metal, dash.CFrame * CFrame.new(0, 2, -3) * CFrame.Angles(math.rad(15), 0, 0))
    end)
    table.insert(buildQueue, function()
        local yoke = pFolder:FindFirstChild("Yoke")
        makePart(pFolder,"YokeTop",Vector3.new(4,0.8,1.5),Color3.fromRGB(25,25,25),Enum.Material.Metal, yoke.CFrame * CFrame.new(0, 2, 0))
    end)
    table.insert(buildQueue, function()
        makePart(pFolder,"GL",Vector3.new(6,10,0.2),Color3.fromRGB(50,100,150),Enum.Material.Glass, baseCF * CFrame.new(-5, -1, -8) * CFrame.Angles(0, math.rad(15), 0), nil, 0.9)
    end)
    table.insert(buildQueue, function()
        makePart(pFolder,"GR",Vector3.new(6,10,0.2),Color3.fromRGB(50,100,150),Enum.Material.Glass, baseCF * CFrame.new(5, -1, -8) * CFrame.Angles(0, math.rad(-15), 0), nil, 0.9)
    end)
    table.insert(buildQueue, function()
        for i=1,20 do
            local btn=makePart(pFolder,"Btn",Vector3.new(0.3,0.1,0.3),i%3==0 and Color3.fromRGB(255,50,50) or Color3.fromRGB(50,255,50),Enum.Material.Neon)
            local dashTop=pFolder:FindFirstChild("DashTop")
            local r=math.floor((i-1)/5)
            local c=(i-1)%5
            btn.CFrame=dashTop.CFrame*CFrame.new((c-2)*1.5,0.6,(r-1.5)*1)
        end
    end)

    local pDefs = {
        {name="Sun", pos=Vector3.new(0, 0, -80000), size=8000, col=Color3.fromRGB(255,200,100), mat=Enum.Material.Neon, isSun=true},
        {name="Mercury", pos=Vector3.new(10000, 2000, -30000), size=400, col=Color3.fromRGB(120,120,120)},
        {name="Venus", pos=Vector3.new(-15000, -3000, -45000), size=800, col=Color3.fromRGB(220,180,120)},
        {name="Earth", pos=Vector3.new(20000, 5000, -60000), size=1000, col=Color3.fromRGB(20,60,150)},
        {name="Mars", pos=Vector3.new(-25000, -8000, -75000), size=700, col=Color3.fromRGB(150,50,40)},
        {name="Jupiter", pos=Vector3.new(30000, 10000, -90000), size=4000, col=Color3.fromRGB(200,170,140)},
        {name="Saturn", pos=Vector3.new(-35000, -12000, -105000), size=3500, col=Color3.fromRGB(220,200,160)},
        {name="Uranus", pos=Vector3.new(40000, 15000, -120000), size=2000, col=Color3.fromRGB(100,200,220)},
        {name="Neptune", pos=Vector3.new(-45000, -18000, -135000), size=1900, col=Color3.fromRGB(50,100,230)},
        {name="Pluto", pos=Vector3.new(50000, 20000, -150000), size=500, col=Color3.fromRGB(150,150,150)}
    }

    for _, def in ipairs(pDefs) do
        table.insert(buildQueue, function()
            local p = makePart(sceneFolder, def.name, Vector3.new(def.size,def.size,def.size), def.col, def.mat or Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin+def.pos), Enum.PartType.Ball)
            planets[def.name] = p
            if def.isSun then
                local l = Instance.new("PointLight", p)
                l.Range = 100000
                l.Brightness = 3
            elseif def.name == "Earth" then
                makePart(sceneFolder, "EarthAtmo", Vector3.new(1030,1030,1030), Color3.fromRGB(50,150,255), Enum.Material.ForceField, p.CFrame, Enum.PartType.Ball, 0.5)
            elseif def.name == "Saturn" then
                for i=1,3 do
                    local r = makePart(sceneFolder, "Ring", Vector3.new(3500*(2+i*0.4), 20, 3500*(2+i*0.4)), Color3.fromRGB(180-i*20, 160-i*20, 130-i*20), Enum.Material.Slate, nil, Enum.PartType.Cylinder, 0.3)
                    r.CFrame = p.CFrame * CFrame.Angles(math.rad(25),0,math.rad(10)) * CFrame.Angles(0,0,math.rad(90))
                end
            end
        end)
    end

    table.insert(buildQueue, function()
        local belt = Instance.new("Folder", sceneFolder)
        belt.Name = "AsteroidBelt"
        for i=1,150 do
            local a = makePart(belt, "Asteroid", Vector3.new(math.random(100,300), math.random(100,300), math.random(100,300)), Color3.fromRGB(80,80,80), Enum.Material.Rock, CFrame.new(sceneOrigin+Vector3.new(math.random(-20000,20000), math.random(-5000,5000), math.random(-35000,-25000))) * CFrame.Angles(math.random(0,6),math.random(0,6),math.random(0,6)))
        end
    end)

    table.insert(buildQueue, function()
        local galaxy = Instance.new("Folder", sceneFolder)
        galaxy.Name = "Galaxy"
        for i=1,300 do
            local s = makePart(galaxy, "Star", Vector3.new(50,50,50), Color3.white, Enum.Material.Neon, CFrame.new(sceneOrigin+Vector3.new(math.random(-150000,150000), math.random(-150000,150000), math.random(-200000,-100000))), Enum.PartType.Ball, math.random(10,80)/100)
        end
    end)

    for i=1,50 do
        table.insert(buildQueue, function()
            local r = makePart(wormhole,"Ring",Vector3.new(20,600,600),Color3.fromRGB(30,100,255),Enum.Material.Neon,nil,Enum.PartType.Cylinder,0.4)
            r.CFrame = CFrame.new(sceneOrigin + Vector3.new(0,0,-5000 + i*150)) * CFrame.Angles(0,0,math.rad(90))
        end)
    end

    isBuilding = true
    local totalTasks = #buildQueue
    local completedTasks = 0
    
    local buildConn
    buildConn = RunService.Heartbeat:Connect(function()
        if not isBuilding then return end
        
        if #buildQueue > 0 then
            local taskFunc = table.remove(buildQueue, 1)
            pcall(taskFunc)
            completedTasks = completedTasks + 1
            barFill.Size = UDim2.fromScale(completedTasks / totalTasks, 1)
            loadText.Text = "全星系模型构建 " .. math.floor((completedTasks / totalTasks) * 100) .. "%"
        else
            isBuilding = false
            buildConn:Disconnect()
            
            loadText.Text = "加载完毕，准备跃迁"
            task.wait(1)
            loadingGui:Destroy()
            
            camera.CameraType = Enum.CameraType.Scriptable
            local startCamPos = hrp.CFrame * CFrame.new(0,5,-15)
            camera.CFrame = startCamPos
            
            local eyeGui = Instance.new("ScreenGui",player.PlayerGui)
            eyeGui.Name = "CinematicUI"; eyeGui.IgnoreGuiInset = true
            
            local topBar = Instance.new("Frame",eyeGui)
            topBar.Size=UDim2.new(1,0,0.5,0); topBar.Position=UDim2.new(0,0,0,0); topBar.BackgroundColor3=Color3.new(0,0,0); topBar.ZIndex=10
            
            local botBar = Instance.new("Frame",eyeGui)
            botBar.Size=UDim2.new(1,0,0.5,0); botBar.Position=UDim2.new(0,0,0.5,0); botBar.BackgroundColor3=Color3.new(0,0,0); botBar.ZIndex=10
            
            blur.Size = 30
            cc.Brightness = -0.5
            
            TweenService:Create(topBar,TweenInfo.new(1.5,Enum.EasingStyle.Quart),{Size=UDim2.new(1,0,0.1,0)}):Play()
            TweenService:Create(botBar,TweenInfo.new(1.5,Enum.EasingStyle.Quart),{Size=UDim2.new(1,0,0.1,0),Position=UDim2.new(0,0,0.9,0)}):Play()
            TweenService:Create(blur,TweenInfo.new(1.5),{Size=0}):Play()
            TweenService:Create(cc,TweenInfo.new(1.5),{Brightness=-0.1}):Play()
            
            local startTime = tick()
            local flightT = 0
            local boardEnd = 3
            local taxiEnd = 8
            local warpEnd = 12
            local cruiseEnd = 40
            
            local startCamCF = startCamPos
            local targetCamCF = CFrame.new(sceneOrigin + Vector3.new(0,-4,-2))
            
            local renderConn
            renderConn = RunService.RenderStepped:Connect(function(dt)
                if not isPlaying then return end
                
                local t = tick() - startTime
                flightT = flightT + dt * 200
                
                local cockpit = Workspace:FindFirstChild("PrecisionCockpit")
                if cockpit then
                    local Dash = cockpit:FindFirstChild("Dash")
                    if Dash then
                        Dash.CFrame = camera.CFrame * CFrame.new(0,-6,-8) * CFrame.Angles(math.rad(15),0,0)
                        local DashTop = cockpit:FindFirstChild("DashTop")
                        if DashTop then DashTop.CFrame = Dash.CFrame * CFrame.new(0,3.5,0) end
                        local Yoke = cockpit:FindFirstChild("Yoke")
                        if Yoke then
                            Yoke.CFrame = Dash.CFrame * CFrame.new(0,2,-3) * CFrame.Angles(math.rad(15),0,0)
                            local YokeTop = cockpit:FindFirstChild("YokeTop")
                            if YokeTop then YokeTop.CFrame = Yoke.CFrame * CFrame.new(0,2,0) end
                        end
                    end
                    local GL = cockpit:FindFirstChild("GL")
                    if GL then GL.CFrame = camera.CFrame * CFrame.new(-5,-1,-8) * CFrame.Angles(0,math.rad(15),0) end
                    local GR = cockpit:FindFirstChild("GR")
                    if GR then GR.CFrame = camera.CFrame * CFrame.new(5,-1,-8) * CFrame.Angles(0,math.rad(-15),0) end
                end
                
                if t < boardEnd then
                    local alpha = math.min(t / boardEnd, 1)
                    local smoothAlpha = alpha * alpha * (3 - 2 * alpha)
                    camera.CFrame = startCamCF:Lerp(targetCamCF, smoothAlpha)
                    camera.FieldOfView = 70 - smoothAlpha * 5
                    
                elseif t < taxiEnd then
                    camera.CFrame = targetCamCF * CFrame.Angles(math.sin(t*3)*0.005, math.sin(t*2)*0.005, 0)
                    camera.FieldOfView = 65 + math.sin(t*2)*2
                    
                    if t > 5.5 then
                        local warpUp = (t - 5.5) / (taxiEnd - 5.5)
                        blur.Size = warpUp * 20
                        cc.TintColor = Color3.fromRGB(150, 170 + warpUp*50, 200 + warpUp*55)
                        camera.FieldOfView = 65 + warpUp * 30
                    end
                    
                elseif t < warpEnd then
                    local warp = (t - taxiEnd) / (warpEnd - taxiEnd)
                    camera.FieldOfView = 95 + warp * 40
                    blur.Size = 20 + warp * 30
                    cc.TintColor = Color3.white
                    cc.Contrast = warp * 3
                    
                elseif t < cruiseEnd then
                    blur.Size = 0
                    cc.TintColor = Color3.fromRGB(150,170,200)
                    cc.Contrast = 0.2
                    
                    local cruiseTime = t - warpEnd
                    local totalCruise = cruiseEnd - warpEnd
                    local progress = math.min(cruiseTime / totalCruise, 1)
                    
                    local startPos = sceneOrigin + Vector3.new(0,-4,-2)
                    local endPos = planets.Pluto.CFrame.Position
                    
                    local pathPos = startPos:Lerp(endPos, progress)
                    local lookAt = pathPos + Vector3.new(0,0,-5000)
                    
                    local names = {"Sun", "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"}
                    local idx = math.floor(progress * #names) + 1
                    if idx > #names then idx = #names end
                    if planets[names[idx]] then
                        lookAt = planets[names[idx]].CFrame.Position
                    end
                    
                    local camCF = CFrame.lookAt(pathPos, lookAt)
                    local shake = 0.05 + math.sin(cruiseTime*10)*0.02
                    camCF = camCF * CFrame.Angles(math.noise(cruiseTime*30,0,0)*shake, math.noise(0,cruiseTime*30,0)*shake, 0)
                    
                    camera.CFrame = camCF
                    camera.FieldOfView = 80 + math.sin(cruiseTime*2)*10
                    
                else
                    cc.Saturation = -1
                    cc.Contrast = 1
                    blur.Size = 20
                    topBar.Size = UDim2.new(1,0,0,0)
                    botBar.Size = UDim2.new(1,0,0,0)
                    
                    if t > cruiseEnd + 2 then
                        renderConn:Disconnect()
                        sceneFolder:Destroy()
                        wormhole:Destroy()
                        if cockpit then cockpit:Destroy() end
                        eyeGui:Destroy()
                        cc:Destroy()
                        blur:Destroy()
                        
                        camera.CameraType = origCamType
                        camera.FieldOfView = origFOV
                        if hrp then hrp.Anchored = false end
                        isPlaying = false
                        mainFrame.Visible = true
                    end
                end
            end)
        end
    end)
end

startBtn.MouseButton1Click:Connect(startCinematic)