-- 封存木材 · 加载器 v5 · Delta 稳定版
local SRC = {
	"https://raw.githubusercontent.com/moos294/jooiionn/main/%E5%BC%80%E4%BD%A0%E8%80%81%E5%86%AF.lua",
	"https://cdn.jsdelivr.net/gh/moos294/jooiionn@main/%E5%BC%80%E4%BD%A0%E8%80%81%E5%86%AF.lua",
	"https://cdn.jsdelivr.net/gh/moos294/jooiionn@main/开你老冯.lua",
}
local SIGN = "EXPECT = 206840"
local MIN = 150000
local box, lbl

local function say(text)
	if not box then
		pcall(function()
			local g = Instance.new("ScreenGui")
			g.Name = "FengcunLoad"
			g.IgnoreGuiInset = true
			g.ResetOnSpawn = false
			local ok = pcall(function() g.Parent = gethui() end)
			if not ok then ok = pcall(function() g.Parent = game:GetService("CoreGui") end) end
			if not ok then g.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
			local l = Instance.new("TextLabel")
			l.Size = UDim2.fromOffset(470, 58)
			l.Position = UDim2.new(0.5, -235, 0, 210)
			l.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			l.TextColor3 = Color3.fromRGB(20, 20, 20)
			l.TextSize = 17
			l.Font = Enum.Font.GothamBold
			l.TextWrapped = true
			l.Text = text
			l.Parent = g
			box, lbl = g, l
		end)
	end
	if lbl then pcall(function() lbl.Text = text end) end
end

say("v5 · 启动")
local done = false
task.spawn(function()
	task.wait(5)
	if not done then say("已等 5 秒 · 仍在下载…") end
	task.wait(10)
	if not done then say("已等 15 秒 · 网络可能被挡住") end
end)

local src, why = nil, "未尝试"
for i = 1, #SRC do
	say("第 " .. i .. "/" .. #SRC .. " 个源 · 下载中…")
	local ok, r = pcall(function() return game:HttpGet(SRC[i]) end)
	if ok and type(r) == "string" and #r >= MIN and string.find(r, SIGN, 1, true) then
		src = r
		break
	elseif not ok then
		why = "请求报错 · " .. tostring(r)
	elseif type(r) ~= "string" then
		why = "返回类型 " .. type(r)
	else
		why = "长度 " .. #r .. " · 指纹不符"
	end
end
done = true

if not src then
	say("下载失败 · " .. tostring(why):sub(1, 44))
	return
end

say("下载 OK · " .. #src .. " 字节 · 载入中…")
local f, e = loadstring(src)
if not f then
	say("编译失败 · " .. tostring(e):sub(1, 44))
	return
end

local ok, err = pcall(f)
if not ok then
	say("运行出错 · " .. tostring(err):sub(1, 44))
	return
end

task.delay(9, function()
	if box then pcall(function() box:Destroy() end) end
end)
