local successLoad, WindUIorErr = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

local function showScreenMessage(text, isError)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = game:GetService("CoreGui")
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = screenGui
    textLabel.Size = UDim2.new(0, 600, 0, 100)
    textLabel.Position = UDim2.new(0.5, -300, 0.5, -50)
    textLabel.BackgroundColor3 = isError and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 200, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 20
    textLabel.TextWrapped = true
    textLabel.Text = text
    task.wait(8)
    screenGui:Destroy()
end

if not successLoad then
    showScreenMessage("WindUI 加载失败! 错误信息: " .. tostring(WindUIorErr), true)
    return
end

local WindUI = WindUIorErr

local successWin, errWin = pcall(function()
    local Window = WindUI:CreateWindow({
        Title = "白Hub-极简测试版",
        Author = "网络测试",
        Folder = "BaiTest",
        Size = UDim2.fromOffset(450, 300),
        Theme = "Dark",
    })
    
    local Tab = Window:Tab({ Title = "测试页面", Icon = "home" })
    
    Tab:Button({ 
        Title = "点我测试", 
        Callback = function() 
            showScreenMessage("按钮点击成功！WindUI 已经完美复活！", false)
        end 
    })
end)

if not successWin then
    showScreenMessage("WindUI 界面创建失败! 错误信息: " .. tostring(errWin), true)
end