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

local Window = WindUI:CreateWindow({Title="封存娱乐 V1.2",Icon="film",Author="Cinematic",Folder="SpaceSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(300,200)})
local MainTab = Window:Tab({Title="控制",Icon="play"})
local CgSection = MainTab:Section({Title="电影级体验",Icon="video"})

local isPlaying = false
local sceneOrigin = Vector3.new(0, 200000, 0)

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
    
    local sun = makePart(folder, "Sun", Vector3.new(3000, 3000, 3000), Color3.fromRGB(255, 120, 50), Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin), Enum.PartType.Ball)
    sun.Material = Enum.Material.Neon
    sun.Transparency = 0.2
    local sunLight = Instance.new("PointLight", sun)
    sunLight.Range = 30000
    sunLight.Brightness = 2
    sunLight.Color = Color3.fromRGB(255, 150, 100)
    
    local pDefs = {
        {name="Earth", pos=Vector3.new(8000, 0, 0), size=600, col=Color3.fromRGB(20, 50, 100), atmo=Color3.fromRGB(50, 100, 200)},
        {name="Mars", pos=Vector3.new(14000, 2000, 8000), size=400, col=Color3.fromRGB(100, 40, 30), atmo=Color3.fromRGB(150, 50, 30)},
        {name="Jupiter", pos=Vector3.new(22000, -2000, 14000), size=1800, col=Color3.fromRGB(120, 90, 70), atmo=Color3.fromRGB(150, 120, 90)},
        {name="Saturn", pos=Vector3.new(32000, 3000, 20000), size=1500, col=Color3.fromRGB(150, 130, 100), atmo=Color3.fromRGB(180, 160, 120)},
        {name="Neptune", pos=Vector3.new(45000, -3000, 28000), size=1000, col=Color3.fromRGB(30, 60, 150), atmo=Color3.fromRGB(50, 100, 255)}
    }
    
    for _, def in ipairs(pDefs) do
        local p = makePart(folder, def.name, Vector3.new(def.size, def.size, def.size), def.col, Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + def.pos), Enum.PartType.Ball)
        local atmo = makePart(folder, "Atmo", Vector3.new(def.size*1.05, def.size*1.05, def.size*1.05), def.atmo, Enum.Material.ForceField, CFrame.new(sceneOrigin + def.pos), Enum.PartType.Ball, 0.6)
        
        if def.name == "Saturn" then
            for i = 1, 2 do
                local ring = makePart(folder, "Ring", Vector3.new(def.size*(2.2 + i*0.2), 20, def.size*(2.2 + i*0.2)), Color3.fromRGB(100, 90, 80), Enum.Material.SmoothPlastic, nil, Enum.PartType.Cylinder, 0.3)
                ring.CFrame = CFrame.new(sceneOrigin + def.pos) * CFrame.Angles(math.rad(15), 0, math.rad(15)) * CFrame.Angles(0,0,math.rad(90))
            end
        elseif def.name == "Jupiter" then
            for i = 1, 6 do
                local band = makePart(folder, "Band", Vector3.new(def.size*1.01, 50, def.size*1.01), Color3.fromRGB(90, 70, 60), Enum.Material.SmoothPlastic, nil, Enum.PartType.Cylinder, 0.5)
                band.CFrame = CFrame.new(sceneOrigin + def.pos + Vector3.new(0, (i-3.5)*200, 0)) * CFrame.Angles(0,0,math.rad(90))
            end
        end
        table.insert(planets, {pos = sceneOrigin + def.pos, name = def.name, size = def.size})
    end
    
    return planets
end

local function createUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CinematicUI"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.Parent = player.PlayerGui
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Contrast = 0.2
    cc.Saturation = -0.2
    cc.Brightness = -0.05
    cc.TintColor = Color3.fromRGB(150, 170, 200)
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    local topBar = Instance.new("Frame", gui)
    topBar.Size = UDim2.new(1, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.new(0,0,0)
    topBar.ZIndex = 10
    
    local botBar = Instance.new("Frame", gui)
    botBar.AnchorPoint = Vector2.new(0, 1)
    botBar.Position = UDim2.new(0, 0, 1, 0)
    botBar.Size = UDim2.new(1, 0, 0, 0)
    botBar.BackgroundColor3 = Color3.new(0,0,0)
    botBar.ZIndex = 10
    
    TweenService:Create(topBar, TweenInfo.new(2), {Size = UDim2.new(1, 0, 0.15, 0)}):Play()
    TweenService:Create(botBar, TweenInfo.new(2), {Size = UDim2.new(1, 0, 0.15, 0)}):Play()
    
    local cockpit = Instance.new("Frame", gui)
    cockpit.Size = UDim2.new(1, 0, 1, 0)
    cockpit.BackgroundTransparency = 1
    cockpit.ZIndex = 5
    
    local leftFrame = Instance.new("Frame", cockpit)
    leftFrame.Size = UDim2.new(0.2, 0, 1, 0)
    leftFrame.Position = UDim2.new(0, 0, 0, 0)
    leftFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 15)
    leftFrame.BorderSizePixel = 0
    
    local rightFrame = Instance.new("Frame", cockpit)
    rightFrame.Size = UDim2.new(0.2, 0, 1, 0)
    rightFrame.Position = UDim2.new(0.8, 0, 0, 0)
    rightFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 15)
    rightFrame.BorderSizePixel = 0
    
    local dash = Instance.new("Frame", cockpit)
    dash.Size = UDim2.new(0.8, 0, 0.25, 0)
    dash.Position = UDim2.new(0.1, 0, 0.75, 0)
    dash.BackgroundColor3 = Color3.fromRGB(15, 18, 22)
    dash.BorderSizePixel = 0
    
    local dashTop = Instance.new("Frame", cockpit)
    dashTop.Size = UDim2.new(0.8, 0, 0.02, 0)
    dashTop.Position = UDim2.new(0.1, 0, 0.73, 0)
    dashTop.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    dashTop.BorderSizePixel = 0
    
    local radar = Instance.new("Frame", dash)
    radar.Size = UDim2.new(0.3, 0, 0.7, 0)
    radar.Position = UDim2.new(0.05, 0, 0.15, 0)
    radar.BackgroundColor3 = Color3.fromRGB(0, 20, 30)
    radar.BorderSizePixel = 2
    radar.BorderColor3 = Color3.fromRGB(0, 100, 150)
    
    local radarText = Instance.new("TextLabel", radar)
    radarText.Size = UDim2.fromScale(1, 1)
    radarText.BackgroundTransparency = 1
    radarText.Text = "SYSTEM\nONLINE\nCRUISE MODE"
    radarText.TextColor3 = Color3.fromRGB(0, 200, 255)
    radarText.Font = Enum.Font.Code
    radarText.TextSize = 18
    
    local yokeBase = Instance.new("Frame", dash)
    yokeBase.Size = UDim2.new(0.15, 0, 0.4, 0)
    yokeBase.Position = UDim2.new(0.5, 0, 0.5, 0)
    yokeBase.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    yokeBase.BorderSizePixel = 2
    yokeBase.BorderColor3 = Color3.fromRGB(50, 50, 50)
    
    local yokeTop = Instance.new("Frame", yokeBase)
    yokeTop.Size = UDim2.new(1.5, 0, 0.3, 0)
    yokeTop.Position = UDim2.new(-0.25, 0, -0.2, 0)
    yokeTop.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    yokeTop.BorderSizePixel = 2
    yokeTop.BorderColor3 = Color3.fromRGB(80, 80, 80)
    
    local btnFrame = Instance.new("Frame", dash)
    btnFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
    btnFrame.Position = UDim2.new(0.55, 0, 0.2, 0)
    btnFrame.BackgroundTransparency = 1
    
    local btnLayout = Instance.new("UIListLayout", btnFrame)
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    btnLayout.Padding = UDim.new(0, 10)
    btnLayout.Wraps = true
    
    for i = 1, 15 do
        local btn = Instance.new("Frame", btnFrame)
        btn.Size = UDim2.fromOffset(30, 30)
        btn.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(0, 100, 150)
        
        local light = Instance.new("Frame", btn)
        light.Size = UDim2.new(0.5, 0, 0.5, 0)
        light.Position = UDim2.new(0.25, 0, 0.25, 0)
        light.BackgroundColor3 = i % 3 == 0 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
        light.BorderSizePixel = 0
    end
    
    return gui, cc, blur, topBar, botBar
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
    
    local gui, cc, blur, topBar, botBar = createUI()
    local planets = buildSpace(sceneFolder)
    
    local wormholeFolder = Instance.new("Folder", sceneFolder)
    local rings = {}
    for i = 1, 50 do
        local ring = makePart(wormholeFolder, "Ring", Vector3.new(10, 500, 500), Color3.fromRGB(10, 20, 40), Enum.Material.SmoothPlastic, nil, Enum.PartType.Cylinder, 0.8)
        ring.CFrame = CFrame.new(sceneOrigin + Vector3.new(0, 0, -20000)) * CFrame.Angles(0, 0, math.rad(90))
        local light = Instance.new("PointLight", ring)
        light.Color = Color3.fromRGB(50, 100, 255)
        light.Brightness = 0.5
        light.Range = 1000
        table.insert(rings, {part = ring, dist = i * 100})
    end
    
    local startTime = tick()
    local flightT = 0
    
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not isPlaying then return end
        
        local t = tick() - startTime
        flightT = flightT + dt * 150
        
        if t < 6 then
            cc.Brightness = -0.1
            cc.Contrast = 0.4
            cc.TintColor = Color3.fromRGB(100, 120, 150)
            blur.Size = 0
            
            local camPos = sceneOrigin + Vector3.new(0, 0, 5000 - (t * 500))
            local lookAt = sceneOrigin + Vector3.new(0, 0, -20000)
            camera.CFrame = CFrame.lookAt(camPos, lookAt)
            camera.FieldOfView = 60
            
            for i, r in ipairs(rings) do
                local ringZ = r.dist - flightT
                r.part.CFrame = CFrame.new(sceneOrigin + Vector3.new(0, 0, -20000 + ringZ)) * CFrame.Angles(0, 0, math.rad(90))
                r.part.Transparency = math.clamp(0.5 + (i/100), 0, 0.9)
            end
            
            if t > 3 then
                local pulse = math.sin((t - 3) * 10) * 0.5 + 0.5
                cc.Contrast = 0.4 + pulse * 0.2
            end
            
        elseif t >= 6 and t < 8 then
            local warp = (t - 6) / 2
            blur.Size = warp * 20
            cc.Contrast = 0.6 + warp
            cc.TintColor = Color3.fromRGB(200, 220, 255)
            camera.FieldOfView = 60 + warp * 40
            camera.CFrame = CFrame.lookAt(sceneOrigin + Vector3.new(0,0, -flightT), sceneOrigin + Vector3.new(0,0,-20000))
            
        else
            blur.Size = 0
            cc.Contrast = 0.2
            cc.TintColor = Color3.fromRGB(150, 170, 200)
            
            local cruiseTime = t - 8
            local totalCruise = 22
            local progress = math.min(cruiseTime / totalCruise, 1)
            
            local targetPlanet = planets[3]
            local startPos = sceneOrigin + Vector3.new(0, 0, 0)
            local endPos = targetPlanet.pos + Vector3.new(targetPlanet.size * 1.5, targetPlanet.size * 0.5, targetPlanet.size * 1.5)
            
            local currentPos = startPos:Lerp(endPos, progress)
            local lookTarget = currentPos + Vector3.new(0, 0, -500)
            
            if progress > 0.1 and progress < 0.9 then
                local idx = math.floor(progress * #planets) + 1
                if idx > #planets then idx = #planets end
                lookTarget = planets[idx].pos
            elseif progress >= 0.9 then
                lookTarget = targetPlanet.pos
            end
            
            local camCF = CFrame.lookAt(currentPos, lookTarget)
            local shake = 0.1 + math.sin(cruiseTime * 5) * 0.05
            if progress > 0.9 then shake = 1 end
            
            camCF = camCF * CFrame.Angles(math.noise(cruiseTime*30,0,0)*shake, math.noise(0,cruiseTime*30,0)*shake, 0)
            camera.CFrame = camCF
            
            if progress > 0.9 then
                camera.FieldOfView = 70 + (progress - 0.9) * 200
                blur.Size = (progress - 0.9) * 40
                cc.Contrast = (progress - 0.9) * 4
            else
                camera.FieldOfView = 60 + math.sin(cruiseTime * 1.5) * 5
            end
            
            if progress >= 1 then
                cc.Saturation = -1
                cc.Contrast = 1
                cc.Brightness = -0.2
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

CgSection:Button({Title="启动星际巡航", Callback=function()
    if not isPlaying then
        startCinematic()
    end
end})