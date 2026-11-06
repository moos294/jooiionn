local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "木材辅助终端1.0",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(420, 320),
    Transparent = true,
    Theme = "Dark"
})

local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")

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

local function DragModel(m, cf)
	pcall(function() RS.Interaction.ClientIsDragging:FireServer(m) end)
	if not m.PrimaryPart then m.PrimaryPart = m:FindFirstChildOfClass("Part") end
	if m.PrimaryPart then m:SetPrimaryPartCFrame(cf) end
end

local function Teleport(cf)
	if not player.Character then return end
	if player.Character.Humanoid.SeatPart then
		for i = 1, 15 do DragModel(player.Character.Humanoid.SeatPart.Parent, cf); task.wait() end
		return
	end
	for i = 1, 3 do DragModel(player.Character, cf); task.wait() end
end

local function toggleInvis(num)
	if not player.Character then return end
	for i, v in pairs(player.Character:GetChildren()) do
		if v:IsA("Accessory") then 
			for i, k in pairs(v:GetChildren()) do 
				if k:IsA("Part") then 
					k.Transparency = num 
					k.CanCollide = false
				end 
			end 
		end
		if v:IsA("Part") then
			v.CanCollide = false
			if v.Name ~= "HumanoidRootPart" then
				v.Transparency = num
			end
			if v.Name == "Head" and v:FindFirstChild("face") then 
				v:FindFirstChild("face").Transparency = num 
			end
		end
	end
end

local function getAxe()
	for _, v in next, player.Character:GetChildren() do if v:IsA("Tool") and v:FindFirstChild("CuttingTool") then return v end end
	for _, v in next, player.Backpack:GetChildren() do if v:IsA("Tool") and v:FindFirstChild("CuttingTool") then return v end end
	return nil
end

local function cutTree(wood, axe)
	local damage = 0
	if axe.ToolName.Value == "EndTimesAxe" and wood.TreeClass.Value == "LoneCave" then
		damage = 10000000
	else
		local success, mod = pcall(function() return require(RS.AxeClasses[("AxeClass_%s"):format(axe.ToolName.Value)]) end)
		if success then damage = mod.new().Damage else damage = 10 end
	end
	
	RS.Interaction.RemoteProxy:FireServer(wood.CutEvent, {
		["tool"] = axe; ["faceVector"] = Vector3.new(1,0,0); ["height"] = 0.3;
		["sectionId"] = 1; ["hitPoints"] = tonumber(damage); ["cooldown"] = 0.01; ["cuttingClass"] = "Axe";
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
end

player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        if isCutting then
            resetCuttingState()
            WindUI:Notify({ Title = "警告", Content = "检测到角色死亡，伐木已自动中断！", Duration = 4 })
        end
    end)
end)

if player.Character then
    player.Character:WaitForChild("Humanoid").Died:Connect(function()
        if isCutting then
            resetCuttingState()
            WindUI:Notify({ Title = "警告", Content = "检测到角色死亡，伐木已自动中断！", Duration = 4 })
        end
    end)
end

TabWood:Button({
    Title = "开始自动伐木",
    Desc = "自动隐身、传送、砍树并拉回原位",
    Callback = function()
        if isCutting then 
            WindUI:Notify({ Title = "提示", Content = "正在运行中！", Duration = 2 })
            return 
        end
        
        local axe = getAxe()
        if not axe then
            WindUI:Notify({ Title = "错误", Content = "背包里没有斧头！", Duration = 3 })
            return
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
                            if m:FindFirstChild("CutEvent") and m:FindFirstChild("WoodSection") and not m:FindFirstChild("RootCut") then
                                if m.Owner.Value == nil or m.Owner.Value == player then
                                    if m.TreeClass.Value == targetTree then targetWood = m; break; end
                                end
                            end
                        end
                    end
                    if targetWood then break end
                end
                
                if targetWood then
                    toggleInvis(1)
                    local woodPart = targetWood:FindFirstChild("WoodSection")
                    
                    local treeRadius = math.max(woodPart.Size.X, woodPart.Size.Z) * 0.5
                    local safeOffset = Vector3.new(0, 3, treeRadius + 6)
                    
                    local timeout = 0
                    while isCutting and not targetWood:FindFirstChild("RootCut") and timeout < 150 do
                        if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
                            isCutting = false
                            break
                        end
                        
                        Teleport(woodPart.CFrame + safeOffset)
                        task.wait(0.05)
                        cutTree(targetWood, axe)
                        timeout = timeout + 1
                    end
                    
                    if isCutting and targetWood:FindFirstChild("RootCut") then
                        local Log
                        for _, b in next, Workspace.LogModels:GetDescendants() do
                            if b:FindFirstChild("Owner") and b.Owner.Value == player then Log = b end
                        end
                        if Log then
                            for i = 1, 15 do
                                DragModel(Log, oldpos)
                                task.wait(0.1)
                            end
                        end
                        count = count + 1
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
            WindUI:Notify({ Title = "完成", Content = "已结束本次伐木", Duration = 3 })
        end)
    end
})

TabWood:Button({
    Title = "停止伐木",
    Desc = "强行中断并恢复正常状态",
    Callback = function()
        resetCuttingState()
        WindUI:Notify({ Title = "已停止", Content = "已中断自动伐木", Duration = 3 })
    end
})