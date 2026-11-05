local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "真实传送最终版",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(400, 300),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "物品传送", Icon = "rbxassetid://10734898355" })
local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local TP_Position = nil
local TP_Ball = nil

Tab:Button({
    Title = "1. 设置绿球坐标",
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
    if not TP_Position then return end
    local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Tool") and obj:FindFirstChild("Handle")) or obj:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end
    
    if obj:IsA("Tool") then
        obj.Parent = player.Backpack
        return
    end

    -- 清除物理限制
    if obj:IsA("Model") then
        for _, p in pairs(obj:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Anchored = false
                p.CanCollide = false
            elseif p:IsA("Weld") or p:IsA("WeldConstraint") or p:IsA("JointInstance") then
                p:Destroy()
            end
        end
    else
        obj.Anchored = false
        obj.CanCollide = false
    end
    
    -- 给一个极强的推力，骗过物理引擎
    local direction = (TP_Position + Vector3.new(0, 3, 0) - targetPart.Position).Unit
    targetPart.AssemblyLinearVelocity = direction * 5000
    
    -- 开启 0.5 秒的高频本地锁定，防止瞬间被服务器弹回
    local startTime = tick()
    task.spawn(function()
        while tick() - startTime < 0.5 do
            pcall(function()
                if targetPart and targetPart.Parent then
                    targetPart.CFrame = CFrame.new(TP_Position + Vector3.new(0, 2, 0))
                end
            end)
            task.wait()
        end
    end)
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
            
            if target and isStrictlyMovableItem(target) then
                trueTeleport(target)
            end
        end
    end
end)