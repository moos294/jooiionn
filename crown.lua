local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存拖拽器0.1",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(400, 300),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "拖拽控制", Icon = "rbxassetid://10734898355" })
local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local dragConnection = nil
local isHooked = false
local currentDragTarget = nil

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
                    if _G.OrigCanDrag(part) then 
                        currentDragTarget = part
                        return true 
                    end
                    local char = player.Character
                    if not char then return false end
                    if char:FindFirstChildOfClass("Tool") then return false end
                    if part and part.Parent then
                        if part.Name == "LeafPart" then return false end
                        local h = part
                        repeat h = h.Parent until h.Parent == Workspace or h.Parent.Name == "PlayerModels" or h.Parent.Name == "LogModels"
                        if h.Parent == Workspace or h.Parent.Name == "PlayerModels" or h.Parent.Name == "LogModels" then
                            currentDragTarget = part
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
            
            task.spawn(function()
                local b = obj:WaitForChild("BodyGyro", 1)
                local c = obj:WaitForChild("BodyPosition", 1)
                if not b or not c then return end
                
                local char = player.Character
                
                while obj.Parent == Workspace and isHooked do
                    RunService.Heartbeat:Wait()
                    
                    -- 物理拉力拉满
                    c.P = 500000
                    c.D = 10000
                    c.maxForce = Vector3.new(math.huge, math.huge, math.huge)
                    b.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    b.P = 500000
                    b.D = 10000
                    
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- 核心绝杀 1：直接拉到头顶 15 格的高空
                        c.Position = hrp.Position + Vector3.new(0, 15, 0)
                        
                        -- 核心绝杀 2：彻底关闭触碰和碰撞事件
                        pcall(function()
                            if currentDragTarget then
                                if currentDragTarget:IsA("BasePart") then
                                    currentDragTarget.CanCollide = false
                                    currentDragTarget.CanTouch = false
                                elseif currentDragTarget:IsA("Model") then
                                    for _, v in pairs(currentDragTarget:GetDescendants()) do
                                        if v:IsA("BasePart") then
                                            v.CanCollide = false
                                            v.CanTouch = false
                                        end
                                    end
                                end
                            end
                        end)

                        -- 狂发拖拽包欺骗服务器
                        local dragEvent = RS:FindFirstChild("Interaction") and RS.Interaction:FindFirstChild("ClientIsDragging")
                        if dragEvent and currentDragTarget then
                            for i = 1, 3 do
                                pcall(function() dragEvent:FireServer(currentDragTarget) end)
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    WindUI:Notify({ Title = "开启成功", Content = "物品已锁定头顶，关闭触碰！", Duration = 5 })
end

local function disableSuperDrag()
    isHooked = false
    if dragConnection then
        dragConnection:Disconnect()
        dragConnection = nil
    end
    pcall(function()
        if currentDragTarget then
            if currentDragTarget:IsA("BasePart") then
                currentDragTarget.CanCollide = true
                currentDragTarget.CanTouch = true
            elseif currentDragTarget:IsA("Model") then
                for _, v in pairs(currentDragTarget:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                        v.CanTouch = true
                    end
                end
            end
        end
    end)
    currentDragTarget = nil
    pcall(function()
        local DraggerGUI = player.PlayerGui:FindFirstChild("ItemDraggingGUI")
        if DraggerGUI and DraggerGUI:FindFirstChild("Dragger") and _G.OrigCanDrag then
            getsenv(DraggerGUI.Dragger).canDrag = _G.OrigCanDrag
            _G.OrigCanDrag = nil
        end
    end)
    WindUI:Notify({ Title = "已关闭", Content = "拖拽已恢复原版", Duration = 3 })
end

Tab:Toggle({
    Title = "开启无限制拖拽",
    Desc = "锁定头顶，随便飞绝不掉",
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
    Desc = "如果拖拽卡住，点这里立刻断开",
    Callback = function()
        disableSuperDrag()
    end
})