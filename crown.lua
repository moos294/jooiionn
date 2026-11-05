local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "超级物理拖拽器",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(400, 300),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "拖拽控制", Icon = "rbxassetid://10734898355" })
local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local dragConnection = nil
local isHooked = false

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
                        repeat
                            h = h.Parent
                        until h.Parent == Workspace or h.Parent.Name == "PlayerModels" or h.Parent.Name == "LogModels"
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
        if obj.Name == "Dragger" then
            task.spawn(function()
                local b = obj:WaitForChild("BodyGyro", 2)
                local c = obj:WaitForChild("BodyPosition", 2)
                if not b or not c then return end
                
                obj.BrickColor = BrickColor.new("Bright blue")
                
                while obj.Parent == Workspace do
                    task.wait()
                    c.P = 120000
                    c.D = 1000
                    c.maxForce = Vector3.new(1, 1, 1) * 1000000
                    b.maxTorque = Vector3.new(1, 1, 1) * 200
                    b.P = 1200
                    b.D = 140
                end
            end)
        end
    end)
    
    WindUI:Notify({ Title = "开启成功", Content = "直接用手拖动物品，随便飞绝对不掉！", Duration = 5 })
end

local function disableSuperDrag()
    if dragConnection then
        dragConnection:Disconnect()
        dragConnection = nil
    end
    pcall(function()
        local DraggerGUI = player.PlayerGui:FindFirstChild("ItemDraggingGUI")
        if DraggerGUI and DraggerGUI:FindFirstChild("Dragger") and _G.OrigCanDrag then
            getsenv(DraggerGUI.Dragger).canDrag = _G.OrigCanDrag
            _G.OrigCanDrag = nil
        end
    end)
    WindUI:Notify({ Title = "已关闭", Content = "已恢复游戏原版物理拉力", Duration = 3 })
end

Tab:Toggle({
    Title = "开启全图无限制拖拽",
    Desc = "用手按住物品，不管飞多快都不会掉",
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