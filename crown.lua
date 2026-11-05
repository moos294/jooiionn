local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "真·逻辑传送",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(400, 300),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "物品传送", Icon = "rbxassetid://10734898355" })
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

local TP_Position = nil
local TP_Ball = nil

Tab:Button({
    Title = "1. 设置当前身体位置为目标点",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            TP_Position = hrp.Position
            
            if TP_Ball then TP_Ball:Destroy() end
            
            TP_Ball = Instance.new("Part")
            TP_Ball.Name = "LocalTPMarker"
            TP_Ball.Shape = Enum.PartType.Ball
            TP_Ball.Size = Vector3.new(1, 1, 1)
            TP_Ball.Position = TP_Position
            TP_Ball.Material = Enum.Material.SmoothPlastic
            TP_Ball.Color = Color3.fromRGB(0, 255, 0)
            TP_Ball.Anchored = true
            TP_Ball.CanCollide = false
            TP_Ball.CanQuery = false
            TP_Ball.CastShadow = false
            TP_Ball.Transparency = 0.3
            TP_Ball.Parent = workspace
            
            WindUI:Notify({ Title = "成功", Content = "坐标已设置！", Duration = 3 })
        end
    end
})

Tab:Button({
    Title = "2. 获得隐身传送魔杖",
    Callback = function()
        if player.Backpack:FindFirstChild("传送魔杖") or (player.Character and player.Character:FindFirstChild("传送魔杖")) then return end
        local tool = Instance.new("Tool")
        tool.Name = "传送魔杖"
        tool.RequiresHandle = true
        tool.CanBeDropped = false
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.1, 0.1, 0.1)
        handle.Transparency = 1
        handle.CanCollide = false
        handle.Parent = tool
        tool.Parent = player.Backpack
    end
})

local function isStrictlyMovableItem(obj)
    if obj:IsA("Terrain") then return false end
    if obj.Name == "LocalTPMarker" then return false end
    if obj:IsDescendantOf(player.Character) then return false end
    if obj.Parent == workspace then return false end
    
    local current = obj
    for i = 1, 5 do
        if current == workspace or current == nil then break end
        if current:FindFirstChild("CutEvent") then return false end
        if current:FindFirstChildOfClass("Humanoid") then return false end
        current = current.Parent
    end
    
    local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Tool") and obj:FindFirstChild("Handle")) or obj:FindFirstChildWhichIsA("BasePart")
    if targetPart and (targetPart.Size.X > 15 or targetPart.Size.Y > 15 or targetPart.Size.Z > 15) then
        return false
    end
    
    return true 
end

local function realTeleport(obj)
    if not TP_Position then 
        WindUI:Notify({ Title = "警告", Content = "请先设置目标点！", Duration = 3 })
        return 
    end
    
    if obj:IsA("Tool") then
        obj.Parent = player.Backpack
        WindUI:Notify({ Title = "成功", Content = "工具已入包", Duration = 2 })
        return
    end

    -- 锁定模型
    local targetModel = obj:IsA("Model") and obj or obj:FindFirstChildOfClass("Model")
    if not targetModel then targetModel = obj end 
    
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local oldCFrame = hrp.CFrame

    local primaryPart = targetModel:IsA("BasePart") and targetModel or targetModel.PrimaryPart or targetModel:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then return end
    targetModel.PrimaryPart = primaryPart

    local success = pcall(function()
        -- 1. 原版最核心逻辑：强行移动到物品中心点抢夺控制权！
        char:MoveTo(primaryPart.CFrame.p)
        task.wait(0.2) -- 给服务器一点反应时间

        -- 2. 解除所有物理锁定
        if targetModel:IsA("Model") then
            for _, p in pairs(targetModel:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                elseif p:IsA("Weld") or p:IsA("WeldConstraint") or p:IsA("JointInstance") then
                    p:Destroy()
                end
            end
        else
            targetModel.Anchored = false
        end
        
        -- 3. 目标坐标（稍微偏移，防止直接卡进绿球）
        local finalCFrame = CFrame.new(TP_Position + Vector3.new(0, 2, 0))
        
        -- 4. 原版高频抢占循环
        for i = 1, 60 do
            pcall(function()
                RS.Interaction.ClientIsDragging:FireServer(targetModel)
            end)
            
            if primaryPart then
                primaryPart.Velocity = Vector3.new(0, 0, 0)
            end
            
            if targetModel:IsA("Model") then
                targetModel:SetPrimaryPartCFrame(finalCFrame)
            else
                targetModel.CFrame = finalCFrame
            end
            
            -- 每次循环把本体拉回原位，假装什么都没发生
            hrp.CFrame = oldCFrame
            
            task.wait(0.02)
        end
    end)
    
    if success then
        WindUI:Notify({ Title = "传送成功", Content = "物品已实体化传送！", Duration = 2 })
    else
        WindUI:Notify({ Title = "失败", Content = "被服务器拒绝", Duration = 3 })
    end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local char = player.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        
        if tool and tool.Name == "传送魔杖" then
            local camera = workspace.CurrentCamera
            local unitRay = camera:ViewportPointToRay(input.Position.X, input.Position.Y)
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {player.Character, TP_Ball}
            
            local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 200, rayParams)
            local target = result and result.Instance
            
            if target then
                if isStrictlyMovableItem(target) then
                    realTeleport(target)
                else
                    WindUI:Notify({ Title = "拒绝", Content = "该物体不可移动！", Duration = 2 })
                end
            end
        end
    end
end)