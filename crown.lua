local player = game.Players.LocalPlayer
local TS = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
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

local function CleanupAll()
    isDragEnabled = false
    if dragConn then
        dragConn:Disconnect()
        dragConn = nil
    end

    for i = 1, 3 do
        local bringPoint = Workspace:FindFirstChild("BRING"..i)
        if bringPoint then bringPoint:Destroy() end
    end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, v in pairs(backpack:GetChildren()) do
            if v:IsA("Tool") and (string.find(v.Name, "空投工具") or v.Name == "点击传送" or v.Name == "多选框选工具") then
                v:Destroy()
            end
        end
    end
    
    local char = player.Character
    if char then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") and (string.find(v.Name, "空投工具") or v.Name == "点击传送" or v.Name == "多选框选工具") then
                v:Destroy()
            end
        end
    end

    local oldGui = CoreGui:FindFirstChild("封存木材")
    if oldGui then oldGui:Destroy() end
end

CleanupAll()

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存木材0.1",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Size = UDim2.fromOffset(420, 380),
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

local TabCraft = Window:Tab({ Title = "合成物品", Icon = "rbxassetid://10734945123" })

TabCraft:Button({
    Title = "【一键清理】消除所有空投工具",
    Desc = "清理背包里多余的合成工具",
    Callback = function()
        local count = 0
        local backpack = player:FindFirstChild("Backpack")
        local char = player.Character
        
        if backpack then
            for _, v in pairs(backpack:GetChildren()) do
                if v:IsA("Tool") and string.find(v.Name, "空投工具") then
                    v:Destroy()
                    count = count + 1
                end
            end
        end
        
        if char then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("Tool") and string.find(v.Name, "空投工具") then
                    v:Destroy()
                    count = count + 1
                end
            end
        end
        
        WindUI:Notify({ Title = "清理完毕", Content = "共消除了 "..count.." 个空投工具", Duration = 3 })
    end
})

TabCraft:Paragraph({
    Title = "【 三叉戟合成 】",
    Desc = "天堂鸭 / 星星鸭 / 恶魔鸭",
    Color = Color3.fromRGB(0, 255, 255)
})

local Pos_Heaven = CFrame.new(-360.262, 14.753, -1333.273)
local Pos_Star   = CFrame.new(-372.022, 15.158, -1330.268)
local Pos_Demon  = CFrame.new(-383.149, 15.565, -1327.575)
local Pos_Altar  = CFrame.new(-365.610, 12.621, -1319.532)

local dropTarget_Trident = Pos_Heaven

TabCraft:Button({
    Title = "传送到三叉戟祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达三叉戟祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择三叉戟材料位置",
    Values = {"天堂鸭子 (左)", "星星鸭子 (中)", "恶魔鸭子 (右)"},
    Value = "天堂鸭子 (左)",
    Callback = function(opt)
        if opt == "天堂鸭子 (左)" then dropTarget_Trident = Pos_Heaven
        elseif opt == "星星鸭子 (中)" then dropTarget_Trident = Pos_Star
        elseif opt == "恶魔鸭子 (右)" then dropTarget_Trident = Pos_Demon end
    end
})

TabCraft:Button({
    Title = "获取【三叉戟空投工具】",
    Desc = "点击地上的鸭子直接瞬移入阵",
    Callback = function()
        if player.Backpack:FindFirstChild("空投工具") or player.Character:FindFirstChild("空投工具") then
            player.Backpack["空投工具"]:Destroy()
        end
        
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            local targetPart = Mouse.Target
            if not targetPart then return end
            local targetModel = targetPart.Parent
            
            if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
                for i = 1, 30 do
                    DragModel(targetModel, dropTarget_Trident)
                    task.wait(0.01)
                end
                WindUI:Notify({ Title = "空投成功", Content = "已放入三叉戟祭坛", Duration = 2 })
            end
        end)
        WindUI:Notify({ Title = "获取成功", Content = "工具已放入背包！", Duration = 3 })
    end
})

TabCraft:Button({
    Title = "一键全自动摆阵(三叉戟)",
    Desc = "自动吸附附近的鸭子",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local nearbyItems = {}
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local p = obj.PrimaryPart or (obj:IsA("Part") and obj)
                if p and (p.Position - hrp.Position).Magnitude < 20 then
                    if not obj:FindFirstChild("Humanoid") and obj.Name ~= "HumanoidRootPart" and not obj:FindFirstChild("TreeClass") then
                        table.insert(nearbyItems, obj)
                    end
                end
            end
        end
        
        if #nearbyItems >= 3 then
            WindUI:Notify({ Title = "扫描成功", Content = "正在强制吸附...", Duration = 3 })
            for i = 1, 15 do DragModel(nearbyItems[1], Pos_Heaven) task.wait(0.01) end
            for i = 1, 15 do DragModel(nearbyItems[2], Pos_Star) task.wait(0.01) end
            for i = 1, 15 do DragModel(nearbyItems[3], Pos_Demon) task.wait(0.01) end
            WindUI:Notify({ Title = "布阵完成", Content = "请检查祭坛是否触发", Duration = 4 })
        else
            WindUI:Notify({ Title = "失败", Content = "附近物品不足 3 个！", Duration = 4 })
        end
    end
})

TabCraft:Paragraph({
    Title = "【 永恒剑合成 】",
    Desc = "三叉戟 / 复仇剑 / 恶魔鸭子",
    Color = Color3.fromRGB(255, 150, 0)
})

local Pos_Eternal_Trident = CFrame.new(-360.408, 14.757, -1333.086)
local Pos_Eternal_Revenge = CFrame.new(-371.428, 15.148, -1330.260)
local Pos_Eternal_Demon   = CFrame.new(-382.908, 15.561, -1327.481)
local Pos_Eternal_Altar   = CFrame.new(-367.265, 12.692, -1317.212)

local dropTarget_Eternal = Pos_Eternal_Trident

TabCraft:Button({
    Title = "传送到永恒剑祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Eternal_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达永恒剑祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择永恒剑材料位置",
    Values = {"三叉戟 (左)", "复仇剑 (中)", "恶魔鸭子 (右)"},
    Value = "三叉戟 (左)",
    Callback = function(opt)
        if opt == "三叉戟 (左)" then dropTarget_Eternal = Pos_Eternal_Trident
        elseif opt == "复仇剑 (中)" then dropTarget_Eternal = Pos_Eternal_Revenge
        elseif opt == "恶魔鸭子 (右)" then dropTarget_Eternal = Pos_Eternal_Demon end
    end
})

TabCraft:Button({
    Title = "获取【永恒剑空投工具】",
    Desc = "点击地上的物品直接瞬移入阵",
    Callback = function()
        if player.Backpack:FindFirstChild("空投工具(永恒)") or player.Character:FindFirstChild("空投工具(永恒)") then
            player.Backpack["空投工具(永恒)"]:Destroy()
        end
        
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(永恒)"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            local targetPart = Mouse.Target
            if not targetPart then return end
            local targetModel = targetPart.Parent
            
            if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
                for i = 1, 30 do
                    DragModel(targetModel, dropTarget_Eternal)
                    task.wait(0.01)
                end
                WindUI:Notify({ Title = "空投成功", Content = "已放入永恒剑祭坛", Duration = 2 })
            end
        end)
        WindUI:Notify({ Title = "获取成功", Content = "永恒工具已放入背包！", Duration = 3 })
    end
})

TabCraft:Button({
    Title = "一键全自动摆阵(永恒剑)",
    Desc = "自动吸附附近的物品",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local nearbyItems = {}
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local p = obj.PrimaryPart or (obj:IsA("Part") and obj)
                if p and (p.Position - hrp.Position).Magnitude < 20 then
                    if not obj:FindFirstChild("Humanoid") and obj.Name ~= "HumanoidRootPart" and not obj:FindFirstChild("TreeClass") then
                        table.insert(nearbyItems, obj)
                    end
                end
            end
        end
        
        if #nearbyItems >= 3 then
            WindUI:Notify({ Title = "扫描成功", Content = "正在强制吸附...", Duration = 3 })
            for i = 1, 15 do DragModel(nearbyItems[1], Pos_Eternal_Trident) task.wait(0.01) end
            for i = 1, 15 do DragModel(nearbyItems[2], Pos_Eternal_Revenge) task.wait(0.01) end
            for i = 1, 15 do DragModel(nearbyItems[3], Pos_Eternal_Demon) task.wait(0.01) end
            WindUI:Notify({ Title = "布阵完成", Content = "请检查祭坛是否触发", Duration = 4 })
        else
            WindUI:Notify({ Title = "失败", Content = "附近物品不足 3 个！", Duration = 4 })
        end
    end
})

TabCraft:Paragraph({
    Title = "【 复仇剑合成 】",
    Desc = "恶魔鸭子 / 天堂鸭子",
    Color = Color3.fromRGB(255, 0, 0)
})

local Pos_Revenge_Demon  = CFrame.new(6487.173, -92.148, -4551.805)
local Pos_Revenge_Heaven = CFrame.new(6448.009, -93.535, -4523.665)
local Pos_Revenge_Altar  = CFrame.new(6462.440, -94.916, -4543.508)

local dropTarget_Revenge = Pos_Revenge_Demon

TabCraft:Button({
    Title = "传送到复仇剑祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Revenge_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达复仇剑祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择复仇剑材料位置",
    Values = {"恶魔鸭子 (左/右)", "天堂鸭子 (右/左)"},
    Value = "恶魔鸭子 (左/右)",
    Callback = function(opt)
        if opt == "恶魔鸭子 (左/右)" then dropTarget_Revenge = Pos_Revenge_Demon
        elseif opt == "天堂鸭子 (右/左)" then dropTarget_Revenge = Pos_Revenge_Heaven end
    end
})

TabCraft:Button({
    Title = "获取【复仇剑空投工具】",
    Desc = "点击地上的物品直接瞬移入阵",
    Callback = function()
        if player.Backpack:FindFirstChild("空投工具(复仇)") or player.Character:FindFirstChild("空投工具(复仇)") then
            player.Backpack["空投工具(复仇)"]:Destroy()
        end
        
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(复仇)"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            local targetPart = Mouse.Target
            if not targetPart then return end
            local targetModel = targetPart.Parent
            
            if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
                for i = 1, 30 do
                    DragModel(targetModel, dropTarget_Revenge)
                    task.wait(0.01)
                end
                WindUI:Notify({ Title = "空投成功", Content = "已放入复仇剑祭坛", Duration = 2 })
            end
        end)
        WindUI:Notify({ Title = "获取成功", Content = "复仇工具已放入背包！", Duration = 3 })
    end
})

TabCraft:Button({
    Title = "一键全自动摆阵(复仇剑)",
    Desc = "自动吸附附近的物品 (仅需2个)",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local nearbyItems = {}
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local p = obj.PrimaryPart or (obj:IsA("Part") and obj)
                if p and (p.Position - hrp.Position).Magnitude < 20 then
                    if not obj:FindFirstChild("Humanoid") and obj.Name ~= "HumanoidRootPart" and not obj:FindFirstChild("TreeClass") then
                        table.insert(nearbyItems, obj)
                    end
                end
            end
        end
        
        if #nearbyItems >= 2 then
            WindUI:Notify({ Title = "扫描成功", Content = "正在强制吸附...", Duration = 3 })
            for i = 1, 15 do DragModel(nearbyItems[1], Pos_Revenge_Demon) task.wait(0.01) end
            for i = 1, 15 do DragModel(nearbyItems[2], Pos_Revenge_Heaven) task.wait(0.01) end
            WindUI:Notify({ Title = "布阵完成", Content = "请检查祭坛是否触发", Duration = 4 })
        else
            WindUI:Notify({ Title = "失败", Content = "附近物品不足 2 个！", Duration = 4 })
        end
    end
})

TabCraft:Paragraph({
    Title = "【 星星鸭子合成 】",
    Desc = "天堂鸭子 / 普通鸭子 / 恶魔鸭子",
    Color = Color3.fromRGB(200, 0, 255)
})

local Pos_StarDuck_Heaven = CFrame.new(-7041.764, 391.973, 4906.096)
local Pos_StarDuck_Normal = CFrame.new(-7066.685, 392.111, 4898.619)
local Pos_StarDuck_Demon  = CFrame.new(-7092.101, 392.085, 4890.774)
local Pos_StarDuck_Altar  = CFrame.new(-7064.089, 390.357, 4885.606)

local dropTarget_StarDuck = Pos_StarDuck_Heaven

TabCraft:Button({
    Title = "传送到星星鸭子祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_StarDuck_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达星星鸭子祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择星星鸭子材料位置",
    Values = {"天堂鸭子 (左)", "普通鸭子 (中)", "恶魔鸭子 (右)"},
    Value = "天堂鸭子 (左)",
    Callback = function(opt)
        if opt == "天堂鸭子 (左)" then dropTarget_StarDuck = Pos_StarDuck_Heaven
        elseif opt == "普通鸭子 (中)" then dropTarget_StarDuck = Pos_StarDuck_Normal
        elseif opt == "恶魔鸭子 (右)" then dropTarget_StarDuck = Pos_StarDuck_Demon end
    end
})

TabCraft:Button({
    Title = "获取【星星鸭子空投工具】",
    Desc = "点击地上的物品直接瞬移入阵",
    Callback = function()
        if player.Backpack:FindFirstChild("空投工具(星星)") or player.Character:FindFirstChild("空投工具(星星)") then
            player.Backpack["空投工具(星星)"]:Destroy()
        end
        
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(星星)"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            local targetPart = Mouse.Target
            if not targetPart then return end
            local targetModel = targetPart.Parent
            
            if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
                for i = 1, 30 do
                    DragModel(targetModel, dropTarget_StarDuck)
                    task.wait(0.01)
                end
                WindUI:Notify({ Title = "空投成功", Content = "已放入星星鸭子祭坛", Duration = 2 })
            end
        end)
        WindUI:Notify({ Title = "获取成功", Content = "星星工具已放入背包！", Duration = 3 })
    end
})

TabCraft:Button({
    Title = "一键全自动摆阵(星星鸭子)",
    Desc = "自动吸附附近的物品 (需3个)",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local nearbyItems = {}
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local p = obj.PrimaryPart or (obj:IsA("Part") and obj)
                if p and (p.Position - hrp.Position).Magnitude < 20 then
                    if not obj:FindFirstChild("Humanoid") and obj.Name ~= "HumanoidRootPart" and not obj:FindFirstChild("TreeClass") then
                        table.insert(nearbyItems, obj)
                    end
                end
            end
        end
        
        if #nearbyItems >= 3 then
            WindUI:Notify({ Title = "扫描成功", Content = "正在强制吸附...", Duration = 3 })
            for i = 1, 15 do DragModel(nearbyItems[1], Pos_StarDuck_Heaven) task.wait(0.01) end
            for i = 1, 15 do DragModel(nearbyItems[2], Pos_StarDuck_Normal) task.wait(0.01) end
            for i = 1, 15 do DragModel(nearbyItems[3], Pos_StarDuck_Demon) task.wait(0.01) end
            WindUI:Notify({ Title = "布阵完成", Content = "请检查祭坛是否触发", Duration = 4 })
        else
            WindUI:Notify({ Title = "失败", Content = "附近物品不足 3 个！", Duration = 4 })
        end
    end
})

TabCraft:Paragraph({
    Title = "【 地狱火合成 】",
    Desc = "三叉戟 / 恶魔鸭子",
    Color = Color3.fromRGB(255, 69, 0)
})

local Pos_Hellfire_Trident = CFrame.new(-1755.451, 346.302, 1478.264)
local Pos_Hellfire_Demon   = CFrame.new(-1785.906, 346.302, 1495.925)
local Pos_Hellfire_Altar   = CFrame.new(-1682.328, 349.602, 1477.501)

local dropTarget_Hellfire = Pos_Hellfire_Trident

TabCraft:Button({
    Title = "传送到地狱火祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Hellfire_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达地狱火祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择地狱火材料位置",
    Values = {"三叉戟 (左/右)", "恶魔鸭子 (右/左)"},
    Value = "三叉戟 (左/右)",
    Callback = function(opt)
        if opt == "三叉戟 (左/右)" then dropTarget_Hellfire = Pos_Hellfire_Trident
        elseif opt == "恶魔鸭子 (右/左)" then dropTarget_Hellfire = Pos_Hellfire_Demon end
    end
})

TabCraft:Button({
    Title = "获取【地狱火空投工具】",
    Desc = "点击地上的物品直接瞬移入阵",
    Callback = function()
        if player.Backpack:FindFirstChild("空投工具(地狱火)") or player.Character:FindFirstChild("空投工具(地狱火)") then
            player.Backpack["空投工具(地狱火)"]:Destroy()
        end
        
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(地狱火)"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            local targetPart = Mouse.Target
            if not targetPart then return end
            local targetModel = targetPart.Parent
            
            if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
                for i = 1, 30 do
                    DragModel(targetModel, dropTarget_Hellfire)
                    task.wait(0.01)
                end
                WindUI:Notify({ Title = "空投成功", Content = "已放入地狱火祭坛", Duration = 2 })
            end
        end)
        WindUI:Notify({ Title = "获取成功", Content = "地狱火工具已放入背包！", Duration = 3 })
    end
})

TabCraft:Button({
    Title = "一键全自动摆阵(地狱火)",
    Desc = "自动吸附附近的物品 (仅需2个)",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local nearbyItems = {}
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local p = obj.PrimaryPart or (obj:IsA("Part") and obj)
                if p and (p.Position - hrp.Position).Magnitude < 20 then
                    if not obj:FindFirstChild("Humanoid") and obj.Name ~= "HumanoidRootPart" and not obj:FindFirstChild("TreeClass") then
                        table.insert(nearbyItems, obj)
                    end
                end
            end
        end
        
        if #nearbyItems >= 2 then
            WindUI:Notify({ Title = "扫描成功", Content = "正在强制吸附...", Duration = 3 })
            for i = 1, 15 do DragModel(nearbyItems[1], Pos_Hellfire_Trident) task.wait(0.01) end
            for i = 1, 15 do DragModel(nearbyItems[2], Pos_Hellfire_Demon) task.wait(0.01) end
            WindUI:Notify({ Title = "布阵完成", Content = "请检查祭坛是否触发", Duration = 4 })
        else
            WindUI:Notify({ Title = "失败", Content = "附近物品不足 2 个！", Duration = 4 })
        end
    end
})

TabCraft:Paragraph({
    Title = "【 天堂光环合成 】",
    Desc = "天堂鸭子 / 永恒剑",
    Color = Color3.fromRGB(255, 255, 150)
})

TabCraft:Paragraph({
    Title = "⚠️ 前置任务提醒 ⚠️",
    Desc = "合成前，请先去【辐射商店】输入密码 444 把门打开！",
    Color = Color3.fromRGB(255, 0, 0)
})

local Pos_Halo_HeavenDuck  = CFrame.new(-678.179, 25.500, -404.403)
local Pos_Halo_EternalSword = CFrame.new(-680.807, 25.500, -413.101)
local Pos_Halo_Altar       = CFrame.new(-670.157, 21.800, -412.872)

local dropTarget_Halo = Pos_Halo_HeavenDuck

TabCraft:Button({
    Title = "传送到天堂光环祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Halo_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达天堂光环祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择天堂光环材料位置",
    Values = {"天堂鸭子 (左/右)", "永恒剑 (右/左)"},
    Value = "天堂鸭子 (左/右)",
    Callback = function(opt)
        if opt == "天堂鸭子 (左/右)" then dropTarget_Halo = Pos_Halo_HeavenDuck
        elseif opt == "永恒剑 (右/左)" then dropTarget_Halo = Pos_Halo_EternalSword end
    end
})

TabCraft:Button({
    Title = "获取【天堂光环空投工具】",
    Desc = "点击地上的物品直接瞬移入阵",
    Callback = function()
        if player.Backpack:FindFirstChild("空投工具(光环)") or player.Character:FindFirstChild("空投工具(光环)") then
            player.Backpack["空投工具(光环)"]:Destroy()
        end
        
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(光环)"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            local targetPart = Mouse.Target
            if not targetPart then return end
            local targetModel = targetPart.Parent
            
            if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
                for i = 1, 30 do
                    DragModel(targetModel, dropTarget_Halo)
                    task.wait(0.01)
                end
                WindUI:Notify({ Title = "空投成功", Content = "已放入天堂光环祭坛", Duration = 2 })
            end
        end)
        WindUI:Notify({ Title = "获取成功", Content = "光环工具已放入背包！", Duration = 3 })
    end
})

TabCraft:Button({
    Title = "一键全自动摆阵(天堂光环)",
    Desc = "自动吸附附近的物品 (仅需2个)",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local nearbyItems = {}
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local p = obj.PrimaryPart or (obj:IsA("Part") and obj)
                if p and (p.Position - hrp.Position).Magnitude < 20 then
                    if not obj:FindFirstChild("Humanoid") and obj.Name ~= "HumanoidRootPart" and not obj:FindFirstChild("TreeClass") then
                        table.insert(nearbyItems, obj)
                    end
                end
            end
        end
        
        if #nearbyItems >= 2 then
            WindUI:Notify({ Title = "扫描成功", Content = "正在强制吸附...", Duration = 3 })
            for i = 1, 15 do DragModel(nearbyItems[1], Pos_Halo_HeavenDuck) task.wait(0.01) end
            for i = 1, 15 do DragModel(nearbyItems[2], Pos_Halo_EternalSword) task.wait(0.01) end
            WindUI:Notify({ Title = "布阵完成", Content = "请检查祭坛是否触发", Duration = 4 })
        else
            WindUI:Notify({ Title = "失败", Content = "附近物品不足 2 个！", Duration = 4 })
        end
    end
})

TabCraft:Paragraph({
    Title = "【 天堂剑合成 】",
    Desc = "天堂光环 (雪山专属)",
    Color = Color3.fromRGB(255, 255, 255)
})

local Pos_HeavenSword_Halo = CFrame.new(1662.831, 402.424, 3280.203)
local Pos_HeavenSword_Altar = CFrame.new(1659.923, 399.730, 3273.653)

local dropTarget_HeavenSword = Pos_HeavenSword_Halo

TabCraft:Button({
    Title = "传送到雪山天堂剑祭坛",
    Desc = "瞬间移动到雪山合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_HeavenSword_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达天堂剑祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择天堂剑材料位置",
    Values = {"天堂光环 (指定点)"},
    Value = "天堂光环 (指定点)",
    Callback = function(opt)
        dropTarget_HeavenSword = Pos_HeavenSword_Halo
    end
})

TabCraft:Button({
    Title = "获取【天堂剑空投工具】",
    Desc = "点击地上的光环直接瞬移入阵",
    Callback = function()
        if player.Backpack:FindFirstChild("空投工具(天堂剑)") or player.Character:FindFirstChild("空投工具(天堂剑)") then
            player.Backpack["空投工具(天堂剑)"]:Destroy()
        end
        
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(天堂剑)"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            local targetPart = Mouse.Target
            if not targetPart then return end
            local targetModel = targetPart.Parent
            
            if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
                for i = 1, 30 do
                    DragModel(targetModel, dropTarget_HeavenSword)
                    task.wait(0.01)
                end
                WindUI:Notify({ Title = "空投成功", Content = "已放入天堂剑祭坛", Duration = 2 })
            end
        end)
        WindUI:Notify({ Title = "获取成功", Content = "天堂剑工具已放入背包！", Duration = 3 })
    end
})

TabCraft:Button({
    Title = "一键全自动摆阵(天堂剑)",
    Desc = "自动吸附附近的光环 (仅需1个)",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local nearbyItems = {}
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local p = obj.PrimaryPart or (obj:IsA("Part") and obj)
                if p and (p.Position - hrp.Position).Magnitude < 20 then
                    if not obj:FindFirstChild("Humanoid") and obj.Name ~= "HumanoidRootPart" and not obj:FindFirstChild("TreeClass") then
                        table.insert(nearbyItems, obj)
                    end
                end
            end
        end
        
        if #nearbyItems >= 1 then
            WindUI:Notify({ Title = "扫描成功", Content = "正在强制吸附...", Duration = 3 })
            for i = 1, 15 do DragModel(nearbyItems[1], Pos_HeavenSword_Halo) task.wait(0.01) end
            WindUI:Notify({ Title = "布阵完成", Content = "请检查祭坛是否触发", Duration = 4 })
        else
            WindUI:Notify({ Title = "失败", Content = "附近物品不足 1 个！", Duration = 4 })
        end
    end
})

local TimeLabel = TabCraft:Paragraph({
    Title = "【 月牙合成 (限定傍晚) 】",
    Desc = "正在读取游戏时间...",
    Color = Color3.fromRGB(255, 215, 0)
})

task.spawn(function()
    while task.wait(1) do
        local timeValue = Lighting.ClockTime
        local hour = math.floor(timeValue)
        local minute = math.floor((timeValue % 1) * 60)
        
        local timeStr = string.format("%02d:%02d", hour, minute)
        
        if timeValue >= 17 and timeValue <= 19 then
            TimeLabel:SetTitle("【 月牙合成 (限定傍晚) 】")
            TimeLabel:SetDesc("游戏当前时间：" .. timeStr .. " | 祭坛已出现！可以合成！")
            TimeLabel:SetColor(Color3.fromRGB(0, 255, 0))
        else
            TimeLabel:SetTitle("【 月牙合成 (限定傍晚) 】")
            TimeLabel:SetDesc("游戏当前时间：" .. timeStr .. " | 祭坛未出现，需等待 17:00")
            TimeLabel:SetColor(Color3.fromRGB(255, 100, 100))
        end
    end
end)

local Pos_Moon_HeavenSword = CFrame.new(1491.958, 415.623, 3322.311)
local Pos_Moon_Hellfire    = CFrame.new(1477.948, 415.623, 3327.516)
local Pos_Moon_Altar       = CFrame.new(1482.868, 413.256, 3318.388)

local dropTarget_Moon = Pos_Moon_HeavenSword

local function IsEvening()
    local clockTime = Lighting.ClockTime
    return clockTime >= 17 and clockTime <= 19
end

TabCraft:Button({
    Title = "传送到月牙祭坛",
    Desc = "瞬间移动过去 (仅限傍晚)",
    Callback = function()
        if not IsEvening() then
            WindUI:Notify({ 
                Title = "时间未到", 
                Content = "当前游戏时间不是傍晚 (17:00-19:00)，祭坛没有显现！", 
                Duration = 5 
            })
            return
        end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Moon_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达月牙祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择月牙材料位置",
    Values = {"天堂剑 (左/右)", "地狱火 (右/左)"},
    Value = "天堂剑 (左/右)",
    Callback = function(opt)
        if opt == "天堂剑 (左/右)" then dropTarget_Moon = Pos_Moon_HeavenSword
        elseif opt == "地狱火 (右/左)" then dropTarget_Moon = Pos_Moon_Hellfire end
    end
})

TabCraft:Button({
    Title = "获取【月牙空投工具】",
    Desc = "点击地上的物品直接瞬移入阵 (仅限傍晚)",
    Callback = function()
        if not IsEvening() then
            WindUI:Notify({ 
                Title = "拒绝提供工具", 
                Content = "游戏内当前时间：".. string.format("%.1f", Lighting.ClockTime) .."点，不是傍晚。请等到 17:00 再来！", 
                Duration = 5 
            })
            return
        end

        if player.Backpack:FindFirstChild("空投工具(月牙)") or player.Character:FindFirstChild("空投工具(月牙)") then
            player.Backpack["空投工具(月牙)"]:Destroy()
        end
        
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(月牙)"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            if not IsEvening() then
                WindUI:Notify({ Title = "时间过了", Content = "祭坛消失，物品无法放入！", Duration = 4 })
                return
            end
            
            local targetPart = Mouse.Target
            if not targetPart then return end
            local targetModel = targetPart.Parent
            
            if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
                for i = 1, 30 do
                    DragModel(targetModel, dropTarget_Moon)
                    task.wait(0.01)
                end
                WindUI:Notify({ Title = "空投成功", Content = "已放入月牙祭坛", Duration = 2 })
            end
        end)
        WindUI:Notify({ Title = "获取成功", Content = "当前是傍晚，月牙工具已放入背包！", Duration = 3 })
    end
})

TabCraft:Button({
    Title = "一键全自动摆阵(月牙)",
    Desc = "自动吸附附近的物品 (仅限傍晚)",
    Callback = function()
        if not IsEvening() then
            WindUI:Notify({ Title = "时间未到", Content = "游戏内当前不是傍晚，请等待！", Duration = 4 })
            return
        end
        
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local nearbyItems = {}
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local p = obj.PrimaryPart or (obj:IsA("Part") and obj)
                if p and (p.Position - hrp.Position).Magnitude < 20 then
                    if not obj:FindFirstChild("Humanoid") and obj.Name ~= "HumanoidRootPart" and not obj:FindFirstChild("TreeClass") then
                        table.insert(nearbyItems, obj)
                    end
                end
            end
        end
        
        if #nearbyItems >= 2 then
            WindUI:Notify({ Title = "扫描成功", Content = "正在强制吸附...", Duration = 3 })
            for i = 1, 15 do DragModel(nearbyItems[1], Pos_Moon_HeavenSword) task.wait(0.01) end
            for i = 1, 15 do DragModel(nearbyItems[2], Pos_Moon_Hellfire) task.wait(0.01) end
            WindUI:Notify({ Title = "布阵完成", Content = "请检查祭坛是否触发", Duration = 4 })
        else
            WindUI:Notify({ Title = "失败", Content = "附近物品不足 2 个！", Duration = 4 })
        end
    end
})

TabCraft:Paragraph({
    Title = "【 月神剑合成 】",
    Desc = "月牙 (指定位置)",
    Color = Color3.fromRGB(200, 200, 255)
})

local Pos_MoonSword_Crescent = CFrame.new(-7648.661, 322.803, 4233.530)
local Pos_MoonSword_Altar    = CFrame.new(-7642.798, 320.995, 4227.344)

local dropTarget_MoonSword = Pos_MoonSword_Crescent

TabCraft:Button({
    Title = "传送到月神剑祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_MoonSword_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达月神剑祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择月神剑材料位置",
    Values = {"月牙 (指定点)"},
    Value = "月牙 (指定点)",
    Callback = function(opt)
        dropTarget_MoonSword = Pos_MoonSword_Crescent
    end
})

TabCraft:Button({
    Title = "获取【月神剑空投工具】",
    Desc = "点击地上的月牙直接瞬移入阵",
    Callback = function()
        if player.Backpack:FindFirstChild("空投工具(月神剑)") or player.Character:FindFirstChild("空投工具(月神剑)") then
            player.Backpack["空投工具(月神剑)"]:Destroy()
        end
        
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(月神剑)"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            local targetPart = Mouse.Target
            if not targetPart then return end
            local targetModel = targetPart.Parent
            
            if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
                for i = 1, 30 do
                    DragModel(targetModel, dropTarget_MoonSword)
                    task.wait(0.01)
                end
                WindUI:Notify({ Title = "空投成功", Content = "已放入月神剑祭坛", Duration = 2 })
            end
        end)
        WindUI:Notify({ Title = "获取成功", Content = "月神剑工具已放入背包！", Duration = 3 })
    end
})

TabCraft:Button({
    Title = "一键全自动摆阵(月神剑)",
    Desc = "自动吸附附近的月牙 (仅需1个)",
    Callback = function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local nearbyItems = {}
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local p = obj.PrimaryPart or (obj:IsA("Part") and obj)
                if p and (p.Position - hrp.Position).Magnitude < 20 then
                    if not obj:FindFirstChild("Humanoid") and obj.Name ~= "HumanoidRootPart" and not obj:FindFirstChild("TreeClass") then
                        table.insert(nearbyItems, obj)
                    end
                end
            end
        end
        
        if #nearbyItems >= 1 then
            WindUI:Notify({ Title = "扫描成功", Content = "正在强制吸附...", Duration = 3 })
            for i = 1, 15 do DragModel(nearbyItems[1], Pos_MoonSword_Crescent) task.wait(0.01) end
            WindUI:Notify({ Title = "布阵完成", Content = "请检查祭坛是否触发", Duration = 4 })
        else
            WindUI:Notify({ Title = "失败", Content = "附近物品不足 1 个！", Duration = 4 })
        end
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
local selectedObjects = {}

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
                        task.wait()
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

TabItem:Paragraph({
    Title = "【 多选批量传送 】",
    Desc = "使用工具点击物品进行多选，然后一键传送",
    Color = Color3.fromRGB(0, 150, 255)
})

TabItem:Button({
    Title = "获取【多选框选工具】",
    Desc = "点击物品添加蓝框，再次点击取消",
    Callback = function()
        if player.Backpack:FindFirstChild("多选框选工具") or player.Character:FindFirstChild("多选框选工具") then
            player.Backpack["多选框选工具"]:Destroy()
        end
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
                        if targetPart:FindFirstChild("BlueSelectBox") then
                            targetPart.BlueSelectBox:Destroy()
                        elseif targetModel:FindFirstChild("BlueSelectBox") then
                            targetModel.BlueSelectBox:Destroy()
                        end
                        WindUI:Notify({ Title = "取消选中", Content = targetModel.Name, Duration = 2 })
                        break
                    end
                end
                
                if not isSelected then
                    table.insert(selectedObjects, targetModel)
                    local box = Instance.new("SelectionBox")
                    box.Name = "BlueSelectBox"
                    box.Adornee = targetModel
                    box.Color3 = Color3.fromRGB(0, 150, 255)
                    box.LineThickness = 
                    box.Parent = targetModel
                    WindUI:Notify({ Title = "已选中", Content = targetModel.Name, Duration = 2 })
                end
            end
        end)
        WindUI:Notify({ Title = "成功", Content = "多选框选工具已放入背包", Duration = 3 })
    end
})

TabItem:Button({
    Title = "清除所有选中(蓝框)",
    Callback = function()
        for i = #selectedObjects, 1, -1 do
            local obj = selectedObjects[i]
            if obj then
                if obj:FindFirstChild("BlueSelectBox") then
                    obj.BlueSelectBox:Destroy()
                end
                table.remove(selectedObjects, i)
            end
        end
        WindUI:Notify({ Title = "已清空", Content = "所有选中的物品已取消", Duration = 3 })
    end
})

TabItem:Button({
    Title = "【一键传送所有选中物品】",
    Desc = "将所有蓝框物品拉到选定的拉回点位",
    Callback = function()
        if not Workspace:FindFirstChild(selectedBringTarget) then
            WindUI:Notify({ Title = "错误", Content = "请先设置拉回点位", Duration = 3 })
            return
        end
        
        local targetCFrame = Workspace[selectedBringTarget].CFrame
        local count = 0
        
        for i = #selectedObjects, 1, -1 do
            local obj = selectedObjects[i]
            if obj and obj.Parent then
                for j = 1, 40 do
                    DragModel(obj, targetCFrame)
                    task.wait(0.1)
                end
                if obj:FindFirstChild("BlueSelectBox") then
                    obj.BlueSelectBox:Destroy()
                end
                table.remove(selectedObjects, i)
                count = count + 1
            else
                table.remove(selectedObjects, i)
            end
        end
        
        WindUI:Notify({ Title = "传送完毕", Content = "成功传送了 "..count.." 个物品", Duration = 3 })
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
    Desc = "经典底层重连法",
    Callback = function()
        local TS = game:GetService("TeleportService")
        local success, err = pcall(function()
            if game.PrivateServerId and game.PrivateServerId ~= "" then
                TS:TeleportToPrivateServer(game.PlaceId, game.PrivateServerId, {player})
            else
                TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            end
        end)
        if not success then
            WindUI:Notify({ Title = "传送失败", Content = "请稍等10秒后再试 (773防刷限制)", Duration = 5 })
        end
    end
})

TabServer:Button({
    Title = "指定服务器换服",
    Desc = "需在上方填写 PlaceId，精准抓取新服",
    Callback = function()
        local TS = game:GetService("TeleportService")
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
    Desc = "使用官方API获取真实JobId，秒进",
    Callback = function()
        local TS = game:GetService("TeleportService")
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
    Desc = "如果遇到卡顿，点此强行断开",
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
    Desc = "关闭UI并清除所有残留工具与点位",
    Callback = function()
        CleanupAll()
    end
})