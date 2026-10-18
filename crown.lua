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
title.Text = "封存娱乐 V5.2 平衡光影版"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
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
local sceneOrigin = Vector3.new(0, 50000, 0)

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end
local function vpart(props, parent)
    local p = new("Part", { Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = true, Material = Enum.Material.SmoothPlastic }, parent)
    for k, v in pairs(props) do p[k] = v end
    return p
end
local function buildCannonStyleShip(parent, cf)
    local SCALE = 20
    local model = new("Model", { Name = "CineShip" }, parent)
    model.WorldPivot = cf
    local HULL = Color3.fromRGB(50, 60, 70)
    local METAL = Color3.fromRGB(130, 140, 150)
    local RED = Color3.fromRGB(255, 50, 50)
    local function box(name, x, y, z, sx, sy, sz, col, mat, rz, ry, rx, tr)
        return vpart({ Name = name, Size = Vector3.new(sx*SCALE, sy*SCALE, sz*SCALE), Color = col, Material = mat or Enum.Material.Metal, Transparency = tr or 0, CFrame = cf * CFrame.new(x*SCALE, y*SCALE, z*SCALE) * CFrame.Angles(rx or 0, ry or 0, rz or 0) }, model)
    end
    box("Core", 0, 0, 0, 4, 3, 10, HULL, Enum.Material.Metal)
    for i = 0, 7 do
        local a = i * math.pi / 4
        box("Armor", math.cos(a)*2.2, math.sin(a)*2.2, 0, 1, 1.2, 8, METAL, Enum.Material.Metal, a)
    end
    box("Cockpit", 0, 2.2, -3, 2.5, 1.5, 4, Color3.fromRGB(0, 200, 255), Enum.Material.Glass)
    box("WingL", -4, 0, 2, 6, 0.3, 4, HULL, Enum.Material.Metal, math.rad(-15))
    box("WingR", 4, 0, 2, 6, 0.3, 4, HULL, Enum.Material.Metal, math.rad(15))
    box("Door", 0, -2, -2, 2, 2.5, 0.2, Color3.fromRGB(60, 70, 80), Enum.Material.Metal)
    box("Ladder", 0, -4, -2.5, 1.5, 5, 0.2, METAL, Enum.Material.Metal, math.rad(20))
    local thr = vpart({ Name = "Thruster", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.5*SCALE, 1.5*SCALE, 1.5*SCALE), CFrame = cf * CFrame.new(0,0,5.5*SCALE) * CFrame.Angles(0,math.rad(90),0), Color = RED, Material = Enum.Material.Neon }, model)
    new("PointLight", { Color = RED, Range = 30, Brightness = 2 }, thr)
    local light = new("PointLight", { Color = Color3.fromRGB(180, 200, 255), Range = 40, Brightness = 1.5 }, model:FindFirstChild("Cockpit"))
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
    Lighting.Ambient = Color3.fromRGB(50, 60, 80)
    Lighting.OutdoorAmbient = Color3.fromRGB(60, 70, 90)
    Lighting.ClockTime = 0
    
    local cc = new("ColorCorrectionEffect", { Contrast = 0.1, Saturation = -0.1, Brightness = 0, TintColor = Color3.fromRGB(200, 210, 255) }, Lighting)
    local blur = new("BlurEffect", { Size = 0 }, Lighting)
    
    local subGui = new("ScreenGui", { Name = "SubtitleUI", IgnoreGuiInset = true, DisplayOrder = 1000 }, player.PlayerGui)
    local subText = new("TextLabel", { Size = UDim2.new(1,0,0,50), Position = UDim2.new(0,0,0.8,0), BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 24, TextStrokeTransparency = 0, TextTransparency = 1, Text = "" }, subGui)
    
    local loadingGui = new("ScreenGui", { Name = "LoadingUI", IgnoreGuiInset = true, DisplayOrder = 1000 }, player.PlayerGui)
    local bg = new("Frame", { Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(10,10,12), BorderSizePixel = 0 }, loadingGui)
    local loadTxt = new("TextLabel", { Size = UDim2.fromScale(1,0.4), Position = UDim2.fromScale(0,0.2), BackgroundTransparency = 1, Text = "正在装载深空环境 0%", TextColor3 = Color3.fromRGB(0,200,255), Font = Enum.Font.GothamBold, TextSize = 28 }, loadingGui)
    local barBg = new("Frame", { Size = UDim2.fromOffset(300,10), Position = UDim2.fromScale(0.5,0.5), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Color3.fromRGB(30,30,35), BorderSizePixel = 0 }, loadingGui)
    new("UICorner", { CornerRadius = UDim.new(1,0) }, barBg)
    local barFill = new("Frame", { Size = UDim2.fromScale(0,1), BackgroundColor3 = Color3.fromRGB(0,200,255), BorderSizePixel = 0 }, barBg)
    new("UICorner", { CornerRadius = UDim.new(1,0) }, barFill)

    local sceneFolder = new("Folder", { Name = "CinematicScene" }, Workspace)
    
    local startCF = CFrame.new(sceneOrigin + Vector3.new(150, 100, 0))
    local landCF = CFrame.new(sceneOrigin + Vector3.new(0, 10, 0))
    
    local buildQueue = {}
    local shipModel
    
    table.insert(buildQueue, function()
        shipModel = buildCannonStyleShip(sceneFolder, startCF)
    end)
    
    table.insert(buildQueue, function()
        local earth = vpart({ Shape = Enum.PartType.Ball, Size = Vector3.new(2000, 2000, 2000), Position = sceneOrigin + Vector3.new(3000, 500, -4000), Color = Color3.fromRGB(20, 60, 150), Material = Enum.Material.SmoothPlastic }, sceneFolder)
        new("SpecialMesh", { MeshType = Enum.MeshType.Sphere, Scale = Vector3.new(1,1,1), TextureId = "rbxassetid://218579141" }, earth)
        vpart({ Shape = Enum.PartType.Ball, Size = Vector3.new(2050, 2050, 2050), Position = earth.Position, Color = Color3.fromRGB(50, 150, 255), Material = Enum.Material.ForceField, Transparency = 0.5 }, sceneFolder)
    end)

    table.insert(buildQueue, function()
        local stars = new("Folder", { Name = "Stars" }, sceneFolder)
        for i = 1, 150 do
            vpart({ Shape = Enum.PartType.Ball, Size = Vector3.new(15,15,15), Position = sceneOrigin + Vector3.new(math.random(-10000,10000), math.random(-10000,10000), math.random(-10000, 1000)), Color = Color3.new(1,1,1), Material = Enum.Material.Neon, Transparency = math.random(0.2, 0.8) }, stars)
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
            loadTxt.Text = "正在装载深空环境 " .. math.floor((completedTasks / totalTasks) * 100) .. "%"
        else
            isBuilding = false
            buildConn:Disconnect()
            
            loadTxt.Text = "模型就绪，正在渲染光影..."
            task.wait(3)
            loadingGui:Destroy()
            
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.lookAt(landCF.Position + Vector3.new(30, 20, 40), landCF.Position)
            
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
                local hrpTarget1 = landCF * CFrame.new(0, -4, -4)
                local hrpTarget2 = landCF * CFrame.new(0, 0, -2)
                
                TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = hrpTarget1}):Play()
                task.wait(2)
                TweenService:Create(hrp, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = hrpTarget2}):Play()
                task.wait(1.5)
                
                hrp.Transparency = 1
                for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.Transparency = 1 end end
                
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame}):Play()
                TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                task.wait(1)
                
                camera.CFrame = landCF * CFrame.new(0, 3, -6)
                subText.Text = "正在制造虫洞，请稍等..."; TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                
                local wormholePos = landCF.Position + landCF.LookVector * 100
                local wormholeFolder = new("Folder", { Name = "WormholeFX" }, Workspace)
                local voidPart = vpart({ Shape = Enum.PartType.Ball, Size = Vector3.new(1, 1, 1), Color = Color3.new(0,0,0), Material = Enum.Material.SmoothPlastic, CFrame = CFrame.new(wormholePos) * CFrame.Angles(0, math.rad(180), 0) }, wormholeFolder)
                local rings = {}
                for i=1, 12 do
                    local ring = vpart({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(1, 10, 10), Color = Color3.fromRGB(0,255,100), Material = Enum.Material.Neon, CFrame = CFrame.new(wormholePos) * CFrame.Angles(math.rad(math.random(-20,20)), math.rad(math.random(-20,20)), 0), Transparency = 0.5 }, wormholeFolder)
                    table.insert(rings, ring)
                end
                
                TweenService:Create(voidPart, TweenInfo.new(4, Enum.EasingStyle.Quad), {Size = Vector3.new(120, 120, 2)}):Play()
                for i, r in ipairs(rings) do
                    TweenService:Create(r, TweenInfo.new(4, Enum.EasingStyle.Quad), {Size = Vector3.new(1, 15 + i*8, 15 + i*8)}):Play()
                end
                
                local rotSpeed = 0
                local rotConn
                rotConn = RunService.RenderStepped:Connect(function(dt)
                    rotSpeed = rotSpeed + dt * 1.5
                    for i, r in ipairs(rings) do
                        r.CFrame = CFrame.new(wormholePos) * CFrame.Angles(0, rotSpeed * (i%2==0 and 1 or -1), 0)
                    end
                end)
                
                task.wait(4)
                TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                TweenService:Create(blur, TweenInfo.new(1), {Size = 20}):Play()
                
                for _, p in pairs(shipModel:GetChildren()) do
                    if p:IsA("BasePart") then
                        TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.Exponential), {CFrame = p.CFrame - landCF.Position + wormholePos}):Play()
                    end
                end
                task.wait(2)
                
                if rotConn then rotConn:Disconnect() end
                for _, p in pairs(shipModel:GetChildren()) do p.Transparency = 1 end
                wormholeFolder:Destroy()
                
                task.wait(0.5); blur.Size = 0
                local speedLines = new("Folder", { Name = "SpeedLines" }, Workspace)
                for i=1, 150 do
                    local line = vpart({ Size = Vector3.new(0.1,0.1,math.random(200,800)), Color = Color3.new(1,1,1), Material = Enum.Material.Neon, CFrame = CFrame.new(camera.CFrame.Position + Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-500,-100))) }, speedLines)
                    task.spawn(function()
                        while isPlaying do
                            line.CFrame = CFrame.lookAt(line.Position - camera.CFrame.LookVector * 100, camera.CFrame.LookVector) * CFrame.Angles(math.rad(-90),0,0)
                            task.wait(0.01)
                        end
                    end)
                end
                
                local startT = tick()
                while tick() - startT < 5 do
                    camera.CFrame = camera.CFrame * CFrame.new(0,0,-10)
                    camera.FieldOfView = 70 + math.random(-10,10)
                    task.wait(0.05)
                end
                
                speedLines:Destroy()
                task.wait(1)
                
                TweenService:Create(blur, TweenInfo.new(1), {Size = 20}):Play()
                task.wait(1)
                
                local earthObj = nil
                for _, p in pairs(sceneFolder:GetChildren()) do if p.Name == "Part" and p.Size.X == 2000 then earthObj = p break end end
                local landPos2 = sceneOrigin + Vector3.new(3000, 1500, -4000)
                if earthObj then landPos2 = earthObj.Position + Vector3.new(0, 1100, 0) end
                
                local platform = vpart({ Size = Vector3.new(100, 2, 100), Color = Color3.fromRGB(30,30,30), Material = Enum.Material.Metal, CFrame = CFrame.new(landPos2) }, sceneFolder)
                local shipLandCF2 = CFrame.new(landPos2 + Vector3.new(0, 5, 0)) * CFrame.Angles(0, math.rad(math.random(0,360)), 0)
                
                camera.CFrame = shipLandCF2 * CFrame.new(30, 30, 30) * CFrame.Angles(0, math.rad(45), 0)
                TweenService:Create(blur, TweenInfo.new(1), {Size = 0}):Play()
                
                for _, p in pairs(shipModel:GetChildren()) do
                    if p:IsA("BasePart") then
                        p.Transparency = 0
                        p.CFrame = shipLandCF2 * (p.CFrame - landCF.Position) + Vector3.new(0, 80, 0)
                        TweenService:Create(p, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = p.CFrame - Vector3.new(0, 80, 0)}):Play()
                    end
                end
                task.wait(4)
                
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