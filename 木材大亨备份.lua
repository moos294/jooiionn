local LocalPlayer = game:GetService("Players").LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local OverlayGui = Instance.new("ScreenGui")
OverlayGui.Name = "Yttrium_Overlay"
OverlayGui.ResetOnSpawn = false
OverlayGui.IgnoreGuiInset = true
OverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if PlayerGui:FindFirstChild("Yttrium_Overlay") then
    PlayerGui.Yttrium_Overlay:Destroy()
end
OverlayGui.Parent = PlayerGui

local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    TextTitle = Color3.fromRGB(255, 255, 255)
}

local TopBar = Instance.new("Frame")
TopBar.AnchorPoint = Vector2.new(1, 0)
TopBar.Size = UDim2.new(0, 240, 0, 30)
TopBar.Position = UDim2.new(1, -10, 0, 40)
TopBar.BackgroundColor3 = Theme.Background
TopBar.BorderSizePixel = 0
TopBar.Parent = OverlayGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = TopBar

local TopStroke = Instance.new("UIStroke")
TopStroke.Color = Color3.fromRGB(0, 255, 255)
TopStroke.Thickness = 1
TopStroke.Parent = TopBar

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 1, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Theme.TextTitle
InfoLabel.Font = Enum.Font.Code
InfoLabel.TextSize = 12
InfoLabel.Parent = TopBar

local dragging, dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = TopBar.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        TopBar.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

task.spawn(function()
    while OverlayGui.Parent do
        local fps = math.floor(workspace:GetRealPhysicsFPS())
        local ping = 0
        pcall(function()
            local pingStr = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            ping = math.floor(tonumber(pingStr:match("%d+")) or 0)
        end)
        InfoLabel.Text = string.format("Yttrium | 帧率: %d | 延迟: %dms", fps, ping)
        task.wait(1)
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Character = LocalPlayer.Character
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
end)

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/MillJackson832/-/refs/heads/main/Wind%20Ui.txt"))()
local Window = WindUI:CreateWindow({
    Title = "Yttrium Hub",
    Author = "俄亥俄州",
    Folder = "V3",
    Size = UDim2.fromOffset(200, 395),
    Transparent = true,
    Theme = "Light",
    User = {
        Enabled = false,
        Callback = function() print("clicked") end,
        Anonymous = false
    },
    SideBarWidth = 135,
    ScrollBarEnabled = true,
    Background = "video:https://raw.githubusercontent.com/MillJackson832/_/refs/heads/main/Video_1774513461181_838.mp4",---背景
    BackgroundImageTransparency = 0.4, --透明度
})

Window:EditOpenButton({
    Title = "<font color='#FFFFFF'>Y</font><font color='#7FFFFF'>t</font><font color='#33FFFF'>t</font><font color='#00FFFF'>r</font><font color='#0099FF'>i</font><font color='#0033FF'>u</font><font color='#0000FF'>m</font>", --最小化按钮文字显示
    Icon = "https://raw.githubusercontent.com/122525a/Xiang/refs/heads/main/Image_1772856235446_755.jpg", --最小化按钮图标
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2.35,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("00FFFF")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("FFFFFF")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("1E90FF"))
    }),
    Draggable = true
})
local Tabs = {}

Tabs.MainSection = Window:Section({
    Title = "俄亥俄州",
    Opened = true,
})

Tabs.AuraTab        = Tabs.MainSection:Tab({ Title = "杀戮",     Icon = "sword" })
Tabs.MoneyTab       = Tabs.MainSection:Tab({ Title = "刷钱",  Icon = "wallet" })
Tabs.BypassTab      = Tabs.MainSection:Tab({ Title = "绕过",  Icon = "crown" })
Tabs.ProTab         = Tabs.MainSection:Tab({ Title = "防护",  Icon = "key" })
Tabs.PlayerTab      = Tabs.MainSection:Tab({ Title = "人物",  Icon = "user" })
Tabs.MMMTab         = Tabs.MainSection:Tab({ Title = "实体美化",Icon = "moon" })
Tabs.MHTab          = Tabs.MainSection:Tab({ Title = "枪械美化",Icon = "phone" })
Tabs.ACTab          = Tabs.MainSection:Tab({ Title = "活动",Icon = "star" })
Tabs.FfTab          = Tabs.MainSection:Tab({ Title = "防反",Icon = "shield" })
Tabs.ByTab          = Tabs.MainSection:Tab({ Title = "ESP",Icon = "eye" })
Tabs.TeTraXTab          = Tabs.MainSection:Tab({ Title = "TeTraX",Icon = "key" })
Tabs.ServerTab          = Tabs.MainSection:Tab({ Title = "服务器",Icon = "list" })
Tabs.LockTab          = Tabs.MainSection:Tab({ Title = "瞄准",Icon = "bot" })
Tabs.RaybotTab          = Tabs.MainSection:Tab({ Title = "子弹追踪",Icon = "bot" })
Tabs.ShujuTab          = Tabs.MainSection:Tab({ Title = "数据",Icon = "github" })
Tabs.MeiTab          = Tabs.MainSection:Tab({ Title = "人物美化",Icon = "github" })


Window:SelectTab(1)
Window:SetToggleKey(Enum.KeyCode.F, true)
_G.HealthThreshold = 0
_G.BladeAuraEnabled = false

local AutoArmor = false
local autokz = false
local healThread = nil
local AutoKnockReset = false
local antiKBEnabled = false
local sudu = nil
local Speed = 1
local jumpConn = nil
local skinvoid = false
local autoskin = false
local skinsec = ""

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local DrawingCache = {}
local nametagEnabled = false

local function ClearDrawings()
    for _, draw in pairs(DrawingCache) do
        pcall(function() draw:Remove() end)
    end
    DrawingCache = {}
end

local function GetPlayerCash(plr)
    if not plr:FindFirstChild("stats") then return nil end
    local money = plr.stats:FindFirstChild("Money")
    return money and money.Value or nil
end

local function initAllNametags()
    RunService.RenderStepped:Connect(function()
        if not nametagEnabled then return end
        ClearDrawings()

        for _, plr in pairs(Players:GetPlayers()) do
            if plr == LocalPlayer or not plr.Character then continue end
            local head = plr.Character:FindFirstChild("Head")
            if not head then continue end

            local cash = GetPlayerCash(plr)
            if cash == nil then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
            if not onScreen then continue end

            local text = Drawing.new("Text")
            text.Text = plr.Name .. " | $" .. cash
            text.Position = Vector2.new(pos.X, pos.Y - 30)
            text.Color = Color3.new(1, 1, 0)
            text.Outline = true
            text.Size = 16
            text.Center = true
            text.Visible = true

            table.insert(DrawingCache, text)
        end
    end)
end

local function clearAllNametags()
    ClearDrawings()
    nametagEnabled = false
end

Tabs.ByTab:Toggle({
    Title = "玩家金钱透视",
    Default = false,
    Callback = function(Value)
        nametagEnabled = Value
        if Value then
            initAllNametags()
        else
            clearAllNametags()
        end
    end
})
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera

local DrawingCache = {}
local itemESPEnabled = false
local renderConnection = nil

local function ClearDraw()
    for _, d in pairs(DrawingCache) do
        pcall(function() d:Remove() end)
    end
    DrawingCache = {}
end

local function GetAllPickupItems()
    local items = {}
    local itemFolder = Workspace:FindFirstChild("Game")
        and Workspace.Game:FindFirstChild("Entities")
        and Workspace.Game.Entities:FindFirstChild("ItemPickup")

    if not itemFolder then return items end

    for _, obj in pairs(itemFolder:GetChildren()) do
        local part = obj.PrimaryPart or obj:FindFirstChildOfClass("Part")
        if part then
            local realName = obj:GetAttribute("itemName") or obj.Name
            table.insert(items, {
                obj = obj,
                part = part,
                name = realName
            })
        end
    end
    return items
end

local function initAllItemESP()
    if renderConnection then renderConnection:Disconnect() end
    renderConnection = RunService.RenderStepped:Connect(function()
        if not itemESPEnabled then return end
        ClearDraw()

        local items = GetAllPickupItems()
        for _, item in pairs(items) do
            local part = item.part
            local name = item.name
            local pos = part.Position

            local screen, onScreen = Camera:WorldToViewportPoint(pos)
            if not onScreen then continue end

            local text = Drawing.new("Text")
            text.Text = string.format("[%s] 距离: %.1f", name, (Camera.CFrame.Position - pos).Magnitude)
            text.Size = 16
            text.Center = true
            text.Color = Color3.new(0, 1, 1)
            text.Outline = true
            text.Position = Vector2.new(screen.X, screen.Y - 20)
            text.Visible = true

            local dot = Drawing.new("Circle")
            dot.Position = Vector2.new(screen.X, screen.Y)
            dot.Radius = 4
            dot.Color = Color3.new(1, 0, 0)
            dot.Filled = true
            dot.Visible = true

            table.insert(DrawingCache, text)
            table.insert(DrawingCache, dot)
        end
    end)
end

local function clearAllItemESP()
    ClearDraw()
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    itemESPEnabled = false
end

Tabs.ByTab:Toggle({
    Title = "物品透视",
    Default = false,
    Callback = function(Value)
        itemESPEnabled = Value
        if Value then
            initAllItemESP()
        else
            clearAllItemESP()
        end
    end
})
local MoneyPrinterESP = false
local espCache = {}

game.RunService.RenderStepped:Connect(function()
    if not MoneyPrinterESP then return end

    local drop = game.Workspace:FindFirstChild("Game", true)
    if not drop then return end

    for _, obj in pairs(drop:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Money Printer" then
            if not espCache[obj] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = Color3.fromRGB(0,255,0)
                highlight.OutlineColor = Color3.fromRGB(0,255,0)
                highlight.FillTransparency = 0.3
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = obj
                highlight.Parent = obj

                local bill = Instance.new("BillboardGui")
                bill.Name = "ESP_Billboard"
                bill.AlwaysOnTop = true
                bill.Size = UDim2.new(0,160,0,50)
                bill.StudsOffset = Vector3.new(0,3,0)
                bill.Adornee = obj.PrimaryPart or obj
                bill.Parent = obj

                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1,0,1,0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.fromRGB(0,255,0)
                text.TextSize = 16
                text.TextStrokeColor3 = Color3.new(0,0,0)
                text.TextStrokeTransparency = 0
                text.Text = "印钞机\n距离: ? 米"
                text.Parent = bill

                espCache[obj] = {
                    highlight = highlight,
                    bill = bill,
                    text = text
                }
            end

            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and obj.PrimaryPart then
                local dist = math.floor((hrp.Position - obj.PrimaryPart.Position).Magnitude)
                espCache[obj].text.Text = "印钞机\n距离: "..dist.." 米"
            end
        end
    end

    for obj, data in pairs(espCache) do
        if not obj or not obj:IsDescendantOf(workspace) or obj.Name ~= "Money Printer" then
            data.highlight:Destroy()
            data.bill:Destroy()
            espCache[obj] = nil
        end
    end
end)

Tabs.ByTab:Toggle({
    Title = "印钞机透视",
    Default = false,
    Callback = function(Value)
        MoneyPrinterESP = Value
        if not Value then
            for _, d in pairs(espCache) do
                d.highlight:Destroy()
                d.bill:Destroy()
            end
            table.clear(espCache)
        end
    end
})
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local itemESPEnabled = false
local espCache = {}

local TEXT_COLOR = Color3.fromRGB(255, 215, 0)
local HIGHLIGHT_COLOR = Color3.fromRGB(255, 215, 0)
local HIGHLIGHT_TRANSPARENCY = 0.3

local function CreateESP(obj)
    if espCache[obj] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "DailyPrinterHighlight"
    highlight.FillColor = HIGHLIGHT_COLOR
    highlight.OutlineColor = HIGHLIGHT_COLOR
    highlight.FillTransparency = HIGHLIGHT_TRANSPARENCY
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = obj
    highlight.Parent = obj

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DailyPrinterESPText"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 160, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = obj.PrimaryPart or obj
    billboard.Parent = obj

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = TEXT_COLOR
    text.TextSize = 16
    text.TextStrokeColor3 = Color3.new(0,0,0)
    text.TextStrokeTransparency = 0
    text.Text = "每日印钞机\ 快来抢-"
    text.Parent = billboard

    espCache[obj] = {
        highlight = highlight,
        billboard = billboard,
        text = text
    }
end

local function UpdateESP()
    if not itemESPEnabled then return end

    local dropFolder = Workspace:FindFirstChild("Game")
    if dropFolder then
        dropFolder = dropFolder:FindFirstChild("Local")
        if dropFolder then
            dropFolder = dropFolder:FindFirstChild("droppables")
        end
    end
    if not dropFolder then return end

    for _, obj in pairs(dropFolder:GetChildren()) do
        if obj.Name == "Daily Printer" and obj:IsA("Model") then
            CreateESP(obj)

            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local dist = "?"

            if hrp and obj.PrimaryPart then
                dist = math.floor((hrp.Position - obj.PrimaryPart.Position).Magnitude)
            end

            espCache[obj].text.Text = "每日印钞机\n距离: " .. dist .. " 米"
        end
    end

    for obj, data in pairs(espCache) do
        if not obj or not obj:IsDescendantOf(Workspace) or obj.Name ~= "Daily Printer" then
            data.highlight:Destroy()
            data.billboard:Destroy()
            espCache[obj] = nil
        end
    end
end

local function initAllItemESP()
    RunService.RenderStepped:Connect(UpdateESP)
end

local function clearAllItemESP()
    for obj, data in pairs(espCache) do
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
    end
    table.clear(espCache)
end

Tabs.ByTab:Toggle({
    Title = "每日印钞机透视",
    Default = false,
    Callback = function(Value)
        itemESPEnabled = Value
        if Value then
            initAllItemESP()
        else
            clearAllItemESP()
        end
    end
})

local plrs = game:GetService("Players")
local rs = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
local lp = plrs.LocalPlayer
local dvv = require(rs.devv)
local sig = dvv.load("Signal")
local guid = dvv.load("GUID")
local inv = dvv.load("v3item").inventory
local dartOn = false
local dartCachedHitId = nil
local dartCurrentTarget = nil
local dartHeartConnections = {}
local dartNinjaStarBuyThread = nil
local targetDropdown = nil
local teleportLoopConn = nil
local teleportEnabled = false
getgenv().TrailColors = {
    StartColor = Color3.fromRGB(0, 255, 255),
    MiddleColor1 = Color3.fromRGB(173, 216, 230),
    MiddleColor2 = Color3.fromRGB(255, 255, 255),
    EndColor = Color3.fromRGB(30, 144, 255)
}
getgenv().AuraConfig = {
    SelectedTarget = "all",
    LockAttack = false,
    ShieldCheck = true
}
local function robloxNotify(title, text, duration)
    pcall(function()
        starterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end
local function hasShieldProtection(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    for _, desc in pairs(player.Character:GetDescendants()) do
        if desc:IsA("ForceField") or desc.Name:lower():find("shield") then
            return true
        end
    end
    return false
end
local function getFilteredTargets()
    local targets = {}
    local validPlayers = {}
    for _, p in ipairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if not getgenv().AuraConfig.ShieldCheck or (getgenv().AuraConfig.ShieldCheck and not hasShieldProtection(p)) then
                table.insert(validPlayers, p)
            end
        end
    end
    if getgenv().AuraConfig.LockAttack and getgenv().AuraConfig.SelectedTarget ~= "all" then
        for _, p in ipairs(validPlayers) do
            if p.Name == getgenv().AuraConfig.SelectedTarget then
                table.insert(targets, p)
                break
            end
        end
    else
        targets = validPlayers
    end
    return targets
end
local function generatePlayerList()
    local list = {"all"}
    for _, p in ipairs(plrs:GetPlayers()) do
        if p ~= lp then table.insert(list, p.Name) end
    end
    return list
end
local function refreshTargetDropdown()
    if targetDropdown then
        local newList = generatePlayerList()
        targetDropdown.Values = newList
        if not table.find(newList, getgenv().AuraConfig.SelectedTarget) then
            getgenv().AuraConfig.SelectedTarget = "all"
            targetDropdown.Value = "all"
        end
    end
end
local function createBeautifulTrail(origin, targetPos)
    local trailContainer = Instance.new("Folder")
    trailContainer.Name = "MagicTrail"
    trailContainer.Parent = workspace
    local midPoint = (origin + targetPos) / 2
    local direction = (targetPos - origin).Unit
    local perpendicular = Vector3.new(-direction.Z, direction.Y, direction.X) * 3
    local controlPoint = midPoint + perpendicular + Vector3.new(0, math.random(-3, 3), 0)
    local function createBezierCurve(p0, p1, p2, t)
        return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
    end
    local curvePoints = {}
    local numSegments = 20
    for i = 0, numSegments do
        local t = i / numSegments
        local point = createBezierCurve(origin, controlPoint, targetPos, t)
        table.insert(curvePoints, point)
    end
    for i = 1, #curvePoints - 1 do
        local startPoint = curvePoints[i]
        local endPoint = curvePoints[i + 1]
        local distance = (endPoint - startPoint).Magnitude
        local beamPart = Instance.new("Part")
        beamPart.Size = Vector3.new(0.15, 0.15, distance)
        beamPart.Anchored = true
        beamPart.CanCollide = false
        beamPart.Material = Enum.Material.Neon
        beamPart.Transparency = 0.3
        beamPart.CFrame = CFrame.new(startPoint, endPoint) * CFrame.new(0, 0, -distance / 2)
        beamPart.Parent = trailContainer
        local t = i / (#curvePoints - 1)
        local color
        if t < 0.3 then
            color = getgenv().TrailColors.StartColor or Color3.fromRGB(200, 180, 255)
        elseif t < 0.6 then
            color = getgenv().TrailColors.MiddleColor1 or Color3.fromRGB(180, 150, 240)
        elseif t < 0.9 then
            color = getgenv().TrailColors.MiddleColor2 or Color3.fromRGB(160, 130, 230)
        else
            color = getgenv().TrailColors.EndColor or Color3.fromRGB(140, 100, 220)
        end
        beamPart.Color = color
        local pointLight = Instance.new("PointLight")
        pointLight.Brightness = 5
        pointLight.Range = 3
        pointLight.Color = color
        pointLight.Parent = beamPart
        local particles = Instance.new("ParticleEmitter")
        particles.Size = NumberSequence.new(0.1, 0.3)
        particles.Transparency = NumberSequence.new(0.3, 0.8)
        particles.Lifetime = NumberRange.new(0.5, 1)
        particles.Rate = 50
        particles.Speed = NumberRange.new(1, 2)
        particles.VelocitySpread = 180
        particles.Color = ColorSequence.new(color)
        particles.Parent = beamPart
    end
    task.delay(1.5, function()
        if trailContainer and trailContainer.Parent then
            trailContainer:Destroy()
        end
    end)
    return trailContainer
end
local function dartCleanupConnections()
    for _, conn in ipairs(dartHeartConnections) do
        if conn then conn:Disconnect() end
    end
    dartHeartConnections = {}
    if teleportLoopConn then
        teleportLoopConn:Disconnect()
        teleportLoopConn = nil
    end
end
local function dartEquipNinjaStar()
    local itm = inv.getItems and inv.getItems() or inv.items or {}
    for _, v in next, itm do
        if v.name == "Ninja Star" then
            sig.FireServer("equip", v.guid)
            return v.guid
        end
    end
    return nil
end
local function dartInitThrow()
    local sg = dartEquipNinjaStar()
    if not sg then return end
    local c = lp.Character
    if not c then return end
    local rh = c:FindFirstChild("RightHand")
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not rh or not hrp then return end
    local mp = rh.Position + Vector3.new(0, 0.5, 0)
    local tp = mp + Vector3.new(50, 0, 0)
    local vel = (tp - mp).Unit * 150
    createBeautifulTrail(mp, tp)
    local ok, r1, hid = pcall(function()
        return sig.InvokeServer("throwSticky", guid(), "Ninja Star", sg, vel, tp)
    end)
    if ok and r1 and hid then
        dartCachedHitId = hid
    end
end
local function dartFindValidTarget()
    local targets = getFilteredTargets()
    if #targets == 0 then return nil end
    local closest = nil
    local minDist = math.huge
    local myPos = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character.HumanoidRootPart.Position
    if not myPos then return nil end
    for _, player in ipairs(targets) do
        local char = player.Character
        local head = char:FindFirstChild("Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if head and hrp then
            local dist = (hrp.Position - myPos).Magnitude
            if dist < minDist and dist <= 50 then
                minDist = dist
                closest = {player = player, head = head}
            end
        end
    end
    return closest
end
local function dartRapidThrowAttack()
    if not dartOn or not dartCachedHitId then return end
    local targetData = dartFindValidTarget()
    if not targetData then return end
    local head = targetData.head
    local tp = head.Position
    local wcf = CFrame.new(tp, tp + Vector3.new(0, 1, 0))
    local rcf = CFrame.new(0, 0, 0)
    local c = lp.Character
    if c and c:FindFirstChild("RightHand") then
        local rh = c:FindFirstChild("RightHand")
        createBeautifulTrail(rh.Position, tp)
    end
    for i = 1, 15 do
        sig.InvokeServer("hitSticky", dartCachedHitId, head, rcf, wcf)
    end
end
local function getRandomValidTarget()
    local validTargets = getFilteredTargets()
    if #validTargets == 0 then return nil end
    return validTargets[math.random(1, #validTargets)]
end
local function dartFastTeleport()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp then
        robloxNotify("传送失败", "自身角色未加载", 3)
        return
    end
    local validTargets = getFilteredTargets()
    if #validTargets == 0 then
        robloxNotify("传送失败", "无有效传送目标（全带护盾/无玩家）", 3)
        dartCurrentTarget = nil
        return
    end
    if getgenv().AuraConfig.SelectedTarget ~= "all" then
        dartCurrentTarget = nil
        for _, p in ipairs(validTargets) do
            if p.Name == getgenv().AuraConfig.SelectedTarget then
                dartCurrentTarget = p
                break
            end
        end
        if not dartCurrentTarget then
            robloxNotify("传送失败", "选中目标无效，自动切换随机目标", 3)
            dartCurrentTarget = getRandomValidTarget()
        end
    else
        if not dartCurrentTarget or hasShieldProtection(dartCurrentTarget) or not dartCurrentTarget.Character or not dartCurrentTarget.Character:FindFirstChild("HumanoidRootPart") or dartCurrentTarget.Character.Humanoid.Health <= 0 then
            dartCurrentTarget = getRandomValidTarget()
        end
    end
    if not dartCurrentTarget then
        robloxNotify("传送失败", "无可用目标", 3)
        return
    end
    local targetChar = dartCurrentTarget.Character
    if not targetChar then
        robloxNotify("传送失败", "目标未加载", 3)
        dartCurrentTarget = nil
        return
    end
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHrp then
        robloxNotify("传送失败", "根部件加载失败", 3)
        dartCurrentTarget = nil
        return
    end
    local targetHum = targetChar:FindFirstChild("Humanoid")
    if not targetHum or targetHum.Health <= 0 then
        robloxNotify("传送失败", "目标生命值为0", 3)
        dartCurrentTarget = nil
        return
    end
    if getgenv().AuraConfig.ShieldCheck and hasShieldProtection(dartCurrentTarget) then
        robloxNotify("传送失败", "目标拥有护盾", 3)
        dartCurrentTarget = getRandomValidTarget()
        return
    end
    hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 1.5)
end
local function startTeleportLoop()
    if teleportLoopConn then teleportLoopConn:Disconnect() end
    teleportLoopConn = runService.Heartbeat:Connect(function()
        if teleportEnabled and dartOn then
            dartFastTeleport()
            task.wait(0.3)
        end
    end)
end
targetDropdown = Tabs.AuraTab:Dropdown({
    Title = "攻击/传送目标",
    Values = generatePlayerList(),
    Value = getgenv().AuraConfig.SelectedTarget,
    Callback = function(value)
        getgenv().AuraConfig.SelectedTarget = value
        dartCurrentTarget = nil
    end
})
Tabs.AuraTab:Button({
    Title = "刷新目标列表",
    Callback = function()
        refreshTargetDropdown()
    end
})
Tabs.AuraTab:Toggle({
    Title = "锁定攻击",
    Default = getgenv().AuraConfig.LockAttack,
    Callback = function(state)
        getgenv().AuraConfig.LockAttack = state
        dartCurrentTarget = nil
    end
})
Tabs.AuraTab:Toggle({
    Title = "护盾检测",
    Default = getgenv().AuraConfig.ShieldCheck,
    Callback = function(state)
        getgenv().AuraConfig.ShieldCheck = state
        dartCurrentTarget = nil
    end
})
Tabs.AuraTab:Toggle({
    Title = "自动持续传送",
    Default = false,
    Callback = function(state)
        teleportEnabled = state
        dartCurrentTarget = nil
        if state and dartOn then
            startTeleportLoop()
        else
            if teleportLoopConn then
                teleportLoopConn:Disconnect()
                teleportLoopConn = nil
            end
        end
    end
})
Tabs.AuraTab:Toggle({
    Title = "忍者飞镖光环",
    Default = false,
    Callback = function(state)
        dartOn = state
        dartCleanupConnections()
        if state then
            dartEquipNinjaStar()
            task.wait(0.1)
            dartInitThrow()
            local fastAttackConn = runService.RenderStepped:Connect(function()
                if not dartOn then return end
                dartRapidThrowAttack()
            end)
            table.insert(dartHeartConnections, fastAttackConn)
            if teleportEnabled then
                startTeleportLoop()
            end
        end
    end
})
Tabs.AuraTab:Toggle({
    Title = "自动购买飞镖",
    Default = false,
    Callback = function(state)
        if dartNinjaStarBuyThread then
            dartNinjaStarBuyThread:Disconnect()
            dartNinjaStarBuyThread = nil
        end
        if state then
            local heartbeat = game:GetService("RunService").Heartbeat
            dartNinjaStarBuyThread = heartbeat:Connect(function()
                sig.InvokeServer("attemptPurchase", "Ninja Star")
                for _, v in next, inv.items do
                    if v.name == "Ninja Star" then
                        break
                    end
                end
            end)
        end
    end
})
local originalOnDestroy = Window.OnDestroy or function() end
Window.OnDestroy = function(...)
    originalOnDestroy(...)
    dartCleanupConnections()
    if dartNinjaStarBuyThread then
        dartNinjaStarBuyThread:Disconnect()
        dartNinjaStarBuyThread = nil
    end
end
Tabs.AuraTab:Toggle({
    Title = "香蕉皮光环",
    Default = false,
    Callback = function(state)
        _G.AuraEnabled = state
        if not state then _G.TargetId = nil end
    end
})
Tabs.AuraTab:Toggle({
    Title = "战斧",
    Default = false,
    Callback = function(state)
        _G.BladeAuraEnabled = state
    end
})
Tabs.AuraTab:Slider({
    Title = "不攻击生命值",
    Value = {
        Min = 0,
        Max = 25,
        Default = 0,
    },
    Callback = function(value)
        _G.HealthThreshold = value
    end
})
local devv = ReplicatedStorage:WaitForChild("devv")
local load = require(devv).load
local FireServer = load("Signal").FireServer
local InvokeServer = load("Signal").InvokeServer
local GUID = load("GUID")
local Raycast = load("Raycast")
local v3item = load("v3item")
local inventory = v3item.inventory
_G.TargetId = nil
local lastAttack = 0
local lastAmmo = 0
local function getTarget()
    local targets = getFilteredTargets()
    if #targets == 0 then return nil end
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local target, dist = nil, 150
    for _, plr in ipairs(targets) do
        local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
        local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
        if tRoot and tHum and tHum.Health >= (_G.HealthThreshold or 0) then
            local d = (root.Position - tRoot.Position).Magnitude
            if d < dist then
                dist = d
                target = plr
            end
        end
    end
    return target
end
local function hackthrow(plr, itemname, itemguid, velocity, epos)
    if plr ~= lp then
        return
    end
    task.spawn(function()
        local throwGuid = GUID()
        local char = plr.Character
        if char and char:FindFirstChild("RightHand") then
            local hand = char:FindFirstChild("RightHand")
            createBeautifulTrail(hand.Position, epos)
        end
        local success, stickyId = InvokeServer("throwSticky", throwGuid, itemname, itemguid, velocity, epos)
        if not success then
            return
        end
        local dummyPart = Instance.new("Part")
        dummyPart.Size = Vector3.new(2, 2, 2)
        dummyPart.Position = epos
        dummyPart.Anchored = true
        dummyPart.Transparency = 1
        dummyPart.CanCollide = true
        dummyPart.Parent = workspace
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = { plr.Character, workspace.Game.Local, workspace.Game.Drones }
        local dist = (epos - plr.Character.Head.Position).Magnitude
        local rayResult = workspace:Raycast(
            plr.Character.Head.Position,
            (epos - plr.Character.Head.Position).Unit * (dist + 5),
            rayParams
        )
        if rayResult and rayResult.Instance then
            local hitPart = rayResult.Instance
            local relativeHitCFrame = hitPart.CFrame:ToObjectSpace(CFrame.new(rayResult.Position, rayResult.Position + rayResult.Normal))
            local stickyCFrame = CFrame.new(rayResult.Position)
            if dummyPart.Parent then
                dummyPart:Destroy()
            end
            _G.throwargs = {
                "hitSticky",
                stickyId or throwGuid,
                hitPart,
                relativeHitCFrame,
                stickyCFrame,
            }
            InvokeServer("hitSticky", stickyId or throwGuid, hitPart, relativeHitCFrame, stickyCFrame)
        else
            if dummyPart.Parent then
                dummyPart:Destroy()
            end
        end
    end)
end
local function getinventory()
    return inventory.items
end
local function finditem(string)
    for _, data in next, getinventory() do
        if data.name == string or data.type == string or data.subtype == string then
            return data
        end
    end
end
local function executebladekill(plr, head)
    local item = finditem("Tomahawk")
    if item then
        FireServer("equip", item.guid)
        if not _G.throwargs then
            local char = lp.Character
            if not char then return end
            local hand = char:FindFirstChild("RightHand")
            if not hand then return end
            local spos = hand.Position
            local epos = head.Position
            local velocity = (epos - spos).Unit * ((spos - epos).Magnitude * 15)
            createBeautifulTrail(spos, epos)
            task.spawn(InvokeServer, "attemptPurchaseAmmo", "Tomahawk")
            hackthrow(lp, "Tomahawk", item.guid, velocity, epos)
        end
        if _G.throwargs then
            _G.throwargs[3] = head
            task.spawn(InvokeServer, unpack(_G.throwargs))
        end
    else
        task.spawn(InvokeServer, "attemptPurchase", "Tomahawk")
    end
end
local function attack(plr)
    local now = tick()
    if now - lastAttack < 0.03 then return end
    lastAttack = now
    local tChar = plr.Character
    local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
    if not tRoot or not tHum or tHum.Health < 15 then return end
    task.spawn(function()
        local items = inventory.items or {}
        local banana = nil
        for _, v in next, items do
            if v.name == "Banana Peel" then
                banana = v
                break
            end
        end
        if not banana then
            pcall(function() InvokeServer("attemptPurchase", "Banana Peel") end)
            return
        end
        FireServer("equip", banana.guid)
        local pred = tRoot.AssemblyLinearVelocity * 0.2
        local cf = tRoot.CFrame * CFrame.new(0, -1, 0) + pred
        local rcf = tRoot.CFrame:ToObjectSpace(cf)
        local char = lp.Character
        if char and char:FindFirstChild("RightHand") then
            local hand = char:FindFirstChild("RightHand")
            createBeautifulTrail(hand.Position, cf.Position)
        end
        if not _G.TargetId then
            local ok, _, id = pcall(function()
                return InvokeServer("throwSticky", GUID(), "Banana Peel", banana.guid, Vector3.new(0, 100, 0), cf.Position)
            end)
            if ok and id then _G.TargetId = id end
        end
        if _G.TargetId then
            pcall(function()
                InvokeServer("hitSticky", _G.TargetId, tRoot, rcf, cf)
            end)
        end
    end)
end
runService.Heartbeat:Connect(function()
    if _G.AuraEnabled then
        local target = getTarget()
        if target then
            attack(target)
        end
        if tick() - lastAmmo > 0.5 then
            lastAmmo = tick()
            task.spawn(function()
                pcall(function() InvokeServer("attemptPurchaseAmmo", "Banana Peel") end)
            end)
        end
    end
    if _G.BladeAuraEnabled then
        local char = lp.Character
        local HumanoidRootPart = char and char:FindFirstChild("HumanoidRootPart")
        if not HumanoidRootPart then return end
        local target = getTarget()
        if target then
            local tChar = target.Character
            local hum = tChar and tChar:FindFirstChildOfClass("Humanoid")
            local head = tChar and tChar:FindFirstChild("Head")
            if head and hum and hum.Health > 0 then
                local dist = (HumanoidRootPart.Position - head.Position).Magnitude
                if dist < 190 then
                    executebladekill(target, head)
                end
            end
        end
    end
end)
pcall(function()
    starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Notification, true)
end)


local autobank = false
local bankThread = nil
local autoCraftEnabled = false
local autoClaimEnabled = false

Tabs.MoneyTab:Paragraph({
    Title = "云更新-刷钱",
    Desc = "优化了ATM 银行速度 修复了自动吃印钞机无法启用的问题 修复了自动拾取物品无法启用的问题",
    Image = "cloud",
    ImageSize = 42,
})

local VirtualInputManager = game:GetService("VirtualInputManager")

local function findAllBankCash()
    local cash = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), "bankcash") then
            if obj:IsA("Model") then
                local primaryPart = obj.PrimaryPart
                if not primaryPart then
                    for _, desc in ipairs(obj:GetDescendants()) do
                        if desc:IsA("BasePart") then
                            primaryPart = desc
                            break
                        end
                    end
                end
                if primaryPart then
                    table.insert(cash, primaryPart)
                end
            elseif obj:IsA("BasePart") then
                table.insert(cash, obj)
            end
        end
    end
    return cash
end

local function pressE()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
    pcall(function()
        game:GetService("UserInputService"):SetFocusedTextBox(nil)
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.None)
    end)
end

local function notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Bank",
            Text = text,
            Duration = 1
        })
    end)
end

local function bankLoop()
    while autobank do
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if not character then 
            task.wait(0.1)
            continue
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then 
            task.wait(0.1)
            continue
        end

        local cashList = findAllBankCash()
        if #cashList == 0 then
            notify("未刷新")
            task.wait(5)
            continue
        end

        local nearest = nil
        local nearestDist = math.huge
        for _, cash in ipairs(cashList) do
            local dist = (cash.Position - root.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = cash
            end
        end

        if nearest then
            root.CFrame = nearest.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.3)
            for i = 1, 10 do
                pressE()
            end
            task.wait(0.01)
        end

        task.wait(0.01)
    end
end

local function startBankLoop()
    if bankThread then return end
    bankThread = task.spawn(function()
        bankLoop()
        bankThread = nil
    end)
end

local function stopBankLoop()
    if bankThread then
        task.cancel(bankThread)
        bankThread = nil
    end
end

Tabs.MoneyTab:Toggle({
    Title = "自动银行",
    Value = false,
    Callback = function(state) 
        autobank = state
        if autobank then
            startBankLoop()
        else
            stopBankLoop()
        end
    end
})

local VirtualInputManager = game:GetService("VirtualInputManager")

local function findAllBankCash()
    local cash = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), "bankcash") then
            if obj:IsA("Model") then
                local primaryPart = obj.PrimaryPart
                if not primaryPart then
                    for _, desc in ipairs(obj:GetDescendants()) do
                        if desc:IsA("BasePart") then
                            primaryPart = desc
                            break
                        end
                    end
                end
                if primaryPart then
                    table.insert(cash, primaryPart)
                end
            elseif obj:IsA("BasePart") then
                table.insert(cash, obj)
            end
        end
    end
    return cash
end

local function pressE()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
    pcall(function()
        game:GetService("UserInputService"):SetFocusedTextBox(nil)
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.None)
    end)
end

local function notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Bank",
            Text = text,
            Duration = 1
        })
    end)
end

local function bankLoop()
    while autobank do
        local player = game:GetService("Players").LocalPlayer
local character = player.Character
if not character then 
    task.wait(0.1)
    continue
end
local root = character:FindFirstChild("HumanoidRootPart")
if not root then 
    task.wait(0.1)
    continue
end

local cashList = findAllBankCash()
if #cashList == 0 then
    notify("未刷新")
    -- 传送到你给的位置
    root.CFrame = CFrame.new(1156.01, -40.29, 192.84)
    task.wait(5) -- 传送后等5秒再继续找
    continue
end

        local nearest = nil
        local nearestDist = math.huge
        for _, cash in ipairs(cashList) do
            local dist = (cash.Position - root.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = cash
            end
        end

        if nearest then
            root.CFrame = nearest.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.3)
            for i = 1, 10 do
                pressE()
            end
            task.wait(0.01)
        end

        task.wait(0.01)
    end
end

local function startBankLoop()
    if bankThread then return end
    bankThread = task.spawn(function()
        bankLoop()
        bankThread = nil
    end)
end

local function stopBankLoop()
    if bankThread then
        task.cancel(bankThread)
        bankThread = nil
    end
end

Tabs.MoneyTab:Toggle({
    Title = "挂机银行",
    Value = false,
    Callback = function(state) 
        autobank = state
        if autobank then
            startBankLoop()
        else
            stopBankLoop()
        end
    end
})


local autoATMCashCombo = false

Tabs.MoneyTab:Toggle({
    Title = "ATM农场",
    Default = false,
    Callback = function(Value)
        autoATMCashCombo = Value
        
        if autoATMCashCombo then
            local function collectCash()
                local player = game:GetService("Players").LocalPlayer
                local cashSize = Vector3.new(2, 0.2499999850988388, 1)
                
                for _, part in ipairs(workspace.Game.Entities.CashBundle:GetDescendants()) do
                    if part:IsA("BasePart") and part.Size == cashSize then
                        player.Character.HumanoidRootPart.CFrame = part.CFrame
                        task.wait()
                    end
                end
            end
            
            coroutine.wrap(function()
                while autoATMCashCombo and task.wait() do
                   
                    local ATMsFolder = workspace:FindFirstChild("ATMs")
                    local localPlayer = game:GetService("Players").LocalPlayer
                    local hasActiveATM = false
                    
                    if ATMsFolder and localPlayer.Character then
                        for _, atm in ipairs(ATMsFolder:GetChildren()) do
                            if atm:IsA("Model") then
                                local hp = atm:GetAttribute("health")
                                if hp ~= 0 then
                                    hasActiveATM = true
                                    for _, part in ipairs(atm:GetChildren()) do
                                        if part.Name == "Main" and part:IsA("BasePart") then
                                            localPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
                                            task.wait()
                                            atm:SetAttribute("health", 0)
                                            break
                                        end
                                    end
                                    task.wait()
                                end
                            end
                        end
                    end
                    
                    if hasActiveATM then
                        task.wait(0.01)
                    else
                        collectCash()
                        
                 
                        task.wait()
                    end
                end
            end)()
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动制作劳力士并领取",
    Value = false,
    Callback = function(state)
        getgenv().AutoCraftClaimGem = state
        if not state then return end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local devv = require(ReplicatedStorage.devv)
        local Signal = devv.load("Signal")
        local RunService = game:GetService("RunService")

        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not getgenv().AutoCraftClaimGem then
                connection:Disconnect()
                return
            end
            pcall(function()
                Signal.InvokeServer("beginCraft", 'RollieCraft')
                Signal.InvokeServer("claimCraft", 'RollieCraft')
            end)
        end)

        while task.wait(0.1) do
            if not getgenv().AutoCraftClaimGem then break end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动存放贵重珠宝（需要珠宝柜）",
    Value = false,
    Callback = function(state)
        getgenv().AutoStoreGems = state
        if not state then return end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Workspace = game:GetService("Workspace")
        local devv = require(ReplicatedStorage.devv)
        local Signal = devv.load("Signal")
        local v3item = devv.load("v3item")
        local b1 = v3item.inventory.items

        while task.wait(0.5) do
            if not getgenv().AutoStoreGems then break end
            pcall(function()
                b1 = v3item.inventory.items
                for _, v in pairs(Workspace.HousingPlots:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and (v.ActionText == "Add Gem" or v.ActionText == "Equip a Gem") then
                        local houseid = v.Parent.Parent.Name
                        local hitid = v.Parent.Name
                        for i, item in next, b1 do
                            if item.name == "Diamond" or item.name == "Rollie" or item.name == "Dark Matter Gem" or item.name == "Void Gem" then
                                Signal.FireServer("equip", item.guid)
                                Signal.FireServer("updateGemDisplay", houseid, hitid, item.guid)
                            end
                        end
                    end
                end
            end)
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动开启幸运方块",
    Value = false,
    Callback = function(state)
        getgenv().AutoOpenLuckyBlock = state
        if not state then return end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local devv = require(ReplicatedStorage.devv)
        local Signal = devv.load("Signal")
        local v3item = devv.load("v3item")
        local item = v3item.inventory
        local luckyBlockItems = {"Green Lucky Block", "Orange Lucky Block", "Purple Lucky Block"}

        local function openLuckyBlocks()
            for i, v in next, item.items do
                if table.find(luckyBlockItems, v.name) then
                    local useid = v.guid
                    pcall(function()
                        Signal.FireServer("equip", useid)
                        task.wait(0.1)
                        Signal.FireServer("useConsumable", useid)
                        task.wait(0.1)
                        Signal.FireServer("removeItem", useid)
                    end)
                    break
                end
            end
        end

        while task.wait(0.05) do
            if not getgenv().AutoOpenLuckyBlock then break end
            pcall(openLuckyBlocks)
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动空投",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickAirdrop = state
        if not state then return end

        local Players = game:GetService("Players")
        local Workspace = game:GetService("Workspace")
        local localPlayer = Players.LocalPlayer

        local function teleportToAirdrop()
            local character = localPlayer.Character
            if not character then return false end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return false end
            local originalPosition = rootPart.CFrame
            local foundAirdrop = false

            local airdrops = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Airdrops") and Workspace.Game.Airdrops:GetChildren() or {}
            for _, airdrop in pairs(airdrops) do
                if airdrop:FindFirstChild('Airdrop') and airdrop.Airdrop:FindFirstChild("ProximityPrompt") then
                    local prompt = airdrop.Airdrop.ProximityPrompt
                    prompt.RequiresLineOfSight = false
                    prompt.HoldDuration = 0
                    rootPart.CFrame = airdrop.Airdrop.CFrame
                    task.wait(0.1)
                    for i = 1, 15 do
                        if fireproximityprompt then fireproximityprompt(prompt) else firesignal(prompt.Triggered) end
                        task.wait(0.02)
                    end
                    foundAirdrop = true
                    break
                end
            end

            if not foundAirdrop then
                rootPart.CFrame = originalPosition
            else
                task.wait(0.3)
                rootPart.CFrame = originalPosition
            end
            return foundAirdrop
        end

        while task.wait(0.1) do
            if not getgenv().AutoPickAirdrop then break end
            local collected = teleportToAirdrop()
            if not collected then
                for i = 1, 10 do
                    if not getgenv().AutoPickAirdrop then break end
                    task.wait(0.1)
                end
            else
                for i = 1, 3 do
                    if not getgenv().AutoPickAirdrop then break end
                    task.wait(0.1)
                end
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动租房",
    Value = false,
    Callback = function(state)
        getgenv().AutoRentHouse = state
        if not state then return end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Workspace = game:GetService("Workspace")
        local devv = require(ReplicatedStorage.devv)
        local Signal = devv.load("Signal")
        local lastRentTime = tick()
        local rentInterval = 2

        while task.wait(0.1) do
            if not getgenv().AutoRentHouse then break end
            local currentTime = tick()
            if currentTime - lastRentTime >= rentInterval then
                pcall(function()
                    for _, v in pairs(Workspace.HousingPlots:GetChildren()) do
                        if not v:GetAttribute("Owner") then
                            Signal.InvokeServer("rentHouse", v)
                        end
                    end
                end)
                lastRentTime = currentTime
            end
        end
    end
})

Tabs.MoneyTab:Toggle({
    Title = "自动售卖全部物品",
    Value = false,
    Callback = function(state)
        getgenv().AutoSellAll = state
        if not state then return end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local devv = require(ReplicatedStorage.devv)
        local Signal = devv.load("Signal")
        local v3item = devv.load("v3item")
        local item = v3item.inventory
        local lastSellTime = tick()
        local sellInterval = 1

        local function autoSellItems()
            for i, v in next, item.items do
                local sellid = v.guid
                pcall(function()
                    Signal.FireServer("equip", sellid)
                    Signal.FireServer("sellItem", sellid)
                end)
            end
        end

        while task.wait(0.1) do
            if not getgenv().AutoSellAll then break end
            local currentTime = tick()
            if currentTime - lastSellTime >= sellInterval then
                pcall(autoSellItems)
                lastSellTime = currentTime
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动开启材料盒",
    Value = false,
    Callback = function(state)
        getgenv().AutoOpenMaterialBox = state
        if not state then return end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local devv = require(ReplicatedStorage.devv)
        local Signal = devv.load("Signal")
        local v3item = devv.load("v3item")
        local item = v3item.inventory
        local materialBoxItems = {"Electronics", "Weapon Parts"}

        local function openMaterialBoxes()
            for i, v in next, item.items do
                if table.find(materialBoxItems, v.name) then
                    local useid = v.guid
                    pcall(function()
                        Signal.FireServer("equip", useid)
                        task.wait(0.1)
                        Signal.FireServer("useConsumable", useid)
                        task.wait(0.1)
                        Signal.FireServer("removeItem", useid)
                    end)
                    break
                end
            end
        end

        while task.wait(0.5) do
            if not getgenv().AutoOpenMaterialBox then break end
            pcall(openMaterialBoxes)
        end
    end
})

Tabs.MoneyTab:Toggle({
    Title = "自动捡稀有物品",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickEnabled = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Heart Crossbow",
            "Void Gem",
            "Diamond",
            "Nuclear Missile Launcher", 
            "NextBot Grenade",
            "Rollie",
            "Gold Crown",
            "Dark Matter Gem",
            "Diamond Glock",
            "Diamond Banana Peel",
            "Spirit Kunai",
            "Kunai",
            "Purple Lucky Block",
            "Snowflake Balloon",
            "Suitcase Nuke",
            "Nuke Launcher",
            "Easter Basket",
            "Gold Cup",
            "Pearl Necklace",
            "Treasure Map",
            "Spectral Scythe",
            "Bunny Balloon",
            "Ghost Balloon",
            "Clover Balloon",
            "Bat Balloon",
            "Gold Clover Balloon",
            "Golden Rose",
            "Black Rose",
            "Heart Balloon",
            "Skull Balloon",
            "Money Printer"
        }


        while task.wait(0.1) do
            -- 关闭就退出循环
            if not getgenv().AutoPickEnabled then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动捡印钞机",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickPrinter = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Money Printer",
            "Daily Printer"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickPrinter then break end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.MoneyTab:Toggle({
    Title = "自动捡载具钥匙",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickKey = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Helicopter Key",
            "Mustang Key"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickKey then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动捡稀有枪械",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickGun = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Diamond Glock",
            "Gold AK-47",
            "Golden Dragon"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickGun then break end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动捡稀有宝石",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickRare = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Void Gem",
            "Diamond",
            "Diamond Ring",
            "Gold Crown",
            "Dark Matter Gem",
            "Gold Cup",
            "Rollie"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickRare then break end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动捡材料",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickMaterial = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Electronics",
            "Weapon Parts"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickMaterial then break end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动捡糖果棒",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickCandy = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Candy Cane",
            "Blue Candy Cane"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickCandy then break end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动捡幸运方块",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickLuckyBlock = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Green Lucky Block",
            "Orange Lucky Block",
            "Purple Lucky Block"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickLuckyBlock then break end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.MoneyTab:Toggle({
    Title = "自动捡核弹",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickNuke = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Nuclear Missile Launcher",
            "NextBot Grenade",
            "Suitcase Nuke",
            "Nuke Launcher"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickNuke then break end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.MoneyTab:Toggle({
    Title = "自动捡气球",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickEnabled = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Snowflake Balloon",
            "Bunny Balloon",
            "Ghost Balloon",
            "Clover Balloon",
            "Bat Balloon",
            "Gold Clover Balloon",
            "Heart Balloon",
            "Skull Balloon",
            "Golden Rose",
            "Black Rose",
            "Spirit Kunai",
            "Kunai"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickEnabled then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动捡蓝卡",
    Value = false,
    Callback = function(state)
        getgenv().AutoPoliceKey = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Police Armory Keycard"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPoliceKey then break end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动捡空投&空袭标记",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickAirdrop = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Airdrop Marker",
            "Airstrike Marker"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickAirdrop then break end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动捡红卡",
    Value = false,
    Callback = function(state)
        getgenv().AutoMilitaryKey = state
        if not state then return end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Military Armory Keycard"
        }

        while task.wait(0.1) do
            if not getgenv().AutoMilitaryKey then break end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.MoneyTab:Toggle({
    Title = "自动吃普通印钞机",
    Value = false,
    Callback = function(state)
        -- 全局控制开关
        getgenv().AutoMoneyEnabled = state

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer

        local setting = {autoMoney = true, minMoney = 1000}

        local function fastCollectMoney()
            local character = localPlayer.Character
            if not character then return false end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end

            local originalCFrame = hrp.CFrame
            local foundMoney = false
            local moneyEntities = workspace.Game.Entities.CashBundle:GetChildren()
            for _, l in ipairs(moneyEntities) do
                local moneyValue = l:FindFirstChildWhichIsA("IntValue")
                if moneyValue and moneyValue.Value >= setting.minMoney then
                    local moneyPart = l:FindFirstChildWhichIsA("Part")
                    if moneyPart then
                        hrp.CFrame = moneyPart.CFrame
                        task.wait(0.05)
                        hrp.CFrame = originalCFrame
                        foundMoney = true
                        break
                    end
                end
            end
            return foundMoney
        end

        -- 主循环
        while task.wait(0.01) do
            -- 开关关闭
            if not getgenv().AutoMoneyEnabled then
                break
            end

            if setting.autoMoney then
                local hasCollected = fastCollectMoney()
                if hasCollected then
                    continue
                end
            end

            local droppables = workspace.Game.Local.droppables
            if droppables and droppables:FindFirstChild("Money Printer") then
                local unusualMoneyPrinter = droppables["Money Printer"]
                for _, child in pairs(unusualMoneyPrinter:GetChildren()) do
                    if child:IsA("MeshPart") then
                        local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = CFrame.new(child.Position)
                        end
                    end
                end
            end
        end
    end
})
Tabs.MoneyTab:Toggle({
    Title = "自动吃每日印钞机",
    Value = false,
    Callback = function(state)
        -- 全局控制开关
        getgenv().AutoMoneyEnabled = state

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer

        local setting = {autoMoney = true, minMoney = 2000}

        local function fastCollectMoney()
            local character = localPlayer.Character
            if not character then return false end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return false end

            local originalCFrame = hrp.CFrame
            local foundMoney = false
            local moneyEntities = workspace.Game.Entities.CashBundle:GetChildren()
            for _, l in ipairs(moneyEntities) do
                local moneyValue = l:FindFirstChildWhichIsA("IntValue")
                if moneyValue and moneyValue.Value >= setting.minMoney then
                    local moneyPart = l:FindFirstChildWhichIsA("Part")
                    if moneyPart then
                        hrp.CFrame = moneyPart.CFrame
                        task.wait(0.05)
                        hrp.CFrame = originalCFrame
                        foundMoney = true
                        break
                    end
                end
            end
            return foundMoney
        end

        -- 主循环
        while task.wait(0.01) do
            -- 开关关闭
            if not getgenv().AutoMoneyEnabled then
                break
            end

            if setting.autoMoney then
                local hasCollected = fastCollectMoney()
                if hasCollected then
                    continue
                end
            end

            local droppables = workspace.Game.Local.droppables
            if droppables and droppables:FindFirstChild("Daily Printer") then
                local unusualMoneyPrinter = droppables["Daily Printer"]
                for _, child in pairs(unusualMoneyPrinter:GetChildren()) do
                    if child:IsA("MeshPart") then
                        local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = CFrame.new(child.Position)
                        end
                    end
                end
            end
        end
    end
})

local autoUnlockEnabled = false
local originalPosition = nil
local originalEquipped = nil
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")

Tabs.MoneyTab:Toggle({
Title = "自动保险箱",
Value = false,
Callback = function(state)
autoUnlockEnabled = state
if state then
task.spawn(function()
character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
originalPosition = HumanoidRootPart.CFrame
local equippedItem = v3item.inventory.getEquippedItem()
originalEquipped = equippedItem and equippedItem.guid
while autoUnlockEnabled do
character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
Signal.InvokeServer("attemptPurchase", "Lockpick")
task.wait(0.2)
local allSafes = {}
local safeTypes = {
"LargeSafe",
"MediumSafe",
"SmallSafe",
"JewelSafe",
"GoldJewelSafe"
}
for _, safeType in pairs(safeTypes) do
local safesFolder = Workspace.Game.Entities:FindFirstChild(safeType)
if safesFolder then
for _, safe in pairs(safesFolder:GetChildren()) do
table.insert(allSafes, safe)
end
end
end
for _, safe in pairs(allSafes) do
if not autoUnlockEnabled then break end
local prompt = safe:FindFirstChild("ProximityPrompt", true)
if prompt and prompt.Enabled then
local safePosition
if safe:IsA("Model") and safe.PrimaryPart then
safePosition = safe.PrimaryPart.Position
else
safePosition = safe.WorldPivot.Position
end
HumanoidRootPart.CFrame = CFrame.new(safePosition)
task.wait(0.3)
fireproximityprompt(prompt)
task.wait(1)
for attempt = 1, 20 do
if not autoUnlockEnabled then break end
local moneyFound = false
for _, obj in pairs(Workspace.Game.Entities:GetDescendants()) do
if not autoUnlockEnabled then break end
if obj:IsA("BasePart") and obj.Name == "Cash" then
moneyFound = true
HumanoidRootPart.CFrame = CFrame.new(obj.Position)
firetouchinterest(obj, character:FindFirstChild("HumanoidRootPart"), 0)
firetouchinterest(obj, character:FindFirstChild("HumanoidRootPart"), 1)
task.wait(0.1)
elseif obj:IsA("Model") and (obj.Name == "GoldBar" or obj.Name == "Diamond" or obj.Name == "Emerald" or obj.Name == "Ruby" or obj.Name == "Sapphire" or obj.Name == "Amethyst" or obj.Name == "Topaz" or string.find(obj.Name, "Ring") or string.find(obj.Name, "Gem") or obj.Name == "Watch" or obj.Name == "Rollie") then
moneyFound = true
if obj.PrimaryPart then
HumanoidRootPart.CFrame = CFrame.new(obj.PrimaryPart.Position)
firetouchinterest(obj.PrimaryPart, character:FindFirstChild("HumanoidRootPart"), 0)
firetouchinterest(obj.PrimaryPart, character:FindFirstChild("HumanoidRootPart"), 1)
task.wait(0.1)
end
end
end
if not moneyFound then
break
end
task.wait(0.2)
end
task.wait(0.5)
end
end
task.wait(1)
end
if originalPosition then
HumanoidRootPart.CFrame = originalPosition
end
if originalEquipped then
Signal.FireServer("equip", originalEquipped)
end
end)
else
if originalEquipped then
Signal.FireServer("equip", originalEquipped)
end
end
end
})

Tabs.ACTab:Button({
    Title = "传送到TE玩家区域",
    Callback = function()
        HumanoidRootPart.CFrame = CFrame.new(1653.3216552734375, -16.953155517578125, -529.6856079101562)
    end
})

Tabs.ACTab:Button({
    Title = "传送到银行",
    Callback = function()
        HumanoidRootPart.CFrame = CFrame.new(1089.2777099609375, 8.169798851013184, -344.85955810546875)
    end
})

Tabs.ACTab:Button({
    Title = "传送Yttrium玩家区域",
    Callback = function()
        HumanoidRootPart.CFrame = CFrame.new(1156.01, -40.29, 192.84)
    end
})

Tabs.ACTab:Button({
    Title = "传送神秘打野点(吃印钞机)",
    Callback = function()
        HumanoidRootPart.CFrame = CFrame.new(562.01, -40.41, -72.31)
    end
})

-- 开锁光环
local autoUnlockEnabled = false
Tabs.MoneyTab:Toggle({
Title = "开锁光环",
Value = false,
Callback = function(state)
autoUnlockEnabled = state
if state then
task.spawn(function()
while autoUnlockEnabled do
Signal.InvokeServer("attemptPurchase", "Lockpick")
for _, safe in pairs(Workspace.Game.Entities.LargeSafe:GetChildren()) do
if safe:FindFirstChild("ProximityPrompt", true) then
local distance = (HumanoidRootPart.Position - safe.WorldPivot.Position).magnitude
if distance <= 45 then
fireproximityprompt(safe:FindFirstChild("ProximityPrompt", true))
end
end
end
for _, safe in pairs(Workspace.Game.Entities.MediumSafe:GetChildren()) do
if safe:FindFirstChild("ProximityPrompt", true) then
local distance = (HumanoidRootPart.Position - safe.WorldPivot.Position).magnitude
if distance <= 45 then
fireproximityprompt(safe:FindFirstChild("ProximityPrompt", true))
end
end
end
for _, safe in pairs(Workspace.Game.Entities.SmallSafe:GetChildren()) do
if safe:FindFirstChild("ProximityPrompt", true) then
local distance = (HumanoidRootPart.Position - safe.WorldPivot.Position).magnitude
if distance <= 45 then
fireproximityprompt(safe:FindFirstChild("ProximityPrompt", true))
end
end
end
for _, safe in pairs(Workspace.Game.Entities.JewelSafe:GetChildren()) do
if safe:FindFirstChild("ProximityPrompt", true) then
local distance = (HumanoidRootPart.Position - safe.WorldPivot.Position).magnitude
if distance <= 45 then
fireproximityprompt(safe:FindFirstChild("ProximityPrompt", true))
end
end
end
for _, safe in pairs(Workspace.Game.Entities.GoldJewelSafe:GetChildren()) do
if safe:FindFirstChild("ProximityPrompt", true) then
local distance = (HumanoidRootPart.Position - safe.WorldPivot.Position).magnitude
if distance <= 45 then
fireproximityprompt(safe:FindFirstChild("ProximityPrompt", true))
end
end
end
task.wait(0.2)
end
end)
end
end
})

-- 现金光环
local cashAuraEnabled = false
Tabs.MoneyTab:Toggle({
Title = "现金光环",
Value = false,
Callback = function(state)
cashAuraEnabled = state
if state then
task.spawn(function()
while cashAuraEnabled do
for _, cash in pairs(Workspace.Game.Entities.CashBundle:GetChildren()) do
if not cashAuraEnabled then break end
if cash:FindFirstChildOfClass("Part") then
local part = cash:FindFirstChildOfClass("Part")
local distance = (HumanoidRootPart.Position - part.Position).magnitude
if distance <= 30 and cash:FindFirstChildOfClass("ClickDetector") then
fireclickdetector(cash:FindFirstChildOfClass("ClickDetector"))
end
end
end
task.wait(0.1)
end
end)
end
end
})

-- 物品光环
local itemAuraEnabled = false
Tabs.MoneyTab:Toggle({
Title = "物品光环",
Value = false,
Callback = function(state)
itemAuraEnabled = state
if state then
task.spawn(function()
local valuableItems = {
"Dark Matter Gem", "Void Gem", "Diamond Ring", "Diamond", "Rollie",
"Watch", "Glock 18", "AR-15", "Amethyst", "Topaz", "Emerald",
"Gold Bar", "Sapphire", "Ruby", "Emerald Ring", "Topaz Ring",
"Amethyst Ring", "Sapphire Ring", "Ruby Ring", "AK-47", "Glock",
"Raygun", "Gold AK-47", "Gold Deagle", "AS Val", "AUG", "Acid Gun",
"P90", "Raygun", "RPK", "Sawn Off", "Scar L", "Saiga 12", "Tommy Gun",
"Double Barrel", "Deagle", "Dragunov", "Flamethrower", "M249 SAW",
"MP7", "Minigun", "M4A1", "Barrett M107", "Gravity Gun",
"Gold Lucky Block", "Orange Lucky Block", "Purple Lucky Block",
"Green Lucky Block", "Red Lucky Block", "Blue Lucky Block",
"Treasure Map", "Pearl Necklace", "Military Armory Keycard",
"Police Armory Keycard", "Money Printer", "RPG", "Trident",
"Gold Crown", "Gold Cup", "Heavy Vest", "Military Vest"
}
while itemAuraEnabled do
for _, item in pairs(Workspace.Game.Entities.ItemPickup:GetChildren()) do
if not itemAuraEnabled then break end
local itemName = item:GetAttribute("itemName")
local mainPart = item:FindFirstChildOfClass("Part")
if mainPart then
for _, valuableName in pairs(valuableItems) do
if itemName == valuableName then
local distance = (HumanoidRootPart.Position - mainPart.Position).magnitude
if distance <= 27 then
if item:FindFirstChildOfClass("ClickDetector") then
fireclickdetector(item:FindFirstChildOfClass("ClickDetector"))
elseif mainPart:FindFirstChildOfClass("ClickDetector") then
fireclickdetector(mainPart:FindFirstChildOfClass("ClickDetector"))
end
end
break
end
end
end
end
task.wait(0.3)
end
end)
end
end
})

-- 自动哑铃
local weightFarmEnabled = false
Tabs.MoneyTab:Toggle({
Title = "自动使用哑铃锻炼",
Value = false,
Callback = function(state)
weightFarmEnabled = state
if state then
task.spawn(function()
while weightFarmEnabled do
local equippedName = v3item.inventory.getEquippedItem().name
if equippedName == "Dumbell" then
Signal.FireServer("liftDumbell")
end
task.wait(0.5)
end
end)
end
end
})

local craftConnection

Tabs.BypassTab:Button({
    Title = "绕过移动经销商",
    Callback = function()
local pjyd pjyd=hookmetamethod(game,"__namecall",function(self,...)local args={...}local method=getnamecallmethod()if method=="InvokeServer" and args[2]==true then args[2]=false return pjyd(self,unpack(args))end return pjyd(self,...)end)
game:GetService("Players").LocalPlayer:SetAttribute("mobileDealer",true)
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local mobileDealer=require(ReplicatedStorage.devv.shared.Indicies.mobileDealer)

for category,items in pairs(mobileDealer)do 
    for _,item in ipairs(items)do 
        item.stock=999999 
    end 
end

table.insert(mobileDealer.Gun,{itemName="Acid Gun",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Candy Bucket",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Golden Rose",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Black Rose",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Dollar Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Bat Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Bunny Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Clover Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Ghost Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Gold Clover Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Heart Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Skull Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Snowflake Balloon",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Admin AK-47",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Admin Nuke Launcher",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Admin RPG",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Void Gem",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Pulse Rifle",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Unusual Money Printer",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Money Printer",stock=9999})
table.insert(mobileDealer.Gun,{itemName="Trident",stock=9999})
table.insert(mobileDealer.Gun,{itemName="NextBot Grenade",stock=9999})
table.insert(mobileDealer.Gun,{itemName="El Fuego",stock=9999})
    end
})

Tabs.BypassTab:Button({
    Title = "绕过高级动作",
    Callback = function()
        for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Emotes.Frame.ScrollingFrame:GetDescendants()) do
            if v.Name == "Locked" then
                v.Visible = false
            end
        end
    end
})

Tabs.BypassTab:Button({
    Title = "绕过飞行封禁",
    Callback = function()
        if game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion") then
            game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion"):Destroy()
        end
    end
})

Tabs.BypassTab:Button({
    Title = "绕过物品栏封禁",
    Callback = function()
        if game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion") then
            game:GetService("ReplicatedStorage"):FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion"):Destroy()
        end
    end
})

Tabs.BypassTab:Button({
    Title = "绕过战斗状态",
    Callback = function()
        for _, func in pairs(getgc(true)) do
            if type(func) == "function" then
                local info = debug.getinfo(func)
                if info.name == "isInCombat" or (info.source and info.source:find("combatIndicator")) then
                    hookfunction(func, function() 
                        return false 
                    end)
                end
            end
        end
    end
})

local maskOptions = {"Surgeon Mask", "Hockey Mask", "Blue Bandana", "Black Bandana", "Red Bandana"}
local selectedMask = "Surgeon Mask"
local autoMaskEnabled2 = false

Tabs.ProTab:Dropdown({
    Title = "选择口罩类型",
    Values = {"口罩", "杰森面具", "蓝色头巾", "黑色头巾", "红色头巾"},
    Value = "口罩",
    Callback = function(option)
        if option == "口罩" then
            selectedMask = "Surgeon Mask"
        elseif option == "杰森面具" then
            selectedMask = "Hockey Mask"
        elseif option == "蓝色头巾" then
            selectedMask = "Blue Bandana"
        elseif option == "黑色头巾" then
            selectedMask = "Black Bandana"
        elseif option == "红色头巾" then
            selectedMask = "Red Bandana"
        end
    end
})

Tabs.ProTab:Toggle({
    Title = "自动口罩(多种)",
    Default = false,
    Callback = function(Value)
        autoMaskEnabled2 = Value
        
        if not Value then return end
        
        task.spawn(function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
            local item = require(game:GetService("ReplicatedStorage").devv).load("v3item")

            local function purchaseAndEquipMask()
                if not autoMaskEnabled2 then return end
                
                local hasMask = false
                for _, v in pairs(item.inventory.items) do
                    if v.name == selectedMask then
                        hasMask = true
                        break
                    end
                end

                if not hasMask then
                    Signal.InvokeServer("attemptPurchase", selectedMask)
                    task.wait()
                end

                for _, v in pairs(item.inventory.items) do
                    if v.name == selectedMask then
                        Signal.FireServer("equip", v.guid)
                        Signal.FireServer("wearMask", v.guid)
                        break
                    end
                end
            end

            purchaseAndEquipMask()

            local conn
            conn = LocalPlayer.CharacterAdded:Connect(function(char)
                char:WaitForChild("HumanoidRootPart")
                task.wait()
                purchaseAndEquipMask()
            end)

            while autoMaskEnabled2 do
                task.wait()
            end

            if conn then conn:Disconnect() end
        end)
    end
})
Tabs.ProTab:Toggle({
    Title = "自动买护甲",
    Default = false,
    Callback = function(Value)
        AutoArmor = Value
        if Value then
            local heartbeat = game:GetService("RunService").Heartbeat
            local connection
            connection = heartbeat:Connect(function()
                if not AutoArmor then
                    connection:Disconnect()
                    return
                end
                
                pcall(function()
                    local player = game:GetService('Players').LocalPlayer
                    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 35 then
                        local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
                        local hasLightVest = false
                        
                        for i, v in next, b1 do
                            if v.name == "Light Vest" then
                                hasLightVest = true
                                local light = v.guid
                                local armor = player:GetAttribute('armor')
                                if armor == nil or armor <= 0 then
                                    require(game:GetService("ReplicatedStorage").devv).load("Signal").FireServer("equip", light)
                                    require(game:GetService("ReplicatedStorage").devv).load("Signal").FireServer("useConsumable", light)
                                    require(game:GetService("ReplicatedStorage").devv).load("Signal").FireServer("removeItem", light)
                                end
                                break
                            end
                        end
                        
                        if not hasLightVest then
                            require(game:GetService("ReplicatedStorage").devv).load("Signal").InvokeServer("attemptPurchase", "Light Vest")
                        end
                    end
                end)
            end)
        end
    end
})
Tabs.ProTab:Toggle({
    Title = "自动购买面具",
    Value = false,
    Callback = function(state) 
        autokz = state
        if autokz then
            while autokz and task.wait(1) do
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local Mask = character:FindFirstChild("Hockey Mask")
                local Signal = require(game:GetService("ReplicatedStorage").devv).load("Signal")
                local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
                if not Mask then
                    Signal.InvokeServer("attemptPurchase", "Hockey Mask")
                    for i, v in next, b1 do
                        if v.name == "Hockey Mask" then
                            local sugid = v.guid
                            if not Mask then
                                Signal.FireServer("equip", sugid)
                                Signal.FireServer("wearMask", sugid)
                            end
                            break
                        end
                    end
                end
            end
        end
    end
})

Tabs.ProTab:Toggle({
    Title = "自动回血",
    Default = false,
    Callback = function(Value)
        if healThread then
            healThread:Disconnect()
            healThread = nil
        end

        if Value then
            local heartbeat = game:GetService("RunService").Heartbeat
            healThread = heartbeat:Connect(function()
                Signal.InvokeServer("attemptPurchase", 'Bandage')
                local inv = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory
                for _, v in next, inv.items do
                    if v.name == 'Bandage' then
                        local bande = v.guid
                        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                        local Humanoid = Character:WaitForChild('Humanoid')
                        if Humanoid.Health >= 5 and Humanoid.Health < Humanoid.MaxHealth then
                            Signal.FireServer("equip", bande)
                            Signal.FireServer("useConsumable", bande)
                            Signal.FireServer("removeItem", bande)
                        end
                        break
                    end
                end
            end)
        end
    end
})


Tabs.PlayerTab:Toggle({
    Title = "移速修改",
    Default = false,
    Callback = function(v)
        if v == true then
            sudu = game:GetService("RunService").Heartbeat:Connect(function()
                if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.Humanoid and game:GetService("Players").LocalPlayer.Character.Humanoid.Parent then
                    if game:GetService("Players").LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 then
                        game:GetService("Players").LocalPlayer.Character:TranslateBy(game:GetService("Players").LocalPlayer.Character.Humanoid.MoveDirection * Speed / 10)
                    end
                end
            end)
        elseif not v and sudu then
            sudu:Disconnect()
            sudu = nil
        end
    end
})

Tabs.PlayerTab:Slider({
    Title = "速度设置",
    Value = {
        Min = 1,
        Max = 100,
        Default = 1,
    },
    Callback = function(Value)
        Speed = Value
    end
})
Tabs.PlayerTab:Toggle({
Title = "扩大视野 (开/关)",
Default = false,
Callback = function(v)
if v == true then
fovConnection = game:GetService("RunService").Heartbeat:Connect(function()
workspace.CurrentCamera.FieldOfView = 120
end)
elseif not v and fovConnection then
fovConnection:Disconnect()
fovConnection = nil
end
end
})

Tabs.PlayerTab:Slider({
Title = "视野范围设置",
Desc = "调整视野大小",
Value = {
Min = 70,
Max = 120,
Default = 120,
},
Callback = function(Value)
if fovConnection then
workspace.CurrentCamera.FieldOfView = Value
end
end
})
Tabs.PlayerTab:Button({
    Title = "购买以前的皮肤包",
    Callback = function()
        local cloneref = cloneref or function(v) return v end
local MarketplaceService = cloneref(game:GetService("MarketplaceService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 400, 0, 350)
frame.Position = UDim2.new(0.5, -200, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.15
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Text = "Yttrium Hub（仅支持ronix注入器）"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, 0, 1, -30)
scroll.Position = UDim2.new(0, 0, 0, 30)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local uiList = Instance.new("UIListLayout", scroll)
uiList.Padding = UDim.new(0, 6)
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 10)
end)

local function addProduct(info)
    local button = Instance.new("TextButton", scroll)
    button.Size = UDim2.new(1, -10, 0, 60)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = ""
    button.AutoButtonColor = true

    local icon = Instance.new("ImageLabel", button)
    icon.Size = UDim2.new(0, 60, 1, 0)
    icon.Image = "rbxassetid://" .. (info.IconImageAssetId or 0)
    icon.BackgroundTransparency = 1

    local nameLabel = Instance.new("TextLabel", button)
    nameLabel.Size = UDim2.new(1, -70, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 70, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = info.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true

    local priceLabel = Instance.new("TextLabel", button)
    priceLabel.Size = UDim2.new(1, -70, 0.5, 0)
    priceLabel.Position = UDim2.new(0, 70, 0.5, 0)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text = info.PriceInRobux and (tostring(info.PriceInRobux) .. " ROBUX") or "未上架"
    priceLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    priceLabel.TextXAlignment = Enum.TextXAlignment.Left
    priceLabel.Font = Enum.Font.Gotham
    priceLabel.TextScaled = true

    button.MouseButton1Click:Connect(function()
        if info.PriceInRobux then
            local success = pcall(function()
                MarketplaceService:PromptProductPurchase(player, info.ProductId)
            end)
            if not success then
                setclipboard("https://www.roblox.com/library/" .. tostring(info.ProductId))
            end
        else
            setclipboard("https://www.roblox.com/library/" .. tostring(info.ProductId))
        end
    end)
end

local function loadProducts()
    local pages
    local ok = pcall(function()
        pages = MarketplaceService:GetDeveloperProductsAsync()
    end)
    if not ok or not pages then
        local lbl = Instance.new("TextLabel", scroll)
        lbl.Size = UDim2.new(1, -10, 0, 40)
        lbl.BackgroundTransparency = 1
        lbl.Text = "获取商品失败"
        lbl.TextColor3 = Color3.fromRGB(255, 0, 0)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        return
    end

    local foundAny = false
    while true do
        local currentPage = pages:GetCurrentPage()
        if currentPage and #currentPage > 0 then
            for _, prod in ipairs(currentPage) do
                local info = MarketplaceService:GetProductInfo(prod.ProductId, Enum.InfoType.Product)
                addProduct(info)
                foundAny = true
            end
        end
        if pages.IsFinished then break end
        local success = pcall(function()
            pages:AdvanceToNextPage()
        end)
        if not success then break end
    end

    if not foundAny then
        local lbl = Instance.new("TextLabel", scroll)
        lbl.Size = UDim2.new(1, -10, 0, 40)
        lbl.BackgroundTransparency = 1
        lbl.Text = "未找到任何商品"
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
    end
end

loadProducts()
    end
})

Tabs.PlayerTab:Toggle({
    Title = "飞行（必须先绕过飞行）",
    Value = false,
    Callback = function(state)
        if state then
            local CoreGui = game:GetService("StarterGui") CoreGui:SetCore("SendNotification", { Title = "Yttrium Hub", Text = "不绕过执行此功能 600后别找我", Duration = 5, })
            local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speed = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local mini2 = Instance.new("TextButton")
main.Name = "main"
main.Parent = game:GetService"Players".LocalPlayer:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(173, 216, 230) -- 浅蓝色主框架
Frame.BorderColor3 = Color3.fromRGB(100, 149, 237) -- 深蓝色边框
Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
Frame.Size = UDim2.new(0, 190, 0, 57)
up.Name = "up"
up.Parent = Frame
up.BackgroundColor3 = Color3.fromRGB(135, 206, 235) -- 浅蓝色按钮
up.Size = UDim2.new(0, 44, 0, 28)
up.Font = Enum.Font.SourceSans
up.Text = "上"
up.TextColor3 = Color3.fromRGB(0, 0, 0)
up.TextSize = 14.000
down.Name = "down"
down.Parent = Frame
down.BackgroundColor3 = Color3.fromRGB(135, 206, 235) -- 浅蓝色按钮
down.Position = UDim2.new(0, 0, 0.491228074, 0)
down.Size = UDim2.new(0, 44, 0, 28)
down.Font = Enum.Font.SourceSans
down.Text = "下"
down.TextColor3 = Color3.fromRGB(0, 0, 0)
down.TextSize = 14.000
onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(173, 240, 255) -- 浅天蓝色飞行按钮
onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
onof.Size = UDim2.new(0, 56, 0, 28)
onof.Font = Enum.Font.SourceSans
onof.Text = "飞行"
onof.TextColor3 = Color3.fromRGB(0, 0, 0)
onof.TextSize = 14.000
TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(100, 149, 237) -- 深蓝色标题栏
TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
TextLabel.Size = UDim2.new(0, 100, 0, 28)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Yttrium Hub"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true
plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(135, 206, 235) -- 浅蓝色按钮
plus.Position = UDim2.new(0.231578946, 0, 0, 0)
plus.Size = UDim2.new(0, 45, 0, 28)
plus.Font = Enum.Font.SourceSans
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(0, 0, 0)
plus.TextScaled = true
plus.TextSize = 14.000
plus.TextWrapped = true
speed.Name = "speed"
speed.Parent = Frame
speed.BackgroundColor3 = Color3.fromRGB(173, 240, 255) -- 浅天蓝色速度显示
speed.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
speed.Size = UDim2.new(0, 44, 0, 28)
speed.Font = Enum.Font.SourceSans
speed.Text = "1"
speed.TextColor3 = Color3.fromRGB(0, 0, 0)
speed.TextScaled = true
speed.TextSize = 14.000
speed.TextWrapped = true
mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(135, 206, 235) -- 浅蓝色按钮
mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
mine.Size = UDim2.new(0, 45, 0, 29)
mine.Font = Enum.Font.SourceSans
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(0, 0, 0)
mine.TextScaled = true
mine.TextSize = 14.000
mine.TextWrapped = true
closebutton.Name = "Close"
closebutton.Parent = main.Frame
closebutton.BackgroundColor3 = Color3.fromRGB(204, 232, 255) -- 浅蓝色关闭按钮
closebutton.Font = "SourceSans"
closebutton.Size = UDim2.new(0, 45, 0, 28)
closebutton.Text = "关闭"
closebutton.TextSize = 30
closebutton.Position = UDim2.new(0, 0, -1, 27)
mini.Name = "minimize"
mini.Parent = main.Frame
mini.BackgroundColor3 = Color3.fromRGB(135, 206, 235) -- 浅蓝色隐藏按钮
mini.Font = "SourceSans"
mini.Size = UDim2.new(0, 45, 0, 28)
mini.Text = "隐藏"
mini.TextSize = 40
mini.Position = UDim2.new(0, 44, -1, 27)
mini2.Name = "minimize2"
mini2.Parent = main.Frame
mini2.BackgroundColor3 = Color3.fromRGB(135, 206, 235) -- 浅蓝色显示按钮
mini2.Font = "SourceSans"
mini2.Size = UDim2.new(0, 45, 0, 28)
mini2.Text = "+"
mini2.TextSize = 40
mini2.Position = UDim2.new(0, 44, -1, 57)
mini2.Visible = false
speeds = 1
local speaker = game:GetService("Players").LocalPlayer
local chr = game:GetService"Players".LocalPlayer.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
nowe = false
Frame.Active = true
Frame.Draggable = true
onof.MouseButton1Down:connect(function()
	if nowe == true then
		nowe = false
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	else 
		nowe = true
		for i = 1, speeds do
			spawn(function()
				local hb = game:GetService("RunService").Heartbeat	
				tpwalking = true
				local chr = game:GetService"Players".LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end
			end)
		end
		game:GetService"Players".LocalPlayer.Character.Animate.Disabled = true
		local Char = game:GetService"Players".LocalPlayer.Character
		local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
		for i,v in next, Hum:GetPlayingAnimationTracks() do
			v:AdjustSpeed(0)
		end
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	end
	if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
		local plr = game:GetService"Players".LocalPlayer
		local torso = plr.Character.Torso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0
		local bg = Instance.new("BodyGyro", torso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = torso.CFrame
		local bv = Instance.new("BodyVelocity", torso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			game:GetService("RunService").RenderStepped:Wait()
			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game:GetService"Players".LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false
	else
		local plr = game:GetService"Players".LocalPlayer
		local UpperTorso = plr.Character.UpperTorso
		local flying = true
		local deb = true
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local speed = 0
		local bg = Instance.new("BodyGyro", UpperTorso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = UpperTorso.CFrame
		local bv = Instance.new("BodyVelocity", UpperTorso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			wait()
			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+.5+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-1
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0,0)
			end
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		end
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		game:GetService"Players".LocalPlayer.Character.Animate.Disabled = false
		tpwalking = false
	end
end)
local tis
up.MouseButton1Down:connect(function()
	tis = up.MouseEnter:connect(function()
		while tis do
			wait()
			game:GetService"Players".LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService"Players".LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
		end
	end)
end)
up.MouseLeave:connect(function()
	if tis then
		tis:Disconnect()
		tis = nil
	end
end)
local dis
down.MouseButton1Down:connect(function()
	dis = down.MouseEnter:connect(function()
		while dis do
			wait()
			game:GetService"Players".LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService"Players".LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
		end
	end)
end)
down.MouseLeave:connect(function()
	if dis then
		dis:Disconnect()
		dis = nil
	end
end)
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
	wait(0.7)
	game:GetService"Players".LocalPlayer.Character.Humanoid.PlatformStand = false
	game:GetService"Players".LocalPlayer.Character.Animate.Disabled = false
end)
plus.MouseButton1Down:connect(function()
	speeds = speeds + 1
	speed.Text = speeds
	if nowe == true then
		tpwalking = false
		for i = 1, speeds do
			spawn(function()
				local hb = game:GetService("RunService").Heartbeat	
				tpwalking = true
				local chr = game:GetService"Players".LocalPlayer.Character
				local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
				while tpwalking and hb:Wait() and chr and hum and hum.Parent do
					if hum.MoveDirection.Magnitude > 0 then
						chr:TranslateBy(hum.MoveDirection)
					end
				end
			end)
		end
	end
end)
mine.MouseButton1Down:connect(function()
	if speeds == 1 then
		speed.Text = 'cannot be less than 1'
		wait(1)
		speed.Text = speeds
	else
		speeds = speeds - 1
		speed.Text = speeds
		if nowe == true then
			tpwalking = false
			for i = 1, speeds do
				spawn(function()
					local hb = game:GetService("RunService").Heartbeat	
					tpwalking = true
					local chr = game:GetService"Players".LocalPlayer.Character
					local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
					while tpwalking and hb:Wait() and chr and hum and hum.Parent do
						if hum.MoveDirection.Magnitude > 0 then
							chr:TranslateBy(hum.MoveDirection)
						end
					end
				end)
			end
		end
	end
end)
closebutton.MouseButton1Click:Connect(function()
	main:Destroy()
end)
mini.MouseButton1Click:Connect(function()
	up.Visible = false
	down.Visible = false
	onof.Visible = false
	plus.Visible = false
	speed.Visible = false
	mine.Visible = false
	mini.Visible = false
	mini2.Visible = true
	main.Frame.BackgroundTransparency = 1
	closebutton.Position = UDim2.new(0, 0, -1, 57)
end)
mini2.MouseButton1Click:Connect(function()
	up.Visible = true
	down.Visible = true
	onof.Visible = true
	plus.Visible = true
	speed.Visible = true
	mine.Visible = true
	mini.Visible = true
	mini2.Visible = false
	main.Frame.BackgroundTransparency = 0 
	closebutton.Position = UDim2.new(0, 0, -1, 27)
end)
        end
    end
})

Tabs.PlayerTab:Toggle({
    Title = "快速互动",
    Value = false,
    Callback = function(state)
        if state then
            game.ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
        prompt.HoldDuration = 0
    end)
        end
    end
})
Tabs.PlayerTab:Button({
    Title = "修改9个物品栏",
    Callback = function()
        local YttriumHub=require(game:GetService('ReplicatedStorage').devv.client.Objects.v3item)
YttriumHub.inventory.numSlots=9
    end
})
Tabs.PlayerTab:Toggle({
    Title = "解锁聊天框",
    Value = false,
    Callback = function(state)
        if state then
            game:GetService("Players").LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame.Visible = true
        end
    end
})

Tabs.PlayerTab:Button({
    Title = "全枪无限子弹",
    Callback = function()
        local function setInfiniteAmmo()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            
            local itemSystem = require(ReplicatedStorage.devv).load("v3item")
            local inventory = itemSystem.inventory
            
            for _, item in pairs(inventory.items) do
                if item and item.ammoManager then
                    item.ammoManager:setAmmo(9999)
                    item.ammoManager:setAmmoOut(9999)
                end
            end
        end
        
        setInfiniteAmmo()
        
        local infiniteAmmoLoop = task.spawn(function()
            while true do
                pcall(setInfiniteAmmo)
                task.wait(25)
            end
        end)
    end
})

Tabs.PlayerTab:Button({
    Title = "全枪射速提升",
    Callback = function()
        local function increaseFireRate()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            
            local itemSystem = require(ReplicatedStorage.devv).load("v3item")
            local inventory = itemSystem.inventory
            
            for _, item in pairs(inventory.items) do
                if item then
                    item.fireDebounce = 0.01
                    item.reloadTime = 0.1
                    if item.ammoManager then
                        item.ammoManager.ammo = 9999
                    end
                end
            end
        end
        
        increaseFireRate()
        
        local fireRateLoop = task.spawn(function()
            while true do
                pcall(increaseFireRate)
                task.wait(30)
            end
        end)
    end
})

Tabs.PlayerTab:Button({
    Title = "全枪无后坐力",
    Callback = function()
        local function removeRecoil()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            
            local itemSystem = require(ReplicatedStorage.devv).load("v3item")
            local inventory = itemSystem.inventory
            
            for _, item in pairs(inventory.items) do
                if item then
                    item.recoilAdd = 0
                    item.maxRecoil = 0
                    item.recoilDiminishFactor = 0
                    item.recoilFastDiminishFactor = 0
                    item.baseSpread = 0
                    item.baseAimSpread = 0
                    item.spread = 0
                    item.aimSpread = 0
                end
            end
        end
        
        removeRecoil()
        
        local recoilLoop = task.spawn(function()
            while true do
                pcall(removeRecoil)
                task.wait(30)
            end
        end)
    end
})


Tabs.PlayerTab:Toggle({
Title = "显示名字血量",
Value = false,
Callback = function(enableESP)
if enableESP then
local function ApplyESP(v)
if v.Character and v.Character:FindFirstChildOfClass'Humanoid' then
v.Character.Humanoid.NameDisplayDistance = 9e9
v.Character.Humanoid.NameOcclusion = "NoOcclusion"
v.Character.Humanoid.HealthDisplayDistance = 9e9
v.Character.Humanoid.HealthDisplayType = "AlwaysOn"
v.Character.Humanoid.Health = v.Character.Humanoid.Health
end
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
for i, v in pairs(Players:GetPlayers()) do
ApplyESP(v)
v.CharacterAdded:Connect(function()
task.wait(0.33)
ApplyESP(v)
end)
end
Players.PlayerAdded:Connect(function(v)
ApplyESP(v)
v.CharacterAdded:Connect(function()
task.wait(0.33)
ApplyESP(v)
end)
end)
local espConnection = RunService.Heartbeat:Connect(function()
for i, v in pairs(Players:GetPlayers()) do
if v.Character and v.Character:FindFirstChildOfClass'Humanoid' then
v.Character.Humanoid.NameDisplayDistance = 9e9
v.Character.Humanoid.NameOcclusion = "NoOcclusion"
v.Character.Humanoid.HealthDisplayDistance = 9e9
v.Character.Humanoid.HealthDisplayType = "AlwaysOn"
end
end
end)
_G.ESPConnection = espConnection
else
if _G.ESPConnection then
_G.ESPConnection:Disconnect()
_G.ESPConnection = nil
end
local Players = game:GetService("Players")
for i, v in pairs(Players:GetPlayers()) do
if v.Character and v.Character:FindFirstChildOfClass'Humanoid' then
v.Character.Humanoid.NameDisplayDistance = 100
v.Character.Humanoid.NameOcclusion = "OccludeAll"
v.Character.Humanoid.HealthDisplayDistance = 100
v.Character.Humanoid.HealthDisplayType = "DisplayWhenDamaged"
end
end
end
end
})



Tabs.PlayerTab:Toggle({
    Title = "无限跳跃",
    Default = false,
    Callback = function(Value)
        local jumpConn
        if Value then
            jumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local humanoid = game:GetService("Players").LocalPlayer.Character and
                                 game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if jumpConn then
                jumpConn:Disconnect()
                jumpConn = nil
            end
        end
    end
})

local nametagEnabled = false
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local LocalCharacter, LocalHead
local playerConnections = {}

local colorSequence = {
    Color3.fromRGB(173, 216, 230),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(0, 120, 255),
    Color3.fromRGB(255, 255, 255)
}
local colorT = 0

local function getGradientColor()
    colorT = colorT + 0.015
    if colorT >= #colorSequence then colorT = 0 end
    local i = math.floor(colorT) + 1
    local j = i % #colorSequence + 1
    local t = colorT - math.floor(colorT)
    return colorSequence[i]:Lerp(colorSequence[j], t)
end

local function updateNametag(player, textLabel)
    if not nametagEnabled then return end
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local targetHead = character:FindFirstChild("Head")
    if humanoid and targetHead and humanoid.Health > 0 and LocalHead then
        local distance = (LocalHead.Position - targetHead.Position).Magnitude
        textLabel.Text = string.format("%s\n血量: %d/%d\n距离: %.1fm", player.Name, math.floor(humanoid.Health), math.floor(humanoid.MaxHealth), distance)
        textLabel.TextColor3 = getGradientColor()
        textLabel.Visible = true
    else
        textLabel.Visible = false
    end
end

local function createNametag(player)
    if player == LocalPlayer or not nametagEnabled then return end
    playerConnections[player] = {}

    local function setupCharacter(character)
        local head = character:WaitForChild("Head")
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "TestNametag"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 9
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.2
        textLabel.BackgroundTransparency = 1
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.Parent = billboard

        local heartbeatConn = RunService.Heartbeat:Connect(function()
            if not character or not character.Parent then
                heartbeatConn:Disconnect()
                return
            end
            updateNametag(player, textLabel)
        end)
        table.insert(playerConnections[player], heartbeatConn)

        local charRemoveConn = character.AncestryChanged:Connect(function(_, parent)
            if parent == nil then
                billboard:Destroy()
                heartbeatConn:Disconnect()
                charRemoveConn:Disconnect()
            end
        end)
        table.insert(playerConnections[player], charRemoveConn)
    end

    if player.Character then setupCharacter(player.Character) end
    local charAddConn = player.CharacterAdded:Connect(setupCharacter)
    table.insert(playerConnections[player], charAddConn)
end

local function removeNametag(player)
    if playerConnections[player] then
        for _, conn in ipairs(playerConnections[player]) do conn:Disconnect() end
        playerConnections[player] = nil
    end
    if player.Character then
        local head = player.Character:FindFirstChild("Head")
        if head then local nt = head:FindFirstChild("TestNametag") if nt then nt:Destroy() end end
    end
end

local function initAllNametags()
    LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    LocalHead = LocalCharacter:WaitForChild("Head")
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createNametag(player)
            local leaveConn = player.AncestryChanged:Connect(function(_, parent)
                if parent == nil then removeNametag(player) leaveConn:Disconnect() end
            end)
        end
    end
    Players.PlayerAdded:Connect(function(player)
        createNametag(player)
        local leaveConn = player.AncestryChanged:Connect(function(_, parent)
            if parent == nil then removeNametag(player) leaveConn:Disconnect() end
        end)
    end)
    LocalPlayer.CharacterAdded:Connect(function(character)
        LocalCharacter = character
        LocalHead = character:WaitForChild("Head")
    end)
end

local function clearAllNametags()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            removeNametag(player)
        end
    end
    colorT = 0
end

Tabs.ByTab:Toggle({
    Title = "玩家透视",
    Default = false,
    Callback = function(Value)
        nametagEnabled = Value
        if Value then
            initAllNametags()
        else
            clearAllNametags()
        end
    end
})

local xeniox = {
    Data = {
        Identity = getidentity()
    },
    Helpers = {}
}

local devv = game:GetService("ReplicatedStorage").devv
local load = require(devv).load

xeniox.Helpers.SetIdentity = function(self, identity)
    setidentity(identity)
end

xeniox.Helpers.CallFuncSec = function(self, func, waited)
    self:SetIdentity(2)
    local result, err = pcall(func)
    if not result then
        warn("函数执行错误:", err)
    end
    if waited then
        task.wait(waited)
    end
    self:SetIdentity(xeniox.Data.Identity)
end

Tabs.MMMTab:Toggle({
    Title = "自动购买气球",
    Value = false,
    Callback = function(state)
        if not state then return end
        
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character:FindFirstChild("Balloon") then return end
        
        local Signal = load("Signal")
        Signal.InvokeServer("attemptPurchase", "Balloon")
        
        task.wait(0.5)
        
        local v3item = load("v3item")
        local inventory = v3item.inventory
        local balloonItem = inventory.getFromName("Balloon")
        
        if balloonItem then
            xeniox.Helpers:CallFuncSec(function()
                balloonItem:SetEquipped(true)
            end)
        end
    end
})
Tabs.MMMTab:Toggle({
    Title = "自动购买镰刀",
    Value = false,
    Callback = function(state)
        if not state then return end
        
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        
        if character:FindFirstChild("Balloon") then return end
        
        local Signal = load("Signal")
        Signal.InvokeServer("attemptPurchase", "Scythe")
        
        task.wait(0.5)
        
        local v3item = load("v3item")
        local inventory = v3item.inventory
        local balloonItem = inventory.getFromName("Scythe")
        
        if balloonItem then
            xeniox.Helpers:CallFuncSec(function()
                balloonItem:SetEquipped(true)
            end)
        end
    end
})

Tabs.MMMTab:Button({
    Title = "普通气球修改美金",
    Callback = function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "name") == "Balloon" and rawget(v, "holdableType") == "Balloon" then
                v.name, v.cost, v.unpurchasable, v.multiplier, v.movespeedAdd, v.cannotDiscard = "Dollar Balloon", 200, true, 0.8, 8, true
                if v.TPSOffsets then v.TPSOffsets.hold = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0) end
                if v.viewportOffsets and v.viewportOffsets.hotbar then v.viewportOffsets.hotbar.dist = 4 end
                v.canDrop, v.dropCooldown, v.craft = nil
                break
            end
        end

        for _, item in pairs(require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
            if item.name == "Dollar Balloon" then
                for _, btn in pairs({item.button, item.backpackButton}) do
                    if btn and btn.resetModelSkin then btn:resetModelSkin() end
                end
            end
        end
    end
})
Tabs.MMMTab:Button({
    Title = "普通镰刀修改万圣节镰刀",
    Callback = function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "name") == "Scythe" and rawget(v, "subtype") == "knife" then
                v.name = "Spectral Scythe"
                v.subtype = "knife"
                v.permanent = true
                v.unpurchasable = true
                v.canDrop = true
                v.dropCooldown = 120
                v.meleeSlowTime = 0
                v.movespeedAdd = 12
                v.debounce = 0.7
                v.slashAnimName = "saberSlash"
                v.stabAnimName = "saberStab"
                v.swingSound = {name = "scythe", playbackSpeed = 1, variations = 1}
                v.hitSound = {name = "stab", playbackSpeed = 1, variations = 3}
                v.damageTable = {meleeswing = 60, meleemegaswing = 200}
                v.zoneTable = {
                    meleeswing = {size = Vector3.new(6.5,6,5), offset = CFrame.new(0,0,-2.5)},
                    meleemegaswing = {size = Vector3.new(6.5,6,5), offset = CFrame.new(0,0,-2.5)}
                }
                v.stabDamage = 60
                v.itemAnimOffsets = {}
                v.TPSOffsets = {
                    offsetPart = "RightHand",
                    hold = CFrame.new(0, 0, 0) * CFrame.Angles(math.pi, -1.5707963, math.pi)
                }
                v.FPSOffsets = {}
                v.viewportOffsets = {
                    hotbar = {dist = 6, offset = CFrame.new(0,-0.75,0), rotoffset = CFrame.Angles(0,0,0)},
                    ammoHUD = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)},
                    slotButton = {dist = 4, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)}
                }
                break
            end
        end
        for _, item in pairs(require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
            if item.name == "Spectral Scythe" then
                for _, btn in pairs({item.button, item.backpackButton}) do
                    if btn and btn.resetModelSkin then
                        btn:resetModelSkin()
                    end
                end
            end
        end
    end
})

Tabs.MMMTab:Button({
    Title = "普通气球修改黑玫瑰",
    Callback = function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "name") == "Balloon" and rawget(v, "holdableType") == "Balloon" then
                v.name, v.cost, v.unpurchasable, v.multiplier, v.movespeedAdd, v.cannotDiscard = "Black Rose", 200, true, 0.75, 12, true
                if v.TPSOffsets then v.TPSOffsets.hold = CFrame.new(0, 0.5, 0) end
                if v.viewportOffsets and v.viewportOffsets.hotbar then v.viewportOffsets.hotbar.dist = 3 end
                v.canDrop, v.dropCooldown, v.craft = nil
                break
            end
        end

        for _, item in pairs(require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
            if item.name == "Black Rose" then
                for _, btn in pairs({item.button, item.backpackButton}) do
                    if btn and btn.resetModelSkin then btn:resetModelSkin() end
                end
            end
        end
    end
})

Tabs.MMMTab:Button({
Title = "普通气球修改苦无",
Callback = function()
for _, v in pairs(getgc(true)) do
if type(v) == "table" and rawget(v, "name") == "Balloon" and rawget(v, "holdableType") == "Balloon" then
v.name = "Kunai"
v.permanent = true
v.canDrop = true
v.dropCooldown = 120
v.holdableType = "Balloon"
v.movespeedAdd = 12
if v.TPSOffsets then
v.TPSOffsets.hold = CFrame.new(0, -0.3, 0)
else
v.TPSOffsets = {hold = CFrame.new(0, -0.3, 0)}
end
if v.viewportOffsets then
if v.viewportOffsets.hotbar then
v.viewportOffsets.hotbar.dist = 3
v.viewportOffsets.hotbar.offset = CFrame.new(0, 0, 0)
v.viewportOffsets.hotbar.rotoffset = CFrame.Angles(0, 1.5707963, 0)
else
v.viewportOffsets.hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)}
end
if v.viewportOffsets.ammoHUD then
v.viewportOffsets.ammoHUD.dist = 2
v.viewportOffsets.ammoHUD.offset = CFrame.new(-0.1, -0.2, 0)
v.viewportOffsets.ammoHUD.rotoffset = CFrame.Angles(0, -1.3744468, 0)
else
v.viewportOffsets.ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)}
end
if v.viewportOffsets.slotButton then
v.viewportOffsets.slotButton.dist = 1
v.viewportOffsets.slotButton.offset = CFrame.new(-0.1, -0.2, 0)
v.viewportOffsets.slotButton.rotoffset = CFrame.Angles(0, -1.5707963, 0)
else
v.viewportOffsets.slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
end
else
v.viewportOffsets = {
hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)},
ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)},
slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
}
end
break
end
end
for _, item in pairs(require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
if item.name == "Kunai" then
for _, btn in pairs({item.button, item.backpackButton}) do
if btn and btn.resetModelSkin then btn:resetModelSkin() end
end
end
end
end
})

Tabs.MMMTab:Button({
    Title = "苦无修改虚空苦无",
    Callback = function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "name") == "Kunai" and rawget(v, "holdableType") == "Kunai" then
                v.name = "Spirit Kunai"
                v.permanent = true
                v.canDrop = true
                v.dropCooldown = 120
                v.holdableType = "Kunai"
                v.movespeedAdd = 12
                if v.TPSOffsets then
                    v.TPSOffsets.hold = CFrame.new(0, -0.3, 0)
                else
                    v.TPSOffsets = {hold = CFrame.new(0, -0.3, 0)}
                end
                if v.viewportOffsets then
                    if v.viewportOffsets.hotbar then
                        v.viewportOffsets.hotbar.dist = 3
                        v.viewportOffsets.hotbar.offset = CFrame.new(0, 0, 0)
                        v.viewportOffsets.hotbar.rotoffset = CFrame.Angles(0, 1.5707963, 0)
                    else
                        v.viewportOffsets.hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)}
                    end
                    if v.viewportOffsets.ammoHUD then
                        v.viewportOffsets.ammoHUD.dist = 2
                        v.viewportOffsets.ammoHUD.offset = CFrame.new(-0.1, -0.2, 0)
                        v.viewportOffsets.ammoHUD.rotoffset = CFrame.Angles(0, -1.3744468, 0)
                    else
                        v.viewportOffsets.ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)}
                    end
                    if v.viewportOffsets.slotButton then
                        v.viewportOffsets.slotButton.dist = 1
                        v.viewportOffsets.slotButton.offset = CFrame.new(-0.1, -0.2, 0)
                        v.viewportOffsets.slotButton.rotoffset = CFrame.Angles(0, -1.5707963, 0)
                    else
                        v.viewportOffsets.slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
                    end
                else
                    v.viewportOffsets = {
                        hotbar = {dist = 3, offset = CFrame.new(0, 0, 0), rotoffset = CFrame.Angles(0, 1.5707963, 0)},
                        ammoHUD = {dist = 2, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.3744468, 0)},
                        slotButton = {dist = 1, offset = CFrame.new(-0.1, -0.2, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
                    }
                end
                break
            end
        end
        for _, item in pairs(require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).items) do
            if item.name == "Spirit Kunai" then
                for _, btn in pairs({item.button, item.backpackButton}) do
                    if btn and btn.resetModelSkin then
                        btn:resetModelSkin()
                    end
                end
            end
        end
    end
})


Tabs.MMMTab:Toggle({
    Title = "背包枪械美化虚空",
    Value = false,
    Callback = function(start) 
        skinvoid = start
        if skinvoid then
            local it = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory
            local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
            for i, item in next, b1 do 
                if item.type == "Gun" then
                    table.insert(require(game:GetService("ReplicatedStorage").devv.shared.Indicies.skins.bin.Special.Void).compatabilities, item.name)
                    it.skinUpdate(item.name, "Void")
                end
            end
        end
    end
})

Tabs.MMMTab:Toggle({
    Title = "背包枪械美化战术",
    Value = false,
    Callback = function(start) 
        skinvoid = start
        if skinvoid then
            local it = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory
            local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
            for i, item in next, b1 do 
                if item.type == "Gun" then
                    table.insert(require(game:GetService("ReplicatedStorage").devv.shared.Indicies.skins.bin.Special.Void).compatabilities, item.name)
                    it.skinUpdate(item.name, "Tactical")
                end
            end
        end
    end
})

Tabs.MMMTab:Toggle({
    Title = "背包枪械美化赛博",
    Value = false,
    Callback = function(start) 
        skinvoid = start
        if skinvoid then
            local it = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory
            local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
            for i, item in next, b1 do 
                if item.type == "Gun" then
                    table.insert(require(game:GetService("ReplicatedStorage").devv.shared.Indicies.skins.bin.Special.Void).compatabilities, item.name)
                    it.skinUpdate(item.name, "Cyberpunk")
                end
            end
        end
    end
})

Tabs.MMMTab:Toggle({
    Title = "背包枪械美化黑曜石",
    Value = false,
    Callback = function(start) 
        skinvoid = start
        if skinvoid then
            local it = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory
            local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
            for i, item in next, b1 do 
                if item.type == "Gun" then
                    table.insert(require(game:GetService("ReplicatedStorage").devv.shared.Indicies.skins.bin.Special.Void).compatabilities, item.name)
                    it.skinUpdate(item.name, "Obsidian")
                end
            end
        end
    end
})

Tabs.MHTab:Dropdown({
    Title = "选择美化皮肤",
    Values = { 
        "烟火", "虚空", "纯金", "暗物质", "反物质", "神秘", "虚空神秘", "战术", "纯金战术", 
        "白未来", "黑未来", "圣诞未来", "礼物包装", "猩红", "收割者", "虚空收割者", "圣诞玩具",
        "荒地", "隐形", "像素", "钻石像素", "黄金零下", "绿水晶", "生物", "樱花", "精英", 
        "黑樱花", "彩虹激光", "蓝水晶", "紫水晶", "红水晶", "零下", "虚空射线", "冰冻钻石",
        "虚空梦魇", "金雪", "爱国者", "MM2", "声望", "酷化", "蒸汽", "海盗", "玫瑰", "黑玫瑰",
        "激光", "烟花", "诅咒背瓜", "大炮", "财富", "黄金大炮", "四叶草", "自由", "黑曜石", "赛博朋克"
    },
    Callback = function(Value) 
        if Value == "烟火" then
            skinsec = "Sparkler"
        elseif Value == "虚空" then
            skinsec = "Void"
        elseif Value == "纯金" then
            skinsec = "Solid Gold"
        elseif Value == "暗物质" then
            skinsec = "Dark Matter"
        elseif Value == "反物质" then
            skinsec = "Anti Matter"
        elseif Value == "神秘" then
            skinsec = "Hystic"
        elseif Value == "虚空神秘" then
            skinsec = "Void Mystic"
        elseif Value == "战术" then
            skinsec = "Tactical"
        elseif Value == "纯金战术" then
            skinsec = "Solid Gold Tactical"
        elseif Value == "白未来" then
            skinsec = "Future White"
        elseif Value == "黑未来" then
            skinsec = "Future Black"
        elseif Value == "圣诞未来" then
            skinsec = "Christmas Future"
        elseif Value == "礼物包装" then
            skinsec = "Gift Wrapped"
        elseif Value == "猩红" then
            skinsec = "Crimson Blood"
        elseif Value == "收割者" then
            skinsec = "Reaper"
        elseif Value == "虚空收割者" then
            skinsec = "Void Reaper"
        elseif Value == "圣诞玩具" then
            skinsec = "Christmas Toy"
        elseif Value == "荒地" then
            skinsec = "Wasteland"
        elseif Value == "隐形" then
            skinsec = "Invisible"
        elseif Value == "像素" then
            skinsec = "Pixel"
        elseif Value == "钻石像素" then
            skinsec = "Diamond Pixel"
        elseif Value == "黄金零下" then
            skinsec = "Frozen-Gold"
        elseif Value == "绿水晶" then
            skinsec = "Atomic Nature"
        elseif Value == "生物" then
            skinsec = "Biohazard"
        elseif Value == "樱花" then
            skinsec = "Sakura"
        elseif Value == "精英" then
            skinsec = "Elite"
        elseif Value == "黑樱花" then
            skinsec = "Death Blossom-Gold"
        elseif Value == "彩虹激光" then
            skinsec = "Rainbowlaser"
        elseif Value == "蓝水晶" then
            skinsec = "Atomic Water"
        elseif Value == "紫水晶" then
            skinsec = "Atomic Amethyst"
        elseif Value == "红水晶" then
            skinsec = "Atomic Flame"
        elseif Value == "零下" then
            skinsec = "Sub-Zero"
        elseif Value == "虚空射线" then
            skinsec = "Void-Ray"
        elseif Value == "冰冻钻石" then
            skinsec = "Frozen Diamond"
        elseif Value == "虚空梦魇" then
            skinsec = "Void Nightmare"
        elseif Value == "金雪" then
            skinsec = "Golden Snow"
        elseif Value == "爱国者" then
            skinsec = "Patriot"
        elseif Value == "MM2" then
            skinsec = "MM2 Barrett"
        elseif Value == "声望" then
            skinsec = "Prestige Barnett"
        elseif Value == "酷化" then
            skinsec = "Skin Walter"
        elseif Value == "蒸汽" then
            skinsec = "Steampunk"
        elseif Value == "海盗" then
            skinsec = "Pirate"
        elseif Value == "玫瑰" then
            skinsec = "Rose"
        elseif Value == "黑玫瑰" then
            skinsec = "Black Rose"
        elseif Value == "激光" then
            skinsec = "Hyperlaser"
        elseif Value == "烟花" then
            skinsec = "Firework"
        elseif Value == "诅咒背瓜" then
            skinsec = "Cursed Pumpkin"
        elseif Value == "大炮" then
            skinsec = "Cannon"
        elseif Value == "财富" then
            skinsec = "Firework"
        elseif Value == "黄金大炮" then
            skinsec = "Gold Cannon"
        elseif Value == "四叶草" then
            skinsec = "Lucky Clover"
        elseif Value == "自由" then
            skinsec = "Freedom"
        elseif Value == "黑曜石" then
            skinsec = "Obsidian"
        elseif Value == "赛博朋克" then
            skinsec = "Cyberpunk"
        end
    end
})

Tabs.MHTab:Toggle({
    Title = "全部枪械美化",
    Value = false,
    Callback = function(start) 
        autoskin = start
        if autoskin then
            local it = require(game:GetService("ReplicatedStorage").devv).load("v3item").inventory
            local b1 = require(game:GetService('ReplicatedStorage').devv).load('v3item').inventory.items
            for i, item in next, b1 do 
                if item.type == "Gun" then
                    it.skinUpdate(item.name, skinsec)
                end
            end
        end
    end
})

-- 修正后的春节活动标签页
Tabs.ACTab:Toggle({
    Title = "自动灯笼🏮",
    Value = false,
    Callback = function(state)
        lanternEnabled = state
        if state then
            task.spawn(function()
                local plr = game:GetService("Players").LocalPlayer
                local char = plr.Character or plr.CharacterAdded:Wait()
                local root = char:WaitForChild("HumanoidRootPart")
                
                while lanternEnabled do
                    local targetFolder = workspace:FindFirstChild("LunarNewYear")
                    if targetFolder then
                        for _, obj in pairs(targetFolder:GetChildren()) do
                            if not lanternEnabled then break end
                            if obj:IsA("Model") or obj:IsA("BasePart") then
                                local pos
                                if obj:IsA("Model") and obj.PrimaryPart then
                                    pos = obj.PrimaryPart.Position
                                elseif obj:IsA("BasePart") then
                                    pos = obj.Position
                                end
                                if pos then
                                    root.CFrame = CFrame.new(pos)
                                    task.wait(0.5)
                                    local prompt = obj:FindFirstChild("ProximityPrompt", true)
                                    if prompt then
                                        fireproximityprompt(prompt)
                                    end
                                    task.wait(0.5)
                                end
                            end
                        end
                    else
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
})

Tabs.ACTab:Toggle({
    Title = "自动换服农场",
    Value = false,
    Callback = function(state)
        if state then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/MillJackson832/-/refs/heads/main/l"))()
        end
    end
})

Tabs.ACTab:Toggle({
    Title = "自动换服开保险",
    Value = false,
    Callback = function(state)
        if state then
            local player = game:GetService("Players").LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local function getCharacter()
    local char = player.Character
    if not char then
        char = player.CharacterAdded:Wait()
    end
    return char
end

local character = getCharacter()
local HumanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
local humanoid = character:WaitForChild("Humanoid", 10)
local devv, Signal, item
pcall(function()
    devv = require(ReplicatedStorage.devv)
    Signal = devv.load("Signal")
    item = devv.load("v3item")
end)

local scriptStartTime = os.time()
local forbiddenZoneCenter = Vector3.new(352.884155, 13.0287256, -1353.05396)
local forbiddenRadius = 80
local timeoutSeconds = 7 -- 换服
local targetItems = {
     "Helicopter Key", "Wild Horse Key", "Easter Basket", "Diamond Banana Peel", 
    "Nuclear Launcher", "Trident", "Golden Cup", "Pearl Necklace", "Military Armory Keycard"
}

local function createFloatingText()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LYY_HUB_GUI"
    screenGui.Parent = player.PlayerGui
    screenGui.IgnoreGuiInset = true 

    local mainText = Instance.new("TextLabel")
    mainText.Text = "如果没有保险七秒后会自动换服"
    mainText.Size = UDim2.new(0, 300, 0, 30)
    mainText.Position = UDim2.new(0.5, -150, 0.5, -30)
    mainText.BackgroundTransparency = 1
    mainText.TextColor3 = Color3.new(1, 0, 0) 
    mainText.Font = Enum.Font.GothamBold
    mainText.TextSize = 24
    mainText.Parent = screenGui

    local subText1 = Instance.new("TextLabel")
    subText1.Text = "自动换服保险"
    subText1.Size = UDim2.new(0, 200, 0, 20)
    subText1.Position = UDim2.new(0.5, -100, 0.5, 5)
    subText1.BackgroundTransparency = 1
    subText1.TextColor3 = Color3.new(1, 0, 0)
    subText1.Font = Enum.Font.Gotham
    subText1.TextSize = 18
    subText1.Parent = screenGui

    local subText2 = Instance.new("TextLabel")
    subText2.Text = "Yttrium Hub"
    subText2.Size = UDim2.new(0, 400, 0, 20)
    subText2.Position = UDim2.new(0.5, -200, 0.5, 30)
    subText2.BackgroundTransparency = 1
    subText2.TextColor3 = Color3.new(1, 0, 0)
    subText2.Font = Enum.Font.Gotham
    subText2.TextSize = 14
    subText2.Parent = screenGui

    return screenGui
end

local floatingGui = createFloatingText()

local function fetchAvailableServers()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
        ))
    end)
    if not success then return {} end
    local available = {}
    for _, server in ipairs(result.data) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
            table.insert(available, server.id)
        end
    end
    return available
end

local function teleportToRandomServer()
    local servers = fetchAvailableServers()
    if #servers == 0 then
        task.wait(3)
        servers = fetchAvailableServers()
        if #servers == 0 then return end
    end
    local targetServer = servers[math.random(1, #servers)]
    TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer, player)
end

local function autoBuyLockpickLoop()
    while true do
        if character and HumanoidRootPart and Signal then
            pcall(function()
                Signal.InvokeServer("attemptPurchase", "Lockpick")
            end)
        end
        task.wait(2)
    end
end

local function openBankDoor()
    local BankDoor = Workspace:FindFirstChild("BankRobbery") and Workspace.BankRobbery:FindFirstChild("VaultDoor")
    if not BankDoor then return end
    local prompt = BankDoor.Door.Attachment:FindFirstChildOfClass("ProximityPrompt")
    if prompt and prompt.Enabled then
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 20
        HumanoidRootPart.CFrame = CFrame.new(1071.9558, 9, -343.8082)
        task.wait(0.3)
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(0.3)
        pcall(function() prompt:InputHoldEnd() end)
        task.wait(1)
    end
end

local function crackSafes()
    if not item or not item.inventory then return end
    -- 买撬锁
    local hasLockpick = false
    pcall(function()
        for _, v in next, item.inventory.items do
            if v.name == "Lockpick" then
                hasLockpick = true
                return
            end
        end
    end)
    if not hasLockpick then return end

    local targetContainers = {
        Workspace.Game.Entities:FindFirstChild("SmallSafe"),
        Workspace.Game.Entities:FindFirstChild("MediumSafe"),
        Workspace.Game.Entities:FindFirstChild("LargeSafe"),
        Workspace.Game.Entities:FindFirstChild("SmallChest"),
        Workspace.Game.Entities:FindFirstChild("LargeChest")
    }
    for _, container in ipairs(targetContainers) do
        if container then
            for _, obj in ipairs(container:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and (obj.ActionText == "Crack Safe" or obj.ActionText == "Crack Chest") and obj.Enabled then
                    obj.RequiresLineOfSight = false
                    obj.HoldDuration = 0
                    local target = obj.Parent and obj.Parent.Parent
                    if target and target:IsA("BasePart") then
                        HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 2, 2)
                        task.wait(0.5)
                        pcall(function() fireproximityprompt(obj) end)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end

local function autoPickItems()
    while true do
        if os.time() - scriptStartTime >= timeoutSeconds then
            teleportToRandomServer()
            return
        end

        openBankDoor()
        crackSafes()

        local foundItem = false
        local itemPickup = Workspace.Game.Entities:FindFirstChild("ItemPickup")
        if itemPickup then
            for _, itemFolder in pairs(itemPickup:GetChildren()) do
                for _, item in pairs(itemFolder:GetChildren()) do
                    if item:IsA("MeshPart") or item:IsA("Part") then
                        local itemPos = item.Position
                        local distance = (itemPos - forbiddenZoneCenter).Magnitude
                        if distance > forbiddenRadius then
                            for _, child in pairs(item:GetChildren()) do
                                if child:IsA("ProximityPrompt") then
                                    for _, targetName in pairs(targetItems) do
                                        if child.ObjectText == targetName then
                                            foundItem = true
                                            HumanoidRootPart.CFrame = item.CFrame * CFrame.new(0, 2, 0)
                                            child.RequiresLineOfSight = false
                                            child.HoldDuration = 0
                                            pcall(function() fireproximityprompt(child) end)
                                            task.wait(0.3)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        task.wait(0.1)
    end
end

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 10)
    humanoid = newChar:WaitForChild("Humanoid", 10)
    scriptStartTime = os.time()
end)

if Signal then
    task.spawn(autoBuyLockpickLoop)
end
autoPickItems()
        end
    end
})

Tabs.ACTab:Toggle({
    Title = "反挂机",
    Value = false,
    Callback = function(state)
        if state then
            local vu = game:GetService("VirtualUser") game:GetService("Players").LocalPlayer.Idled:connect(function() vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame) wait(1) vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) end) wait(1) local CoreGui = game:GetService("StarterGui") CoreGui:SetCore("SendNotification", { Title = "Yttrium Hub", Text = "反挂机已开启", Duration = 5, })
        end
    end
})


local ItemTab = Window:Tab({
	Title = "物品",
	Icon = "gift"
})
ItemTab:Select()
ItemTab:Paragraph({
	Title = "Yttrium Hub",
	Desc = "物品获取"
})
ItemTab:Paragraph({
	Title = "使用说明",
	Desc = "选择物品后点击按钮即可直接获取"
})
load = require(ReplicatedStorage.devv).load
Signal = load("Signal")
FireServer = Signal.FireServer
InvokeServer = Signal.InvokeServer
v3item = load("v3item")
local inventory = v3item.inventory
local items = {
    "Golden Rose", "Black Rose", "Dollar Balloon", "Admin AK-47",
    "Admin RPG", "Void Gem", "Pulse Rifle", "Money Printer", "Trident",
    "Spirit Kunai", "Spectral Scythe", "Blue Candy Cane", 
    "Diamond Banana Peel", "Diamond Glock", "Kunai", "Easter Basket",
    "Snowflake Balloon", "Dark Matter Gem", "Gold Crown",
    "Heart Crossbow", "NextBot Grenade", "El Fuego",
    "Bat Balloon", "Bunny Balloon", "Clover Balloon", "Ghost Balloon",
    "Gold Clover Balloon", "Heart Balloon", "Skull Balloon",
    "Unusual Money Printer", "Daily Printer"
}
local itemDisplayNames = {
    ["Golden Rose"] = "金玫瑰",
    ["Black Rose"] = "黑玫瑰",
    ["Dollar Balloon"] = "美元气球",
    ["Admin AK-47"] = "管理员黄金AK-47",
    ["Admin RPG"] = "管理员RPG",
    ["Void Gem"] = "虚空宝石",
    ["Pulse Rifle"] = "脉冲步枪",
    ["Money Printer"] = "印钞机",
    ["Trident"] = "三叉戟",
    ["Spirit Kunai"] = "灵魂苦无",
    ["Spectral Scythe"] = "万圣节镰刀",
    ["Blue Candy Cane"] = "蓝色糖果棒",
    ["Diamond Banana Peel"] = "钻石香蕉皮",
    ["Diamond Glock"] = "钻石格洛克",
    ["Kunai"] = "普通苦无",
    ["Easter Basket"] = "复活节篮子",
    ["Snowflake Balloon"] = "雪花气球",
    ["Dark Matter Gem"] = "暗物质宝石",
    ["Gold Crown"] = "黄金皇冠",
    ["Heart Crossbow"] = "爱心弩箭",
    ["NextBot Grenade"] = "NextBot手雷",
    ["El Fuego"] = "火焰喷射器",
    ["Bat Balloon"] = "蝙蝠气球",
    ["Bunny Balloon"] = "兔子气球",
    ["Clover Balloon"] = "幸运草气球",
    ["Ghost Balloon"] = "幽灵气球",
    ["Gold Clover Balloon"] = "黄金幸运草气球",
    ["Heart Balloon"] = "爱心气球",
    ["Skull Balloon"] = "骷髅气球",
    ["Unusual Money Printer"] = "奇怪印钞机",
    ["Daily Printer"] = "每日印钞机"
}
local itemData = {
    ["Golden Rose"] = {
        name = "Golden Rose",guid = "golden_rose_"..tostring(tick()),permanent = true,canDrop = true,
        dropCooldown = 120,multiplier = 0.625,holdableType = "Balloon",movespeedAdd = 5,
        TPSOffsets = {hold = CFrame.new(0, 0.5, 0)},
        viewportOffsets = {hotbar = {dist = 3, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,math.pi/2,0)}}
    },
    ["Black Rose"] = {
        name = "Black Rose",guid = "black_rose_"..tostring(tick()),permanent = true,canDrop = true,
        dropCooldown = 120,multiplier = 0.75,holdableType = "Balloon",movespeedAdd = 12,
        TPSOffsets = {hold = CFrame.new(0, 0.5, 0)},
        viewportOffsets = {hotbar = {dist = 3, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,math.pi/2,0)}}
    },
    ["Dollar Balloon"] = {
        name = "Dollar Balloon",cost = 100000000000,unpurchasable = true,multiplier = 0.8,
        holdableType = "Balloon",movespeedAdd = 8,cannotDiscard = true,
        TPSOffsets = {hold = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0)}
    },
    ["Admin AK-47"] = {
        name = "Admin AK-47",modelName = "Gold AK-47",subtype = "AK-47",adminOnly = true,
        canDrop = false,unpurchasable = true,damage = 10,ammo = 999999999,
        startAmmo = -1,maxAmmo = -1,firemode = "auto",numProjectiles = 8,fireDebounce = 0.01
    },
    ["Admin RPG"] = {
        canDrop = false,unpurchasable = true,name = "Admin RPG",modelName = "RPG",subtype = "RPG",
        adminOnly = true,ammo = 99999999,startAmmo = -1,maxAmmo = -1,reloadTime = 0,
        firemode = "auto",numProjectiles = 1,fireDebounce = 0.02,recoilAdd = 0
    },
    ["Void Gem"] = {
        name = "Void Gem",subtype = "gem",maxAmmo = 3,adminLimit = 1,
        sellPrice = 25000,canDrop = true,dropCooldown = 300
    },
    ["Pulse Rifle"] = {
        name = "Pulse Rifle",subtype = "Raygun",unpurchasable = true,damage = 22,headshotMultiplier = 1.5,ammo = 50,
        startAmmo = -1,maxAmmo = -1,reloadTime = 3.5,reloadType = "mag",firemode = "auto",numProjectiles = 1,fireDebounce = 0.04,
        projectileLength = 20,projectileLifetime = 200,speedDropoff = 0.04,speedMax = 5,
        baseSpread = 3,baseAimSpread = 0.8,spread = 11,aimSpread = 2.4,
        recoilAdd = 0.05,maxRecoil = 0.4,recoilDiminishFactor = 0.95,recoilFastDiminishFactor = 0.85
    },
    ["Money Printer"] = {
        name = "Money Printer",ammo = 1,startAmmo = -1,maxAmmo = 1,adminLimit = 10,
        canDrop = true,dropCooldown = 600,isConsumable = true,permanent = true,
        hint = {computer = "Click to Place",console = "Click to Place"},
        TPSOffsets = {hold = CFrame.new(-0.1, 0, -0.75)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0,0.15,0), rotoffset = CFrame.Angles(0,-math.pi/2,0)},
            ammoHUD = {dist = 3.25, offset = CFrame.new(0,1,0), rotoffset = CFrame.Angles(0,-math.pi/2,0)}
        }
    },
    ["Trident"] = {
        name = "Trident",subtype = "RPG",unpurchasable = true,ammo = 1,startAmmo = 12,
        maxAmmo = 12,firemode = "semi",numProjectiles = 3,fireDebounce = 0.5
    },
    ["Spirit Kunai"] = {
        name = "Spirit Kunai",permanent = true,canDrop = true,dropCooldown = 120,multiplier = 1,holdableType = "Kunai",movespeedAdd = 12,
        TPSOffsets = { hold = CFrame.new(0, 0.5, 0) },
        viewportOffsets = {
            hotbar = { dist = 3, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,math.pi/2,0)},
            ammoHUD = { dist = 2, offset = CFrame.new(-0.1,-0.2,0), rotoffset = CFrame.Angles(0,-1.3744,0)},
            slotButton = { dist = 1, offset = CFrame.new(-0.1,-0.2,0), rotoffset = CFrame.Angles(0,-math.pi/2,0)}
        }
    },
    ["Spectral Scythe"] = {
        name = "Spectral Scythe",subtype = "knife",canDrop = true,dropCooldown = 120,permanent = true,unpurchasable = true,meleeSlowTime = 0,movespeedAdd = 12,debounce = 0.7,
        slashAnimName = "saberSlash",stabAnimName = "saberStab",swingSound = { name = "scythe", playbackSpeed = 1, variations = 1 },hitSound = { name = "stab", playbackSpeed = 1, variations = 3 },
        damageTable = { meleeswing = 60, meleemegaswing = 200 },
        zoneTable = {meleeswing = { size = Vector3.new(6.5,6,5), offset = CFrame.new(0,0,-2.5)},meleemegaswing = { size = Vector3.new(6.5,6,5), offset = CFrame.new(0,0,-2.5)}},
        stabDamage = 60,itemAnimOffsets = {},
        TPSOffsets = {offsetPart = "RightHand",hold = CFrame.new(0, 0, 0) * CFrame.Angles(3.1415927, -1.5707963, 3.1415927)},
        FPSOffsets = {},
        viewportOffsets = {
            hotbar = { dist = 6, offset = CFrame.new(0,-0.75,0), rotoffset = CFrame.Angles(0,0,0)},
            ammoHUD = { dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)},
            slotButton = { dist = 4, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)}
        }
    },
    ["Blue Candy Cane"] = {
        name = "Blue Candy Cane",subtype = "bat",cost = 50,unpurchasable = true,meleeSlowTime = 0,movespeedAdd = 10,canDrop = true,dropCooldown = 120,debounce = 1.2,permanent = true,
        damageTable = { meleeswing = 60, meleemegaswing = 200 },stabDamage = 60,itemAnimOffsets = {},
        TPSOffsets = {offsetPart = "RightHand",hold = CFrame.new(0,1.4,-0.4) * CFrame.Angles(0,1.5707963,0)},
        FPSOffsets = {}
    },
    ["Diamond Banana Peel"] = {
        name = "Diamond Banana Peel",cost = 25,unpurchasable = true,isSticky = true,isTrap = true,canDrop = true,dropCooldown = 120,thrownOffset = CFrame.Angles(0,1.5707963,0),ammo = 1,startAmmo = -1,maxAmmo = 3,health = 50,damage = 5,
        placeSound = "splat",hitSound = "slip",isConsumable = true,ammoPurchaseAmount = 1,ammoPurchaseCost = 30,throwDist = 30,
        TPSOffsets = { hold = CFrame.new(-0.1,0,-0.125) },
        viewportOffsets = {
            hotbar = { dist = 3.25, offset = CFrame.new(0,-0.33,0), rotoffset = CFrame.Angles(0,1.8849556,0)},
            ammoHUD = { dist = 2.5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,1.5707963,0)},
            store = { dist = 2.5, offset = CFrame.new(-1,-0.15,0), rotoffset = CFrame.Angles(0,1.5707963,0)}
        }
    },
    ["Diamond Glock"] = {
        name = "Diamond Glock",modelName = "Diamond Glock",subtype = "Glock",adminLimit = 3,unpurchasable = true,damage = 20,ammo = 13,startAmmo = 252,maxAmmo = 252,sellPrice = 15000
    },
    ["Kunai"] = {
        name = "Kunai",permanent = true,canDrop = true,dropCooldown = 120,multiplier = 1,holdableType = "Kunai",movespeedAdd = 8,
        TPSOffsets = { hold = CFrame.new(0,0.5,0) },
        viewportOffsets = {
            hotbar = { dist = 3, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,math.pi/2,0)},
            ammoHUD = { dist = 2, offset = CFrame.new(-0.1,-0.2,0), rotoffset = CFrame.Angles(0,-1.3744,0)},
            slotButton = { dist = 1, offset = CFrame.new(-0.1,-0.2,0), rotoffset = CFrame.Angles(0,-math.pi/2,0)}
        }
    },
    ["Easter Basket"] = {
        name = "Easter Basket",cost = 20,unpurchasable = true,permanent = true,canDrop = true,dropCooldown = 120,
        TPSOffsets = {hold = CFrame.new(-0.1,-1.25,0.05)},
        viewportOffsets = {
            hotbar = {dist = 3.5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,1.5707963,0)},
            ammoHUD = {dist = 2, offset = CFrame.new(0,0.1,0), rotoffset = CFrame.Angles(0,2.6179939,0)}
        }
    },
    ["Snowflake Balloon"] = {
        name = "Snowflake Balloon",cost = 0,unpurchasable = true,multiplier = 0.625,holdableType = "Balloon",canDrop = true,dropCooldown = 120,permanent = true,
        TPSOffsets = {hold = CFrame.new(0,0,0)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,1.5707963,0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)}
        }
    },
    ["Dark Matter Gem"] = {
        name = "Dark Matter Gem",subtype = "gem",maxAmmo = 3,sellPrice = 50000,adminLimit = 1,canDrop = true,dropCooldown = 600
    },
    ["Gold Crown"] = {
        name = "Gold Crown",subtype = "valuable",maxAmmo = 5,sellPrice = 30000,canDrop = true,dropCooldown = 180
    },
    ["Heart Crossbow"] = {
        name = "Heart Crossbow",subtype = "crossbow",cost = 700,unpurchasable = true,canDrop = true,dropCooldown = 900,adminLimit = 1,damage = 50,ammo = 1,startAmmo = 10,maxAmmo = 20,
        aimingMovespeedPenalty = 0.3,ammoPurchaseAmount = 1,ammoPurchaseCost = 10,reloadTime = 4,reloadType = "mag",firemode = "semi",numProjectiles = 1,fireDebounce = 1,
        guid = "heart_crossbow_"..tostring(tick()),permanent = true,itemAnimOffsets = {},FPSOffsets = {},
        TPSOffsets = {hold = CFrame.new(-0.1,0,-0.75)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0,0.15,0), rotoffset = CFrame.Angles(0,-math.pi/2,0)},
            ammoHUD = {dist = 3.25, offset = CFrame.new(0,1,0), rotoffset = CFrame.Angles(0,math.pi/2,0)}
        }
    },
    ["NextBot Grenade"] = {
        name = "NextBot Grenade",isNade = true,bounceSFX = "nadeBounce",canDrop = true,dropCooldown = 600,thrownOffset = CFrame.Angles(0,math.pi/2,0),ammo = 1,startAmmo = -1,maxAmmo = 1,permanent = true,throwDist = 50,
        TPSOffsets = {hold = CFrame.new(-0.1,0.25,-0.125)},
        viewportOffsets = {
            hotbar = {dist = 2.75, offset = CFrame.new(0,-0.125,0), rotoffset = CFrame.Angles(0,1.8849555921538759,0)},
            ammoHUD = {dist = 2, offset = CFrame.new(0,0.1,0), rotoffset = CFrame.Angles(0,math.pi/2,0)}
        }
    },
    ["El Fuego"] = {
        name = "El Fuego",modelName = "El Fuego",subtype = "Flamethrower",unpurchasable = true,ammo = 600,startAmmo = 0,maxAmmo = 600,reloadTime = 6,reloadType = "mag",firemode = "auto",damage = 6,numProjectiles = 3,fireDebounce = 0.05,
        projectileLength = 4,projectileLifetime = 60,speedDropoff = 0.04,speedMax = 5,baseSpread = 4,baseAimSpread = 2,spread = 12,aimSpread = 6,
        recoilAdd = 0.1,maxRecoil = 1,recoilDiminishFactor = 0.95,recoilFastDiminishFactor = 0.8
    },
    ["Bat Balloon"] = {
        name = "Bat Balloon",cost = 0,unpurchasable = true,multiplier = 0.625,holdableType = "Balloon",canDrop = true,dropCooldown = 120,permanent = true,
        TPSOffsets = {hold = CFrame.new(0,0,0)},
        viewportOffsets = {
            hotbar = {dist = 5.5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,math.pi,0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)}
        }
    },
    ["Bunny Balloon"] = {
        name = "Bunny Balloon",cost = 0,unpurchasable = true,multiplier = 0.61,holdableType = "Balloon",canDrop = true,dropCooldown = 120,permanent = true,
        TPSOffsets = {hold = CFrame.new(0,0,0)},
        viewportOffsets = {
            hotbar = {dist = 4.75, offset = CFrame.new(0,-0.25,0), rotoffset = CFrame.Angles(0,4.71238898038469,0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)}
        }
    },
    ["Clover Balloon"] = {
        name = "Clover Balloon",cost = 200,unpurchasable = true,multiplier = 0.625,holdableType = "Balloon",canDrop = true,dropCooldown = 120,permanent = true,
        TPSOffsets = {hold = CFrame.new(0,0,0)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)}
        }
    },
    ["Ghost Balloon"] = {
        name = "Ghost Balloon",cost = 0,unpurchasable = true,multiplier = 0.625,holdableType = "Balloon",canDrop = true,dropCooldown = 120,permanent = true,
        TPSOffsets = {hold = CFrame.new(0,0,0)},
        viewportOffsets = {
            hotbar = {dist = 3.5, offset = CFrame.new(0,0.5,0), rotoffset = CFrame.Angles(0,math.pi,0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)}
        }
    },
    ["Gold Clover Balloon"] = {
        name = "Gold Clover Balloon",cost = 250000,unpurchasable = true,multiplier = 0.6,holdableType = "Balloon",canDrop = true,dropCooldown = 120,permanent = true,
        TPSOffsets = {hold = CFrame.new(0,0,0)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)}
        }
    },
    ["Heart Balloon"] = {
        name = "Heart Balloon",cost = 200,multiplier = 0.6,holdableType = "Balloon",unpurchasable = true,canDrop = true,dropCooldown = 120,permanent = true,
        TPSOffsets = {hold = CFrame.new(0,0,0)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)}
        }
    },
    ["Skull Balloon"] = {
        name = "Skull Balloon",cost = 0,unpurchasable = true,multiplier = 0.625,holdableType = "Balloon",canDrop = true,dropCooldown = 120,permanent = true,
        TPSOffsets = {hold = CFrame.new(0,0,0)},
        viewportOffsets = {
            hotbar = {dist = 5.5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,-math.pi*1.5,0)},
            ammoHUD = {dist = 5, offset = CFrame.new(0,0,0), rotoffset = CFrame.Angles(0,0,0)}
        }
    },
    ["Unusual Money Printer"] = {
        name = "Unusual Money Printer",cost = 500,ammo = 1,startAmmo = -1,maxAmmo = 1,
        hint = {computer = "Click to Place",console = "Click to Place"},
        canDrop = true,dropCooldown = 600,isConsumable = true,
        TPSOffsets = {hold = CFrame.new(-0.1,0,-0.75)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0,0.15,0), rotoffset = CFrame.Angles(0,-math.pi/2,0)},
            ammoHUD = {dist = 3.25, offset = CFrame.new(0,1,0), rotoffset = CFrame.Angles(0,math.pi/2,0)}
        }
    },
    ["Daily Printer"] = {
        name = "Daily Printer",ammo = 1,startAmmo = -1,maxAmmo = 1,adminLimit = 10,
        hint = {computer = "Click to Place",console = "Click to Place"},
        isConsumable = true,permanent = true,subtype = "printer",cost = 0,
        unpurchasable = true,canDrop = true,dropCooldown = 900,itemAnimOffsets = {},
        FPSOffsets = {},TPSOffsets = {hold = CFrame.new(-0.1, 0, -0.75) * CFrame.Angles(0, 0, 0)},
        viewportOffsets = {
            hotbar = {dist = 5, offset = CFrame.new(0, 0.15, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)},
            ammoHUD = {dist = 3.25, offset = CFrame.new(0, 1, 0), rotoffset = CFrame.Angles(0, -1.5707963, 0)}
        }
    }
}
local function getItemList()
    local itemList = {}
    for _, itemName in ipairs(items) do
        table.insert(itemList, itemDisplayNames[itemName] or itemName)
    end
    return itemList
end
local selectedItem = getItemList()[1]
ItemTab:Dropdown({
    Title = "选择物品",
    Desc = "请选择需要获取的物品",
    Values = getItemList(),
    Value = selectedItem,
    Callback = function(value)
        if value and value ~= "" then
            selectedItem = value
        end
    end
})
local function getItemNameByDisplayName(displayName)
    for itemName, dispName in pairs(itemDisplayNames) do
        if dispName == displayName then
            return itemName
        end
    end
    return displayName
end
local function playSound()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9047002353"
        sound.Volume = 0.3
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 2)
    end)
end
local function addItem(itemName)
    pcall(function()
        if not itemData[itemName] then
            WindUI:Notify({
                Title = "错误",
                Content = "物品数据不存在！",
                Duration = 2,
                Icon = "warning"
            })
            return
        end
        local itemConfig = itemData[itemName]
        local itemToAdd = {}
        for k, v in pairs(itemConfig) do
            itemToAdd[k] = v
        end
        if not itemToAdd.guid then
            itemToAdd.guid = itemName:lower():gsub(" ", "_").."_"..tostring(tick())
        end
        if inventory.add then
            inventory.add(itemToAdd, false)
            if inventory.currentItemsData then
                table.insert(inventory.currentItemsData, itemToAdd)
            end
        end
        if inventory.rerender then
            inventory:rerender()
        end
        WindUI:Notify({
            Title = "获取成功",
            Content = "已获得：" .. (itemDisplayNames[itemName] or itemName),
            Duration = 2,
            Icon = "check",
            Color = Color3.fromHex("00FF00")
        })
        playSound()
    end)
end
ItemTab:Button({
    Title = "免费获取选中物品",
    Icon = "gift",
    Size = UDim2.new(1, -20, 0, 40),
    Callback = function()
        if selectedItem and selectedItem ~= "" then
            local itemName = getItemNameByDisplayName(selectedItem)
            if itemName then
                addItem(itemName)
            end
        else
            WindUI:Notify({
                Title = "提示",
                Content = "请先选择需要获取的物品！",
                Duration = 2,
                Icon = "warning"
            })
        end
    end
})
ItemTab:Dropdown({
    Title = "选择光剑",
    Desc = "请选择需要获取的光剑",
    Values = (function()
        local list = {}
        local f = game:GetService("ReplicatedStorage").devv.shared.Indicies.v3items.bin.Melee
        for _,v in pairs(f:GetChildren())do
            pcall(function()
                local i = require(v)
                if i.name and i.name:find("Saber",1,true)then
                    table.insert(list,i.name)
                end
            end)
        end
        return list
    end)(),
    Value = "",
    Callback = function(v)
        getfenv().selectedItem = v
    end
})
ItemTab:Button({
    Title = "获取选中的光剑",
    Desc = "",
    Callback = function()
        local sel = getfenv().selectedItem
        if not sel or sel == "" then return end
        local rs = game:GetService("ReplicatedStorage")
        local itemSys = require(rs.devv).load("v3item")
        local inv = itemSys.inventory
        local f = rs.devv.shared.Indicies.v3items.bin.Melee
        pcall(function()
            local mod = f:FindFirstChild(sel)
            if mod and mod:IsA("ModuleScript")then
                local d = require(mod)
                local it = {
                    name = d.name,
                    guid = d.name:gsub("%s","_"):lower().."_"..tick(),
                    modelName = d.modelName or d.name,
                    subtype = d.subtype or "saber",
                    canDrop = false,
                    cannotDiscard = true,
                    permanent = true,
                    unpurchasable = true,
                    TPSOffsets = d.TPSOffsets or {},
                    viewportOffsets = d.viewportOffsets or {}
                }
                if inv.add then inv.add(it,false)end
                if inv.currentItemsData then table.insert(inv.currentItemsData,it)end
                if inv.rerender then inv:rerender()end
            end
        end)
    end
})

local function getAllBalloons()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    pcall(function()
        local itemSystem = require(ReplicatedStorage.devv).load("v3item")
        local inventory = itemSystem.inventory
        
        local fistsItem = nil
        for guid, item in pairs(inventory.items) do
            if item.name == "Fists" then
                fistsItem = item
                break
            end
        end
        
        local hdir = ReplicatedStorage.devv.shared.Indicies.v3items.bin.Holdable
        if hdir then
            for _, hmd in pairs(hdir:GetChildren()) do
                if hmd:IsA("ModuleScript") then
                    pcall(function()
                        local hdat = require(hmd)
                        if hdat and hdat.name and hdat.holdableType == "Balloon" then
                            local hnew = {
                                name = hdat.name,
                                guid = hdat.name:gsub("%s", "_"):lower() .. "_" .. tostring(tick()),
                                modelName = hdat.modelName or hdat.name,
                                holdableType = "Balloon",
                                multiplier = hdat.multiplier or 0.5,
                                movespeedAdd = hdat.movespeedAdd or 0,
                                canDrop = false,
                                cannotDiscard = true,
                                permanent = true,
                                unpurchasable = true,
                                TPSOffsets = hdat.TPSOffsets or {},
                                viewportOffsets = hdat.viewportOffsets or (fistsItem and fistsItem.viewportOffsets)
                            }
                            if inventory.add then
                                inventory.add(hnew, false)
                                if inventory.currentItemsData then
                                    table.insert(inventory.currentItemsData, hnew)
                                end
                            end
                        end
                    end)
                end
            end
        end
        
        if fistsItem then
            local fistsCopy = {
                name = "Fists",
                guid = "fists_copy_" .. tostring(tick()),
                permanent = true,
                cannotDiscard = true,
                doMakeModel = false,
                debounce = 0.3,
                damageTable = {
                    meleepunch = 15,
                    meleemegapunch = 200,
                    meleekick = 20,
                    meleejumpKick = 20
                },
                viewportOffsets = fistsItem.viewportOffsets,
                TPSOffsets = fistsItem.TPSOffsets or {},
                FPSOffsets = fistsItem.FPSOffsets or {}
            }
            if inventory.add then
                inventory.add(fistsCopy, false)
            end
        end
        
        if inventory.rerender then
            inventory:rerender()
        end
    end)
end

ItemTab:Button({Title = "获取所有气球", Callback = getAllBalloons})
ItemTab:Button({
    Title = "获取所有光剑",
    Callback = function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    local itemSystem = require(ReplicatedStorage.devv).load("v3item")
    local inventory = itemSystem.inventory
    local hdir = ReplicatedStorage.devv.shared.Indicies.v3items.bin.Melee
    if hdir then
        for _, hmd in pairs(hdir:GetChildren()) do
            if hmd:IsA("ModuleScript") then
                pcall(function()
                    local hdat = require(hmd)
                    -- 核心筛选：名称包含Saber（不区分大小写），只刷光剑
                    if hdat and hdat.name and hdat.name:find("Saber", 1, true) then
                        local snew = {
                            name = hdat.name,
                            guid = hdat.name:gsub("%s", "_"):lower() .. "_" .. tostring(tick()),
                            modelName = hdat.modelName or hdat.name,
                            subtype = hdat.subtype or "saber",
                            canDrop = false,
                            cannotDiscard = true,
                            permanent = true,
                            unpurchasable = true,
                            TPSOffsets = hdat.TPSOffsets or {},
                            viewportOffsets = hdat.viewportOffsets or {}
                        }
                        if inventory.add then
                            inventory.add(snew, false)
                        end
                        if inventory.currentItemsData then
                            table.insert(inventory.currentItemsData, snew)
                        end
                    end
                end)
            end
        end
    end
    if inventory.rerender then
        inventory:rerender()
    end
end)

    end
})


local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local devv = require(ReplicatedStorage.devv)
local melee = devv.load("ClientReplicator")

local function sendNotify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

Tabs.FfTab:Toggle({
    Title = "防管理",
    Default = false,
    Callback = function(Value)
        if Value then
            sendNotify("功能启动", "防管理 已开启")
            task.spawn(function()
                while Value and task.wait(0.1) do
                    local Players = game:GetService("Players")
                    local lp = Players.LocalPlayer
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= lp then
                            if 
                                v.Name == "FEARLESS4654" or
                                v.Name == "jbear314" or
                                v.Name == "amogus12342920" or
                                v.Name == "kumamikan1" or
                                v.Name == "RedRubyyy611" or
                                v.Name == "whyrally" or
                                v.Name == "Davydevv" or
                                v.Name == "HagahZet" or
                                v.Name == "alvis220" or
                                v.Name == "na3k7" or
                                v.Name == "KardenaLUSA1" or
                                v.Name == "fakest_reallty" or
                                v.Name == "Mikejeck6" or
                                v.Name == "Bogdanpro55555" or
                                v.Name == "Suponjibobu00" or
                                v.Name == "Realsigmadeepseek" 
                            then
                                lp:Kick("[Yttrium Hub] 反管理踢出 管理员用户名为: " .. v.Name)
                            end
                        end
                    end
                end
            end)
        end
    end
})Tabs.FfTab:Button({
    Title = "反吸人",
    Callback = function()
        local Yttrium_Players = game:GetService("Players")
local Yttrium_LocalPlayer = Yttrium_Players.LocalPlayer

local function Yttrium_ForceStand()
    local Yttrium_Character = Yttrium_LocalPlayer.Character
    if not Yttrium_Character then return end
    
    local Yttrium_Humanoid = Yttrium_Character:FindFirstChildOfClass("Humanoid")
    local Yttrium_HRP = Yttrium_Character:FindFirstChild("HumanoidRootPart")
    
    if not Yttrium_Humanoid or not Yttrium_HRP or Yttrium_Humanoid.Health <= 0 then
        return
    end
    
    if Yttrium_Humanoid:GetState() == Enum.HumanoidStateType.Seated then
        Yttrium_Humanoid.Sit = false
        Yttrium_Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    
    for _, Yttrium_Seat in ipairs(workspace:GetDescendants()) do
        if Yttrium_Seat:IsA("Seat") and Yttrium_Seat.Occupant == Yttrium_Humanoid then
            Yttrium_Seat.Occupant = nil
        end
    end
end

Yttrium_ForceStand()

    end
})
Tabs.FfTab:Toggle({
    Title = "防虚空",
    Default = false,
    Callback = function(Value)
        AutoAntiVoid = Value
        if Value then
            sendNotify("功能启动", "防虚空 已开启")
            task.spawn(function()
                while AutoAntiVoid do
                    local character = game:GetService("Players").LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        local position = humanoidRootPart.Position
                        if position.Y < -200 then
                            humanoidRootPart.CFrame = CFrame.new(1156.01, -40.29, 192.84)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

Tabs.FfTab:Toggle({
    Title = "反直立",
    Default = false,
    Callback = function(Value)
        AutoKnockReset = Value
        if Value then
            sendNotify("功能启动", "反直立 已开启")
            task.spawn(function()
                while AutoKnockReset do
                    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                        melee.Set(lp, "knocked", false)
                        melee.Replicate("knocked")
                    end
                    task.wait()
                end
            end)
        end
    end
})

Tabs.FfTab:Toggle({
    Title = "反击退",
    Default = false,
    Callback = function(Value)
        antiKBEnabled = Value
        if Value then
            sendNotify("功能启动", "反击退 已开启")
            task.spawn(function()
                while antiKBEnabled and task.wait(0.1) do
                    local character = game:GetService("Players").LocalPlayer.Character
                    if character then
                        for _, part in ipairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    end
})

Tabs.FfTab:Toggle({
    Title = "防抓取",
    Value = false,
    Callback = function(state)
        local antiGrab = state
        if antiGrab then
            sendNotify("功能启动", "防抓取 已开启")
            task.spawn(function()
                local ClientReplicator = devv.load("ClientReplicator")
                while antiGrab do
                    if ClientReplicator.Get(LocalPlayer, "carried") == true then
                        ClientReplicator.Set(LocalPlayer, "carried", false)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

Tabs.FfTab:Toggle({
    Title = "防倒地",
    Value = false,
    Callback = function(state)
        local antiRagdoll = state
        if antiRagdoll then
            sendNotify("功能启动", "防倒地 已开启")
            task.spawn(function()
                while antiRagdoll do
                    if LocalPlayer:GetAttribute("isRagdoll") == true then
                        local ClientRagdoll = devv.load("ClientRagdoll")
                        ClientRagdoll.SetRagdoll(LocalPlayer, false)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

Tabs.FfTab:Toggle({
    Title = "防一拳",
    Value = false,
    Callback = function(state)
        local silentBlock = state
        if silentBlock then
            sendNotify("功能启动", "防一拳 已开启")
            task.spawn(function()
                local ClientReplicator = devv.load("ClientReplicator")
                while silentBlock do
                    if ClientReplicator.Get(LocalPlayer, "blocking") == false then
                        ClientReplicator.Set(LocalPlayer, "blocking", true)
                        ClientReplicator.Replicate("blocking")
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

Tabs.FfTab:Toggle({
    Title = "防甩飞",
    Default = false,
    Callback = function(Value)
        if Value then
            sendNotify("功能启动", "防甩飞 已开启")
            task.spawn(function()
                while Value and task.wait(0.1) do
                    local character = game:GetService("Players").LocalPlayer.Character
                    if character then
                        for _, part in ipairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    end
})

Tabs.FfTab:Toggle({
    Title = "防坐下",
    Default = false,
    Callback = function(Value)
        if Value then
            sendNotify("功能启动", "防坐下 已开启")
            task.spawn(function()
                while Value and task.wait(0.1) do
                    local character = game:GetService("Players").LocalPlayer.Character
                    if character and character:FindFirstChild("Humanoid") then
                        local humanoid = character.Humanoid
                        if humanoid:GetState() == Enum.HumanoidStateType.Seated then
                            humanoid.Sit = false
                            humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end
                    end
                end
            end)
        end
    end
})
Tabs.TeTraXTab:Paragraph({
    Title = "TeTraX\u{e000}",
    Desc = "同款功能",
    Image = "star",
    ImageSize = 42,
})

Tabs.TeTraXTab:Toggle({
    Title = "珠宝箱农场(稀有宝石)",
    Value = false,
    Callback = function(state)
        getgenv().AutoFarmRareJewelry = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        while task.wait(0.5) do
            if not getgenv().AutoFarmRareJewelry then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local gameFolder = game.Workspace:FindFirstChild("Game")
            if not gameFolder then return end
            local entities = gameFolder:FindFirstChild("Entities")
            if not entities then return end

            local jewelSafes = entities:FindFirstChild("JewelSafe")
            if jewelSafes then
                for _, safe in pairs(jewelSafes:GetChildren()) do
                    if safe.PrimaryPart then
                        rootPart.CFrame = safe.PrimaryPart.CFrame + Vector3.new(0, 2, 0)
                        local prompt = safe:FindFirstChild("ProximityPrompt", true)
                        if prompt then
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end

            local goldJewelSafes = entities:FindFirstChild("GoldJewelSafe")
            if goldJewelSafes then
                for _, safe in pairs(goldJewelSafes:GetChildren()) do
                    if safe.PrimaryPart then
                        rootPart.CFrame = safe.PrimaryPart.CFrame + Vector3.new(0, 2, 0)
                        local prompt = safe:FindFirstChild("ProximityPrompt", true)
                        if prompt then
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.TeTraXTab:Toggle({
    Title = "珠宝箱农场(所有宝石)",
    Value = false,
    Callback = function(state)
        getgenv().AutoFarmAllJewelry = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        while task.wait(0.5) do
            if not getgenv().AutoFarmAllJewelry then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local gameFolder = game.Workspace:FindFirstChild("Game")
            if not gameFolder then return end
            local entities = gameFolder:FindFirstChild("Entities")
            if not entities then return end

            local jewelCases = entities:FindFirstChild("JewelryCase")
            if jewelCases then
                for _, box in pairs(jewelCases:GetChildren()) do
                    if box:FindFirstChild("ProximityPrompt") then
                        rootPart.CFrame = box.CFrame + Vector3.new(0, 2, 0)
                        local prompt = box.ProximityPrompt
                        prompt.RequiresLineOfSight = false
                        prompt.HoldDuration = 0
                        task.wait(0.05)
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        else
                            firesignal(prompt.Triggered)
                        end
                    end
                end
            end

            local jewelSafes = entities:FindFirstChild("JewelSafe")
            if jewelSafes then
                for _, safe in pairs(jewelSafes:GetChildren()) do
                    if safe.PrimaryPart then
                        rootPart.CFrame = safe.PrimaryPart.CFrame + Vector3.new(0, 2, 0)
                        local prompt = safe:FindFirstChild("ProximityPrompt", true)
                        if prompt then
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end

            local goldJewelSafes = entities:FindFirstChild("GoldJewelSafe")
            if goldJewelSafes then
                for _, safe in pairs(goldJewelSafes:GetChildren()) do
                    if safe.PrimaryPart then
                        rootPart.CFrame = safe.PrimaryPart.CFrame + Vector3.new(0, 2, 0)
                        local prompt = safe:FindFirstChild("ProximityPrompt", true)
                        if prompt then
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.TeTraXTab:Toggle({
    Title = "宝藏物品",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickTreasure = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Treasure Map",
            "Pearl Necklace",
            "Seashell",
            "Purple Seashell",
            "Blue Seashell"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickTreasure then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.TeTraXTab:Toggle({
    Title = "组件箱",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickComponent = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Component Box"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickComponent then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.TeTraXTab:Toggle({
    Title = "黄金枪械",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickGoldGun = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Gold AK-47",
            "Gold Deagle"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickGoldGun then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.TeTraXTab:Toggle({
    Title = "礼物/幸运方块",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickPresent = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Small Present",
            "Medium Present",
            "Large Present",
            "Gold Lucky Block",
            "Orange Lucky Block",
            "Purple Lucky Block",
            "Green Lucky Block",
            "Red Lucky Block",
            "Blue Lucky Block"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickPresent then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.TeTraXTab:Toggle({
    Title = "稀有宝石",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickRareGem = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Diamond",
            "Diamond Ring",
            "Diamond Ore",
            "Rollie",
            "Dark Matter Gem",
            "Void Gem",
            "Gold Cup",
            "Gold Crown"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickRareGem then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.TeTraXTab:Toggle({
    Title = "超稀有物品",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickVeryRare = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Dollar Balloon",
            "Heart Crossbow",
            "Void Gem",
            "Diamond",
            "Nuclear Missile Launcher", 
            "NextBot Grenade",
            "Rollie",
            "Gold Crown",
            "Dark Matter Gem",
            "Diamond Glock",
            "Diamond Banana Peel",
            "Spirit Kunai",
            "Kunai",
            "Purple Lucky Block",
            "Snowflake Balloon",
            "Suitcase Nuke",
            "Nuke Launcher",
            "Easter Basket",
            "Gold Cup",
            "Pearl Necklace",
            "Treasure Map",
            "Spectral Scythe",
            "Bunny Balloon",
            "Ghost Balloon",
            "Clover Balloon",
            "Bat Balloon",
            "Gold Clover Balloon",
            "Golden Rose",
            "Black Rose",
            "Heart Balloon",
            "Skull Balloon",
            "Candy Cane",
            "Easter Basket",
            "Diamond Glock",
            "Clover Balloon",
            "Heart Balloon",
            "Ghost Balloon",
            "Nuke Case",
            "NextBot Grenade",
            "Pulse Rifle",
            "Trident",
            "El Fuego"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickVeryRare then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.TeTraXTab:Toggle({
    Title = "蓝卡",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickBlueCard = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Police Armory Keycard"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickBlueCard then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.TeTraXTab:Toggle({
    Title = "红卡",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickRedCard = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Military Armory Keycard"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickRedCard then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.TeTraXTab:Toggle({
    Title = "印钞机",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickPrinter = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Money Printer"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickPrinter then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.TeTraXTab:Toggle({
    Title = "金条",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickGoldBar = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Gold Bar"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickGoldBar then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.TeTraXTab:Toggle({
    Title = "音箱",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickBoombox = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Boombox"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickBoombox then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})

Tabs.TeTraXTab:Toggle({
    Title = "车辆钥匙",
    Value = false,
    Callback = function(state)
        getgenv().AutoPickCarKey = state

        if not state then
            return
        end

        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local targetItems = {
            "Mustang Key",
            "Cruiser Key",
            "Helicopter Key",
            "Airdrop Marker"
        }

        while task.wait(0.1) do
            if not getgenv().AutoPickCarKey then
                break
            end

            if not rootPart or not rootPart:IsDescendantOf(game) then
                character = localPlayer.Character
                rootPart = character:WaitForChild("HumanoidRootPart")
            end

            local itemFolder = game.Workspace:FindFirstChild("Game")
            if not itemFolder then return end
            local entities = itemFolder:FindFirstChild("Entities")
            if not entities then return end
            local itemPickup = entities:FindFirstChild("ItemPickup")
            if not itemPickup then return end

            for _, l in pairs(itemPickup:GetChildren()) do
                for _, v in pairs(l:GetChildren()) do
                    if v:IsA("MeshPart") or v:IsA("Part") then
                        local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                        if prompt and table.find(targetItems, prompt.ObjectText) then
                            rootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                            prompt.RequiresLineOfSight = false
                            prompt.HoldDuration = 0
                            task.wait(0.05)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                firesignal(prompt.Triggered)
                            end
                        end
                    end
                end
            end
        end
    end
})
Tabs.ServerTab:Button({
    Title = "重新加入当前服务器",
    Callback = function()
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        if game.PlaceId and game.JobId then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
        end
    end
})

Tabs.ServerTab:Button({
    Title = "切换至低人数服务器",
    Callback = function()
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer
        pcall(function()
            local Servers = game:GetService("HttpService"):JSONDecode(game:HttpGet(string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", game.PlaceId))).data
            for _, v in pairs(Servers) do
                if v.id ~= game.JobId and v.playing < v.maxPlayers and v.playing > 0 then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id, localPlayer)
                    break
                end
            end
        end)
    end
})
Tabs.ServerTab:Paragraph({
    Title = "当前服务器ID",
    Desc = game.JobId,
    Buttons = {{
        Title = "Copy",
        Callback = function()
            setclipboard(game.JobId);
        end
    }}
});
Tabs.ServerTab:Input({
    Title = "输入服务器ID",
    Callback = function(value)
        _G.JobId = value;
    end
});
Tabs.ServerTab:Button({
    Title = "加入服务器ID",
    Callback = function()
        (game:GetService("TeleportService")):TeleportToPlaceInstance(game.PlaceId, _G.JobId);
    end
})
local AimbotConfig = {
    Enabled = false,
    WallCheck = true,
    PredictAim = false,
    PredictValue = 1.5,
    AimPart = "Head",
    Radius = 200,
    CheckShield = true,
    AimMode = "Camera"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local aimConnection = nil

local function hasShieldProtection(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    for _, desc in pairs(player.Character:GetDescendants()) do
        if desc:IsA("ForceField") or desc.Name:lower():find("shield") then
            return true
        end
    end
    return false
end

local function getNearestTarget()
    local nearest = nil
    local minDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end

        local char = plr.Character
        if not char or not char:FindFirstChild(AimbotConfig.AimPart) or not char:FindFirstChild("Humanoid") then continue end
        if char.Humanoid.Health <= 0 then continue end

        if AimbotConfig.CheckShield and hasShieldProtection(plr) then
            continue
        end

        local worldPos = char[AimbotConfig.AimPart].Position
        local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)

        local dist
        if AimbotConfig.AimMode == "Camera" then
            if not onScreen then continue end
            dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if dist > AimbotConfig.Radius then continue end
        else
            dist = (worldPos - Camera.CFrame.Position).Magnitude
        end

        if AimbotConfig.WallCheck then
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local ray = workspace:Raycast(Camera.CFrame.Position, worldPos - Camera.CFrame.Position, rayParams)
            local canSee = ray and ray.Instance and ray.Instance:IsDescendantOf(char)
            if not canSee then continue end
        end

        if AimbotConfig.PredictAim then
            worldPos = worldPos + char[AimbotConfig.AimPart].Velocity * AimbotConfig.PredictValue / 10
        end

        if dist < minDist then
            minDist = dist
            nearest = {Part = char[AimbotConfig.AimPart], WorldPos = worldPos}
        end
    end
    return nearest
end

Tabs.LockTab:Toggle({
    Title = "自瞄开关",
    Default = false,
    Callback = function(Value)
        AimbotConfig.Enabled = Value

        if aimConnection then
            aimConnection:Disconnect()
            aimConnection = nil
        end

        if Value then
            aimConnection = RunService.RenderStepped:Connect(function()
                if not AimbotConfig.Enabled then return end
                local tar = getNearestTarget()
                if tar and Camera then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, tar.WorldPos)
                end
            end)
        end
    end
})

Tabs.LockTab:Toggle({
    Title = "墙壁检测",
    Default = true,
    Callback = function(Value)
        AimbotConfig.WallCheck = Value
    end
})

Tabs.LockTab:Toggle({
    Title = "预判自瞄",
    Default = false,
    Callback = function(Value)
        AimbotConfig.PredictAim = Value
    end
})

Tabs.LockTab:Slider({
    Title = "预判倍数",
    Desc = "预判强度",
    Value = {
        Min = 0.1,
        Max = 5,
        Default = 1.5
    },
    Callback = function(Value)
        AimbotConfig.PredictValue = Value
    end
})

Tabs.LockTab:Dropdown({
    Title = "瞄准部位",
    Values = {
        "头部",
        "身体"
    },
    Default = "头部",
    Callback = function(Value)
        if Value == "头部" then
            AimbotConfig.AimPart = "Head"
        elseif Value == "身体" then
            AimbotConfig.AimPart = "UpperTorso"
        end
    end
})

Tabs.LockTab:Toggle({
    Title = "护盾检测",
    Default = true,
    Callback = function(Value)
        AimbotConfig.CheckShield = Value
    end
})

Tabs.LockTab:Dropdown({
    Title = "瞄准模式",
    Values = {
        "相机瞄准",
        "最近瞄准"
    },
    Default = "相机瞄准",
    Callback = function(Value)
        if Value == "相机瞄准" then
            AimbotConfig.AimMode = "Camera"
        elseif Value == "最近瞄准" then
            AimbotConfig.AimMode = "Nearest"
        end
    end
})
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local BulletConfig = {
    Enabled = false,
    CheckShield = false,
    CheckFriend = false,
    ShootPart = "Head",
    ShootMode = "Camera",
    Radius = 300
}

local bulletTrackingHook = nil

local function hasShield(char)
    if not char then return false end
    if char:FindFirstChildOfClass("ForceField") then return true end
    for _, d in pairs(char:GetDescendants()) do
        if d.Name:lower():find("shield") then return true end
    end
    return false
end

local function isFriend(plr)
    return LocalPlayer:IsFriendsWith(plr.UserId)
end

local function getTarget()
    local target = nil
    local minDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end

        local part = char:FindFirstChild(BulletConfig.ShootPart)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not part or not hum or hum.Health <= 0 then continue end

        if BulletConfig.CheckShield and hasShield(char) then
            continue
        end

        if BulletConfig.CheckFriend and isFriend(plr) then
            continue
        end

        local wp = part.Position
        local sp, os = Camera:WorldToViewportPoint(wp)
        local dist = (wp - Camera.CFrame.Position).Magnitude

        if BulletConfig.ShootMode == "Camera" then
            if not os then continue end
            local sdist = (Vector2.new(sp.X,sp.Y)-center).Magnitude
            if sdist > BulletConfig.Radius then continue end
        end

        if dist < minDist then
            minDist = dist
            target = part
        end
    end
    return target
end

Tabs.RaybotTab:Toggle({
    Title = "子弹追踪",
    Default = false,
    Callback = function(Value)
        BulletConfig.Enabled = Value

        if bulletTrackingHook then
            hookmetamethod(game, "__namecall", bulletTrackingHook)
            bulletTrackingHook = nil
        end

        if Value then
            bulletTrackingHook = hookmetamethod(game, "__namecall", function(self,...)
                local m = getnamecallmethod()
                local args = {...}
                if m == "Raycast" and not checkcaller() then
                    local origin = args[1] or Camera.CFrame.Position
                    local tar = getTarget()
                    if tar then
                        return {
                            Instance = tar,
                            Position = tar.Position,
                            Normal = (origin-tar.Position).Unit,
                            Material = Enum.Material.Plastic,
                            Distance = (tar.Position-origin).Magnitude
                        }
                    end
                end
                return bulletTrackingHook(self,...)
            end)
        end
    end
})

Tabs.RaybotTab:Toggle({
    Title = "护盾检测",
    Default = false,
    Callback = function(Value)
        BulletConfig.CheckShield = Value
    end
})

Tabs.RaybotTab:Toggle({
    Title = "好友检测",
    Default = false,
    Callback = function(Value)
        BulletConfig.CheckFriend = Value
    end
})

Tabs.RaybotTab:Dropdown({
    Title = "射击部位",
    Values = {"头部","身体"},
    Default = "头部",
    Callback = function(Value)
        BulletConfig.ShootPart = Value == "头部" and "Head" or "UpperTorso"
    end
})

Tabs.RaybotTab:Dropdown({
    Title = "射击方式",
    Values = {"相机判断","最近判断"},
    Default = "相机判断",
    Callback = function(Value)
        BulletConfig.ShootMode = Value == "相机判断" and "Camera" or "Nearest"
    end
})


Tabs.ShujuTab:Section({
    Title = "当前钱数 " .. require(game:GetService("ReplicatedStorage").devv.datum.state).data.money,
})
Tabs.ShujuTab:Section({
    Title = "历史总钱数 " .. require(game:GetService("ReplicatedStorage").devv.datum.state).data.totalMoneyEarned,
})
Tabs.ShujuTab:Section({
    Title = "当前Robux花费 " .. require(game:GetService("ReplicatedStorage").devv.datum.state).data.robuxSpent,
})
Tabs.ShujuTab:Section({
    Title = "ATM抢劫金钱 " .. require(game:GetService("ReplicatedStorage").devv.datum.state).data.atmsRobbed,
})
Tabs.ShujuTab:Section({
    Title = "宝石抢劫金钱 " .. require(game:GetService("ReplicatedStorage").devv.datum.state).data.gemsRobbed,
})
Tabs.ShujuTab:Section({
    Title = "历史最高连续登陆 " .. require(game:GetService("ReplicatedStorage").devv.datum.state).data.topLoginStreak,
})
Tabs.ShujuTab:Section({
    Title = "工作赚钱金钱 " .. require(game:GetService("ReplicatedStorage").devv.datum.state).data.jobEarnings,
})

Tabs.MeiTab:Button({
    Title = "无头",
    Callback = function()
        local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function setHeadInvisible(char)
    local function hideHead()
        local head = char:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            for _, v in pairs(head:GetChildren()) do
                if v:IsA("Decal") then v:Destroy() end
            end
        end
    end
    hideHead()
    char.ChildAdded:Connect(function(child)
        if child.Name == "Head" then
            task.wait(0.01)
            child.Transparency = 1
            for _, v in pairs(child:GetChildren()) do
                if v:IsA("Decal") then v:Destroy() end
            end
        end
    end)
end

if LocalPlayer.Character then setHeadInvisible(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setHeadInvisible)

    end
})
Tabs.MeiTab:Button({
    Title = "紫色特效",
    Callback = function()
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local trailEnabled = true
local glowPart = nil
local lastWavePoints = {}

getgenv().TrailConfig = {
    Color1 = Color3.fromRGB(200, 180, 255),
    Color2 = Color3.fromRGB(160, 130, 230),
    Color3 = Color3.fromRGB(140, 100, 220),
    WaveCount = 10,
    WaveAmplitude = 2.5,
    TrailLength = 18,
    FadeSpeed = 0.1,
    GlowBrightness = 7,
    GlowRange = 5,
    ParticleRate = 300,
    ParticleSize = 1.2,
    CoreParticleRate = 400,
    CoreParticleSize = 1.0
}

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
    Humanoid = char:WaitForChild("Humanoid", 5)
    if glowPart and glowPart.Parent then
        glowPart:Destroy()
        glowPart = nil
    end
    if HumanoidRootPart and Humanoid then
        pcall(createBodyGlow)
        lastWavePoints = {}
    end
end)

local function clearOldEffects()
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name == "PlayerWaveTrail" then
            pcall(function() v:Destroy() end)
        end
    end
    if Character then
        for _, v in pairs(Character:GetChildren()) do
            if v.Name == "PlayerBodyGlow" then
                pcall(function() v:Destroy() end)
            end
        end
    end
end

clearOldEffects()

local function createBodyGlow()
    if not Character or not HumanoidRootPart then return end
    glowPart = Instance.new("Part")
    glowPart.Name = "PlayerBodyGlow"
    glowPart.Size = Vector3.new(4, 6, 4)
    glowPart.Transparency = 1
    glowPart.CanCollide = false
    glowPart.Anchored = false
    glowPart.CanTouch = false
    glowPart.Massless = true
    glowPart.Parent = Character

    local weld = Instance.new("Weld")
    weld.Part0 = HumanoidRootPart
    weld.Part1 = glowPart
    weld.C0 = CFrame.identity
    weld.C1 = CFrame.identity
    weld.Parent = glowPart

    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = getgenv().TrailConfig.GlowBrightness
    pointLight.Range = getgenv().TrailConfig.GlowRange
    pointLight.Color = getgenv().TrailConfig.Color2
    pointLight.Parent = glowPart

    local coreParticle = Instance.new("ParticleEmitter")
    coreParticle.Parent = glowPart
    coreParticle.Size = NumberSequence.new(0.3, getgenv().TrailConfig.CoreParticleSize)
    coreParticle.Transparency = NumberSequence.new(0.1, 0.85)
    coreParticle.Lifetime = NumberRange.new(0.2, 0.7)
    coreParticle.Rate = getgenv().TrailConfig.CoreParticleRate
    coreParticle.Speed = NumberRange.new(0.8, 2.0)
    coreParticle.VelocitySpread = 180
    coreParticle.Color = ColorSequence.new(getgenv().TrailConfig.Color1, getgenv().TrailConfig.Color3)
    coreParticle.EmissionDirection = Enum.EmissionDirection.Outward
    coreParticle.Rotation = NumberRange.new(0, 360)
    coreParticle.RotationSpeed = NumberRange.new(-50, 50)

    local coreParticle2 = Instance.new("ParticleEmitter")
    coreParticle2.Parent = glowPart
    coreParticle2.Size = NumberSequence.new(0.2, 0.8)
    coreParticle2.Transparency = NumberSequence.new(0.2, 0.9)
    coreParticle2.Lifetime = NumberRange.new(0.3, 0.9)
    coreParticle2.Rate = getgenv().TrailConfig.CoreParticleRate / 2
    coreParticle2.Speed = NumberRange.new(0.5, 1.5)
    coreParticle2.VelocitySpread = 180
    coreParticle2.Color = ColorSequence.new(getgenv().TrailConfig.Color2, getgenv().TrailConfig.Color1)
    coreParticle2.EmissionDirection = Enum.EmissionDirection.Upward
end

pcall(createBodyGlow)

local function getWavePoints(origin, step)
    if not origin then return {} end
    local points = {}
    local config = getgenv().TrailConfig
    for i = 0, config.WaveCount do
        local t = i / config.WaveCount
        local offsetX = math.sin(t * math.pi * 2 + tick() * 3) * config.WaveAmplitude * step
        local offsetZ = math.cos(t * math.pi * 2 + tick() * 2) * config.WaveAmplitude * step
        local offsetY = math.sin(t * math.pi * 1 + tick() * 4) * config.WaveAmplitude * step / 2
        local pos = origin + Vector3.new(offsetX, offsetY, offsetZ)
        table.insert(points, pos)
    end
    return points
end

local function createWaveTrail()
    if not Character or not HumanoidRootPart or Humanoid.Health <= 0 or not trailEnabled then return end
    local config = getgenv().TrailConfig
    local currentPos = HumanoidRootPart.Position + Vector3.new(0, 0.5, 0)
    
    table.insert(lastWavePoints, 1, currentPos)
    if #lastWavePoints > config.TrailLength then
        table.remove(lastWavePoints, #lastWavePoints)
    end

    for i, pos in ipairs(lastWavePoints) do
        local fade = i / #lastWavePoints
        local wavePoints = getWavePoints(pos, fade)
        if #wavePoints < 2 then continue end

        local trailFolder = Instance.new("Folder")
        trailFolder.Name = "PlayerWaveTrail"
        trailFolder.Parent = Workspace

        for j = 1, #wavePoints - 1 do
            local p1 = wavePoints[j]
            local p2 = wavePoints[j + 1]
            local midPos = (p1 + p2) / 2

            local particle = Instance.new("Part")
            particle.Size = Vector3.new(0.1, 0.1, 0.1)
            particle.Transparency = 1
            particle.CanCollide = false
            particle.Anchored = true
            particle.Position = midPos
            particle.Parent = trailFolder

            local emitter = Instance.new("ParticleEmitter")
            emitter.Parent = particle
            emitter.Size = NumberSequence.new(config.ParticleSize * fade, config.ParticleSize * fade * 0.3)
            emitter.Transparency = NumberSequence.new(0.05 * fade, 0.9)
            emitter.Lifetime = NumberRange.new(0.4 * fade, 1.3 * fade)
            emitter.Rate = config.ParticleRate * fade
            emitter.Speed = NumberRange.new(0.5, 1.2)
            emitter.VelocitySpread = 120
            emitter.Color = ColorSequence.new(config.Color1, config.Color2, config.Color3)
            emitter.EmissionDirection = Enum.EmissionDirection.Both
            emitter.Drag = 2
            emitter.RotationSpeed = NumberRange.new(-30, 30)

            local emitter2 = Instance.new("ParticleEmitter")
            emitter2.Parent = particle
            emitter2.Size = NumberSequence.new(0.2 * fade, 0.6 * fade)
            emitter2.Transparency = NumberSequence.new(0.1 * fade, 0.85)
            emitter2.Lifetime = NumberRange.new(0.3 * fade, 1.0 * fade)
            emitter2.Rate = config.ParticleRate * fade / 2
            emitter2.Speed = NumberRange.new(0.3, 0.9)
            emitter2.VelocitySpread = 180
            emitter2.Color = ColorSequence.new(config.Color3, config.Color2)
            emitter2.EmissionDirection = Enum.EmissionDirection.Outward

            local light = Instance.new("PointLight")
            light.Parent = particle
            light.Brightness = config.GlowBrightness * fade * 0.6
            light.Range = config.GlowRange * fade
            light.Color = config.Color2
        end

        task.delay(config.FadeSpeed * 5, function()
            if trailFolder and trailFolder.Parent then
                pcall(function()
                    for _, v in pairs(trailFolder:GetChildren()) do
                        local tween = TweenService:Create(v, TweenInfo.new(0.3), {Transparency = 1})
                        tween:Play()
                        tween.Completed:Connect(function() v:Destroy() end)
                    end
                    task.wait(0.3)
                    trailFolder:Destroy()
                end)
            end
        end)
    end
end

RunService.Heartbeat:Connect(function()
    pcall(createWaveTrail)
end)

    end
})
