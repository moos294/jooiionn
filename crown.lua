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
for _,v in pairs(Workspace:GetChildren())do if v.Name=="CinematicScene" or v.Name=="WormholeFX" or v.Name=="CineShip" or v.Name=="SpeedLines" or v.Name=="DeepSpace" then v:Destroy()end end
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
title.Text = "封存娱乐 V4.4 终极修复"
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
startBtn.Text = "启动高精度星际巡航"
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
local baseOrigin = Vector3.new(0, 50000, 0)

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
    local ship = Instance.new("Model", Workspace); ship.Name = "CineShip"
    local dark = Color3.fromRGB(20, 25, 30); local metal = Enum.Material.Metal
    local base = makePart(ship, "Base", Vector3.new(10, 3, 24), dark, metal, CFrame.new(baseOrigin))
    
    for i=1, 3 do
        makePart(ship, "Nose"..i, Vector3.new(8 - i*1.5, 1, 4), dark, metal, base.CFrame * CFrame.new(0, 0, -12 - i*2) * CFrame.Angles(math.rad(-15),0,0))
    end
    
    makePart(ship, "Cockpit", Vector3.new(6, 2, 6), Color3.fromRGB(100,200,255), Enum.Material.Glass, base.CFrame * CFrame.new(0, 1.8, -7) * CFrame.Angles(math.rad(-10),0,0))
    
    for side=-1, 1, 2 do
        for i=1, 4 do
            makePart(ship, "Wing", Vector3.new(4, 0.2, 8), dark, metal, base.CFrame * CFrame.new(side * (6 + i*1.5), -0.5 - i*0.2, 4 + i*0.5) * CFrame.Angles(0, math.rad(side*20), math.rad(-side*10)))
        end
    end
    
    for i=1, 4 do
        local eL = makePart(ship, "EL"..i, Vector3.new(2.5, 2.5, 5), Color3.fromRGB(15,15,15), metal, base.CFrame * CFrame.new(-3 + (i-1)*2, -0.5, 12))
        local fL = makePart(ship, "FL"..i, Vector3.new(2, 2, 0.5), Color3.fromRGB(0,200,255), Enum.Material.Neon, eL.CFrame * CFrame.new(0,0,2.7))
        local l = Instance.new("PointLight", fL); l.Color = Color3.fromRGB(0,150,255); l.Range = 15; l.Brightness = 3
    end
    
    makePart(ship, "Door", Vector3.new(4, 5, 0.5), Color3.fromRGB(40,45,50), metal, base.CFrame * CFrame.new(0, -2, -2))
    makePart(ship, "Ladder", Vector3.new(1.5, 8, 0.5), Color3.fromRGB(150,150,150), metal, base.CFrame * CFrame.new(0, -5, -3) * CFrame.Angles(math.rad(30),0,0))
    
    makePart(ship, "LightL", Vector3.new(0.5,0.5,0.5), Color3.fromRGB(255,50,50), Enum.Material.Neon, base.CFrame * CFrame.new(-10,0,4))
    makePart(ship, "LightR", Vector3.new(0.5,0.5,0.5), Color3.fromRGB(50,255,50), Enum.Material.Neon, base.CFrame * CFrame.new(10,0,4))
    
    return ship
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
    
    local cc = Instance.new("ColorCorrectionEffect", Lighting); cc.Contrast=0.2; cc.Saturation=-0.1; cc.Brightness=-0.1
    local blur = Instance.new("BlurEffect", Lighting); blur.Size=0
    
    local subGui = Instance.new("ScreenGui", player.PlayerGui); subGui.Name = "SubtitleUI"; subGui.IgnoreGuiInset = true; subGui.DisplayOrder = 1000
    local subText = Instance.new("TextLabel", subGui); subText.Size=UDim2.new(1,0,0,50); subText.Position=UDim2.new(0,0,0.8,0); subText.BackgroundTransparency=1; subText.TextColor3=Color3.new(1,1,1); subText.Font=Enum.Font.GothamBold; subText.TextSize=24; subText.TextStrokeTransparency=0; subText.TextTransparency=1; subText.Text=""
    
    local loadingGui = Instance.new("ScreenGui", player.PlayerGui); loadingGui.Name="LoadingUI"; loadingGui.IgnoreGuiInset=true; loadingGui.DisplayOrder=1000
    local bg = Instance.new("Frame", loadingGui); bg.Size=UDim2.fromScale(1,1); bg.BackgroundColor3=Color3.fromRGB(10,10,12); bg.BorderSizePixel=0
    local loadTxt = Instance.new("TextLabel", loadingGui); loadTxt.Size=UDim2.fromScale(1,0.4); loadTxt.Position=UDim2.fromScale(0,0.2); loadTxt.BackgroundTransparency=1; loadTxt.Text="构建深空场景 0%"; loadTxt.TextColor3=Color3.fromRGB(0,200,255); loadTxt.Font=Enum.Font.GothamBold; loadTxt.TextSize=28
    local barBg = Instance.new("Frame", loadingGui); barBg.Size=UDim2.fromOffset(300,10); barBg.Position=UDim2.fromScale(0.5,0.5); barBg.AnchorPoint=Vector2.new(0.5,0.5); barBg.BackgroundColor3=Color3.fromRGB(30,30,35); barBg.BorderSizePixel=0; Instance.new("UICorner", barBg).CornerRadius=UDim.new(1,0)
    local barFill = Instance.new("Frame", barBg); barFill.Size=UDim2.fromScale(0,1); barFill.BackgroundColor3=Color3.fromRGB(0,200,255); barFill.BorderSizePixel=0; Instance.new("UICorner", barFill).CornerRadius=UDim.new(1,0)

    local sceneFolder = Instance.new("Folder", Workspace); sceneFolder.Name="CinematicScene"
    
    local shipStartCF = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 20 + hrp.CFrame.RightVector * -150 + Vector3.new(0, 80, 0)) * CFrame.Angles(0, hrp.Orientation.Y + math.rad(45), 0)
    local shipLandCF = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 20 + Vector3.new(0, 5, 0)) * CFrame.Angles(0, hrp.Orientation.Y, 0)
    
    local shipModel
    local buildQueue = {}
    table.insert(buildQueue, function() shipModel = buildShip() end)
    
    isBuilding = true
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
            loadTxt.Text = "构建深空场景 " .. math.floor((completedTasks / totalTasks) * 100) .. "%"
        else
            isBuilding = false
            buildConn:Disconnect()
            task.wait(0.5)
            loadingGui:Destroy()
            
            shipModel:PivotTo(shipStartCF)
            
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.lookAt(hrp.Position + hrp.CFrame.LookVector * 20 + Vector3.new(0, 20, 40), hrp.Position)
            
            task.spawn(function()
                task.wait(1)
                subText.Text = "飞船正在降落..."; TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                
                local base = shipModel:FindFirstChild("Base")
                local door = shipModel:FindFirstChild("Door")
                
                local tweenLand = TweenService:Create(base, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = shipLandCF})
                tweenLand:Play()
                TweenService:Create(camera, TweenInfo.new(6, Enum.EasingStyle.Quad), {CFrame = CFrame.lookAt(hrp.Position + hrp.CFrame.LookVector * 10 + Vector3.new(5, 10, 5), shipLandCF.Position)}):Play()
                tweenLand.Completed:Wait()
                
                task.wait(1)
                subText.Text = "舱门开启..."
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame * CFrame.new(0, 5, 0)}):Play()
                task.wait(1.5)
                
                subText.Text = "正在登机..."
                hrp.Anchored = false; if humanoid then humanoid.WalkSpeed = 16 end
                if humanoid then
                    humanoid:MoveTo((shipLandCF * CFrame.new(0, -2, -8)).Position); humanoid.MoveToFinished:Wait()
                    humanoid:MoveTo((shipLandCF * CFrame.new(0, 2, -2)).Position); humanoid.MoveToFinished:Wait()
                else hrp.CFrame = shipLandCF * CFrame.new(0, 2, -2) end
                
                hrp.Anchored = true; if humanoid then humanoid.WalkSpeed = 0 end
                TweenService:Create(hrp, TweenInfo.new(0.5), {Transparency = 1}):Play()
                for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then TweenService:Create(p, TweenInfo.new(0.5), {Transparency = 1}):Play() end end
                
                task.wait(1)
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame}):Play()
                TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                task.wait(1)
                
                camera.CFrame = shipLandCF * CFrame.new(0, 3, -6)
                subText.Text = "正在制造虫洞，请稍等..."; TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                
                local wormholePos = shipLandCF.Position + shipLandCF.LookVector * 100 + Vector3.new(0, 30, 0)
                local wormholeFolder = Instance.new("Folder", Workspace); wormholeFolder.Name = "WormholeFX"
                
                local voidPart = makePart(wormholeFolder, "Void", Vector3.new(1, 1, 1), Color3.new(0,0,0), Enum.Material.SmoothPlastic, CFrame.new(wormholePos) * CFrame.Angles(0, hrp.Orientation.Y, 0))
                
                local rings = {}
                for i=1, 12 do
                    local ring = makePart(wormholeFolder, "Ring", Vector3.new(1, 10, 10), Color3.fromRGB(0,255,100), Enum.Material.Neon, CFrame.new(wormholePos) * CFrame.Angles(0, hrp.Orientation.Y + math.rad(math.random(-20,20)), math.rad(math.random(-20,20))), Enum.PartType.Cylinder, 0.5)
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
                        r.CFrame = CFrame.new(wormholePos) * CFrame.Angles(0, hrp.Orientation.Y + rotSpeed * (i%2==0 and 1 or -1), 0)
                    end
                end)
                
                task.wait(4)
                TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                TweenService:Create(blur, TweenInfo.new(1), {Size = 20}):Play()
                
                local tweenFly = TweenService:Create(base, TweenInfo.new(2, Enum.EasingStyle.Exponential), {CFrame = CFrame.new(wormholePos)})
                tweenFly:Play(); tweenFly.Completed:Wait()
                
                if rotConn then rotConn:Disconnect() end
                for _, p in pairs(shipModel:GetChildren()) do p.Transparency = 1 end
                wormholeFolder:Destroy()
                
                task.wait(0.5); blur.Size = 0
                local speedLines = Instance.new("Folder", Workspace); speedLines.Name = "SpeedLines"
                for i=1, 200 do
                    local line = makePart(speedLines, "Line", Vector3.new(0.1,0.1,math.random(200,800)), Color3.new(1,1,1), Enum.Material.Neon, CFrame.new(camera.CFrame.Position + Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-500,-100))))
                    task.spawn(function()
                        while isPlaying do
                            line.CFrame = CFrame.lookAt(line.Position - camera.CFrame.LookVector * 100, camera.CFrame.LookVector) * CFrame.Angles(math.rad(-90),0,0)
                            task.wait(0.01)
                        end
                    end)
                end
                
                local startT = tick()
                while tick() - startT < 6 do
                    camera.CFrame = camera.CFrame * CFrame.new(0,0,-10)
                    camera.FieldOfView = 70 + math.random(-10,10)
                    task.wait(0.05)
                end
                
                speedLines:Destroy()
                task.wait(1)
                
                TweenService:Create(blur, TweenInfo.new(1), {Size = 20}):Play()
                task.wait(1)
                
                local deepSpace = Instance.new("Folder", Workspace); deepSpace.Name = "DeepSpace"
                local earthPos = camera.CFrame.Position + camera.CFrame.LookVector * 6000
                local earth = makePart(deepSpace, "Earth", Vector3.new(3000,3000,3000), Color3.fromRGB(20,60,150), Enum.Material.SmoothPlastic, CFrame.new(earthPos), Enum.PartType.Ball)
                local earthAtmo = makePart(deepSpace, "EarthAtmo", Vector3.new(3100,3100,3100), Color3.fromRGB(50,150,255), Enum.Material.ForceField, CFrame.new(earthPos), Enum.PartType.Ball, 0.5)
                
                local landPos = earthPos + Vector3.new(0, 1600, 0)
                local platform = makePart(deepSpace, "Platform", Vector3.new(100, 2, 100), Color3.fromRGB(30,30,30), Enum.Material.Metal, CFrame.new(landPos))
                
                for i=1, 100 do
                    makePart(deepSpace, "Star", Vector3.new(20,20,20), Color3.white, Enum.Material.Neon, CFrame.new(camera.CFrame.Position + Vector3.new(math.random(-10000,10000), math.random(-10000,10000), math.random(-10000,-1000))), Enum.PartType.Ball)
                end
                
                local shipLandCF2 = CFrame.new(landPos + Vector3.new(0, 5, 0)) * CFrame.Angles(0, math.rad(math.random(0,360)), 0)
                
                base.CFrame = shipLandCF2 * CFrame.new(0, 80, 0)
                for _, p in pairs(shipModel:GetChildren()) do p.Transparency = 0 end
                
                camera.CFrame = shipLandCF2 * CFrame.new(30, 30, 30) * CFrame.Angles(0, math.rad(45), 0)
                TweenService:Create(blur, TweenInfo.new(1), {Size = 0}):Play()
                
                TweenService:Create(base, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = shipLandCF2}):Play()
                task.wait(5)
                
                subText.Text = "已到达目标星球，舱门开启..."; TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame * CFrame.new(0, 5, 0)}):Play()
                task.wait(1.5)
                
                hrp.Anchored = false; if humanoid then humanoid.WalkSpeed = 16 end
                hrp.CFrame = shipLandCF2 * CFrame.new(0, 2, -2)
                TweenService:Create(hrp, TweenInfo.new(0.5), {Transparency = 0}):Play()
                for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then TweenService:Create(p, TweenInfo.new(0.5), {Transparency = 0}):Play() end end
                
                if humanoid then
                    humanoid:MoveTo((shipLandCF2 * CFrame.new(0, -2, -8)).Position); humanoid.MoveToFinished:Wait()
                    humanoid:MoveTo((shipLandCF2 * CFrame.new(0, -4, -15)).Position); humanoid.MoveToFinished:Wait()
                else hrp.CFrame = shipLandCF2 * CFrame.new(0, -4, -15) end
                
                hrp.Anchored = true; if humanoid then humanoid.WalkSpeed = 0 end
                task.wait(1)
                TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame}):Play()
                task.wait(1)
                
                TweenService:Create(base, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = shipLandCF2 * CFrame.new(0, 200, 0)}):Play()
                task.wait(3)
                
                shipModel:Destroy(); deepSpace:Destroy()
                camera.CameraType = origCamType; camera.FieldOfView = origFOV
                if hrp then hrp.Anchored = false end
                if humanoid then humanoid.WalkSpeed = 16 end
                cc:Destroy(); blur:Destroy(); subGui:Destroy()
                isPlaying = false; mainFrame.Visible = true
            end)
        end
    end)
end

startBtn.MouseButton1Click:Connect(startCinematic)