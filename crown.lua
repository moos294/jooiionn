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
    Title = "封存木材 v5.4",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Size = UDim2.fromOffset(420, 420),
    Transparent = true,
    Theme = "Dark"
})

local function DragModel(m, cf)
	pcall(function() 
        RS.Interaction.ClientIsDragging:FireServer("Begin", m, 4) 
        RS.Interaction.ClientIsDragging:FireServer("Refresh", m, 5)
    end)
	if not m.PrimaryPart then m.PrimaryPart = m:FindFirstChildOfClass("Part") end
	if m.PrimaryPart then 
        m.PrimaryPart.Velocity = Vector3.zero
        m:SetPrimaryPartCFrame(cf) 
    end
end

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

local TabBuy = Window:Tab({ Title = "万能购买", Icon = "rbxassetid://10734945123" })
local buyAmount = 1
local selectedItemEN = ""
local selectedShopEN = ""
local currentPrice = 0
local currentNpcID = 0
local currentNpcName = ""

local ShopDB = {
    ["WoodRUs"] = { NameCN = "木材反斗城", NPC = "Thom", ID = 24, Items = {["Axe1"]={"普通斧头", 90},["Axe2"]={"钢斧", 190},["Axe3"]={"硬化斧", 550},["SilverAxe"]={"银斧头", 2040},["Rukiryaxe"]={"无敌斧", 7400},["Sawmill"]={"破旧锯木厂", 130},["Sawmill2"]={"普通锯木厂", 1600},["Sawmill3"]={"锯木机01", 11000},["Sawmill4"]={"锯木机02", 22500},["Sawmill4L"]={"锯木机02L", 86500},["UtilityTruck"]={"多用途运载车", 400},["WorkLight"]={"工作灯", 80},["BagOfSand"]={"沙子袋", 1600},["ChopSaw"]={"劈锯", 12200},["Wire"]={"电线", 205},["Button0"]={"按钮", 320},["Lever0"]={"控制杆", 520},["PressurePlate"]={"压力板", 640},["StraightConveyor"]={"直式传送带", 80},["TiltConveyor"]={"倾斜传送带", 95},["ConveyorFunnel"]={"漏斗式传送带", 60},["ConveyorSwitch"]={"切换传送器", 320},["LogSweeper"]={"木头清扫机", 430}} },
    ["FineFinds"] = { NameCN = "桥边商店", NPC = "Manachron", ID = 20, Items = {["BasicHatchet"]={"基础斧头", 12},["Dynamite"]={"炸药", 220},["Crate"]={"神秘宝箱", 75000000},["Pie"]={"派", 50},["Furnace"]={"熔炉", 10000},["VirtualAxe"]={"虚拟斧", 10000},["Titanium"]={"钛", 5000}} },
    ["CarStore"] = { NameCN = "汽车店", NPC = "Jenny", ID = 23, Items = {["SmallTrailer"]={"小型拖车", 1800},["Trailer2"]={"拖车2", 13000},["Trailer3"]={"拖车3", 16000},["UtilityTruck2"]={"多功能运载车", 5000},["Pickup1"]={"皮卡1", 19000},["Pickup2"]={"皮卡2", 20000},["Pickup4"]={"皮卡4", 25000},["PickUp5"]={"皮卡5", 30000}} },
    ["FurnitureStore"] = { NameCN = "家具店", NPC = "Corey", ID = 16, Items = {["Toilet"]={"马桶", 90},["Stove"]={"火炉", 340},["Refridgerator"]={"冰箱", 310},["Dishwasher"]={"洗碗机", 380},["Bed1"]={"床1", 250},["Bed2"]={"床2", 350},["Seat_Couch"]={"长沙发", 320},["Seat_Loveseat"]={"双人沙发", 200},["Seat_Armchair"]={"扶手椅", 140},["GlassPane1"]={"微型玻璃板", 12},["GlassPane2"]={"小型玻璃板", 50},["GlassPane3"]={"玻璃板", 220},["GlassPane4"]={"大型玻璃板", 550},["GlassDoor1"]={"玻璃门", 720},["LightBulb"]={"灯泡", 2600},["WallLight1"]={"墙灯1", 90},["WallLight2"]={"墙灯2", 90},["Lamp1"]={"台灯", 90},["FloorLamp1"]={"落地灯", 110},["Torch"]={"火把", 80},["WashingMachine"]={"洗衣机", 80}} },
    ["PlantomicsChoice"] = { NameCN = "辐射商店", NPC = "Null", ID = 26, Items = {["SpiritAxe"]={"灵魂斧", 8000},["Tahoe"]={"雪佛兰Tahoe", 20000},["Cat"]={"猫", 1000},["HappyBall"]={"快乐球", 1000},["Egg"]={"蛋", 100},["Battery"]={"电池", 200}} },
    ["SaplingCart"] = { NameCN = "树苗车", NPC = "Billy", ID = 18, Items = {["SaplingGeneric"]={"普通树苗", 50},["SaplingCrate"]={"树苗箱", 500},["Planter2"]={"种植机2", 1000}} },
    ["StoneRUs"] = { NameCN = "石头反斗城", NPC = "Bloxyway", ID = 27, Items = {["QunatumSawmill"]={"量子锯木厂", 500000},["WoodLauncher"]={"木材发射器", 100000},["MegaConveyor"]={"超级传送带", 50000},["MEGATiltConveyor"]={"超级倾斜传送带", 50000},["MegaFurnace"]={"超级熔炉", 200000},["MagicLamp"]={"神灯", 100000},["Lemon"]={"柠檬", 100}} },
    ["Igloo"] = { NameCN = "冰屋", NPC = "Cold Guy", ID = 29, Items = {["AxeIce"]={"冰斧", 5000},["IceCube"]={"冰块", 100},["Cocoa"]={"热可可", 50}} },
    ["WilliamShop"] = { NameCN = "威廉商店", NPC = "William", ID = 28, Items = {["Dynamite"]={"炸药", 220}} },
    ["LogicStore"] = { NameCN = "逻辑商店", NPC = "Lincoln", ID = 17, Items = {["GateAND"]={"与门", 260},["GateOR"]={"或门", 260},["GateXOR"]={"异或门", 260},["GateNOT"]={"非门", 200},["Laser"]={"激光", 11300},["LaserReceiver"]={"激光接收器", 3200},["WoodChecker"]={"木材检测器", 11300},["SignalDelay"]={"信号延迟", 520},["SignalSustain"]={"信号维持", 520}} },
    ["BlackMarket"] = { NameCN = "黑市", NPC = "sneakypotato7", ID = 20, Items = {["EndtimesChainsaw"]={"末世电锯", 500000},["TinyTrailer"]={"微型拖车", 50000},["UtilityTruckNeon"]={"霓虹多功能车", 80000},["MiniTruck"]={"迷你卡车", 40000},["Bigsaw"]={"巨型锯", 100000}} }
}

local shopListCN = {}
local shopCNToEN = {}
for shopEN, shopData in pairs(ShopDB) do
    table.insert(shopListCN, shopData.NameCN)
    shopCNToEN[shopData.NameCN] = shopEN
end
table.sort(shopListCN)

local PriceLabel = TabBuy:Paragraph({
    Title = "价格预览",
    Desc = "请选择商店和物品",
    Color = Color3.fromRGB(255, 200, 0)
})

local function UpdatePriceUI()
    if currentPrice > 0 then
        local total = currentPrice * buyAmount
        PriceLabel:SetDesc(string.format("单价: %s | 数量: %d | 总价: %s | 当前余额: %s", FormatPrice(currentPrice), buyAmount, FormatPrice(total), FormatPrice(GetMoney())))
    else
        PriceLabel:SetDesc("未获取到价格")
    end
end

local StoreDropdown
local ItemDropdown

StoreDropdown = TabBuy:Dropdown({
    Title = "第一步：选择商店",
    Values = shopListCN,
    Value = shopListCN[1] or "无",
    Callback = function(selectedCN)
        selectedShopEN = shopCNToEN[selectedCN]
        local shopData = ShopDB[selectedShopEN]
        
        if shopData then
            local itemListCN = {}
            for itemEN, itemData in pairs(shopData.Items) do
                local itemCN = itemData[1]
                local price = itemData[2]
                local displayStr = string.format("%s (%s)", itemCN, FormatPrice(price))
                table.insert(itemListCN, displayStr)
            end
            table.sort(itemListCN)
            
            task.spawn(function()
                ItemDropdown:Refresh(itemListCN)
                task.wait(0.05)
                if #itemListCN > 0 then
                    ItemDropdown:SetValue(itemListCN[1])
                    local pureName = string.match(itemListCN[1], "^(.+) %(")
                    if pureName then
                        for itemEN, itemData in pairs(shopData.Items) do
                            if itemData[1] == pureName then
                                selectedItemEN = itemEN
                                currentPrice = itemData[2]
                                currentNpcID = shopData.ID
                                currentNpcName = shopData.NPC
                                break
                            end
                        end
                    end
                    UpdatePriceUI()
                else
                    selectedItemEN = ""
                    currentPrice = 0
                    PriceLabel:SetDesc("该商店无商品")
                end
            end)
        end
    end
})

ItemDropdown = TabBuy:Dropdown({
    Title = "第二步：选择商品",
    Values = {"请先选择商店"},
    Value = "请先选择商店",
    Callback = function(selectedStr)
        if not selectedShopEN then return end
        local shopData = ShopDB[selectedShopEN]
        if not shopData then return end
        
        local pureName = string.match(selectedStr, "^(.+) %(")
        if pureName then
            for itemEN, itemData in pairs(shopData.Items) do
                if itemData[1] == pureName then
                    selectedItemEN = itemEN
                    currentPrice = itemData[2]
                    currentNpcID = shopData.ID
                    currentNpcName = shopData.NPC
                    break
                end
            end
            UpdatePriceUI()
        end
    end
})

TabBuy:Slider({
    Title = "购买数量",
    Value = { Min = 1, Max = 30, Default = 1 },
    Callback = function(val)
        buyAmount = val
        UpdatePriceUI()
    end
})

task.spawn(function()
    task.wait(0.2)
    if #shopListCN > 0 then
        StoreDropdown:SetValue(shopListCN[1])
        task.wait(0.1)
        if StoreDropdown.Callback then
            StoreDropdown.Callback(shopListCN[1])
        end
    end
end)

TabBuy:Button({
    Title = "开始购买",
    Desc = "真实ID + 强制对话状态 + 购买",
    Callback = function()
        if not selectedShopEN or not selectedItemEN then 
            WindUI:Notify({ Title = "错误", Content = "请先选择商店和物品！", Duration = 3 })
            return 
        end
        
        local totalPrice = currentPrice * buyAmount
        local currentMoney = GetMoney()
        
        if currentMoney < totalPrice then
            WindUI:Notify({ Title = "余额不足", Content = "你的钱不够！需要 " .. FormatPrice(totalPrice) .. "，你只有 " .. FormatPrice(currentMoney), Duration = 5 })
            return
        end
        
        local oldpos = player.Character.HumanoidRootPart.CFrame
        
        task.spawn(function()
            local storeFolder = Workspace:WaitForChild("Stores")
            local shopModel = storeFolder:WaitForChild(selectedShopEN)
            local npcModel = shopModel:WaitForChild(currentNpcName)
            local npcDialog = npcModel:WaitForChild("Dialog")
            
            WindUI:Notify({ Title = "加载中", Content = "传送并等待模型加载...", Duration = 2 })
            
            if npcModel:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = npcModel.HumanoidRootPart.CFrame + Vector3.new(0, 3, 5)
            end
            
            task.wait(1.0)
            
            local targetBox = nil
            local targetCounter = nil
            
            for _, v in next, shopModel:GetDescendants() do
                if v.Name == "Counter" or v.Name == "counter" then targetCounter = v end
                if v.Name == "ShopItems" then
                    for _, box in next, v:GetChildren() do
                        if box:FindFirstChild("BoxItemName") and box.BoxItemName.Value == selectedItemEN then
                            targetBox = box
                        end
                    end
                end
            end
            
            if not targetBox or not targetCounter then
                WindUI:Notify({ Title = "失败", Content = "商品盒子模型未加载", Duration = 4 })
                player.Character.HumanoidRootPart.CFrame = oldpos
                return
            end
            
            local successCount = 0
            
            for i = 1, buyAmount do
                WindUI:Notify({ Title = "购买中", Content = "正在购买第 " .. i .. "/" .. buyAmount .. " 个", Duration = 2 })
                
                local t = 0
                repeat
                    DragModel(targetBox, targetCounter.CFrame + Vector3.new(0, 1, 0))
                    if targetBox:FindFirstChild("Main") then
                        player.Character.HumanoidRootPart.CFrame = targetBox.Main.CFrame + Vector3.new(0, 1, 3)
                    end
                    task.wait(0.05)
                    t = t + 0.05
                until (targetBox:FindFirstChild("Main") and (targetBox.Main.Position - targetCounter.Position).Magnitude < 6) or t > 3
                
                if npcModel:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = npcModel.HumanoidRootPart.CFrame + Vector3.new(0, 0, 2)
                end
                task.wait(0.3)
                
                local chatArgs = {
                    {
                        ID = currentNpcID,
                        Character = npcModel,
                        Name = currentNpcName,
                        Dialog = npcDialog
                    },
                    "StartChat"
                }
                pcall(function()
                    RS.NPCDialog.PlayerChatted:InvokeServer(unpack(chatArgs))
                end)
                task.wait(0.5)
                
                local args = {
                    {
                        ID = currentNpcID,
                        Character = npcModel,
                        Name = currentNpcName,
                        Dialog = npcDialog
                    },
                    "ConfirmPurchase"
                }
                
                local buySuccess = false
                local buyTimeout = 0
                
                while not buySuccess and buyTimeout < 5 do
                    pcall(function()
                        RS.NPCDialog.PlayerChatted:InvokeServer(unpack(args))
                    end)
                    task.wait(0.5)
                    buyTimeout = buyTimeout + 0.5
                    
                    if targetBox:FindFirstChild("Owner") and targetBox.Owner.Value == player then
                        buySuccess = true
                    end
                end
                
                if buySuccess then
                    for j = 1, 15 do
                        DragModel(targetBox, oldpos)
                        task.wait(0.02)
                    end
                    successCount = successCount + 1
                else
                    WindUI:Notify({ Title = "购买失败", Content = "发包被拒，未能确认所有权", Duration = 4 })
                    break
                end
            end
            
            if successCount > 0 then
                WindUI:Notify({ Title = "完成", Content = "成功购买并拉回 " .. successCount .. " 个物品", Duration = 4 })
            end
            player.Character.HumanoidRootPart.CFrame = oldpos
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
                        DragModel(targetModel, targetCFrame)
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
                    c.P = 120000; c.D = 1000; c.maxForce = Vector3.new(1, 1, 1) * 1000000
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