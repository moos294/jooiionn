local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")

local isEnabled = false
local dragConn = nil

if game.CoreGui:FindFirstChild("SuperDragUI") then game.CoreGui.SuperDragUI:Destroy() end
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SuperDragUI"

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 130, 0, 40)
btn.Position = UDim2.new(0, 20, 0.5, 0)
btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Text = "原版拖拽: 关"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.Draggable = true
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        btn.Text = "原版拖拽: 开"
        btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        if dragConn then dragConn:Disconnect() end
        dragConn = Workspace.ChildAdded:Connect(function(obj)
            if obj.Name == "Dragger" and isEnabled then
                obj.BrickColor = BrickColor.new("Bright green")
                
                task.spawn(function()
                    local b = obj:WaitForChild("BodyGyro", 2)
                    local c = obj:WaitForChild("BodyPosition", 2)
                    if not b or not c then return end
                    
                    -- 核心修复 1：等待0.1秒，等引擎把 Weld 焊接完，绝不报 Weld is locked 错误！
                    task.wait(0.1)
                    
                    -- 核心修复 2：关闭隐形球的碰撞和触碰，这样飞的时候就算刮到你的脚，也绝对不会强行断开！
                    obj.CanCollide = false
                    obj.CanTouch = false
                    
                    while obj.Parent == Workspace and isEnabled do
                        -- 核心修复 3：完美复刻原版参数，绝不用 math.huge 挤爆引擎
                        c.P = 120000
                        c.D = 1000
                        c.maxForce = Vector3.new(1, 1, 1) * 1000000
                        
                        b.MaxTorque = Vector3.new(1, 1, 1) * 200
                        b.P = 1200
                        b.D = 140
                        
                        -- 狂发合法拖拽包，防止服务器拉回
                        local dragEvent = RS:FindFirstChild("Interaction") and RS.Interaction:FindFirstChild("ClientIsDragging")
                        if dragEvent then
                            pcall(function() dragEvent:FireServer() end)
                        end
                        
                        task.wait()
                    end
                end)
            end
        end)
    else
        btn.Text = "原版拖拽: 关"
        btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        if dragConn then dragConn:Disconnect() dragConn = nil end
    end
end)