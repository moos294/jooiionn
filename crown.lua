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

local Window = WindUI:CreateWindow({Title="封存娱乐 V2.0",Icon="film",Author="Cinematic",Folder="SpaceSave",Theme="Dark",Transparent=true,Resizable=false,Size=UDim2.fromOffset(280,180)})
local MainTab = Window:Tab({Title="控制",Icon="play"})
local CgSection = MainTab:Section({Title="极致电影级体验",Icon="video"})

local isPlaying = false
local sceneOrigin = Vector3.new(0, 20000, 0)

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
    cc.Brightness = -0.1
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    local loadingGui = Instance.new("ScreenGui", player.PlayerGui)
    loadingGui.Name = "LoadingUI"
    loadingGui.IgnoreGuiInset = true
    loadingGui.DisplayOrder = 1000
    
    local whiteBg = Instance.new("Frame", loadingGui)
    whiteBg.Size = UDim2.fromScale(1, 1)
    whiteBg.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    whiteBg.BorderSizePixel = 0
    
    local loadText = Instance.new("TextLabel", loadingGui)
    loadText.Size = UDim2.fromScale(1, 0.4)
    loadText.Position = UDim2.fromScale(0, 0.2)
    loadText.BackgroundTransparency = 1
    loadText.Text = "正在构建深空场景 0%"
    loadText.TextColor3 = Color3.fromRGB(0, 200, 255)
    loadText.Font = Enum.Font.GothamBold
    loadText.TextSize = 28
    
    local barBg = Instance.new("Frame", loadingGui)
    barBg.Size = UDim2.fromOffset(300, 10)
    barBg.Position = UDim2.fromScale(0.5, 0.5)
    barBg.AnchorPoint = Vector2.new(0.5, 0.5)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
    
    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.fromScale(0, 1)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    barFill.BorderSizePixel = 0
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
    
    task.spawn(function()
        local s, err = pcall(function()
            local pFolder = Instance.new("Folder", Workspace)
            pFolder.Name = "PrecisionCockpit"
            local frameCol = Color3.fromRGB(10, 12, 15)
            local metal = Enum.Material.Metal
            
            local lPillar = makePart(pFolder, "L", Vector3.new(2, 15, 20), frameCol, metal)
            local rPillar = makePart(pFolder, "R", Vector3.new(2, 15, 20), frameCol, metal)
            local topFrame = makePart(pFolder, "T", Vector3.new(22, 2, 20), frameCol, metal)
            local dash = makePart(pFolder, "Dash", Vector3.new(20, 8, 12), frameCol, metal)
            local dashTop = makePart(pFolder, "DashTop", Vector3.new(18, 1, 8), Color3.fromRGB(15, 18, 22), Enum.Material.SmoothPlastic)
            local screen = makePart(pFolder, "Screen", Vector3.new(6, 3, 0.2), Color3.fromRGB(0, 20, 30), Enum.Material.Neon)
            
            local sGui = Instance.new("SurfaceGui", screen)
            sGui.Face = Enum.NormalId.Top
            local sText = Instance.new("TextLabel", sGui)
            sText.Size = UDim2.fromScale(1,1)
            sText.BackgroundTransparency = 1
            sText.Text = "SYSTEM: ONLINE\nVEL: WARP\nHULL: 100%"
            sText.TextColor3 = Color3.fromRGB(0, 255, 255)
            sText.Font = Enum.Font.Code
            sText.TextSize = 32
            
            local yoke = makePart(pFolder, "Yoke", Vector3.new(1, 4, 1), Color3.fromRGB(20,20,20), metal)
            local yokeTop = makePart(pFolder, "YokeTop", Vector3.new(4, 0.8, 1.5), Color3.fromRGB(25,25,25), metal)
            local glassL = makePart(pFolder, "GL", Vector3.new(9, 12, 0.2), Color3.fromRGB(50, 100, 150), Enum.Material.Glass, nil, nil, 0.85)
            local glassR = makePart(pFolder, "GR", Vector3.new(9, 12, 0.2), Color3.fromRGB(50, 100, 150), Enum.Material.Glass, nil, nil, 0.85)
            
            local btnFolder = Instance.new("Folder", pFolder)
            btnFolder.Name = "Buttons"
            for i = 1, 100 do
                local btn = makePart(btnFolder, "Btn", Vector3.new(0.25, 0.1, 0.25), i%5==0 and Color3.fromRGB(255,50,50) or (i%3==0 and Color3.fromRGB(50,255,50) or Color3.fromRGB(50,150,255)), Enum.Material.Neon)
                if i % 20 == 0 then task.wait() end
            end
            
            local sceneFolder = Instance.new("Folder", Workspace)
            sceneFolder.Name = "CinematicScene"
            local planets = {}
            
            local earth = makePart(sceneFolder, "Earth", Vector3.new(1000, 1000, 1000), Color3.white, Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + Vector3.new(6000, 0, -12000)), Enum.PartType.Ball)
            local eMesh = Instance.new("SpecialMesh", earth)
            eMesh.MeshType = Enum.MeshType.Sphere
            eMesh.TextureId = "rbxassetid://218579141"
            local eAtmo = makePart(sceneFolder, "EAtmo", Vector3.new(1030, 1030, 1030), Color3.fromRGB(50, 150, 255), Enum.Material.ForceField, earth.CFrame, Enum.PartType.Ball, 0.4)
            
            local jupiter = makePart(sceneFolder, "Jupiter", Vector3.new(2400, 2400, 2400), Color3.white, Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + Vector3.new(-8000, 3000, -25000)), Enum.PartType.Ball)
            local jMesh = Instance.new("SpecialMesh", jupiter)
            jMesh.MeshType = Enum.MeshType.Sphere
            jMesh.TextureId = "rbxassetid://159128343"
            
            local saturn = makePart(sceneFolder, "Saturn", Vector3.new(1800, 1800, 1800), Color3.white, Enum.Material.SmoothPlastic, CFrame.new(sceneOrigin + Vector3.new(10000, -4000, -35000)), Enum.PartType.Ball)
            local sMesh = Instance.new("SpecialMesh", saturn)
            sMesh.MeshType = Enum.MeshType.Sphere
            sMesh.TextureId = "rbxassetid://159128304"
            
            for i = 1, 3 do
                local ring = makePart(sceneFolder, "Ring", Vector3.new(1800*(2 + i*0.3), 15, 1800*(2 + i*0.3)), Color3.fromRGB(150 - i*10, 130 - i*10, 100 - i*10), Enum.Material.Slate, nil, Enum.PartType.Cylinder, 0.2 + i*0.1)
                ring.CFrame = saturn.CFrame * CFrame.Angles(math.rad(25), 0, math.rad(10)) * CFrame.Angles(0,0,math.rad(90))
                task.wait()
            end
            
            planets = {earth=earth, jupiter=jupiter, saturn=saturn}
            
            local stars = Instance.new("Folder", sceneFolder)
            for i = 1, 600 do
                local rPos = sceneOrigin + Vector3.new(math.random(-50000, 50000), math.random(-50000, 50000), math.random(-80000, -10000))
                makePart(stars, "Star", Vector3.new(20,20,20), Color3.white, Enum.Material.Neon, CFrame.new(rPos), Enum.PartType.Ball, math.random(0.1, 0.7))
                if i % 50 == 0 then
                    barFill.Size = UDim2.fromScale(0.2 + (i / 600) * 0.4, 1)
                    loadText.Text = "正在生成星际航标 " .. math.floor((i / 600) * 100) .. "%"
                    task.wait()
                end
            end
            
            local wormhole = Instance.new("Folder", Workspace)
            wormhole.Name = "WormholeFX"
            local rings = {}
            for i = 1, 40 do
                local ring = makePart(wormhole, "Ring", Vector3.new(5, 300, 300), Color3.fromRGB(30, 60, 150), Enum.Material.Neon, nil, Enum.PartType.Cylinder, 0.6)
                table.insert(rings, {part = ring, dist = i * 150})
                if i % 10 == 0 then
                    barFill.Size = UDim2.fromScale(0.6 + (i / 40) * 0.4, 1)
                    loadText.Text = "正在构建虫洞通道 " .. math.floor((i / 40) * 100) .. "%"
                    task.wait()
                end
            end
            
            task.wait(0.5)
            loadText.Text = "加载完毕，即将睁眼"
            
            task.wait(1)
            loadingGui:Destroy()
            
            camera.CameraType = Enum.CameraType.Scriptable
            local startCamPos = hrp.CFrame * CFrame.new(0, 5, -15)
            camera.CFrame = startCamPos
            
            local eyeGui = Instance.new("ScreenGui", player.PlayerGui)
            eyeGui.Name = "CinematicUI"
            eyeGui.IgnoreGuiInset = true
            
            local topBar = Instance.new("Frame", eyeGui)
            topBar.Size = UDim2.new(1, 0, 0.5, 0)
            topBar.Position = UDim2.new(0, 0, 0, 0)
            topBar.BackgroundColor3 = Color3.new(0,0,0)
            topBar.ZIndex = 10
            
            local botBar = Instance.new("Frame", eyeGui)
            botBar.Size = UDim2.new(1, 0, 0.5, 0)
            botBar.Position = UDim2.new(0, 0, 0.5, 0)
            botBar.BackgroundColor3 = Color3.new(0,0,0)
            botBar.ZIndex = 10
            
            blur.Size = 30
            cc.Brightness = -0.5
            
            TweenService:Create(topBar, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0.1, 0)}):Play()
            TweenService:Create(botBar, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0.1, 0), Position = UDim2.new(0, 0, 0.9, 0)}):Play()
            TweenService:Create(blur, TweenInfo.new(1.5), {Size = 0}):Play()
            TweenService:Create(cc, TweenInfo.new(1.5), {Brightness = -0.1}):Play()
            
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
                
                local cockpit = Workspace:FindFirstChild("PrecisionCockpit")
                if cockpit then
                    local L = cockpit:FindFirstChild("L")
                    if L then L.CFrame = camera.CFrame * CFrame.new(-9, 0, -6) end
                    local R = cockpit:FindFirstChild("R")
                    if R then R.CFrame = camera.CFrame * CFrame.new(9, 0, -6) end
                    local T = cockpit:FindFirstChild("T")
                    if T then T.CFrame = camera.CFrame * CFrame.new(0, 7, -6) end
                    
                    local Dash = cockpit:FindFirstChild("Dash")
                    if Dash then
                        Dash.CFrame = camera.CFrame * CFrame.new(0, -7, -8) * CFrame.Angles(math.rad(10), 0, 0)
                        local DashTop = cockpit:FindFirstChild("DashTop")
                        if DashTop then DashTop.CFrame = Dash.CFrame * CFrame.new(0, 4, -1) end
                        local Screen = cockpit:FindFirstChild("Screen")
                        if Screen then Screen.CFrame = Dash.CFrame * CFrame.new(-4, 4.2, -1) * CFrame.Angles(math.rad(-20), 0, 0) end
                        local Yoke = cockpit:FindFirstChild("Yoke")
                        if Yoke then
                            Yoke.CFrame = Dash.CFrame * CFrame.new(0, 2.5, -3) * CFrame.Angles(math.rad(15), 0, 0)
                            local YokeTop = cockpit:FindFirstChild("YokeTop")
                            if YokeTop then YokeTop.CFrame = Yoke.CFrame * CFrame.new(0, 2, 0) end
                        end
                        local btnFolder = cockpit:FindFirstChild("Buttons")
                        if btnFolder then
                            local i = 1
                            for _, btn in ipairs(btnFolder:GetChildren()) do
                                local row = math.floor((i-1)/10)
                                local col = (i-1)%10
                                btn.CFrame = DashTop.CFrame * CFrame.new((col-4.5)*0.8, 0.6, (row-4)*0.6)
                                i = i + 1
                            end
                        end
                    end
                    
                    local GL = cockpit:FindFirstChild("GL")
                    if GL then GL.CFrame = camera.CFrame * CFrame.new(-4.5, 0, -9) * CFrame.Angles(0, math.rad(10), 0) end
                    local GR = cockpit:FindFirstChild("GR")
                    if GR then GR.CFrame = camera.CFrame * CFrame.new(4.5, 0, -9) * CFrame.Angles(0, math.rad(-10), 0) end
                end
                
                if t < boardEnd then
                    local alpha = math.min(t / boardEnd, 1)
                    local smoothAlpha = alpha * alpha * (3 - 2 * alpha)
                    camera.CFrame = startCamCF:Lerp(targetCamCF, smoothAlpha)
                    camera.FieldOfView = 70 - smoothAlpha * 5
                    
                elseif t < taxiEnd then
                    camera.CFrame = targetCamCF * CFrame.Angles(math.sin(t*3)*0.005, math.sin(t*2)*0.005, 0)
                    camera.FieldOfView = 65 + math.sin(t*2) * 2
                    
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
                    
                else
                    cc.Saturation = -1
                    cc.Contrast = 1
                    blur.Size = 20
                    topBar.Size = UDim2.new(1, 0, 0, 0)
                    botBar.Size = UDim2.new(1, 0, 0, 0)
                    
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
                    end
                end
            end)
        end)
        
        if not s then
            warn("生成失败: ", err)
            loadingGui:Destroy()
            if hrp then hrp.Anchored = false end
            isPlaying = false
        end
    end)
end

CgSection:Button({Title="启动星际巡航", Callback=function()
    if not isPlaying then
        startCinematic()
    end
end})