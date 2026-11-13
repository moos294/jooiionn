local player = game.Players.LocalPlayer
local Workspace = workspace
local RS = game:GetService("ReplicatedStorage")
local Mouse = player:GetMouse()
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function CheckWhitelist()
    local url = "https://raw.githubusercontent.com/moos294/jooiionn/main/whitelist.txt"
    local success, content = pcall(function() return game:HttpGet(url) end)
    if not success or not content then return false end
    if string.find(content, player.Name) then return true end
    return false
end

if not CheckWhitelist() then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "系统提示", Text = "你并没有白名单无法用此脚本", Duration = 5})
    return 
end

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "验证成功", Text = "欢迎尊贵的白名单使用此脚本", Duration = 5})

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/UI.lua"))()
local Window = UI.Window
local WindUI = UI.WindUI

for _, v in ipairs(UI.Gui.Panel:GetDescendants()) do
    if v:IsA("TextLabel") then
        if v.Text == "ORIGAMI" then v.Text = "封存木材 V0.1" end
        if v.Text == "BUILD TOOL" then v.Text = "Author: 封存" end
    end
end

local TabHome = Window:Tab({ Title = "个人主页" })
local TabTree = Window:Tab({ Title = "带来树" })
local TabBuy = Window:Tab({ Title = "自动购买" })
local TabCraft = Window:Tab({ Title = "快速合成剑" })
local TabTP = Window:Tab({ Title = "传送" })
local TabExtra = Window:Tab({ Title = "其他功能" })

local function Notify(title, content, duration)
    WindUI:Notify({Title = title, Content = content, Duration = duration or 3})
end

local function DragModel(m, cf)
    pcall(function() RS.Interaction.ClientIsDragging:FireServer("Begin", m, 4) end)
    pcall(function() RS.Interaction.ClientIsDragging:FireServer("Refresh", m, 5) end)
    if not m.PrimaryPart then m.PrimaryPart = m:FindFirstChildOfClass("Part") end
    if m.PrimaryPart then 
        m.PrimaryPart.Velocity = Vector3.zero
        m:SetPrimaryPartCFrame(cf) 
    end
end

TabHome:Paragraph({ Title = "【 属性修改 】" })
TabHome:Input({ Title = "移动速度", Value = "16", Callback = function(v)
    if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end
end })
TabHome:Input({ Title = "跳跃高度", Value = "50", Callback = function(v)
    if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.JumpPower = tonumber(v) or 50; player.Character.Humanoid.UseJumpPower = true end
end })

local infJump = false
TabHome:Toggle({ Title = "无限跳跃", Value = false, Callback = function(s) infJump = s end })
UserInputService.JumpRequest:Connect(function()
    if infJump and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
TabHome:Button({ Title = "开启飞行", Callback = function()
    pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/385j8888/ZOUMAGUIX/refs/heads/main/%E9%A3%9E%E8%A1%8C%E8%84%9A%E6%9C%ACV3(%E5%85%A8%E6%B8%B8%E6%88%8F%E9%80%9A%E7%94%A8).txt"))() end)
end })

TabHome:Paragraph({ Title = "【 鸭鸭获取辅助 】" })
local evilNoteItemMap = { ["I CANT SEE"] = "老虎眼", ["HATCHES INTO SOMETHING GREAT"] = "蛋", ["KEEP ME WARM"] = "热可可", ["GRANT ME LIGHT"] = "灯泡", ["QUACK QUACK"] = "鸭子", ["GRANT MY WISH"] = "神灯", ["GREAT WITH COOKIES"] = "牛奶", ["CHEAT CODE"] = "游戏机", ["GIVE ME POWER"] = "电池", ["IM THIRSTY"] = "可乐", ["CLAIMS TO BE HAPPY"] = "快乐球" }
local morse = { [".-"]="A",["-..."]="B",["-.-."]="C",["-.."]="D",["."]="E",["..-."]="F",["--."]="G",["...."]="H",[".."]="I",[".---"]="J",["-.-"]="K",[".-.."]="L",["--"]="M",["-."]="N",["---"]="O",[".--."]="P",["--.-"]="Q",[".-."]="R",["..."]="S",["-"]="T",["..-"]="U",["...-"]="V",[".--"]="W",["-..-"]="X",["-.--"]="Y",["--.."]="Z",["-----"]="0",[".----"]="1",["..---"]="2",["...--"]="3",["....-"]="4",["....."]="5",["-...."]="6",["--..."]="7",["---.."]="8",["----."]="9" }

TabHome:Button({ Title = "恶魔鸭材料破解", Callback = function()
    local parts = Workspace:FindFirstChild("Stores") and Workspace.Stores:FindFirstChild("StoneRUs") and Workspace.Stores.StoneRUs:FindFirstChild("Parts")
    if not parts then Notify("失败", "未找到商店") return end
    local text = ""
    for i = 1, 3 do
        local raw = ""
        local note = parts:FindFirstChild("Note"..i)
        if note then
            local gui = note:FindFirstChildOfClass("SurfaceGui")
            if gui then for _, obj in pairs(gui:GetDescendants()) do if obj:IsA("TextLabel") then raw = obj.Text break end end end
        end
        if raw ~= "" then
            local words = {}
            for w in raw:gmatch("[^/]+") do
                local letters = {}
                for l in w:gmatch("%S+") do table.insert(letters, morse[l] or "?") end
                table.insert(words, table.concat(letters))
            end
            local decoded = table.concat(words, " ")
            text = text .. "Note"..i..": "..decoded.."  "..(evilNoteItemMap[decoded] or "未知").."\n"
        else text = text .. "Note"..i..": 内容为空\n" end
    end
    Notify("今日材料", text, 10)
end })

TabHome:Button({ Title = "自动敲击天使序列", Callback = function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local oldCF = hrp.CFrame
    hrp.CFrame = CFrame.new(184, 12, -2666)
    task.wait(0.2)
    local controller = Workspace.Stores.PlantomicsChoice.Parts.Controller.yes
    for _, name in ipairs({"Up","Up","Down","Down","Left","Right","Left","Right","B","A","Start"}) do
        local part = controller:FindFirstChild(name)
        local click = part and part:FindFirstChildOfClass("ClickDetector")
        if click then fireclickdetector(click, 1); task.wait(0.2) end
    end
    Notify("序列完成", "请自行寻找掉落的天堂鸭")
    hrp.CFrame = oldCF
end })

TabHome:Paragraph({ Title = "【 系统防踢 】" })
TabHome:Button({ Title = "开启反挂机防踢", Callback = function()
    for _, connection in ipairs(getconnections(game.Players.LocalPlayer.Idled)) do
        pcall(function() connection:Disable() end)
        pcall(function() connection:Disconnect() end)
    end
    Notify("成功", "已处理挂机检测连接")
end })

local targetTree = "Generic"
local playerPos = {nil, nil, nil}
local tree_list = {"普通木 (Generic)", "幻影木 (LoneCave)", "电木 (Electric)", "胡桃木 (Walnut)", "星木 (Star)", "樱桃木 (Cherry)", "桦木 (Birch)", "冰霜木 (Frost)", "大理石木 (Marble)", "火山木 (Volcano)", "金色沼泽木 (GoldSwampy)", "普通金木 (GenericGold)", "巨型橡木 (GreatOak)", "石头木 (Stone)", "辐射木 (Radioactive)", "洞穴木 (Cavern)", "岩浆木 (Magma)", "蓝木 (CaveCrawler)", "灵魂木 (Spirit)", "烈焰木 (Flame)", "星辰木 (Celestial)", "橡木 (Oak)", "绿色沼泽木 (GreenSwampy)", "沙子木 (Sand)", "松木 (Pine)", "玻璃木 (Glass)", "彩虹木 (Rainbow)", "冰木 (Ice)"}

TabTP:Dropdown({ Title = "选择树木种类", Values = tree_list, Value = "普通木 (Generic)", Callback = function(option) local m = string.match(option, "%((.+)%)"); if m then targetTree = m else targetTree = option end end })
TabTP:Button({ Title = "传送到树旁", Callback = function()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local targetWood = nil
    for _, v in next, Workspace:GetDescendants() do
        if v.Name == "TreeRegion" then
            for _, m in next, v:GetChildren() do
                if m:FindFirstChild("CutEvent") and not m:FindFirstChild("RootCut") then
                    if m:FindFirstChild("TreeClass") and m.TreeClass.Value == targetTree then 
                        if m:FindFirstChild("Owner") and (m.Owner.Value == nil or m.Owner.Value == player) then targetWood = m break end
                    end
                end
            end
        end
        if targetWood then break end
    end
    if targetWood and targetWood:FindFirstChild("WoodSection") then
        player.Character.HumanoidRootPart.CFrame = targetWood.WoodSection.CFrame + Vector3.new(0, 2.5, 3.5)
        Notify("成功", "传送成功")
    else Notify("错误", "没找到这种树") end
end })

TabTP:Paragraph({ Title = "【 自定义传送点 】" })
for i = 1, 3 do
    TabTP:Button({ Title = "保存当前位置为 传送点"..i, Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            playerPos[i] = player.Character.HumanoidRootPart.CFrame
            Notify("成功", "已保存传送点"..i)
        end
    end })
    TabTP:Button({ Title = "传送到 传送点"..i, Callback = function()
        if playerPos[i] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = playerPos[i]
            Notify("成功", "已回到传送点"..i)
        else Notify("错误", "未保存传送点"..i) end
    end })
end
local function CleanupAll()
    for i = 1, 3 do
        local bringPoint = Workspace:FindFirstChild("BRING"..i)
        if bringPoint then bringPoint:Destroy() end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, v in pairs(backpack:GetChildren()) do
            if v:IsA("Tool") and (string.find(v.Name, "空投工具") or v.Name == "点击传送" or v.Name == "多选框选工具") then v:Destroy() end
        end
    end
    local char = player.Character
    if char then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") and (string.find(v.Name, "空投工具") or v.Name == "点击传送" or v.Name == "多选框选工具") then v:Destroy() end
        end
    end
    Notify("清理完毕", "已清除残留工具与点位")
end

local function dragToPosition(model, targetCF, callback, waitFinish)
    if not model or not model.Parent then
        if callback then callback() end
        return
    end
    local primary = model.PrimaryPart or model:FindFirstChild("WoodSection") or model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
    if not primary then
        if callback then callback() end
        return
    end
    if not model.PrimaryPart then model.PrimaryPart = primary end
    local lockConn
    local function hold()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(primary.CFrame.Position + Vector3.new(0,3,0)) * CFrame.Angles(0, math.rad(hrp.Orientation.Y or 0), 0)
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end
    end
    hold()
    lockConn = RunService.Heartbeat:Connect(hold)
    local dragID = math.random(1, 1000000)
    local remote = RS.Interaction.ClientIsDragging
    pcall(function() RS.Interaction.ClientRequestOwnership:FireServer(primary) end)
    pcall(function() remote:FireServer("Begin", model, dragID) end)
    for i = 1, 60 do
        if not model.Parent or not model.PrimaryPart then
            pcall(function() remote:FireServer("End", model, dragID) end)
            if lockConn then lockConn:Disconnect() end
            if callback then callback() end
            return
        end
        pcall(function()
            remote:FireServer("Refresh", model, dragID)
            if i >= 28 then
                RS.Interaction.ClientRequestOwnership:FireServer(primary)
                model:SetPrimaryPartCFrame(targetCF)
            end
        end)
        task.wait(0.01)
    end
    task.wait(0.4)
    if lockConn then lockConn:Disconnect() end
    if callback then callback() end
end

local function loadWeaponConfig(weaponName)
    if weaponName == "OlReliable" or weaponName == "OIReliable" then
        local override = nil
        local wsTool = Workspace:FindFirstChild(player.Name)
        if wsTool then
            wsTool = wsTool:FindFirstChild("Tool")
            if wsTool then
                local toolName = wsTool:FindFirstChild("ToolName")
                if toolName and (tostring(toolName.Value) == "OlReliable" or tostring(toolName.Value) == "OIReliable") then
                    override = wsTool:FindFirstChild("AxeClassDamageOverride")
                end
            end
        end
        if not override then
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local toolName = tool:FindFirstChild("ToolName")
                        if toolName and (tostring(toolName.Value) == "OlReliable" or tostring(toolName.Value) == "OIReliable") then
                            override = tool:FindFirstChild("AxeClassDamageOverride")
                            if override then break end
                        end
                    end
                end
            end
        end
        if override then
            local config = {Damage = nil, SwingCooldown = nil, Range = nil, SpecialTrees = {}}
            for key, value in pairs(override:GetAttributes()) do
                if key == "Damage" then config.Damage = value
                elseif key == "SwingCooldown" then config.SwingCooldown = value
                elseif key == "Range" then config.Range = value
                else config.SpecialTrees[key] = {Damage = value} end
            end
            if config.Damage or config.SwingCooldown or next(config.SpecialTrees) then return config end
        end
    end
    return nil
end

local function selectBestWeapon(treeClass)
    local toolFolder = player:FindFirstChild("ToolFolder")
    if not toolFolder then return nil, nil, 0 end
    local bestWeapon, bestDamage, bestConfig = nil, -1, nil
    for _, child in pairs(toolFolder:GetChildren()) do
        local config = loadWeaponConfig(child.Name)
        if config then
            local damage = (config.SpecialTrees[treeClass] and config.SpecialTrees[treeClass].Damage) or config.Damage or 0
            if damage > bestDamage then
                bestWeapon, bestDamage, bestConfig = child.Name, damage, config
            end
        end
    end
    return bestWeapon, bestConfig, bestDamage
end

local function findUncutTree(treeClass)
    local playerPos = player.Character and player.Character.HumanoidRootPart.Position
    if not playerPos then return nil end
    local nearestDist, nearestWood, nearestTree = math.huge, nil, nil
    for _, region in pairs(Workspace:GetChildren()) do
        if region.Name == "TreeRegion" then
            for _, tree in pairs(region:GetChildren()) do
                if tree:IsA("Model") and tree:FindFirstChild("TreeClass") and tree.TreeClass.Value == treeClass then
                    local woodSections = {}
                    for _, child in pairs(tree:GetChildren()) do
                        if child.Name == "WoodSection" and child:IsA("BasePart") then table.insert(woodSections, child) end
                    end
                    if #woodSections >= 2 then
                        local dist = (woodSections[1].Position - playerPos).Magnitude
                        if dist < nearestDist then nearestDist, nearestWood, nearestTree = dist, woodSections[1], tree end
                    end
                end
            end
        end
    end
    return nearestWood, nearestTree
end

local function getTreeTopCFrame(treeModel)
    local topY = -math.huge
    local topCF = nil
    for _, child in pairs(treeModel:GetChildren()) do
        if child:IsA("BasePart") then
            local top = child.Position.Y + child.Size.Y / 2
            if top > topY then
                topY = top
                topCF = CFrame.new(child.Position.X, top + 2, child.Position.Z)
            end
        end
    end
    if not topCF then topCF = treeModel:GetPivot() + Vector3.new(0, 2, 0) end
    return topCF
end

local function bringTreeRemote(treeClass)
    local weaponName, weaponConfig, damage = selectBestWeapon(treeClass)
    if not weaponName then Notify("自动砍树", "自动选武器失败") return false end
    local cooldown = (weaponConfig.SpecialTrees[treeClass] and weaponConfig.SpecialTrees[treeClass].SwingCooldown) or weaponConfig.SwingCooldown or 0.3
    local woodSec, tree = findUncutTree(treeClass)
    if not woodSec then Notify("自动砍树", "附近没有可砍的树") return false end
    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    if not tool then
        local toolFolder = player:FindFirstChild("ToolFolder")
        if toolFolder then
            local weaponObj = toolFolder:FindFirstChild(weaponName)
            tool = weaponObj and (weaponObj:IsA("Tool") and weaponObj or weaponObj.Value) or nil
        end
    end
    if not tool then Notify("自动砍树", "未找到工具: "..weaponName) return false end
    local cutEvent = tree:FindFirstChild("CutEvent")
    if not cutEvent then Notify("自动砍树", "无法获取CutEvent") return false end
    local remote = RS:WaitForChild("Interaction"):WaitForChild("RemoteProxy")
    local playerOriginalCF = player.Character and player.Character.HumanoidRootPart.CFrame
    if not playerOriginalCF then return false end
    local lockConn
    local function hold()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = getTreeTopCFrame(tree)
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end
    end
    hold()
    lockConn = RunService.Heartbeat:Connect(hold)
    local fallenLog, existingLogs = nil, {}
    for _, log in pairs(Workspace.LogModels:GetChildren()) do existingLogs[log] = true end
    local treeCenter = woodSec.Position
    local stopCutting, timeoutReached = false, false
    if not damage or damage <= 0 then damage = 10000 end
    local sendTask = task.spawn(function()
        while not stopCutting do
            pcall(remote.FireServer, remote, cutEvent, {height=0.3, faceVector=Vector3.new(-1,0,0), cooldown=cooldown, sectionId=1, hitPoints=damage, tool=tool, cuttingClass="Axe"})
            task.wait(0.05)
        end
    end)
    local timeoutTask = task.spawn(function()
        task.wait(60)
        if not stopCutting then timeoutReached = true stopCutting = true end
    end)
    while not fallenLog and not stopCutting do
        for _, log in pairs(Workspace.LogModels:GetChildren()) do
            if not existingLogs[log] and log:FindFirstChild("Owner") and log.Owner.Value == player and log:FindFirstChild("TreeClass") and log.TreeClass.Value == treeClass then
                if (log:GetPivot().Position - treeCenter).Magnitude < 100 then fallenLog = log break end
            end
        end
        task.wait(0.01)
    end
    stopCutting = true task.cancel(sendTask) task.cancel(timeoutTask)
    if lockConn then lockConn:Disconnect() end
    if timeoutReached or not fallenLog then
        Notify("自动砍树", "砍树超时或木头未掉落")
        player.Character.HumanoidRootPart.CFrame = playerOriginalCF
        return false
    end
    local primary = fallenLog.PrimaryPart or fallenLog:FindFirstChild("WoodSection") or fallenLog:FindFirstChild("Main") or fallenLog:FindFirstChildWhichIsA("BasePart")
    if not primary then
        Notify("自动砍树", "无法定位木头")
        player.Character.HumanoidRootPart.CFrame = playerOriginalCF
        return false
    end
    if not fallenLog.PrimaryPart then fallenLog.PrimaryPart = primary end
    dragToPosition(fallenLog, playerOriginalCF, function()
        player.Character.HumanoidRootPart.CFrame = playerOriginalCF
    end)
    return true
end

local treeNames = {"普通树","枯木","金树","沼泽黄金","樱花树","蓝木","洞窟紫木","冰木","火山木","橡木","巧克力木","白桦木","大巧克力树","椰子树","雪地松","幻影木","幽灵木","南瓜木","地狱木","岩浆树","虚空木","星空木","天堂木","彩虹木","雷电木","玻璃木","钻石木","金子木","石头木","大理石木","曲奇木","糖果树","狗木","骨头木","水晶木","火焰木","生命古橡","沙子木"}
local selectedTreeName = "普通树"
local batchCount = 1
local isTreeRunning = false

TabTree:Dropdown({ Title = "选择树木种类", Values = treeNames, Value = selectedTreeName, Callback = function(b) selectedTreeName = b end })
TabTree:Input({ Title = "砍伐数量", Value = "1", Callback = function(v) local n = tonumber(v); if n then batchCount = n end end })
TabTree:Button({ Title = "开始带来树", Callback = function()
    if isTreeRunning then return end
    isTreeRunning = true
    task.spawn(function()
        local successCount, failCount = 0, 0
        for i = 1, batchCount do
            if not isTreeRunning then break end
            if bringTreeRemote(selectedTreeName) then successCount = successCount + 1
            else failCount = failCount + 1 break end
            task.wait(0.01)
        end
        isTreeRunning = false
        Notify("自动砍树", string.format("结束 成功 %d 次，失败 %d 次", successCount, failCount))
    end)
end })
TabTree:Button({ Title = "停止任务", Callback = function() isTreeRunning = false end })

local selectedBringTarget = "BRING1"
local selectedObjects = {}
TabExtra:Paragraph({ Title = "【 物品传送 】" })
TabExtra:Dropdown({ Title = "选择物品拉回的目标点", Values = {"拉回点位1", "拉回点位2", "拉回点位3"}, Value = "拉回点位1", Callback = function(option)
    if option == "拉回点位1" then selectedBringTarget = "BRING1"
    elseif option == "拉回点位2" then selectedBringTarget = "BRING2"
    else selectedBringTarget = "BRING3" end
end })

for i = 1, 3 do
    TabExtra:Button({ Title = "设置 物品点位"..i, Callback = function()
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
        Notify("成功", "物品点位"..i.."已设置")
    end })
end

TabExtra:Button({ Title = "获取点击传送工具", Callback = function()
    if player.Backpack:FindFirstChild("点击传送") or player.Character:FindFirstChild("点击传送") then player.Backpack["点击传送"]:Destroy() end
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
                for i = 1, 40 do DragModel(targetModel, targetCFrame); task.wait(0.02) end
                Notify("传送成功", "物品已拉回")
            end
        end
    end)
end })

TabExtra:Button({ Title = "获取多选框选工具", Callback = function()
    if player.Backpack:FindFirstChild("多选框选工具") or player.Character:FindFirstChild("多选框选工具") then player.Backpack["多选框选工具"]:Destroy() end
    local tool = Instance.new("Tool", player.Backpack)
    tool.Name = "多选框选工具"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local targetPart = Mouse.Target
        if not targetPart then return end
        local targetModel = targetPart.Parent
        if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
            local isSelected = false
            for i, obj in pairs(selectedObjects) do
                if obj == targetModel then
                    table.remove(selectedObjects, i)
                    isSelected = true
                    if targetPart:FindFirstChild("BlueSelectBox") then targetPart.BlueSelectBox:Destroy() end
                    if targetModel:FindFirstChild("BlueSelectBox") then targetModel.BlueSelectBox:Destroy() end
                    Notify("取消选中", targetModel.Name)
                    break
                end
            end
            if not isSelected then
                table.insert(selectedObjects, targetModel)
                local box = Instance.new("SelectionBox")
                box.Name = "BlueSelectBox"
                box.Adornee = targetModel
                box.Color3 = Color3.fromRGB(0, 150, 255)
                box.LineThickness = 0.05
                box.Parent = targetModel
                Notify("已选中", targetModel.Name)
            end
        end
    end)
end })

TabExtra:Button({ Title = "一键传送所有选中物品", Callback = function()
    if not Workspace:FindFirstChild(selectedBringTarget) then return end
    local targetCFrame = Workspace[selectedBringTarget].CFrame
    for i = #selectedObjects, 1, -1 do
        local obj = selectedObjects[i]
        if obj and obj.Parent then
            for j = 1, 40 do DragModel(obj, targetCFrame); task.wait(0.02) end
            if obj:FindFirstChild("BlueSelectBox") then obj.BlueSelectBox:Destroy() end
            table.remove(selectedObjects, i)
        end
    end
    Notify("传送完毕", "所有选中物品已拉回")
end })

TabExtra:Button({ Title = "清除所有选中(蓝框)", Callback = function()
    for i = #selectedObjects, 1, -1 do
        local obj = selectedObjects[i]
        if obj and obj:FindFirstChild("BlueSelectBox") then obj.BlueSelectBox:Destroy() end
        table.remove(selectedObjects, i)
    end
end })

local function New_SellAllWood()
    local lm = Workspace:FindFirstChild("LogModels")
    if not lm then return end
    local list = {}
    for _, m in pairs(lm:GetChildren()) do
        if m:FindFirstChild("Owner") and m.Owner.Value == player and m:FindFirstChild("TreeClass") then
            table.insert(list, m)
        end
    end
    if #list == 0 then return Notify("提示","没有木头") end
    local SELL_CF = CFrame.new(314.508514, -0.303692758, 86.5952911)
    local orig = player.Character.HumanoidRootPart.CFrame
    for _, m in ipairs(list) do
        if m.Parent then
            local p = m.PrimaryPart or m:FindFirstChild("WoodSection")
            if p then
                player.Character.HumanoidRootPart.CFrame = p.CFrame + Vector3.new(0,3,0)
                task.wait(0.1)
                for i=1, 40 do DragModel(m, SELL_CF) task.wait(0.01) end
                player.Character.HumanoidRootPart.CFrame = SELL_CF + Vector3.new(0,3,0)
                task.wait(0.5)
            end
        end
    end
    player.Character.HumanoidRootPart.CFrame = orig
    Notify("完成","木头已卖完")
end

TabExtra:Paragraph({ Title = "【 卖木头与拉回鸭子 】" })
TabExtra:Button({ Title = "一键卖掉所有原木", Callback = function() task.spawn(New_SellAllWood) end })
local selectedDuck = "DuckAngel"
TabExtra:Dropdown({ Title = "选择鸭子", Values = {"天堂鸭", "恶魔鸭", "月亮鸭", "普通鸭", "礼物鸭"}, Value = "天堂鸭", Callback = function(opt)
    if opt == "天堂鸭" then selectedDuck = "DuckAngel"
    elseif opt == "恶魔鸭" then selectedDuck = "DuckEvil"
    elseif opt == "月亮鸭" then selectedDuck = "LunarDuck"
    elseif opt == "普通鸭" then selectedDuck = "Duck"
    else selectedDuck = "2018CGift_Duck" end
end })

TabExtra:Button({ Title = "拉回全图【自己的】鸭子", Callback = function()
    local start = player.Character.HumanoidRootPart.CFrame
    local count = 0
    for _, m in pairs(Workspace.PlayerModels:GetChildren()) do
        if m.Name == selectedDuck and m:FindFirstChild("Owner") and m.Owner.Value == player then
            local p = m.PrimaryPart or m:FindFirstChild("Main") or m:FindFirstChildWhichIsA("BasePart")
            if p then
                player.Character.HumanoidRootPart.CFrame = p.CFrame + Vector3.new(0,2,0)
                task.wait(0.1)
                for i=1, 30 do DragModel(m, start) task.wait(0.01) end
                count = count + 1
            end
        end
    end
    player.Character.HumanoidRootPart.CFrame = start
    Notify("完成","拉回 "..count.." 只")
end })

local selectedPlayerName = player.Name
local playerDropdownOptions = {}
for _, p in ipairs(game.Players:GetPlayers()) do table.insert(playerDropdownOptions, p.Name) end
local currentPlayerDropdown = TabExtra:Dropdown({ Title = "选择目标玩家", Values = playerDropdownOptions, Value = selectedPlayerName, Callback = function(option) selectedPlayerName = option end })
TabExtra:Button({ Title = "刷新玩家列表", Callback = function()
    local list = {}
    for _, p in ipairs(game.Players:GetPlayers()) do table.insert(list, p.Name) end
    if currentPlayerDropdown and currentPlayerDropdown.Set then currentPlayerDropdown:Set(list[1]) end
    Notify("刷新成功", "玩家列表已更新")
end })
TabExtra:Button({ Title = "传送到目标玩家身边", Callback = function()
    local target = game.Players:FindFirstChild(selectedPlayerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
end })
local isLoopTeleport = false
TabExtra:Toggle({ Title = "循环锁定传送", Value = false, Callback = function(state)
    isLoopTeleport = state
    if state then
        task.spawn(function()
            while isLoopTeleport do
                local target = game.Players:FindFirstChild(selectedPlayerName)
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    end
                end
                task.wait()
            end
        end)
    end
end })

local currentSortTool = nil
TabExtra:Button({ Title = "获取建筑整理工具", Callback = function()
    if currentSortTool and currentSortTool.Parent then currentSortTool:Destroy() end
    currentSortTool = Instance.new("Tool")
    currentSortTool.RequiresHandle = false
    currentSortTool.Name = "点击整理物品"
    currentSortTool.Activated:Connect(function()
        local model = Mouse.Target and Mouse.Target:FindFirstAncestorOfClass("Model")
        if not model or not model:FindFirstChild("Owner") or model.Owner.Value ~= player then return end
        local itemName, items = model.Name, {}
        for _, v in pairs(Workspace.PlayerModels:GetChildren()) do if v:IsA("Model") and v.Name == itemName and v:FindFirstChild("Owner") and v.Owner.Value == player then table.insert(items, v) end end
        for _, log in pairs(Workspace.LogModels:GetChildren()) do if log.Name == itemName and log:FindFirstChild("Owner") and log.Owner.Value == player then table.insert(items, log) end end
        if #items == 0 then return end
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local startPos = hrp.Position - Vector3.new(0, 3.5, 0) + Vector3.new(0, 1, 0)
        local layerHeight, colInRow, rowInLayer, layerCount = 3, 0, 0, 0
        for i, item in ipairs(items) do
            local x, z, y = colInRow * 3, rowInLayer * 3, layerCount * layerHeight
            local targetPos = CFrame.new(startPos.X + x, startPos.Y + y, startPos.Z + z)
            colInRow = colInRow + 1
            if colInRow >= 3 then colInRow = 0; rowInLayer = rowInLayer + 1; if rowInLayer >= 3 then rowInLayer = 0; layerCount = layerCount + 1 end end
            local primary = item.PrimaryPart or item:FindFirstChild("Main") or item:FindFirstChild("WoodSection") or item:FindFirstChildWhichIsA("BasePart")
            if primary then
                if not item.PrimaryPart then item.PrimaryPart = primary end
                for j = 1, 40 do DragModel(item, targetPos) task.wait(0.02) end
            end
        end
    end)
    currentSortTool.Parent = player.Backpack
end })

TabExtra:Paragraph({ Title = "【 系统清理 】" })
TabExtra:Button({ Title = "彻底关闭并清理缓存", Callback = function() CleanupAll() end })
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local duckDragIDCounter = 0
local duckLockConn = nil

local function duckGetNextDragID()
    duckDragIDCounter = duckDragIDCounter + 1
    return duckDragIDCounter
end

local function duckUprightCFrame(hrp, cf)
    local pos = cf.Position
    local yRot = hrp and hrp.Orientation.Y or 0
    return CFrame.new(pos) * CFrame.Angles(0, math.rad(yRot), 0)
end

local function duckSafeTeleport(cf)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = duckUprightCFrame(hrp, cf)
        task.wait(0.05)
        if hrp.Position.Y < -100 then hrp.CFrame = duckUprightCFrame(hrp, cf) + Vector3.new(0, 10, 0) end
    end
end

local function duckUnlockPlayer()
    if duckLockConn then duckLockConn:Disconnect() duckLockConn = nil end
end

local function duckLockPlayerAt(cf)
    duckUnlockPlayer()
    local function hold()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = duckUprightCFrame(hrp, cf)
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
    hold()
    duckLockConn = RunService.Heartbeat:Connect(hold)
end

local function duckDragToPosition(model, targetCF, callback, waitFinish)
    if not model or not model.Parent then
        if callback then callback() end
        return
    end
    local primary = model.PrimaryPart or model:FindFirstChild("WoodSection") or model:FindFirstChild("Main") or model:FindFirstChildWhichIsA("BasePart")
    if not primary then
        if callback then callback() end
        return
    end
    if not model.PrimaryPart then model.PrimaryPart = primary end
    duckLockPlayerAt(primary.CFrame + Vector3.new(0, 3, 0))
    local dragID = duckGetNextDragID()
    local remote = RS.Interaction.ClientIsDragging
    pcall(function() RS.Interaction.ClientRequestOwnership:FireServer(primary) end)
    pcall(function() remote:FireServer("Begin", model, dragID) end)
    local lastSet = 28 + 2 - 1
    for i = 1, lastSet do
        if not model.Parent or not model.PrimaryPart then
            pcall(function() remote:FireServer("End", model, dragID) end)
            if callback then callback() end
            return
        end
        local shouldSet = (i >= 28)
        pcall(function()
            remote:FireServer("Refresh", model, dragID)
            if shouldSet then
                RS.Interaction.ClientRequestOwnership:FireServer(primary)
                model:SetPrimaryPartCFrame(targetCF)
            end
        end)
        task.wait(0.01)
    end
    task.wait(0.01)
    local dragEnded = false
    task.spawn(function()
        for i = lastSet + 1, 60 do
            if not model.Parent or not model.PrimaryPart then break end
            pcall(function() remote:FireServer("Refresh", model, dragID) end)
            task.wait(0.01)
        end
        pcall(function() remote:FireServer("End", model, dragID) end)
        dragEnded = true
    end)
    if waitFinish then
        local w = 0
        while w < 1.5 and not dragEnded do
            task.wait(0.05)
            w = w + 0.05
        end
    end
    task.wait(0.4)
    duckUnlockPlayer()
    if callback then callback() end
end

local function duckGetAllCashierIds()
    local cashierIds = {}
    local conn = RS.NPCDialog.PromptChat.OnClientEvent:Connect(function(...)
        local pack = { ... }
        for _, v in ipairs(pack) do
            if type(v) == "table" and v.Name ~= nil and v.ID ~= nil then
                if not cashierIds[v.Name] then cashierIds[v.Name] = v.ID end
            end
        end
    end)
    pcall(function() RS.NPCDialog.SetChattingValue:InvokeServer(1) end)
    local startTime = tick()
    while not cashierIds["Manachron"] and tick() - startTime < 15 do
        task.wait(0.2)
    end
    conn:Disconnect()
    pcall(function() RS.NPCDialog.SetChattingValue:InvokeServer(0) end)
    return cashierIds
end

local duckNpcIdCache = nil
local function duckGetNpcId()
    if duckNpcIdCache then return duckNpcIdCache end
    local ids = duckGetAllCashierIds()
    duckNpcIdCache = ids["Manachron"]
    return duckNpcIdCache
end

local function duckBuyCrate()
    local fineFinds = Workspace.Stores:FindFirstChild("FineFinds")
    if not fineFinds then return nil, "找不到商店" end
    local npcChar = fineFinds:FindFirstChild("Manachron")
    if not npcChar then return nil, "找不到NPC" end
    local npcId = duckGetNpcId()
    if not npcId then return nil, "无法获取NPC ID" end
    local counter = fineFinds:FindFirstChild("Counter")
    if not counter then return nil, "找不到Counter" end
    local shopItems = fineFinds:FindFirstChild("ShopItems")
    if not shopItems then return nil, "无ShopItems" end
    local crateItem = shopItems:FindFirstChild("Crate")
    if not crateItem then
        for _ = 1, 10 do
            crateItem = shopItems:FindFirstChild("Crate")
            if crateItem then break end
            task.wait(0.15)
        end
        if not crateItem then return nil, "Crate不在货架" end
    end
    local primary = crateItem.PrimaryPart or crateItem:FindFirstChild("Main") or crateItem:FindFirstChildWhichIsA("BasePart")
    if not primary then return nil, "无法定位商品" end
    if not crateItem.PrimaryPart then crateItem.PrimaryPart = primary end
    duckLockPlayerAt(primary.CFrame + Vector3.new(0, 3, 0))
    task.wait(0.2)
    local counterSurface = counter.CFrame + Vector3.new(0, 0.6, 0)
    duckDragToPosition(crateItem, counterSurface, nil, true)
    duckLockPlayerAt(counter.CFrame + Vector3.new(0, 3, 0))
    task.wait(0.1)
    local purchased = {}
    local conn = Workspace.PlayerModels.ChildAdded:Connect(function(m)
        if m:IsA("Model") and m:FindFirstChild("Owner") and m.Owner.Value == player then
            table.insert(purchased, m)
        end
    end)
    local args = { { ID = npcId, Character = npcChar, Name = "Manachron" }, "ConfirmPurchase" }
    local ok, err = pcall(function() RS.NPCDialog.PlayerChatted:InvokeServer(table.unpack(args)) end)
    task.wait(0.5)
    conn:Disconnect()
    duckUnlockPlayer()
    if not ok then return nil, "购买请求失败" end
    return purchased[1], "成功"
end

local autoDuckTarget = 1
local isAutoBuyingDuck = false
local duckStopFlag = false

local function autoGetGiftDuckDirect(targetCount)
    targetCount = targetCount or 1
    if isAutoBuyingDuck then return end
    isAutoBuyingDuck = true
    duckStopFlag = false
    local successCount = 0
    local startPos = player.Character and player.Character.HumanoidRootPart.CFrame
    if not startPos then isAutoBuyingDuck = false return end
    
    local function getPlayerPos()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        return hrp and hrp.Position or nil
    end
    
    local function getMyDucks()
        local ducks = {}
        for _, m in pairs(Workspace.PlayerModels:GetChildren()) do
            if m:IsA("Model") and m.Name == "2018CGift_Duck" then
                local owner = m:FindFirstChild("Owner")
                if owner and owner.Value == player then table.insert(ducks, m) end
            end
        end
        return ducks
    end
    
    local initialDucks = {}
    for _, d in ipairs(getMyDucks()) do initialDucks[d] = true end
    local initialCount = #getMyDucks()
    
    local function syncDragToPosition(model, targetCF, timeout)
        timeout = timeout or 5
        local done, success = false, false
        duckDragToPosition(model, targetCF, function() done = true; success = true end)
        local startTime = tick()
        while not done and tick() - startTime < timeout do task.wait(0.1) end
        return success
    end
    
    local attempt = 0
    while isAutoBuyingDuck and not duckStopFlag and successCount < targetCount do
        attempt = attempt + 1
        local crate, msg = duckBuyCrate()
        if not crate then
            task.wait(0.15)
            if duckStopFlag then break end
            local currentDucks = getMyDucks()
            if #currentDucks > initialCount then
                for _, d in ipairs(currentDucks) do
                    if not initialDucks[d] and d.Parent then
                        if not d.PrimaryPart then
                            local prim = d:FindFirstChild("Main") or d:FindFirstChildWhichIsA("BasePart")
                            if prim then d.PrimaryPart = prim end
                        end
                        if d.PrimaryPart then
                            duckSafeTeleport(d.PrimaryPart.CFrame + Vector3.new(0, 2, 0))
                            task.wait(0.2)
                            if syncDragToPosition(d, startPos) then
                                duckSafeTeleport(startPos)
                                successCount = successCount + 1
                                initialDucks[d] = true
                                initialCount = initialCount + 1
                                break
                            end
                        end
                    end
                end
            end
            if duckStopFlag then break end
            continue
        end
        
        local playerPos = getPlayerPos()
        if not playerPos then continue end
        local candidates = {}
        for _, m in pairs(Workspace.PlayerModels:GetChildren()) do
            if m:IsA("Model") and m:FindFirstChild("Owner") and m.Owner.Value == player then
                local name = m.Name
                if name:find("Crate Purchased by") or name:find("crate purchased by") then
                    local prim = m.PrimaryPart or m:FindFirstChild("Main") or m:FindFirstChildWhichIsA("BasePart")
                    if prim then
                        local d = (prim.Position - playerPos).Magnitude
                        if d <= 50 then table.insert(candidates, { model = m, dist = d }) end
                    end
                end
            end
        end
        
        if #candidates > 0 then
            table.sort(candidates, function(a, b) return a.dist < b.dist end)
            for _, cand in ipairs(candidates) do
                if duckStopFlag then break end
                pcall(function() RS.Interaction.ClientInteracted:FireServer(cand.model, "Open box") end)
                task.wait(0.1)
            end
            task.wait(0.2)
            local buttonCrates = {}
            for _, m in pairs(Workspace.PlayerModels:GetChildren()) do
                if m:IsA("Model") and m.Name == "Crate" then
                    local owner = m:FindFirstChild("Owner")
                    if owner and owner.Value == player then
                        local prim = m.PrimaryPart or m:FindFirstChild("Main") or m:FindFirstChildWhichIsA("BasePart")
                        if prim and (prim.Position - playerPos).Magnitude <= 50 then table.insert(buttonCrates, m) end
                    end
                end
            end
            for _, crateModel in ipairs(buttonCrates) do
                if duckStopFlag then break end
                local btn = crateModel:FindFirstChild("ButtonRemote_Main")
                if btn then pcall(function() RS.Interaction.RemoteProxy:FireServer(btn) end) end
                task.wait(0.04)
            end
        end
        task.wait(0.5)
        
        local currentDucks = getMyDucks()
        if #currentDucks > initialCount then
            for _, d in ipairs(currentDucks) do
                if not initialDucks[d] and d.Parent then
                    if not d.PrimaryPart then
                        local prim = d:FindFirstChild("Main") or d:FindFirstChildWhichIsA("BasePart")
                        if prim then d.PrimaryPart = prim end
                    end
                    if d.PrimaryPart then
                        duckSafeTeleport(d.PrimaryPart.CFrame + Vector3.new(0, 2, 0))
                        task.wait(0.2)
                        if syncDragToPosition(d, startPos) then
                            duckSafeTeleport(startPos)
                            successCount = successCount + 1
                            initialDucks[d] = true
                            initialCount = initialCount + 1
                        end
                    end
                end
            end
        end
        task.wait(0.08)
    end
    duckSafeTeleport(startPos)
    isAutoBuyingDuck = false
    duckStopFlag = false
end

TabBuy:Paragraph({ Title = "【 购买普通鸭 】" })
TabBuy:Input({ Title = "目标获取数量", Value = "1", Callback = function(v)
    local n = tonumber(v)
    if n and n > 0 then autoDuckTarget = math.floor(n) end
end })
TabBuy:Button({ Title = "开始自动购买普通鸭", Callback = function()
    task.spawn(function() autoGetGiftDuckDirect(autoDuckTarget) end)
end })
TabBuy:Button({ Title = "停止购买", Callback = function()
    if isAutoBuyingDuck then duckStopFlag = true end
end })
TabBuy:Button({ Title = "重置 NPC ID 缓存", Callback = function() duckNpcIdCache = nil end })
local storeInfoMapping = {
    AutumnCatalog = {name = "William", path = "William"}, BlackMarket = {name = "sneakypotato7", path = "sneakypotato7"},
    CarStore = {name = "Jenny", path = "Jenny"}, MusicStore = {name = "NazuReborn", path = "NazuReborn"},
    FineArt = {name = "Timothy", path = "Timothy"}, FineFinds = {name = "Manachron", path = "Manachron"},
    FurnitureStore = {name = "Corey", path = "Corey"}, HLStand = {name = "???", path = "???"},
    Igloo = {name = "Cold Guy", path = "Cold Guy"}, LogicStore = {name = "Lincoln", path = "Lincoln"},
    MountainSide = {name = "Mr.Bacon", path = "Mr.Bacon"}, PlanterStore = {name = "OGxOutcast", path = "OGxOutcast"},
    PlantomicsChoice = {name = "Null", path = "Null"}, SallysSeasonal = {name = "Sally", path = "Sally"},
    SaplingCart = {name = "Billy", path = "Billy"}, SeaSide = {name = "Guy", path = "Guy"},
    StoneRUs = {name = "Bloxyway", path = "Bloxyway"}, TravelingTrader = {name = "Trader", path = "Trader"},
    VIPSHOP = {name = "Todd", path = "Todd"}, WoodRUs = {name = "Thom", path = "Thom"},
}

local npcMapping = {}
for storeName, info in pairs(storeInfoMapping) do
    npcMapping[storeName] = { name = info.name, id = nil, path = info.path }
end

local function GetAllCashierIds()
    local cashierIds = {}
    local receivedCount = 0
    local totalExpected = 0
    for _ in pairs(storeInfoMapping) do totalExpected = totalExpected + 1 end
    local connection = REPLICATED_STORAGE.NPCDialog.PromptChat.OnClientEvent:Connect(function(...)
        local pack = { ... }
        for _, v in ipairs(pack) do
            if type(v) == "table" then
                local nm = v.Name
                local id = v.ID
                if nm ~= nil and id ~= nil then
                    if not cashierIds[nm] then
                        cashierIds[nm] = id
                        receivedCount = receivedCount + 1
                    end
                end
            end
        end
    end)
    pcall(function() REPLICATED_STORAGE.NPCDialog.SetChattingValue:InvokeServer(1) end)
    local timeout = 20
    local startTime = tick()
    while receivedCount < totalExpected and tick() - startTime < timeout do task.wait(0.2) end
    connection:Disconnect()
    pcall(function() REPLICATED_STORAGE.NPCDialog.SetChattingValue:InvokeServer(0) end)
    return cashierIds
end

local translateMap = {
    ["Plank"] = "木板", ["Crate"] = "板条箱", ["Log"] = "原木", ["Blueprint"] = "蓝图", ["Axe"] = "斧头", 
    ["Sawmill"] = "锯木机", ["Workbench"] = "工作台", ["Lantern"] = "灯笼", ["Furniture"] = "家具", ["Door"] = "门", 
    ["Window"] = "窗户", ["Car"] = "汽车", ["Wheel"] = "车轮", ["Toy"] = "玩具", ["Gift"] = "礼物", 
    ["Egg"] = "蛋", ["LightBulb"] = "灯泡", ["Duck"] = "鸭子", ["MagicLamp"] = "神灯", ["Milk"] = "牛奶", 
    ["NESController"] = "游戏机", ["Battery"] = "电池", ["BloxyCola"] = "可乐", ["HappyBall"] = "快乐球", ["Cocoa"] = "热可可",
    ["Eye3"] = "老虎眼", ["Sapling"] = "树苗", ["Bucket"] = "水桶", ["Map"] = "地图", ["Wrench"] = "扳手", ["Sign"] = "告示牌",
    ["Chair"] = "椅子", ["Table"] = "桌子", ["Lamp"] = "台灯", ["Bed"] = "床", ["Shelf"] = "架子", ["Rug"] = "地毯", ["Paint"] = "油漆"
}

local function getCNName(enName)
    if translateMap[enName] then return translateMap[enName] end
    for k, v in pairs(translateMap) do
        if string.find(enName, k) then return v .. " (" .. enName .. ")" end
    end
    return enName
end

local allStores = {}
local stopPurchaseFlag = false

local function waitForItemRefresh(shopItems, itemName, timeout)
    timeout = timeout or 10
    local startTime = tick()
    while tick() - startTime < timeout do
        if stopPurchaseFlag then return false end
        if shopItems:FindFirstChild(itemName) then return true end
        task.wait(0.05)
    end
    return false
end

local function purchaseCycle(storeInfo, selectedItemName, buyAmount, doubleConfirm)
    local store = storeInfo.object
    local shopItems = storeInfo.shopItems
    local npcInfo = storeInfo.npc
    if not npcInfo or not npcInfo.id then return false end
    local npcChar = store:FindFirstChild(npcInfo.path)
    if not npcChar then return false end
    local counter = store:FindFirstChild("Counter")
    if not counter or not counter:IsA("BasePart") then return false end
    local NPCDialog = REPLICATED_STORAGE:WaitForChild("NPCDialog")
    
    local function sendPurchaseAndCollect()
        local purchasedItems = {}
        local conn = workspace.PlayerModels.ChildAdded:Connect(function(model)
            if model:IsA("Model") and model:FindFirstChild("Owner") and model.Owner.Value == player then
                table.insert(purchasedItems, model)
            end
        end)
        local args = { { ID = npcInfo.id, Character = npcChar, Name = npcInfo.name }, "ConfirmPurchase" }
        local ok, err = pcall(function() NPCDialog.PlayerChatted:InvokeServer(table.unpack(args)) end)
        if not ok then conn:Disconnect() return nil end
        task.wait(0.04)
        conn:Disconnect()
        return purchasedItems
    end
    
    local originalPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not originalPos then return false end
    originalPos = originalPos.CFrame
    local successCycles = 0
    
    for i = 1, buyAmount do
        if stopPurchaseFlag then break end
        local itemModel = shopItems:FindFirstChild(selectedItemName)
        if not itemModel then
            if not waitForItemRefresh(shopItems, selectedItemName, 15) then break end
            itemModel = shopItems:FindFirstChild(selectedItemName)
            if not itemModel then break end
        end
        
        local itemPrimary = itemModel.PrimaryPart or itemModel:FindFirstChild("WoodSection") or itemModel:FindFirstChild("Main") or itemModel:FindFirstChildWhichIsA("BasePart")
        if not itemPrimary then break end
        if not itemModel.PrimaryPart then itemModel.PrimaryPart = itemPrimary end
        if stopPurchaseFlag then break end
        
        duckLockPlayerAt(itemPrimary.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.2)
        if stopPurchaseFlag then break end
        
        duckDragToPosition(itemModel, counter.CFrame + Vector3.new(0, 0.6, 0), nil, true)
        if stopPurchaseFlag then break end
        
        duckLockPlayerAt(counter.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.1)
        
        local allItems = {}
        for k = 1, 2 do
            if stopPurchaseFlag then break end
            local items = sendPurchaseAndCollect()
            if items then
                for _, it in ipairs(items) do table.insert(allItems, it) end
            else
                break
            end
            task.wait(0.01)
        end
        
        for _, item in ipairs(allItems) do
            if stopPurchaseFlag then break end
            if item and item.Parent then
                if not item.PrimaryPart then
                    local part = item:FindFirstChild("Main") or item:FindFirstChild("WoodSection") or item:FindFirstChildWhichIsA("BasePart")
                    if part then item.PrimaryPart = part end
                end
                duckDragToPosition(item, originalPos, nil, false)
                task.wait(0.05)
            end
        end
        successCycles = successCycles + 1
        
        if i < buyAmount and not stopPurchaseFlag then
            local refreshed = waitForItemRefresh(shopItems, selectedItemName, 30)
            if not refreshed then break end
        end
    end
    
    duckUnlockPlayer()
    duckSafeTeleport(originalPos)
    if stopPurchaseFlag then stopPurchaseFlag = false end
    return successCycles == buyAmount
end

TabBuy:Paragraph({ Title = "【 全商店购买（中文） 】" })

local currentStoreDropdown
local selectedEntry = nil

local function refreshItemList()
    allStores = {}
    for _, store in pairs(Workspace:WaitForChild("Stores"):GetChildren()) do
        local shopItems = store:FindFirstChild("ShopItems")
        if shopItems and #shopItems:GetChildren() > 0 then
            local storeName = store.Name
            local npcInfo = npcMapping[storeName]
            if not npcInfo then
                npcInfo = { name = storeName, id = nil, path = storeName }
            end
            table.insert(allStores, { name = storeName, object = store, shopItems = shopItems, npc = npcInfo })
        end
    end
    table.sort(allStores, function(a, b) return a.name < b.name end)

    local allItemsList = {}
    for _, store in ipairs(allStores) do
        if store.shopItems then
            for _, item in pairs(store.shopItems:GetChildren()) do
                table.insert(allItemsList, { 
                    display = getCNName(store.name) .. " - " .. getCNName(item.Name), 
                    store = store, 
                    item = item.Name 
                })
            end
        end
    end
    table.sort(allItemsList, function(a, b) return a.display < b.display end)

    local displayOptions = {}
    local itemMap = {}
    for _, entry in ipairs(allItemsList) do
        table.insert(displayOptions, entry.display)
        itemMap[entry.display] = entry
    end

    if #displayOptions > 0 then
        selectedEntry = itemMap[displayOptions[1]]
    end
    
    return displayOptions, itemMap
end

local displayOptions, itemMap = refreshItemList()

if #displayOptions > 0 then
    local selectedDisplay = displayOptions[1]
    local dd = TabBuy:Dropdown({ Title = "选择商品", Values = displayOptions, Value = selectedDisplay, Callback = function(sel)
        selectedDisplay = sel
        selectedEntry = itemMap[sel]
    end })
    
    local buyAmount = 1
    TabBuy:Input({ Title = "循环次数", Value = "1", Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then buyAmount = num else buyAmount = 1 end
    end })
    
    TabBuy:Button({ Title = "刷新商品列表 (跑图加载后点我)", Callback = function()
        local newOpts, newMap = refreshItemList()
        if dd and dd.Refresh then
            dd:Refresh(newOpts)
        else
            Notify("刷新成功", "已更新商品列表，请重新选择", 5)
        end
    end })
    
    TabBuy:Button({ Title = "开始购买选中商品", Callback = function()
        if not selectedEntry then return end
        stopPurchaseFlag = false
        task.spawn(function() purchaseCycle(selectedEntry.store, selectedEntry.item, buyAmount, false) end)
    end })
    
    TabBuy:Button({ Title = "停止全商店购买", Callback = function()
        stopPurchaseFlag = true
        Notify("系统", "已发送停止信号", 3)
    end })
end
local evilStopFlag = false
local evilAutoRunning = false
local evilCombineCount = 1
local allStoresEvil = {}

for _, store in pairs(Workspace:WaitForChild("Stores"):GetChildren()) do
    local shopItems = store:FindFirstChild("ShopItems")
    if shopItems and #shopItems:GetChildren() > 0 then
        local storeName = store.Name
        local npcInfo = npcMapping[storeName]
        if npcInfo then table.insert(allStoresEvil, {name = storeName, object = store, shopItems = shopItems, npc = npcInfo}) end
    end
end

local evilEnItemMap = { ["I CANT SEE"]="Eye3", ["HATCHES INTO SOMETHING GREAT"]="Egg", ["KEEP ME WARM"]="Cocoa", ["GRANT ME LIGHT"]="LightBulb", ["QUACK QUACK"]="Duck", ["GRANT MY WISH"]="MagicLamp", ["GREAT WITH COOKIES"]="Milk", ["CHEAT CODE"]="NESController", ["GIVE ME POWER"]="Battery", ["IM THIRSTY"]="BloxyCola", ["CLAIMS TO BE HAPPY"]="HappyBall", ["WIELDED BY SOMEONE POWERFUL"]="MagicLamp" }

local function evilBuyBlueprintBox(blueprintName)
    local targetStore, targetItemName = nil, nil
    local lower = string.lower(tostring(blueprintName))
    for _, s in ipairs(allStoresEvil) do
        if s.shopItems then
            for _, item in pairs(s.shopItems:GetChildren()) do
                if string.lower(tostring(item.Name)) == lower then targetStore, targetItemName = s, item.Name break end
            end
        end
        if targetStore then break end
    end
    if not targetStore then return nil, "没有任何商店出售: " .. tostring(blueprintName) end
    if not targetStore.npc or not targetStore.npc.id then
        local newIds = GetAllCashierIds()
        for storeName, info in pairs(storeInfoMapping) do
            local npc = npcMapping[storeName]
            if npc and npc.id == nil and newIds[info.name] then npc.id = newIds[info.name] end
        end
        if not targetStore.npc.id then return nil, "商店 " .. targetStore.name .. " 的 NPC ID 未获取" end
    end
    local store = targetStore.object
    local npcInfo = targetStore.npc
    local npcChar = store:FindFirstChild(npcInfo.path)
    if not npcChar then return nil, "找不到NPC实体: " .. tostring(npcInfo.path) end
    local counter = store:FindFirstChild("Counter")
    if not counter or not counter:IsA("BasePart") then return nil, "商店无 Counter 柜台" end
    local shopItems = store:FindFirstChild("ShopItems")
    local itemModel = shopItems:FindFirstChild(targetItemName)
    if not itemModel then return nil, "商品不在货架(可能被买空了): " .. targetItemName end
    local primary = itemModel.PrimaryPart or itemModel:FindFirstChild("WoodSection") or itemModel:FindFirstChild("Main") or itemModel:FindFirstChildWhichIsA("BasePart")
    if not primary then return nil, "无法定位商品模型" end
    if not itemModel.PrimaryPart then itemModel.PrimaryPart = primary end
    
    duckLockPlayerAt(primary.CFrame + Vector3.new(0, 3, 0))
    task.wait(0.3)
    for j = 1, 40 do DragModel(itemModel, counter.CFrame + Vector3.new(0, 0.6, 0)) task.wait(0.02) end
    task.wait(0.09)
    duckLockPlayerAt(counter.CFrame + Vector3.new(0, 3, 0))
    task.wait(0.1)
    
    local purchased = {}
    local conn = workspace.PlayerModels.ChildAdded:Connect(function(m)
        if m:IsA("Model") and m:FindFirstChild("Owner") and m.Owner.Value == player then table.insert(purchased, m) end
    end)
    local NPCDialog = REPLICATED_STORAGE:WaitForChild("NPCDialog")
    local args = {{ID = npcInfo.id, Character = npcChar, Name = npcInfo.name}, "ConfirmPurchase"}
    pcall(function() NPCDialog.PlayerChatted:InvokeServer(table.unpack(args)) end)
    task.wait(0.1)
    pcall(function() NPCDialog.PlayerChatted:InvokeServer(table.unpack(args)) end)
    task.wait(0.1)
    conn:Disconnect()
    duckUnlockPlayer()
    
    for i = #purchased, 1, -1 do
        local m = purchased[i]
        if m and m.Parent then return m, targetStore.name end
    end
    return nil, "购买后未找到新盒子"
end

local function evilGetMaterialNames()
    local parts = Workspace:FindFirstChild("Stores") and Workspace.Stores:FindFirstChild("StoneRUs") and Workspace.Stores.StoneRUs:FindFirstChild("Parts")
    if not parts then return nil, "未找到 StoneRUs 商店或 Parts" end
    local names = {}
    for i = 1, 3 do
        local raw, note = "", parts:FindFirstChild("Note"..i)
        if note then
            local gui = note:FindFirstChildOfClass("SurfaceGui")
            if gui then for _, obj in pairs(gui:GetDescendants()) do if obj:IsA("TextLabel") then raw = obj.Text break end end end
        end
        if raw ~= "" then
            local words = {}
            for w in raw:gmatch("[^/]+") do
                local letters = {}
                for l in w:gmatch("%S+") do table.insert(letters, morse[l] or "?") end
                table.insert(words, table.concat(letters))
            end
            local decoded = table.concat(words, " ")
            names[i] = { decoded = decoded, item = evilEnItemMap[decoded] }
        else names[i] = { decoded = "", item = nil } end
    end
    return names
end

local function getItemKey(model)
    if not model then return nil end
    if model:FindFirstChild("PurchasedBoxItemName") then return "PurchasedBoxItemName:"..model.PurchasedBoxItemName.Value
    elseif model:FindFirstChild("ItemName") then return "ItemName:"..model.ItemName.Value
    elseif model:FindFirstChild("DraggableItem") then return "DraggableItem:"..tostring(model.DraggableItem.Parent) end
    return nil
end

local function findItemByKey(key, allowFuzzy)
    if not key then return nil end
    local prefix, value = key:match("^(.-):(.+)$")
    if not prefix or not value then return nil end
    for _, model in pairs(workspace.PlayerModels:GetChildren()) do
        if model:FindFirstChild("Owner") and model.Owner.Value == player then
            if prefix == "PurchasedBoxItemName" and model:FindFirstChild("PurchasedBoxItemName") and model.PurchasedBoxItemName.Value == value then return model
            elseif prefix == "ItemName" and model:FindFirstChild("ItemName") and model.ItemName.Value == value then return model
            elseif prefix == "DraggableItem" and model:FindFirstChild("DraggableItem") and tostring(model.DraggableItem.Parent) == value then return model end
        end
    end
    if allowFuzzy then
        for _, model in pairs(workspace.PlayerModels:GetChildren()) do
            if model:FindFirstChild("Owner") and model.Owner.Value == player then
                local modelValue = nil
                if model:FindFirstChild("PurchasedBoxItemName") then modelValue = model.PurchasedBoxItemName.Value
                elseif model:FindFirstChild("ItemName") then modelValue = model.ItemName.Value
                elseif model:FindFirstChild("DraggableItem") then modelValue = tostring(model.DraggableItem.Parent) end
                if modelValue == value then return model end
            end
        end
    end
    return nil
end
local function waitItemReady(item, timeout)
    timeout = timeout or 3
    local waited = 0
    while waited < timeout do
        if not item or not item.Parent then return false end
        if item:FindFirstChild("ButtonRemote_Main") or item:FindFirstChild("BoxItemName") or item:FindFirstChild("PurchasedBoxItemName") or item:FindFirstChild("ItemName") or item:FindFirstChild("DraggableItem") then return true end
        task.wait(0.2)
        waited = waited + 0.2
    end
    return item and item.Parent and (item:FindFirstChild("ItemName") ~= nil or item:FindFirstChild("PurchasedBoxItemName") ~= nil)
end

local function openItem(item)
    if not item then return false end
    local remoteButton = item:FindFirstChild("ButtonRemote_Main")
    if remoteButton then
        local ok = pcall(function() REPLICATED_STORAGE.Interaction.RemoteProxy:FireServer(remoteButton) end)
        if ok then return true end
    end
    if item:FindFirstChild("BoxItemName") or item:FindFirstChild("PurchasedBoxItemName") then
        local ok = pcall(function() REPLICATED_STORAGE.Interaction.ClientInteracted:FireServer(item, 'Open box') end)
        if ok then return true end
    end
    return false
end

local function waitEvilDuckAppear(timeout, preSet)
    local deadline = os.clock() + (timeout or 15)
    while os.clock() < deadline do
        if evilStopFlag then return false end
        for _, m in pairs(workspace.PlayerModels:GetChildren()) do
            if m:IsA("Model") and m.Name == "DuckEvil" and (not preSet or not preSet[m]) then return true end
        end
        task.wait(0.2)
    end
    return false
end

local function waitEvilDuckLightGone(timeout)
    local deadline = os.clock() + (timeout or 35)
    while os.clock() < deadline do
        if evilStopFlag then return false end
        local hasLight = false
        for _, m in pairs(workspace.PlayerModels:GetChildren()) do
            if m:IsA("Model") and m.Name == "DuckEvil" then
                local main = m:FindFirstChild("Main")
                if main and main:FindFirstChild("PointLight") then hasLight = true break end
            end
        end
        if not hasLight then return true end
        task.wait(0.2)
    end
    return false
end

local function startEvilDuckCombine(basePos, selectedMaterialKeys)
    local dragTargets = { [1] = CFrame.new(-223.74, 61.00, 940.42), [2] = CFrame.new(-232.924927, 61.3797455, 933.015076), [3] = CFrame.new(-241.81, 61, 925.51) }
    local items = {}
    if not selectedMaterialKeys then return false end
    for i = 1, 3 do
        local key = selectedMaterialKeys[i]
        if not key then return false end
        local item = findItemByKey(key, true)
        if not item then return false end
        items[i] = item
        selectedMaterialKeys[i] = getItemKey(item)
    end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local originalPos = basePos or (hrp and hrp.CFrame)
    if not originalPos then return false end
    local preDucks = {}
    for _, m in pairs(workspace.PlayerModels:GetChildren()) do 
        if m:IsA("Model") and m.Name == "DuckEvil" then preDucks[m] = true end 
    end
    local ok = false
    for attempt = 1, 4 do
        if evilStopFlag then break end
        local pads = {}
        for i = 1, 3 do
            local pad = Instance.new("Part")
            pad.Name = "EvilAntiFallPad"
            pad.Size = Vector3.new(4, 0.2, 4)
            pad.CFrame = dragTargets[i] + Vector3.new(0, 0.1, 0)
            pad.Transparency = 1
            pad.Anchored = true
            pad.CanCollide = true
            pad.Parent = workspace
            table.insert(pads, pad)
        end
        for i = 1, 3 do
            local item = items[i]
            if not item or not item.Parent then
                local key = selectedMaterialKeys[i]
                if key then item = findItemByKey(key, true) end
                if not item then break end
                items[i] = item
            end
            if not waitItemReady(item, 3) then end
            local primary = item.PrimaryPart or item:FindFirstChild("Main") or item:FindFirstChild("WoodSection") or item:FindFirstChildWhichIsA("BasePart")
            if not primary then break end
            if not item.PrimaryPart then item.PrimaryPart = primary end
            
            local targetIdx = i
            if i == 1 then targetIdx = 3 elseif i == 3 then targetIdx = 1 end
            local hoverPos = dragTargets[targetIdx] + Vector3.new(0, 6, 0)
            
            duckLockPlayerAt(hoverPos)
            pcall(function() REPLICATED_STORAGE.Interaction.ClientRequestOwnership:FireServer(primary) end)
            for j = 1, 30 do DragModel(item, dragTargets[targetIdx]) task.wait(0.02) end
            duckUnlockPlayer()
        end
        for i = 1, 3 do
            local item = items[i]
            if not item or not item.Parent then
                local key = selectedMaterialKeys[i]
                if key then item = findItemByKey(key, true) end
                if not item then break end
                items[i] = item
            end
            local targetIdx = i
            if i == 1 then targetIdx = 3 elseif i == 3 then targetIdx = 1 end
            local hoverPos = dragTargets[targetIdx] + Vector3.new(0, 6, 0)
            
            duckLockPlayerAt(hoverPos)
            task.wait(0.2)
            local dp2 = item.PrimaryPart or item:FindFirstChild("Main") or item:FindFirstChild("WoodSection") or item:FindFirstChildWhichIsA("BasePart")
            if dp2 then pcall(function() REPLICATED_STORAGE.Interaction.ClientRequestOwnership:FireServer(dp2) end) end
            openItem(item)
            task.wait(0.2)
            duckUnlockPlayer()
        end
        local duckAppeared = waitEvilDuckAppear(15, preDucks)
        if duckAppeared then
            local newDuck = nil
            for _, m in pairs(workspace.PlayerModels:GetChildren()) do
                if m:IsA("Model") and m.Name == "DuckEvil" and not preDucks[m] then newDuck = m break end
            end
            if newDuck then
                local dp = newDuck.PrimaryPart or newDuck:FindFirstChild("Main") or newDuck:FindFirstChildWhichIsA("BasePart")
                if dp then
                    if not newDuck.PrimaryPart then newDuck.PrimaryPart = dp end
                    duckSafeTeleport(originalPos)
                    for j = 1, 30 do DragModel(newDuck, originalPos) task.wait(0.02) end
                    ok = waitEvilDuckLightGone(35)
                    for _, p in ipairs(pads) do if p then p:Destroy() end end
                    if ok then break end
                end
            end
        else
            for _, p in ipairs(pads) do if p then p:Destroy() end end
            duckSafeTeleport(originalPos)
            task.wait(1)
        end
    end
    if not ok then duckSafeTeleport(originalPos) end
    return ok
end

local function evilMain(count)
    if evilAutoRunning then return end
    evilAutoRunning, evilStopFlag = true, false
    task.spawn(function()
        local success, err = pcall(function()
            local newIds = GetAllCashierIds()
            for storeName, info in pairs(storeInfoMapping) do
                local npc = npcMapping[storeName]
                if npc and newIds[info.name] then npc.id = newIds[info.name] end
            end
            local names, msg = evilGetMaterialNames()
            if not names then error(msg or "识别失败") end
            local matKeys = {}
            for i = 1, 3 do
                if names[i] and names[i].item then matKeys[i] = "ItemName:" .. names[i].item
                else error("材料 " .. i .. " 识别失败") end
            end
            local baseCF = player.Character and player.Character.HumanoidRootPart.CFrame
            for c = 1, count do
                if evilStopFlag then break end
                for i = 1, 3 do
                    if evilStopFlag then break end
                    local key = matKeys[i]
                    if findItemByKey(key, false) then
                    else
                        local buyName = key:match("ItemName:(.+)")
                        local box, err
                        for r = 1, 3 do
                            if evilStopFlag then break end
                            box, err = evilBuyBlueprintBox(buyName)
                            if box then break end
                            task.wait(0.6)
                        end
                        if not box then error("材料 " .. i .. " 购买失败") end
                    end
                    task.wait(0.6)
                end
                local ok = startEvilDuckCombine(baseCF, matKeys)
                if baseCF then duckSafeTeleport(baseCF) end
                task.wait(1)
            end
        end)
        duckUnlockPlayer()
        evilAutoRunning = false
        evilStopFlag = false
    end)
end

TabCraft:Paragraph({ Title = "【 恶魔鸭全自动合成 】" })
TabCraft:Input({ Title = "合成次数", Value = "1", Callback = function(v)
    local n = tonumber(v)
    if n and n > 0 then evilCombineCount = math.floor(n) end
end })
TabCraft:Button({ Title = "开始全自动合成恶魔鸭", Callback = function() evilMain(evilCombineCount) end })
TabCraft:Button({ Title = "停止自动合成", Callback = function() 
    evilStopFlag = true
    evilAutoRunning = false
    duckUnlockPlayer() 
end })

TabBuy:Paragraph({ Title = "【 购买恶魔鸭材料 】" })
TabBuy:Button({ Title = "一键购买材料拉回脚下", Callback = function()
    task.spawn(function()
        local names = evilGetMaterialNames()
        if not names then return end
        local baseCF = player.Character.HumanoidRootPart.CFrame
        for i = 1, 3 do
            if names[i] and names[i].item then
                local key = "ItemName:" .. names[i].item
                if not findItemByKey(key, false) then
                    local box = evilBuyBlueprintBox(names[i].item)
                    if box then
                        if not box.PrimaryPart then box.PrimaryPart = box:FindFirstChildWhichIsA("BasePart") end
                        for j = 1, 30 do DragModel(box, baseCF) task.wait(0.02) end
                    end
                end
            end
        end
    end)
end)
TabCraft:Paragraph({ Title = "【 三叉戟合成 】" })
local Pos_Heaven = CFrame.new(-360.262, 14.753, -1333.273)
local Pos_Star = CFrame.new(-372.022, 15.158, -1330.268)
local Pos_Demon = CFrame.new(-383.149, 15.565, -1327.575)
local Pos_Altar = CFrame.new(-365.610, 12.621, -1319.532)
local dropTarget_Trident = Pos_Heaven

TabCraft:Button({ Title = "传送到三叉戟祭坛", Callback = function() 
    player.Character.HumanoidRootPart.CFrame = Pos_Altar 
    Notify("传送成功", "已到达三叉戟祭坛")
end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂鸭子 (左)", "星星鸭子 (中)", "恶魔鸭子 (右)"}, Value = "天堂鸭子 (左)", Callback = function(opt)
    if opt == "天堂鸭子 (左)" then dropTarget_Trident = Pos_Heaven
    elseif opt == "星星鸭子 (中)" then dropTarget_Trident = Pos_Star
    else dropTarget_Trident = Pos_Demon end
end })
TabCraft:Button({ Title = "获取【三叉戟空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack)
    tool.Name = "空投工具"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local t = Mouse.Target
        if t then
            for i = 1, 30 do DragModel(t.Parent, dropTarget_Trident) task.wait(0.01) end
        end
    end)
end })

TabCraft:Paragraph({ Title = "【 永恒剑合成 】" })
local Pos_Eternal_Trident = CFrame.new(-360.408, 14.757, -1333.086)
local Pos_Eternal_Revenge = CFrame.new(-371.428, 15.148, -1330.260)
local Pos_Eternal_Demon = CFrame.new(-382.908, 15.561, -1327.481)
local Pos_Eternal_Altar = CFrame.new(-367.265, 12.692, -1317.212)
local dropTarget_Eternal = Pos_Eternal_Trident

TabCraft:Button({ Title = "传送到永恒剑祭坛", Callback = function() 
    player.Character.HumanoidRootPart.CFrame = Pos_Eternal_Altar 
    Notify("传送成功", "已到达永恒剑祭坛")
end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"三叉戟 (左)", "复仇剑 (中)", "恶魔鸭子 (右)"}, Value = "三叉戟 (左)", Callback = function(opt)
    if opt == "三叉戟 (左)" then dropTarget_Eternal = Pos_Eternal_Trident
    elseif opt == "复仇剑 (中)" then dropTarget_Eternal = Pos_Eternal_Revenge
    else dropTarget_Eternal = Pos_Eternal_Demon end
end })
TabCraft:Button({ Title = "获取【永恒剑空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack)
    tool.Name = "空投工具(永恒)"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local t = Mouse.Target
        if t then
            for i = 1, 30 do DragModel(t.Parent, dropTarget_Eternal) task.wait(0.01) end
        end
    end)
end })

TabCraft:Paragraph({ Title = "【 复仇剑合成 】" })
local Pos_Revenge_Demon = CFrame.new(6487.173, -92.148, -4551.805)
local Pos_Revenge_Heaven = CFrame.new(6448.009, -93.535, -4523.665)
local Pos_Revenge_Altar = CFrame.new(6462.440, -94.916, -4543.508)
local dropTarget_Revenge = Pos_Revenge_Demon

TabCraft:Button({ Title = "传送到复仇剑祭坛", Callback = function() 
    player.Character.HumanoidRootPart.CFrame = Pos_Revenge_Altar 
    Notify("传送成功", "已到达复仇剑祭坛")
end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"恶魔鸭子", "天堂鸭子"}, Value = "恶魔鸭子", Callback = function(opt)
    if opt == "恶魔鸭子" then dropTarget_Revenge = Pos_Revenge_Demon
    else dropTarget_Revenge = Pos_Revenge_Heaven end
end })
TabCraft:Button({ Title = "获取【复仇剑空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack)
    tool.Name = "空投工具(复仇)"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local t = Mouse.Target
        if t then
            for i = 1, 30 do DragModel(t.Parent, dropTarget_Revenge) task.wait(0.01) end
        end
    end)
end })

TabCraft:Paragraph({ Title = "【 星星鸭子合成 】" })
local Pos_StarDuck_Heaven = CFrame.new(-7041.764, 391.973, 4906.096)
local Pos_StarDuck_Normal = CFrame.new(-7066.685, 392.111, 4898.619)
local Pos_StarDuck_Demon = CFrame.new(-7092.101, 392.085, 4890.774)
local Pos_StarDuck_Altar = CFrame.new(-7064.089, 390.357, 4885.606)
local dropTarget_StarDuck = Pos_StarDuck_Heaven

TabCraft:Button({ Title = "传送到星星鸭子祭坛", Callback = function() 
    player.Character.HumanoidRootPart.CFrame = Pos_StarDuck_Altar 
    Notify("传送成功", "已到达星星鸭子祭坛")
end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂鸭", "普通鸭", "恶魔鸭"}, Value = "天堂鸭", Callback = function(opt)
    if opt == "天堂鸭" then dropTarget_StarDuck = Pos_StarDuck_Heaven
    elseif opt == "普通鸭" then dropTarget_StarDuck = Pos_StarDuck_Normal
    else dropTarget_StarDuck = Pos_StarDuck_Demon end
end })
TabCraft:Button({ Title = "获取【星星鸭子空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack)
    tool.Name = "空投工具(星星)"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local t = Mouse.Target
        if t then
            for i = 1, 30 do DragModel(t.Parent, dropTarget_StarDuck) task.wait(0.01) end
        end
    end)
end })

TabCraft:Paragraph({ Title = "【 地狱火合成 】" })
local Pos_Hellfire_Trident = CFrame.new(-1755.451, 346.302, 1478.264)
local Pos_Hellfire_Demon = CFrame.new(-1785.906, 346.302, 1495.925)
local Pos_Hellfire_Altar = CFrame.new(-1682.328, 349.602, 1477.501)
local dropTarget_Hellfire = Pos_Hellfire_Trident

TabCraft:Button({ Title = "传送到地狱火祭坛", Callback = function() 
    player.Character.HumanoidRootPart.CFrame = Pos_Hellfire_Altar 
    Notify("传送成功", "已到达地狱火祭坛")
end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"三叉戟", "恶魔鸭"}, Value = "三叉戟", Callback = function(opt)
    if opt == "三叉戟" then dropTarget_Hellfire = Pos_Hellfire_Trident
    else dropTarget_Hellfire = Pos_Hellfire_Demon end
end })
TabCraft:Button({ Title = "获取【地狱火空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack)
    tool.Name = "空投工具(地狱火)"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local t = Mouse.Target
        if t then
            for i = 1, 30 do DragModel(t.Parent, dropTarget_Hellfire) task.wait(0.01) end
        end
    end)
end })

TabCraft:Paragraph({ Title = "【 天堂光环合成 】" })
local Pos_Halo_HeavenDuck = CFrame.new(-678.179, 25.500, -404.403)
local Pos_Halo_EternalSword = CFrame.new(-680.807, 25.500, -413.101)
local Pos_Halo_Altar = CFrame.new(-670.157, 21.800, -412.872)
local dropTarget_Halo = Pos_Halo_HeavenDuck

TabCraft:Button({ Title = "传送到天堂光环祭坛", Callback = function() 
    player.Character.HumanoidRootPart.CFrame = Pos_Halo_Altar 
    Notify("传送成功", "已到达天堂光环祭坛")
end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂鸭", "永恒剑"}, Value = "天堂鸭", Callback = function(opt)
    if opt == "天堂鸭" then dropTarget_Halo = Pos_Halo_HeavenDuck
    else dropTarget_Halo = Pos_Halo_EternalSword end
end })
TabCraft:Button({ Title = "获取【天堂光环空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack)
    tool.Name = "空投工具(光环)"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local t = Mouse.Target
        if t then
            for i = 1, 30 do DragModel(t.Parent, dropTarget_Halo) task.wait(0.01) end
        end
    end)
end })

TabCraft:Paragraph({ Title = "【 天堂剑合成 】" })
local Pos_HeavenSword_Halo = CFrame.new(1662.831, 402.424, 3280.203)
local Pos_HeavenSword_Altar = CFrame.new(1659.923, 399.730, 3273.653)
local dropTarget_HeavenSword = Pos_HeavenSword_Halo

TabCraft:Button({ Title = "传送到雪山天堂剑祭坛", Callback = function() 
    player.Character.HumanoidRootPart.CFrame = Pos_HeavenSword_Altar 
    Notify("传送成功", "已到达天堂剑祭坛")
end })
TabCraft:Button({ Title = "获取【天堂剑空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack)
    tool.Name = "空投工具(天堂剑)"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local t = Mouse.Target
        if t then
            for i = 1, 30 do DragModel(t.Parent, dropTarget_HeavenSword) task.wait(0.01) end
        end
    end)
end })

TabCraft:Paragraph({ Title = "【 月牙合成 】" })
local Pos_Moon_HeavenSword = CFrame.new(1491.958, 415.623, 3322.311)
local Pos_Moon_Hellfire = CFrame.new(1477.948, 415.623, 3327.516)
local Pos_Moon_Altar = CFrame.new(1482.868, 413.256, 3318.388)
local dropTarget_Moon = Pos_Moon_HeavenSword

local function IsEvening() 
    return Lighting.ClockTime >= 17 and Lighting.ClockTime <= 19 
end

TabCraft:Button({ Title = "传送到月牙祭坛", Callback = function()
    if not IsEvening() then 
        Notify("时间未到", "当前不是傍晚 (17:00-19:00)")
        return
    end
    player.Character.HumanoidRootPart.CFrame = Pos_Moon_Altar
    Notify("传送成功", "已到达月牙祭坛")
end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂剑", "地狱火"}, Value = "天堂剑", Callback = function(opt)
    if opt == "天堂剑" then dropTarget_Moon = Pos_Moon_HeavenSword
    else dropTarget_Moon = Pos_Moon_Hellfire end
end })
TabCraft:Button({ Title = "获取【月牙空投工具】", Callback = function()
    if not IsEvening() then 
        Notify("拒绝提供工具", "当前不是傍晚，无法获取")
        return
    end
    local tool = Instance.new("Tool", player.Backpack)
    tool.Name = "空投工具(月牙)"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        if not IsEvening() then 
            Notify("时间过了", "祭坛已消失，无法放入")
            return
        end
        local t = Mouse.Target
        if t then
            for i = 1, 30 do DragModel(t.Parent, dropTarget_Moon) task.wait(0.01) end
        end
    end)
end })

TabCraft:Paragraph({ Title = "【 月神剑合成 】" })
local Pos_MoonSword_Crescent = CFrame.new(-7648.661, 322.803, 4233.530)
local Pos_MoonSword_Altar = CFrame.new(-7642.798, 320.995, 4227.344)
local dropTarget_MoonSword = Pos_MoonSword_Crescent

TabCraft:Button({ Title = "传送到月神剑祭坛", Callback = function() 
    player.Character.HumanoidRootPart.CFrame = Pos_MoonSword_Altar 
    Notify("传送成功", "已到达月神剑祭坛")
end })
TabCraft:Button({ Title = "获取【月神剑空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack)
    tool.Name = "空投工具(月神剑)"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local t = Mouse.Target
        if t then
            for i = 1, 30 do DragModel(t.Parent, dropTarget_MoonSword) task.wait(0.01) end
        end
    end)
end })
TabExtra:Paragraph({ Title = "【 环境修改 】" })
local awaysday = false
local awaysdnight = false
local nofog = false

TabExtra:Toggle({ Title = "终日白天", Value = false, Callback = function(state)
    awaysday = state
    if state then Lighting.TimeOfDay = "14:00:00" end
end })
TabExtra:Toggle({ Title = "终日黑夜", Value = false, Callback = function(state)
    awaysdnight = state
    if state then Lighting.TimeOfDay = "02:00:00" end
end })
TabExtra:Toggle({ Title = "去除雾", Value = false, Callback = function(state)
    nofog = state
    if state then Lighting.FogEnd = 1000000 end
end })
TabExtra:Toggle({ Title = "消除阴影", Value = false, Callback = function(state)
    Lighting.GlobalShadows = not state
end })

TabExtra:Paragraph({ Title = "【 穿墙与透视 】" })
local noclipEnabled = false
local noclipConn = nil
local function applyNoClip(state)
    noclipEnabled = state
    if state then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if player.Character then
                for _, v in pairs(player.Character:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if player.Character then
            for _, v in pairs(player.Character:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end
TabExtra:Toggle({ Title = "穿墙模式", Value = false, Callback = function(state) applyNoClip(state) end })

local duckHighlights = {}
local duckOutlineEnabled = false
local function syncDuckHighlights()
    if not duckOutlineEnabled then return end
    local currentDucks = {}
    for _, model in pairs(Workspace.PlayerModels:GetChildren()) do
        if model:IsA("Model") and model.Name == "2018CGift_Duck" then
            currentDucks[model] = true
            if not duckHighlights[model] then
                local hl = Instance.new("Highlight")
                hl.Parent = model
                hl.FillColor = Color3.fromRGB(0, 150, 255)
                hl.FillTransparency = 0.7
                hl.OutlineColor = Color3.fromRGB(0, 100, 200)
                hl.OutlineTransparency = 0.3
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Enabled = true
                duckHighlights[model] = hl
            end
        end
    end
    for model, hl in pairs(duckHighlights) do
        if not currentDucks[model] then
            hl:Destroy()
            duckHighlights[model] = nil
        end
    end
end
TabExtra:Toggle({ Title = "礼物鸭蓝色轮廓透视", Value = false, Callback = function(state)
    duckOutlineEnabled = state
    if state then
        syncDuckHighlights()
        task.spawn(function()
            while duckOutlineEnabled do
                syncDuckHighlights()
                task.wait(2)
            end
        end)
    else
        for _, hl in pairs(duckHighlights) do pcall(function() hl:Destroy() end) end
        duckHighlights = {}
    end
end })

TabExtra:Paragraph({ Title = "【 汽车传送 】" })
local function carTeleport(cf)
    if player.Character then
        local Character = player.Character
        if Character.Humanoid.SeatPart ~= nil then
            local Car = Character.Humanoid.SeatPart.Parent
            task.spawn(function()
                for i = 1, 5 do
                    task.wait()
                    Car:SetPrimaryPartCFrame(cf * CFrame.Angles(math.rad(Character.HumanoidRootPart.Orientation.x), math.rad(Character.HumanoidRootPart.Orientation.y), 0))
                    RS.Interaction.ClientRequestOwnership:FireServer(Car.Main)
                    RS.Interaction.ClientIsDragging:FireServer(Car.Main)
                end
            end)
        end
    end
end
local teleList = {
    "恶魔鸭合成地点", "裂纹木所在地", "回家", "连接逻辑店", "土地商店", "会员商店", "画店", "桥对岸", "沙滩", "火木", "雪山", "洞穴", "码头", "黑市", "糖果原", "雪地入口", "盖克斯航运", "玻璃冰木入口", "云层", "山边商品", "章鱼哥祭坛", "沼泽商店", "石头商店", "沼泽", "冰胡", "星星岛", "辐射商店", "核污染区", "种子商人", "鲍勃的店", "家具店", "车店", "罗布克斯商店", "肯德坤专卖店", "秋季商店"
}
TabExtra:Dropdown({ Title = "选择汽车传送地点", Values = teleList, Value = "恶魔鸭合成地点", Callback = function(val)
    local cf = nil
    if val == "回家" then
        for _, v in pairs(workspace.Properties:GetChildren()) do
            if v.Owner.Value == player then cf = v.OriginSquare.CFrame + Vector3.new(0, 10, 0) break end
        end
    elseif val == "连接逻辑店" then cf = CFrame.new(4607, 9, -740)
    elseif val == "土地商店" then cf = CFrame.new(230, 5, -99)
    elseif val == "会员商店" then cf = CFrame.new(907, 4, -115)
    elseif val == "画店" then cf = CFrame.new(5207, -156, 719)
    elseif val == "桥对岸" then cf = CFrame.new(109, 5, -1166)
    elseif val == "沙滩" then cf = CFrame.new(2549, 5, -42)
    elseif val == "火木" then cf = CFrame.new(-1585, 625, 1140)
    elseif val == "雪山" then cf = CFrame.new(1451.66248, 412.208405, 3183.47607)
    elseif val == "洞穴" then cf = CFrame.new(3581, -177, 430)
    elseif val == "码头" then cf = CFrame.new(1122, 1, -203)
    elseif val == "黑市" then cf = CFrame.new(-15, 61, 1365)
    elseif val == "糖果原" then cf = CFrame.new(-561, 272, 2312)
    elseif val == "雪地入口" then cf = CFrame.new(888, 61, 1188)
    elseif val == "盖克斯航运" then cf = CFrame.new(1894, -2, 1581)
    elseif val == "玻璃冰木入口" then cf = CFrame.new(1929, 256, 2918)
    elseif val == "云层" then cf = CFrame.new(2060, 495, 2967)
    elseif val == "山边商品" then cf = CFrame.new(-640, 160, 374)
    elseif val == "章鱼哥祭坛" then cf = CFrame.new(-1622, 196, 941)
    elseif val == "沼泽商店" then cf = CFrame.new(-1274, 133, -1443)
    elseif val == "石头商店" then cf = CFrame.new(-2395, 302, -1899)
    elseif val == "沼泽" then cf = CFrame.new(-999, 133, -1191)
    elseif val == "冰胡" then cf = CFrame.new(-2149, 321, 743)
    elseif val == "星星岛" then cf = CFrame.new(-612, 46, -3169)
    elseif val == "辐射商店" then cf = CFrame.new(172, 12, -2627)
    elseif val == "核污染区" then cf = CFrame.new(207, 15, -2752)
    elseif val == "种子商人" then cf = CFrame.new(-15, 18, -2680)
    elseif val == "鲍勃的店" then cf = CFrame.new(245, 9, -2541)
    elseif val == "家具店" then cf = CFrame.new(490, 4, -1690)
    elseif val == "车店" then cf = CFrame.new(512, 4, -1490)
    elseif val == "罗布克斯商店" then cf = CFrame.new(652, 4, -1565)
    elseif val == "肯德坤专卖店" then cf = CFrame.new(100, 4, -455)
    elseif val == "秋季商店" then cf = CFrame.new(6004, 4, 33)
    end
    if cf then carTeleport(cf) end
end })