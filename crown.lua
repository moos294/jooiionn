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
for _, obj in pairs(Workspace:GetChildren()) do if obj.Name == "CinematicScene" or obj.Name == "CockpitModel" then obj:Destroy() end end
for _, eff in pairs(Lighting:GetChildren()) do if eff:IsA("BloomEffect") or eff:IsA("ColorCorrectionEffect") or eff:IsA("BlurEffect") then eff:Destroy() end end

local success, WindUI = pcall(function() return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))() end)
if not success or not WindUI then StarterGui:SetCore("SendNotification",{Title="UI加载失败",Text="网络拦截",Duration=10}) return end

local Window = WindUI:CreateWindow({Title="封存娱乐 V1.6",Icon="film",Author="Cinematic",Folder="SpaceSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(280,180)})
local MainTab = Window:Tab({Title="控制",Icon="play"})
local CgSection = MainTab:Section({Title="电影级体验",Icon="video"})

local isPlaying = false
local sceneOrigin = Vector3.new(0, 5000, 0)
local cockpitModel = nil

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

local function buildUltraCockpit()
    local folder = Instance.new("Folder", Workspace)
    folder.Name = "CockpitModel"
    
    local frameCol = Color3.fromRGB(8, 10, 12)
    local metal = Enum.Material.Metal
    
    local lPillar = makePart(folder, "L", Vector3.new(2, 15, 20), frameCol, metal)
    local rPillar = makePart(folder, "R", Vector3.new(2, 15, 20), frameCol, metal)
    local topFrame = makePart(folder, "T", Vector3.new(22, 2, 20), frameCol, metal)
    
    local dash = makePart(folder, "Dash", Vector3.new(20, 8, 12), frameCol, metal)
    local dashTop = makePart(folder, "DashTop", Vector3.new(18, 1, 8), Color3.fromRGB(15, 18, 22), Enum.Material.SmoothPlastic)
    
    local screen = makePart(folder, "Screen", Vector3.new(6, 3, 0.2), Color3.fromRGB(0, 20, 30), Enum.Material.Neon)
    local sGui = Instance.new("SurfaceGui", screen)
    sGui.Face = Enum.NormalId.Top
    local sText = Instance.new("TextLabel", sGui)
    sText.Size = UDim2.fromScale(1,1)
    sText.BackgroundTransparency = 1
    sText.Text = "SYSTEM: BOOTING\nVEL: 0 m/s\nHULL: 100%"
    sText.TextColor3 = Color3.fromRGB(0, 255, 255)
    sText.Font = Enum.Font.Code
    sText.TextSize = 36
    
    local yoke = makePart(folder, "Yoke", Vector3.new(1, 4, 1), Color3.fromRGB(20,20,20), metal)
    local yokeTop = makePart(folder, "YokeTop", Vector3.new(4, 0.8, 1.5), Color3.fromRGB(25,25,25), metal)
    
    local glassL = makePart(folder, "GL", Vector3.new(9, 12, 0.2), Color3.fromRGB(50, 100, 150), Enum.Material.Glass, nil, nil, 0.9)
    local glassR = makePart(folder, "GR", Vector3.new(9, 12, 0.2), Color3.fromRGB(50, 100, 150), Enum.Material.Glass, nil, nil, 0.9)
    
    local btnFolder = Instance.new("Folder", folder)
    for i = 1, 200 do
        local row = math.floor((i-1)/20)
        local col = (i-1)%20
        local btn = makePart(btnFolder, "Btn", Vector3.new(0.25, 0.1, 0.25), i%5==0 and Color3.fromRGB(255,50,50) or (i%3==0 and Color3.fromRGB(50,255,50) or Color3.fromRGB(50,150,255)), Enum.Material.Neon)
        btn.CFrame = dashTop.CFrame * CFrame.new((col-10)*0.5, 0.1, (row-4)*0.5)
    end
    
    return folder
end

local function updateCockpit(camCF)
    if not cockpitModel then return end
    cockpitModel.L.CFrame = camCF * CFrame.new(-9, 0, -6)
    cockpitModel.R.CFrame = camCF * CFrame.new(9, 0, -6)
    cockpitModel.T.CFrame = camCF * CFrame.new(0, 7, -6)
    cockpitModel.Dash.CFrame = camCF * CFrame.new(0, -7, -8) * CFrame.Angles(math.rad(10), 0, 0)
    cockpitModel.DashTop.CFrame = cockpitModel.Dash.CFrame * CFrame.new(0, 4, -1)
    cockpitModel.Screen.CFrame = cockpitModel.Dash.CFrame * CFrame.new(-4, 4.2, -1) * CFrame.Angles(math.rad(-20), 0, 0)
    cockpitModel.Yoke.CFrame = cockpitModel.Dash.CFrame * CFrame.new(0, 2.5, -3) * CFrame.Angles(math.rad(15), 0, 0)
    cockpitModel.YokeTop.CFrame = cockpitModel.Yoke.CFrame * CFrame.new(0, 2, 0)
    cockpitModel.GL.CFrame = camCF * CFrame.new(-4.5, 0, -9) * CFrame.Angles(0, math.rad(10), 0)
    cockpitModel.GR.CFrame = camCF * CFrame.new(4.5, 0, -9) * CFrame.Angles(0, math.rad(-10), 0)
end

local function buildRealPlanets()
    local folder = Instance.new("Folder", Workspace)
    folder.Name = "CinematicScene"
    
    local planets = {}
    
    local earth = makePart(folder, "Earth", Vector3.new(400, 400, 400), Color3.fromRGB(20, 60, 150), Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + Vector3.new(6000, -1000, -15000)), Enum.PartType.Ball)
    local eMesh = Instance.new("SpecialMesh", earth)
    eMesh.MeshType = Enum.MeshType.Sphere
    eMesh.TextureId = "rbxassetid://218579141"
    
    local eCloud = makePart(folder, "ECloud", Vector3.new(404, 404, 404), Color3.white, Enum.Material.SmoothPlastic, earth.CFrame, Enum.PartType.Ball, 0.8)
    local eAtmo = makePart(folder, "EAtmo", Vector3.new(420, 420, 420), Color3.fromRGB(80, 150, 255), Enum.Material.ForceField, earth.CFrame, Enum.PartType.Ball, 0.5)
    local eLight = Instance.new("PointLight", earth)
    eLight.Color = Color3.fromRGB(100, 150, 255)
    eLight.Brightness = 2
    eLight.Range = 1000
    
    local jupiter = makePart(folder, "Jupiter", Vector3.new(1200, 1200, 1200), Color3.fromRGB(200, 170, 140), Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + Vector3.new(-8000, 2000, -25000)), Enum.PartType.Ball)
    local jMesh = Instance.new("SpecialMesh", jupiter)
    jMesh.MeshType = Enum.MeshType.Sphere
    jMesh.TextureId = "rbxassetid://159128343"
    
    local saturn = makePart(folder, "Saturn", Vector3.new(1000, 1000, 1000), Color3.fromRGB(220, 200, 160), Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + Vector3.new(5000, -2000, -35000)), Enum.PartType.Ball)
    local sMesh = Instance.new("SpecialMesh", saturn)
    sMesh.MeshType = Enum.MeshType.Sphere
    sMesh.TextureId = "rbxassetid://159128304"
    
    for i = 1, 4 do
        local ring = makePart(folder, "Ring", Vector3.new(1000*(1.8 + i*0.2), 15, 1000*(1.8 + i*0.2)), Color3.fromRGB(180, 160, 130), Enum.Material.Slate, nil, Enum.PartType.Cylinder, 0.2 + i*0.1)
        ring.CFrame = saturn.CFrame * CFrame.Angles(math.rad(15), 0, math.rad(20)) * CFrame.Angles(0,0,math.rad(90))
    end
    
    local stars = Instance.new("Folder", folder)
    for i = 1, 1000 do
        local rPos = sceneOrigin + Vector3.new(math.random(-50000, 50000), math.random(-50000, 50000), math.random(-60000, -10000))
        makePart(stars, "Star", Vector3.new(20,20,20), Color3.white, Enum.Material.Neon, CFrame.new(rPos), Enum.PartType.Ball, math.random(0, 0.5))
    end
    
    return folder, {earth=earth, jupiter=jupiter, saturn=saturn}
end

local function startCinematic()
    if isPlaying then return end
    isPlaying = true
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
    
    local origCamType = camera.CameraType
    local origFOV = camera.FieldOfView
    camera.CameraType = Enum.CameraType.Scriptable
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Contrast = 0.1
    cc.Brightness = -0.1
    cc.Saturation = -0.2
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "CinematicUI"
    gui.IgnoreGuiInset = true
    
    local topBar = Instance.new("Frame", gui)
    topBar.Size = UDim2.new(1, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.new(0,0,0)
    topBar.ZIndex = 10
    TweenService:Create(topBar, TweenInfo.new(1), {Size = UDim2.new(1, 0, 0.1, 0)}):Play()
    
    local botBar = Instance.new("Frame", gui)
    botBar.AnchorPoint = Vector2.new(0, 1)
    botBar.Position = UDim2.new(0, 0, 1, 0)
    botBar.Size = UDim2.new(1, 0, 0, 0)
    botBar.BackgroundColor3 = Color3.new(0,0,0)
    botBar.ZIndex = 10
    TweenService:Create(botBar, TweenInfo.new(1), {Size = UDim2.new(1, 0, 0.1, 0)}):Play()
    
    local sceneFolder, planets = buildRealPlanets()
    cockpitModel = buildUltraCockpit()
    
    local wormholeFolder = Instance.new("Folder", sceneFolder)
    local rings = {}
    for i = 1, 40 do
        local ring = makePart(wormholeFolder, "Ring", Vector3.new(5, 300, 300), Color3.fromRGB(30, 60, 150), Enum.Material.Neon, nil, Enum.PartType.Cylinder, 0.6)
        table.insert(rings, {part = ring, dist = i * 150})
    end
    
    local startTime = tick()
    local flightT = 0
    
    local startCamCF = camera.CFrame
    local targetCamCF = CFrame.new(sceneOrigin + Vector3.new(0, -4, -2))
    
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function(dt)
        if not isPlaying then return end
        
        local t = tick() - startTime
        flightT = flightT + dt * 200
        
        if t < 3 then
            local alpha = math.min(t / 3, 1)
            local smoothAlpha = alpha * alpha * (3 - 2 * alpha)
            camera.CFrame = startCamCF:Lerp(targetCamCF, smoothAlpha)
            camera.FieldOfView = 70 - smoothAlpha * 5
            blur.Size = smoothAlpha * 5
            
        elseif t < 9 then
            local taxi = (t - 3) / 6
            camera.CFrame = targetCamCF * CFrame.Angles(math.sin(t*3)*0.005, math.sin(t*2)*0.005, 0)
            camera.FieldOfView = 65 + math.sin(t*2) * 2
            
            for i, r in ipairs(rings) do
                local z = -5000 - r.dist + (flightT * 0.5)
                r.part.CFrame = CFrame.new(sceneOrigin + Vector3.new(0, 0, z)) * CFrame.Angles(0, 0, math.rad(90))
                r.part.Size = Vector3.new(5, 300 * (1+i/10), 300 * (1+i/10))
                r.part.Transparency = math.clamp(0.3 + (i / 40), 0, 0.9)
            end
            
            if t > 6 then
                local warpUp = (t - 6) / 3
                blur.Size = warpUp * 20
                cc.TintColor = Color3.fromRGB(150, 170 + warpUp*50, 200 + warpUp*55)
                camera.FieldOfView = 65 + warpUp * 30
            end
            
        elseif t >= 9 and t < 11 then
            local warp = (t - 9) / 2
            camera.FieldOfView = 95 + warp * 40
            blur.Size = 20 + warp * 30
            cc.TintColor = Color3.white
            cc.Contrast = warp * 2
            
        else
            blur.Size = 0
            cc.TintColor = Color3.fromRGB(150, 170, 200)
            cc.Contrast = 0.1
            
            local cruiseTime = t - 11
            local totalCruise = 22
            local progress = math.min(cruiseTime / totalCruise, 1)
            
            local startPos = sceneOrigin + Vector3.new(0, -4, -2)
            local pathPos
            local lookAt
            
            if progress < 0.33 then
                local p = progress / 0.33
                pathPos = startPos:Lerp(planets.earth.CFrame.Position + Vector3.new(400, 0, 400), p)
                lookAt = planets.earth.CFrame.Position
            elseif progress < 0.66 then
                local p = (progress - 0.33) / 0.33
                pathPos = (planets.earth.CFrame.Position + Vector3.new(400, 0, 400)):Lerp(planets.jupiter.CFrame.Position + Vector3.new(1200, 0, 1200), p)
                lookAt = planets.jupiter.CFrame.Position
            else
                local p = (progress - 0.66) / 0.34
                pathPos = (planets.jupiter.CFrame.Position + Vector3.new(1200, 0, 1200)):Lerp(planets.saturn.CFrame.Position + Vector3.new(1000, 0, 1000), p)
                lookAt = planets.saturn.CFrame.Position
            end
            
            local camCF = CFrame.lookAt(pathPos, lookAt)
            local shake = 0.02 + math.sin(cruiseTime * 8) * 0.01
            camCF = camCF * CFrame.Angles(math.noise(cruiseTime*20,0,0)*shake, math.noise(0,cruiseTime*20,0)*shake, 0)
            
            camera.CFrame = camCF
            camera.FieldOfView = 70 + math.sin(cruiseTime * 1.5) * 5
            
            if progress >= 1 then
                cc.Saturation = -1
                cc.Contrast = 1
                blur.Size = 20
                topBar.Size = UDim2.new(1, 0, 0, 0)
                botBar.Size = UDim2.new(1, 0, 0, 0)
                
                if cruiseTime > totalCruise + 2 then
                    renderConn:Disconnect()
                    sceneFolder:Destroy()
                    if cockpitModel then cockpitModel:Destroy() end
                    gui:Destroy()
                    cc:Destroy()
                    blur:Destroy()
                    
                    camera.CameraType = origCamType
                    camera.FieldOfView = origFOV
                    if hrp then hrp.Anchored = false end
                    isPlaying = false
                end
            end
        end
        
        if t >= 3 then
            updateCockpit(camera.CFrame)
        end
    end)
end

CgSection:Button({Title="启动星际巡航", Callback=function()
    if not isPlaying then
        startCinematic()
    end
end})