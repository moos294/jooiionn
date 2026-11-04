local success, err = pcall(function()
    local Window = Library:CreateWindow({
        Title = "测试成功！",
        Version = "v1.0",
        Theme = "Pastel"
    })

    local Tab = Window:CreateTab("测试页面")
    local Mod = Tab:CreateModule("基础测试", "测试按钮是否正常")

    Mod:CreateButton("点击我测试", function()
        print("牛逼！按钮点击成功了！")
    end)

    Mod:CreateToggle("测试开关", false, function(state)
        print("开关状态改变了:", state)
    end)
end)

if not success then
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local lbl = Instance.new("TextLabel", sg)
    lbl.Size = UDim2.new(0, 800, 0, 200)
    lbl.Position = UDim2.new(0.5, -400, 0.5, -100)
    lbl.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextSize = 20
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = "UI创建失败，报错信息:\n" .. tostring(err)
end