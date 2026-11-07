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
    Title = "封存木材 v1.5",
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
local selectedItemEN = ""
local selectedShopEN = ""

local ShopDB = {
    ["FineFinds"] = { NameCN = "寻宝商店", NPC = "Manachron", ID = 20, Items = {["BasicHatchet"]="基础斧头",["VirtualAxe"]="虚拟斧",["Pickup3"]="皮卡3",["Pie"]="派",["Furnace"]="熔炉",["Dynamite"]="炸药",["DogWood"]="狗木",["GlobeWood"]="地球木",["PumpkinWood"]="南瓜木",["Titanium"]="钛",["Floor1MegaLarge"]="超大地板1",["Floor2MegaLarge"]="超大地板2",["Wall2Round"]="圆形墙",["WallMadeWithRound"]="圆墙",["Shelf1"]="架子1",["Crate"]="箱子",["Cube"]="方块",["WritableSign"]="可写告示牌"} },
    ["FurnitureStore"] = { NameCN = "家具店", NPC = "Corey", ID = 8, Items = {["Toilet"]="马桶",["Stove"]="火炉",["Refridgerator"]="冰箱",["Dishwasher"]="洗碗机",["Bed1"]="床1",["Bed2"]="床2",["Seat_Couch"]="长沙发",["Seat_Loveseat"]="双人沙发",["Seat_Armchair"]="扶手椅",["GlassPane1"]="微型玻璃板",["GlassPane2"]="小型玻璃板",["GlassPane3"]="玻璃板",["GlassPane4"]="大型玻璃板",["GlassDoor1"]="玻璃门",["LightBulb"]="灯泡",["WallLight1"]="墙灯1",["WallLight2"]="墙灯2",["Lamp1"]="台灯",["FloorLamp1"]="落地灯",["Cabinet1"]="橱柜",["Cabinet1Thin"]="薄橱柜",["CounterTop1"]="工作台面",["CounterTop1Thin"]="薄工作台面",["CounterTop1Sink"]="带水槽工作台面",["Torch"]="火把",["WashingMachine"]="洗衣机",["largeUmbrella"]="大遮阳伞",["FoldingChair"]="折叠椅",["ParkBench"]="公园长椅",["SmallTable"]="小桌子"} },
    ["WoodRUs"] = { NameCN = "木材反斗城", NPC = "Thom", ID = 7, Items = {["Axe1"]="普通斧头",["Axe2"]="钢斧",["Axe3"]="硬化斧",["SilverAxe"]="银斧头",["Rukiryaxe"]="无敌斧",["Sawmill"]="破旧锯木厂",["Sawmill2"]="普通锯木厂",["Sawmill3"]="锯木机01",["Sawmill4"]="锯木机02",["Sawmill4L"]="锯木机02L",["UtilityTruck"]="多用途运载车",["WorkLight"]="工作灯",["BagOfSand"]="沙子袋",["ChopSaw"]="劈锯",["Wire"]="电线",["Button0"]="按钮",["Lever0"]="控制杆",["PressurePlate"]="压力板",["StraightConveyor"]="直式传送带",["TiltConveyor"]="倾斜传送带",["ConveyorFunnel"]="漏斗式传送带",["ConveyorSwitch"]="切换传送器",["LogSweeper"]="木头清扫机"} },
    ["CarStore"] = { NameCN = "汽车店", NPC = "Jenny", ID = 9, Items = {["SmallTrailer"]="小型拖车",["Trailer2"]="拖车2",["Trailer3"]="拖车3",["UtilityTruck2"]="多功能运载车",["Pickup1"]="皮卡1",["Pickup2"]="皮卡2",["Pickup4"]="皮卡4",["PickUp5"]="皮卡5"} },
    ["BlackMarket"] = { NameCN = "黑市", NPC = "sneakypotato7", ID = 20, Items = {["EndtimesChainsaw"]="末世电锯",["TinyTrailer"]="微型拖车",["UtilityTruckNeon"]="霓虹多功能车",["MiniTruck"]="迷你卡车",["Bigsaw"]="巨型锯",["Cheese"]="奶酪",["Skull"]="骷髅头",["StrangeMan"]="奇怪的人"} },
    ["SallysSeasonal"] = { NameCN = "莎莉商店", NPC = "Sally", ID = 20, Items = {["SinisterSawmill2"]="邪恶锯木厂2",["SinisterChopSaw"]="邪恶劈锯",["PumpkinClassic"]="经典南瓜",["PumpkinDark"]="黑暗南瓜",["PumpkinSinister"]="邪恶南瓜",["AxeSinister2"]="邪恶斧2"} },
    ["StoneRUs"] = { NameCN = "石头反斗城", NPC = "Bloxyway", ID = 20, Items = {["QunatumSawmill"]="量子锯木厂",["WoodLauncher"]="木材发射器",["MegaConveyor"]="超级传送带",["MEGATiltConveyor"]="超级倾斜传送带",["MegaFurnace"]="超级熔炉",["MagicLamp"]="神灯",["Lemon"]="柠檬"} },
    ["Igloo"] = { NameCN = "冰屋", NPC = "Cold Guy", ID = 20, Items = {["AxeIce"]="冰斧",["IceCube"]="冰块",["Cocoa"]="热可可"} },
    ["LogicStore"] = { NameCN = "逻辑商店", NPC = "Lincoln", ID = 12, Items = {["GateAND"]="与门",["GateOR"]="或门",["GateXOR"]="异或门",["GateNOT"]="非门",["Laser"]="激光",["LaserReceiver"]="激光接收器",["WoodChecker"]="木材检测器",["SignalDelay"]="信号延迟",["SignalSustain"]="信号维持"} },
    ["MusicStore"] = { NameCN = "音乐商店", NPC = "NazuReborn", ID = 20, Items = {["LumberCD2"]="木材CD2",["MusicBox"]="音乐盒"} },
    ["PlantomicsChoice"] = { NameCN = "植物学之选", NPC = "Null", ID = 20, Items = {["SpiritAxe"]="灵魂斧",["Tahoe"]="雪佛兰Tahoe",["Cat"]="猫",["HappyBall"]="快乐球",["Egg"]="蛋",["Battery"]="电池"} },
    ["SeaSide"] = { NameCN = "海边商店", NPC = "Guy", ID = 20, Items = {["BeachBall"]="沙滩球",["Milk"]="牛奶",["Cookie"]="饼干"} },
    ["VIPSHOP"] = { NameCN = "VIP商店", NPC = "Todd", ID = 20, Items = {["Vip"]="VIP特权",["WaterCar"]="水上汽车",["GoldBall"]="黄金球",["PumpkinGold"]="黄金南瓜",["GoldChop"]="黄金砍伐机",["FurnaceVIP"]="VIP熔炉"} },
    ["MountainSide"] = { NameCN = "山边商店", NPC = "Mr.Bacon", ID = 20, Items = {["OffRoadTruck"]="越野卡车",["AxeShiny"]="闪亮斧头",["SawmillGift"]="礼物锯木厂"} },
    ["FineArt"] = { NameCN = "艺术品商店", NPC = "Timothy", ID = 11, Items = {["Painting1"]="画作1",["Painting2"]="画作2",["Painting3"]="画作3",["Painting11"]="画作11"} },
    ["SaplingCart"] = { NameCN = "树苗车", NPC = "Billy", ID = 20, Items = {["SaplingGeneric"]="普通树苗",["SaplingCrate"]="树苗箱",["Planter2"]="种植机2"} },
    ["PlanterStore"] = { NameCN = "种植商店", NPC = "OGxOutcast", ID = 20, Items = {["AppleTree"]="苹果树",["WaterCube"]="水方块",["SteamRock"]="蒸汽石",["FireRock"]="火石",["Asphalt"]="沥青"} }
}

local shopListCN = {}
local itemCNToEN = {}
local itemToShop = {}

for shopEN, shopData in pairs(ShopDB) do
    table.insert(shopListCN, shopData.NameCN)
    for itemEN, itemCN in pairs(shopData.Items) do
        local displayStr = string.format("[%s] %s", shopData.NameCN, itemCN)
        table.insert(itemCNToEN, displayStr) 
        itemCNToEN[displayStr] = itemEN 
        itemToShop[displayStr] = shopEN 
    end
end
table.sort(shopListCN)
table.sort(itemCNToEN)

local PriceLabel = TabBuy:Paragraph({
    Title = "价格预览",
    Desc = "请选择下方商品",
    Color = Color3.fromRGB(255, 200, 0)
})

local BuyDropdown = TabBuy:Dropdown({
    Title = "选择要购买的物品 (已分类)",
    Values = itemCNToEN,
    Value = itemCNToEN[1] or "无商品",
    Callback = function(opt) 
        selectedItemEN = itemCNToEN[opt]
        local shopEN = itemToShop[opt]
        selectedShopEN = shopEN
        
        local price = 0
        local storeFolder = Workspace:FindFirstChild("Stores") and Workspace.Stores:FindFirstChild(shopEN)
        if storeFolder then
            for _, v in next, storeFolder:GetDescendants() do
                if v.Name == "ShopItems" then
                    for _, box in next, v:GetChildren() do
                        if box:FindFirstChild("BoxItemName") and box.BoxItemName.Value == selectedItemEN then
                            for _, val in pairs(box:GetChildren()) do
                                if val.Name == "Price" or val.Name == "BoxItemPrice" then
                                    price = tonumber(val.Value) or 0
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if price > 0 then
            local total = price * buyAmount
            PriceLabel:SetDesc(string.format("单价: %d | 数量: %d | 总价: %d | 当前余额: %d", price, buyAmount, total, GetMoney()))
        else
            PriceLabel:SetDesc(string.format("距离过远未加载价格 | 数量: %d | 当前余额: %d", buyAmount, GetMoney()))
        end
    end
})

TabBuy:Slider({
    Title = "购买数量 (上限30)",
    Value = { Min = 1, Max = 30, Default = 1 },
    Callback = function(val)
        buyAmount = val
    end
})

TabBuy:Button({
    Title = "开始购买",
    Desc = "自动带你过去加载商店并购买",
    Callback = function()
        if not selectedShopEN or not selectedItemEN then return end
        
        local oldpos = player.Character.HumanoidRootPart.CFrame
        
        task.spawn(function()
            local storeFolder = Workspace:FindFirstChild("Stores") and Workspace.Stores:FindFirstChild(selectedShopEN)
            local npcModel = nil
            if storeFolder then
                for _, child in next, storeFolder:GetChildren() do
                    if child:IsA("Model") and child:FindFirstChild("Dialog") then
                        npcModel = child break
                    end
                end
            end
            
            WindUI:Notify({ Title = "加载中", Content = "正在传送至商店加载模型...", Duration = 3 })
            
            if not npcModel and storeFolder then
                npcModel = storeFolder:FindFirstChild(ShopDB[selectedShopEN].NPC)
            end
            
            if npcModel and npcModel:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = npcModel.HumanoidRootPart.CFrame + Vector3.new(0, 3, 5)
            end
            
            task.wait(1.5)
            
            local targetBox = nil
            local targetCounter = nil
            
            if storeFolder then
                for _, v in next, storeFolder:GetDescendants() do
                    if v.Name == "Counter" or v.Name == "counter" then targetCounter = v end
                    if v.Name == "ShopItems" then
                        for _, box in next, v:GetChildren() do
                            if box:FindFirstChild("BoxItemName") and box.BoxItemName.Value == selectedItemEN then
                                targetBox = box
                            end
                        end
                    end
                end
            end
            
            if not targetBox or not targetCounter then
                WindUI:Notify({ Title = "失败", Content = "物品模型加载失败，请重试", Duration = 4 })
                player.Character.HumanoidRootPart.CFrame = oldpos
                return
            end
            
            local price = 0
            for _, val in pairs(targetBox:GetChildren()) do
                if val.Name == "Price" or val.Name == "BoxItemPrice" then
                    price = tonumber(val.Value) or 0
                    break
                end
            end
            
            local currentMoney = GetMoney()
            if price > 0 and currentMoney < (price * buyAmount) then
                WindUI:Notify({ Title = "余额不足", Content = "你的钱不够！需要 " .. (price*buyAmount) .. "，你只有 " .. currentMoney, Duration = 5 })
                player.Character.HumanoidRootPart.CFrame = oldpos
                return
            end
            
            local npcID = ShopDB[selectedShopEN].ID
            local npcName = npcModel.Name
            local successCount = 0
            
            for i = 1, buyAmount do
                WindUI:Notify({ Title = "搬运中", Content = "正在购买第 " .. i .. "/" .. buyAmount .. " 个", Duration = 2 })
                
                local t = 0
                repeat
                    DragModel(targetBox, targetCounter.CFrame + Vector3.new(0, 1, 0))
                    if targetBox:FindFirstChild("Main") then
                        player.Character.HumanoidRootPart.CFrame = targetBox.Main.CFrame + Vector3.new(0, 1, 5)
                    end
                    task.wait(0.05)
                    t = t + 0.05
                until (targetBox:FindFirstChild("Main") and (targetBox.Main.Position - targetCounter.Position).Magnitude < 6) or t > 3
                
                if npcModel:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = npcModel.HumanoidRootPart.CFrame + Vector3.new(0, 1, 5)
                end
                task.wait(0.2)
                
                local args = {
                    {
                        ID = npcID,
                        Character = npcModel,
                        Name = npcName,
                        Dialog = npcModel:FindFirstChild("Dialog")
                    },
                    "ConfirmPurchase"
                }
                pcall(function()
                    RS.NPCDialog.PlayerChatted:InvokeServer(unpack(args))
                end)
                task.wait(0.5)
                
                for j = 1, 15 do
                    DragModel(targetBox, oldpos)
                    task.wait(0.02)
                end
                successCount = successCount + 1
            end
            
            WindUI:Notify({ Title = "完成", Content = "成功购买并拉回 " .. successCount .. " 个物品", Duration = 4 })
            player.Character.HumanoidRootPart.CFrame = oldpos
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