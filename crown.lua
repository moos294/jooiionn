local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local Mouse = player:GetMouse()
local CoreGui = game:GetService("CoreGui")

local WhitelistURL = "https://raw.githubusercontent.com/moos294/jooiionn/main/whitelist.txt" 

local function CheckWhitelist()
    local success, response = pcall(function() return game:HttpGet(WhitelistURL) end)
    if not success or not response then return false end
    if string.find(response, player.Name) or string.find(response, tostring(player.UserId)) then return true end
    return false
end

if not CheckWhitelist() then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "系统提示", Text = "你并没有白名单无法用此脚本", Duration = 5})
    return 
end

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "验证成功", Text = "欢迎尊贵的白名单使用此脚本", Duration = 5})

local isDragEnabled = false
local dragConn = nil

local function CleanupAll()
    isDragEnabled = false
    if dragConn then dragConn:Disconnect() dragConn = nil end
    for i = 1, 3 do
        local bringPoint = Workspace:FindFirstChild("BRING"..i)
        if bringPoint then bringPoint:Destroy() end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild("点击传送") then backpack["点击传送"]:Destroy() end
    local char = player.Character
    if char and char:FindFirstChild("点击传送") then char["点击传送"]:Destroy() end
    local oldGui = CoreGui:FindFirstChild("封存木材")
    if oldGui then oldGui:Destroy() end
end

CleanupAll()

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存木材 v2.5",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Size = UDim2.fromOffset(420, 420),
    Transparent = true,
    Theme = "Dark"
})

local function GetMoney()
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        for _, v in pairs(stats:GetChildren()) do
            if v.Name == "Money" or v.Name == "Cash" or v.Name == "Gold" then
                return v.Value
            end
        end
    end
    return 0 
end

local function FormatPrice(price)
    local p = tonumber(price) or 0
    if p >= 1e12 then
        return string.format("%.1fT", p / 1e12):gsub("%.0T", "T")
    elseif p >= 1e8 then
        return string.format("%.1f亿", p / 1e8):gsub("%.0亿", "亿")
    elseif p >= 1e7 then
        return string.format("%.1f千万", p / 1e7):gsub("%.0千万", "千万")
    elseif p >= 1e6 then
        return string.format("%.1f百万", p / 1e6):gsub("%.0百万", "百万")
    elseif p >= 1e4 then
        return string.format("%.1f万", p / 1e4):gsub("%.0万", "万")
    else
        return tostring(p)
    end
end

local function DragModel(m, cf)
    pcall(function() 
        RS.Interaction.ClientIsDragging:FireServer(m)
    end)
    if not m.PrimaryPart then m.PrimaryPart = m:FindFirstChildOfClass("Part") end
    if m.PrimaryPart then 
        m.PrimaryPart.Velocity = Vector3.zero
        m:SetPrimaryPartCFrame(cf) 
    end
end

local TabBuy = Window:Tab({ Title = "神秘箱子购买", Icon = "rbxassetid://10734945123" })
local buyAmount = 1
local cratePrice = 75000000

local PriceLabel = TabBuy:Paragraph({
    Title = "购买详情",
    Desc = "计算中...",
    Color = Color3.fromRGB(255, 200, 0)
})

local function UpdatePriceUI()
    local total = cratePrice * buyAmount
    PriceLabel:SetDesc(string.format("单价: %s | 数量: %d | 总价: %s | 当前余额: %s", FormatPrice(cratePrice), buyAmount, FormatPrice(total), FormatPrice(GetMoney())))
end

UpdatePriceUI()

TabBuy:Slider({
    Title = "购买数量 (最大3个)",
    Value = { Min = 1, Max = 3, Default = 1 },
    Callback = function(val)
        buyAmount = val
        UpdatePriceUI()
    end
})

local function SetupStore()
    local oldpos = player.Character.HumanoidRootPart.CFrame
    local storeFolder = Workspace:WaitForChild("Stores", 10)
    local shopModel = storeFolder and storeFolder:FindFirstChild("FineFinds")
    
    if not shopModel then
        WindUI:Notify({ Title = "加载中", Content = "正在传送加载商店...", Duration = 3 })
        player.Character.HumanoidRootPart.CFrame = CFrame.new(175, 22, 180)
        task.wait(2)
        shopModel = storeFolder:WaitForChild("FineFinds", 10)
    end
    
    if not shopModel then return nil, nil, nil, oldpos end
    
    local npcModel = shopModel:WaitForChild("Manachron", 5)
    local npcDialog = npcModel:WaitForChild("Dialog", 5)
    
    local targetBox = nil
    local targetCounter = nil
    
    for _, v in next, shopModel:GetDescendants() do
        if v.Name == "Counter" or v.Name == "counter" then targetCounter = v end
        if v.Name == "ShopItems" then
            for _, box in next, v:GetChildren() do
                local nameObj = box:FindFirstChild("BoxItemName") or (box:FindFirstChild("Configuration") and box.Configuration:FindFirstChild("BoxItemName"))
                if nameObj and nameObj.Value == "Crate" then
                    targetBox = box
                end
            end
        end
    end
    
    return targetBox, targetCounter, npcModel, npcDialog, oldpos
end

TabBuy:Button({
    Title = "开始购买神秘箱子 (全自动)",
    Desc = "唤醒对话 + 单参拖拽 + 扣钱检测",
    Callback = function()
        local startMoney = GetMoney()
        local totalPrice = cratePrice * buyAmount
        
        if startMoney < totalPrice then
            WindUI:Notify({ Title = "余额不足", Content = "你的钱不够！需要 " .. FormatPrice(totalPrice) .. "，你只有 " .. FormatPrice(startMoney), Duration = 5 })
            return
        end
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        task.spawn(function()
            local targetBox, targetCounter, npcModel, npcDialog, oldpos = SetupStore()
            if not targetBox or not targetCounter then
                WindUI:Notify({ Title = "失败", Content = "商店未找到", Duration = 4 })
                return
            end
            
            for i = 1, buyAmount do
                WindUI:Notify({ Title = "购买中", Content = "正在购买第 " .. i .. "/" .. buyAmount .. " 个", Duration = 2 })
                
                player.Character.HumanoidRootPart.CFrame = targetCounter.CFrame + Vector3.new(0, 3, 3)
                task.wait(0.3)
                
                local boxCF = targetCounter.CFrame + Vector3.new(0, 1, 0)
                for j = 1, 15 do
                    DragModel(targetBox, boxCF)
                    task.wait(0.05)
                end
                task.wait(0.5)
                
                local expectedMoney = GetMoney()
                local buySuccess = false
                local timeout = 0
                
                pcall(function() RS.NPCDialog.SetChattingValue:InvokeServer(1) end)
                task.wait(0.1)
                pcall(function() RS.NPCDialog.SetChattingValue:InvokeServer(2) end)
                task.wait(0.1)
                
                while not buySuccess and timeout < 4 do
                    for tryID = 1, 30 do
                        task.spawn(function()
                            pcall(function()
                                local args = {
                                    {
                                        ID = tryID,
                                        Character = npcModel,
                                        Name = "Manachron",
                                        Dialog = npcDialog
                                    },
                                    "ConfirmPurchase"
                                }
                                RS.NPCDialog.PlayerChatted:InvokeServer(unpack(args))
                            end)
                        end)
                        task.wait(0.02)
                    end
                    
                    task.wait(0.2)
                    timeout = timeout + 0.2
                    
                    if GetMoney() < expectedMoney then
                        buySuccess = true
                        break
                    end
                end
                
                pcall(function() RS.NPCDialog.SetChattingValue:InvokeServer(0) end)
                
                if buySuccess then
                    WindUI:Notify({ Title = "购买成功", Content = "钱已扣！正在拉回...", Duration = 2 })
                    task.wait(0.3)
                    for j = 1, 30 do
                        DragModel(targetBox, oldpos + Vector3.new(0, 3, 0))
                        task.wait(0.02)
                    end
                    WindUI:Notify({ Title = "大功告成", Content = "实体箱子已拉回！", Duration = 4 })
                else
                    WindUI:Notify({ Title = "购买失败", Content = "未扣钱，请尝试下方【半自动】", Duration = 4 })
                    break
                end
            end
            player.Character.HumanoidRootPart.CFrame = oldpos
            UpdatePriceUI()
        end)
    end
})

TabBuy:Button({
    Title = "准备购买 (半自动)",
    Desc = "自动拉实体并开启对话，你手动点购买",
    Callback = function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        task.spawn(function()
            local targetBox, targetCounter, npcModel, npcDialog, oldpos = SetupStore()
            if not targetBox or not targetCounter then
                WindUI:Notify({ Title = "失败", Content = "商店未找到", Duration = 4 })
                return
            end
            
            player.Character.HumanoidRootPart.CFrame = targetCounter.CFrame + Vector3.new(0, 3, 3)
            task.wait(0.3)
            
            local boxCF = targetCounter.CFrame + Vector3.new(0, 1, 0)
            for j = 1, 15 do
                DragModel(targetBox, boxCF)
                task.wait(0.05)
            end
            
            task.wait(0.5)
            pcall(function() RS.NPCDialog.SetChattingValue:InvokeServer(1) end)
            task.wait(0.1)
            pcall(function() RS.NPCDialog.SetChattingValue:InvokeServer(2) end)
            
            WindUI:Notify({ Title = "准备就绪", Content = "实体已放好且对话已开启，请手动点击购买！", Duration = 5 })
        end)
    end
})

local TabTP = Window:Tab({ Title = "安全传送", Icon = "rbxassetid://10734945123" })
local targetTree = "Generic"
local playerPos = {nil, nil, nil}

local tree_list = {"普通木 (Generic)", "幻影木 (LoneCave)", "电木 (Electric)", "橡木 (Oak)", "冰木 (Ice)"}

TabTP:Dropdown({
    Title = "选择树木种类",
    Values = tree_list,
    Value = "普通木 (Generic)",
    Callback = function(option)
        local m = string.match(option, "%((.+)%)")
        if m then targetTree = m else targetTree = option end
    end
})

TabTP:Button({
    Title = "传送到树旁",
    Callback = function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local targetWood = nil
        for _, v in next, Workspace:GetDescendants() do
            if v.Name == "TreeRegion" then
                for _, m in next, v:GetChildren() do
                    if m:FindFirstChild("CutEvent") and not m:FindFirstChild("RootCut") then
                        if m:FindFirstChild("TreeClass") and m.TreeClass.Value == targetTree then 
                            if m:FindFirstChild("Owner") and (m.Owner.Value == nil or m.Owner.Value == player) then
                                targetWood = m break
                            end
                        end
                    end
                end
            end
            if targetWood then break end
        end
        if targetWood and targetWood:FindFirstChild("WoodSection") then
            player.Character.HumanoidRootPart.CFrame = targetWood.WoodSection.CFrame + Vector3.new(0, 2.5, 3.5)
            WindUI:Notify({ Title = "成功", Content = "传送成功", Duration = 3 })
        else
            WindUI:Notify({ Title = "错误", Content = "没找到这种树", Duration = 3 })
        end
    end
})

for i = 1, 3 do
    TabTP:Button({
        Title = "保存当前位置为 传送点"..i,
        Callback = function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                playerPos[i] = player.Character.HumanoidRootPart.CFrame
                WindUI:Notify({ Title = "成功", Content = "已保存", Duration = 3 })
            end
        end
    })
    TabTP:Button({
        Title = "传送到 传送点"..i,
        Callback = function()
            if playerPos[i] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = playerPos[i]
                WindUI:Notify({ Title = "成功", Content = "已传送", Duration = 3 })
            else
                WindUI:Notify({ Title = "错误", Content = "未保存", Duration = 3 })
            end
        end
    })
end

local TabItem = Window:Tab({ Title = "物品传送", Icon = "rbxassetid://10882439086" })
local selectedBringTarget = "BRING1"

TabItem:Dropdown({
    Title = "选择物品拉回的目标点",
    Values = {"拉回点位1", "拉回点位2", "拉回点位3"},
    Value = "拉回点位1",
    Callback = function(option)
        if option == "拉回点位1" then selectedBringTarget = "BRING1"
        elseif option == "拉回点位2" then selectedBringTarget = "BRING2"
        elseif option == "拉回点位3" then selectedBringTarget = "BRING3" end
    end
})

for i = 1, 3 do
    TabItem:Button({
        Title = "设置 物品点位"..i,
        Callback = function()
            if Workspace:FindFirstChild("BRING"..i) then Workspace:FindFirstChild("BRING"..i):Destroy() end
            local p = Instance.new("Part", Workspace)
            p.Name = "BRING"..i
            p.Transparency = 1
            p.Anchored = true
            p.CFrame = player.Character.HumanoidRootPart.CFrame
            p.CanCollide = false
            p.Size = player.Character.HumanoidRootPart.Size
            local posBox = Instance.new("SelectionBox", p)
            posBox.Color3 = Color3.new(0, 255, 0)
            posBox.Adornee = p
            WindUI:Notify({ Title = "成功", Content = "物品点位已设置", Duration = 3 })
        end
    })
end

TabItem:Button({
    Title = "获取点击传送工具",
    Callback = function()
        if player.Backpack:FindFirstChild("点击传送") or player.Character:FindFirstChild("点击传送") then
            player.Backpack["点击传送"]:Destroy()
        end
        local a = Instance.new("Tool", player.Backpack)
        a.Name = "点击传送"
        a.RequiresHandle = false
        a.Activated:Connect(function()
            if Workspace:FindFirstChild(selectedBringTarget) then
                local targetCFrame = Workspace[selectedBringTarget].CFrame
                local targetPart = Mouse.Target
                if not targetPart then return end
                local targetModel = targetPart.Parent
                if targetModel and (targetModel.Name == "Plank" or targetModel:FindFirstChild("WoodSection") or targetModel:FindFirstChild("Owner")) then
                    for i = 1, 40 do
                        pcall(function() RS.Interaction.ClientIsDragging:FireServer(targetModel) end)
                        if targetModel.PrimaryPart then
                            targetModel:PivotTo(targetCFrame)
                        end
                        task.wait(0.02)
                    end
                    WindUI:Notify({ Title = "传送成功", Content = "物品已拉回", Duration = 3 })
                end
            else
                WindUI:Notify({ Title = "错误", Content = "请先设置拉回点位", Duration = 3 })
            end
        end)
        WindUI:Notify({ Title = "成功", Content = "工具已放入背包", Duration = 3 })
    end
})

local TabExtra = Window:Tab({ Title = "其他功能", Icon = "rbxassetid://10882439086" })

local function stopDrag()
    isDragEnabled = false
    if dragConn then dragConn:Disconnect() dragConn = nil end
    WindUI:Notify({ Title = "已停止", Content = "拖拽功能已关闭", Duration = 3 })
end

local function startDrag()
    if dragConn then dragConn:Disconnect() end
    dragConn = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == "Dragger" and isDragEnabled then
            obj.BrickColor = BrickColor.new("Bright green")
            task.spawn(function()
                local b = obj:WaitForChild("BodyGyro", 2)
                local c = obj:WaitForChild("BodyPosition", 2)
                if not b or not c then return end
                task.wait(0.1)
                obj.CanCollide = false
                obj.CanTouch = false
                while obj.Parent == Workspace and isDragEnabled do
                    c.P = 120000; c.D = 1000; c.MaxForce = Vector3.new(1, 1, 1) * 1000000
                    b.MaxTorque = Vector3.new(1, 1, 1) * 200; b.P = 1200; b.D = 140
                    task.wait()
                end
            end)
        end
    end)
end

TabExtra:Toggle({
    Title = "开启拖拽器",
    Default = false,
    Callback = function(state)
        isDragEnabled = state
        if isDragEnabled then
            startDrag()
            WindUI:Notify({ Title = "开启成功", Content = "拖拽功能已开启", Duration = 3 })
        else
            stopDrag()
        end
    end
})

TabExtra:Button({
    Title = "强制关闭并释放物品",
    Callback = function()
        stopDrag()
        local toggleObj = Window:GetToggle("开启拖拽器")
        if toggleObj then toggleObj:Set(false) end
    end
})

TabExtra:Button({
    Title = "开启飞行",
    Callback = function()
        WindUI:Notify({ Title = "加载中", Content = "正在注入飞行脚本...", Duration = 3 })
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/385j8888/ZOUMAGUIX/refs/heads/main/%E9%A3%9E%E8%A1%8C%E8%84%9A%E6%9C%ACV3(%E5%85%A8%E6%B8%B8%E6%88%8F%E9%80%9A%E7%94%A8).txt"))()
        end)
    end
})

TabExtra:Button({
    Title = "彻底关闭并清理缓存",
    Callback = function()
        CleanupAll()
    end
})