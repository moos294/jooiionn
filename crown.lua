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

local Window = WindUI:CreateWindow({Title="封存娱乐 V1.0",Icon="film",Author="Cinematic",Folder="SpaceSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(300,200)})
local MainTab = Window:Tab({Title="控制",Icon="play"})
local CgSection = MainTab:Section({Title="电影级体验",Icon="video"})

local isPlaying = false
local sceneOrigin = Vector3.new(0, 50000, 0)

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
    p.Transparency = transparency or 0
    if shape then p.Shape = shape end
    if cf then p.CFrame = cf end
    return p
end

local function playSound(id, vol, speed)
    local s = Instance.new("Sound", Workspace)
    s.SoundId = id
    s.Volume = vol or 1
    s.PlaybackSpeed = speed or 1
    s.Parent = Workspace
    s:Play()
    task.delay(6, function() s:Destroy() end)
end

local function buildScene(folder)
    local planets = {}
    
    local sun = makePart(folder, "Sun", Vector3.new(1500, 1500, 1500), Color3.fromRGB(255, 180, 80), Enum.Material.Neon, CFrame.new(sceneOrigin), Enum.PartType.Ball)
    local sunLight = Instance.new("PointLight", sun)
    sunLight.Range = 25000
    sunLight.Brightness = 10
    sunLight.Color = Color3.fromRGB(255, 180, 80)
    
    local sunBloom = Instance.new("BloomEffect", Lighting)
    sunBloom.Intensity = 2
    sunBloom.Size = 40
    sunBloom.Threshold = 0.5
    
    local pDefs = {
        {name="Mercury", color=Color3.fromRGB(120, 120, 120), pos=Vector3.new(4000, 0, 0), size=150, atmo=Color3.fromRGB(80,80,80)},
        {name="Venus", color=Color3.fromRGB(240, 180, 80), pos=Vector3.new(7000, 1000, 3000), size=250, atmo=Color3.fromRGB(255,150,50)},
        {name="Earth", color=Color3.fromRGB(20, 80, 200), pos=Vector3.new(11000, -1000, 6000), size=280, atmo=Color3.fromRGB(80,180,255)},
        {name="Mars", color=Color3.fromRGB(180, 60, 30), pos=Vector3.new(16000, 500, 9000), size=200, atmo=Color3.fromRGB(255,80,50)},
        {name="Jupiter", color=Color3.fromRGB(200, 160, 120), pos=Vector3.new(24000, 2000, 14000), size=900, atmo=Color3.fromRGB(255,200,150)},
        {name="Saturn", color=Color3.fromRGB(220, 200, 150), pos=Vector3.new(34000, -1500, 20000), size=800, atmo=Color3.fromRGB(255,220,180)},
        {name="Uranus", color=Color3.fromRGB(100, 200, 220), pos=Vector3.new(44000, 1000, 26000), size=500, atmo=Color3.fromRGB(150,255,255)},
        {name="Neptune", color=Color3.fromRGB(50, 100, 230), pos=Vector3.new(54000, -1000, 32000), size=480, atmo=Color3.fromRGB(100,150,255)}
    }
    
    for _, def in ipairs(pDefs) do
        local p = makePart(folder, def.name, Vector3.new(def.size, def.size, def.size), def.color, Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + def.pos), Enum.PartType.Ball)
        local atmo = makePart(folder, "Atmo", Vector3.new(def.size*1.03, def.size*1.03, def.size*1.03), def.atmo, Enum.Material.ForceField, CFrame.new(sceneOrigin + def.pos), Enum.PartType.Ball, 0.4)
        
        if def.name == "Earth" then
            makePart(folder, "Clouds", Vector3.new(def.size*1.01, def.size*1.01, def.size*1.01), Color3.new(1,1,1), Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + def.pos), Enum.PartType.Ball, 0.7)
        elseif def.name == "Jupiter" then
            for i = 1, 7 do
                local band = makePart(folder, "Band", Vector3.new(def.size*1.005, 30, def.size*1.005), Color3.fromRGB(160, 110, 80), Enum.Material.SmoothPlastic, nil, Enum.PartType.Cylinder)
                band.CFrame = CFrame.new(sceneOrigin + def.pos + Vector3.new(0, (i-4)*120, 0)) * CFrame.Angles(0,0,math.rad(90))
            end
        elseif def.name == "Saturn" then
            local ring1 = makePart(folder, "Ring", Vector3.new(def.size*3, 8, def.size*3), Color3.fromRGB(160, 140, 110), Enum.Material.SmoothPlastic, nil, Enum.PartType.Cylinder, 0.1)
            ring1.CFrame = CFrame.new(sceneOrigin + def.pos) * CFrame.Angles(math.rad(25), 0, math.rad(20)) * CFrame.Angles(0,0,math.rad(90))
            local ring2 = makePart(folder, "Ring", Vector3.new(def.size*2.4, 12, def.size*2.4), Color3.fromRGB(200, 180, 150), Enum.Material.SmoothPlastic, nil, Enum.PartType.Cylinder, 0.3)
            ring2.CFrame = CFrame.new(sceneOrigin + def.pos) * CFrame.Angles(math.rad(25), 0, math.rad(20)) * CFrame.Angles(0,0,math.rad(90))
        end
        table.insert(planets, {pos = sceneOrigin + def.pos, name = def.name})
    end
    
    local starFolder = Instance.new("Folder", folder)
    for i = 1, 2000 do
        local rPos = sceneOrigin + Vector3.new(math.random(-80000, 80000), math.random(-80000, 80000), math.random(-80000, 80000))
        local sSize = math.random(10, 50)
        makePart(starFolder, "Star", Vector3.new(sSize,sSize,sSize), Color3.new(1,1,1), Enum.Material.Neon, CFrame.new(rPos), Enum.PartType.Ball, math.random(0, 0.6))
    end
    
    local astFolder = Instance.new("Folder", folder)
    for i = 1, 40 do
        local rPos = sceneOrigin + Vector3.new(math.random(-30000, 30000), math.random(-10000, 10000), math.random(10000, 40000))
        local aSize = math.random(600, 1800)
        local ast = makePart(astFolder, "Asteroid", Vector3.new(aSize, aSize * 0.7, aSize * 0.9), Color3.fromRGB(80, 75, 70), Enum.Material.Rock, CFrame.new(rPos) * CFrame.Angles(math.random(0,6), math.random(0,6), math.random(0,6)))
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
    cc.Contrast = 0.2
    cc.Saturation = 0.2
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    local planets = buildScene(sceneFolder)
    
    local shipFolder = Instance.new("Folder", sceneFolder)
    local frameL = makePart(shipFolder, "FrameL", Vector3.new(1, 8, 12), Color3.fromRGB(10,12,15), Enum.Material.Metal)
    local frameR = makePart(shipFolder, "FrameR", Vector3.new(1, 8, 12), Color3.fromRGB(10,12,15), Enum.Material.Metal)
    local dash = makePart(shipFolder, "Dash", Vector3.new(16, 4, 6), Color3.fromRGB(8,10,12), Enum.Material.Metal)
    local glass = makePart(shipFolder, "Glass", Vector3.new(14, 7, 0.2), Color3.fromRGB(100,150,200), Enum.Material.ForceField, nil, nil, 0.85)
    
    local alertLightL = makePart(shipFolder, "AlertL", Vector3.new(0.8,0.8,0.8), Color3.fromRGB(255,20,20), Enum.Material.Neon)
    local alertLightR = makePart(shipFolder, "AlertR", Vector3.new(0.8,0.8,0.8), Color3.fromRGB(255,20,20), Enum.Material.Neon)
    
    local wormholeFolder = Instance.new("Folder", sceneFolder)
    local rings = {}
    for i = 1, 60 do
        local ring = makePart(wormholeFolder, "Ring", Vector3.new(1, 200, 200), Color3.fromRGB(50, 150, 255), Enum.Material.Neon, nil, Enum.PartType.Cylinder, 0.5)
        ring.CFrame = CFrame.new(sceneOrigin) * CFrame.Angles(0, 0, math.rad(90))
        table.insert(rings, {part = ring, dist = i * 80})
    end
    
    playSound("rbxasset://sounds/Rocket whoosh 01.wav", 1, 1)
    
    local flightT = 0
    local startTime = tick()
    local currentLookTarget = planets[1].pos
    
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not isPlaying then return end
        
        local t = tick() - startTime
        flightT = flightT + dt * 300
        
        if t < 4.5 then
            cc.TintColor = Color3.fromRGB(150, 180, 255)
            local fovT = math.min(t / 2.5, 1)
            camera.FieldOfView = 70 + fovT * 60
            blur.Size = fovT * 20
            
            local shake = (1 - fovT * 0.3) * 2.5
            local camPos = sceneOrigin + Vector3.new(0, 0, flightT) + Vector3.new(math.noise(t*80,0,0)*shake, math.noise(0,t*80,0)*shake, 0)
            local lookAt = camPos + Vector3.new(0, 0, 100)
            camera.CFrame = CFrame.lookAt(camPos, lookAt)
            
            frameL.CFrame = camera.CFrame * CFrame.new(-7, -1, -4)
            frameR.CFrame = camera.CFrame * CFrame.new(7, -1, -4)
            dash.CFrame = camera.CFrame * CFrame.new(0, -4.5, -5)
            glass.CFrame = camera.CFrame * CFrame.new(0, 0, -9)
            
            local blink = math.floor(t * 8) % 2 == 0
            alertLightL.Transparency = blink and 0 or 1
            alertLightR.Transparency = blink and 0 or 1
            alertLightL.CFrame = camera.CFrame * CFrame.new(-3, -3.5, -5)
            alertLightR.CFrame = camera.CFrame * CFrame.new(3, -3.5, -5)
            
            for i, r in ipairs(rings) do
                local ringZ = (r.dist - (flightT % 4800))
                if ringZ < 0 then ringZ = ringZ + 4800 end
                r.part.CFrame = CFrame.new(sceneOrigin + Vector3.new(0, 0, ringZ - 1500)) * CFrame.Angles(0, 0, math.rad(90))
                local scale = 1 + (ringZ / 4800) * 4
                r.part.Size = Vector3.new(1, 200 * scale, 200 * scale)
                r.part.Transparency = math.clamp(1 - (ringZ / 4000), 0, 0.9)
            end
            
        elseif t >= 4.5 and t < 8 then
            local whiteOut = math.min((t - 4.5) / 0.8, 1)
            cc.TintColor = Color3.fromRGB(255, 255, 255)
            cc.Contrast = whiteOut * 4
            blur.Size = whiteOut * 30
            
            camera.CFrame = CFrame.lookAt(sceneOrigin, sceneOrigin + Vector3.new(0,0,1000))
            camera.FieldOfView = 130 - whiteOut * 50
            
            if t >= 7.5 then
                blur.Size = 0
                cc.Contrast = 0
                cc.TintColor = Color3.fromRGB(255, 255, 255)
                wormholeFolder:Destroy()
                playSound("rbxasset://sounds/impact_water.mp3", 1.5, 0.5)
            end
            
        else
            blur.Size = 0
            cc.Contrast = 0.2
            
            local cruiseTime = t - 8
            local totalCruise = 20
            local progress = math.min(cruiseTime / totalCruise, 1)
            
            local pathStart = sceneOrigin + Vector3.new(0, 0, 0)
            local pathEnd = planets[#planets].pos + Vector3.new(0, 0, 5000)
            
            local basePos = pathStart:Lerp(pathEnd, progress)
            
            local sideOffset = math.sin(progress * math.pi * 6) * 3000
            local upOffset = math.cos(progress * math.pi * 3) * 1000
            
            local camPos = basePos + Vector3.new(sideOffset, upOffset, 0)
            
            local targetIndex = math.floor(progress * #planets) + 1
            if targetIndex > #planets then targetIndex = #planets end
            local lookTarget = planets[targetIndex].pos
            
            currentLookTarget = currentLookTarget:Lerp(lookTarget, dt * 4)
            
            local camCF = CFrame.lookAt(camPos, currentLookTarget)
            
            local shake = 0.15 + (math.sin(cruiseTime * 5) * 0.05)
            camCF = camCF * CFrame.Angles(math.noise(cruiseTime*40,0,0)*shake, math.noise(0,cruiseTime*40,0)*shake, 0)
            
            camera.CFrame = camera.CFrame:Lerp(camCF, dt * 6)
            camera.FieldOfView = 80 + math.sin(cruiseTime * 2) * 15
            
            frameL.CFrame = camera.CFrame * CFrame.new(-4.5, -0.5, -2.5)
            frameR.CFrame = camera.CFrame * CFrame.new(4.5, -0.5, -2.5)
            dash.CFrame = camera.CFrame * CFrame.new(0, -2.8, -3)
            glass.CFrame = camera.CFrame * CFrame.new(0, 0, -4.5)
            alertLightL.CFrame = camera.CFrame * CFrame.new(-2, -2.5, -3)
            alertLightR.CFrame = camera.CFrame * CFrame.new(2, -2.5, -3)
            
            if progress >= 1 then
                cc.Saturation = 0
                cc.Contrast = -1
                blur.Size = 25
                blackBarTop.Size = UDim2.new(1, 0, 0, 0)
                blackBarBot.Size = UDim2.new(1, 0, 0, 0)
                
                if cruiseTime > totalCruise + 2.5 then
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