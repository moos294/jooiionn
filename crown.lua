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
    Title = "封存木材 v8.5",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Size = UDim2.fromOffset(420, 420),
    Transparent = true,
    Theme = "Dark"
})

local Interaction = RS:WaitForChild("Interaction")
local NPCDialog = RS:WaitForChild("NPCDialog")
local PlayerChatted = NPCDialog:WaitForChild("PlayerChatted")
local TestPing = RS:FindFirstChild("TestPing")

local function DragModel(m, cf)
    pcall(function()
        Interaction.ClientIsDragging:FireServer(m)
    end)
    if m:IsA("Model") then
        if not m.PrimaryPart then m.PrimaryPart = m:FindFirstChildOfClass("Part") end
        if m.PrimaryPart then
            m.PrimaryPart.Velocity = Vector3.zero
            m:SetPrimaryPartCFrame(cf)
        end
    elseif m:IsA("BasePart") then
        m.Velocity = Vector3.zero
        m.CFrame = cf
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
    ["FineFinds"] = { NameCN = "桥边商店", NPC = "Manachron", ID = 20, Items = {["BasicHatchet"]={"基础斧头", 12},["Dynamite"]={"炸弹", 220},["Crate"]={"神秘宝箱", 75000000},["Pie"]={"派", 50},["Furnace"]={"熔炉", 10000},["VirtualAxe"]={"虚拟斧", 10000},["Titanium"]={"钛", 5000}} },
    ["CarStore"] = { NameCN = "汽车店", NPC = "Jenny", ID = 23, Items = {["SmallTrailer"]={"小型拖车", 1800},["Trailer2"]={"拖车2", 13000},["Trailer3"]={"拖车3", 16000},["UtilityTruck2"]={"多功能运载车", 5000},["Pickup1"]={"皮卡1", 19000},["Pickup2"]={"皮卡2", 20000},["Pickup4"]={"皮卡4", 25000},["PickUp5"]={"皮卡5", 30000}} },
    ["FurnitureStore"] = { NameCN = "家具店", NPC = "Corey", ID = 16, Items = {["Toilet"]={"马桶", 90},["Stove"]={"火炉", 340},["Refridgerator"]={"冰箱", 310},["Dishwasher"]={"洗碗机", 380},["Bed1"]={"床1", 250},["Bed2"]={"床2", 350},["Seat_Couch"]={"长沙发", 320},["Seat_Loveseat"]={"双人沙发", 200},["Seat_Armchair"]={"扶手椅", 140},["GlassPane1"]={"微型玻璃板", 12},["GlassPane2"]={"小型玻璃板", 50},["GlassPane3"]={"玻璃板", 220},["GlassPane4"]={"大型玻璃板", 550},["GlassDoor1"]={"玻璃门", 720},["LightBulb"]={"灯泡", 2600},["WallLight1"]={"墙灯1", 90},["WallLight2"]={"墙灯2", 90},["Lamp1"]={"台灯", 90},["FloorLamp1"]={"落地灯", 110},["Torch"]={"火把", 80},["WashingMachine"]={"洗衣机", 80}} },
    ["PlantomicsChoice"] = { NameCN = "辐射商店", NPC = "Null", ID = 26, Items = {["SpiritAxe"]={"灵魂斧", 8000},["Tahoe"]={"雪佛兰Tahoe", 20000},["Cat"]={"猫", 1000},["HappyBall"]={"快乐球", 1000},["Egg"]={"蛋", 100},["Battery"]={"电池", 200}} },
    ["SaplingCart"] = { NameCN = "树苗车", NPC = "Billy", ID = 18, Items = {["SaplingGeneric"]={"普通树苗", 50},["SaplingCrate"]={"树苗箱", 500},["Planter2"]={"种植机2", 1000}} },
    ["StoneRUs"] = { NameCN = "石头反斗城", NPC = "Bloxyway", ID = 27, Items = {["QunatumSawmill"]={"量子锯木厂", 500000},["WoodLauncher"]={"木材发射器", 100000},["MegaConveyor"]={"超级传送带", 50000},["MEGATiltConveyor"]={"超级倾斜传送带", 50000},["MegaFurnace"]={"超级熔炉", 200000},["MagicLamp"]={"神灯", 100000},["Lemon"]={"柠檬", 100}} },
    ["Igloo"] = { NameCN = "冰屋", NPC = "Cold Guy", ID = 29, Items = {["AxeIce"]={"冰斧", 5000},["IceCube"]={"冰块", 100},["Cocoa"]={"热可可", 50}} },
    ["WilliamShop"] = { NameCN = "威廉商店", NPC = "William", ID = 28, Items = {["Dynamite"]={"炸弹", 220}} },
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

local function FindShopItem(itemName)
    for _, v in pairs(Workspace:GetChildren()) do
        if v.Name == itemName and (v:IsA("Model") or v:IsA("BasePart")) then
            return v
        end
    end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == itemName and (v:IsA("Model") or v:IsA("BasePart")) then
            return v
        end
    end
    return nil
end

local function PurchaseItem(itemEN, shopEN, amount)
    local shopData = ShopDB[shopEN]
    if not shopData then return false end
    local npcID = shopData.ID

    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    for i = 1, amount do
        local item = FindShopItem(itemEN)
        if item then
            local targetCF = CFrame.new(hrp.Position + Vector3.new(0, 3, 0))
            DragModel(item, targetCF)
            task.wait(0.12)

            pcall(function()
                PlayerChatted:InvokeServer({
                    ID = npcID,
                    Character = "name",
                    Name = "name",
                    Dialog = "Dialog",
                }, "ConfirmPurchase")
            end)
            task.wait(0.2)
        else
            pcall(function()
                PlayerChatted:InvokeServer({
                    ID = npcID,
                    Character = "name",
                    Name = "name",
                    Dialog = "Dialog",
                }, "ConfirmPurchase")
            end)
            task.wait(0.3)
        end

        if TestPing then pcall(function() TestPing:InvokeServer() end) end
    end
    return true
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

local AmountInput = TabBuy:Input({
    Title = "第三步：输入数量",
    Value = "1",
    Placeholder = "输入数量",
    Callback = function(text)
        buyAmount = tonumber(text) or 1
        if buyAmount < 1 then buyAmount = 1 end
        UpdatePriceUI()
    end
})

local BuyButton = TabBuy:Button({
    Title = "开始购买",
    Desc = "点击开始购买所选商品",
    Callback = function()
        if not selectedShopEN then
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "提示", Text = "请先选择商店", Duration = 3})
            return
        end
        if not selectedItemEN or selectedItemEN == "" then
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "提示", Text = "请先选择商品", Duration = 3})
            return
        end
        local total = currentPrice * buyAmount
        if total > GetMoney() then
            game:GetService("StarterGui"):SetCore("SendNotification", {Title = "余额不足", Text = "总价 " .. FormatPrice(total) .. " 超过当前余额", Duration = 3})
            return
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "开始购买", Text = "正在购买 " .. buyAmount .. " 个 " .. selectedItemEN, Duration = 3})
        task.spawn(function()
            PurchaseItem(selectedItemEN, selectedShopEN, buyAmount)
        end)
    end
})

if StoreDropdown and shopListCN[1] then
    task.spawn(function()
        task.wait(0.1)
        pcall(function()
            StoreDropdown:SetValue(shopListCN[1])
        end)
    end)
end