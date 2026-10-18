local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

for _, obj in pairs(game:GetService("CoreGui"):GetChildren()) do if obj.Name == "PowerCrownUI" or obj.Name == "WindUI" or obj.Name == "CinematicUI" or obj.Name == "LoadingUI" then obj:Destroy() end end
for _, obj in pairs(player.PlayerGui:GetChildren()) do if obj.Name == "PowerCrownUI" or obj.Name == "WindUI" or obj.Name == "CinematicUI" or obj.Name == "LoadingUI" then obj:Destroy() end end
for _, obj in pairs(Workspace:GetChildren()) do if obj.Name == "CinematicScene" or obj.Name == "PrecisionCockpit" or obj.Name == "WormholeFX" then obj:Destroy() end end
for _, eff in pairs(Lighting:GetChildren()) do if eff:IsA("BloomEffect") or eff:IsA("ColorCorrectionEffect") or eff:IsA("BlurEffect") then eff:Destroy() end end

local success, WindUI = pcall(function() return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))() end)
if not success or not WindUI then StarterGui:SetCore("SendNotification",{Title="UI加载失败",Text="网络拦截",Duration=10}) return end

local Window = WindUI:CreateWindow({Title="封存娱乐 V1.7",Icon="film",Author="Cinematic",Folder="SpaceSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(280,180)})
local MainTab = Window:Tab({Title="控制",Icon="play"})
local CgSection = MainTab:Section({Title="极致电影级体验",Icon="video"})

local isPlaying = false
local sceneOrigin = Vector3.new(0, 15000, 0)

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

local function buildPrecisionCockpit()
    local folder = Instance.new("Folder", Workspace)
    folder.Name = "PrecisionCockpit"
    
    local frameMat = Enum.Material.Metal
    local frameCol = Color3.fromRGB(10, 12, 15)
    local neonBlue = Color3.fromRGB(0, 180, 255)
    
    local seat = makePart(folder, "Seat", Vector3.new(4, 6, 2), frameCol, Enum.Material.SmoothPlastic)
    local seatHead = makePart(folder, "SeatHead", Vector3.new(3, 3, 1), frameCol, Enum.Material.SmoothPlastic)
    
    local dash = makePart(folder, "Dash", Vector3.new(20, 6, 10), frameCol, frameMat)
    local dashTop = makePart(folder, "DashTop", Vector3.new(18, 1, 6), Color3.fromRGB(20, 22, 25), Enum.Material.SmoothPlastic)
    
    local glass = makePart(folder, "Glass", Vector3.new(20, 12, 0.2), Color3.fromRGB(50, 100, 150), Enum.Material.Glass, nil, nil, 0.85)
    
    local screen = makePart(folder, "Screen", Vector3.new(6, 3, 0.2), Color3.fromRGB(5, 10, 15), Enum.Material.SmoothPlastic)
    local sGui = Instance.new("SurfaceGui", screen)
    sGui.Face = Enum.NormalId.Top
    local sText = Instance.new("TextLabel", sGui)
    sText.Size = UDim2.fromScale(1, 1)
    sText.BackgroundTransparency = 1
    sText.Text = "WARP DRIVE: READY\nHULL INTEGRITY: 100%"
    sText.TextColor3 = neonBlue
    sText.Font = Enum.Font.Code
    sText.TextSize = 32
    
    local yoke = makePart(folder, "Yoke", Vector3.new(1, 4, 1), Color3.fromRGB(25, 25, 25), Enum.Material.Metal)
    local yokeTop = makePart(folder, "YokeTop", Vector3.new(4, 0.8, 1.5), Color3.fromRGB(35, 35, 35), Enum.Material.Metal)
    
    local btnFolder = Instance.new("Folder", folder)
    btnFolder.Name = "Buttons"
    for i = 1, 150 do
        local row = math.floor((i-1)/15)
        local col = (i-1)%15
        local btn = makePart(btnFolder, "Btn", Vector3.new(0.3, 0.15, 0.3), i%5==0 and Color3.fromRGB(255,50,50) or (i%3==0 and neonBlue or Color3.fromRGB(100,100,100)), Enum.Material.Neon)
    end
    
    return folder
end

local function updateCockpit(camCF)
    local cockpit = Workspace:FindFirstChild("PrecisionCockpit")
    if not cockpit then return end
    
    cockpit.Seat.CFrame = camCF * CFrame.new(0, -5.5, -1.5)
    cockpit.SeatHead.CFrame = cockpit.Seat.CFrame * CFrame.new(0, 4, 0)
    
    cockpit.Dash.CFrame = camCF * CFrame.new(0, -4.5, -6) * CFrame.Angles(math.rad(15), 0, 0)
    cockpit.DashTop.CFrame = cockpit.Dash.CFrame * CFrame.new(0, 2.8, -0.5)
    
    cockpit.Glass.CFrame = camCF * CFrame.new(0, 0, -9)
    
    cockpit.Screen.CFrame = cockpit.Dash.CFrame * CFrame.new(-4, 3.1, -0.5) * CFrame.Angles(math.rad(-25), math.rad(10), 0)
    
    cockpit.Yoke.CFrame = cockpit.Dash.CFrame * CFrame.new(0, 2.5, -3) * CFrame.Angles(math.rad(10), 0, 0)
    cockpit.YokeTop.CFrame = cockpit.Yoke.CFrame * CFrame.new(0, 2, 0)
    
    local btnFolder = cockpit:FindFirstChild("Buttons")
    if btnFolder then
        local i = 1
        for _, btn in ipairs(btnFolder:GetChildren()) do
            local row = math.floor((i-1)/15)
            local col = (i-1)%15
            btn.CFrame = cockpit.DashTop.CFrame * CFrame.new((col-7)*0.6, 0.6, (row-4)*0.6)
            i = i + 1
        end
    end
end

local function buildUniverse()
    local folder = Instance.new("Folder", Workspace)
    folder.Name = "CinematicScene"
    
    local planets = {}
    
    local earth = makePart(folder, "Earth", Vector3.new(1000, 1000, 1000), Color3.white, Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + Vector3.new(6000, 0, -12000)), Enum.PartType.Ball)
    local eMesh = Instance.new("SpecialMesh", earth)
    eMesh.MeshType = Enum.MeshType.Sphere
    eMesh.TextureId = "rbxassetid://218579141"
    local eAtmo = makePart(folder, "EAtmo", Vector3.new(1030, 1030, 1030), Color3.fromRGB(50, 150, 255), Enum.Material.ForceField, earth.CFrame, Enum.PartType.Ball, 0.4)
    
    local jupiter = makePart(folder, "Jupiter", Vector3.new(2400, 2400, 2400), Color3.white, Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + Vector3.new(-8000, 3000, -25000)), Enum.PartType.Ball)
    local jMesh = Instance.new("SpecialMesh", jupiter)
    jMesh.MeshType = Enum.MeshType.Sphere
    jMesh.TextureId = "rbxassetid://159128343"
    
    local saturn = makePart(folder, "Saturn", Vector3.new(1800, 1800, 1800), Color3.white, Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + Vector3.new(10000, -4000, -35000)), Enum.PartType.Ball)
    local sMesh = Instance.new("SpecialMesh", saturn)
    sMesh.MeshType = Enum.MeshType.Sphere
    sMesh.TextureId = "rbxassetid://159128304"
    
    for i = 1, 4 do
        local ring = makePart(folder, "Ring", Vector3.new(1800*(2 + i*0.3), 15, 1800*(2 + i*0.3)), Color3.fromRGB(150 - i*10, 130 - i*10, 100 - i*10), Enum.Material.Slate, nil, Enum.PartType.Cylinder, 0.2 + i*0.1)
        ring.CFrame = saturn.CFrame * CFrame.Angles(math.rad(25), 0, math.rad(10)) * CFrame.Angles(0,0,math.rad(90))
    end
    
    local stars = Instance.new("Folder", folder)
    for i = 1, 1000 do
        local rPos = sceneOrigin + Vector3.new(math.random(-50000, 50000), math.random(-50000, 50000), math.random(-80000, -10000))
        makePart(stars, "Star", Vector3.new(20,20,20), Color3.white, Enum.Material.Neon, CFrame.new(rPos), Enum.PartType.Ball, math.random(0.1, 0.7))
    end
    
    local wormhole = Instance.new("Folder", Workspace)
    wormhole.Name = "WormholeFX"
    local rings = {}
    for i = 1, 40 do
        local ring = makePart(wormhole, "Ring", Vector3.new(5, 300, 300), Color3.fromRGB(30, 60, 150), Enum.Material.Neon, nil, Enum.PartType.Cylinder, 0.6)
        table.insert(rings, {part = ring, dist = i * 150})
    end
    
    return folder, wormhole, {earth=earth, jupiter=jupiter, saturn=saturn}, rings
end

local function startCinematic()
    if isPlaying then return end
    isPlaying = true
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
    
    local origCamType = camera.CameraType
    local origFOV = camera.FieldOfView
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    cc.Contrast = 0.2
    cc.Saturation = -0.1
    cc.Brightness = -0.05
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    local loadingGui = Instance.new("ScreenGui", player.PlayerGui)
    loadingGui.Name = "LoadingUI"
    loadingGui.IgnoreGuiInset = true
    loadingGui.DisplayOrder = 1000
    
    local whiteBg = Instance.new("Frame", loadingGui)
    whiteBg.Size = UDim2.fromScale(1, 1)
    whiteBg.BackgroundColor3 = Color3.new(1, 1, 1)
    whiteBg.BorderSizePixel = 0
    
    local loadText = Instance.new("TextLabel", loadingGui)
    loadText.Size = UDim2.fromScale(1, 1)
    loadText.BackgroundTransparency = 1
    loadText.Text = "加载宇宙模型中... 3"
    loadText.TextColor3 = Color3.fromRGB(30, 30, 30)
    loadText.Font = Enum.Font.GothamBlack
    loadText.TextSize = 48
    
    task.spawn(function()
        local sceneFolder, wormholeFolder, planets, rings = buildUniverse()
        local cockpit = buildPrecisionCockpit()
        
        task.wait(1)
        loadText.Text = "加载宇宙模型中... 2"
        task.wait(1)
        loadText.Text = "加载宇宙模型中... 1"
        task.wait(1)
        
        loadingGui:Destroy()
        
        camera.CameraType = Enum.CameraType.Scriptable
        local startCamPos = hrp.CFrame * CFrame.new(0, 5, -15)
        camera.CFrame = startCamPos
        
        local gui = Instance.new("ScreenGui", player.PlayerGui)
        gui.Name = "CinematicUI"
        gui.IgnoreGuiInset = true
        
        local topBar = Instance.new("Frame", gui)
        topBar.Size = UDim2.new(1, 0, 0, 0)
        topBar.BackgroundColor3 = Color3.new(0,0,0)
        topBar.ZIndex = 10
        TweenService:Create(topBar, TweenInfo.new(2), {Size = UDim2.new(1, 0, 0.1, 0)}):Play()
        
        local botBar = Instance.new("Frame", gui)
        botBar.AnchorPoint = Vector2.new(0, 1)
        botBar.Position = UDim2.new(0, 0, 1, 0)
        botBar.Size = UDim2.new(1, 0, 0, 0)
        botBar.BackgroundColor3 = Color3.new(0,0,0)
        botBar.ZIndex = 10
        TweenService:Create(botBar, TweenInfo.new(2), {Size = UDim2.new(1, 0, 0.1, 0)}):Play()
        
        local startTime = tick()
        local flightT = 0
        
        local boardEnd = 3
        local taxiEnd = 8
        local warpEnd = 11
        local cruiseEnd = 33
        
        local startCamCF = startCamPos
        local targetCamCF = CFrame.new(sceneOrigin + Vector3.new(0, -4, -2))
        
        local renderConn
        renderConn = RunService.RenderStepped:Connect(function(dt)
            if not isPlaying then return end
            
            local t = tick() - startTime
            flightT = flightT + dt * 200
            
            if t < boardEnd then
                local alpha = math.min(t / boardEnd, 1)
                local smoothAlpha = alpha * alpha * (3 - 2 * alpha)
                camera.CFrame = startCamCF:Lerp(targetCamCF, smoothAlpha)
                camera.FieldOfView = 70 - smoothAlpha * 5
                blur.Size = smoothAlpha * 5
                
            elseif t < taxiEnd then
                local taxi = (t - boardEnd) / (taxiEnd - boardEnd)
                camera.CFrame = targetCamCF * CFrame.Angles(math.sin(t*3)*0.005, math.sin(t*2)*0.005, 0)
                camera.FieldOfView = 65 + math.sin(t*2) * 2
                updateCockpit(camera.CFrame)
                
                for i, r in ipairs(rings) do
                    local z = -5000 - r.dist + (flightT * 0.5)
                    r.part.CFrame = CFrame.new(sceneOrigin + Vector3.new(0, 0, z)) * CFrame.Angles(0, 0, math.rad(90))
                    r.part.Size = Vector3.new(5, 300 * (1+i/10), 300 * (1+i/10))
                    r.part.Transparency = math.clamp(0.3 + (i / 40), 0, 0.9)
                end
                
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
                cc.Contrast = warp * 2
                updateCockpit(camera.CFrame)
                
            elseif t < cruiseEnd then
                blur.Size = 0
                cc.TintColor = Color3.fromRGB(150, 170, 200)
                cc.Contrast = 0.2
                
                local cruiseTime = t - warpEnd
                local totalCruise = cruiseEnd - warpEnd
                local progress = math.min(cruiseTime / totalCruise, 1)
                
                local startPos = sceneOrigin + Vector3.new(0, -4, -2)
                local pathPos
                local lookAt
                
                if progress < 0.33 then
                    local p = progress / 0.33
                    pathPos = startPos:Lerp(planets.earth.CFrame.Position + Vector3.new(1000, 0, 1000), p)
                    lookAt = planets.earth.CFrame.Position
                elseif progress < 0.66 then
                    local p = (progress - 0.33) / 0.33
                    pathPos = (planets.earth.CFrame.Position + Vector3.new(1000, 0, 1000)):Lerp(planets.jupiter.CFrame.Position + Vector3.new(2400, 0, 2400), p)
                    lookAt = planets.jupiter.CFrame.Position
                else
                    local p = (progress - 0.66) / 0.34
                    pathPos = (planets.jupiter.CFrame.Position + Vector3.new(2400, 0, 2400)):Lerp(planets.saturn.CFrame.Position + Vector3.new(1800, 0, 1800), p)
                    lookAt = planets.saturn.CFrame.Position
                end
                
                local camCF = CFrame.lookAt(pathPos, lookAt)
                local shake = 0.02 + math.sin(cruiseTime * 8) * 0.01
                camCF = camCF * CFrame.Angles(math.noise(cruiseTime*20,0,0)*shake, math.noise(0,cruiseTime*20,0)*shake, 0)
                
                camera.CFrame = camCF
                camera.FieldOfView = 70 + math.sin(cruiseTime * 1.5) * 5
                updateCockpit(camera.CFrame)
                
            else
                cc.Saturation = -1
                cc.Contrast = 1
                blur.Size = 20
                topBar.Size = UDim2.new(1, 0, 0, 0)
                botBar.Size = UDim2.new(1, 0, 0, 0)
                
                if t > cruiseEnd + 2 then
                    renderConn:Disconnect()
                    sceneFolder:Destroy()
                    wormholeFolder:Destroy()
                    if cockpit then cockpit:Destroy() end
                    gui:Destroy()
                    cc:Destroy()
                    blur:Destroy()
                    
                    camera.CameraType = origCamType
                    camera.FieldOfView = origFOV
                    if hrp then hrp.Anchored = false end
                    isPlaying = false
                end
            end
        end)
    end)
end

CgSection:Button({Title="启动星际巡航", Callback=function()
    if not isPlaying then
        startCinematic()
    end
end})