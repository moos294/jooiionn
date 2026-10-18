local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local StarterGui=game:GetService("StarterGui")
local Workspace=game:GetService("Workspace")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local camera=Workspace.CurrentCamera

for _,v in pairs(game:GetService("CoreGui"):GetChildren())do if v.Name=="PowerCrownUI" or v.Name=="CinematicUI" or v.Name=="LoadingUI" or v.Name=="TunnelUI" then v:Destroy()end end
for _,v in pairs(player.PlayerGui:GetChildren())do if v.Name=="PowerCrownUI" or v.Name=="CinematicUI" or v.Name=="LoadingUI" or v.Name=="TunnelUI" then v:Destroy()end end
for _,v in pairs(Workspace:GetChildren())do if v.Name=="CinematicScene" or v.Name=="WormholeFX" or v.Name=="CineShip" or v.Name=="SpaceStage" then v:Destroy()end end
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
title.Text = "封存娱乐 V11.0 终极重构"
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
local SPACE_ORIGIN = Vector3.new(0, 300000, 0)
local EARTH_RADIUS = 80
local SUN_RADIUS = 1400
local TEXTURES = {
    earth = "rbxassetid://218579141", mercury = "rbxassetid://6218473454", venus = "rbxassetid://6218473772",
    sun = "rbxassetid://6218473826", mars = "rbxassetid://6218473454", jupiter = "rbxassetid://6218473826", saturn = "rbxassetid://6218473826",
    uranus = "rbxassetid://6218473866", neptune = "rbxassetid://6218473866"
}

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
local function texturedSphere(parent, pos, diameter, textureId, color, material, transparency, name)
    if not textureId then return nil end
    local baseDiameter = math.min(diameter, 2048)
    local p = vpart({ Name = name or "TexturedCelestialBody", Size = Vector3.one * baseDiameter, Position = pos, Color = color or Color3.new(1, 1, 1), Material = material or Enum.Material.SmoothPlastic, Transparency = transparency or 0 }, parent)
    local ok = pcall(function() new("SpecialMesh", { MeshType = Enum.MeshType.Sphere, Scale = Vector3.one * (diameter / baseDiameter), TextureId = textureId }, p) end)
    if not ok then p:Destroy() return nil end
    return p
end
local function randDir() local z = math.random() * 2 - 1 local a = math.random() * math.pi * 2 local r = math.sqrt(1 - z * z) return Vector3.new(r * math.cos(a), z, r * math.sin(a)) end

local function buildCannonStyleShip(parent, cf)
    local SCALE = 20
    local model = new("Model", { Name = "CineShip" }, parent)
    model.WorldPivot = cf
    local HULL = Color3.fromRGB(28, 31, 39)
    local HULL_LIT = Color3.fromRGB(48, 52, 62)
    local METAL = Color3.fromRGB(129, 136, 148)
    local DARK = Color3.fromRGB(14, 17, 23)
    local GOLD = Color3.fromRGB(191, 148, 62)
    local RED = Color3.fromRGB(235, 28, 42)
    
    local function L(x, y, z) return Vector3.new(x * SCALE, y * SCALE, z * SCALE) end
    local function box(name, x, y, z, sx, sy, sz, col, mat, rz)
        return vpart({ Name = name, Size = L(sx, sy, sz), Color = col, Material = mat, CFrame = cf * CFrame.new(L(x, y, z)) * CFrame.Angles(0, 0, rz or 0) }, model)
    end
    local function axialCylinder(name, z, radius, length, col, mat)
        return vpart({ Name = name, Shape = Enum.PartType.Cylinder, Size = Vector3.new(length * SCALE, radius * 2 * SCALE, radius * 2 * SCALE), Color = col, Material = mat, CFrame = cf * CFrame.new(0, 0, z * SCALE) * CFrame.Angles(0, math.rad(90), 0) }, model)
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

    axialCylinder("EngineCore", 4, 1.2, 6, HULL, Enum.Material.Metal)
    for i = 0, 7 do
        local a = i * math.pi / 4
        box("ArmorFacet", math.cos(a) * 1.4, math.sin(a) * 1.4, 2, 0.6, 1.2, 8, HULL_LIT, Enum.Material.Metal, a)
    end
    for k = 0, 10 do
        octRing("InductionCoil", -4 + k * 1.0, 1.8, 1.2, 0.2, METAL, Enum.Material.Metal)
    end
    box("Nose", 0, 0, -10, 2, 2, 4, DARK, Enum.Material.Metal)
    box("NoseTip", 0, 0, -13, 1, 1, 2, DARK, Enum.Material.Metal)
    box("Cockpit", 0, 1.5, -5, 1.8, 1, 3.4, Color3.fromRGB(100, 200, 255), Enum.Material.Glass)
    box("WingL", -5, -0.5, 2, 8, 0.3, 6, DARK, Enum.Material.Metal, math.rad(-15))
    box("WingR", 5, -0.5, 2, 8, 0.3, 6, DARK, Enum.Material.Metal, math.rad(15))
    box("WingL2", -8, -0.8, 4, 6, 0.2, 4, HULL, Enum.Material.Metal, math.rad(-25))
    box("WingR2", 8, -0.8, 4, 6, 0.2, 4, HULL, Enum.Material.Metal, math.rad(25))
    box("Door", 0, -2, -2, 2, 2.5, 0.2, Color3.fromRGB(40, 45, 50), Enum.Material.Metal)
    box("Ladder", 0, -4, -2.5, 1.5, 4, 0.2, METAL, Enum.Material.Metal, math.rad(20))
    box("Bridge", 0, 2.4, 1, 1.2, 0.5, 2, DARK, Enum.Material.Metal)
    local thr = axialCylinder("Thruster", 7.5, 0.8, 0.5, RED, Enum.Material.Neon)
    new("PointLight", { Color = RED, Range = 40, Brightness = 4 }, thr)
    
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
    Lighting.Brightness = 1
    Lighting.Ambient = Color3.fromRGB(30, 40, 50)
    Lighting.OutdoorAmbient = Color3.fromRGB(40, 50, 60)
    Lighting.ClockTime = 0
    
    local cc = new("ColorCorrectionEffect", { Contrast = 0.1, Saturation = -0.1, Brightness = 0 }, Lighting)
    local blur = new("BlurEffect", { Size = 0 }, Lighting)
    
    local subGui = new("ScreenGui", { Name = "SubtitleUI", IgnoreGuiInset = true, DisplayOrder = 1000 }, player.PlayerGui)
    local subText = new("TextLabel", { Size = UDim2.new(1,0,0,50), Position = UDim2.new(0,0,0.8,0), BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 24, TextStrokeTransparency = 0, TextTransparency = 1, Text = "" }, subGui)
    
    local loadingGui = new("ScreenGui", { Name = "LoadingUI", IgnoreGuiInset = true, DisplayOrder = 1000 }, player.PlayerGui)
    new("Frame", { Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(10,10,12), BorderSizePixel = 0 }, loadingGui)
    local loadTxt = new("TextLabel", { Size = UDim2.fromScale(1,0.4), Position = UDim2.fromScale(0,0.2), BackgroundTransparency = 1, Text = "加载原版宇宙模型 0%", TextColor3 = Color3.fromRGB(0,200,255), Font = Enum.Font.GothamBold, TextSize = 28 }, loadingGui)
    local barBg = new("Frame", { Size = UDim2.fromOffset(300,10), Position = UDim2.fromScale(0.5,0.5), AnchorPoint = Vector2.new(0.5,0.5), BackgroundColor3 = Color3.fromRGB(30,30,35), BorderSizePixel = 0 }, loadingGui)
    new("UICorner", { CornerRadius = UDim.new(1,0) }, barBg)
    local barFill = new("Frame", { Size = UDim2.fromScale(0,1), BackgroundColor3 = Color3.fromRGB(0,200,255), BorderSizePixel = 0 }, barBg)
    new("UICorner", { CornerRadius = UDim.new(1,0) }, barFill)

    local sceneFolder = new("Folder", { Name = "CinematicScene" }, Workspace)
    local stageFolder = new("Folder", { Name = "SpaceStage" }, sceneFolder)
    
    local startCF = CFrame.new(SPACE_ORIGIN + Vector3.new(300, 150, 0))
    local landCF = CFrame.new(SPACE_ORIGIN + Vector3.new(0, 15, 0))
    
    local buildQueue = {}
    local shipModel
    table.insert(buildQueue, function() shipModel = buildCannonStyleShip(sceneFolder, startCF) end)
    
    local planets = {}
    local GC = SPACE_ORIGIN
    local EC = GC + Vector3.new(5000, 0, 5000)
    
    local pDefs = {
        {name="Sun", pos=GC, size=SUN_RADIUS*2, tex=TEXTURES.sun},
        {name="Mercury", pos=GC+Vector3.new(6000, 1000, 2000), size=100, tex=TEXTURES.mercury},
        {name="Venus", pos=GC+Vector3.new(10000, -2000, 8000), size=200, tex=TEXTURES.venus},
        {name="Earth", pos=EC, size=EARTH_RADIUS*2, tex=TEXTURES.earth},
        {name="Mars", pos=GC+Vector3.new(20000, -4000, 18000), size=150, tex=TEXTURES.mars},
        {name="Jupiter", pos=GC+Vector3.new(30000, 5000, 25000), size=500, tex=TEXTURES.jupiter},
        {name="Saturn", pos=GC+Vector3.new(45000, -6000, 35000), size=400, tex=TEXTURES.saturn},
        {name="Uranus", pos=GC+Vector3.new(60000, 7000, 45000), size=300, tex=TEXTURES.uranus},
        {name="Neptune", pos=GC+Vector3.new(80000, -8000, 60000), size=280, tex=TEXTURES.neptune}
    }
    
    for _, def in ipairs(pDefs) do
        table.insert(buildQueue, function()
            local p = texturedSphere(stageFolder, def.pos, def.size, def.tex, Color3.new(1,1,1), Enum.Material.SmoothPlastic, 0, def.name)
            planets[def.name] = p
            if def.name == "Saturn" then
                for i = 1, 3 do
                    vpart({ Shape = Enum.PartType.Cylinder, Size = Vector3.new(def.size*(2+i*0.3), 15, def.size*(2+i*0.3)), CFrame = CFrame.new(def.pos) * CFrame.Angles(math.rad(25),0,math.rad(10)) * CFrame.Angles(0,0,math.rad(90)), Color = Color3.fromRGB(150-i*10,130-i*10,100-i*10), Material = Enum.Material.Slate, Transparency = 0.2 + i*0.1 }, stageFolder)
                end
            end
        end)
    end

    table.insert(buildQueue, function()
        local stars = new("Folder", { Name = "Stars" }, stageFolder)
        for i = 1, 300 do
            vpart({ Shape = Enum.PartType.Ball, Size = Vector3.new(20,20,20), Position = GC + randDir() * math.random(10000, 100000), Color = Color3.new(1,1,1), Material = Enum.Material.Neon, Transparency = math.random(0.2, 0.8) }, stars)
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
            loadTxt.Text = "加载原版宇宙模型 " .. math.floor((completedTasks / totalTasks) * 100) .. "%"
        else
            isBuilding = false
            buildConn:Disconnect()
            loadTxt.Text = "模型就绪，正在渲染光影..."
            task.wait(3)
            loadingGui:Destroy()
            
            camera.CameraType = Enum.CameraType.Scriptable
            camera.FieldOfView = 90
            camera.CFrame = CFrame.lookAt(landCF.Position + Vector3.new(200, 50, 200), landCF.Position)
            
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
                TweenService:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = landCF * CFrame.new(0, -4, -6)}):Play()
                task.wait(2)
                TweenService:Create(hrp, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = landCF * CFrame.new(0, 0, -3)}):Play()
                task.wait(1.5)
                
                hrp.Transparency = 1
                for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.Transparency = 1 end end
                
                TweenService:Create(door, TweenInfo.new(1), {CFrame = door.CFrame}):Play()
                TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                task.wait(1)
                
                camera.CFrame = landCF * CFrame.new(0, 10, -30)
                subText.Text = "正在制造虫洞，请稍等..."; TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                
                local wormholeGui = new("ScreenGui", { IgnoreGuiInset = true, DisplayOrder = 998 }, player.PlayerGui)
                local void = new("Frame", { AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.fromOffset(0,0), BackgroundColor3 = Color3.new(0,0,0) }, wormholeGui)
                new("UICorner", { CornerRadius = UDim.new(1,0) }, void)
                
                local ring1 = new("Frame", { AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.fromOffset(0,0), BackgroundTransparency = 1 }, wormholeGui)
                new("UICorner", { CornerRadius = UDim.new(1,0) }, ring1)
                new("UIStroke", { Color = Color3.fromRGB(50, 150, 255), Thickness = 15, Transparency = 0.2 }, ring1)
                
                local ring2 = new("Frame", { AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.fromOffset(0,0), BackgroundTransparency = 1 }, wormholeGui)
                new("UICorner", { CornerRadius = UDim.new(1,0) }, ring2)
                new("UIStroke", { Color = Color3.fromRGB(255, 200, 50), Thickness = 8, Transparency = 0.4 }, ring2)
                
                TweenService:Create(void, TweenInfo.new(4, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(300, 300)}):Play()
                TweenService:Create(ring1, TweenInfo.new(4, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(320, 320)}):Play()
                TweenService:Create(ring2, TweenInfo.new(4, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(350, 350)}):Play()
                
                task.wait(4)
                TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                
                for _, p in pairs(shipModel:GetChildren()) do
                    if p:IsA("BasePart") then
                        TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.Exponential), {CFrame = p.CFrame + p.CFrame.LookVector * 200}):Play()
                    end
                end
                task.wait(2)
                wormholeGui:Destroy()
                for _, p in pairs(shipModel:GetChildren()) do p.Transparency = 1 end
                
                local tunnelGui = new("ScreenGui", { Name = "TunnelUI", IgnoreGuiInset = true, DisplayOrder = 999 }, player.PlayerGui)
                local bg = new("Frame", { Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(5, 10, 20) }, tunnelGui)
                local hexGrid = new("ImageLabel", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Image = "rbxassetid://8305647025", ImageTransparency = 0.4, ImageColor3 = Color3.fromRGB(50, 150, 255) }, bg)
                local center = new("Frame", { AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.fromOffset(50, 50), BackgroundColor3 = Color3.new(0,0,0) }, bg)
                new("UICorner", { CornerRadius = UDim.new(1,0) }, center)
                
                local lines = {}
                for i=1, 200 do
                    local line = new("Frame", { AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.fromOffset(math.random(2,4), 0), BackgroundColor3 = i%3==0 and Color3.fromRGB(255,200,50) or Color3.fromRGB(100,200,255), Rotation = math.random(0,360) }, bg)
                    table.insert(lines, line)
                end
                
                local travelConn
                travelConn = RunService.RenderStepped:Connect(function(dt)
                    if not isPlaying then return end
                    for _, line in ipairs(lines) do
                        local length = line.AbsoluteSize.Y + 100
                        line.Size = UDim2.fromOffset(line.Size.X.Offset, length)
                        line.Position = UDim2.new(0.5, math.cos(math.rad(line.Rotation)) * length/2, 0.5, math.sin(math.rad(line.Rotation)) * length/2)
                    end
                    local size = center.AbsoluteSize.X + dt * 200
                    center.Size = UDim2.fromOffset(size, size)
                end)
                
                task.wait(6)
                if travelConn then travelConn:Disconnect() end
                tunnelGui:Destroy()
                
                camera.CFrame = CFrame.lookAt(GC + Vector3.new(0, 500, 5000), GC)
                
                local planetsOrder = {"Sun", "Earth", "Jupiter", "Saturn", "Mars", "Uranus", "Neptune"}
                for _, pName in ipairs(planetsOrder) do
                    local targetP = planets[pName]
                    local lookAt = CFrame.lookAt(targetP.Position + Vector3.new(0, 200, 800), targetP.Position)
                    TweenService:Create(camera, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = lookAt}):Play()
                    task.wait(2)
                end
                
                local earthObj = planets["Earth"]
                local landPos2 = earthObj.Position + Vector3.new(0, earthObj.Size.Y/2 + 10, 0)
                local platform = vpart({ Size = Vector3.new(400, 2, 400), Color = Color3.fromRGB(30, 100, 30), Material = Enum.Material.Grass, CFrame = CFrame.new(landPos2) }, sceneFolder)
                local shipLandCF2 = CFrame.new(landPos2 + Vector3.new(0, 5, 0)) * CFrame.Angles(0, math.rad(math.random(0,360)), 0)
                
                camera.CFrame = shipLandCF2 * CFrame.new(100, 50, 100) * CFrame.Angles(0, math.rad(45), 0)
                
                for _, p in pairs(shipModel:GetChildren()) do
                    if p:IsA("BasePart") then
                        p.Transparency = 0
                        p.CFrame = shipLandCF2 * (p.CFrame - landCF.Position) + Vector3.new(0, 100, 0)
                        TweenService:Create(p, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = p.CFrame - Vector3.new(0, 100, 0)}):Play()
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