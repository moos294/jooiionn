local player = game.Players.LocalPlayer
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

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存木材",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
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
local oldPos = nil

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
    Title = "保存当前位置",
    Desc = "传送前先点一下，方便砍完回来",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            oldPos = player.Character.HumanoidRootPart.CFrame
            WindUI:Notify({ Title = "成功", Content = "已保存当前位置", Duration = 3 })
        end
    end
})

TabTP:Button({
    Title = "传送到树旁",
    Desc = "安全传送到树旁边的空地上，绝对不会卡树",
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
                WindUI:Notify({ Title = "传送成功", Content = "已传送完成", Duration = 3 })
            else
                WindUI:Notify({ Title = "提示", Content = "找不到树干部分", Duration = 3 })
            end
        else
            WindUI:Notify({ Title = "错误", Content = "并没有这种树", Duration = 3 })
        end
    end
})

TabTP:Button({
    Title = "传送回原点",
    Callback = function()
        if oldPos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = oldPos
            WindUI:Notify({ Title = "成功", Content = "已回到原点", Duration = 3 })
        else
            WindUI:Notify({ Title = "错误", Content = "你还没有保存位置", Duration = 3 })
        end
    end
})

local TabItem = Window:Tab({ Title = "物品传送", Icon = "rbxassetid://10882439086" })

TabItem:Button({
    Title = "设置拉回点位",
    Desc = "在你当前脚下设置一个拉回点",
    Callback = function()
        if Workspace:FindFirstChild("BRING") then Workspace.BRING:Destroy() end
        local p = Instance.new("Part", Workspace)
        p.Name = "BRING"
        p.Transparency = 1
        p.Anchored = true
        p.CFrame = player.Character.HumanoidRootPart.CFrame
        p.CanCollide = false
        p.Size = player.Character.HumanoidRootPart.Size
        
        local posBox = Instance.new("SelectionBox", p)
        posBox.Name = "BRINGBOX"
        posBox.Color3 = Color3.new(0, 255, 0)
        posBox.Adornee = posBox.Parent
        WindUI:Notify({ Title = "成功", Content = "点位已设置", Duration = 3 })
    end
})

TabItem:Button({
    Title = "获取点击传送工具",
    Desc = "拿在手上点击木头/物品，直接拉回点位",
    Callback = function()
        if player.Backpack:FindFirstChild("点击传送") or player.Character:FindFirstChild("点击传送") then
            player.Backpack["点击传送"]:Destroy()
        end
        local a = Instance.new("Tool", player.Backpack)
        a.Name = "点击传送"
        a.RequiresHandle = false
        a.Activated:Connect(function()
            if Workspace:FindFirstChild("BRING") then
                local targetCFrame = Workspace.BRING.CFrame
                local targetPart = Mouse.Target
                if not targetPart then return end
                local targetModel = targetPart.Parent
                
                if targetModel and (targetModel.Name == "Plank" or targetModel:FindFirstChild("WoodSection") or targetModel:FindFirstChild("Owner")) then
                    for i = 1, 40 do
                        DragModel(targetModel, targetCFrame)
                        task.wait(0.02)
                    end
                    WindUI:Notify({ Title = "传送成功", Content = "传送成功", Duration = 3 })
                end
            else
                WindUI:Notify({ Title = "错误", Content = "请先设置拉回点位！", Duration = 3 })
            end
        end)
        WindUI:Notify({ Title = "成功", Content = "工具已放入背包", Duration = 3 })
    end
})

local TabDrag = Window:Tab({ Title = "完美拖拽", Icon = "rbxassetid://10734898355" })
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

TabDrag:Toggle({
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

TabDrag:Button({
    Title = "强制关闭拖拽",
    Desc = "如果遇到卡顿，点此强行断开",
    Callback = function()
        stopDrag()
        local toggleObj = Window:GetToggle("开启完美拖拽")
        if toggleObj then toggleObj:Set(false) end
    end
})