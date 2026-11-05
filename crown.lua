local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "木材大亨 - 传送黑洞版",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(450, 450),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "自动化控制", Icon = "rbxassetid://10734898355" })
local Tab2 = Window:Tab({ Title = "传送功能", Icon = "rbxassetid://10734903245" })

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local isRunning = false
local originPosition = nil
local targetTreeName = "TreeModel"
local maxChopCount = 1
local currentChopCount = 0
local currentCoroutine = nil
local choppedTrees = {}

local TP_Position = nil
local TP_Ball = nil
local TP_Mode_Enabled = false

local StatusLabel = Tab:Paragraph({
    Title = "实时状态",
    Desc = "等待操作...",
    Color = "Red"
})

local TP_StatusLabel = Tab2:Paragraph({
    Title = "传送状态",
    Desc = "未设置目标点",
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

Tab2:Button({
    Title = "1. 设置传送目标点 (以躯干为中心)",
    Desc = "在脚下生成发光标记",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            TP_Position = hrp.Position - Vector3.new(0, 2.5, 0) 
            TP_StatusLabel:SetTitle("传送点已设置")
            TP_StatusLabel:SetDesc("坐标: " .. math.floor(TP_Position.X) .. ", " .. math.floor(TP_Position.Z))
            TP_StatusLabel:SetColor("Green")
            
            if TP_Ball then TP_Ball:Destroy() end
            
            TP_Ball = Instance.new("Part")
            TP_Ball.Name = "LocalTPMarker"
            TP_Ball.Shape = Enum.PartType.Ball
            TP_Ball.Size = Vector3.new(4, 4, 4)
            TP_Ball.Position = TP_Position
            TP_Ball.Material = Enum.Material.Neon
            TP_Ball.Color = Color3.fromRGB(0, 255, 0)
            TP_Ball.Anchored = true
            TP_Ball.CanCollide = false
            TP_Ball.Transparency = 0.3
            TP_Ball.Parent = workspace
            
            WindUI:Notify({ Title = "成功", Content = "传送点已设置，并显示绿球", Duration = 3 })
        end
    end
})
local function safeReturn()
    if originPosition and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = originPosition
        player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end
end

local function moveObjToTP(obj)
    if not TP_Position then return end
    local root = obj
    if obj:IsA("Model") then
        root = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    if root and root:IsA("BasePart") then
        pcall(function()
            if not obj:IsA("Model") then
                obj.Anchored = false
                obj.CanCollide = false
                obj.CFrame = CFrame.new(TP_Position + Vector3.new(math.random(-3,3), 3, math.random(-3,3)))
            else
                obj:PivotTo(CFrame.new(TP_Position + Vector3.new(math.random(-3,3), 3, math.random(-3,3))))
                for _, p in pairs(obj:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Anchored = false
                        p.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function getItemsToTeleport()
    local count = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local objNameLower = string.lower(obj.Name)
            if (string.find(objNameLower, "log") or string.find(objNameLower, "wood") or string.find(objNameLower, "plank")) 
               and obj.Name ~= "WoodRUs" and obj.Name ~= "WOODDROPOFF" and obj.Name ~= "LocalTPMarker" then
                
                local dist = 9999
                local p = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj)
                if p then
                    dist = (p.Position - player.Character.HumanoidRootPart.Position).Magnitude
                end
                
                if dist < 150 then
                    moveObjToTP(obj)
                    count = count + 1
                end
            end
        end
    end
    return count
end

Tab2:Button({
    Title = "2. 一键吸取附近木头到目标点",
    Callback = function()
        if not TP_Position then
            WindUI:Notify({ Title = "警告", Content = "请先设置传送目标点！", Duration = 3 })
            return
        end
        local c = getItemsToTeleport()
        WindUI:Notify({ Title = "吸取完成", Content = "已传送 " .. c .. " 个物品到绿球处", Duration = 3 })
    end
})

Tab2:Toggle({
    Title = "3. 开启点击传送魔杖",
    Desc = "拿着斧头指着零件点一下，它就会飞向绿球",
    Default = false,
    Callback = function(state)
        TP_Mode_Enabled = state
        if state and not TP_Position then
            WindUI:Notify({ Title = "警告", Content = "请先设置目标点！", Duration = 3 })
            TP_Mode_Enabled = false
        end
    end
})

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if TP_Mode_Enabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local target = player:GetMouse().Target
        if target and target.Name ~= "LocalTPMarker" and not target:IsDescendantOf(player.Character) then
            moveObjToTP(target)
            WindUI:Notify({ Title = "魔杖生效", Content = "已将 " .. target.Name .. " 传送", Duration = 2 })
        end
    end
end)

local function MainLoop()
    currentChopCount = 0
    choppedTrees = {}
    while isRunning do
        task.wait(0.3)
        if not isRunning then break end
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart
        local proxy = rs:FindFirstChild("Interaction") and rs.Interaction:FindFirstChild("RemoteProxy")
        local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
        if not proxy or not tool then continue end

        local targetTree = nil
        local targetPart = nil
        local logModels = workspace:FindFirstChild("LogModels")
        if logModels then
            for _, obj in pairs(logModels:GetChildren()) do
                if obj.Name == targetTreeName and obj:FindFirstChild("CutEvent") then
                    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj)
                    if part then
                        local posStr = tostring(math.floor(part.Position.X)) .. "_" .. tostring(math.floor(part.Position.Z))
                        if not choppedTrees[posStr] then
                            targetTree = obj
                            targetPart = part
                            break
                        end
                    end
                end
            end
        end
        
        if not targetTree then
            StatusLabel:SetTitle("⚠️ 没找到 " .. targetTreeName)
            StatusLabel:SetDesc("请往前走加载新树")
            task.wait(1.5)
            continue
        end

        StatusLabel:SetTitle("⚡ 正在砍树: " .. currentChopCount .. "/" .. maxChopCount)
        local treePos = targetPart.Position
        choppedTrees[tostring(math.floor(treePos.X)) .. "_" .. tostring(math.floor(treePos.Z))] = true
        
        hrp.CFrame = CFrame.lookAt(treePos + Vector3.new(3, 3, 3), treePos)
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        task.wait(0.15)

        local args = {
            targetTree:FindFirstChild("CutEvent"),
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
        task.wait(0.5)
        currentChopCount = currentChopCount + 1

        if currentChopCount >= maxChopCount then
            isRunning = false
            safeReturn()
            task.wait(0.5)
            
            -- 如果设置了传送点，砍完自动传送过去；否则传回原点
            if TP_Position then
                getItemsToTeleport()
                StatusLabel:SetTitle("✅ 砍伐完成，物品已传送至目标点")
            else
                StatusLabel:SetTitle("✅ 砍伐完成")
            end
            break
        end
    end
end

Tab:Button({
    Title = "2. 开始自动砍树",
    Callback = function()
        if not originPosition then return end
        if isRunning then return end
        isRunning = true
        currentCoroutine = coroutine.wrap(function()
            local success, err = pcall(MainLoop)
            if not success then isRunning = false safeReturn() end
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