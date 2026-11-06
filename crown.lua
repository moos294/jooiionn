local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存拖拽",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(400, 300),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "拖拽控制", Icon = "rbxassetid://10734898355" })
local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")

local isEnabled = false
local dragConn = nil

local function stopDrag()
    isEnabled = false
    if dragConn then
        dragConn:Disconnect()
        dragConn = nil
    end
    WindUI:Notify({ Title = "已停止", Content = "拖拽功能已关闭", Duration = 3 })
end

local function startDrag()
    if dragConn then dragConn:Disconnect() end
    dragConn = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == "Dragger" and isEnabled then
            obj.BrickColor = BrickColor.new("Bright green")
            
            task.spawn(function()
                local b = obj:WaitForChild("BodyGyro", 2)
                local c = obj:WaitForChild("BodyPosition", 2)
                if not b or not c then return end
                
                task.wait(0.1)
                
                obj.CanCollide = false
                obj.CanTouch = false
                
                while obj.Parent == Workspace and isEnabled do
                    c.P = 120000
                    c.D = 1000
                    c.maxForce = Vector3.new(1, 1, 1) * 1000000
                    
                    b.MaxTorque = Vector3.new(1, 1, 1) * 200
                    b.P = 1200
                    b.D = 140
                    
                    local dragEvent = RS:FindFirstChild("Interaction") and RS.Interaction:FindFirstChild("ClientIsDragging")
                    if dragEvent then
                        pcall(function() dragEvent:FireServer() end)
                    end
                    
                    task.wait()
                end
            end)
        end
    end)
end

Tab:Toggle({
    Title = "开启完美拖拽",
    Desc = "锁定物理拉力，随便飞绝对不掉",
    Default = false,
    Callback = function(state)
        isEnabled = state
        if isEnabled then
            startDrag()
            WindUI:Notify({ Title = "开启成功", Content = "直接用手抓取物品起飞！", Duration = 3 })
        else
            stopDrag()
        end
    end
})

Tab:Button({
    Title = "强制关闭并释放物品",
    Desc = "如果遇到卡顿，点此强行断开",
    Callback = function()
        stopDrag()
        local toggleObj = Window:GetToggle("开启完美拖拽")
        if toggleObj then toggleObj:Set(false) end
    end
})