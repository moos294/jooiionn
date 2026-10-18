local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local StarterGui=game:GetService("StarterGui")
local Workspace=game:GetService("Workspace")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local camera=Workspace.CurrentCamera

for _,v in pairs(game:GetService("CoreGui"):GetChildren())do if v.Name=="PowerCrownUI" or v.Name=="CinematicUI" or v.Name=="LoadingUI" then v:Destroy()end end
for _,v in pairs(player.PlayerGui:GetChildren())do if v.Name=="PowerCrownUI" or v.Name=="CinematicUI" or v.Name=="LoadingUI" then v:Destroy()end end
for _,v in pairs(Workspace:GetChildren())do if v.Name=="CinematicScene" or v.Name=="WormholeFX" or v.Name=="CineShip" or v.Name=="SpeedLines" then v:Destroy()end end
for _,v in pairs(Lighting:GetChildren())do if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") then v:Destroy()end end

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
title.Text = "封存娱乐 V6.0"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
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
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
mainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
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
        minimizeBtn.Text = "+"; minimizeBtn.Size = UDim2.fromOffset(40, 40); minimizeBtn.Position = UDim2.new(0, 0, 0, 0)
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = UDim2.fromOffset(260, 120)}):Play()
        TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(startBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
        minimizeBtn.Text = "-"; minimizeBtn.Size = UDim2.fromOffset(30, 30); minimizeBtn.Position = UDim2.new(1, -35, 0, 5)
    end
end)

local isPlaying = false
local SPACE_ORIGIN = Vector3.new(0, 50000, 0)

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end
local function vpart(props, parent)
    local p = new("Part", { Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false, Material = Enum.Material.SmoothPlastic }, parent)
    for k, v in pairs(props) do p[k] = v end
    return p
end
local function buildHighPrecisionShip(parent, cf)
    local SCALE = 15
    local model = new("Model", { Name = "CineShip" }, parent)
    model.WorldPivot = cf
    local HULL = Color3.fromRGB(40, 45, 55)
    local METAL = Color3.fromRGB(120, 130, 140)
    local RED = Color3.fromRGB(255, 50, 50)
    local function box(name, x, y, z, sx, sy, sz, col, mat, rz, ry, rx)
        return vpart({ Name = name, Size = Vector3.new(sx*SCALE, sy*SCALE, sz*SCALE), Color = col, Material = mat, CFrame = cf * CFrame.new(x*SCALE, y*SCALE, z*SCALE) * CFrame.Angles(rx or 0, ry or 0, rz or 0) }, model)
    end
    box("Core", 0, 0, 0, 4, 3, 12, HULL, Enum.Material.Metal)
    for i = 0, 7 do
        local a = i * math.pi / 4
        box("Armor", math.cos(a)*2.2, math.sin(a)*2.2, 0, 1, 1.2, 10, METAL, Enum.Material.Metal, a)
    end
    box("Cockpit", 0, 2.2, -4, 2.5, 1.5, 4, Color3.fromRGB(0, 200, 255), Enum.Material.Glass)
    box("WingL", -5, 0, 2, 8, 0.3, 5, HULL, Enum.Material.Metal, math.rad(-15))
    box("WingR", 5, 0, 2, 8, 0.3, 5, HULL, Enum.Material.Metal, math.rad(15))
    box("Door", 0, -2, -3, 2, 2.5, 0.2, Color3.fromRGB(60, 70, 80), Enum.Material.Metal)
    box("Ladder", 0, -4, -3.5, 1.5, 5, 0.2, METAL, Enum.Material.Metal, math.rad(20))
    local thr = vpart({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.5*SCALE, 1.5*SCALE, 1.5*SCALE), CFrame = cf * CFrame.new(0,0,6.5*SCALE) * CFrame.Angles(0,math.rad(90),0), Color = RED, Material = Enum.Material.Neon }, model)
    new("PointLight", { Color = RED, Range = 40, Brightness = 3 }, thr)
    return model
end

local function startCinematic()
    if isPlaying then return end
    isPlaying = true
    mainFrame.Visible = false
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and humanoid then hrp.Anchored = true; humanoid.WalkSpeed = 0 end
    
    local origCamType = camera.CameraType
    local origFOV = camera.FieldOfView
    
    local oldBrightness = Lighting.Brightness
    local oldAmbient = Lighting.Ambient
    local oldOutdoor = Lighting.OutdoorAmbient
    Lighting.Brightness = 1.5
    Lighting.Ambient = Color3.fromRGB(60, 60, 70)
    Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 80)
    Lighting.ClockTime = 0
    
    local cc = new("ColorCorrectionEffect", { Contrast = 0.1, Saturation = -0.1, Brightness = 0, TintColor = Color3.fromRGB(200,220,255) }, Lighting)
    local blur = new("BlurEffect", { Size = 0 }, Lighting)
    
    local subGui = new("ScreenGui", { Name = "SubtitleUI", IgnoreGuiInset = true, DisplayOrder = 1000 }, player.PlayerGui)
    local subText = new("TextLabel", { Size = UDim2.new(1,0,0,50), Position = UDim2.new(0,0,0.8,0), BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 24, TextStrokeTransparency = 0, TextTransparency = 1, Text = "" }, subGui)
    
    local loadingGui = new("ScreenGui", { Name = "LoadingUI", IgnoreGuiInset = true, DisplayOrder = 1000 }, player.PlayerGui)
    new("Frame", { Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(10,10,12), BorderSizePixel = 0 }, loadingGui)
    local loadTxt = new("TextLabel", { Size = UDim2.fromScale(1,0.4), Position = UDim2.fromScale(0,0.2), BackgroundTransparency = 1, Text = "正在装载全星系环境 0%", TextColor3 = Color3.fromRGB(0,200,255), Font = Enum.Font.GothamBold, TextSize = 28 }, loadingGui)
    local barBg = new("Frame", { Size = UDim2.fromOffset(300,10), Position = UDim2.fromScale(0.5,0.5), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Color3.fromRGB(30,30,35), BorderSizePixel = 0 }, loadingGui)
    new("UICorner", { CornerRadius = UDim.new(1,0) }, barBg)
    local barFill = new("Frame", { Size = UDim2.fromScale(0,1), BackgroundColor3 = Color3.fromRGB(0,200,255), BorderSizePixel = 0 }, barBg)
    new("UICorner", { CornerRadius = UDim.new(1,0) }, barFill)

    local sceneFolder = new("Folder", { Name = "CinematicScene" }, Workspace)
    local startCF = CFrame.new(SPACE_ORIGIN + Vector3.new(200, 100, 0))
    local landCF = CFrame.new(SPACE_ORIGIN + Vector3.new(0, 15, 0))
    
    local buildQueue = {}
    local shipModel
    table.insert(buildQueue, function() shipModel = buildHighPrecisionShip(sceneFolder, startCF) end)
    
    local planets = {}
    local pDefs = {
        {name="Sun", pos=SPACE_ORIGIN+Vector3.new(0,0,-5000), size=800, col=Color3.fromRGB(255,200,100)},
        {name="Mercury", pos=SPACE_ORIGIN+Vector3.new(1000,200,-10000), size=100, col=Color3.fromRGB(120,120,120)},
        {name="Venus", pos=SPACE_ORIGIN+Vector3.new(-1500,-300,-15000), size=200, col=Color3.fromRGB(220,180,120)},
        {name="Earth", pos=SPACE_ORIGIN+Vector3.new(2000,500,-20000), size=250, col=Color3.fromRGB(20,60,150)},
        {name="Mars", pos=SPACE_ORIGIN+Vector3.new(-2500,-800,-25000), size=150, col=Color3.fromRGB(150,50,40)},
        {name="Jupiter", pos=SPACE_ORIGIN+Vector3.new(3000,1000,-30000), size=500, col=Color3.fromRGB(200,170,140)},
        {name="Saturn", pos=SPACE_ORIGIN+Vector3.new(-3500,-1200,-35000), size=400, col=Color3.fromRGB(220,200,160)},
        {name="Uranus", pos=SPACE_ORIGIN+Vector3.new(4000,1500,-40000), size=300, col=Color3.fromRGB(100,200,220)},
        {name="Neptune", pos=SPACE_ORIGIN+Vector3.new(-4500,-1800,-45000), size=280, col=Color3.fromRGB(50,100,230)}
    }
    
    for _, def in ipairs(pDefs) do
        table.insert(buildQueue, function()
            local p = vpart({ Name = def.name, Shape = Enum.PartType.Ball, Size = Vector3.new(def.size, def.size, def.size), Position = def.pos, Color = def.col, Material = def.name=="Sun" and Enum.Material.Neon or Enum.Material.SmoothPlastic }, sceneFolder)
            planets[def.name] = p
            if def.name == "Saturn" then
                for i=1, 2 do
                    vpart({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(def.size*(2+i*0.2), 10, def.size*(2+i*0.2)), CFrame = CFrame.new(def.pos) * CFrame.Angles(math.rad(20),0,math.rad(10)) * CFrame.Angles(0,0,math.rad(90)), Color = Color3.fromRGB(180,160,130), Material = Enum.Material.Slate }, sceneFolder)
                end
            end
        end)
    end

    table.insert(buildQueue, function()
        local stars = new("Folder", { Name = "Stars" }, sceneFolder)
        for i=1, 100 do
            vpart({ Shape = Enum.PartType.Ball, Size = Vector3.new(15,15,15), Position = SPACE_ORIGIN + Vector3.new(math.random(-10000,10000), math.random(-10000,10000), math.random(-50000, 0)), Color = Color3.new(1,1,1), Material = Enum.Material.Neon, Transparency = math.random(0.2, 0.8) }, stars)
        end
    end)

    local isBuilding = true
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
            loadTxt.Text = "正在装载全星系环境 " .. math.floor((completedTasks / totalTasks) * 100) .. "%"
        else
            isBuilding = false
            buildConn:Disconnect()
            loadTxt.Text = "模型就绪，正在渲染光影..."
            task.wait(3)
            loadingGui:Destroy()
            
            camera.CameraType = Enum.CameraType.Scriptable
            camera.FieldOfView = 90
            camera.CFrame = CFrame.lookAt(landCF.Position + Vector3.new(60, 30, 60), landCF.Position)
            
            task.spawn(function()
                task.wait(1)
                subText.Text = "飞船正在降落..."; TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                
                for _, p in pairs(shipModel:GetChildren()) do
                    if p:IsA("BasePart") then
                        TweenService:Create(p, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = p.CFrame - startCF.Position + landCF.Position}):Play()
                    end
                end
                task.wait(5)
                
                subText.Text = "舱门开启..."
                local door = shipModel:FindFirstChild("Door")
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame * CFrame.new(0, 4, 0)}):Play()
                task.wait(1.5)
                
                subText.Text = "正在登机..."
                TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = landCF * CFrame.new(0, -4, -4)}):Play()
                task.wait(2)
                TweenService:Create(hrp, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = landCF * CFrame.new(0, 0, -2)}):Play()
                task.wait(1.5)
                
                hrp.Transparency = 1
                for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.Transparency = 1 end end
                
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame}):Play()
                TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                task.wait(1)
                
                camera.CFrame = landCF * CFrame.new(0, 5, -15)
                subText.Text = "正在制造虫洞，请稍等..."; TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                
                local wormholePos = landCF.Position + landCF.LookVector * 150
                local wormholeFolder = new("Folder", { Name = "WormholeFX" }, Workspace)
                
                local voidSphere = vpart({ Shape = Enum.PartType.Ball, Size = Vector3.new(1,1,1), Color = Color3.new(0,0,0), Material = Enum.Material.SmoothPlastic, CFrame = CFrame.new(wormholePos) }, wormholeFolder)
                local blueRings = {}
                for i=1, 10 do
                    local ring = vpart({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1, 5, 5), Color = Color3.fromRGB(50, 150, 255), Material = Enum.Material.Neon, CFrame = CFrame.new(wormholePos) * CFrame.Angles(math.rad(90), 0, 0), Transparency = 0.3 }, wormholeFolder)
                    table.insert(blueRings, ring)
                end
                
                TweenService:Create(voidSphere, TweenInfo.new(4, Enum.EasingStyle.Quad), {Size = Vector3.new(80, 80, 80)}):Play()
                for i, r in ipairs(blueRings) do
                    TweenService:Create(r, TweenInfo.new(4, Enum.EasingStyle.Quad), {Size = Vector3.new(1, 10 + i*10, 10 + i*10)}):Play()
                end
                
                task.wait(4)
                TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                TweenService:Create(blur, TweenInfo.new(1), {Size = 20}):Play()
                
                for _, p in pairs(shipModel:GetChildren()) do
                    if p:IsA("BasePart") then
                        TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.Exponential), {CFrame = p.CFrame - landCF.Position + wormholePos}):Play()
                    end
                end
                task.wait(2)
                
                for _, p in pairs(shipModel:GetChildren()) do p.Transparency = 1 end
                wormholeFolder:Destroy()
                
                task.wait(0.5); blur.Size = 0
                
                local tunnelGui = new("ScreenGui", { IgnoreGuiInset = true, DisplayOrder = 999 }, player.PlayerGui)
                local tunnelBg = new("Frame", { Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(5, 10, 20) }, tunnelGui)
                local hexGrid = new("ImageLabel", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Image = "rbxassetid://8305647025", ImageTransparency = 0.5 }, tunnelBg)
                local tunnelCenter = new("Frame", { AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.fromOffset(50, 50), BackgroundColor3 = Color3.new(0,0,0) }, tunnelBg)
                new("UICorner", { CornerRadius = UDim.new(1,0) }, tunnelCenter)
                
                local lines = {}
                for i=1, 100 do
                    local line = new("Frame", { AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.fromOffset(2, math.random(50, 200)), BackgroundColor3 = i%3==0 and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(100, 200, 255), Rotation = math.random(0,360) }, tunnelBg)
                    table.insert(lines, line)
                end
                
                local travelConn
                travelConn = RunService.RenderStepped:Connect(function(dt)
                    if not isPlaying then return end
                    for i, line in ipairs(lines) do
                        line.Position = line.Position + UDim2.fromOffset(0, 10)
                        if line.Position.Y.Scale > 1 then
                            line.Position = UDim2.fromScale(0.5, 0)
                            line.Rotation = math.random(0,360)
                        end
                    end
                    local size = tunnelCenter.AbsoluteSize.X + dt * 500
                    tunnelCenter.Size = UDim2.fromOffset(size, size)
                end)
                
                task.wait(4)
                if travelConn then travelConn:Disconnect() end
                tunnelGui:Destroy()
                
                task.wait(0.5)
                TweenService:Create(blur, TweenInfo.new(1), {Size = 20}):Play()
                task.wait(1)
                
                local planetsOrder = {"Sun", "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"}
                for _, pName in ipairs(planetsOrder) do
                    local targetP = planets[pName]
                    local lookAt = CFrame.lookAt(targetP.Position + Vector3.new(0, 100, 500), targetP.Position)
                    TweenService:Create(camera, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = lookAt}):Play()
                    task.wait(1.5)
                end
                
                local earthObj = planets["Earth"]
                local landPos2 = earthObj.Position + Vector3.new(0, earthObj.Size.Y/2 + 20, 0)
                local platform = vpart({ Size = Vector3.new(400, 2, 400), Color = Color3.fromRGB(40, 80, 40), Material = Enum.Material.Grass, CFrame = CFrame.new(landPos2) }, sceneFolder)
                local shipLandCF2 = CFrame.new(landPos2 + Vector3.new(0, 5, 0)) * CFrame.Angles(0, math.rad(math.random(0,360)), 0)
                
                camera.CFrame = shipLandCF2 * CFrame.new(50, 20, 50) * CFrame.Angles(0, math.rad(45), 0)
                TweenService:Create(blur, TweenInfo.new(1), {Size = 0}):Play()
                
                for _, p in pairs(shipModel:GetChildren()) do
                    if p:IsA("BasePart") then
                        p.Transparency = 0
                        p.CFrame = shipLandCF2 * (p.CFrame - wormholePos) + Vector3.new(0, 80, 0)
                        TweenService:Create(p, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = p.CFrame - Vector3.new(0, 80, 0)}):Play()
                    end
                end
                task.wait(3)
                
                subText.Text = "已到达目标星球，舱门开启..."; TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame * CFrame.new(0, 4, 0)}):Play()
                task.wait(1.5)
                
                hrp.CFrame = shipLandCF2 * CFrame.new(0, 2, -2)
                TweenService:Create(hrp, TweenInfo.new(0.5), {Transparency = 0}):Play()
                for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then TweenService:Create(p, TweenInfo.new(0.5), {Transparency = 0}):Play() end end
                
                TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = shipLandCF2 * CFrame.new(0, -2, -8)}):Play()
                task.wait(2)
                TweenService:Create(hrp, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = shipLandCF2 * CFrame.new(0, -4, -15)}):Play()
                task.wait(1.5)
                
                TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame}):Play()
                task.wait(1)
                
                for _, p in pairs(shipModel:GetChildren()) do
                    if p:IsA("BasePart") then
                        TweenService:Create(p, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = p.CFrame + Vector3.new(0, 200, 0)}):Play()
                    end
                end
                task.wait(3)
                
                shipModel:Destroy(); sceneFolder:Destroy()
                camera.CameraType = origCamType; camera.FieldOfView = origFOV
                if hrp then hrp.Anchored = false end
                if humanoid then humanoid.WalkSpeed = 16 end
                Lighting.Brightness = oldBrightness
                Lighting.Ambient = oldAmbient
                Lighting.OutdoorAmbient = oldOutdoor
                cc:Destroy(); blur:Destroy(); subGui:Destroy()
                isPlaying = false; mainFrame.Visible = true
            end)
        end
    end)
end

startBtn.MouseButton1Click:Connect(startCinematic)