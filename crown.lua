local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local success, WindUI = pcall(function() return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))() end)
if not success or not WindUI then
    StarterGui:SetCore("SendNotification", {Title = "UI加载失败", Text = "网络拦截或执行器不支持", Duration = 10})
    return
end
local Cfg = {
    AutoPetEgg = false, PetEggName = "SkyPetEgg", PetEggQty = 1, AutoHaloEgg = false, HaloEggName = "SkyHaloEgg", HaloEggQty = 1,
    EggCurrency = "Gem", EggInterval = 0.1, AutoTrain = false, TrainAction = "Dumbbell", TrainActionCN = "哑铃",
    TrainInterval = 0.2, FastTrain = false, FastTrainAction = "Dumbbell", FastTrainActionCN = "哑铃", FastPerBeat = 1,
    FastMaxPerSecond = 0, FastTotalReps = 0, AutoRebirth = false, TargetStrength = 10000, RebirthInc = 10000,
    TargetRebirthCount = 5, InfiniteRebirth = false, BaseStrength = 10000, Fly = false, FlySpeed = 50, WalkSpeed = 16,
    AntiAfk = true, TotalReps = 0, ScriptStartTime = tick(), RailgunKeyBind = true
}
local ActionMap = {
    ["俯卧撑"] = "PushUp", ["哑铃"] = "Dumbbell", ["肩部推举1"] = "ShoulderPress_1", ["肩部推举2"] = "ShoulderPress_2",
    ["肩部推举3"] = "ShoulderPress_3", ["跑步机1"] = "TrendMill_1", ["平躺卧推1"] = "FlatBench_1", ["平躺卧推L1"] = "FlatBench_L1",
    ["平躺卧推K1"] = "FlatBench_K1", ["举石1"] = "Rock_1", ["举石2"] = "Rock_2", ["举石3"] = "Rock_3",
    ["杠铃架L1"] = "BarbellRack_L1", ["杠铃架S1"] = "BarbellRack_S1", ["杠铃架1"] = "BarbellRack_1", ["杠铃架2"] = "BarbellRack_2",
    ["卧推L1"] = "BenchPress_L1", ["卧推1"] = "BenchPress_1", ["卧推2"] = "BenchPress_2", ["红史莱姆"] = "Red slime", ["天空史莱姆"] = "SkySlime"
}
local ActionListCN = {}
for cn, _ in pairs(ActionMap) do table.insert(ActionListCN, cn) end
table.sort(ActionListCN)
local function corner(p, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 8) c.Parent = p return c end
local function fmt(n) n = math.floor(tonumber(n) or 0) local s = tostring(n) local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse() if out:sub(1, 1) == "," then out = out:sub(2) end return out end
local function getCurrentStrength() local str = 0 pcall(function() local attr = player:GetAttribute("Strength") or player:GetAttribute("Power") if attr then str = attr return end if player.leaderstats then local ls = player.leaderstats if ls:FindFirstChild("Strength") then str = ls.Strength.Value return end if ls:FindFirstChild("Power") then str = ls.Power.Value return end end end) return str end
local function getCurrentRebirths() local count = 0 pcall(function() local attr = player:GetAttribute("Rebirths") or player:GetAttribute("Rebirth") if attr then count = attr return end if player.leaderstats then for _, n in ipairs({"Rebirths", "Rebirth", "RebirthCount", "Prestige"}) do if player.leaderstats:FindFirstChild(n) then count = player.leaderstats[n].Value return end end end end) return count end
local function applyAntiIdleKick()
    if not getconnections then return end
    pcall(function() for _, conn in next, getconnections(player.Idled) do pcall(function() conn:Disable() end) pcall(function() conn:Disconnect() end) end end)
end
local TP = { Target = "", Loop = false, OffsetY = 3, Thread = nil }
function TP:ToTarget() local char = player.Character if not char then return false end local hrp = char:FindFirstChild("HumanoidRootPart") if not hrp then return false end local target = Players:FindFirstChild(self.Target) if not target or not target.Character then return false end local targetHrp = target.Character:FindFirstChild("HumanoidRootPart") if not targetHrp then return false end hrp.CFrame = targetHrp.CFrame + Vector3.new(0, self.OffsetY, 0) return true end
function TP:StartLoop() if self.Loop then return end self.Loop = true self.Thread = task.spawn(function() while self.Loop do self:ToTarget() task.wait() end end) end
function TP:StopLoop() self.Loop = false self.Thread = nil end
local Window = WindUI:CreateWindow({ Title = "力量之冠 V4.0 高精度版", Icon = "zap", Author = "力量之冠", Folder = "PowerCrownSave", Theme = "Dark", Transparent = true, Resizable = false, Size = UDim2.fromOffset(460, 780) })
local MainTab = Window:Tab({ Title = "控制面板", Icon = "settings" })
local PetSection = MainTab:Section({ Title = "🐾 宠物区", Icon = "paw" })
PetSection:Toggle({ Title = "自动抽宠物蛋", Value = false, Callback = function(state) Cfg.AutoPetEgg = state end })
PetSection:Input({ Title = "宠物蛋名字", Value = "SkyPetEgg", Callback = function(text) Cfg.PetEggName = text end })
local PetStatus = PetSection:Paragraph({ Title = "宠物区状态", Desc = "待机中..." })
local HaloSection = MainTab:Section({ Title = "✨ 光环区", Icon = "star" })
HaloSection:Toggle({ Title = "自动抽光环蛋", Value = false, Callback = function(state) Cfg.AutoHaloEgg = state end })
HaloSection:Input({ Title = "光环蛋名字", Value = "SkyHaloEgg", Callback = function(text) Cfg.HaloEggName = text end })
local HaloStatus = HaloSection:Paragraph({ Title = "光环区状态", Desc = "待机中..." })
local TrainSection = MainTab:Section({ Title = "🏋️ 自动锻炼", Icon = "activity" })
TrainSection:Toggle({ Title = "自动锻炼", Value = false, Callback = function(state) Cfg.AutoTrain = state end })
TrainSection:Dropdown({ Title = "选择动作", Values = ActionListCN, Value = "哑铃", Callback = function(selected) local en = ActionMap[selected] if en then Cfg.TrainAction = en Cfg.TrainActionCN = selected end end })
local TrainStatus = TrainSection:Paragraph({ Title = "锻炼状态", Desc = "待机中..." })
local FastTrainSection = MainTab:Section({ Title = "⚡ 无间隔极速锻炼", Icon = "gauge" })
FastTrainSection:Toggle({ Title = "开启极速锻炼", Value = false, Callback = function(state) Cfg.FastTrain = state end })
FastTrainSection:Dropdown({ Title = "选择动作", Values = ActionListCN, Value = "哑铃", Callback = function(selected) local en = ActionMap[selected] if en then Cfg.FastTrainAction = en Cfg.FastTrainActionCN = selected end end })
local FastTrainStatus = FastTrainSection:Paragraph({ Title = "极速状态", Desc = "待机中..." })
local RebirthSection = MainTab:Section({ Title = "💀 自动重生", Icon = "refresh-cw" })
RebirthSection:Toggle({ Title = "开启自动重生", Value = false, Callback = function(state) Cfg.AutoRebirth = state end })
RebirthSection:Input({ Title = "目标力量", Value = "10000", Callback = function(text) Cfg.TargetStrength = tonumber(text) or 10000 end })
local RebirthStatus = RebirthSection:Paragraph({ Title = "重生状态", Desc = "待机中..." })
local MoveSection = MainTab:Section({ Title = "⚡ 移动与反挂机", Icon = "move" })
MoveSection:Toggle({ Title = "飞行模式", Value = false, Callback = function(state) Cfg.Fly = state end })
MoveSection:Slider({ Title = "步行速度", Value = { Min = 16, Max = 500, Default = 16 }, Step = 1, Callback = function(value) Cfg.WalkSpeed = value local char = player.Character if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed = value end end end })
MoveSection:Toggle({ Title = "强力反挂机", Value = true, Callback = function(state) Cfg.AntiAfk = state end })
local FunTab = Window:Tab({ Title = "娱乐区", Icon = "sparkles" })
local RailgunSection = FunTab:Section({ Title = "末日轨道炮 (高精度)", Icon = "zap" })
local RailgunStatus = RailgunSection:Paragraph({ Title = "轨道炮状态", Desc = "请先点击选择目标" })
local targetPosition = nil
local isTargeting = false
RailgunSection:Button({ Title = "选择发射目标", Callback = function() isTargeting = true RailgunStatus:SetDesc("请在画面中点击地面") end })
RailgunSection:Button({ Title = "立即发射", Callback = function()
    if not targetPosition then RailgunStatus:SetDesc("请先选择目标！") return end
    RailgunStatus:SetDesc("播放高精度过场动画...")
    runSequence(targetPosition)
end })
RailgunSection:Toggle({ Title = "启用 F 键发射", Value = true, Callback = function(state) Cfg.RailgunKeyBind = state end })
local TeleportTab = Window:Tab({ Title = "传送", Icon = "send" })
local TPSection = TeleportTab:Section({ Title = "传送玩家", Icon = "user" })
local function GetPlayerList() local list = {} for _, p in ipairs(Players:GetPlayers()) do if p ~= player then table.insert(list, p.Name) end end return list end
local TPDropdown = TPSection:Dropdown({ Title = "选择在线玩家", Values = GetPlayerList(), Value = "", Callback = function(selected) if type(selected) == "table" then selected = selected[1] end TP.Target = selected or "" end })
TPSection:Button({ Title = "刷新玩家", Callback = function() pcall(function() TPDropdown:Refresh(GetPlayerList()) end) end })
TPSection:Button({ Title = "传送", Callback = function() TP:ToTarget() end })
local SG = Instance.new("ScreenGui") SG.Name = "PowerCrownUI" SG.ResetOnSpawn = false SG.IgnoreGuiInset = true
pcall(function() SG.Parent = game:GetService("CoreGui") end) if not SG.Parent then SG.Parent = player.PlayerGui end
local DataHUD = Instance.new("Frame") DataHUD.Size = UDim2.new(0, 210, 0, 105) DataHUD.Position = UDim2.new(0, 20, 0.3, 0) DataHUD.BackgroundColor3 = Color3.fromRGB(20, 24, 34) DataHUD.BackgroundTransparency = 0.1 DataHUD.BorderSizePixel = 0 DataHUD.Parent = SG
corner(DataHUD, 10)
local HUDTitle = Instance.new("TextLabel") HUDTitle.Size = UDim2.new(1, 0, 0, 24) HUDTitle.BackgroundTransparency = 1 HUDTitle.Text = "📊 力量之冠 V4.0" HUDTitle.TextColor3 = Color3.fromRGB(60, 150, 230) HUDTitle.Font = Enum.Font.GothamBold HUDTitle.TextSize = 12 HUDTitle.Parent = DataHUD
local LabelReps = Instance.new("TextLabel") LabelReps.Size = UDim2.new(0.5, -10, 0, 18) LabelReps.Position = UDim2.new(0, 10, 0, 30) LabelReps.BackgroundTransparency = 1 LabelReps.Text = "总训练: 0" LabelReps.TextColor3 = Color3.fromRGB(230, 230, 235) LabelReps.Font = Enum.Font.Gotham LabelReps.TextSize = 11 LabelReps.TextXAlignment = Enum.TextXAlignment.Left LabelReps.Parent = DataHUD
local LabelRebirth = Instance.new("TextLabel") LabelRebirth.Size = UDim2.new(0.5, -10, 0, 18) LabelRebirth.Position = UDim2.new(0, 10, 0, 50) LabelRebirth.BackgroundTransparency = 1 LabelRebirth.Text = "总转生: 0" LabelRebirth.TextColor3 = Color3.fromRGB(230, 230, 235) LabelRebirth.Font = Enum.Font.Gotham LabelRebirth.TextSize = 11 LabelRebirth.TextXAlignment = Enum.TextXAlignment.Left LabelRebirth.Parent = DataHUD
local flying, flyBV, flyBG = false, nil, nil
RunService.RenderStepped:Connect(function()
    if not Cfg.Fly then if flying then flying = false local c = player.Character if c then local h = c:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand = false end end if flyBV then flyBV:Destroy() flyBV = nil end if flyBG then flyBG:Destroy() flyBG = nil end end return end
    if not flying then
        local c = player.Character if not c then return end local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end local h = c:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand = true end
        flyBV = Instance.new("BodyVelocity") flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5) flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro") flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5) flyBG.P = 3000 flyBG.D = 500 flyBG.Parent = hrp
        flying = true
    end
    local c = player.Character if not c then return end local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp or not flyBV or not flyBG then return end
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
    if dir.Magnitude > 0 then dir = dir.Unit * Cfg.FlySpeed end
    flyBV.Velocity = dir flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + camera.CFrame.LookVector)
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if isTargeting then
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local ray = camera:ViewportPointToRay(input.Position.X, input.Position.Y)
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000)
            if result then
                targetPosition = result.Position
                local targetMarker = Instance.new("Part") targetMarker.Shape = Enum.PartType.Ball targetMarker.Material = Enum.Material.Neon targetMarker.Color = Color3.fromRGB(255, 0, 0) targetMarker.Size = Vector3.new(14, 14, 14) targetMarker.Position = targetPosition + Vector3.new(0, 5, 0) targetMarker.Anchored = true targetMarker.CanCollide = false targetMarker.Parent = workspace
                Debris:AddItem(targetMarker, 10) RailgunStatus:SetDesc("目标已选定！") isTargeting = false
            end
        end
        return
    end
    if input.KeyCode == Enum.KeyCode.F and Cfg.RailgunKeyBind and targetPosition then runSequence(targetPosition) end
end)
task.spawn(function()
    local storeEvent pcall(function() storeEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StoreEvent") end)
    while true do task.wait(Cfg.EggInterval) if Cfg.AutoPetEgg and storeEvent then pcall(function() storeEvent:FireServer("Egg", Cfg.PetEggQty, Cfg.EggCurrency, Cfg.PetEggName) PetStatus:SetDesc("抽: " .. Cfg.PetEggName) end) end if Cfg.AutoHaloEgg and storeEvent then pcall(function() storeEvent:FireServer("Egg", Cfg.HaloEggQty, Cfg.EggCurrency, Cfg.HaloEggName) HaloStatus:SetDesc("抽: " .. Cfg.HaloEggName) end) end end
end)
task.spawn(function()
    local trainEvent pcall(function() trainEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TrainEvent") end)
    while true do task.wait(Cfg.TrainInterval) if Cfg.AutoTrain and trainEvent then pcall(function() trainEvent:FireServer(Cfg.TrainAction) Cfg.TotalReps = Cfg.TotalReps + 1 TrainStatus:SetDesc("锻炼: " .. Cfg.TrainActionCN) end) end end
end)
task.spawn(function()
    local fastTrainEvent pcall(function() fastTrainEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TrainEvent") end)
    RunService.Heartbeat:Connect(function() if not Cfg.FastTrain or not fastTrainEvent then return end for _ = 1, 10 do pcall(function() fastTrainEvent:FireServer(Cfg.FastTrainAction) Cfg.FastTotalReps = Cfg.FastTotalReps + 1 Cfg.TotalReps = Cfg.TotalReps + 1 end) end end)
end)
task.spawn(function()
    local rebirthEvent pcall(function() rebirthEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RebirthEvent") end)
    while true do task.wait(0.1) if Cfg.AutoRebirth and rebirthEvent then pcall(function() if getCurrentStrength() >= Cfg.TargetStrength then rebirthEvent:FireServer("Update") Cfg.TargetStrength = Cfg.TargetStrength + Cfg.RebirthInc RebirthStatus:SetDesc("进度: " .. getCurrentRebirths()) end end) end end
end)
task.spawn(function()
    while SG.Parent do
        task.wait(10)
        if Cfg.AntiAfk then
            pcall(function()
                local VIM = game:GetService("VirtualInputManager")
                VIM:SendKeyEvent(Enum.KeyCode.Space, true, false, game) task.wait(0.05)
                VIM:SendKeyEvent(Enum.KeyCode.Space, false, false, game)
                VIM:SendMouseMoveEvent(0, 0, game) task.wait(0.05)
                VIM:SendMouseMoveEvent(1, 1, game)
            end)
        end
    end
end)
task.spawn(function()
    while SG.Parent do
        local et = tick() - Cfg.ScriptStartTime
        LabelReps.Text = "总训练: " .. fmt(Cfg.TotalReps)
        LabelRebirth.Text = "总转生: " .. fmt(getCurrentRebirths())
        task.wait(0.5)
    end
end)
if player.Character then local hum = player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed = Cfg.WalkSpeed end end
applyAntiIdleKick()
local COOLDOWN = 30
local DANGER_RADIUS = 480
local CRATER_RADIUS = 480
local CRATER_DEPTH = 185
local RIM_WIDTH = 190
local RIM_HEIGHT = 96
local CELL = 12
local KILL_RADIUS = 520
local BLAST_RADIUS = 1500
local ROCK_COUNT = 260
local SPIRE_COUNT = 22
local BLAST_PARTS = true
local RESTORE_AFTER = 120
local SPACE_ORIGIN = Vector3.new(0, 300000, 0)
local EARTH_RADIUS = 80
local GALAXY_RADIUS = 34000
local SUN_RADIUS = 1400
local EARTH_ORBIT_RADIUS = 3600
local T = { lockEnd = 2, ascentEnd = 6, orbitEnd = 9.5, pullEnd = 12.5, holdEnd = 13.5, swoopEnd = 17, fireT = 21.5, groundT = 23.4, imp = 25, endT = 32 }
local ASSET_ROOT = "SpaceCannon_OriginalAssets/"
local function loadLocalAsset(relativePath)
    local getter pcall(function() getter = getcustomasset or getsynasset or (syn and syn.getcustomasset) end) if type(getter) ~= "function" then return nil end
    local path = ASSET_ROOT .. relativePath local existsFn pcall(function() existsFn = isfile end)
    if type(existsFn) == "function" then local okExists, exists = pcall(existsFn, path) if okExists and not exists then return nil end end
    local ok, uri = pcall(getter, path) if ok and type(uri) == "string" and uri ~= "" then return uri end return nil
end
local TEXTURES = { earth = loadLocalAsset("textures/earth_day.jpg"), clouds = loadLocalAsset("textures/earth_clouds_alpha.png"), earthLights = loadLocalAsset("textures/earth_night_lights.png"), moon = loadLocalAsset("textures/moon.jpg"), galaxyTop = loadLocalAsset("textures/milky_way_top_alpha.png"), galaxySky = loadLocalAsset("textures/milky_way_sky.jpg"), skyboxBk = loadLocalAsset("textures/skybox/bk.jpg"), skyboxDn = loadLocalAsset("textures/skybox/dn.jpg"), skyboxFt = loadLocalAsset("textures/skybox/ft.jpg"), skyboxLf = loadLocalAsset("textures/skybox/lf.jpg"), skyboxRt = loadLocalAsset("textures/skybox/rt.jpg"), skyboxUp = loadLocalAsset("textures/skybox/up.jpg"), mercury = loadLocalAsset("textures/mercury.jpg"), venus = loadLocalAsset("textures/venus.jpg"), sun = loadLocalAsset("textures/sun.jpg"), mars = loadLocalAsset("textures/mars.jpg"), jupiter = loadLocalAsset("textures/jupiter.jpg"), saturn = loadLocalAsset("textures/saturn.jpg"), uranus = loadLocalAsset("textures/uranus.jpg"), neptune = loadLocalAsset("textures/neptune.jpg") }
local SOUNDS = { click = { file = "audio/staff_select.mp3", fallback = "rbxasset://sounds/switch.wav" }, select = { file = "audio/star_press.mp3", fallback = "rbxasset://sounds/electronicpingshort.wav" }, lock = { file = "audio/star_lock.mp3", fallback = "rbxasset://sounds/electronicpingshort.wav" }, whoosh = { file = "audio/star_ascent.mp3", fallback = "rbxasset://sounds/Rocket whoosh 01.wav" }, charge = { file = "audio/star_gun.mp3", fallback = "rbxasset://sounds/Rocket whoosh 01.wav" }, fire = { file = "audio/star_fire.mp3", fallback = "rbxasset://sounds/Rocket shot.wav" }, boom = { file = "audio/star_impact.mp3", fallback = "rbxasset://sounds/impact_explosion_03.mp3" }, beam = { file = "audio/star_beam.mp3", fallback = "rbxasset://sounds/Rocket whoosh 01.wav" }, ambient = { file = "audio/stars_hum.mp3", fallback = "" }, countdown = { file = "audio/star_countdown.mp3", fallback = "" }, arm = { file = "audio/star_arm.mp3", fallback = "" }, after = { file = "audio/star_after.mp3", fallback = "" } }
local NK = NumberSequenceKeypoint.new local FLAT = CFrame.Angles(0, 0, math.rad(90)) local RED = Color3.fromRGB(255, 56, 56)
local function new(class, props, parent) local inst = Instance.new(class) for k, v in pairs(props) do inst[k] = v end if parent then inst.Parent = parent end return inst end
local function vpart(props, parent) local p = new("Part", { Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false, Material = Enum.Material.SmoothPlastic, TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth }, nil) for k, v in pairs(props) do p[k] = v end p.Parent = parent return p end
local function bigSphere(parent, pos, diameter, color, material, transparency) local p if diameter <= 2048 then p = vpart({ Shape = Enum.PartType.Ball, Size = Vector3.one * diameter, Position = pos, Color = color, Material = material, Transparency = transparency }, parent) else p = vpart({ Size = Vector3.one * 2048, Position = pos, Color = color, Material = material, Transparency = transparency }, parent) new("SpecialMesh", { MeshType = Enum.MeshType.Sphere, Scale = Vector3.one * (diameter / 2048) }, p) end return p end
local function texturedSphere(parent, pos, diameter, textureId, color, material, transparency, name) if not textureId then return nil end local baseDiameter = math.min(diameter, 2048) local p = vpart({ Name = name or "TexturedCelestialBody", Size = Vector3.one * baseDiameter, Position = pos, Color = color or Color3.new(1, 1, 1), Material = material or Enum.Material.SmoothPlastic, Transparency = transparency or 0 }, parent) local ok = pcall(function() new("SpecialMesh", { MeshType = Enum.MeshType.Sphere, Scale = Vector3.one * (diameter / baseDiameter), TextureId = textureId }, p) end) if not ok then p:Destroy() return nil end return p end
local function addTexturedGalaxyDisc(parent, center, radius) if not TEXTURES.galaxyTop then return nil end local baseSpan = 2040 local plate = vpart({ Name = "OriginalMilkyWayCoreTexture", Size = Vector3.new(baseSpan, 0.5, baseSpan), Position = center, Transparency = 1, Material = Enum.Material.SmoothPlastic }, parent) local ok = pcall(function() new("SpecialMesh", { Name = "GalaxyDiscScale", MeshType = Enum.MeshType.Brick, Scale = Vector3.new((radius * 2) / baseSpan, 1, (radius * 2) / baseSpan) }, plate) new("Decal", { Name = "MilkyWaySpiralCore", Face = Enum.NormalId.Top, Texture = TEXTURES.galaxyTop, Transparency = 0.04 }, plate) end) if not ok then plate:Destroy() return nil end return plate end
local function clamp01(x) return math.clamp(x, 0, 1) end
local function lerp(a, b, t) return a + (b - a) * t end
local function smooth(t) t = clamp01(t) return t * t * (3 - 2 * t) end
local function gauss() return math.random() + math.random() + math.random() - 1.5 end
local function rotY(v, a) return CFrame.Angles(0, a, 0):VectorToWorldSpace(v) end
local function randDir() local z = math.random() * 2 - 1 local a = math.random() * math.pi * 2 local r = math.sqrt(1 - z * z) return Vector3.new(r * math.cos(a), z, r * math.sin(a)) end
local function tween(inst, time, props, style, dir) local tw = TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props) tw:Play() return tw end
local fxFolder = new("Folder", { Name = "SpaceCannonFX" }, Workspace)
local function playSound(id, volume, speed, looped) if type(id) == "table" then local localId = loadLocalAsset(id.file or "") id = localId or id.fallback end if not id or id == "" then return nil end local s = new("Sound", { SoundId = id, Volume = volume or 1, PlaybackSpeed = speed or 1, Looped = looped or false }, SoundService) pcall(function() s:Play() end) if not looped then Debris:AddItem(s, 10) end return s end
local state = "idle" local lastFire = -1e9
local gui = new("ScreenGui", { Name = "SpaceCannonUI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 50, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, player:WaitForChild("PlayerGui"))
local flash = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 100, Active = false }, gui)
local function setFlash(a, color) flash.BackgroundColor3 = color or Color3.new(1, 1, 1) flash.BackgroundTransparency = 1 - clamp01(a) end
local barTop = new("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 90 }, gui)
local barBottom = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 90 }, gui)
local function showBars(on) local s = UDim2.new(1, 0, on and 0.1 or 0, 0) tween(barTop, 0.8, { Size = s }) tween(barBottom, 0.8, { Size = s }) end
local caption = new("TextLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0.9, 0), Size = UDim2.new(0.9, 0, 0, 40), BackgroundTransparency = 1, Text = "", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 22, TextTransparency = 1, TextStrokeTransparency = 0.6, ZIndex = 95 }, gui)
local function setCaption(text, color) if text == "" then tween(caption, 0.4, { TextTransparency = 1 }) return end caption.Text = text caption.TextColor3 = color or Color3.new(1, 1, 1) caption.TextTransparency = 1 tween(caption, 0.4, { TextTransparency = 0 }) end
local fx = {}
local function ensureFx() if fx.cc then return end fx.cc = new("ColorCorrectionEffect", { Name = "SC_CC" }, Lighting) fx.bloom = new("BloomEffect", { Name = "SC_Bloom", Intensity = 0.5, Size = 28, Threshold = 1 }, Lighting) fx.blur = new("BlurEffect", { Name = "SC_Blur", Size = 0 }, Lighting) end
local function clearFx() for k, v in pairs(fx) do v:Destroy() fx[k] = nil end end
local savedLighting = nil
local function enterSpaceLighting()
    if savedLighting then return end
    savedLighting = { props = {}, removed = {} }
    for _, k in ipairs({ "ClockTime", "Ambient", "OutdoorAmbient", "Brightness", "FogStart", "FogEnd", "FogColor", "ExposureCompensation" }) do savedLighting.props[k] = Lighting[k] end
    for _, c in ipairs(Lighting:GetChildren()) do if c:IsA("Sky") or c:IsA("Atmosphere") or c:IsA("Clouds") then savedLighting.removed[#savedLighting.removed + 1] = c c.Parent = nil end end
    Lighting.ClockTime = 0 Lighting.Ambient = Color3.fromRGB(10, 14, 32) Lighting.OutdoorAmbient = Color3.fromRGB(18, 23, 48)
    Lighting.Brightness = 1.9 Lighting.FogStart = 1e8 Lighting.FogEnd = 1e8 Lighting.FogColor = Color3.fromRGB(3, 5, 18) Lighting.ExposureCompensation = -0.12
    savedLighting.sky = new("Sky", { Name = "SC_CosmicSkybox", SkyboxBk = T