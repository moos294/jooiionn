local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "真实物理传送系统",
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
    
    local targetPos = TP_Position + Vector3.new(0, 2, 0)
    
    local success = pcall(function()
        if obj:IsA("Model") then
            for _, p in pairs(obj:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    p.CanCollide = true
                    p.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    p.AssemblyAngularVelocity = Vector3.new(0,0,0)
                    p:SetNetworkOwner(player)
                end
            end
            obj:PivotTo(CFrame.new(targetPos))
            
            task.wait(0.1)
            obj:PivotTo(CFrame.new(targetPos))
            
        elseif obj:IsA("BasePart") then
            obj.Anchored = false
            obj.CanCollide = true
            obj.AssemblyLinearVelocity = Vector3.new(0,0,0)
            obj.AssemblyAngularVelocity = Vector3.new(0,0,0)
            obj:SetNetworkOwner(player)
            
            obj.CFrame = CFrame.new(targetPos)
            
            task.wait(0.1)
            obj.CFrame = CFrame.new(targetPos)
        elseif obj:IsA("Tool") then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                handle.Anchored = false
                handle:SetNetworkOwner(player)
                handle.CFrame = CFrame.new(targetPos)
            end
        end
    end)
    
    if success then
        WindUI:Notify({ Title = "传送成功", Content = "物品已真实抵达！", Duration = 2 })
    else
        WindUI:Notify({ Title = "失败", Content = "物体被服务器死死锁住", Duration = 3 })
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