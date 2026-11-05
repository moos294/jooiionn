local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "传送魔杖",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(400, 300),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "传送功能", Icon = "rbxassetid://10734898355" })

local player = game.Players.LocalPlayer

local TP_Position = nil
local TP_Ball = nil

Tab:Button({
    Title = "1. 设置当前身体位置为目标点",
    Desc = "在躯干位置生成一个发光绿球",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            TP_Position = hrp.Position
            
            if TP_Ball then TP_Ball:Destroy() end
            
            TP_Ball = Instance.new("Part")
            TP_Ball.Name = "LocalTPMarker"
            TP_Ball.Shape = Enum.PartType.Ball
            TP_Ball.Size = Vector3.new(6, 6, 6)
            TP_Ball.Position = TP_Position
            TP_Ball.Material = Enum.Material.Neon
            TP_Ball.Color = Color3.fromRGB(0, 255, 0)
            TP_Ball.Anchored = true
            TP_Ball.CanCollide = false
            TP_Ball.CanQuery = false
            TP_Ball.CastShadow = false
            TP_Ball.Transparency = 0.2
            TP_Ball.Parent = workspace
            
            local light = Instance.new("PointLight")
            light.Color = Color3.fromRGB(0, 255, 0)
            light.Range = 15
            light.Brightness = 3
            light.Parent = TP_Ball
            
            WindUI:Notify({ Title = "成功", Content = "目标点已设置！", Duration = 3 })
        end
    end
})

Tab:Button({
    Title = "2. 获得传送魔杖",
    Desc = "放入背包，拿在手里点击物体即可传送",
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
        handle.Size = Vector3.new(0.5, 0.5, 3)
        handle.Color = Color3.fromRGB(0, 255, 0)
        handle.Material = Enum.Material.Neon
        handle.Parent = tool

        tool.Parent = player.Backpack
        WindUI:Notify({ Title = "成功", Content = "魔杖已放入背包，请装备！", Duration = 3 })
    end
})

local function isMovableItem(obj)
    if obj:IsA("Terrain") then return false end
    if obj.Name == "LocalTPMarker" then return false end
    if obj:IsDescendantOf(player.Character) then return false end
    
    local current = obj
    for i = 1, 4 do
        if current == workspace or current == nil then break end
        if current:FindFirstChildOfClass("Humanoid") then return false end
        if current:FindFirstChild("CutEvent") then return false end
        if current.Name == "WOODDROPOFF" or current.Name == "WoodRUs" then return false end
        current = current.Parent
    end
    
    return true 
end

local function teleportObject(obj)
    if not TP_Position then 
        WindUI:Notify({ Title = "警告", Content = "请先设置目标点！", Duration = 3 })
        return 
    end
    
    local targetPos = TP_Position + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
    
    local targetModel = obj:FindFirstAncestorOfClass("Model")
    if targetModel and isMovableItem(targetModel) and targetModel.Parent ~= workspace then
        obj = targetModel
    end
    
    local success = pcall(function()
        if obj:IsA("Model") then
            for _, p in pairs(obj:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    p.CanCollide = false
                    p:SetNetworkOwner(player)
                end
            end
            obj:PivotTo(CFrame.new(targetPos))
        elseif obj:IsA("BasePart") then
            obj.Anchored = false
            obj.CanCollide = false
            obj:SetNetworkOwner(player)
            obj.CFrame = CFrame.new(targetPos)
        end
    end)
    
    if success then
        WindUI:Notify({ Title = "传送成功", Content = "已将 " .. obj.Name .. " 传送", Duration = 2 })
    else
        WindUI:Notify({ Title = "失败", Content = "传送失败，可能被服务器拦截", Duration = 3 })
    end
end

local function bindTool(t)
    if t.Name == "传送魔杖" and t:IsA("Tool") and not t:GetAttribute("Bound") then
        t:SetAttribute("Bound", true)
        
        t.Activated:Connect(function()
            local mouse = player:GetMouse()
            local target = mouse.Target
            
            if not target then
                local camera = workspace.CurrentCamera
                local screenPos = Vector2.new(mouse.X, mouse.Y)
                local unitRay = camera:ViewportPointToRay(screenPos.X, screenPos.Y)
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {player.Character, TP_Ball}
                local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 100, rayParams)
                if result then
                    target = result.Instance
                end
            end
            
            if target then
                if isMovableItem(target) then
                    teleportObject(target)
                else
                    WindUI:Notify({ Title = "拒绝传送", Content = "该物体无法传送", Duration = 2 })
                end
            else
                WindUI:Notify({ Title = "传送失败", Content = "未识别到物体", Duration = 2 })
            end
        end)
    end
end

if player:FindFirstChild("Backpack") then
    player.Backpack.ChildAdded:Connect(bindTool)
    for _, child in pairs(player.Backpack:GetChildren()) do bindTool(child) end
end

player.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(bindTool)
    for _, child in pairs(char:GetChildren()) do bindTool(child) end
end)

if player.Character then
    player.Character.ChildAdded:Connect(bindTool)
    for _, child in pairs(player.Character:GetChildren()) do bindTool(child) end
end