local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存NB - 全局拖拽动态发包版",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Size = UDim2.fromOffset(450, 350),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "主要功能", Icon = "mouse-pointer" })
local Section = Tab:Section({ Title = "全局拖拽器" })

local RS = game:GetService("ReplicatedStorage")
local LP = game.Players.LocalPlayer
local Mouse = LP:GetMouse()
local RunService = game:GetService("RunService")

local _G_HardDraggerConnection = nil
local _G_OrigDrag = nil
local activeDragger = nil

local function ToggleDragger(state)
    if state then
        pcall(function()
            _G_HardDraggerConnection = game.Workspace.ChildAdded:Connect(function(a)
                if a.Name == "Dragger" then
                    activeDragger = a
                    
                    task.spawn(function()
                        while activeDragger and activeDragger.Parent == game.Workspace do
                            task.wait(0.05)
                            
                            local targetModel = nil
                            if Mouse.Target then
                                targetModel = Mouse.Target:FindFirstAncestorOfClass("Model")
                            end
                            
                            if targetModel and targetModel:FindFirstChild("Owner") then
                                pcall(function()
                                    local args = {
                                        "Refresh",
                                        targetModel, 
                                        1
                                    }
                                    RS:WaitForChild("Interaction"):WaitForChild("ClientIsDragging"):FireServer(unpack(args))
                                end)
                                
                                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                                    local root = LP.Character.HumanoidRootPart
                                    local lockCFrame = root.CFrame * CFrame.new(0, 2, -6)
                                    if targetModel.PrimaryPart then
                                        targetModel:PivotTo(lockCFrame)
                                    else
                                        local main = targetModel:FindFirstChild("Main") or targetModel:FindFirstChild("WoodSection")
                                        if main then main.CFrame = lockCFrame end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
            
            if not _G_OrigDrag then
                local gui = LP.PlayerGui:FindFirstChild("ItemDraggingGUI")
                if gui and gui:FindFirstChild("Dragger") then
                    _G_OrigDrag = getsenv(gui.Dragger).canDrag
                    getsenv(gui.Dragger).canDrag = function(f)
                        if _G_OrigDrag(f) == true then return true end
                        local char = LP.Character
                        if not char or char.Humanoid.Health <= 0 then return false end
                        if f and f.Name == "LeafPart" then return false end
                        return true 
                    end
                end
            end
        end)
    else
        pcall(function()
            activeDragger = nil
            if _G_HardDraggerConnection then
                _G_HardDraggerConnection:Disconnect()
                _G_HardDraggerConnection = nil
            end
            if _G_OrigDrag then
                local gui = LP.PlayerGui:FindFirstChild("ItemDraggingGUI")
                if gui and gui:FindFirstChild("Dragger") then
                    getsenv(gui.Dragger).canDrag = _G_OrigDrag
                end
                _G_OrigDrag = nil
            end
        end)
    end
end

Section:Toggle({
    Title = "开启全局发包拖拽",
    Desc = "点一下任何物品，强制锁在面前，发包欺骗服务器，飞再快不掉落",
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