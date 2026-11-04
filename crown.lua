local urls = {
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    "https://github.com/Footagesus/WindUI/releases/download/1.6.41/main.lua"
}

local WindUI = nil
local lastErr = ""

for _, url in ipairs(urls) do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if ok and res then
        WindUI = res
        break
    else
        lastErr = tostring(res)
    end
end

local function showMsg(text, isError)
    local sg = Instance.new("ScreenGui")
    sg.Parent = game:GetService("CoreGui")
    local t = Instance.new("TextLabel")
    t.Parent = sg
    t.Size = UDim2.new(0, 600, 0, 120)
    t.Position = UDim2.new(0.5, -300, 0.5, -60)
    t.BackgroundColor3 = isError and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 200, 0)
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 18
    t.TextWrapped = true
    t.Text = text
    task.wait(8)
    sg:Destroy()
end

if not WindUI then
    showMsg("所有链接均失败! 最后错误: " .. lastErr, true)
    return
end

local ok, err = pcall(function()
    local Window = WindUI:CreateWindow({
        Title = "测试成功",
        Author = "备用链接",
        Folder = "BaiTest",
        Size = UDim2.fromOffset(450, 300),
        Theme = "Dark",
    })
    local Tab = Window:Tab({ Title = "测试", Icon = "home" })
    Tab:Button({ Title = "点我", Callback = function() showMsg("WindUI 完美运行!", false) end })
end)

if not ok then
    showMsg("窗口创建失败: " .. tostring(err), true)
end