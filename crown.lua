local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "第一版完美强化",
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

local function enableSuperDrag()
    if dragConnection then dragConnection:Disconnect() end
    
    dragConnection = Workspace.ChildAdded:Connect(function(obj)
        if obj.Name == "Dragger" and isHooked then
            obj.BrickColor = BrickColor.new("Bright green")
            
            task.spawn(function()
                local b = obj:WaitForChild("BodyGyro", 2)
                local c = obj:WaitForChild("BodyPosition", 2)
                if not b or not c then return end
                
                local char = player.Character
                
                while obj.Parent == Workspace and isHooked do
                    RunService.Heartbeat:Wait()
                    
                    c.P = math.huge
                    c.D = 10000
                    c.maxForce = Vector3.new(math.huge, math.huge, math.huge)
                    b.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    b.P = math.huge
                    b.D = 10000
                    
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        c.Position = hrp.Position + Vector3.new(0, 8, 0)
                        
                        local dragEvent = RS:FindFirstChild("Interaction") and RS.Interaction:FindFirstChild("ClientIsDragging")
                        if dragEvent then
                            for i = 1, 3 do
                                pcall(function() dragEvent:FireServer() end)
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    WindUI:Notify({ Title = "开启成功", Content = "第一版完美逻辑，随便飞绝不掉！", Duration = 5 })
end

local function disableSuperDrag()
    isHooked = false
    if dragConnection then
        dragConnection:Disconnect()
        dragConnection = nil
    end
    WindUI:Notify({ Title = "已关闭", Content = "拖拽已停止", Duration = 3 })
end

Tab:Toggle({
    Title = "开启无敌拖拽",
    Desc = "锁定头顶8格，无视任何拉回",
    Default = false,
    Callback = function(state)
        isHooked = state
        if isHooked then enableSuperDrag() else disableSuperDrag() end
    end
})

Tab:Button({
    Title = "强制关闭",
    Callback = function() disableSuperDrag() end
})