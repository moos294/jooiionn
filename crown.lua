local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "传送系统",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(400, 300),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "真实传送", Icon = "rbxassetid://10734898355" })
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local TP_Position = nil
local TP_Ball = nil

Tab:Button({
    Title = "1. 设置绿球坐标",
    Desc = "物品会真实传送到这里",
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
    Title = "2. 获得隐身魔杖",
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

local function trueTeleport(obj)
    if not TP_Position then 
        WindUI:Notify({ Title = "警告", Content = "请先设置绿球坐标！", Duration = 3 })
        return 
    end
    
    local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Tool") and obj:FindFirstChild("Handle")) or obj:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end
    
    local success = pcall(function()
        if obj:IsA("Tool") then
            obj.Parent = player.Backpack
            WindUI:Notify({ Title = "抓取成功", Content = "工具已收入背包", Duration = 2 })
            return
        end

        -- 暴力解除锚定、移除所有物理限制（比如传送带上的焊接）
        if obj:IsA("Model") then
            for _, p in pairs(obj:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    p.CanCollide = true
                elseif p:IsA("Weld") or p:IsA("WeldConstraint") or p:IsA("JointInstance") then
                    p:Destroy()
                end
            end
        elseif obj:IsA("BasePart") then
            obj.Anchored = false
            obj.CanCollide = true
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("Weld") or child:IsA("WeldConstraint") or child:IsA("JointInstance") then
                    child:Destroy()
                end
            end
        end
        
        -- 尝试获取所有权（如果失败就跳过，不中断代码）
        pcall(function() targetPart:SetNetworkOwner(player) end)
        
        -- 计算到绿球的物理弹射方向
        local direction = (TP_Position + Vector3.new(0, 3, 0) - targetPart.Position).Unit
        
        -- 给它一个巨大的抛射初速度
        targetPart.AssemblyLinearVelocity = direction * 1000
        
        -- 瞬间改写一次 CFrame（争取让服务器在延迟内接收新坐标）
        local offset = Vector3.new(math.random(-1, 1), 2, math.random(-1, 1))
        if obj:IsA("Model") then
            obj:PivotTo(CFrame.new(TP_Position + offset))
        else
            targetPart.CFrame = CFrame.new(TP_Position + offset)
        end
        
        WindUI:Notify({ Title = "物理弹射", Content = "物品正在飞向绿球...", Duration = 2 })
    end)
    
    if not success then
        WindUI:Notify({ Title = "失败", Content = "物理引擎拒绝解绑该物体", Duration = 3 })
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
                    trueTeleport(target)
                else
                    WindUI:Notify({ Title = "拒绝", Content = "该物体不可移动！", Duration = 2 })
                end
            end
        end
    end
end)