local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

for _, obj in pairs(game:GetService("CoreGui"):GetChildren()) do if obj.Name == "PowerCrownUI" or obj.Name == "WindUI" or obj.Name == "CinematicUI" then obj:Destroy() end end
for _, obj in pairs(player.PlayerGui:GetChildren()) do if obj.Name == "PowerCrownUI" or obj.Name == "WindUI" or obj.Name == "CinematicUI" then obj:Destroy() end end
for _, obj in pairs(Workspace:GetChildren()) do if obj.Name == "CinematicScene" then obj:Destroy() end end
for _, eff in pairs(Lighting:GetChildren()) do if eff:IsA("BloomEffect") or eff:IsA("ColorCorrectionEffect") or eff:IsA("BlurEffect") then eff:Destroy() end end

local success, WindUI = pcall(function() return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))() end)
if not success or not WindUI then StarterGui:SetCore("SendNotification",{Title="UI加载失败",Text="网络拦截",Duration=10}) return end

local Window = WindUI:CreateWindow({Title="封存娱乐 V1.1",Icon="film",Author="Cinematic",Folder="SpaceSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(300,200)})
local MainTab = Window:Tab({Title="控制",Icon="play"})
local CgSection = MainTab:Section({Title="电影级体验",Icon="video"})

local isPlaying = false
local sceneOrigin = Vector3.new(0, 500000, 0)

local function makePart(parent, name, size, color, mat, cf, shape, transparency)
    local p = Instance.new("Part", parent)
    p.Name = name
    p.Size = size
    p.Color = color
    p.Material = mat or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.Transparency = transparency or 0
    if shape then p.Shape = shape end
    if cf then p.CFrame = cf end
    return p
end

local function buildScene(folder)
    local planets = {}
    
    local sun = makePart(folder, "Sun", Vector3.new(2500, 2500, 2500), Color3.fromRGB(255, 200, 100), Enum.Material.Neon, CFrame.new(sceneOrigin), Enum.PartType.Ball)
    local sunLight = Instance.new("PointLight", sun)
    sunLight.Range = 100000
    sunLight.Brightness = 5
    sunLight.Color = Color3.fromRGB(255, 200, 100)
    
    local sunBloom = Instance.new("BloomEffect", Lighting)
    sunBloom.Intensity = 2
    sunBloom.Size = 40
    sunBloom.Threshold = 0.5
    
    local pDefs = {
        {name="Mercury", pos=Vector3.new(8000, 0, 0), size=400, col=Color3.fromRGB(100, 100, 100), atmo=Color3.fromRGB(60,60,60)},
        {name="Venus", pos=Vector3.new(14000, 3000, 6000), size=600, col=Color3.fromRGB(220, 180, 120), atmo=Color3.fromRGB(255,150,50)},
        {name="Earth", pos=Vector3.new(22000, -3000, 12000), size=800, col=Color3.fromRGB(20, 80, 200), atmo=Color3.fromRGB(80,180,255)},
        {name="Mars", pos=Vector3.new(30000, 2000, 18000), size=500, col=Color3.fromRGB(180, 80, 50), atmo=Color3.fromRGB(255,100,50)},
        {name="Jupiter", pos=Vector3.new(42000, 5000, 26000), size=1600, col=Color3.fromRGB(200, 170, 140), atmo=Color3.fromRGB(255,200,150)},
        {name="Saturn", pos=Vector3.new(58000, -4000, 35000), size=1400, col=Color3.fromRGB(220, 200, 160), atmo=Color3.fromRGB(255,230,180)},
        {name="Uranus", pos=Vector3.new(72000, 3000, 45000), size=1000, col=Color3.fromRGB(120, 200, 220), atmo=Color3.fromRGB(150,255,255)},
        {name="Neptune", pos=Vector3.new(88000, -3000, 55000), size=950, col=Color3.fromRGB(60, 100, 230), atmo=Color3.fromRGB(100,150,255)}
    }
    
    for _, def in ipairs(pDefs) do
        local p = makePart(folder, def.name, Vector3.new(def.size, def.size, def.size), def.col, Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + def.pos), Enum.PartType.Ball)
        local atmo = makePart(folder, "Atmo", Vector3.new(def.size*1.04, def.size*1.04, def.size*1.04), def.atmo, Enum.Material.ForceField, CFrame.new(sceneOrigin + def.pos), Enum.PartType.Ball, 0.6)
        
        if def.name == "Earth" then
            local clouds = makePart(folder, "Clouds", Vector3.new(def.size*1.015, def.size*1.015, def.size*1.015), Color3.new(1,1,1), Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + def.pos), Enum.PartType.Ball, 0.75)
        elseif def.name == "Jupiter" then
            for i = 1, 9 do
                local band = makePart(folder, "Band", Vector3.new(def.size*1.005, 40, def.size*1.005), Color3.fromRGB(150, 110, 90), Enum.Material.SmoothPlastic, nil, Enum.PartType.Cylinder)
                band.CFrame = CFrame.new(sceneOrigin + def.pos + Vector3.new(0, (i-5)*140, 0)) * CFrame.Angles(0,0,math.rad(90))
            end
        elseif def.name == "Saturn" then
            local ring1 = makePart(folder, "Ring", Vector3.new(def.size*2.8, 15, def.size*2.8), Color3.fromRGB(180, 160, 120), Enum.Material.SmoothPlastic, nil, Enum.PartType.Cylinder, 0.1)
            ring1.CFrame = CFrame.new(sceneOrigin + def.pos) * CFrame.Angles(math.rad(25), 0, math.rad(20)) * CFrame.Angles(0,0,math.rad(90))
            local ring2 = makePart(folder, "Ring", Vector3.new(def.size*2.1, 20, def.size*2.1), Color3.fromRGB(200, 180, 140), Enum.Material.SmoothPlastic, nil, Enum.PartType.Cylinder, 0.3)
            ring2.CFrame = CFrame.new(sceneOrigin + def.pos) * CFrame.Angles(math.rad(25), 0, math.rad(20)) * CFrame.Angles(0,0,math.rad(90))
        end
        table.insert(planets, {pos = sceneOrigin + def.pos, name = def.name, size = def.size})
    end
    
    local starFolder = Instance.new("Folder", folder)
    for i = 1, 3000 do
        local rPos = sceneOrigin + Vector3.new(math.random(-120000, 120000), math.random(-120000, 120000), math.random(-120000, 120000))
        local sSize = math.random(20, 80)
        makePart(starFolder, "Star", Vector3.new(sSize,sSize,sSize), Color3.new(1,1,1), Enum.Material.Neon, CFrame.new(rPos), Enum.PartType.Ball, math.random(0, 0.4))
    end
    
    return planets
end

local function startCinematic()
    if isPlaying then return end
    isPlaying = true
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
    
    local originalCamType = camera.CameraType
    local originalFOV = camera.FieldOfView
    camera.CameraType = Enum.CameraType.Scriptable
    
    local sceneFolder = Instance.new("Folder", Workspace)
    sceneFolder.Name = "CinematicScene"
    
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "CinematicUI"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    
    local blackBarTop = Instance.new("Frame", gui)
    blackBarTop.Size = UDim2.new(1, 0, 0, 0)
    blackBarTop.BackgroundColor3 = Color3.new(0,0,0)
    blackBarTop.ZIndex = 10
    TweenService:Create(blackBarTop, TweenInfo.new(1), {Size = UDim2.new(1, 0, 0.15, 0)}):Play()
    
    local blackBarBot = Instance.new("Frame", gui)
    blackBarBot.AnchorPoint = Vector2.new(0, 1)
    blackBarBot.Position = UDim2.new(0, 0, 1, 0)
    blackBarBot.Size = UDim2.new(1, 0, 0, 0)
    blackBarBot.BackgroundColor3 = Color3.new(0,0,0)
    blackBarBot.ZIndex = 10
    TweenService:Create(blackBarBot, TweenInfo.new(1), {Size = UDim2.new(1, 0, 0.15, 0)}):Play()
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Contrast = 0.1
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    local planets = buildScene(sceneFolder)
    
    local shipFolder = Instance.new("Folder", sceneFolder)
    
    local frameL = makePart(shipFolder, "FrameL", Vector3.new(1.5, 10, 15), Color3.fromRGB(15,18,22), Enum.Material.Metal)
    local frameR = makePart(shipFolder, "FrameR", Vector3.new(1.5, 10, 15), Color3.fromRGB(15,18,22), Enum.Material.Metal)
    local dash = makePart(shipFolder, "Dash", Vector3.new(20, 6, 10), Color3.fromRGB(10,12,15), Enum.Material.Metal)
    
    local screen = makePart(shipFolder, "Screen", Vector3.new(6, 2.5, 0.5), Color3.fromRGB(20, 100, 150), Enum.Material.Neon)
    local sGui = Instance.new("SurfaceGui", screen)
    sGui.Face = Enum.NormalId.Top
    local sText = Instance.new("TextLabel", sGui)
    sText.Size = UDim2.fromScale(1, 1)
    sText.BackgroundTransparency = 1
    sText.Text = "SYSTEM ONLINE\nTARGET: EARTH\nSTATUS: CRUISING"
    sText.TextColor3 = Color3.fromRGB(0, 255, 255)
    sText.Font = Enum.Font.Code
    sText.TextSize = 32
    
    local yoke = makePart(shipFolder, "Yoke", Vector3.new(1, 2.5, 1), Color3.fromRGB(30,30,30), Enum.Material.Metal)
    local yokeTop = makePart(shipFolder, "YokeTop", Vector3.new(3.5, 0.5, 1.5), Color3.fromRGB(40,40,40), Enum.Material.Metal)
    
    local lightL = makePart(shipFolder, "LightL", Vector3.new(1,1,1), Color3.fromRGB(0,200,255), Enum.Material.Neon)
    local lightR = makePart(shipFolder, "LightR", Vector3.new(1,1,1), Color3.fromRGB(0,200,255), Enum.Material.Neon)
    
    local warpLines = Instance.new("Folder", sceneFolder)
    local lines = {}
    for i = 1, 200 do
        local line = makePart(warpLines, "WarpLine", Vector3.new(0.5, 0.5, 2000), Color3.fromRGB(150, 200, 255), Enum.Material.Neon, nil, nil, 0.5)
        table.insert(lines, {
            part = line,
            angle = math.random() * math.pi * 2,
            dist = math.random() * 3000,
            speed = math.random(2000, 5000)
        })
    end
    
    local flightT = 0
    local startTime = tick()
    
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not isPlaying then return end
        local t = tick() - startTime
        
        if t < 5 then
            cc.TintColor = Color3.fromRGB(150, 180, 255)
            local fovT = math.min(t / 3, 1)
            camera.FieldOfView = 70 + fovT * 60
            blur.Size = fovT * 15
            
            local shake = (1 - fovT * 0.3) * 2
            local camPos = sceneOrigin + Vector3.new(0, 0, t * 3000) + Vector3.new(math.noise(t*100,0,0)*shake, math.noise(0,t*100,0)*shake, 0)
            local lookAt = camPos + Vector3.new(0, 0, 100)
            camera.CFrame = CFrame.lookAt(camPos, lookAt)
            
            frameL.CFrame = camera.CFrame * CFrame.new(-10, -3, -6)
            frameR.CFrame = camera.CFrame * CFrame.new(10, -3, -6)
            dash.CFrame = camera.CFrame * CFrame.new(0, -7, -7)
            screen.CFrame = camera.CFrame * CFrame.new(0, -6.5, -6.5) * CFrame.Angles(math.rad(30), 0, 0)
            yoke.CFrame = camera.CFrame * CFrame.new(0, -5.5, -6) * CFrame.Angles(math.rad(-20), 0, 0)
            yokeTop.CFrame = yoke.CFrame * CFrame.new(0, 1.2, 0)
            lightL.CFrame = camera.CFrame * CFrame.new(-4, -6, -6.5)
            lightR.CFrame = camera.CFrame * CFrame.new(4, -6, -6.5)
            
            for i, l in ipairs(lines) do
                local z = (l.dist + t * l.speed) % 4000
                local x = math.cos(l.angle) * 500
                local y = math.sin(l.angle) * 500
                l.part.CFrame = camera.CFrame * CFrame.new(x, y, -z + 1000)
                l.part.Transparency = math.clamp(1 - (z / 3000), 0, 0.8)
            end
            
        elseif t >= 5 and t < 8 then
            local whiteOut = math.min((t - 5) / 1, 1)
            cc.TintColor = Color3.fromRGB(255, 255, 255)
            cc.Contrast = whiteOut * 4
            blur.Size = whiteOut * 30
            camera.CFrame = CFrame.lookAt(sceneOrigin, sceneOrigin + Vector3.new(0,0,1000))
            camera.FieldOfView = 120 - whiteOut * 40
            if t >= 7.5 then
                blur.Size = 0
                cc.Contrast = 0
                cc.TintColor = Color3.fromRGB(255, 255, 255)
                warpLines:Destroy()
            end
            
        elseif t >= 8 then
            blur.Size = 0
            cc.Contrast = 0.1
            
            local cruiseTime = t - 8
            local totalCruise = 22
            local progress = math.min(cruiseTime / totalCruise, 1)
            
            local startPos = sceneOrigin + Vector3.new(0, 0, 0)
            local targetPlanet = planets[3]
            local endPos = targetPlanet.pos + Vector3.new(targetPlanet.size * 1.2, targetPlanet.size * 0.5, targetPlanet.size * 1.5)
            
            local currentPos = startPos:Lerp(endPos, progress)
            
            local lookTarget = currentPos + Vector3.new(0, 0, -500)
            
            if progress > 0.1 and progress < 0.85 then
                local idx = math.floor(progress * #planets) + 1
                if idx > #planets then idx = #planets end
                lookTarget = planets[idx].pos
            elseif progress >= 0.85 then
                lookTarget = targetPlanet.pos
            end
            
            local camCF = CFrame.lookAt(currentPos, lookTarget)
            local shake = 0.3 + math.sin(cruiseTime * 10) * 0.1
            if progress > 0.85 then shake = 3 end
            
            camCF = camCF * CFrame.Angles(math.noise(cruiseTime*50,0,0)*shake, math.noise(0,cruiseTime*50,0)*shake, 0)
            camera.CFrame = camCF
            
            if progress > 0.85 then
                camera.FieldOfView = 70 + (progress - 0.85) * 150
                blur.Size = (progress - 0.85) * 50
                cc.Contrast = (progress - 0.85) * 5
            else
                camera.FieldOfView = 80 + math.sin(cruiseTime * 2) * 10
            end
            
            frameL.CFrame = camera.CFrame * CFrame.new(-6, -2, -4)
            frameR.CFrame = camera.CFrame * CFrame.new(6, -2, -4)
            dash.CFrame = camera.CFrame * CFrame.new(0, -5, -5)
            screen.CFrame = camera.CFrame * CFrame.new(0, -4.5, -4.5) * CFrame.Angles(math.rad(30), 0, 0)
            yoke.CFrame = camera.CFrame * CFrame.new(0, -3.5, -4.5) * CFrame.Angles(math.rad(-20), 0, 0)
            yokeTop.CFrame = yoke.CFrame * CFrame.new(0, 1.2, 0)
            lightL.CFrame = camera.CFrame * CFrame.new(-2.5, -4, -4.5)
            lightR.CFrame = camera.CFrame * CFrame.new(2.5, -4, -4.5)
            
            if progress >= 1 then
                cc.Saturation = 0
                cc.Contrast = -1
                blur.Size = 30
                blackBarTop.Size = UDim2.new(1, 0, 0, 0)
                blackBarBot.Size = UDim2.new(1, 0, 0, 0)
                
                if cruiseTime > totalCruise + 2 then
                    renderConn:Disconnect()
                    sceneFolder:Destroy()
                    gui:Destroy()
                    cc:Destroy()
                    blur:Destroy()
                    if sunBloom then sunBloom:Destroy() end
                    
                    camera.CameraType = originalCamType
                    camera.FieldOfView = originalFOV
                    if hrp then hrp.Anchored = false end
                    isPlaying = false
                end
            end
        end
    end)
end

CgSection:Button({Title="启动光速巡航", Callback=function()
    if not isPlaying then
        startCinematic()
    end
end})