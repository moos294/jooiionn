local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "木材大亨 - 精准瞬移版",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(450, 400),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "自动化控制", Icon = "rbxassetid://10734898355" })

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")

local isRunning = false
local basePosition = nil
local targetTreeName = "Loose_Koa"
local maxChopCount = 1
local currentChopCount = 0

local StatusLabel = Tab:Paragraph({
    Title = "实时状态",
    Desc = "等待开启..."
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
    Title = "记录基地坐标",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            basePosition = player.Character.HumanoidRootPart.CFrame
            StatusLabel:SetTitle("状态: 基地已记录")
            WindUI:Notify({ Title = "成功", Content = "坐标记录成功", Duration = 3 })
        end
    end
})
local function MainLoop()
    currentChopCount = 0
    
    while isRunning do
        task.wait(0.3)
        
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
        local logModels = workspace:FindFirstChild("LogModels")
        
        -- 精准在 LogModels 里找树（减少遍历，防卡顿）
        if logModels then
            for _, obj in pairs(logModels:GetChildren()) do
                if obj.Name == targetTreeName and obj:FindFirstChild("CutEvent") then
                    targetTree = obj
                    break
                end
            end
        end
        
        if not targetTree then
            -- 内存里没有就不动，绝对不乱跳
            StatusLabel:SetTitle("⚠️ 内存中没找到 " .. targetTreeName)
            StatusLabel:SetDesc("请往前走几步，等树加载出来")
            task.wait(1)
            continue
        end

        StatusLabel:SetTitle("⚡ 已锁定，正在瞬移...")
        StatusLabel:SetDesc("目标: " .. targetTreeName)

        local treePos = targetTree:IsA("Model") and targetTree:GetPivot().Position or targetTree.Position
        local cutEvent = targetTree:FindFirstChild("CutEvent")

        -- 直接瞬移到树根部
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
        
        -- 木头直接传送到脚下
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
        StatusLabel:SetTitle("✅ 砍伐进度: " .. currentChopCount .. "/" .. maxChopCount)
        
        -- 砍够了回城
        if currentChopCount >= maxChopCount then
            isRunning = false
            if basePosition then hrp.CFrame = basePosition end
            StatusLabel:SetTitle("状态: 已回城")
            WindUI:Notify({ Title = "完成", Content = "任务结束", Duration = 5 })
            
            local toggleObj = Window:GetToggle("开启自动收割")
            if toggleObj then toggleObj:Set(false) end
            break
        end
    end
end

Tab:Toggle({
    Title = "开启自动收割",
    Default = false,
    Callback = function(state)
        isRunning = state
        if isRunning then
            if not basePosition and player.Character then
                basePosition = player.Character.HumanoidRootPart.CFrame
            end
            
            coroutine.wrap(function()
                local success, err = pcall(MainLoop)
                if not success then
                    WindUI:Notify({ Title = "错误", Content = tostring(err), Duration = 10 })
                end
            end)()
        end
    end
})