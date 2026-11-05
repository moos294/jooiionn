local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "真·服务器承认的传送",
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
            TP_Ball.Material = Enum.Material.Neon
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

local function realTeleport(obj)
    if not TP_Position then return end
    
    local targetModel = obj
    while targetModel.Parent and targetModel.Parent ~= workspace and not targetModel:IsA("Tool") do
        if targetModel:IsA("Model") then break end
        targetModel = targetModel.Parent
    end

    local primaryPart = targetModel:IsA("BasePart") and targetModel or (targetModel.PrimaryPart or targetModel:FindFirstChildWhichIsA("BasePart"))
    if not primaryPart then return end
    targetModel.PrimaryPart = primaryPart

    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local oldCFrame = hrp.CFrame
    
    local dragEvent = RS:FindFirstChild("Interaction") and RS.Interaction:FindFirstChild("ClientIsDragging")

    local success = pcall(function()
        char:MoveTo(primaryPart.CFrame.p)
        task.wait(0.2)

        if targetModel:IsA("Model") or targetModel:IsA("Tool") then
            for _, p in pairs(targetModel:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = false
                    p.CanCollide = false
                    p.Massless = true
                elseif p:IsA("Weld") or p:IsA("WeldConstraint") or p:IsA("JointInstance") then
                    p:Destroy()
                end
            end
        else
            targetModel.Anchored = false
            targetModel.CanCollide = false
        end

        if dragEvent then
            pcall(function() dragEvent:FireServer(targetModel) end)
        end

        local targetVector = TP_Position + Vector3.new(0, 5, 0)
        local direction = (targetVector - primaryPart.Position).Unit
        
        primaryPart.AssemblyLinearVelocity = direction * 500 
        primaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

        local startTime = tick()
        while tick() - startTime < 1.5 do
            if not primaryPart or not primaryPart.Parent then break end
            
            local dist = (primaryPart.Position - targetVector).Magnitude
            if dist < 10 then
                primaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            else
                local newDir = (targetVector - primaryPart.Position).Unit
                primaryPart.AssemblyLinearVelocity = newDir * 500
            end

            if dragEvent then
                pcall(function() dragEvent:FireServer(targetModel) end)
            end

            hrp.CFrame = oldCFrame
            task.wait(0.02)
        end
        
        primaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end)
    
    if success then
        WindUI:Notify({ Title = "传送成功", Content = "物品已飞到目标点，请尝试拾取！", Duration = 3 })
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
                local current = target
                local isTree, isPlayer, isTooBig = false, false, false
                local maxSize = 0
                
                for i = 1, 6 do
                    if current == workspace or current == nil then break end
                    if current:FindFirstChild("CutEvent") then isTree = true end
                    if current:FindFirstChildOfClass("Humanoid") then isPlayer = true end
                    if current:IsA("BasePart") then
                        local size = math.max(current.Size.X, current.Size.Y, current.Size.Z)
                        if size > maxSize then maxSize = size end
                    end
                    current = current.Parent
                end

                if maxSize > 20 then isTooBig = true end

                if isTree then
                    WindUI:Notify({ Title = "拒绝", Content = "不能传活树！", Duration = 2 })
                elseif isPlayer then
                    WindUI:Notify({ Title = "拒绝", Content = "不能传人！", Duration = 2 })
                elseif isTooBig then
                    WindUI:Notify({ Title = "拒绝", Content = "不能传商店或巨大物体！", Duration = 2 })
                elseif target:IsA("Terrain") then
                    WindUI:Notify({ Title = "拒绝", Content = "不能传地形！", Duration = 2 })
                else
                    realTeleport(target)
                end
            end
        end
    end
end)