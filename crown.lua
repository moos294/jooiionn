local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "木材大亨 - 传送魔杖版",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(450, 400),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "传送控制", Icon = "rbxassetid://10734898355" })

local player = game.Players.LocalPlayer

local TP_Position = nil
local TP_Ball = nil

local TP_StatusLabel = Tab:Paragraph({
    Title = "传送状态",
    Desc = "未设置目标点",
    Color = "Red"
})

Tab:Button({
    Title = "1. 设置当前脚下为目标点",
    Desc = "在此处生成一个只有你能看到的标记绿球",
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
            TP_Ball.Size = Vector3.new(5, 5, 5)
            TP_Ball.Position = TP_Position
            TP_Ball.Material = Enum.Material.Neon
            TP_Ball.Color = Color3.fromRGB(0, 255, 0)
            TP_Ball.Anchored = true
            TP_Ball.CanCollide = false
            TP_Ball.Transparency = 0.4
            TP_Ball.Parent = workspace
            
            WindUI:Notify({ Title = "成功", Content = "目标点已设置！", Duration = 3 })
        end
    end
})

Tab:Button({
    Title = "2. 获得传送魔杖",
    Desc = "放入背包，拿在手里点击物品即可传送",
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
    if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then return false end
    if obj:IsDescendantOf(player.Character) then return false end
    if obj.Name == "LocalTPMarker" then return false end
    
    -- 排除活树
    if obj:FindFirstChild("CutEvent") then return false end
    
    local nameLower = string.lower(obj.Name)
    if string.find(nameLower, "log") or string.find(nameLower, "wood") or string.find(nameLower, "plank") or string.find(nameLower, "crate") or string.find(nameLower, "box") then
        return true
    end
    
    -- 零件是否未锚定（可移动）
    if obj:IsA("BasePart") and obj.Anchored == false then
        return true
    end
    
    -- 模型内部是否有未锚定零件
    if obj:IsA("Model") then
        for _, p in pairs(obj:GetDescendants()) do
            if p:IsA("BasePart") and p.Anchored == false then
                return true
            end
        end
    end
    
    return false
end

local function teleportObject(obj)
    if not TP_Position then return end
    
    local targetPos = TP_Position + Vector3.new(math.random(-2, 2), 3, math.random(-2, 2))
    
    pcall(function()
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
end

-- 监听玩家背包，自动给魔杖绑定功能
player.ChildAdded:Connect(function(child)
    if child.Name == "传送魔杖" and child:IsA("Tool") then
        local function bindWand(tool)
            tool.Activated:Connect(function()
                if not TP_Position then
                    WindUI:Notify({ Title = "警告", Content = "请先在面板设置目标点！", Duration = 3 })
                    return
                end

                local mouse = player:GetMouse()
                local target = mouse.Target

                if target then
                    if isMovableItem(target) then
                        teleportObject(target)
                        WindUI:Notify({ Title = "传送成功", Content = "已将 " .. target.Name .. " 传送", Duration = 2 })
                    else
                        -- 如果是子零件属于某个可移动模型，则连根拔起
                        local parentModel = target:FindFirstAncestorOfClass("Model")
                        if parentModel and isMovableItem(parentModel) then
                            teleportObject(parentModel)
                            WindUI:Notify({ Title = "传送成功", Content = "已将 " .. parentModel.Name .. " 传送", Duration = 2 })
                        else
                            WindUI:Notify({ Title = "拒绝传送", Content = "固定物、地形或活树无法传送！", Duration = 3 })
                        end
                    end
                end
            end)
        end
        
        bindWand(child)
    end
end)