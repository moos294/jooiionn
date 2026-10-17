local VERSION = "V4.9"
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local SGui = game:GetService("StarterGui")
local SS = game:GetService("SoundService")
local WS = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = WS.CurrentCamera

local ok, WindUI = pcall(function() 
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua"))() 
end)

if not ok or not WindUI then 
    pcall(function() SGui:SetCore("SendNotification", {Title = "UI加载失败", Text = "网络拦截或执行器不支持", Duration = 10}) end)
    return 
end

local Cfg = {
    AutoPetEgg = false, PetEggName = "SkyPetEgg", PetEggQty = 1,
    AutoHaloEgg = false, HaloEggName = "SkyHaloEgg", HaloEggQty = 1, EggCurrency = "Gem", EggInterval = 0.1,
    AutoTrain = false, TrainAction = "Dumbbell", TrainActionCN = "哑铃", TrainInterval = 0.2,
    FastTrain = false, FastTrainAction = "Dumbbell", FastTrainActionCN = "哑铃",
    AutoRebirth = false, TargetStrength = 10000, RebirthInc = 10000,
    Fly = false, FlySpeed = 50, WalkSpeed = 16, AntiAfk = true,
    TotalReps = 0, ScriptStartTime = tick(), RailgunKeyBind = true
}

local ActionMap = {["俯卧撑"]="PushUp",["哑铃"]="Dumbbell",["肩部推举1"]="ShoulderPress_1",["肩部推举2"]="ShoulderPress_2",["肩部推举3"]="ShoulderPress_3",["跑步机1"]="TrendMill_1",["平躺卧推1"]="FlatBench_1",["平躺卧推L1"]="FlatBench_L1",["平躺卧推K1"]="FlatBench_K1",["举石1"]="Rock_1",["举石2"]="Rock_2",["举石3"]="Rock_3",["杠铃架L1"]="BarbellRack_L1",["杠铃架S1"]="BarbellRack_S1",["杠铃架1"]="BarbellRack_1",["杠铃架2"]="BarbellRack_2",["卧推L1"]="BenchPress_L1",["卧推1"]="BenchPress_1",["卧推2"]="BenchPress_2",["红史莱姆"]="Red slime",["天空史莱姆"]="SkySlime"}
local ActionListCN = {}
for cn, _ in pairs(ActionMap) do table.insert(ActionListCN, cn) end
table.sort(ActionListCN)

local function corner(p, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 8) c.Parent = p return c end
local function fmt(n) n = math.floor(tonumber(n) or 0) local s = tostring(n) local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse() if out:sub(1, 1) == "," then out = out:sub(2) end return out end

local function getCurrentStrength()
    local str = 0
    pcall(function()
        local attr = player:GetAttribute("Strength") or player:GetAttribute("Power")
        if attr then str = attr return end
        if player.leaderstats then
            local ls = player.leaderstats
            if ls:FindFirstChild("Strength") then str = ls.Strength.Value return end
            if ls:FindFirstChild("Power") then str = ls.Power.Value return end
        end
    end)
    return str
end

local function getCurrentRebirths()
    local count = 0
    pcall(function()
        local attr = player:GetAttribute("Rebirths") or player:GetAttribute("Rebirth")
        if attr then count = attr return end
        if player.leaderstats then
            for _, n in ipairs({"Rebirths", "Rebirth", "RebirthCount", "Prestige"}) do
                if player.leaderstats:FindFirstChild(n) then count = player.leaderstats[n].Value return end
            end
        end
    end)
    return count
end

local function applyAntiIdleKick()
    if not getconnections then return end
    pcall(function()
        for _, conn in next, getconnections(player.Idled) do
            pcall(function() conn:Disable() end)
            pcall(function() conn:Disconnect() end)
        end
    end)
end

local TP = {Target = "", Loop = false, OffsetY = 3, Thread = nil}
function TP:ToTarget()
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local target = Players:FindFirstChild(self.Target)
    if not target or not target.Character then return false end
    local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return false end
    hrp.CFrame = targetHrp.CFrame + Vector3.new(0, self.OffsetY, 0)
    return true
end

local successUI, Window = pcall(function()
    return WindUI:CreateWindow({Title = "力量之冠 " .. VERSION .. " 修复版", Icon = "zap", Author = "力量之冠", Folder = "PowerCrownSave", Theme = "Dark", Transparent = true, Resizable = false, Size = UDim2.fromOffset(460, 780)})
end)

if not successUI or not Window then 
    pcall(function() SGui:SetCore("SendNotification", {Title = "UI创建失败", Text = "组件崩溃", Duration = 10}) end)
    return 
end

local MainTab = Window:Tab({Title = "控制面板", Icon = "settings"})

local PetSection = MainTab:Section({Title = "🐾 宠物区", Icon = "paw"})
PetSection:Toggle({Title = "自动抽宠物蛋", Value = false, Callback = function(state) Cfg.AutoPetEgg = state end})
PetSection:Input({Title = "宠物蛋名字", Value = "SkyPetEgg", Callback = function(text) Cfg.PetEggName = text end})
local PetStatus = PetSection:Label({Text = "宠物区状态: 待机中..."})

local HaloSection = MainTab:Section({Title = "✨ 光环区", Icon = "star"})
HaloSection:Toggle({Title = "自动抽光环蛋", Value = false, Callback = function(state) Cfg.AutoHaloEgg = state end})
HaloSection:Input({Title = "光环蛋名字", Value = "SkyHaloEgg", Callback = function(text) Cfg.HaloEggName = text end})
local HaloStatus = HaloSection:Label({Text = "光环区状态: 待机中..."})

local TrainSection = MainTab:Section({Title = "🏋️ 自动锻炼", Icon = "activity"})
TrainSection:Toggle({Title = "自动锻炼", Value = false, Callback = function(state) Cfg.AutoTrain = state end})
TrainSection:Dropdown({Title = "选择动作", Values = ActionListCN, Value = "哑铃", Callback = function(selected) local en = ActionMap[selected] if en then Cfg.TrainAction = en Cfg.TrainActionCN = selected end end})
local TrainStatus = TrainSection:Label({Text = "锻炼状态: 待机中..."})

local FastTrainSection = MainTab:Section({Title = "⚡ 无间隔极速锻炼", Icon = "gauge"})
FastTrainSection:Toggle({Title = "开启极速锻炼", Value = false, Callback = function(state) Cfg.FastTrain = state end})
FastTrainSection:Dropdown({Title = "选择动作", Values = ActionListCN, Value = "哑铃", Callback = function(selected) local en = ActionMap[selected] if en then Cfg.FastTrainAction = en Cfg.FastTrainActionCN = selected end end})
local FastTrainStatus = FastTrainSection:Label({Text = "极速状态: 待机中..."})

local RebirthSection = MainTab:Section({Title = "💀 自动重生", Icon = "refresh-cw"})
RebirthSection:Toggle({Title = "开启自动重生", Value = false, Callback = function(state) Cfg.AutoRebirth = state end})
RebirthSection:Input({Title = "目标力量", Value = "10000", Callback = function(text) Cfg.TargetStrength = tonumber(text) or 10000 end})
local RebirthStatus = RebirthSection:Label({Text = "重生状态: 待机中..."})

local MoveSection = MainTab:Section({Title = "⚡ 移动与反挂机", Icon = "move"})
MoveSection:Toggle({Title = "飞行模式", Value = false, Callback = function(state) Cfg.Fly = state end})
MoveSection:Slider({Title = "步行速度", Value = {Min = 16, Max = 500, Default = 16}, Step = 1, Callback = function(value) Cfg.WalkSpeed = value local char = player.Character if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed = value end end end})
MoveSection:Toggle({Title = "强力反挂机", Value = true, Callback = function(state) Cfg.AntiAfk = state end})

local FunTab = Window:Tab({Title = "娱乐区", Icon = "sparkles"})
local RailgunSection = FunTab:Section({Title = "末日轨道炮 (全星系)", Icon = "zap"})
local RailgunStatus = RailgunSection:Label({Text = "轨道炮状态: 请先点击选择目标"})
local targetPosition = nil
local isTargeting = false

RailgunSection:Button({Title = "选择发射目标", Callback = function() isTargeting = true RailgunStatus:SetText("轨道炮状态: 请在画面中点击地面") end})
RailgunSection:Button({Title = "立即发射", Callback = function() if not targetPosition then RailgunStatus:SetText("请先选择目标！") return end RailgunStatus:SetText("正在加载宇宙模型...") if _G.TriggerStarDestroyer then _G.TriggerStarDestroyer(targetPosition) else RailgunStatus:SetText("模型未加载完毕") end end})
RailgunSection:Toggle({Title = "启用 F 键发射", Value = true, Callback = function(state) Cfg.RailgunKeyBind = state end})

local JupiterSection = FunTab:Section({Title = "木星轨道炮 (巨物降临)", Icon = "moon"})
local JupiterStatus = JupiterSection:Label({Text = "木星炮状态: 请先在上方选择发射目标"})
JupiterSection:Button({Title = "☄️ 立即发射木星炮", Callback = function() if not targetPosition then JupiterStatus:SetText("请先在上方选择目标！") return end JupiterStatus:SetText("木星引力锁定中...") if _G.TriggerJupiter then _G.TriggerJupiter(targetPosition) end end})

local TeleportTab = Window:Tab({Title = "传送", Icon = "send"})
local TPSection = TeleportTab:Section({Title = "传送玩家", Icon = "user"})
local function GetPlayerList() local list = {} for _, p in ipairs(Players:GetPlayers()) do if p ~= player then table.insert(list, p.Name) end end return list end
local TPDropdown = TPSection:Dropdown({Title = "选择在线玩家", Values = GetPlayerList(), Value = "", Callback = function(selected) if type(selected) == "table" then selected = selected[1] end TP.Target = selected or "" end})
TPSection:Button({Title = "刷新玩家", Callback = function() pcall(function() TPDropdown:Refresh(GetPlayerList()) end) end})
TPSection:Button({Title = "传送", Callback = function() TP:ToTarget() end})

local SG = Instance.new("ScreenGui") SG.Name = "PowerCrownUI" SG.ResetOnSpawn = false SG.IgnoreGuiInset = true
pcall(function() SG.Parent = game:GetService("CoreGui") end)
if not SG.Parent then SG.Parent = player.PlayerGui end

local DataHUD = Instance.new("Frame") DataHUD.Size = UDim2.new(0, 210, 0, 105) DataHUD.Position = UDim2.new(0, 20, 0.3, 0) DataHUD.BackgroundColor3 = Color3.fromRGB(20, 24, 34) DataHUD.BackgroundTransparency = 0.1 DataHUD.BorderSizePixel = 0 DataHUD.Parent = SG corner(DataHUD, 10)
local HUDTitle = Instance.new("TextLabel") HUDTitle.Size = UDim2.new(1, 0, 0, 24) HUDTitle.BackgroundTransparency = 1 HUDTitle.Text = "📊 力量之冠 " .. VERSION HUDTitle.TextColor3 = Color3.fromRGB(60, 150, 230) HUDTitle.Font = Enum.Font.GothamBold HUDTitle.TextSize = 12 HUDTitle.Parent = DataHUD
local LabelReps = Instance.new("TextLabel") LabelReps.Size = UDim2.new(0.5, -10, 0, 18) LabelReps.Position = UDim2.new(0, 10, 0, 30) LabelReps.BackgroundTransparency = 1 LabelReps.Text = "总训练: 0" LabelReps.TextColor3 = Color3.fromRGB(230, 230, 235) LabelReps.Font = Enum.Font.Gotham LabelReps.TextSize = 11 LabelReps.TextXAlignment = Enum.TextXAlignment.Left LabelReps.Parent = DataHUD
local LabelRebirth = Instance.new("TextLabel") LabelRebirth.Size = UDim2.new(0.5, -10, 0, 18) LabelRebirth.Position = UDim2.new(0, 10, 0, 50) LabelRebirth.BackgroundTransparency = 1 LabelRebirth.Text = "总转生: 0" LabelRebirth.TextColor3 = Color3.fromRGB(230, 230, 235) LabelRebirth.Font = Enum.Font.Gotham LabelRebirth.TextSize = 11 LabelRebirth.TextXAlignment = Enum.TextXAlignment.Left LabelRebirth.Parent = DataHUD

local dragging, dragInput, dragStart, startPos
DataHUD.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = input.Position startPos = DataHUD.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
DataHUD.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart DataHUD.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

local flying, flyBV, flyBG = false, nil, nil
RunService.RenderStepped:Connect(function()
    if not Cfg.Fly then if flying then flying = false local c = player.Character if c then local h = c:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand = false end end if flyBV then flyBV:Destroy() flyBV = nil end if flyBG then flyBG:Destroy() flyBG = nil end end return end
    if not flying then local c = player.Character if not c then return end local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end local h = c:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand = true end flyBV = Instance.new("BodyVelocity") flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5) flyBV.Parent = hrp flyBG = Instance.new("BodyGyro") flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5) flyBG.P = 3000 flyBG.D = 500 flyBG.Parent = hrp flying = true end
    local c = player.Character if not c then return end local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp or not flyBV or not flyBG then return end
    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
    if dir.Magnitude > 0 then dir = dir.Unit * Cfg.FlySpeed end
    flyBV.Velocity = dir flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + camera.CFrame.LookVector)
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if isTargeting then
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local ray = camera:ViewportPointToRay(input.Position.X, input.Position.Y) local res = WS:Raycast(ray.Origin, ray.Direction * 1000)
            if res then targetPosition = res.Position local mk = Instance.new("Part") mk.Shape = Enum.PartType.Ball mk.Material = Enum.Material.Neon mk.Color = Color3.fromRGB(255, 0, 0) mk.Size = Vector3.new(14, 14, 14) mk.Position = targetPosition + Vector3.new(0, 5, 0) mk.Anchored = true mk.CanCollide = false mk.Parent = WS Debris:AddItem(mk, 10) RailgunStatus:SetText("目标已选定！") JupiterStatus:SetText("目标已选定！") isTargeting = false end
        end
        return
    end
    if input.KeyCode == Enum.KeyCode.F and Cfg.RailgunKeyBind and targetPosition and _G.TriggerStarDestroyer then _G.TriggerStarDestroyer(targetPosition) end
end)

task.spawn(function() local ev pcall(function() ev = RS:WaitForChild("Remotes"):WaitForChild("StoreEvent") end) while true do task.wait(Cfg.EggInterval) if Cfg.AutoPetEgg and ev then pcall(function() ev:FireServer("Egg", Cfg.PetEggQty, Cfg.EggCurrency, Cfg.PetEggName) PetStatus:SetText("抽: " .. Cfg.PetEggName) end) end if Cfg.AutoHaloEgg and ev then pcall(function() ev:FireServer("Egg", Cfg.HaloEggQty, Cfg.EggCurrency, Cfg.HaloEggName) HaloStatus:SetText("抽: " .. Cfg.HaloEggName) end) end end end)
task.spawn(function() local ev pcall(function() ev = RS:WaitForChild("Remotes"):WaitForChild("TrainEvent") end) while true do task.wait(Cfg.TrainInterval) if Cfg.AutoTrain and ev then pcall(function() ev:FireServer(Cfg.TrainAction) Cfg.TotalReps = Cfg.TotalReps + 1 TrainStatus:SetText("锻炼: " .. Cfg.TrainActionCN) end) end end end)
task.spawn(function() local ev pcall(function() ev = RS:WaitForChild("Remotes"):WaitForChild("TrainEvent") end) RunService.Heartbeat:Connect(function() if not Cfg.FastTrain or not ev then return end for _ = 1, 10 do pcall(function() ev:FireServer(Cfg.FastTrainAction) Cfg.TotalReps = Cfg.TotalReps + 1 end) end end) end)
task.spawn(function() local ev pcall(function() ev = RS:WaitForChild("Remotes"):WaitForChild("RebirthEvent") end) while true do task.wait(0.1) if Cfg.AutoRebirth and ev then pcall(function() if getCurrentStrength() >= Cfg.TargetStrength then ev:FireServer("Update") Cfg.TargetStrength = Cfg.TargetStrength + Cfg.RebirthInc RebirthStatus:SetText("进度: " .. getCurrentRebirths()) end end) end end end)
task.spawn(function() while SG.Parent do task.wait(10) if Cfg.AntiAfk then pcall(function() local VIM = game:GetService("VirtualInputManager") VIM:SendKeyEvent(Enum.KeyCode.Space, true, false, game) task.wait(0.05) VIM:SendKeyEvent(Enum.KeyCode.Space, false, false, game) VIM:SendMouseMoveEvent(0, 0, game) task.wait(0.05) VIM:SendMouseMoveEvent(1, 1, game) end) end end end)
task.spawn(function() while SG.Parent do LabelReps.Text = "总训练: " .. fmt(Cfg.TotalReps) LabelRebirth.Text = "总转生: " .. fmt(getCurrentRebirths()) task.wait(0.5) end end)
if player.Character then local hum = player.Character:FindFirstChildOfClass("Humanoid") if hum then hum.WalkSpeed = Cfg.WalkSpeed end end applyAntiIdleKick()
local fxFolder = Instance.new("Folder") fxFolder.Name = "SpaceCannonFX" fxFolder.Parent = WS

local function new(class, props, parent) local inst = Instance.new(class) for k, v in pairs(props) do inst[k] = v end if parent then inst.Parent = parent end return inst end
local function vpart(props, parent) local p = new("Part", { Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false, Material = Enum.Material.SmoothPlastic, TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth }, nil) for k, v in pairs(props) do p[k] = v end p.Parent = parent return p end
local function clamp01(x) return math.clamp(x, 0, 1) end
local function tween(inst, time, props, style, dir) local tw = TS:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props) tw:Play() return tw end
local function smooth(t) t = clamp01(t) return t * t * (3 - 2 * t) end
local function gauss() return math.random() + math.random() + math.random() - 1.5 end
local function rotY(v, a) return CFrame.Angles(0, a, 0):VectorToWorldSpace(v) end
local function randDir() local z = math.random() * 2 - 1 local a = math.random() * math.pi * 2 local r = math.sqrt(1 - z * z) return Vector3.new(r * math.cos(a), z, r * math.sin(a)) end

local flash = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 100, Active = false }, SG)
local function setFlash(a, color) flash.BackgroundColor3 = color or Color3.new(1, 1, 1) flash.BackgroundTransparency = 1 - clamp01(a) end
local impactFlash = { t = -1e9, a = 0 } local impactShake = { t = -1e9, amp = 0 }
local function impactFlashValue() local e = os.clock() - impactFlash.t if e < 0 or e > 0.62 then return 0 end local rise = math.clamp(e / 0.045, 0, 1) local fall = math.clamp(1 - math.max(0, e - 0.045) / 0.575, 0, 1) return impactFlash.a * rise * fall * fall end
local function impactShakeAmount() local e = os.clock() - impactShake.t if e < 0 or e > 3.5 then return 0 end return impactShake.amp * (1 - e / 3.5) ^ 2 end
local function shakeCF(cf, amp, t, rotAmp) if amp <= 0.001 then return cf end local nx = math.noise(t * 23, 1.3, 0) * 2 local ny = math.noise(t * 27, 5.1, 0) * 2 local nz = math.noise(t * 19, 9.7, 0) * 2 return cf * CFrame.new(nx * amp, ny * amp, 0) * CFrame.Angles(ny * rotAmp, nx * rotAmp, nz * rotAmp * 0.5) end
local wasShaking = false

RunService.RenderStepped:Connect(function()
    if state ~= "cinematic" then
        local f = impactFlashValue()
        if f > 0.003 then setFlash(f) elseif flash.BackgroundTransparency < 1 and flash.BackgroundColor3 == Color3.new(1, 1, 1) then setFlash(0) end
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local a = impactShakeAmount()
            if a > 0.01 then wasShaking = true local t = os.clock() hum.CameraOffset = Vector3.new(math.noise(t * 25, 1, 0), math.noise(t * 31, 2, 0), math.noise(t * 17, 3, 0)) * 2 * a
            elseif wasShaking then wasShaking = false hum.CameraOffset = Vector3.zero end
        end
    end
end)

local barTop = new("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 90 }, SG)
local barBottom = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 90 }, SG)
local function showBars(on) local s = UDim2.new(1, 0, on and 0.1 or 0, 0) tween(barTop, 0.8, { Size = s }) tween(barBottom, 0.8, { Size = s }) end

local caption = new("TextLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0.9, 0), Size = UDim2.new(0.9, 0, 0, 40), BackgroundTransparency = 1, Text = "", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 22, TextTransparency = 1, TextStrokeTransparency = 0.6, ZIndex = 95 }, SG)
local function setCaption(text, color) if text == "" then tween(caption, 0.4, { TextTransparency = 1 }) return end caption.Text = text caption.TextColor3 = color or Color3.new(1, 1, 1) caption.TextTransparency = 1 tween(caption, 0.4, { TextTransparency = 0 }) end

local SOUNDS = { lock = { fallback = "rbxasset://sounds/electronicpingshort.wav" }, whoosh = { fallback = "rbxasset://sounds/Rocket whoosh 01.wav" }, charge = { fallback = "rbxasset://sounds/Rocket whoosh 01.wav" }, fire = { fallback = "rbxasset://sounds/Rocket shot.wav" }, boom = { fallback = "rbxasset://sounds/impact_explosion_03.mp3" } }
local function playSound(id, volume, speed, looped) if type(id) == "table" then id = id.fallback end if not id or id == "" then return nil end local s = new("Sound", { SoundId = id, Volume = volume or 1, PlaybackSpeed = speed or 1, Looped = looped or false }, SS) pcall(function() s:Play() end) if not looped then Debris:AddItem(s, 10) end return s end

local fx = {} local function ensureFx() if fx.cc then return end fx.cc = new("ColorCorrectionEffect", { Name = "SC_CC" }, Lighting) fx.bloom = new("BloomEffect", { Name = "SC_Bloom", Intensity = 0.5, Size = 28, Threshold = 1 }, Lighting) fx.blur = new("BlurEffect", { Name = "SC_Blur", Size = 0 }, Lighting) end
local function clearFx() for k, v in pairs(fx) do v:Destroy() fx[k] = nil end end
local function setControls(enabled) pcall(function() local pm = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")) local c = pm:GetControls() if enabled then c:Enable() else c:Disable() end end) end
local function setCoreGui(enabled) pcall(function() SGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, enabled) end) end
local state = "idle" local lastFire = -1e9

local COOLDOWN = 30 local DANGER_RADIUS = 480 local CRATER_RADIUS = 480 local CRATER_DEPTH = 185 local RIM_WIDTH = 190 local RIM_HEIGHT = 96 local CELL = 12 local KILL_RADIUS = 520 local BLAST_RADIUS = 1500 local ROCK_COUNT = 260 local SPIRE_COUNT = 22 local BLAST_PARTS = true local RESTORE_AFTER = 120 local SPACE_ORIGIN = Vector3.new(0, 300000, 0) local EARTH_RADIUS = 80 local GALAXY_RADIUS = 34000 local SUN_RADIUS = 1400 local EARTH_ORBIT_RADIUS = 3600 local T = { lockEnd = 2, ascentEnd = 6, orbitEnd = 12, moonEnd = 15, marsEnd = 18, jupiterEnd = 21, solarSystemEnd = 24, pullEnd = 28, holdEnd = 32, swoopEnd = 38, fireT = 42, groundT = 45, imp = 47, endT = 52 }
local NK = NumberSequenceKeypoint.new local FLAT = CFrame.Angles(0, 0, math.rad(90)) local RED = Color3.fromRGB(255, 56, 56)

local function bigSphere(parent, pos, diameter, color, material, transparency)
    local p
    if diameter <= 2048 then p = vpart({ Shape = Enum.PartType.Ball, Size = Vector3.one * diameter, Position = pos, Color = color, Material = material, Transparency = transparency }, parent)
    else p = vpart({ Size = Vector3.one * 2048, Position = pos, Color = color, Material = material, Transparency = transparency }, parent) new("SpecialMesh", { MeshType = Enum.MeshType.Sphere, Scale = Vector3.one * (diameter / 2048) }, p) end
    return p
end

local function landAt(n) return math.noise(n.X * 2.1 + 3.7, n.Y * 2.1 + 1.3, n.Z * 2.1 + 8.1) + 0.45 * math.noise(n.X * 5 + 1, n.Y * 5 + 2, n.Z * 5 + 3) > 0.04 end
local function cloudAt(n) return math.noise(n.X * 3.3 + 9.1, n.Y * 3.3 + 4.2, n.Z * 3.3 + 2.7) + 0.5 * math.noise(n.X * 8 + 5, n.Y * 8 + 6, n.Z * 8 + 7) > 0.12 end
local function plateOnSphere(folder, EC, n, r, w, color, material, transparency, thick) local p = EC + n * r return vpart({ Size = Vector3.new(w, w, thick or 2), CFrame = CFrame.lookAt(p, p + n), Color = color, Material = material or Enum.Material.SmoothPlastic, Transparency = transparency or 0 }, folder) end

local function buildStars(folder, GC) local palette = { Color3.fromRGB(190, 215, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 232, 190), Color3.fromRGB(255, 190, 140), Color3.fromRGB(160, 190, 255) } local bn = Vector3.new(0.35, 0.85, 0.4).Unit local e1 = bn:Cross(Vector3.yAxis).Unit local e2 = bn:Cross(e1).Unit local coreA = 1.2 local shell = GALAXY_RADIUS * 2.9 local detailed = false local function addStar(dir, radius, sizeScale) local s = (detailed and 12 or 18) + (math.random() ^ 3) * (detailed and 34 or 62) s *= sizeScale vpart({ Name = "DeepSpaceStar", Shape = Enum.PartType.Ball, Size = Vector3.one * s, Position = GC + dir * radius, Material = Enum.Material.Neon, Color = palette[math.random(1, #palette)], Transparency = math.random() * 0.18 }, folder) end local shellCount = detailed and 680 or 1100 for i = 1, shellCount do addStar(randDir(), shell + math.random() * GALAXY_RADIUS * 0.18, 0.8) if i % 170 == 0 then task.wait() end end local armCount = detailed and 980 or 1450 local made = 0 while made < armCount do local a = math.random() * math.pi * 2 local da = math.abs(((a - coreA + math.pi) % (math.pi * 2)) - math.pi) if math.random() < 0.35 + 0.65 * math.exp(-da * da / 0.9) then local dir = (e1 * math.cos(a) + e2 * math.sin(a) + bn * gauss() * 0.2).Unit addStar(dir, shell - GALAXY_RADIUS * 0.04 + math.random() * GALAXY_RADIUS * 0.14, 1 + 0.35 * math.exp(-da * da / 0.9)) made += 1 if made % 170 == 0 then task.wait() end end end local hazeCount = detailed and 22 or 38 local hazeColors = { Color3.fromRGB(100, 120, 255), Color3.fromRGB(255, 100, 170), Color3.fromRGB(255, 170, 90), Color3.fromRGB(110, 255, 230) } for i = 1, hazeCount do local a = math.random() * math.pi * 2 local dir = (e1 * math.cos(a) + e2 * math.sin(a) + bn * gauss() * 0.12).Unit bigSphere(folder, GC + dir * (GALAXY_RADIUS * 2.62), GALAXY_RADIUS * (0.045 + math.random() * 0.035), hazeColors[math.random(1, #hazeColors)], Enum.Material.Neon, 0.965 + math.random() * 0.025) end end

local function buildGalaxy(folder, GC) local ARMS, R = 4, GALAXY_RADIUS local textured = false local brightCount = textured and 560 or 1150 local dustCount = textured and 680 or 1050 for i = 1, brightCount do local arm = i % ARMS local tt = math.random() ^ 0.68 local r = tt *