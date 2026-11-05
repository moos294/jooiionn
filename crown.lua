local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "木材大亨 - 极限贴地版",
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
local targetTreeName = "TreeModel"
local maxChopCount = 1
local currentChopCount = 0
local currentCoroutine = nil

local StatusLabel = Tab:Paragraph({
    Title = "实时状态",
    Desc = "等待操作...",
    Color = "Red"
})

local treeOptions = {"Loose_Koa", "DogWood", "TreeModel", "GlobeWood", "TreeRegion", "Tree", "PumpkinWood", "AppleTree", "oak"}

Tab:Dropdown({
    Title = "选择树木",
    Values = treeOptions,
    Default = treeOptions[3],
    Callback = function(option)
        targetTreeName = option
    end
})
targetTreeName = treeOptions[3]

Tab:Slider({
    Title = "砍伐数量",
    Value = { Min = 1, Max = 30, Default = 1 },
    Callback = function(value) maxChopCount = value end
})

Tab:Button({
    Title = "1. 记录原点坐标",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            originPosition = player.Character.HumanoidRootPart.CFrame
            StatusLabel:SetTitle("状态: 原点已记录")
            WindUI:Notify({ Title = "成功", Content = "原点记录成功", Duration = 3 })
        end
    end
})

local function safeReturn()
    if originPosition and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = originPosition
        player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end
end
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
            StatusLabel:SetTitle("错误: 斧头不在手")
            task.wait(1)
            continue 
        end

        local targetTree = nil
        local logModels = workspace:FindFirstChild("LogModels")
        
        if logModels then
            for _, obj in pairs(logModels:GetChildren()) do
                if obj.Name == targetTreeName and obj:FindFirstChild("CutEvent") then
                    targetTree = obj
                    break
                end
            end
        end
        
        if not targetTree then
            StatusLabel:SetTitle("⚠️ 没找到 " .. targetTreeName)
            StatusLabel:SetDesc("请往前走两步加载")
            task.wait(1.5)
            continue
        end

        StatusLabel:SetTitle("⚡ 正在瞬移砍树: " .. currentChopCount .. "/" .. maxChopCount)
        
        local targetPart = nil
        if targetTree:IsA("Model") then
            targetPart = targetTree.PrimaryPart or targetTree:FindFirstChildWhichIsA("BasePart")
        elseif targetTree:IsA("BasePart") then
            targetPart = targetTree
        end

        local treePos = targetPart and targetPart.Position or (targetTree:IsA("Model") and targetTree:GetPivot().Position)
        
        if treePos then
            local safeCFrame = CFrame.lookAt(treePos + Vector3.new(3, 3, 3), treePos)
            hrp.CFrame = safeCFrame
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            task.wait(0.15)

            local cutEvent = targetTree:FindFirstChild("CutEvent")
            local args = {
                cutEvent,
                {
                    height = 2.1333739161491394,
                    faceVector = Vector3.new(-1, 0, 0),
                    cooldown = -0.10668772220611572,
                    sectionId = 5,
                    hitPoints = 18000,
                    tool = tool,
                    cuttingClass = "Axe"
                }
            }
            
            pcall(function() proxy:FireServer(unpack(args)) end)
            task.wait(0.4)
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name ~= targetTreeName and obj.Name ~= "WoodRUs" then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist < 60 then
                        pcall(function()
                            obj.Anchored = false 
                            obj.CanCollide = false
                            obj:SetNetworkOwner(player) 
                            obj.CFrame = hrp.CFrame * CFrame.new(math.random(-2,2), -2, math.random(-2,2))
                        end)
                    end
                end
            end

            currentChopCount = currentChopCount + 1
        end
        
        if currentChopCount >= maxChopCount then
            isRunning = false
            safeReturn()
            StatusLabel:SetTitle("✅ 状态: 砍伐完成，已返回原点")
            break
        end
    end
end

Tab:Button({
    Title = "2. 开始自动砍树",
    Callback = function()
        if not originPosition then
            WindUI:Notify({ Title = "警告", Content = "请先记录原点！", Duration = 3 })
            return
        end
        if isRunning then return end
        
        isRunning = true
        currentCoroutine = coroutine.wrap(function()
            local success, err = pcall(MainLoop)
            if not success then
                isRunning = false
                safeReturn()
            end
        end)
        currentCoroutine()
    end
})

Tab:Button({
    Title = "3. 停止并返回原点",
    Callback = function()
        if isRunning then
            isRunning = false
            safeReturn()
            StatusLabel:SetTitle("🛑 状态: 已停止")
        end
    end
})