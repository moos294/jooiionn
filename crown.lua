local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存NB - 原版框架替换版",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Size = UDim2.fromOffset(450, 350),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "主要功能", Icon = "mouse-pointer" })
local Section = Tab:Section({ Title = "拖拽功能" })

local RS = game:GetService("ReplicatedStorage")
local LP = game.Players.LocalPlayer
local Mouse = LP:GetMouse()
local RunService = game:GetService("RunService")

local _G_HardDraggerConnection = nil
local _G_OrigDrag = nil
local isDragging = false

-- 完全照搬原版逻辑，只替换核心部分
local function ToggleDragger(state)
    if state then
        pcall(function()
            _G_HardDraggerConnection = game.Workspace.ChildAdded:connect(
                function(a)
                    if a.Name == "Dragger" then
                        -- ================= 替换的部分开始 =================
                        -- 原版这里写的是 local b = a:WaitForChild("BodyGyro") 然后修改 P, D, MaxForce
                        -- 我们直接换成你抓到的木材大亨发包逻辑 + 本地强制视觉锁定
                        
                        isDragging = true
                        
                        -- 启动异步循环，在拖拽期间持续发包
                        task.spawn(function()
                            while isDragging do
                                task.wait(0.05) -- 每秒发20次包
                                
                                local targetModel = nil
                                -- 手机端点一下，获取当前点到的模型
                                if Mouse.Target then
                                    targetModel = Mouse.Target:FindFirstAncestorOfClass("Model")
                                end
                                
                                if targetModel and targetModel:FindFirstChild("Owner") then
                                    -- 1. 发送你抓到的木材大亨发包代码
                                    pcall(function()
                                        local args = {
                                            "Refresh", -- 你抓到的参数
                                            targetModel,
                                            1
                                        }
                                        RS:WaitForChild("Interaction"):WaitForChild("ClientIsDragging"):FireServer(unpack(args))
                                    end)
                                    
                                    -- 2. 本地强制视觉固定（防止高速飞行时掉下）
                                    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                                        local root = LP.Character.HumanoidRootPart
                                        local targetCFrame = root.CFrame * CFrame.new(0, 2, -6)
                                        if targetModel.PrimaryPart then
                                            targetModel:PivotTo(targetCFrame)
                                        else
                                            local mainPart = targetModel:FindFirstChild("Main") or targetModel:FindFirstChild("WoodSection")
                                            if mainPart then mainPart.CFrame = targetCFrame end
                                        end
                                    end
                                end
                            end
                        end)
                        
                        -- 监听 Dragger 被销毁（松手）
                        a.Destroying:Connect(function()
                            isDragging = false
                        end)
                        -- ================= 替换的部分结束 =================
                    end
                end
            )
            
            -- 下面这段原封不动保留（用来解除手机端的限制）
            if not _G_OrigDrag then
                _G_OrigDrag = getsenv(game:GetService("Players").LocalPlayer.PlayerGui.ItemDraggingGUI.Dragger).canDrag
                getsenv(game:GetService("Players").LocalPlayer.PlayerGui.ItemDraggingGUI.Dragger).canDrag = function(f)
                    if _G_OrigDrag(f) == true then return true end
                    local g = game.Players.LocalPlayer.Character
                    if not g then return end
                    if g:FindFirstChildOfClass("Tool") then return end
                    if f then
                        if f.Parent then
                            if 0 <= g.Humanoid.Health and f.Name == "LeafPart" then
                                return false
                            else
                                local h = f
                                repeat
                                    h = h.Parent
                                until h.Parent.Name == "PlayerModels" or h.Parent == game.Workspace or h.Parent == game or h.Parent.Name == "LogModels"
                                if h.Parent.Name == "PlayerModels" or h.Parent.Name == "LogModels" then
                                end
                            end
                        end
                    end
                    return false
                end
            end
        end)
    else
        pcall(function()
            isDragging = false
            if _G_HardDraggerConnection then
                _G_HardDraggerConnection:Disconnect()
                _G_HardDraggerConnection = nil
            end
            if _G_OrigDrag then
                getsenv(game:GetService("Players").LocalPlayer.PlayerGui.ItemDraggingGUI.Dragger).canDrag = _G_OrigDrag
                _G_OrigDrag = nil
            end
        end)
    end
end

Section:Toggle({
    Title = "开启原版替换拖拽器",
    Desc = "使用木材大亨的原生发包进行强制拖拽",
    Default = false
}, function(state)
    ToggleDragger(state)
end)

Section:Button({
    Title = "执行飞行脚本",
    Desc = "加载 Pastebin 飞行"
}, function()
    pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/ZBzcTm1f"))() end)
end)