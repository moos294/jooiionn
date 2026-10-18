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
if not success or not WindUI then StarterGui:SetCore("SendNotification",{Title="UI加载失败",Text="请检查网络或执行器",Duration=10}) return end

local Window = WindUI:CreateWindow({Title="封存娱乐 V1.4",Icon="film",Author="Cinematic",Folder="SpaceSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(300,200)})
local MainTab = Window:Tab({Title="控制",Icon="play"})
local CgSection = MainTab:Section({Title="电影级体验",Icon="video"})

local isPlaying = false
local sceneOrigin = Vector3.new(0, 3000, 0)

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

local function buildSpace(folder)
    local planets = {}
    
    local sun = makePart(folder, "Sun", Vector3.new(2500, 2500, 2500), Color3.fromRGB(255, 100, 50), Enum.Material.Neon, CFrame.new(sceneOrigin + Vector3.new(0, 0, -30000)), Enum.PartType.Ball, 0.2)
    local sunLight = Instance.new("PointLight", sun)
    sunLight.Range = 50000
    sunLight.Brightness = 1.5
    sunLight.Color = Color3.fromRGB(255, 150, 100)
    
    local pDefs = {
        {name="Earth", pos=Vector3.new(-5000, 0, -10000), size=600, col=Color3.fromRGB(20, 40, 80), atmo=Color3.fromRGB(30, 80, 150)},
        {name="Mars", pos=Vector3.new(5000, 2000, -18000), size=400, col=Color3.fromRGB(100, 40, 30), atmo=Color3.fromRGB(120, 40, 20)},
        {name="Jupiter", pos=Vector3.new(-10000, -2000, -25000), size=1800, col=Color3.fromRGB(120, 90, 70), atmo=Color3.fromRGB(140, 110, 90)},
        {name="Saturn", pos=Vector3.new(12000, 3000, -35000), size=1500, col=Color3.fromRGB(150, 130, 100), atmo=Color3.fromRGB(170, 150, 120)},
        {name="Neptune", pos=Vector3.new(-15000, -3000, -45000), size=1000, col=Color3.fromRGB(20, 50, 150), atmo=Color3.fromRGB(40, 80, 200)}
    }
    
    for _, def in ipairs(pDefs) do
        local p = makePart(folder, def.name, Vector3.new(def.size, def.size, def.size), def.col, Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + def.pos), Enum.PartType.Ball)
        makePart(folder, "Atmo", Vector3.new(def.size*1.02, def.size*1.02, def.size*1.02), def.atmo, Enum.Material.ForceField, CFrame.new(sceneOrigin + def.pos), Enum.PartType.Ball, 0.4)
        
        if def.name == "Saturn" then
            for i = 1, 3 do
                local ring = makePart(folder, "Ring", Vector3.new(def.size*(2 + i*0.3), 10, def.size*(2 + i*0.3)), Color3.fromRGB(100 - i*10, 90 - i*10, 80 - i*10), Enum.Material.Slate, nil, Enum.PartType.Cylinder, 0.4)
                ring.CFrame = CFrame.new(sceneOrigin + def.pos) * CFrame.Angles(math.rad(20), 0, math.rad(10)) * CFrame.Angles(0,0,math.rad(90))
            end
        elseif def.name == "Jupiter" then
            for i = 1, 8 do
                local band = makePart(folder, "Band", Vector3.new(def.size*1.01, 60, def.size*1.01), Color3.fromRGB(90, 70, 60), Enum.Material.Slate, nil, Enum.PartType.Cylinder, 0.5)
                band.CFrame = CFrame.new(sceneOrigin + def.pos + Vector3.new(0, (i-4.5)*200, 0)) * CFrame.Angles(0,0,math.rad(90))
            end
        end
        table.insert(planets, {pos = sceneOrigin + def.pos, name = def.name, size = def.size})
    end
    
    local stars = Instance.new("Folder", folder)
    for i = 1, 1000 do
        local rPos = sceneOrigin + Vector3.new(math.random(-40000, 40000), math.random(-40000, 40000), math.random(-60000, -10000))
        makePart(stars, "Star", Vector3.new(10,10,10), Color3.new(1,1,1), Enum.Material.SmoothPlastic, CFrame.new(rPos), Enum.PartType.Ball, math.random(0.2, 0.8))
    end
    
    return planets
end

local function createCockpit(folder)
    local cockpit = Instance.new("Folder", folder)
    
    local frameL = makePart(cockpit, "FrameL", Vector3.new(1, 8, 10), Color3.fromRGB(15, 18, 20), Enum.Material.Metal)
    local frameR = makePart(cockpit, "FrameR", Vector3.new(1, 8, 10), Color3.fromRGB(15, 18, 20), Enum.Material.Metal)
    local dash = makePart(cockpit, "Dash", Vector3.new(14, 4, 6), Color3.fromRGB(10, 12, 15), Enum.Material.Metal)
    
    local yoke = makePart(cockpit, "Yoke", Vector3.new(0.8, 2.5, 0.8), Color3.fromRGB(30, 30, 30), Enum.Material.Metal)
    local yokeTop = makePart(cockpit, "YokeTop", Vector3.new(3, 0.5, 1.2), Color3.fromRGB(20, 20, 20), Enum.Material.Metal)
    
    local buttons = Instance.new("Folder", cockpit)
    for i = 1, 20 do
        local xOffset = (i % 5 - 2) * 1.2
        local zOffset = math.floor(i / 5) * 1.2 - 2
        local btn = makePart(buttons, "Btn" .. i, Vector3.new(0.4, 0.4, 0.4), i % 3 == 0 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50), Enum.Material.Neon, nil, Enum.PartType.Block, 0.5)
    end
    
    local screen = makePart(cockpit, "Screen", Vector3.new(4, 2, 0.1), Color3.fromRGB(0, 50, 80), Enum.Material.Neon)
    local sGui = Instance.new("SurfaceGui", screen)
    sGui.Face = Enum.NormalId.Top
    local sText = Instance.new("TextLabel", sGui)
    sText.Size = UDim2.fromScale(1, 1)
    sText.BackgroundTransparency = 1
    sText.Text = "SYS: ONLINE\nVEL: 0.0\nWARP: READY"
    sText.TextColor3 = Color3.fromRGB(0, 200, 255)
    sText.Font = Enum.Font.Code
    sText.TextSize = 32
    
    return {
        frameL = frameL, frameR = frameR, dash = dash,
        yoke = yoke, yokeTop = yokeTop, buttons = buttons, screen = screen
    }
end

local function updateCockpit(cockpit, camCF)
    cockpit.frameL.CFrame = camCF * CFrame.new(-6, -1, -3)
    cockpit.frameR.CFrame = camCF * CFrame.new(6, -1, -3)
    cockpit.dash.CFrame = camCF * CFrame.new(0, -4, -4.5)
    cockpit.yoke.CFrame = camCF * CFrame.new(0, -2.8, -4) * CFrame.Angles(math.rad(-15), 0, 0)
    cockpit.yokeTop.CFrame = cockpit.yoke.CFrame * CFrame.new(0, 1.2, 0)
    cockpit.screen.CFrame = camCF * CFrame.new(0, -3.5, -3.8) * CFrame.Angles(math.rad(25), 0, 0)
    
    for i, btn in ipairs(cockpit.buttons:GetChildren()) do
        local xOffset = (i % 5 - 2) * 1.2
        local zOffset = math.floor(i / 5) * 0.9 - 2
        btn.CFrame = cockpit.dash.CFrame * CFrame.new(xOffset, 2.05, zOffset)
    end
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
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Contrast = 0.2
    cc.Saturation = -0.1
    cc.Brightness = -0.1
    cc.TintColor = Color3.fromRGB(150, 180, 220)
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "CinematicUI"
    gui.IgnoreGuiInset = true
    
    local topBar = Instance.new("Frame", gui)
    topBar.Size = UDim2.new(1, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.new(0,0,0)
    topBar.ZIndex = 10
    TweenService:Create(topBar, TweenInfo.new(2), {Size = UDim2.new(1, 0, 0.15, 0)}):Play()
    
    local botBar = Instance.new("Frame", gui)
    botBar.AnchorPoint = Vector2.new(0, 1)
    botBar.Position = UDim2.new(0, 0, 1, 0)
    botBar.Size = UDim2.new(1, 0, 0, 0)
    botBar.BackgroundColor3 = Color3.new(0,0,0)
    botBar.ZIndex = 10
    TweenService:Create(botBar, TweenInfo.new(2), {Size = UDim2.new(1, 0, 0.15, 0)}):Play()
    
    local planets = buildSpace(sceneFolder)
    local cockpit = createCockpit(sceneFolder)
    
    local wormholeFolder = Instance.new("Folder", sceneFolder)
    local rings = {}
    for i = 1, 40 do
        local ring = makePart(wormholeFolder, "Ring", Vector3.new(5, 200, 200), Color3.fromRGB(50, 100, 255), Enum.Material.Neon, nil, Enum.PartType.Cylinder, 0.6)
        table.insert(rings, {part = ring, dist = i * 200})
    end
    
    local startTime = tick()
    local flightT = 0
    
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not isPlaying then return end
        
        local t = tick() - startTime
        flightT = flightT + dt * 100
        
        local camPos = sceneOrigin + Vector3.new(0, 0, 0)
        local lookAt = sceneOrigin + Vector3.new(0, 0, -30000)
        
        if t < 6 then
            camPos = sceneOrigin + Vector3.new(0, 0, 1000 - t * 100)
            camera.CFrame = CFrame.lookAt(camPos, lookAt)
            camera.FieldOfView = 70
            
            for i, r in ipairs(rings) do
                local z = -3000 - r.dist + (flightT * 0.5)
                r.part.CFrame = CFrame.new(sceneOrigin + Vector3.new(0, 0, z)) * CFrame.Angles(0, 0, math.rad(90))
                local scale = 1 + (i / 10)
                r.part.Size = Vector3.new(5, 200 * scale, 200 * scale)
                r.part.Transparency = math.clamp(0.2 + (i / 40), 0, 0.9)
            end
            updateCockpit(cockpit, camera.CFrame)
            
        elseif t >= 6 and t < 8 then
            local warp = (t - 6) / 2
            camera.CFrame = CFrame.lookAt(sceneOrigin + Vector3.new(0, 0, 1000 + warp * 2000), lookAt)
            camera.FieldOfView = 70 + warp * 50
            blur.Size = warp * 20
            cc.TintColor = Color3.fromRGB(200, 220, 255)
            
            for i, r in ipairs(rings) do
                r.part.Transparency = math.clamp(r.part.Transparency + warp * 0.5, 0, 1)
            end
            updateCockpit(cockpit, camera.CFrame)
            
        else
            blur.Size = 0
            cc.TintColor = Color3.fromRGB(150, 180, 220)
            
            local cruiseTime = t - 8
            local totalCruise = 24
            local progress = math.min(cruiseTime / totalCruise, 1)
            
            local pathStart = sceneOrigin
            local targetPlanet = planets[1]
            local pathEnd = targetPlanet.pos
            
            local currentPos = pathStart:Lerp(pathEnd, progress)
            local currentLook = currentPos + Vector3.new(0, 0, -5000)
            
            if progress > 0.1 and progress < 0.9 then
                local idx = math.floor(progress * #planets) + 1
                if idx > #planets then idx = #planets end
                currentLook = planets[idx].pos
            elseif progress >= 0.9 then
                currentLook = targetPlanet.pos
            end
            
            local camCF = CFrame.lookAt(currentPos, currentLook)
            local shake = 0.1 + math.sin(cruiseTime * 5) * 0.05
            if progress > 0.9 then shake = 1 end
            
            camCF = camCF * CFrame.Angles(math.noise(cruiseTime*30,0,0)*shake, math.noise(0,cruiseTime*30,0)*shake, 0)
            camera.CFrame = camCF
            
            if progress > 0.9 then
                camera.FieldOfView = 70 + (progress - 0.9) * 150
                blur.Size = (progress - 0.9) * 40
                cc.Contrast = (progress - 0.9) * 3
            else
                camera.FieldOfView = 70 + math.sin(cruiseTime * 2) * 10
            end
            
            updateCockpit(cockpit, camera.CFrame)
            
            if progress >= 1 then
                cc.Saturation = -1
                cc.Contrast = 1
                blur.Size = 20
                topBar.Size = UDim2.new(1, 0, 0, 0)
                botBar.Size = UDim2.new(1, 0, 0, 0)
                
                if cruiseTime > totalCruise + 2 then
                    renderConn:Disconnect()
                    sceneFolder:Destroy()
                    gui:Destroy()
                    cc:Destroy()
                    blur:Destroy()
                    
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