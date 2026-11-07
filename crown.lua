local player = game.Players.LocalPlayer
local TS = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local Mouse = player:GetMouse()
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

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
    Title = "封存木材",
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

local TabBuy = Window:Tab({ Title = "万能购买", Icon = "rbxassetid://10734945123" })
local buyAmount = 1
local currentStoreData = nil
local currentItemData = nil

local ShopTranslations = {
    ["SeaSide"]="海边商店", ["VIPSHOP"]="VIP商店", ["MountainSide"]="山边商店", ["BlackMarket"]="黑市",
    ["LogicStore"]="逻辑商店", ["FineArt"]="艺术品商店", ["FineFinds"]="寻宝商店", ["FurnitureStore"]="家具店",
    ["SaplingCart"]="树苗车", ["PlanterStore"]="种植商店", ["CarStore"]="汽车店", ["WoodRUs"]="木材反斗城",
    ["SallysSeasonal"]="莎莉商店", ["StoneRUs"]="石头反斗城", ["Igloo"]="冰屋", ["MusicStore"]="音乐商店",
    ["HLStand"]="高地摊位", ["PlantomicsChoice"]="植物学之选"
}

local ItemTranslations = {
    ["BeachBall"]="沙滩球", ["Milk"]="牛奶", ["Cookie"]="饼干", ["Vip"]="VIP特权", ["TeleportGold"]="黄金传送门",
    ["WaterCar"]="水上汽车", ["GoldBall"]="黄金球", ["PumpkinGold"]="黄金南瓜", ["GoldStraightConveyor"]="黄金直传送带",
    ["GoldTiltConveyor"]="黄金斜传送带", ["GoldTightTurnConveyor"]="黄金急弯传送带", ["GoldConveyorFunnel"]="黄金漏斗传送带",
    ["ToiletGoldVIP"]="黄金VIP马桶", ["OwnerOnlyDoor"]="仅限服主门", ["Store2"]="二号仓库", ["StorageHouse"]="储物房",
    ["Store"]="仓库", ["Ship"]="大船", ["FurnaceVIP"]="VIP熔炉", ["GoldChop"]="黄金砍伐机", ["GlassDoor2"]="玻璃门2",
    ["SawmillPower"]="动力锯木厂", ["WaterTrailer"]="水拖车", ["LumberCD2"]="木材CD2", ["LavaCar"]="岩浆车",
    ["OffRoadTruck"]="越野卡车", ["6die"]="6面骰子", ["SawmillGift"]="礼物锯木厂", ["AxeShiny"]="闪亮斧头",
    ["Cheese"]="奶酪", ["Crate_Cube"]="方块箱子", ["EndtimesChainsaw"]="末世电锯", ["Eye3"]="眼睛3", ["Skull"]="骷髅头",
    ["StrangeMan"]="奇怪的人", ["TinyTrailer"]="微型拖车", ["Turkey3"]="火鸡3", ["Turkey4"]="火鸡4", ["Turkey5"]="火鸡5",
    ["UtilityTruckNeon"]="霓虹多功能车", ["MiniTruck"]="迷你卡车", ["Bigsaw"]="巨型锯",
    ["SignalSustain"]="信号维持", ["GateAND"]="与门", ["GateXOR"]="异或门", ["WoodChecker"]="木材检测器",
    ["TeleportPink"]="粉色传送门", ["PressurePlate"]="压力板", ["GateOR"]="或门", ["Wire"]="电线", ["Lever0"]="控制杆",
    ["SignalDelay"]="信号延迟", ["Hatch"]="舱门", ["GateNOT"]="非门", ["Laser"]="激光", ["LaserReceiver"]="激光接收器",
    ["TeleportBlue"]="蓝色传送门", ["Button0"]="按钮", ["NeonWireOrange"]="橙色霓虹线", ["NeonWireGreen"]="绿色霓虹线",
    ["NeonWireYellow"]="黄色霓虹线", ["NeonWireWhite"]="白色霓虹线", ["NeonWireViolet"]="紫色霓虹线", ["NeonWireRed"]="红色霓虹线",
    ["NeonWireCyan"]="青色霓虹线", ["NeonWireBlue"]="蓝色霓虹线", ["Display"]="展示台", ["Counter"]="柜台",
    ["TeleportGreen"]="绿色传送门", ["TeleportRed"]="红色传送门", ["Piston"]="活塞",
    ["Painting1"]="画作1", ["Painting2"]="画作2", ["Painting3"]="画作3", ["Painting11"]="画作11",
    ["WritableSign"]="可写告示牌", ["Dynamite"]="炸药", ["Cube"]="方块", ["Wall2Round"]="圆形墙", ["WallMadeWithRound"]="圆墙",
    ["WallMadeWithRoundBig"]="大圆墙", ["Shelf1"]="架子1", ["DogWood"]="狗木", ["GlobeWood"]="地球木",
    ["Floor1MegaLarge"]="超大地板1", ["Floor2MegaLarge"]="超大地板2", ["Crate"]="箱子", ["Sign1"]="告示牌1",
    ["Floor2long"]="长地板2", ["PumpkinWood"]="南瓜木", ["Titanium"]="钛", ["VirtualAxe"]="虚拟斧", ["Pickup3"]="皮卡3",
    ["Pie"]="派", ["Furnace"]="熔炉",
    ["FloorLamp1"]="落地灯", ["Seat_Armchair"]="扶手椅", ["Bed2"]="床2", ["LightBulb"]="灯泡", ["Bed1"]="床1",
    ["WallLight2"]="墙灯2", ["WallLight1"]="墙灯1", ["Dishwasher"]="洗碗机", ["Seat_Loveseat"]="双人沙发",
    ["Stove"]="火炉", ["Toilet"]="马桶", ["Refridgerator"]="冰箱", ["Seat_Couch"]="长沙发", ["CounterTop1Thin"]="薄工作台面",
    ["CounterTop1Sink"]="带水槽工作台面", ["CounterTop1"]="工作台面", ["Cabinet1CornerWide"]="宽橱柜角",
    ["Cabinet1CornerTight"]="窄橱柜角", ["Cabinet1"]="橱柜", ["Cabinet1Thin"]="薄橱柜", ["Lamp1"]="台灯",
    ["GlassPane1"]="微型玻璃板", ["GlassPane2"]="小型玻璃板", ["GlassPane3"]="玻璃板", ["GlassPane4"]="大型玻璃板",
    ["GlassDoor1"]="玻璃门", ["IcicleWireAmber"]="琥珀色冰柱灯串", ["IcicleWireRed"]="红色冰柱灯串",
    ["IcicleWireGreen"]="绿色冰柱灯串", ["IcicleWireBlue"]="蓝色冰柱灯串", ["TallLargeGlassPane"]="高大玻璃板",
    ["largeUmbrella"]="大遮阳伞", ["CeilingLight"]="吸顶灯", ["Torch"]="火把", ["FoldingChair"]="折叠椅",
    ["ParkBench"]="公园长椅", ["SmallTable"]="小桌子", ["WashingMachine"]="洗衣机", ["SmallTable2"]="小桌子2",
    ["SaplingGeneric"]="普通树苗", ["Planter2"]="种植机2", ["SaplingCrate"]="树苗箱", ["SteamRock"]="蒸汽石",
    ["FireRock"]="火石", ["Asphalt"]="沥青", ["WaterCube"]="水方块", ["AppleTree"]="苹果树", ["Pot"]="花盆",
    ["Pickup2"]="皮卡2", ["SmallTrailer"]="小型拖车", ["Trailer2"]="拖车2", ["Trailer3"]="拖车3",
    ["UtilityTruck2"]="多功能运载车", ["Pickup1"]="皮卡1", ["TrailerGate"]="拖车尾门", ["GateTruck"]="卡车尾门",
    ["Pickup4"]="皮卡4", ["PickUp5"]="皮卡5",
    ["WorkLight"]="工作灯", ["Wedge9_Thin"]="1/2x1木楔", ["Wedge9"]="1/2木楔", ["Wedge8_Thin"]="2/2x1木楔",
    ["Wedge8"]="2/2木楔", ["Wedge7_Thin"]="1/3x1木楔", ["Wedge7"]="1/3木楔", ["Wedge6_Thin"]="2/3x1木楔",
    ["Wedge6"]="2/3木楔", ["Wedge5_Thin"]="3/3x1木楔", ["Wedge5"]="3/3木楔", ["Wedge4_Thin"]="1/4x1木楔",
    ["Wedge4"]="1/4木楔", ["Wedge3_Thin"]="2/4x1木楔", ["Wedge3"]="2/4木楔", ["Wedge2_Thin"]="3/4x1木楔",
    ["Wedge2"]="3/4木楔", ["Wedge1Corner"]="4/4木楔角", ["Wedge10_Thin"]="1/1x1木楔", ["Wedge10"]="1/1木楔",
    ["Wedge1"]="4/4木楔", ["Wall3Thin"]="矮篱笆[窄]", ["Wall3TallThin"]="篱笆[窄]", ["Wall3TallCorner"]="篱笆角",
    ["Wall3Tall"]="篱笆[宽]", ["Wall3Corner"]="矮篱笆角", ["Wall3"]="矮篱笆[宽]", ["Wall2Thin"]="矮光滑墙[窄]",
    ["Wall2TallThin"]="光滑的墙[窄]", ["Wall2TallCorner"]="光滑墙角", ["Wall2Tall"]="光滑的墙[宽]",
    ["Wall2ShortThin"]="光滑墙立柱[窄]", ["Wall2ShortCorner"]="光滑墙角立柱", ["Wall2Short"]="光滑墙立柱[宽]",
    ["Wall2Corner"]="又矮又光滑的墙角", ["Wall2"]="矮光滑墙[宽]", ["Wall1Thin"]="矮波纹墙[窄]",
    ["Wall1TallThin"]="波纹墙[窄]", ["Wall1TallCorner"]="波纹墙角", ["Wall1Tall"]="波纹墙[宽]",
    ["Wall1ShortThin"]="波纹墙立柱[窄]", ["Wall1ShortCorner"]="波纹墙角立柱", ["Wall1Short"]="波纹墙立柱[宽]",
    ["Wall1Corner"]="矮波纹墙角", ["Wall1"]="矮波纹墙[宽]", ["UtilityTruck"]="多用途运载车",
    ["Wedge10Corner"]="1/1木楔角", ["ToiletPaper"]="卫生纸", ["TiltConveyor"]="倾斜传送带",
    ["TightTurnConveyorSupports"]="急弯传送带支架", ["TightTurnConveyor"]="急弯传送带", ["Table2"]="长桌",
    ["Table1"]="方桌", ["StraightSwitchConveyorRight"]="右转直式传送带", ["StraightSwitchConveyorLeft"]="左转直式传送带",
    ["StraightConveyorLong"]="长直式传送带", ["StraightConveyorExtraLong"]="超长直式传送带", ["StraightConveyor"]="直式传送带",
    ["Stair2"]="楼梯", ["Stair1"]="陡峭楼梯", ["SmallKey"]="小钥匙", ["SilverAxe"]="银斧头", ["Shelf3"]="架子3",
    ["Shelf2"]="架子2", ["Sawmill5"]="锯木机05", ["Sawmill4L"]="锯木机02L", ["Sawmill4"]="锯木机02", ["Sawmill3"]="锯木机01",
    ["Sawmill2"]="普通锯木厂", ["Sawmill"]="破旧锯木厂", ["Rukiryaxe"]="无敌斧", ["Wedge8Corner"]="2/2木楔角",
    ["CargoBox"]="货箱", ["Wedge7Corner"]="1/3木楔角", ["Wedge6Corner"]="2/3木楔角", ["ObamaAxe"]="奥巴马斧",
    ["BadWaterCar"]="漏水车", ["Wall2TallThinTall"]="高窄光滑墙", ["BigTable1"]="大方桌", ["LargeChest"]="大箱子",
    ["DisplayCase"]="展示柜", ["LogSweeper"]="木头清扫机", ["Ladder1"]="梯子", ["GingerbreadAxe"]="姜饼人斧头",
    ["Wedge9Corner"]="1/2木楔角", ["Floor2Tiny"]="微型瓷砖", ["Floor2Small"]="小型瓷砖", ["Floor2Large"]="大型瓷砖",
    ["Floor2"]="瓷砖", ["Floor1Tiny"]="微型地板", ["Floor1Small"]="小型地板", ["Floor1Large"]="大型地板",
    ["Floor1"]="地板", ["FireAxe"]="火山斧", ["FastTiltConveyor"]="快速倾斜传送带", ["FastTightTurnConveyor"]="快速急弯传送带",
    ["FastConveyor"]="快速传送带", ["EndTimesAxe"]="末世斧", ["Door1"]="普通门", ["ConveyorSwitch"]="切换传送器",
    ["ConveyorSupports"]="传送带支架", ["ConveyorFunnel"]="漏斗式传送带", ["ChopSaw"]="劈锯", ["Chest"]="箱子",
    ["Chair1"]="普通椅子", ["Chainsaw"]="电锯", ["CandyCaneAxe"]="拐杖糖斧", ["BookCase"]="书架", ["Wall2Stub"]="短墙",
    ["BirdAxe"]="小鸟斧", ["BeeAxe"]="蜜蜂斧", ["BasicHatchet"]="基础斧头", ["BagOfSand"]="沙子袋", ["AxeSinister2"]="邪恶斧2",
    ["ManyAxe"]="多重斧", ["Ramp"]="斜坡", ["AxeCommunity"]="社区斧", ["AxeChicken"]="鸡斧", ["Wedge2Corner"]="3/4木楔角",
    ["AxeBlurple"]="蓝紫色斧", ["AxeBetaTesters"]="测试员斧(Beta)", ["AxeAmber"]="琥珀斧", ["AxeAlphaTesters"]="测试员斧(Alpha)",
    ["Axe3"]="硬化斧", ["Axe2"]="钢斧", ["Axe1"]="普通斧头", ["4SeatTruck"]="4座卡车", ["Wedge4Corner"]="1/4木楔角",
    ["Wedge5Corner"]="3/3木楔角", ["Wedge3Corner"]="2/4木楔角", ["Box1Large"]="大盒子", ["Table3"]="桌子3",
    ["BloodBorne"]="血源", ["CursedWorklight"]="诅咒工作灯",
    ["Eye1"]="眼睛1", ["PumpkinClassic"]="经典南瓜", ["PumpkinDark"]="黑暗南瓜", ["PumpkinSinister"]="邪恶南瓜",
    ["SinisterSawmill2"]="邪恶锯木厂2", ["SinisterSeller"]="邪恶售货机", ["NeonWireSinister"]="邪恶霓虹线",
    ["BobbleheadSpooky"]="幽灵摇头娃娃", ["SinisterConveyor"]="邪恶传送带", ["SinisterTiltConveyor"]="邪恶倾斜传送带",
    ["SinisterTightTurnConveyor"]="邪恶急弯传送带", ["SinisterChopSaw"]="邪恶劈锯",
    ["Lemon"]="柠檬", ["MagicLamp"]="神灯", ["QunatumSawmill"]="量子锯木厂", ["WoodLauncher"]="木材发射器", 
    ["MEGATiltConveyor"]="超级倾斜传送带", ["MegaConveyor"]="超级传送带", ["MegaConveyorFunnel"]="超级漏斗传送带", 
    ["MegaFurnace"]="超级熔炉", ["AxeIce"]="冰斧", ["IceCube"]="冰块", ["Cocoa"]="热可可", ["HappyBall"]="快乐球", 
    ["Egg"]="蛋", ["Battery"]="电池", ["SpiritAxe"]="灵魂斧", ["Cat"]="猫", ["Pan"]="平底锅", 
    ["Flashlight"]="手电筒", ["Tahoe"]="雪佛兰Tahoe", ["NESController"]="NES手柄", ["MusicBox"]="音乐盒"
}

local npcIDs = {
    ["Thom"] = 7, ["Corey"] = 8, ["Jenny"] = 9, ["Bob"] = 10, ["Timothy"] = 11, 
    ["Lincoln"] = 12, ["Ruhven"] = 1, ["Seranok"] = 14, ["Hoover"] = 15, ["Manachron"] = 20
}

local ShopsData = {}

local function ScanShops()
    ShopsData = {}
    local storeList = {}
    
    for _, v in next, Workspace:GetDescendants() do
        if v.Name == "ShopItems" then
            local storeFolder = v.Parent
            local npcModel = nil
            local counter = storeFolder:FindFirstChild("Counter") or storeFolder:FindFirstChild("counter")
            
            for _, child in next, storeFolder:GetChildren() do
                if child:IsA("Model") and child:FindFirstChild("Dialog") then
                    npcModel = child break
                end
            end
            
            if npcModel and counter then
                local storeNameEN = storeFolder.Name
                local storeNameCN = ShopTranslations[storeNameEN] or "未知商店"
                
                if not ShopsData[storeNameEN] then
                    ShopsData[storeNameEN] = {
                        NameCN = storeNameCN,
                        NPC = npcModel,
                        Counter = counter,
                        Items = {},
                        ItemNamesCN = {}
                    }
                    table.insert(storeList, storeNameCN)
                end
                
                for _, box in next, v:GetChildren() do
                    if box:FindFirstChild("BoxItemName") then
                        local bName = box.BoxItemName.Value
                        local bNameCN = ItemTranslations[bName] or "未知物品" 
                        
                        local price = 0
                        for _, val in pairs(box:GetChildren()) do
                            if val:IsA("NumberValue") or val:IsA("IntValue") or val:IsA("StringValue") then
                                if val.Name == "Price" or val.Name == "BoxItemPrice" or val.Name == "Cost" then
                                    price = tonumber(val.Value) or 0
                                    break
                                end
                            end
                        end
                        
                        if not ShopsData[storeNameEN].Items[bNameCN] then
                            ShopsData[storeNameEN].Items[bNameCN] = {
                                Box = box,
                                Price = price
                            }
                            local displayStr = string.format("%s (%d$)", bNameCN, price)
                            table.insert(ShopsData[storeNameEN].ItemNamesCN, displayStr)
                        end
                    end
                end
            end
        end
    end
    table.sort(storeList)
    for _, sData in pairs(ShopsData) do
        table.sort(sData.ItemNamesCN)
    end
    return storeList
end

local PriceLabel = TabBuy:Paragraph({
    Title = "价格预览",
    Desc = "请选择商店和物品",
    Color = Color3.fromRGB(255, 200, 0)
})

local StoreDropdown = TabBuy:Dropdown({
    Title = "第一步：选择商店",
    Values = {"加载中..."},
    Value = "加载中...",
    Callback = function(selectedCN)
        for enName, data in pairs(ShopsData) do
            if data.NameCN == selectedCN then
                currentStoreData = data
                break
            end
        end
        
        if currentStoreData then
            ItemDropdown:Refresh(currentStoreData.ItemNamesCN)
            if #currentStoreData.ItemNamesCN > 0 then
                ItemDropdown:SetValue(currentStoreData.ItemNamesCN[1])
                
                local pureName = string.match(currentStoreData.ItemNamesCN[1], "^(.+) %(")
                if pureName then
                    currentItemData = currentStoreData.Items[pureName]
                    local total = currentItemData.Price * buyAmount
                    PriceLabel:SetDesc(string.format("单价: %d | 数量: %d | 总价: %d | 当前余额: %d", currentItemData.Price, buyAmount, total, GetMoney()))
                end
            else
                currentItemData = nil
                PriceLabel:SetDesc("该商店暂无商品")
            end
        end
    end
})

local ItemDropdown = TabBuy:Dropdown({
    Title = "第二步：选择商品",
    Values = {"请先选择商店"},
    Value = "请先选择商店",
    Callback = function(selectedStr)
        if currentStoreData then
            local pureName = string.match(selectedStr, "^(.+) %(")
            if pureName then
                currentItemData = currentStoreData.Items[pureName]
                if currentItemData then
                    local total = currentItemData.Price * buyAmount
                    PriceLabel:SetDesc(string.format("单价: %d | 数量: %d | 总价: %d | 当前余额: %d", currentItemData.Price, buyAmount, total, GetMoney()))
                end
            end
        end
    end
})

TabBuy:Slider({
    Title = "购买数量 (上限30)",
    Value = { Min = 1, Max = 30, Default = 1 },
    Callback = function(val)
        buyAmount = val
        if currentItemData then
            local total = currentItemData.Price * buyAmount
            PriceLabel:SetDesc(string.format("单价: %d | 数量: %d | 总价: %d | 当前余额: %d", currentItemData.Price, buyAmount, total, GetMoney()))
        end
    end
})

task.spawn(function()
    local storeList = ScanShops()
    if #storeList > 0 then
        StoreDropdown:Refresh(storeList)
        StoreDropdown:SetValue(storeList[1])
        for enName, data in pairs(ShopsData) do
            if data.NameCN == storeList[1] then
                currentStoreData = data
                break
            end
        end
        
        if currentStoreData and #currentStoreData.ItemNamesCN > 0 then
            ItemDropdown:Refresh(currentStoreData.ItemNamesCN)
            ItemDropdown:SetValue(currentStoreData.ItemNamesCN[1])
            
            local pureName = string.match(currentStoreData.ItemNamesCN[1], "^(.+) %(")
            if pureName then
                currentItemData = currentStoreData.Items[pureName]
                local total = currentItemData.Price * buyAmount
                PriceLabel:SetDesc(string.format("单价: %d | 数量: %d | 总价: %d | 当前余额: %d", currentItemData.Price, buyAmount, total, GetMoney()))
            end
        end
    end
end)

TabBuy:Button({
    Title = "开始批量购买",
    Desc = "自动校验余额，不够立刻停止",
    Callback = function()
        if not currentStoreData or not currentItemData then return end
        
        local unitPrice = currentItemData.Price
        local totalPrice = unitPrice * buyAmount
        local currentMoney = GetMoney()
        
        if currentMoney < totalPrice then
            WindUI:Notify({ Title = "余额不足", Content = "你的钱不够！需要 " .. totalPrice .. "，你只有 " .. currentMoney, Duration = 5 })
            return
        end
        
        local box = currentItemData.Box
        local counter = currentStoreData.Counter
        local npc = currentStoreData.NPC
        local npcID = npcIDs[npc.Name] or 20 
        local oldpos = player.Character.HumanoidRootPart.CFrame
        
        task.spawn(function()
            local successCount = 0
            for i = 1, buyAmount do
                if GetMoney() < unitPrice then
                    WindUI:Notify({ Title = "中断", Content = "余额不足，已停止购买", Duration = 4 })
                    break
                end
                
                WindUI:Notify({ Title = "搬运中", Content = "正在购买第 " .. i .. "/" .. buyAmount .. " 个", Duration = 2 })
                
                if box:FindFirstChild("Main") then
                    player.Character.HumanoidRootPart.CFrame = box.Main.CFrame + Vector3.new(0, 1, 5)
                end
                
                local t = 0
                repeat
                    DragModel(box, counter.CFrame + Vector3.new(0, 1, 0))
                    task.wait(0.05)
                    t = t + 0.05
                until (box:FindFirstChild("Main") and (box.Main.Position - counter.Position).Magnitude < 6) or t > 3
                
                if npc:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame + Vector3.new(0, 1, 5)
                end
                task.wait(0.2)
                
                local args = {
                    {
                        ID = npcID,
                        Character = npc,
                        Name = npc.Name,
                        Dialog = npc:FindFirstChild("Dialog")
                    },
                    "ConfirmPurchase"
                }
                pcall(function()
                    RS.NPCDialog.PlayerChatted:InvokeServer(unpack(args))
                end)
                task.wait(0.5)
                
                for j = 1, 15 do
                    DragModel(box, oldpos)
                    task.wait(0.02)
                end
                successCount = successCount + 1
            end
            
            WindUI:Notify({ Title = "完成", Content = "成功购买并拉回 " .. successCount .. " 个物品", Duration = 4 })
            player.Character.HumanoidRootPart.CFrame = oldpos
            PriceLabel:SetDesc(string.format("单价: %d | 数量: %d | 总价: %d | 当前余额: %d", unitPrice, buyAmount, unitPrice * buyAmount, GetMoney()))
        end)
    end
})

local TabTP = Window:Tab({ Title = "安全传送", Icon = "rbxassetid://10734945123" })
local targetTree = "Generic"
local playerPos = {nil, nil, nil}

local tree_list = {
	"普通木 (Generic)", "幻影木 (LoneCave)", "电木 (Electric)", "胡桃木 (Walnut)", "星木 (Star)", "樱桃木 (Cherry)", "桦木 (Birch)", "冰霜木 (Frost)",
	"大理石木 (Marble)", "火山木 (Volcano)", "金色沼泽木 (GoldSwampy)", "普通金木 (GenericGold)", "巨型橡木 (GreatOak)", "石头木 (Stone)", "辐射木 (Radioactive)",
	"洞穴木 (Cavern)", "岩浆木 (Magma)", "蓝木 (CaveCrawler)", "灵魂木 (Spirit)", "烈焰木 (Flame)", "星辰木 (Celestial)", "橡木 (Oak)", "绿色沼泽木 (GreenSwampy)",
	"沙子木 (Sand)", "松木 (Pine)", "玻璃木 (Glass)", "彩虹木 (Rainbow)", "冰木 (Ice)"
}

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
    Desc = "安全传送到树旁边的空地上",
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
                WindUI:Notify({ Title = "成功", Content = "已保存传送点"..i, Duration = 3 })
            end
        end
    })
    TabTP:Button({
        Title = "传送到 传送点"..i,
        Callback = function()
            if playerPos[i] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = playerPos[i]
                WindUI:Notify({ Title = "成功", Content = "已回到传送点"..i, Duration = 3 })
            else
                WindUI:Notify({ Title = "错误", Content = "未保存传送点"..i, Duration = 3 })
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
            WindUI:Notify({ Title = "成功", Content = "物品点位"..i.."已设置", Duration = 3 })
        end
    })
end

TabItem:Button({
    Title = "获取点击传送工具",
    Desc = "拿在手上点击木头，直接拉回选中的点位",
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

local TabServer = Window:Tab({ Title = "服务器", Icon = "rbxassetid://10882439086" })
local targetPlaceId = tostring(game.PlaceId)

TabServer:Input({
    Title = "指定服务器 ID",
    Value = tostring(game.PlaceId),
    Callback = function(text) targetPlaceId = text end
})

local function getServerList(pid)
	local candidates = {}
	local url = ("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(pid)
	local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
	if ok and res and res.data then
		for _, s in ipairs(res.data) do
			if s.id ~= game.JobId and s.playing >= 2 and s.playing <= s.maxPlayers - 2 then
				table.insert(candidates, s.id)
			end
		end
	end
	return candidates
end

TabServer:Button({
    Title = "重进当前服务器",
    Callback = function() pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end) end
})

TabServer:Button({
    Title = "指定服务器换服",
    Callback = function()
        local id = tonumber(targetPlaceId)
        if id then
            local servers = getServerList(id)
            if #servers > 0 then
                local randomJobId = servers[math.random(1, #servers)]
                pcall(function() TS:TeleportToPlaceInstance(id, randomJobId, player) end)
            else
                pcall(function() TS:Teleport(id, player) end)
            end
        else
            WindUI:Notify({ Title = "错误", Content = "服务器 ID 格式不正确", Duration = 3 })
        end
    end
})

TabServer:Button({
    Title = "随机换服",
    Callback = function()
        local servers = getServerList(game.PlaceId)
        if #servers > 0 then
            local randomJobId = servers[math.random(1, #servers)]
            pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, randomJobId, player) end)
        else
            pcall(function() TS:Teleport(game.PlaceId, player) end)
        end
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
    Desc = "锁定物理拉力，随便飞绝对不掉",
    Default = false,
    Callback = function(state)
        isDragEnabled = state
        if isDragEnabled then
            startDrag()
            WindUI:Notify({ Title = "开启成功", Content = "直接用手抓取物品起飞！", Duration = 3 })
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