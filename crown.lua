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
    local oldGui = CoreGui:FindFirstChild("封存木材1.2")
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
local itemMap = {}
local buyAmount = 1
local selectedItemEN = ""

local TranslationMap = {
    ["SeaSide"]="海边商店", ["VIPSHOP"]="VIP商店", ["MountainSide"]="山边商店", ["BlackMarket"]="黑市",
    ["LogicStore"]="逻辑商店", ["FineArt"]="艺术品商店", ["FineFinds"]="寻宝商店", ["FurnitureStore"]="家具店",
    ["SaplingCart"]="树苗车", ["PlanterStore"]="种植商店", ["CarStore"]="汽车店", ["WoodRUs"]="木材反斗城",
    ["SallysSeasonal"]="莎莉商店", ["StoneRUs"]="石头反斗城", ["Igloo"]="冰屋", ["MusicStore"]="音乐商店",
    ["BasicHatchet"]="基础斧头", ["SilverAxe"]="银斧头", ["EndTimesAxe"]="末世斧", ["Chainsaw"]="电锯",
    ["OffRoadTruck"]="越野卡车", ["UtilityTruck"]="多用途运载车", ["Pickup1"]="皮卡1", ["Pickup2"]="皮卡2",
    ["Painting1"]="画作1", ["Painting2"]="画作2", ["Wall1"]="矮波纹墙", ["Floor1"]="地板",
    ["Sawmill"]="破旧锯木厂", ["Sawmill2"]="普通锯木厂", ["Wire"]="电线", ["Button0"]="按钮"
}

local npcIDs = {
    ["Thom"] = 7, ["Corey"] = 8, ["Jenny"] = 9, ["Bob"] = 10, ["Timothy"] = 11, 
    ["Lincoln"] = 12, ["Ruhven"] = 1, ["Seranok"] = 14, ["Hoover"] = 15, ["Manachron"] = 20
}

local function ScanShops()
    itemMap = {}
    local tempList = {}
    
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
                local storeNameCN = TranslationMap[storeFolder.Name] or storeFolder.Name
                for _, box in next, v:GetChildren() do
                    if box:FindFirstChild("BoxItemName") then
                        local bName = box.BoxItemName.Value
                        local bNameCN = TranslationMap[bName] or bName
                        local displayName = "[" .. storeNameCN .. "] " .. bNameCN
                        
                        local price = 0
                        for _, val in pairs(box:GetChildren()) do
                            if val:IsA("NumberValue") or val:IsA("IntValue") or val:IsA("StringValue") then
                                if val.Name == "Price" or val.Name == "BoxItemPrice" or val.Name == "Cost" then
                                    price = tonumber(val.Value) or 0
                                    break
                                end
                            end
                        end
                        
                        if not itemMap[displayName] then
                            itemMap[displayName] = {
                                Box = box,
                                Counter = counter,
                                NPC = npcModel,
                                NPCName = npcModel.Name,
                                ItemEN = bName,
                                Price = price
                            }
                            table.insert(tempList, displayName)
                        end
                    end
                end
            end
        end
    end
    table.sort(tempList)
    return tempList
end

local PriceLabel = TabBuy:Paragraph({
    Title = "价格预览",
    Desc = "请选择物品",
    Color = Color3.fromRGB(255, 200, 0)
})

local BuyDropdown = TabBuy:Dropdown({
    Title = "选择要购买的物品",
    Values = {"加载中..."},
    Value = "加载中...",
    Callback = function(opt) 
        selectedItemEN = opt 
        local data = itemMap[opt]
        if data then
            local total = data.Price * buyAmount
            PriceLabel:SetDesc(string.format("单价: %d | 数量: %d | 总价: %d | 当前余额: %d", data.Price, buyAmount, total, GetMoney()))
        end
    end
})

TabBuy:Slider({
    Title = "购买数量 (上限30)",
    Value = { Min = 1, Max = 30, Default = 1 },
    Callback = function(val)
        buyAmount = val
        local data = itemMap[selectedItemEN]
        if data then
            local total = data.Price * buyAmount
            PriceLabel:SetDesc(string.format("单价: %d | 数量: %d | 总价: %d | 当前余额: %d", data.Price, buyAmount, total, GetMoney()))
        end
    end
})

task.spawn(function()
    local list = ScanShops()
    if #list > 0 then
        BuyDropdown:Refresh(list)
        BuyDropdown:SetValue(list[1])
        selectedItemEN = list[1]
        local data = itemMap[list[1]]
        PriceLabel:SetDesc(string.format("单价: %d | 数量: %d | 总价: %d | 当前余额: %d", data.Price, buyAmount, data.Price * buyAmount, GetMoney()))
    end
end)

TabBuy:Button({
    Title = "开始批量购买",
    Desc = "自动校验余额，不够立刻停止",
    Callback = function()
        if not selectedItemEN or selectedItemEN == "加载中..." then return end
        local data = itemMap[selectedItemEN]
        if not data then return end
        
        local unitPrice = data.Price
        local totalPrice = unitPrice * buyAmount
        local currentMoney = GetMoney()
        
        if currentMoney < totalPrice then
            WindUI:Notify({ Title = "余额不足", Content = "你的钱不够！需要 " .. totalPrice .. "，你只有 " .. currentMoney, Duration = 5 })
            return
        end
        
        local box = data.Box
        local counter = data.Counter
        local npc = data.NPC
        local npcID = npcIDs[data.NPCName] or 20 
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