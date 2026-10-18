local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local StarterGui=game:GetService("StarterGui")
local Workspace=game:GetService("Workspace")
local UserInputService=game:GetService("UserInputService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local camera=Workspace.CurrentCamera

for _,v in pairs(game:GetService("CoreGui"):GetChildren())do if v.Name=="PowerCrownUI" or v.Name=="CinematicUI" or v.Name=="LoadingUI" then v:Destroy()end end
for _,v in pairs(player.PlayerGui:GetChildren())do if v.Name=="PowerCrownUI" or v.Name=="CinematicUI" or v.Name=="LoadingUI" then v:Destroy()end end
for _,v in pairs(Workspace:GetChildren())do if v.Name=="CinematicScene" or v.Name=="WormholeFX" or v.Name=="CineShip" or v.Name=="SpeedLines" or v.Name=="SpaceStage" then v:Destroy()end end
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
title.Text = "封存娱乐 V5.0"
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
    local p = new("Part", { Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false, Material = Enum.Material.SmoothPlastic, TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth }, parent)
    for k, v in pairs(props) do p[k] = v end
    return p
end
local function bigSphere(parent, pos, diameter, color, material, transparency)
    local p
    if diameter <= 2048 then
        p = vpart({ Shape = Enum.PartType.Ball, Size = Vector3.one * diameter, Position = pos, Color = color, Material = material, Transparency = transparency }, parent)
    else
        p = vpart({ Size = Vector3.one * 2048, Position = pos, Color = color, Material = material, Transparency = transparency }, parent)
        new("SpecialMesh", { MeshType = Enum.MeshType.Sphere, Scale = Vector3.one * (diameter / 2048) }, p)
    end
    return p
end
local function texturedSphere(parent, pos, diameter, textureId, color, material, transparency, name)
    if not textureId then return nil end
    local baseDiameter = math.min(diameter, 2048)
    local p = vpart({ Name = name or "TexturedCelestialBody", Size = Vector3.one * baseDiameter, Position = pos, Color = color or Color3.new(1, 1, 1), Material = material or Enum.Material.SmoothPlastic, Transparency = transparency or 0 }, parent)
    local ok = pcall(function() new("SpecialMesh", { MeshType = Enum.MeshType.Sphere, Scale = Vector3.one * (diameter / baseDiameter), TextureId = textureId }, p) end)
    if not ok then p:Destroy() return nil end
    return p
end
local function randDir() local z = math.random() * 2 - 1 local a = math.random() * math.pi * 2 local r = math.sqrt(1 - z * z) return Vector3.new(r * math.cos(a), z, r * math.sin(a)) end
local function plateOnSphere(folder, EC, n, r, w, color, material, transparency, thick) local p = EC + n * r return vpart({ Size = Vector3.new(w, w, thick or 2), CFrame = CFrame.lookAt(p, p + n), Color = color, Material = material or Enum.Material.SmoothPlastic, Transparency = transparency or 0 }, folder) end

local TEXTURES = {
    earth = "rbxassetid://218579141", moon = "rbxassetid://159128304", mercury = "rbxassetid://6218473454", venus = "rbxassetid://6218473772",
    sun = "rbxassetid://6218473826", mars = "rbxassetid://6218473454", jupiter = "rbxassetid://6218473826", saturn = "rbxassetid://6218473826",
    uranus = "rbxassetid://6218473866", neptune = "rbxassetid://6218473866"
}

local buildQueue = {}
local isBuilding = false

local function buildCannonStyleShip(folder, cf)
    local SCALE = 20
    local C = { coils = {} }
    local model = new("Model", { Name = "CineShip" }, folder)
    model.WorldPivot = cf
    local root = model
    local HULL = Color3.fromRGB(28, 31, 39)
    local METAL = Color3.fromRGB(129, 136, 148)
    local DARK = Color3.fromRGB(14, 17, 23)
    local GOLD = Color3.fromRGB(191, 148, 62)
    local RED = Color3.fromRGB(235, 28, 42)
    local function L(x, y, z) return Vector3.new(x * SCALE, y * SCALE, z * SCALE) end
    local function box(name, x, y, z, sx, sy, sz, col, mat, rz, ry, rx, transparency)
        return vpart({ Name = name, Size = L(sx, sy, sz), Color = col, Material = mat or Enum.Material.Metal, Transparency = transparency or 0, CFrame = cf * CFrame.new(L(x, y, z)) * CFrame.Angles(rx or 0, ry or 0, rz or 0) }, root)
    end
    local function axialCylinder(name, z, radius, length, col, mat, transparency)
        return vpart({ Name = name, Shape = Enum.PartType.Cylinder, Size = Vector3.new(length * SCALE, radius * 2 * SCALE, radius * 2 * SCALE), Color = col, Material = mat or Enum.Material.Metal, Transparency = transparency or 0, CFrame = cf * CFrame.new(0, 0, z * SCALE) * CFrame.Angles(0, math.rad(90), 0) }, root)
    end
    local function octRing(name, z, outer, inner, thickness, col, mat)
        local parts = {}
        for i = 0, 7 do
            local a = i * math.pi / 4
            local mid = (outer + inner) * 0.5
            local tangential = 2 * outer * math.tan(math.pi / 8) * 1.04
            parts[#parts + 1] = box(name, math.cos(a) * mid, math.sin(a) * mid, z, outer - inner, tangential, thickness, col, mat, a)
        end
        return parts
    end
    axialCylinder("EngineCore", 2, 1.2, 6, HULL, Enum.Material.Metal)
    for i = 0, 7 do
        local a = i * math.pi / 4
        box("ArmorFacet", math.cos(a) * 1.4, math.sin(a) * 1.4, 1, 0.6, 1.2, 6, HULL, Enum.Material.Metal, a)
    end
    for k = 0, 6 do
        local z = -2 + k * 1.2
        local main = octRing("Coil", z, 1.8, 1.2, 0.2, METAL, Enum.Material.Metal)
        C.coils[#C.coils + 1] = main
    end
    box("Cockpit", 0, 1.8, -2.5, 1.6, 1, 2.4, Color3.fromRGB(100, 200, 255), Enum.Material.Glass)
    box("WingL", -3, 0, 1, 5, 0.2, 3, DARK, Enum.Material.Metal, math.rad(-10))
    box("WingR", 3, 0, 1, 5, 0.2, 3, DARK, Enum.Material.Metal, math.rad(10))
    box("Door", 0, -1.5, -1, 1.5, 2, 0.2, Color3.fromRGB(40, 45, 50), Enum.Material.Metal)
    box("Ladder", 0, -3, -1.5, 1, 4, 0.2, Color3.fromRGB(150, 150, 150), Enum.Material.Metal, math.rad(30))
    local thruster = axialCylinder("Thruster", 4.5, 0.8, 0.5, RED, Enum.Material.Neon)
    local light = new("PointLight", { Color = RED, Range = 30, Brightness = 5 }, thruster)
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
    local cc = new("ColorCorrectionEffect", { Contrast = 0.2, Saturation = -0.1, Brightness = -0.1 }, Lighting)
    local blur = new("BlurEffect", { Size = 0 }, Lighting)
    
    local subGui = new("ScreenGui", { Name = "SubtitleUI", IgnoreGuiInset = true, DisplayOrder = 1000 }, player.PlayerGui)
    local subText = new("TextLabel", { Size = UDim2.new(1,0,0,50), Position = UDim2.new(0,0,0.8,0), BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 24, TextStrokeTransparency = 0, TextTransparency = 1, Text = "" }, subGui)
    
    local loadingGui = new("ScreenGui", { Name = "LoadingUI", IgnoreGuiInset = true, DisplayOrder = 1000 }, player.PlayerGui)
    new("Frame", { Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(10,10,12), BorderSizePixel = 0 }, loadingGui)
    local loadTxt = new("TextLabel", { Size = UDim2.fromScale(1,0.4), Position = UDim2.fromScale(0,0.2), BackgroundTransparency = 1, Text = "构建宇宙深空模型 0%", TextColor3 = Color3.fromRGB(0,200,255), Font = Enum.Font.GothamBold, TextSize = 28 }, loadingGui)
    local barBg = new("Frame", { Size = UDim2.fromOffset(300,10), Position = UDim2.fromScale(0.5,0.5), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Color3.fromRGB(30,30,35), BorderSizePixel = 0 }, loadingGui)
    new("UICorner", { CornerRadius = UDim.new(1,0) }, barBg)
    local barFill = new("Frame", { Size = UDim2.fromScale(0,1), BackgroundColor3 = Color3.fromRGB(0,200,255), BorderSizePixel = 0 }, barBg)
    new("UICorner", { CornerRadius = UDim.new(1,0) }, barFill)

    local sceneFolder = new("Folder", { Name = "CinematicScene" }, Workspace)
    local stageFolder = new("Folder", { Name = "SpaceStage" }, sceneFolder)
    
    local shipStartCF = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 30 + hrp.CFrame.RightVector * -150 + Vector3.new(0, 60, 0)) * CFrame.Angles(0, hrp.Orientation.Y + math.rad(90), 0)
    local shipLandCF = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 30 + Vector3.new(0, 5, 0)) * CFrame.Angles(0, hrp.Orientation.Y, 0)
    local shipModel

    local GC = SPACE_ORIGIN + Vector3.new(0,0,-100000)
    local EC = GC + Vector3.new(5000, 0, 5000)
    
    table.insert(buildQueue, function() shipModel = buildCannonStyleShip(sceneFolder, shipStartCF) end)
    
    table.insert(buildQueue, function()
        local sun = bigSphere(stageFolder, GC, 2500, Color3.fromRGB(255, 200, 100), Enum.Material.Neon, 0.1)
        new("PointLight", { Range = 50000, Brightness = 3, Color = Color3.fromRGB(255,200,100) }, sun)
    end)
    
    local pDefs = {
        {name="Mercury", pos=GC+Vector3.new(6000, 1000, 2000), size=300, tex=TEXTURES.mercury},
        {name="Venus", pos=GC+Vector3.new(10000, -2000, 8000), size=600, tex=TEXTURES.venus},
        {name="Earth", pos=GC+Vector3.new(15000, 3000, 12000), size=800, tex=TEXTURES.earth},
        {name="Mars", pos=GC+Vector3.new(20000, -4000, 18000), size=500, tex=TEXTURES.mars},
        {name="Jupiter", pos=GC+Vector3.new(30000, 5000, 25000), size=1500, tex=TEXTURES.jupiter},
        {name="Saturn", pos=GC+Vector3.new(45000, -6000, 35000), size=1200, tex=TEXTURES.saturn},
        {name="Uranus", pos=GC+Vector3.new(60000, 7000, 45000), size=900, tex=TEXTURES.uranus},
        {name="Neptune", pos=GC+Vector3.new(80000, -8000, 60000), size=850, tex=TEXTURES.neptune}
    }
    
    for _, def in ipairs(pDefs) do
        table.insert(buildQueue, function()
            local p = texturedSphere(stageFolder, def.pos, def.size, def.tex, Color3.new(1,1,1), Enum.Material.SmoothPlastic, 0, def.name)
            if def.name == "Saturn" then
                for i = 1, 3 do
                    local r = vpart({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(def.size*(2+i*0.3), 15, def.size*(2+i*0.3)), CFrame = CFrame.new(def.pos) * CFrame.Angles(math.rad(25),0,math.rad(10)) * CFrame.Angles(0,0,math.rad(90)), Color = Color3.fromRGB(150-i*10,130-i*10,100-i*10), Material = Enum.Material.Slate, Transparency = 0.2 + i*0.1 }, stageFolder)
                end
            end
        end)
    end

    table.insert(buildQueue, function()
        local stars = new("Folder", { Name = "Stars" }, stageFolder)
        for i = 1, 200 do
            vpart({ Shape = Enum.PartType.Ball, Size = Vector3.new(20,20,20), Position = GC + randDir() * math.random(10000, 100000), Color = Color3.new(1,1,1), Material = Enum.Material.Neon, Transparency = math.random(0.2, 0.8) }, stars)
        end
    end)

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
            loadTxt.Text = "构建宇宙深空模型 " .. math.floor((completedTasks / totalTasks) * 100) .. "%"
        else
            isBuilding = false
            buildConn:Disconnect()
            task.wait(1)
            loadingGui:Destroy()
            
            shipModel:PivotTo(shipStartCF)
            
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.lookAt(hrp.Position + hrp.CFrame.LookVector * 20 + Vector3.new(0, 15, 30), hrp.Position)
            
            task.spawn(function()
                task.wait(1)
                subText.Text = "飞船正在降落..."; TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                
                local base = shipModel:FindFirstChild("Cockpit")
                local door = shipModel:FindFirstChild("Door")
                
                local tweenLand = TweenService:Create(shipModel.PrimaryPart or shipModel:FindFirstChild("EngineCore"), TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = shipLandCF})
                if not shipModel.PrimaryPart then
                    for _, p in pairs(shipModel:GetChildren()) do
                        if p:IsA("BasePart") then
                            TweenService:Create(p, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = p.CFrame - shipStartCF.Position + shipLandCF.Position}):Play()
                        end
                    end
                end
                TweenService:Create(camera, TweenInfo.new(6, Enum.EasingStyle.Quad), {CFrame = CFrame.lookAt(hrp.Position + hrp.CFrame.LookVector * 5 + Vector3.new(5, 5, 5), shipLandCF.Position)}):Play()
                tweenLand.Completed:Wait()
                
                task.wait(1)
                subText.Text = "舱门开启..."
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame * CFrame.new(0, 4, 0)}):Play()
                task.wait(1.5)
                
                subText.Text = "正在登机..."
                hrp.Anchored = false; if humanoid then humanoid.WalkSpeed = 16 end
                if humanoid then
                    humanoid:MoveTo((shipLandCF * CFrame.new(0, -2, -6)).Position); humanoid.MoveToFinished:Wait()
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
                local wormholeFolder = new("Folder", { Name = "WormholeFX" }, Workspace)
                
                local voidPart = vpart({ Shape = Enum.PartType.Ball, Size = Vector3.new(1, 1, 1), Color = Color3.new(0,0,0), Material = Enum.Material.SmoothPlastic, CFrame = CFrame.new(wormholePos) }, wormholeFolder)
                
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
                
                local tweenFly = TweenService:Create(shipModel.PrimaryPart or shipModel:FindFirstChild("EngineCore"), TweenInfo.new(2, Enum.EasingStyle.Exponential), {CFrame = CFrame.new(wormholePos)})
                if not shipModel.PrimaryPart then
                    for _, p in pairs(shipModel:GetChildren()) do
                        if p:IsA("BasePart") then
                            TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.Exponential), {CFrame = p.CFrame - shipLandCF.Position + wormholePos}):Play()
                        end
                    end
                end
                task.wait(2)
                
                if rotConn then rotConn:Disconnect() end
                for _, p in pairs(shipModel:GetChildren()) do p.Transparency = 1 end
                wormholeFolder:Destroy()
                
                task.wait(0.5); blur.Size = 0
                local speedLines = new("Folder", { Name = "SpeedLines" }, Workspace)
                for i=1, 200 do
                    local line = vpart({ Size = Vector3.new(0.1,0.1,math.random(200,800)), Color = Color3.new(1,1,1), Material = Enum.Material.Neon, CFrame = CFrame.new(camera.CFrame.Position + Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-500,-100))) }, speedLines)
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
                
                local earthObj = nil
                for _, p in pairs(stageFolder:GetChildren()) do if p.Name == "Earth" then earthObj = p break end end
                local earthPos = earthObj and earthObj.Position or (camera.CFrame.Position + camera.CFrame.LookVector * 6000)
                
                local landPos = earthPos + Vector3.new(0, 1600, 0)
                local platform = vpart({ Size = Vector3.new(100, 2, 100), Color = Color3.fromRGB(30,30,30), Material = Enum.Material.Metal, CFrame = CFrame.new(landPos) }, stageFolder)
                
                local shipLandCF2 = CFrame.new(landPos + Vector3.new(0, 5, 0)) * CFrame.Angles(0, math.rad(math.random(0,360)), 0)
                
                camera.CFrame = shipLandCF2 * CFrame.new(30, 30, 30) * CFrame.Angles(0, math.rad(45), 0)
                TweenService:Create(blur, TweenInfo.new(1), {Size = 0}):Play()
                
                for _, p in pairs(shipModel:GetChildren()) do
                    if p:IsA("BasePart") then
                        p.Transparency = 0
                        p.CFrame = shipLandCF2 * (p.CFrame - shipStartCF.Position) + Vector3.new(0, 80, 0)
                        TweenService:Create(p, TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = p.CFrame - Vector3.new(0, 80, 0)}):Play()
                    end
                end
                task.wait(5)
                
                subText.Text = "已到达目标星球，舱门开启..."; TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame * CFrame.new(0, 4, 0)}):Play()
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
                
                for _, p in pairs(shipModel:GetChildren()) do
                    if p:IsA("BasePart") then
                        TweenService:Create(p, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = p.CFrame + Vector3.new(0, 200, 0)}):Play()
                    end
                end
                task.wait(3)
                
                shipModel:Destroy(); stageFolder:Destroy()
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