-- 封存木材 · 加载器 v9 · 失败时显示仓库里的实际内容
local SRC = {
	"https://raw.githubusercontent.com/moos294/jooiionn/main/kai.lua",
	"https://cdn.jsdelivr.net/gh/moos294/jooiionn@main/kai.lua",
	"https://raw.githubusercontent.com/moos294/jooiionn/main/%E5%BC%80%E4%BD%A0%E8%80%81%E5%86%AF.lua",
}
local SIGN = "EXPECT = 206840"
local MIN = 150000
local box, lbl, SS

local function beep(kind)
	pcall(function()
		SS = SS or game:GetService("SoundService")
		local s = Instance.new("Sound")
		s.SoundId = "rbxasset://sounds/electronicpingshort.wav"
		if kind == "ok" then
			s.PlaybackSpeed = 1.3
			s.Volume = 0.5
		elseif kind == "bad" then
			s.PlaybackSpeed = 0.55
			s.Volume = 0.55
		else
			s.PlaybackSpeed = 0.95
			s.Volume = 0.28
		end
		local played = pcall(function() SS:PlayLocalSound(s) end)
		if not played then
			pcall(function()
				s.Parent = SS
				s:Play()
			end)
		end
		task.delay(4, function() pcall(function() s:Destroy() end) end)
	end)
end

local function attach(g)
	local fns = {
		function() return game:GetService("CoreGui") end,
		function() return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end,
		function() return gethui() end,
	}
	for i = 1, #fns do
		local ok, p = pcall(fns[i])
		if ok and p ~= nil then
			pcall(function() g.Parent = p end)
			if g.Parent ~= nil then return true end
		end
	end
	return false
end

local function say(text, kind)
	print("[封存木材] " .. text)
	if not box then
		pcall(function()
			local g = Instance.new("ScreenGui")
			g.Name = "FengcunLoad"
			g.IgnoreGuiInset = true
			g.ResetOnSpawn = false
			g.DisplayOrder = 999
			if attach(g) then
				local l = Instance.new("TextLabel")
				l.Size = UDim2.fromOffset(500, 64)
				l.Position = UDim2.new(0.5, -250, 0, 150)
				l.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				l.TextColor3 = Color3.fromRGB(20, 20, 20)
				l.TextSize = 16
				l.Font = Enum.Font.GothamBold
				l.TextWrapped = true
				l.Text = text
				l.Parent = g
				box, lbl = g, l
			end
		end)
	end
	if lbl then pcall(function() lbl.Text = text end) end
	if kind then beep(kind) end
end

say("v9 · 启动", "info")
local done = false
task.spawn(function()
	task.wait(6)
	if not done then say("已等 6 秒 · 仍在下载…", "info") end
	task.wait(10)
	if not done then say("已等 16 秒 · 网络可能被挡住", "info") end
end)

local src, why, head = nil, "未尝试", ""
for i = 1, #SRC do
	say("第 " .. i .. "/" .. #SRC .. " 个源 · 下载中…", "info")
	local ok, r = pcall(function() return game:HttpGet(SRC[i]) end)
	if ok and type(r) == "string" and #r >= MIN and string.find(r, SIGN, 1, true) then
		src = r
		break
	elseif not ok then
		why = "请求报错 " .. tostring(r)
	elseif type(r) ~= "string" then
		why = "返回类型 " .. type(r)
	else
		why = #r .. " 字节 · 非密文"
		head = tostring(r):sub(1, 22):gsub("%s+", " ")
	end
end
done = true

if not src then
	local msg = "下载失败 · " .. tostring(why):gsub("[%c]", " ")
	if head ~= "" then msg = msg .. " · " .. head end
	say(msg:sub(1, 70), "bad")
	return
end

say("下载 OK · " .. #src .. " 字节 · 载入中…", "info")
local f, e = loadstring(src)
if not f then
	say("编译失败 · " .. tostring(e):sub(1, 44), "bad")
	return
end

local ok, err = pcall(f)
if not ok then
	say("运行出错 · " .. tostring(err):sub(1, 44), "bad")
	return
end

say("全部完成", "ok")
task.delay(9, function()
	if box then pcall(function() box:Destroy() end) end
end)