local player = game.Players.LocalPlayer
local TS = game:GetService("TeleportService")
local WhitelistURL = "https://raw.githubusercontent.com/moos294/jooiionn/main/whitelist.txt" 

local function CheckWhitelist()
    local success, response = pcall(function()
        return game:HttpGet(WhitelistURL)
    end)
    
    if not success or not response then
        return false
    end
    
    if string.find(response, player.Name) or string.find(response, tostring(player.UserId)) then
        return true
    end
    
    return false
end

local isWhitelisted = CheckWhitelist()
if not isWhitelisted then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "系统提示",
        Text = "你并没有白名单无法用此脚本",
        Duration = 5
    })
    return 
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "验证成功",
    Text = "欢迎尊贵的白名单使用此脚本",
    Duration = 5
})

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存木材",
    Icon = "rbxassetid://10882439086",
    Author = "作者:封存NB",
    Size = UDim2.fromOffset(420, 360),
    Transparent = true,
    Theme = "Dark"
})

local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local Mouse = player:GetMouse()

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
                                targetWood = m
                                break
                            end
                        end
                    end
                end
            end
            if targetWood then break end
        end
        
        if targetWood then
            local baseWood = targetWood:FindFirstChild("WoodSection")
            if baseWood then
                local safePos = baseWood.CFrame + Vector3.new(0, 2.5, 3.5)
                player.Character.HumanoidRootPart.CFrame = safePos
                WindUI:Notify({ Title = "成功", Content = "传送成功", Duration = 3 })
            end
        else
            WindUI:Notify({ Title = "错误", Content = "没找到这种树", Duration = 3 })
        end
    end
})

TabTP:Button({
    Title = "保存当前位置为 传送点1",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            playerPos[1] = player.Character.HumanoidRootPart.CFrame
            WindUI:Notify({ Title = "成功", Content = "已保存传送点1", Duration = 3 })
        end
    end
})

TabTP:Button({
    Title = "传送到 传送点1",
    Callback = function()
        if playerPos[1] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = playerPos[1]
            WindUI:Notify({ Title = "成功", Content = "已回到传送点1", Duration = 3 })
        else
            WindUI:Notify({ Title = "错误", Content = "未保存传送点1", Duration = 3 })
        end
    end
})

TabTP:Button({
    Title = "保存当前位置为 传送点2",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            playerPos[2] = player.Character.HumanoidRootPart.CFrame
            WindUI:Notify({ Title = "成功", Content = "已保存传送点2", Duration = 3 })
        end
    end
})

TabTP:Button({
    Title = "传送到 传送点2",
    Callback = function()
        if playerPos[2] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = playerPos[2]
            WindUI:Notify({ Title = "成功", Content = "已回到传送点2", Duration = 3 })
        else
            WindUI:Notify({ Title = "错误", Content = "未保存传送点2", Duration = 3 })
        end
    end
})

TabTP:Button({
    Title = "保存当前位置为 传送点3",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            playerPos[3] = player.Character.HumanoidRootPart.CFrame
            WindUI:Notify({ Title = "成功", Content = "已保存传送点3", Duration = 3 })
        end
    end
})

TabTP:Button({
    Title = "传送到 传送点3",
    Callback = function()
        if playerPos[3] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = playerPos[3]
            WindUI:Notify({ Title = "成功", Content = "已回到传送点3", Duration = 3 })
        else
            WindUI:Notify({ Title = "错误", Content = "未保存传送点3", Duration = 3 })
        end
    end
})

local TabItem = Window:Tab({ Title = "物品传送", Icon = "rbxassetid://10882439086" })
local selectedBringTarget = "拉回点位1"

TabItem:Dropdown({
    Title = "选择物品拉回的目标点",
    Values = {"拉回点位1", "拉回点位2", "拉回点位3"},
    Value = "拉回点位1",
    Callback = function(option)
        selectedBringTarget = option
    end
})

TabItem:Button({
    Title = "设置 物品点位1",
    Callback = function()
        if Workspace:FindFirstChild("BRING1") then Workspace.BRING1:Destroy() end
        local p = Instance.new("Part", Workspace)
        p.Name = "BRING1"
        p.Transparency = 1
        p.Anchored = true
        p.CFrame = player.Character.HumanoidRootPart.CFrame
        p.CanCollide = false
        p.Size = player.Character.HumanoidRootPart.Size
        
        local posBox = Instance.new("SelectionBox", p)
        posBox.Color3 = Color3.new(0, 255, 0)
        posBox.Adornee = p
        WindUI:Notify({ Title = "成功", Content = "物品点位1已设置", Duration = 3 })
    end
})

TabItem:Button({
    Title = "设置 物品点位2",
    Callback = function()
        if Workspace:FindFirstChild("BRING2") then Workspace.BRING2:Destroy() end
        local p = Instance.new("Part", Workspace)
        p.Name = "BRING2"
        p.Transparency = 1
        p.Anchored = true
        p.CFrame = player.Character.HumanoidRootPart.CFrame
        p.CanCollide = false
        p.Size = player.Character.HumanoidRootPart.Size
        
        local posBox = Instance.new("SelectionBox", p)
        posBox.Color3 = Color3.new(0, 255, 0)
        posBox.Adornee = p
        WindUI:Notify({ Title = "成功", Content = "物品点位2已设置", Duration = 3 })
    end
})

TabItem:Button({
    Title = "设置 物品点位3",
    Callback = function()
        if Workspace:FindFirstChild("BRING3") then Workspace.BRING3:Destroy() end
        local p = Instance.new("Part", Workspace)
        p.Name = "BRING3"
        p.Transparency = 1
        p.Anchored = true
        p.CFrame = player.Character.HumanoidRootPart.CFrame
        p.CanCollide = false
        p.Size = player.Character.HumanoidRootPart.Size
        
        local posBox = Instance.new("SelectionBox", p)
        posBox.Color3 = Color3.new(0, 255, 0)
        posBox.Adornee = p
        WindUI:Notify({ Title = "成功", Content = "物品点位3已设置", Duration = 3 })
    end
})

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
            local targetPartName = "BRING1"
            if selectedBringTarget == "拉回点位2" then targetPartName = "BRING2" end
            if selectedBringTarget == "拉回点位3" then targetPartName = "BRING3" end
            
            if Workspace:FindFirstChild(targetPartName) then
                local targetCFrame = Workspace[targetPartName].CFrame
                local targetPart = Mouse.Target
                if not targetPart then return end
                local targetModel = targetPart.Parent
                
                if targetModel and (targetModel.Name == "Plank" or targetModel:FindFirstChild("WoodSection") or targetModel:FindFirstChild("Owner")) then
                    for i = 1, 40 do
                        DragModel(targetModel, targetCFrame)
                        task.wait(0.02)
                    end
                    WindUI:Notify({ Title = "传送成功", Content = "物品已拉回" .. selectedBringTarget, Duration = 3 })
                end
            else
                WindUI:Notify({ Title = "错误", Content = "请先设置 " .. selectedBringTarget, Duration = 3 })
            end
        end)
        WindUI:Notify({ Title = "成功", Content = "工具已放入背包", Duration = 3 })
    end
})

local TabServer = Window:Tab({ Title = "服务器", Icon = "rbxassetid://10882439086" })
local targetPlaceId = tostring(game.PlaceId)

TabServer:Input({
    Title = "指定服务器 ID (PlaceId)",
    Value = tostring(game.PlaceId),
    Callback = function(text)
        targetPlaceId = text
    end
})

TabServer:Button({
    Title = "重新进入当前服务器",
    Desc = "快速重连当前私人服务器",
    Callback = function()
        local options = Instance.new("TeleportOptions")
        options.ServerInstanceId = game.JobId
        local success, err = pcall(function()
            TS:TeleportAsync(game.PlaceId, {player}, options)
        end)
        
        if not success then
            pcall(function()
                TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            end)
        end
    end
})

TabServer:Button({
    Title = "指定服务器换服",
    Desc = "需在上方填写正确的 PlaceId",
    Callback = function()
        local id = tonumber(targetPlaceId)
        if id then
            local success, err = pcall(function()
                TS:TeleportAsync(id, {player})
            end)
            if not success then
                pcall(function()
                    TS:Teleport(id, player)
                end)
            end
        else
            WindUI:Notify({ Title = "错误", Content = "服务器 ID 格式不正确", Duration = 3 })
        end
    end
})

TabServer:Button({
    Title = "随机换服",
    Desc = "随机加入当前游戏的另一个服务器",
    Callback = function()
        local success, err = pcall(function()
            TS:TeleportAsync(game.PlaceId, {player})
        end)
        if not success then
            pcall(function()
                TS:Teleport(game.PlaceId, player)
            end)
        end
    end
})

local TabExtra = Window:Tab({ Title = "其他功能", Icon = "rbxassetid://10882439086" })

local isDragEnabled = false
local dragConn = nil

local function stopDrag()
    isDragEnabled = false
    if dragConn then
        dragConn:Disconnect()
        dragConn = nil
    end
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
    Title = "强制关闭拖拽",
    Callback = function()
        stopDrag()
        local toggleObj = Window:GetToggle("开启拖拽器")
        if toggleObj then toggleObj:Set(false) end
    end
})

TabExtra:Button({
    Title = "开启飞行",
    Desc = "点击加载飞行脚本V3",
    Callback = function()
        WindUI:Notify({ Title = "加载中", Content = "正在注入飞行脚本...", Duration = 3 })
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/385j8888/ZOUMAGUIX/refs/heads/main/%E9%A3%9E%E8%A1%8C%E8%84%9A%E6%9C%ACV3(%E5%85%A8%E6%B8%B8%E6%88%8F%E9%80%9A%E7%94%A8).txt"))()
        end)
    end
})