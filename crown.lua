local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "木材大亨 - 全图加载版",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(450, 420),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "自动化控制", Icon = "rbxassetid://10734898355" })

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")

local isRunning = false
local originPosition = nil
local targetTreeName = "Loose_Koa"
local maxChopCount = 1
local currentChopCount = 0
local currentCoroutine = nil

pcall(function()
    workspace.StreamingEnabled = false
    workspace.StreamingTargetRadius = 100000
    workspace.StreamingMinRadius = 100000
end)

local StatusLabel = Tab:Paragraph({
    Title = "实时状态",
    Desc = "等待操作...",
    Color = "Red"
})

local treeOptions = {
    "Loose_Koa", "DogWood", "TreeModel", "GlobeWood", 
    "TreeRegion", "Tree", "Region_SideTrees", "PumpkinWood", 
    "AppleTree", "oak", "Wood", "InnerWood", "WoodBox", "Plank"
}

Tab:Dropdown({
    Title = "选择树木",
    Desc = "已写入全部名单",
    Values = treeOptions,
    Default = treeOptions[1],
    Callback = function(option)
        targetTreeName = option
    end
})
targetTreeName = treeOptions[1]

Tab:Slider({
    Title = "砍伐数量",
    Value = { Min = 1, Max = 30, Default = 1 },
    Callback = function(value) maxChopCount = value end
})

Tab:Button({
    Title = "1. 记录原点坐标",
    Desc = "设置挂机/休息的位置",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            originPosition = player.Character.HumanoidRootPart.CFrame
            StatusLabel:SetTitle("状态: 原点已记录")
            WindUI:Notify({ Title = "成功", Content = "原点记录成功", Duration = 3 })
        end
    end
})
local function MainLoop()
    currentChopCount = 0
    
    while isRunning do
        task.wait(0.3)
        if not isRunning then break end
        
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart

        local proxy = rs:FindFirstChild("Interaction") and rs.Interaction:FindFirstChild("RemoteProxy")
        local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
        
        if not proxy or not tool then 
            StatusLabel:SetTitle("错误: 请确保斧头在手")
            continue 
        end

        local targetTree = nil
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == targetTreeName and obj:FindFirstChild("CutEvent") then
                targetTree = obj
                break
            end
        end
        
        if not targetTree then
            StatusLabel:SetTitle("⚠️ 全图搜索未找到 " .. targetTreeName)
            StatusLabel:SetDesc("可能这棵树在地图边缘未生成")
            task.wait(1)
            continue
        end

        StatusLabel:SetTitle("⚡ 正在瞬移砍树: " .. currentChopCount .. "/" .. maxChopCount)
        StatusLabel:SetDesc("目标: " .. targetTreeName)

        local treePos = targetTree:IsA("Model") and targetTree:GetPivot().Position or targetTree.Position
        local cutEvent = targetTree:FindFirstChild("CutEvent")

        hrp.CFrame = CFrame.new(treePos + Vector3.new(0, 3, 0))
        task.wait(0.15)

        local args = {
            cutEvent,
            {
                height = math.random(1, 10),
                faceVector = Vector3.new(-1, 0, 0),
                cooldown = 0.1,
                sectionId = math.random(1, 10),
                hitPoints = 18000,
                tool = tool,
                cuttingClass = "Axe"
            }
        }
        
        pcall(function() proxy:FireServer(unpack(args)) end)
        task.wait(0.3)
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local objName = string.lower(obj.Name)
                if (string.find(objName, "log") or string.find(objName, "wood") or string.find(objName, "plank")) and obj.Name ~= "WOODDROPOFF" and obj.Name ~= "WoodRUs" then
                    pcall(function()
                        if obj:IsA("Model") then obj:PivotTo(hrp.CFrame * CFrame.new(0, -2, 0))
                        else obj.CFrame = hrp.CFrame * CFrame.new(0, -2, 0) end
                    end)
                end
            end
        end

        currentChopCount = currentChopCount + 1
        
        if currentChopCount >= maxChopCount then
            isRunning = false
            if originPosition then hrp.CFrame = originPosition end
            StatusLabel:SetTitle("✅ 状态: 砍伐完成，已返回原点")
            WindUI:Notify({ Title = "完成", Content = "任务结束，已返回原点", Duration = 5 })
            break
        end
    end
end

Tab:Button({
    Title = "2. 开始自动砍树",
    Desc = "强行全图拉取，直接瞬移",
    Callback = function()
        if not originPosition then
            WindUI:Notify({ Title = "警告", Content = "请先记录原点坐标！", Duration = 3 })
            return
        end
        if isRunning then return end
        
        isRunning = true
        StatusLabel:SetTitle("状态: 开始全图搜索...")
        
        currentCoroutine = coroutine.wrap(function()
            local success, err = pcall(MainLoop)
            if not success then
                WindUI:Notify({ Title = "错误", Content = tostring(err), Duration = 10 })
                isRunning = false
            end
        end)
        currentCoroutine()
    end
})

Tab:Button({
    Title = "3. 强制停止并返回原点",
    Desc = "立即中断并回到记录点",
    Callback = function()
        if isRunning then
            isRunning = false
            if originPosition and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = originPosition
            end
            StatusLabel:SetTitle("🛑 状态: 已强制停止")
            StatusLabel:SetColor("Red")
            WindUI:Notify({ Title = "已停止", Content = "任务中断，已返回原点", Duration = 3 })
        end
    end
})