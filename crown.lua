local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local children = workspace:GetChildren()
for k, value1 in pairs(children) do
	local result = value1.Name:lower()
	if result:find("windui") then
		value1:Destroy()
	end
end

local response = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
local WindUI = loadstring(response)()

WindUI:AddTheme({
	Name = "NB29Neon",
	Text = Color3.fromHex("#FFFFFF"),
	Accent = Color3.fromHex("#00FFA3"),
	Background = Color3.fromHex("#0B1020"),
	Button = Color3.fromHex("#14233f"),
	Icon = Color3.fromHex("#00FFA3"),
	Outline = Color3.fromHex("#00E0FF"),
	Placeholder = Color3.fromHex("#7fdfff")
})

local Window = WindUI:CreateWindow({
	Title = "力量之冠封存4.0",
	Author = "力量之冠",
	Folder = "PowerCrownV5",
	HideSearchBar = true,
	Icon = "zap",
	MaxSize = Vector2.new(520, 420),
	MinSize = Vector2.new(520, 420),
	NoResize = true,
	OpenButton = {
		Title = "打开面板",
		Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")), ColorSequenceKeypoint.new(0.16, Color3.fromHex("FF7F00")), ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")), ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")), ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")), ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")), ColorSequenceKeypoint.new(1, Color3.fromHex("9400D3"))) }),
		CornerRadius = UDim.new(0, 16),
		Draggable = true,
		Enabled = true,
		Icon = "zap",
		StrokeThickness = 3
	},
	Resizable = false,
	ScrollBarEnabled = true,
	SideBarWidth = 140,
	Size = UDim2.fromOffset(520, 420),
	Theme = "NB29Neon",
	Transparent = false
})

Window:Tag({ Title = "封存版", Color = Color3.fromHex("#00FFA3") })
Window:Tag({ Title = "29 UI 框架", Color = Color3.fromHex("#FFD400") })

task.spawn(function()
	task.wait(0.5)
	local PlayerGui = player:WaitForChild("PlayerGui")
	local children2 = PlayerGui:GetChildren()
	for k2, value2 in pairs(children2) do
		local result3 = value2.Name:lower()
		if result3:find("wind") then
			local descendants = value2:GetDescendants()
			for k3, descendant in pairs(descendants) do
				pcall(function()
					descendant.Size = UDim2.fromOffset(520, 420)
					descendant.MinSize = Vector2.new(520, 420)
					descendant.MaxSize = Vector2.new(520, 420)
				end)
			end
		end
	end
end)

local targetPosition = nil
local isTargeting = false
local Tab = Window:Tab({ Title = "娱乐大炮", Icon = "crosshair" })

Tab:Paragraph({ Title = "操作提示", Desc = "请先点击【选择目标】，在游戏里点一下地面，最后点击发射！" })

Tab:Button({
	Title = "1. 🎯 选择发射目标",
	Callback = function()
		isTargeting = true
		WindUI:Notify({ Title = "提示", Content = "请在游戏画面中点击地面！", Duration = 3 })
	end
})

Tab:Button({
	Title = "2. ☄️ 发射：星际轨道炮",
	Color = Color3.fromHex("#FF4444"),
	Callback = function()
		if not targetPosition then WindUI:Notify({ Title = "错误", Content = "请先选择目标！", Duration = 3 }) return end
		if _G.TriggerStarDestroyer then _G.TriggerStarDestroyer(targetPosition) end
	end
})

Tab:Button({
	Title = "3. 🪐 发射：土星/木星网格炮",
	Color = Color3.fromHex("#FF9500"),
	Callback = function()
		if not targetPosition then WindUI:Notify({ Title = "错误", Content = "请先选择目标！", Duration = 3 }) return end
		if _G.TriggerJupiter then _G.TriggerJupiter(targetPosition) end
	end
})

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if isTargeting then
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local ray = camera:ViewportPointToRay(input.Position.X, input.Position.Y)
			local res = Workspace:Raycast(ray.Origin, ray.Direction * 2000)
			if res then
				targetPosition = res.Position
				local mk = Instance.new("Part")
				mk.Shape = Enum.PartType.Ball mk.Material = Enum.Material.Neon
				mk.Color = Color3.fromRGB(255, 0, 0) mk.Size = Vector3.new(14, 14, 14)
				mk.Position = targetPosition + Vector3.new(0, 5, 0) mk.Anchored = true mk.CanCollide = false mk.Parent = Workspace
				Debris:AddItem(mk, 10)
				isTargeting = false
				WindUI:Notify({ Title = "锁定成功", Content = "目标已标定，请点击发射！", Duration = 3 })
			end
		end
		return
	end
end)
local fxFolder = Instance.new("Folder")
fxFolder.Name = "SpaceCannonFX"
fxFolder.Parent = Workspace

local function new(class, props, parent) local inst = Instance.new(class) for k, v in pairs(props) do inst[k] = v end if parent then inst.Parent = parent end return inst end
local function vpart(props, parent) local p = new("Part", { Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false, Material = Enum.Material.SmoothPlastic, TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth }, nil) for k, v in pairs(props) do p[k] = v end p.Parent = parent return p end
local function clamp01(x) return math.clamp(x, 0, 1) end
local function tween(inst, time, props, style, dir) local tw = TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props) tw:Play() return tw end
local function smooth(t) t = clamp01(t) return t * t * (3 - 2 * t) end
local function gauss() return math.random() + math.random() + math.random() - 1.5 end
local function rotY(v, a) return CFrame.Angles(0, a, 0):VectorToWorldSpace(v) end
local function randDir() local z = math.random() * 2 - 1 local a = math.random() * math.pi * 2 local r = math.sqrt(1 - z * z) return Vector3.new(r * math.cos(a), z, r * math.sin(a)) end

local flash = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 100, Active = false }, player.PlayerGui:FindFirstChildOfClass("ScreenGui"))
local function setFlash(a, color) flash.BackgroundColor3 = color or Color3.new(1, 1, 1) flash.BackgroundTransparency = 1 - clamp01(a) end
local impactFlash = { t = -1e9, a = 0 } local impactShake = { t = -1e9, amp = 0 }
local function impactFlashValue() local e = os.clock() - impactFlash.t if e < 0 or e > 0.62 then return 0 end local rise = math.clamp(e / 0.045, 0, 1) local fall = math.clamp(1 - math.max(0, e - 0.045) / 0.575, 0, 1) return impactFlash.a * rise * fall * fall end
local function impactShakeAmount() local e = os.clock() - impactShake.t if e < 0 or e > 3.5 then return 0 end return impactShake.amp * (1 - e / 3.5) ^ 2 end
local function shakeCF(cf, amp, t, rotAmp) if amp <= 0.001 then return cf end local nx = math.noise(t * 23, 1.3, 0) * 2 local ny = math.noise(t * 27, 5.1, 0) * 2 local nz = math.noise(t * 19, 9.7, 0) * 2 return cf * CFrame.new(nx * amp, ny * amp, 0) * CFrame.Angles(ny * rotAmp, nx * rotAmp, nz * rotAmp * 0.5) end
local wasShaking = false
local barTop = new("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 90 }, player.PlayerGui:FindFirstChildOfClass("ScreenGui"))
local barBottom = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 90 }, player.PlayerGui:FindFirstChildOfClass("ScreenGui"))
local function showBars(on) local s = UDim2.new(1, 0, on and 0.1 or 0, 0) tween(barTop, 0.8, { Size = s }) tween(barBottom, 0.8, { Size = s }) end
local caption = new("TextLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0.9, 0), Size = UDim2.new(0.9, 0, 0, 40), BackgroundTransparency = 1, Text = "", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 22, TextTransparency = 1, TextStrokeTransparency = 0.6, ZIndex = 95 }, player.PlayerGui:FindFirstChildOfClass("ScreenGui"))
local function setCaption(text, color) if text == "" then tween(caption, 0.4, { TextTransparency = 1 }) return end caption.Text = text caption.TextColor3 = color or Color3.new(1, 1, 1) caption.TextTransparency = 1 tween(caption, 0.4, { TextTransparency = 0 }) end
local SOUNDS = { lock = { fallback = "rbxasset://sounds/electronicpingshort.wav" }, whoosh = { fallback = "rbxasset://sounds/Rocket whoosh 01.wav" }, charge = { fallback = "rbxasset://sounds/Rocket whoosh 01.wav" }, fire = { fallback = "rbxasset://sounds/Rocket shot.wav" }, boom = { fallback = "rbxasset://sounds/impact_explosion_03.mp3" } }
local function playSound(id, volume, speed, looped) if type(id) == "table" then id = id.fallback end if not id or id == "" then return nil end local s = new("Sound", { SoundId = id, Volume = volume or 1, PlaybackSpeed = speed or 1, Looped = looped or false }, game:GetService("SoundService")) pcall(function() s:Play() end) if not looped then Debris:AddItem(s, 10) end return s end
local fx = {}
local function ensureFx() if fx.cc then return end fx.cc = new("ColorCorrectionEffect", { Name = "SC_CC" }, Lighting) fx.bloom = new("BloomEffect", { Name = "SC_Bloom", Intensity = 0.5, Size = 28, Threshold = 1 }, Lighting) fx.blur = new("BlurEffect", { Name = "SC_Blur", Size = 0 }, Lighting) end
local function clearFx() for k, v in pairs(fx) do v:Destroy() fx[k] = nil end end
local function setControls(enabled) pcall(function() local pm = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")) local c = pm:GetControls() if enabled then c:Enable() else c:Disable() end end) end
local function setCoreGui(enabled) pcall(function() game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, enabled) end) end
local state = "idle" local lastFire = -1e9
local DANGER_RADIUS = 480 local CRATER_RADIUS = 480 local CRATER_DEPTH = 185 local RIM_WIDTH = 190 local RIM_HEIGHT = 96 local CELL = 12 local SPACE_ORIGIN = Vector3.new(0, 300000, 0) local EARTH_RADIUS = 80 local GALAXY_RADIUS = 34000 local SUN_RADIUS = 1400 local EARTH_ORBIT_RADIUS = 3600 local T = { lockEnd = 2, ascentEnd = 6, orbitEnd = 12, moonEnd = 15, marsEnd = 18, jupiterEnd = 21, solarSystemEnd = 24, pullEnd = 28, holdEnd = 32, swoopEnd = 38, fireT = 42, groundT = 45, imp = 47, endT = 52 }
local NK = NumberSequenceKeypoint.new local FLAT = CFrame.Angles(0, 0, math.rad(90)) local RED = Color3.fromRGB(255, 56, 56)
local function bigSphere(parent, pos, diameter, color, material, transparency) local p if diameter <= 2048 then p = vpart({ Shape = Enum.PartType.Ball, Size = Vector3.one * diameter, Position = pos, Color = color, Material = material, Transparency = transparency }, parent) else p = vpart({ Size = Vector3.one * 2048, Position = pos, Color = color, Material = material, Transparency = transparency }, parent) new("SpecialMesh", { MeshType = Enum.MeshType.Sphere, Scale = Vector3.one * (diameter / 2048) }, p) end return p end
local function landAt(n) return math.noise(n.X * 2.1 + 3.7, n.Y * 2.1 + 1.3, n.Z * 2.1 + 8.1) + 0.45 * math.noise(n.X * 5 + 1, n.Y * 5 + 2, n.Z * 5 + 3) > 0.04 end
local function cloudAt(n) return math.noise(n.X * 3.3 + 9.1, n.Y * 3.3 + 4.2, n.Z * 3.3 + 2.7) + 0.5 * math.noise(n.X * 8 + 5, n.Y * 8 + 6, n.Z * 8 + 7) > 0.12 end
local function plateOnSphere(folder, EC, n, r, w, color, material, transparency, thick) local p = EC + n * r return vpart({ Size = Vector3.new(w, w, thick or 2), CFrame = CFrame.lookAt(p, p + n), Color = color, Material = material or Enum.Material.SmoothPlastic, Transparency = transparency or 0 }, folder) end

local function buildStars(folder, GC) local palette = { Color3.fromRGB(190, 215, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 232, 190), Color3.fromRGB(255, 190, 140), Color3.fromRGB(160, 190, 255) } local bn = Vector3.new(0.35, 0.85, 0.4).Unit local e1 = bn:Cross(Vector3.yAxis).Unit local e2 = bn:Cross(e1).Unit local coreA = 1.2 local shell = GALAXY_RADIUS * 2.9 local detailed = false local function addStar(dir, radius, sizeScale) local s = (detailed and 12 or 18) + (math.random() ^ 3) * (detailed and 34 or 62) s *= sizeScale vpart({ Name = "DeepSpaceStar", Shape = Enum.PartType.Ball, Size = Vector3.one * s, Position = GC + dir * radius, Material = Enum.Material.Neon, Color = palette[math.random(1, #palette)], Transparency = math.random() * 0.18 }, folder) end local shellCount = detailed and 680 or 1100 for i = 1, shellCount do addStar(randDir(), shell + math.random() * GALAXY_RADIUS * 0.18, 0.8) if i % 170 == 0 then task.wait() end end local armCount = detailed and 980 or 1450 local made = 0 while made < armCount do local a = math.random() * math.pi * 2 local da = math.abs(((a - coreA + math.pi) % (math.pi * 2)) - math.pi) if math.random() < 0.35 + 0.65 * math.exp(-da * da / 0.9) then local dir = (e1 * math.cos(a) + e2 * math.sin(a) + bn * gauss() * 0.2).Unit addStar(dir, shell - GALAXY_RADIUS * 0.04 + math.random() * GALAXY_RADIUS * 0.14, 1 + 0.35 * math.exp(-da * da / 0.9)) made += 1 if made % 170 == 0 then task.wait() end end end local hazeCount = detailed and 22 or 38 local hazeColors = { Color3.fromRGB(100, 120, 255), Color3.fromRGB(255, 100, 170), Color3.fromRGB(255, 170, 90), Color3.fromRGB(110, 255, 230) } for i = 1, hazeCount do local a = math.random() * math.pi * 2 local dir = (e1 * math.cos(a) + e2 * math.sin(a) + bn * gauss() * 0.12).Unit bigSphere(folder, GC + dir * (GALAXY_RADIUS * 2.62), GALAXY_RADIUS * (0.045 + math.random() * 0.035), hazeColors[math.random(1, #hazeColors)], Enum.Material.Neon, 0.965 + math.random() * 0.025) end end
local function buildGalaxy(folder, GC) local ARMS, R = 4, GALAXY_RADIUS local textured = false local brightCount = textured and 560 or 1150 local dustCount = textured and 680 or 1050 for i = 1, brightCount do local arm = i % ARMS local tt = math.random() ^ 0.68 local r = tt * R + 120 * math.random() local ang = arm * (2 * math.pi / ARMS) + tt * 4.6 + gauss() * 0.19 * (1.2 - tt) local rr = r + gauss() * R * 0.018 * (0.4 + tt) local pos = GC + Vector3.new(math.cos(ang) * rr, 78 + gauss() * (R * 0.008 * (1 - tt) + 18), math.sin(ang) * rr) local size = (18 + math.random() * 66) * (1.1 - 0.42 * tt) local col = Color3.fromRGB(255, 225, 170):Lerp(Color3.fromRGB(255, 140, 150), clamp01(tt * 1.6)):Lerp(Color3.fromRGB(110, 150, 255), clamp01((tt - 0.5) * 2)) vpart({ Name = "GalacticArmStar", Shape = Enum.PartType.Ball, Size = Vector3.one * size, Position = pos, Material = Enum.Material.Neon, Color = col, Transparen