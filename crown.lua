local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "木材大亨专用版2.2",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(420, 320),
    Transparent = true,
    Theme = "Dark"
})

local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")

local function DragModel(m, cf)
	pcall(function() RS.Interaction.ClientIsDragging:FireServer(m) end)
	if not m.PrimaryPart then m.PrimaryPart = m:FindFirstChildOfClass("Part") end
	if m.PrimaryPart then 
        m.PrimaryPart.Velocity = Vector3.zero
        m:SetPrimaryPartCFrame(cf) 
    end
end

local function Teleport(cf)
	if not player.Character then return end
	if player.Character.Humanoid.SeatPart then
		task.spawn(function() 
            for i = 1, 15 do DragModel(player.Character.Humanoid.SeatPart.Parent, cf) end 
        end)
		return
	end
	for i = 1, 3 do 
        DragModel(player.Character, cf)
        task.wait()
    end
end

local function toggleInvis(num)
	if not player.Character then return end
	for i, v in pairs(player.Character:GetChildren()) do
		if v:IsA("Accessory") then 
			for i, k in pairs(v:GetChildren()) do 
				if k:IsA("Part") then k.Transparency = num end 
			end 
		end
		if v:IsA("Part") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = num
			if v.Name == "Head" and v:FindFirstChild("face") then 
				v:FindFirstChild("face").Transparency = num 
			end
		end
	end
end

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
                    c.P = 120000
                    c.D = 1000
                    c.maxForce = Vector3.new(1, 1, 1) * 1000000
                    
                    b.MaxTorque = Vector3.new(1, 1, 1) * 200
                    b.P = 1200
                    b.D = 140
                    
                    local dragEvent = RS:FindFirstChild("Interaction") and RS.Interaction:FindFirstChild("ClientIsDragging")
                    if dragEvent then
                        pcall(function() dragEvent:FireServer() end)
                    end
                    
                    task.wait()
                end
            end)
        end
    end)
end

TabDrag:Toggle({
    Title = "开启完美拖拽",
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

local TabWood = Window:Tab({ Title = "自动伐木", Icon = "rbxassetid://10734945123" })

local isCutting = false
local targetTree = "Generic"
local woodQty = 1

local tree_list = {
	"普通木 (Generic)", "幻影木 (LoneCave)", "电木 (Electric)", "胡桃木 (Walnut)", "星木 (Star)", "樱桃木 (Cherry)", "桦木 (Birch)", "冰霜木 (Frost)",
	"大理石木 (Marble)", "火山木 (Volcano)", "金色沼泽木 (GoldSwampy)", "普通金木 (GenericGold)", "巨型橡木 (GreatOak)", "石头木 (Stone)", "辐射木 (Radioactive)",
	"洞穴木 (Cavern)", "岩浆木 (Magma)", "蓝木 (CaveCrawler)", "灵魂木 (Spirit)", "烈焰木 (Flame)", "星辰木 (Celestial)", "橡木 (Oak)", "绿色沼泽木 (GreenSwampy)",
	"沙子木 (Sand)", "松木 (Pine)", "玻璃木 (Glass)", "彩虹木 (Rainbow)", "冰木 (Ice)"
}

local function cutTree(wood, tool, secId)
	local damage = 1
	local success, mod = pcall(function() return require(RS.AxeClasses[("AxeClass_%s"):format(tool.ToolName.Value)]) end)
	if success then damage = mod.new().Damage end
    
    if damage < 5 then damage = damage * 50 end
    
	RS.Interaction.RemoteProxy:FireServer(wood.CutEvent, {
		["tool"] = tool;
        ["faceVector"] = Vector3.zAxis;
        ["height"] = 0.3;
        ["sectionId"] = tonumber(secId); 
        ["hitPoints"] = tonumber(damage); 
        ["cooldown"] = 0;
        ["cuttingClass"] = "Axe";
	})
end

TabWood:Dropdown({
    Title = "选择树木种类",
    Values = tree_list,
    Value = "普通木 (Generic)",
    Callback = function(option)
        local m = string.match(option, "%((.+)%)")
        if m then targetTree = m else targetTree = option end
    end
})

TabWood:Slider({
    Title = "砍伐数量",
    Value = { Min = 1, Max = 50, Default = 1 },
    Callback = function(val)
        woodQty = val
    end
})

local function resetCuttingState()
    isCutting = false
    toggleInvis(0)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.Anchored = false
    end
end

player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        if isCutting then
            resetCuttingState()
            WindUI:Notify({ Title = "警告", Content = "检测到角色死亡，已自动中断！", Duration = 4 })
        end
    end)
end)

if player.Character then
    player.Character:WaitForChild("Humanoid").Died:Connect(function()
        if isCutting then
            resetCuttingState()
            WindUI:Notify({ Title = "警告", Content = "检测到角色死亡，已自动中断！", Duration = 4 })
        end
    end)
end

TabWood:Button({
    Title = "开始贴脸站桩砍树",
    Desc = "精准站立在树皮外沿，锁定不下落",
    Callback = function()
        if isCutting then return end
        
        local tool = player.Character:FindFirstChild("Tool") or player.Backpack:FindFirstChild("Tool") or player.Backpack:FindFirstChildWhichIsA("Tool")
        if not tool then
            WindUI:Notify({ Title = "错误", Content = "背包里没有斧头！", Duration = 3 })
            return
        end
        
        if tool.Parent ~= player.Character then
            player.Character.Humanoid:EquipTool(tool)
            task.wait(0.5)
        end
        
        isCutting = true
        local oldpos = player.Character.HumanoidRootPart.CFrame
        local count = 0
        
        task.spawn(function()
            while isCutting and count < woodQty do
                if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
                    isCutting = false
                    break
                end
                
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
                    toggleInvis(1)
                    
                    local baseWood = targetWood:FindFirstChild("WoodSection")
                    local targetId = 2
                    for _, w in pairs(targetWood:GetDescendants()) do
                        if w.Name == "WoodSection" and w:FindFirstChild("ID") then
                            if w.ID.Value == 1 then
                                baseWood = w
                                targetId = 1
                                break
                            else
                                baseWood = w
                                targetId = w.ID.Value
                            end
                        end
                    end
                    
                    if baseWood then
                        -- 射线找地面
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {player.Character, targetWood}
                        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                        
                        local result = Workspace:Raycast(baseWood.Position + Vector3.new(0, 10, 0), Vector3.new(0, -500, 0), raycastParams)
                        
                        local groundY = baseWood.Position.Y
                        if result then
                            groundY = result.Position.Y
                        end
                        
                        -- 计算贴脸距离：树半径 + 玩家半径(约2) + 0.5缝隙
                        local treeRadius = math.max(baseWood.Size.X, baseWood.Size.Z) / 2
                        local standDist = treeRadius + 2.5
                        
                        -- 站在树的 Z 轴正前方
                        local safePos = CFrame.new(baseWood.Position.X, groundY + 3, baseWood.Position.Z + standDist)
                        Teleport(safePos)
                        
                        -- 锁死在地面
                        local hrp = player.Character.HumanoidRootPart
                        if hrp then
                            hrp.Anchored = true 
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end
                        
                        local timeout = 0
                        while isCutting and not targetWood:FindFirstChild("RootCut") and timeout < 100 do
                            if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
                                isCutting = false
                                break
                            end
                            
                            local currentTool = player.Character:FindFirstChild("Tool")
                            if currentTool then
                                cutTree(targetWood, currentTool, targetId)
                            end
                            
                            task.wait(0.1)
                            timeout = timeout + 1
                        end
                        
                        if hrp then
                            hrp.Anchored = false 
                        end
                        
                        if isCutting and targetWood:FindFirstChild("RootCut") then
                            local Log
                            for _, b in next, Workspace.LogModels:GetDescendants() do
                                if b:FindFirstChild("Owner") and b.Owner.Value == player then Log = b end
                            end
                            if Log then
                                for i = 1, 20 do
                                    DragModel(Log, oldpos)
                                    task.wait(0.1)
                                end
                            end
                            count = count + 1
                        end
                    end
                else
                    WindUI:Notify({ Title = "提示", Content = "未发现目标树木", Duration = 3 })
                    break
                end
                task.wait(0.2)
            end
            
            resetCuttingState()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
                Teleport(oldpos)
            end
        end)
    end
})

TabWood:Button({
    Title = "停止",
    Desc = "强行中断",
    Callback = function()
        resetCuttingState()
        WindUI:Notify({ Title = "已停止", Content = "已中断", Duration = 3 })
    end
})