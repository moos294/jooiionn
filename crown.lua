local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "物理抓取传送系统",
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
    Title = "1. 设置当前身体位置为目标点",
    Desc = "在躯干位置生成一个小绿点",
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
            
            WindUI:Notify({ Title = "成功", Content = "目标点已设置！", Duration = 3 })
        end
    end
})

Tab:Button({
    Title = "2. 获得隐身传送魔杖",
    Callback = function()
        if player.Backpack:FindFirstChild("传送魔杖") or (player.Character and player.Character:FindFirstChild("传送魔杖")) then
            return
        end

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

local function soulTeleport(obj)
    if not TP_Position then 
        WindUI:Notify({ Title = "警告", Content = "请先设置目标点！", Duration = 3 })
        return 
    end
    
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local targetPart = obj:IsA("BasePart") and obj or (obj:IsA("Tool") and obj:FindFirstChild("Handle")) or obj:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end
    
    local originalCFrame = hrp.CFrame
    
    local success = pcall(function()
        hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 5, 0))
        task.wait(0.05)
        
        targetPart.Anchored = false
        targetPart.CanCollide = false
        
        local att0 = Instance.new("Attachment")
        att0.Parent = targetPart
        
        local att1 = Instance.new("Attachment")
        att1.Parent = TP_Ball
        
        local align = Instance.new("AlignPosition")
        align.Attachment0 = att0
        align.Attachment1 = att1
        align.MaxForce = 100000000
        align.Responsiveness = 30
        align.Position = Vector3.new(0, 2, 0)
        align.Parent = targetPart
        
        hrp.CFrame = originalCFrame
        WindUI:Notify({ Title = "抓取成功", Content = "物理引擎正在拉取物品...", Duration = 2 })
        
        task.delay(1.5, function()
            if align then align:Destroy() end
            if att0 then att0:Destroy() end
            if att1 then att1:Destroy() end
            targetPart.CanCollide = true
        end)
    end)
    
    if not success then
        hrp.CFrame = originalCFrame
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
                    soulTeleport(target)
                else
                    WindUI:Notify({ Title = "拒绝", Content = "该物体不可移动！", Duration = 2 })
                end
            end
        end
    end
end)