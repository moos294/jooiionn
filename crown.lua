local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "传送0.1",
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
    Desc = "放入背包，拿在手里点击屏幕即可传送",
    Callback = function()
        if player.Backpack:FindFirstChild("传送魔杖") or (player.Character and player.Character:FindFirstChild("传送魔杖")) then
            WindUI:Notify({ Title = "提示", Content = "你已经有魔杖了！", Duration = 3 })
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
        WindUI:Notify({ Title = "成功", Content = "魔杖已放入背包", Duration = 3 })
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
        if current.Name == "LogModels" then return false end
        if current:FindFirstChild("CutEvent") then return false end
        if current:FindFirstChildOfClass("Humanoid") then return false end
        if current.Name == "WOODDROPOFF" or current.Name == "WoodRUs" then return false end
        current = current.Parent
    end
    
    local nameLower = string.lower(obj.Name)
    local isWoodName = string.find(nameLower, "log") or string.find(nameLower, "wood") or string.find(nameLower, "plank") or string.find(nameLower, "crate") or string.find(nameLower, "box")
    
    if obj:IsA("BasePart") then
        if obj.Anchored and not isWoodName then return false end
        if obj.Size.X > 15 or obj.Size.Y > 15 or obj.Size.Z > 15 then return false end
        return true
    elseif obj:IsA("Model") then
        local hasPart = false
        for _, p in pairs(obj:GetDescendants()) do
            if p:IsA("BasePart") then
                hasPart = true
                if p.Size.X > 15 or p.Size.Y > 15 or p.Size.Z > 15 then return false end
            end
        end
        if not hasPart then return false end
        if obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Anchored and not isWoodName then 
            return false 
        end
        return true
    end
    
    return false
end

local function teleportObject(obj)
    if not TP_Position then 
        WindUI:Notify({ Title = "警告", Content = "请先设置目标点！", Duration = 3 })
        return 
    end
    
    local targetPos = TP_Position + Vector3.new(math.random(-1, 1), 1.5, math.random(-1, 1))
    
    local success = pcall(function()
        if obj:IsA("Model") then
            for _, p in pairs(obj:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    p.CanCollide = false
                    p.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    p.AssemblyAngularVelocity = Vector3.new(0,0,0)
                end
            end
            obj:PivotTo(CFrame.new(targetPos))
        elseif obj:IsA("BasePart") then
            obj.Anchored = false
            obj.CanCollide = false
            obj.AssemblyLinearVelocity = Vector3.new(0,0,0)
            obj.AssemblyAngularVelocity = Vector3.new(0,0,0)
            obj.CFrame = CFrame.new(targetPos)
        end
    end)
    
    if success then
        WindUI:Notify({ Title = "传送成功", Content = "已将物品传送", Duration = 2 })
    end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local char = player.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        
        if tool and tool.Name == "传送魔杖" then
            local camera = workspace.CurrentCamera
            local screenPos = input.Position
            local unitRay = camera:ViewportPointToRay(screenPos.X, screenPos.Y)
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {player.Character, TP_Ball}
            
            local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 200, rayParams)
            local target = result and result.Instance
            
            if target then
                if isStrictlyMovableItem(target) then
                    teleportObject(target)
                else
                    WindUI:Notify({ Title = "拒绝", Content = "只能传送可移动的散落物品！", Duration = 2 })
                end
            end
        end
    end
end)