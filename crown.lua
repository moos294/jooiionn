local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library._windows = {}
Library.Version = "6.8.12"

local Themes = {
    Dark = { Primary = Color3.fromRGB(50, 173, 230), Accent = Color3.fromRGB(100, 210, 255) },
    Purple = { Primary = Color3.fromRGB(191, 90, 242), Accent = Color3.fromRGB(94, 92, 230) },
    Red = { Primary = Color3.fromRGB(255, 55, 95), Accent = Color3.fromRGB(255, 100, 130) }
}

local Theme = {
    Bg = Color3.fromRGB(6, 6, 8), Window = Color3.fromRGB(16, 16, 19), Sidebar = Color3.fromRGB(20, 20, 24),
    Card = Color3.fromRGB(26, 26, 31), CardHover = Color3.fromRGB(35, 35, 42), Track = Color3.fromRGB(33, 33, 39),
    TrackHover = Color3.fromRGB(42, 42, 50), Text = Color3.fromRGB(255, 255, 255), SubText = Color3.fromRGB(158, 158, 166),
    Muted = Color3.fromRGB(99, 99, 107), Border = Color3.fromRGB(48, 48, 55),
}

local function createInstance(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    if children then for _, c in ipairs(children) do c.Parent = inst end end
    return inst
end

local function tweenTo(inst, props, time)
    TS:Create(inst, TweenInfo.new(time or 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function addCorner(radius) return createInstance("UICorner", { CornerRadius = UDim.new(0, radius) }) end

local function getGuiParent()
    local gethui = getgenv and getgenv().gethui or gethui
    if type(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local player = Players.LocalPlayer
    return player and player:FindFirstChildOfClass("PlayerGui") or CoreGui
end

local function fitTextSize(props)
    return createInstance("TextLabel", {
        Text = props.Text or "", Size = props.Size or UDim2.new(1, 0, 1, 0),
        Position = props.Position or UDim2.new(), BackgroundTransparency = 1,
        TextColor3 = props.Color or Theme.Text, TextSize = props.TextSize or 14,
        Font = Enum.Font.BuilderSans, TextXAlignment = props.X or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center, TextWrapped = props.Wrapped or false,
        TextTruncate = props.Truncate or Enum.TextTruncate.None, ZIndex = props.ZIndex or 1
    })
end

function Library:CreateWindow(config)
    local cfg = config or {}
    local title = cfg.Title or "Rise"
    local theme = Themes[cfg.Theme or "Dark"] or Themes.Dark
    local size = cfg.Size or UDim2.fromOffset(600, 480)
    local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled
    if isMobile then size = UDim2.fromOffset(340, 460) end

    local Window = {
        Title = title, Theme = theme, IsMobile = isMobile,
        Tabs = {}, TabOrder = {}, ActiveTabName = "", Visible = true,
        _frameSize = size, _framePosition = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    }

    local sg = createInstance("ScreenGui", { Name = "RiseUI_Test", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = getGuiParent() })
    Window.ScreenGui = sg

    local main = createInstance("Frame", { Name = "Window", Size = size, Position = Window._framePosition, BackgroundColor3 = Theme.Window, BorderColor3 = Theme.Border, BorderSizePixel = 1, ClipsDescendants = true }, { addCorner(18) })
    main.Parent = sg
    Window.Frame = main

    local sidebar = createInstance("Frame", { Size = UDim2.new(0, isMobile and 120 or 160, 1, 0), BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0 }, { addCorner(18) })
    sidebar.Parent = main
    Window.Sidebar = sidebar

    local logo = createInstance("Frame", { Position = UDim2.new(0, 8, 0, 10), Size = UDim2.new(1, -8, 0, 38), BackgroundTransparency = 1, Parent = sidebar })
    fitTextSize({ Text = title, Size = UDim2.new(0, 100, 0, 36), TextSize = 20, Parent = logo })
    fitTextSize({ Text = "v" .. Library.Version, Position = UDim2.new(0, 100, 0, 10), Size = UDim2.new(0, 50, 0, 16), TextSize = 12, Color = theme.Primary, Parent = logo })

    local nav = createInstance("ScrollingFrame", { Position = UDim2.new(0, 0, 0, 60), Size = UDim2.new(1, 0, 1, -60), BackgroundTransparency = 1, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y }, { createInstance("UIListLayout", { Padding = UDim.new(0, 4) }) })
    nav.Parent = sidebar
    Window.Nav = nav

    local content = createInstance("Frame", { Position = UDim2.new(0, isMobile and 120 or 160, 0, 0), Size = UDim2.new(1, -(isMobile and 120 or 160), 1, 0), BackgroundTransparency = 1, ClipsDescendants = true })
    content.Parent = main

    local header = createInstance("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, Active = true })
    header.Parent = content
    Window.Header = header

    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    local closeBtn = createInstance("TextButton", { Text = "×", Position = UDim2.new(1, -34, 0, 8), Size = UDim2.fromOffset(26, 26), BackgroundTransparency = 1, TextColor3 = Theme.Text, TextSize = 20, Font = Enum.Font.BuilderSans })
    closeBtn.Parent = main
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    local scroll = createInstance("ScrollingFrame", { Position = UDim2.new(0, 0, 0, 54), Size = UDim2.new(1, -24, 1, -66), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageTransparency = 0.8, AutomaticCanvasSize = Enum.AutomaticSize.Y }, { createInstance("UIListLayout", { Padding = UDim.new(0, 7) }) })
    scroll.Parent = content
    Window.Scroll = scroll
    Window.List = scroll:FindFirstChildOfClass("UIListLayout").Parent

    function Window:SelectTab(tabName)
        self.ActiveTabName = tabName
        for _, v in ipairs(self.TabOrder) do
            local isSel = v.Name == tabName
            tweenTo(v.NavButton, { BackgroundTransparency = isSel and 0 or 1 }, 0.3)
            v.NavLabel.TextColor3 = isSel and Theme.Text or Theme.SubText
        end
        for _, child in ipairs(self.Scroll:GetChildren()) do
            if child:IsA("GuiObject") then child.Visible = false end
        end
        for _, mod in ipairs(self.Tabs[tabName].Modules) do
            mod.Card.Visible = true
            mod.Card.Parent = self.Scroll
        end
    end

    function Window:CreateTab(name)
        local tab = { Name = name, Modules = {} }
        self.Tabs[name] = tab
        table.insert(self.TabOrder, tab)

        local btn = createInstance("TextButton", { Text = "", Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = self.Theme.Accent, BackgroundTransparency = 1 }, { addCorner(100) })
        btn.Parent = self.Nav
        local lbl = fitTextSize({ Text = name, Position = UDim2.new(0, 22, 0, 0), Size = UDim2.new(1, -28, 1, 0), TextSize = 15, Color = Theme.SubText })
        lbl.Parent = btn
        tab.NavButton = btn; tab.NavLabel = lbl

        btn.MouseButton1Click:Connect(function() self:SelectTab(name) end)
        if #self.TabOrder == 1 then self:SelectTab(name) end
        return tab
    end
    return Window
end

function Library:CreateModule(window, tab, name, desc)
    local tabObj = window.Tabs[tab]
    if not tabObj then return end

    local card = createInstance("Frame", { Size = UDim2.new(1, 0, 0, 74), BackgroundColor3 = Color3.fromRGB(22, 25, 33), BackgroundTransparency = 0.4, BorderColor3 = Theme.Border, BorderSizePixel = 1, ClipsDescendants = true }, { addCorner(14), createInstance("UIListLayout") })
    local header = createInstance("TextButton", { Text = "", Size = UDim2.new(1, 0, 0, 74), BackgroundTransparency = 1 })
    header.Parent = card

    local titleLbl = fitTextSize({ Text = name, Position = UDim2.new(0, 12, 0, 9), Size = UDim2.new(0.8, 0, 0, 25), TextSize = 16 })
    titleLbl.Parent = header
    local descLbl = fitTextSize({ Text = desc or "", Position = UDim2.new(0, 12, 0, 39), Size = UDim2.new(1, -42, 0, 22), TextSize = 13, Color = Theme.SubText, Truncate = Enum.TextTruncate.AtEnd })
    descLbl.Parent = header

    local body = createInstance("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true }, { createInstance("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 14) }), createInstance("UIListLayout", { Padding = UDim.new(0, 1) }) })
    body.Parent = card

    local expanded = false
    local gear = createInstance("TextButton", { Text = "+", Position = UDim2.new(1, -42, 0, 23), Size = UDim2.new(0, 26, 0, 26), BackgroundColor3 = Theme.Track, BorderColor3 = Theme.Border, BorderSizePixel = 1, TextColor3 = Theme.SubText, TextSize = 16 }, { addCorner(100) })
    gear.Parent = header

    gear.MouseButton1Click:Connect(function()
        expanded = not expanded
        gear.Rotation = expanded and 45 or 0
        tweenTo(body, { Size = expanded and UDim2.new(1, 0, 0, body.UIListLayout.AbsoluteContentSize.Y + 26) or UDim2.new(1, 0, 0, 0) }, 0.2)
    end)

    local mod = { Card = card, Window = window, Tab = tab }
    table.insert(tabObj.Modules, mod)

    function mod:AddToggle(txt, def, cb)
        local row = createInstance("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = body })
        fitTextSize({ Text = txt, Size = UDim2.new(1, -30, 1, 0), Parent = row })
        local btn = createInstance("TextButton", { Position = UDim2.new(1, -24, 0.5, -7), Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = def and window.Theme.Primary or Theme.Track, BorderColor3 = def and window.Theme.Primary or Theme.Muted, BorderSizePixel = 1 }, { addCorner(100), Parent = row })
        local state = def
        btn.MouseButton1Click:Connect(function()
            state = not state
            tweenTo(btn, { BackgroundColor3 = state and window.Theme.Primary or Theme.Track }, 0.15)
            btn.BorderColor3 = state and window.Theme.Primary or Theme.Muted
            if cb then cb(state) end
        end)
    end

    function mod:AddButton(txt, cb)
        local row = createInstance("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = body })
        local lbl = fitTextSize({ Text = txt, Size = UDim2.new(1, 0, 1, 0), Parent = row })
        row.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then if cb then cb() end end end)
        row.MouseEnter:Connect(function() lbl.TextColor3 = window.Theme.Primary end)
        row.MouseLeave:Connect(function() lbl.TextColor3 = Theme.Text end)
    end

    function mod:AddSlider(txt, min, max, def, cb)
        local row = createInstance("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Parent = body })
        fitTextSize({ Text = txt, Size = UDim2.new(0.5, 0, 1, 0), Parent = row })
        local track = createInstance("TextButton", { Text = "", Position = UDim2.new(0.5, 0, 0.5, -4), Size = UDim2.new(0.5, -40, 0, 8), BackgroundColor3 = Theme.Track, BorderSizePixel = 0 }, { addCorner(100), Parent = row })
        local fill = createInstance("Frame", { Size = UDim2.new((def-min)/(max-min), 0, 1, 0), BackgroundColor3 = window.Theme.Primary, BorderSizePixel = 0 }, { addCorner(100), Parent = track })
        local valLbl = fitTextSize({ Text = tostring(def), Position = UDim2.new(1, -32, 0, 0), Size = UDim2.new(0, 30, 1, 0), X = Enum.TextXAlignment.Right, Parent = row })
        
        local dragging = false
        track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
        UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local p = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            tweenTo(fill, { Size = UDim2.new(p, 0, 1, 0) }, 0.1)
            local val = math.floor((min + (max - min) * p) / 1) * 1
            valLbl.Text = tostring(val)
            if cb then cb(val) end
        end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    end
    
    return mod
end

local success, err = pcall(function()
    local win = Library:CreateWindow({ Title = "纯UI测试", Theme = "Dark" })
    local tab = win:CreateTab("测试页")
    local mod = Library:CreateModule(win, "测试页", "这是一个测试模块", "点击右上角 + 展开")
    
    mod:AddToggle("测试开关", true, function(s)
        print("开关状态:", s)
    end)
    mod:AddButton("测试按钮", function()
        print("按钮被点击了！")
    end)
    mod:AddSlider("测试滑动条", 0, 100, 50, function(v)
        print("滑块值:", v)
    end)
end)

if not success then
    warn("UI 加载失败: " .. tostring(err))
end