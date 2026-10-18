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
for _,v in pairs(Workspace:GetChildren())do if v.Name=="CinematicScene" or v.Name=="PrecisionCockpit" or v.Name=="WormholeFX" or v.Name=="CineShip" then v:Destroy()end end
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
title.Text = "封存娱乐 V5.0 导演剪辑版"
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
local baseOrigin = Vector3.new(0, 5000, 0)

local function makePart(parent,name,size,color,mat,cf,shape,trans)
    local p=Instance.new("Part")
    p.Name=name; p.Size=size; p.Color=color; p.Material=mat or Enum.Material.SmoothPlastic
    p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.CastShadow=true; p.Transparency=trans or 0
    if shape then p.Shape=shape end
    if cf then p.CFrame=cf end
    p.Parent=parent
    return p
end

local function buildShip()
    local ship = Instance.new("Model", Workspace)
    ship.Name = "CineShip"
    local base = makePart(ship, "Base", Vector3.new(12, 3, 20), Color3.fromRGB(30, 35, 40), Enum.Material.Metal, CFrame.new(baseOrigin + Vector3.new(0, 2, 0)))
    local nose = makePart(ship, "Nose", Vector3.new(8, 2, 8), Color3.fromRGB(20, 25, 30), Enum.Material.Metal, base.CFrame * CFrame.new(0, 0.5, -12) * CFrame.Angles(math.rad(-15), 0, 0))
    local glass = makePart(ship, "Glass", Vector3.new(6, 2, 4), Color3.fromRGB(100, 200, 255), Enum.Material.Glass, base.CFrame * CFrame.new(0, 2, -6))
    local lWing = makePart(ship, "LWing", Vector3.new(10, 0.5, 6), Color3.fromRGB(25, 30, 35), Enum.Material.Metal, base.CFrame * CFrame.new(-8, 0, 5) * CFrame.Angles(0, math.rad(15), math.rad(-5)))
    local rWing = makePart(ship, "RWing", Vector3.new(10, 0.5, 6), Color3.fromRGB(25, 30, 35), Enum.Material.Metal, base.CFrame * CFrame.new(8, 0, 5) * CFrame.Angles(0, math.rad(-15), math.rad(5)))
    local engine = makePart(ship, "Engine", Vector3.new(4, 2, 4), Color3.fromRGB(0, 150, 255), Enum.Material.Neon, base.CFrame * CFrame.new(0, 0, 10))
    local door = makePart(ship, "Door", Vector3.new(3, 4, 0.5), Color3.fromRGB(40, 45, 50), Enum.Material.Metal, base.CFrame * CFrame.new(0, -1, -2))
    local ladder = makePart(ship, "Ladder", Vector3.new(1, 6, 1), Color3.fromRGB(100, 100, 100), Enum.Material.Metal, base.CFrame * CFrame.new(0, -4, -2) * CFrame.Angles(math.rad(30), 0, 0))
    local glow = Instance.new("PointLight", engine)
    glow.Color = Color3.fromRGB(0, 150, 255)
    glow.Range = 15
    glow.Brightness = 2
    return ship, door
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
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting)
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Size = 0
    
    local subGui = Instance.new("ScreenGui", player.PlayerGui)
    subGui.Name = "SubtitleUI"; subGui.IgnoreGuiInset = true; subGui.DisplayOrder = 1000
    local subText = Instance.new("TextLabel", subGui)
    subText.Size = UDim2.new(1, 0, 0, 50)
    subText.Position = UDim2.new(0, 0, 0.8, 0)
    subText.BackgroundTransparency = 1
    subText.TextColor3 = Color3.new(1, 1, 1)
    subText.Font = Enum.Font.GothamBold
    subText.TextSize = 24
    subText.TextStrokeTransparency = 0
    subText.TextTransparency = 1
    subText.Text = ""
    
    local topBar = Instance.new("Frame", subGui)
    topBar.Size = UDim2.new(1, 0, 0, 0); topBar.BackgroundColor3 = Color3.new(0,0,0); topBar.ZIndex = 10
    local botBar = Instance.new("Frame", subGui)
    botBar.Size = UDim2.new(1, 0, 0, 0); botBar.Position = UDim2.new(0, 0, 1, 0); botBar.BackgroundColor3 = Color3.new(0,0,0); botBar.ZIndex = 10
    
    local shipModel, door = buildShip()
    local shipBase = shipModel:FindFirstChild("Base")
    
    local shipStartCF = shipBase.CFrame * CFrame.new(0, 50, 0)
    shipModel:PivotTo(shipStartCF)
    
    camera.CameraType = Enum.CameraType.Scriptable
    local camStart = hrp.CFrame * CFrame.new(10, 10, 20) * CFrame.Angles(0, math.rad(20), 0)
    local camLook = CFrame.lookAt(camStart.Position, shipBase.Position)
    camera.CFrame = camLook
    
    task.spawn(function()
        task.wait(1)
        subText.Text = "飞船正在降落..."
        TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        
        local shipLandCF = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 15 + Vector3.new(0, 5, 0)) * CFrame.Angles(0, hrp.Orientation.Y, 0)
        
        local tweenShipLand = TweenService:Create(shipBase, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = shipLandCF})
        tweenShipLand:Play()
        
        local tweenCam = TweenService:Create(camera, TweenInfo.new(4, Enum.EasingStyle.Quad), {CFrame = CFrame.lookAt(hrp.Position + hrp.CFrame.LookVector * 5 + Vector3.new(5, 5, 5), shipLandCF.Position)})
        tweenCam:Play()
        tweenShipLand.Completed:Wait()
        
        task.wait(1)
        subText.Text = "舱门开启..."
        
        local doorOpen = door.CFrame * CFrame.new(0, 4, 0)
        TweenService:Create(door, TweenInfo.new(1), {CFrame = doorOpen}):Play()
        task.wait(1.5)
        
        subText.Text = "正在登机..."
        
        local walkTarget1 = shipLandCF * CFrame.new(0, 2, -8)
        local walkTarget2 = shipLandCF * CFrame.new(0, 2, -2)
        local tweenWalk = TweenService:Create(hrp, TweenInfo.new(3, Enum.EasingStyle.Linear), {CFrame = walkTarget2})
        
        if humanoid then
            humanoid:MoveTo(walkTarget1.Position)
            humanoid.MoveToFinished:Wait()
            hrp.CFrame = walkTarget2
        else
            tweenWalk:Play()
            tweenWalk.Completed:Wait()
        end
        
        TweenService:Create(hrp, TweenInfo.new(0.5), {Transparency = 1}):Play()
        for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then TweenService:Create(p, TweenInfo.new(0.5), {Transparency = 1}):Play() end end
        
        task.wait(1)
        TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame}):Play()
        TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        
        task.wait(1)
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = shipLandCF * CFrame.new(0, 3, -3)
        
        task.wait(1)
        subText.Text = "正在制造虫洞，请稍等..."
        TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        
        local wormholePos = shipLandCF.Position + shipLandCF.LookVector * 50 + Vector3.new(0, 10, 0)
        local wormholeFolder = Instance.new("Folder", Workspace)
        wormholeFolder.Name = "WormholeFX"
        
        local rings = {}
        for i=1, 30 do
            local ring = makePart(wormholeFolder, "Ring", Vector3.new(2, 10, 10), Color3.fromRGB(0, 150, 50), Enum.Material.Neon, CFrame.new(wormholePos) * CFrame.Angles(0,0,math.rad(90)))
            table.insert(rings, ring)
        end
        
        for i, r in ipairs(rings) do
            task.wait(0.1)
            TweenService:Create(r, TweenInfo.new(3, Enum.EasingStyle.Exponential), {Size = Vector3.new(2, 15 + i*2, 15 + i*2)}):Play()
            TweenService:Create(r, TweenInfo.new(3), {CFrame = CFrame.new(wormholePos) * CFrame.Angles(math.rad(math.random(-20, 20)), math.rad(math.random(-20, 20)), math.rad(90))}):Play()
        end
        
        local centerBlack = makePart(wormholeFolder, "Center", Vector3.new(2, 15, 15), Color3.new(0,0,0), Enum.Material.SmoothPlastic, CFrame.new(wormholePos) * CFrame.Angles(0,0,math.rad(90)))
        TweenService:Create(centerBlack, TweenInfo.new(3), {Size = Vector3.new(2, 80, 80)}):Play()
        
        task.wait(4)
        TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(blur, TweenInfo.new(1), {Size = 20}):Play()
        
        local tweenShipFly = TweenService:Create(shipBase, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {CFrame = CFrame.new(wormholePos)})
        tweenShipFly:Play()
        tweenShipFly.Completed:Wait()
        
        for _, p in pairs(Workspace:GetDescendants()) do
            if p.Name == "CineShip" or p.Name == "Base" then p.Transparency = 1 end
        end
        for _, p in pairs(shipModel:GetChildren()) do p.Transparency = 1 end
        wormholeFolder:Destroy()
        
        task.wait(0.5)
        blur.Size = 0
        
        local speedLines = Instance.new("Folder", Workspace)
        speedLines.Name = "SpeedLines"
        for i=1, 200 do
            local line = makePart(speedLines, "Line", Vector3.new(0.1, 0.1, math.random(100, 500)), Color3.new(1,1,1), Enum.Material.Neon, CFrame.new(camera.CFrame.Position + Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-500,-100))))
            line.Anchored = true
            task.spawn(function()
                while isPlaying do
                    local pos = line.Position - camera.CFrame.LookVector * 50
                    line.CFrame = CFrame.lookAt(pos, pos + camera.CFrame.LookVector) * CFrame.Angles(math.rad(-90), 0, 0)
                    task.wait(0.01)
                end
            end)
        end
        
        local travelTime = 5
        local startTravel = tick()
        while tick() - startTravel < travelTime do
            camera.CFrame = camera.CFrame * CFrame.new(0, 0, -5)
            camera.FieldOfView = 70 + math.random(-5, 5)
            task.wait(0.05)
        end
        
        speedLines:Destroy()
        
        local earthPos = camera.CFrame.Position + camera.CFrame.LookVector * 5000
        local earth = makePart(Workspace, "Earth", Vector3.new(2000,2000,2000), Color3.fromRGB(20, 60, 150), Enum.Material.SmoothPlastic, CFrame.new(earthPos), Enum.PartType.Ball)
        local earthAtmo = makePart(Workspace, "EarthAtmo", Vector3.new(2050,2050,2050), Color3.fromRGB(50, 150, 255), Enum.Material.ForceField, CFrame.new(earthPos), Enum.PartType.Ball, 0.5)
        
        local landPos = earthPos + Vector3.new(0, 1100, 0)
        
        task.wait(1)
        TweenService:Create(blur, TweenInfo.new(1), {Size = 20}):Play()
        task.wait(1)
        
        local shipLandCF2 = CFrame.new(landPos) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
        shipBase.CFrame = shipLandCF2 * CFrame.new(0, 50, 0)
        for _, p in pairs(shipModel:GetChildren()) do p.Transparency = 0 end
        
        camera.CFrame = shipLandCF2 * CFrame.new(15, 15, 15) * CFrame.Angles(0, math.rad(45), 0)
        TweenService:Create(blur, TweenInfo.new(1), {Size = 0}):Play()
        
        TweenService:Create(shipBase, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = shipLandCF2}):Play()
        task.wait(3)
        
        subText.Text = "已到达目标星球，舱门开启..."
        TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        
        TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame * CFrame.new(0, 4, 0)}):Play()
        task.wait(1.5)
        
        hrp.CFrame = shipLandCF2 * CFrame.new(0, 2, -2)
        TweenService:Create(hrp, TweenInfo.new(0.5), {Transparency = 0}):Play()
        for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then TweenService:Create(p, TweenInfo.new(0.5), {Transparency = 0}):Play() end end
        
        local walkOff1 = shipLandCF2 * CFrame.new(0, -2, -6)
        local walkOff2 = shipLandCF2 * CFrame.new(0, -4, -12)
        
        if humanoid then
            humanoid:MoveTo(walkOff1.Position)
            humanoid.MoveToFinished:Wait()
            humanoid:MoveTo(walkOff2.Position)
            humanoid.MoveToFinished:Wait()
        end
        
        task.wait(1)
        TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame}):Play()
        task.wait(1)
        
        TweenService:Create(shipBase, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = shipLandCF2 * CFrame.new(0, 200, 0)}):Play()
        task.wait(3)
        
        shipModel:Destroy()
        earth:Destroy()
        earthAtmo:Destroy()
        
        camera.CameraType = origCamType
        camera.FieldOfView = origFOV
        if hrp then hrp.Anchored = false end
        if humanoid then humanoid.WalkSpeed = 16 end
        cc:Destroy()
        blur:Destroy()
        subGui:Destroy()
        isPlaying = false
        mainFrame.Visible = true
    end)
end

startBtn.MouseButton1Click:Connect(startCinematic)