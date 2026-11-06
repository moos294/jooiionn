local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存拖拽器",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(400, 300),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "吸附拖拽", Icon = "rbxassetid://10734898355" })
local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local isHooked = false
local dragConnection = nil
local currentAttach = nil
local currentAlignPos = nil

local function breakAttach()
    if currentAlignPos then
        currentAlignPos:Destroy()
        currentAlignPos = nil
    end
    if currentAttach then
        currentAttach:Destroy()
        currentAttach = nil
    end
end

local function disableSuperDrag()
    isHooked = false
    if dragConnection then 
        dragConnection:Disconnect() 
        dragConnection = nil 
    end
    breakAttach()
    pcall(function()
        local DraggerGUI = player.PlayerGui:FindFirstChild("ItemDraggingGUI")
        if DraggerGUI and DraggerGUI:FindFirstChild("Dragger") and _G.OrigCanDrag then
            getsenv(DraggerGUI.Dragger).canDrag = _G.OrigCanDrag
            _G.OrigCanDrag = nil
        end
    end)
    WindUI:Notify({ Title = "已关闭", Content = "吸附已断开，限制已恢复", Duration = 3 })
end

local function enableSuperDrag()
    pcall(function()
        local DraggerGUI = player.PlayerGui:WaitForChild("ItemDraggingGUI", 3)
        if DraggerGUI and DraggerGUI:FindFirstChild("Dragger") then
            local env = getsenv(DraggerGUI.Dragger)
            if env then
                if not _G.OrigCanDrag then
                    _G.OrigCanDrag = env.canDrag
                end
                env.canDrag = function(part)
                    if _G.OrigCanDrag(part) then return true end
                    local char = player.Character
                    if not char then return false end
                    if char:FindFirstChildOfClass("Tool") then return false end
                    if part and part.Parent then
                        if part.Name == "LeafPart" then return false end
                        local h = part
                        repeat h = h.Parent until h.Parent == Workspace or h.Parent.Name == "PlayerModels" or h.Parent.Name == "LogModels"
                        if h.Parent == Workspace or h.Parent.Name == "PlayerModels" or h.Parent.Name == "LogModels" then
                            return true
                        end
                    end
                    return false
                end
            end
        end
    end)

    if dragConnection then dragConnection:Disconnect() end
    dragConnection = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == "Dragger" and isHooked then
            obj.BrickColor = BrickColor.new("Bright green")
            
            local nearestDist = 999
            local nearestPart = nil
            for _, v in pairs(Workspace:GetChildren()) do
                if v:IsA("Model") or v:IsA("BasePart") or v:IsA("Tool") then
                    local p = v:IsA("Model") and v.PrimaryPart or v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                    if p then
                        local d = (p.Position - obj.Position).Magnitude
                        if d < nearestDist and d < 15 then
                            nearestDist = d
                            nearestPart = v
                        end
                    end
                end
            end

            if nearestPart then
                local primaryPart = nearestPart:IsA("BasePart") and nearestPart or nearestPart.PrimaryPart or nearestPart:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    primaryPart.CanCollide = false
                    
                    for _, p in pairs(nearestPart:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                        if p:IsA("Weld") or p:IsA("WeldConstraint") or p:IsA("JointInstance") then p:Destroy() end
                    end

                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        breakAttach()
                        
                        currentAttach = Instance.new("Attachment", primaryPart)
                        currentAlignPos = Instance.new("AlignPosition", primaryPart)
                        currentAlignPos.Attachment0 = currentAttach
                        currentAlignPos.MaxForce = math.huge
                        currentAlignPos.Responsiveness = 200
                        currentAlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
                        
                        local followConn
                        followConn = RunService.Heartbeat:Connect(function()
                            if not isHooked or not obj or obj.Parent ~= Workspace or not primaryPart or not primaryPart.Parent then
                                if followConn then followConn:Disconnect() end
                                breakAttach()
                                return
                            end
                            if hrp then
                                currentAlignPos.Position = hrp.Position + Vector3.new(0, 8, 0)
                            end
                            
                            local dragEvent = RS:FindFirstChild("Interaction") and RS.Interaction:FindFirstChild("ClientIsDragging")
                            if dragEvent then
                                for i = 1, 3 do
                                    pcall(function() dragEvent:FireServer(nearestPart) end)
                                end
                            end
                        end)
                        
                        obj.AncestryChanged:Connect(function()
                            if not obj:IsDescendantOf(Workspace) then
                                if followConn then followConn:Disconnect() end
                                breakAttach()
                                primaryPart.CanCollide = true
                            end
                        end)
                    end
                end
            end
        end
    end)
    
    WindUI:Notify({ Title = "开启成功", Content = "直接按住物品，飞多快都掉不了！", Duration = 5 })
end

Tab:Toggle({
    Title = "开启无敌吸附拖拽",
    Desc = "拖起物品后直接飞，绝对不掉",
    Default = false,
    Callback = function(state)
        isHooked = state
        if isHooked then
            enableSuperDrag()
        else
            disableSuperDrag()
        end
    end
})

Tab:Button({
    Title = "强制关闭并释放物品",
    Desc = "如果卡住了，点这里立刻断开吸附",
    Callback = function()
        disableSuperDrag()
    end
})