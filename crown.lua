local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存NB - 整合版",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Folder = "BaiScript",
    Size = UDim2.fromOffset(450, 350),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "主要功能", Icon = "mouse-pointer" })
local Section = Tab:Section({ Title = "功能菜单" })

local dragActive = false
local _G_HardDraggerConnection = nil
local _G_OrigDrag = nil

local function ToggleDragger(state)
    if state then
        pcall(function()
            _G_HardDraggerConnection = game.Workspace.ChildAdded:connect(
                function(a)
                    if a.Name == "Dragger" then
                        local b = a:WaitForChild("BodyGyro")
                        local c = a:WaitForChild("BodyPosition")
                        local d = {
                            bp_p = c.P,
                            bp_d = c.D,
                            bp_maxforce = c.maxForce,
                            bg_p = b.P,
                            bg_d = b.D,
                            bg_maxtorque = b.maxTorque,
                            color_backup = a.BrickColor
                        }
                        local e = BrickColor.new("Bright blue")
                        a.BrickColor = e
                        repeat
                            task.wait()
                            c.P = 120000
                            c.D = 1000
                            c.maxForce = Vector3.new(1, 1, 1) * 1000000
                            b.maxTorque = Vector3.new(1, 1, 1) * 200
                            b.P = 1200
                            b.D = 140
                        until a.Parent ~= game.Workspace
                        c.maxForce = d["bp_maxforce"]
                        c.D = d["bp_d"]
                        c.P = d["bp_p"]
                        b.maxTorque = d["bg_maxtorque"]
                        b.P = d["bg_p"]
                        b.D = d["bg_d"]
                        a.BrickColor = d["color_backup"]
                    end
                end
            )
            
            if not _G_OrigDrag then
                _G_OrigDrag = getsenv(game:GetService("Players").LocalPlayer.PlayerGui.ItemDraggingGUI.Dragger).canDrag
                getsenv(game:GetService("Players").LocalPlayer.PlayerGui.ItemDraggingGUI.Dragger).canDrag = function(f)
                    if _G_OrigDrag(f) == true then
                        return true
                    end
                    local g = game.Players.LocalPlayer.Character
                    if not g then
                        return
                    end
                    if g:FindFirstChildOfClass("Tool") then
                        return
                    end
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
    Title = "开启/关闭拖拽器",
    Desc = "开启后拖拽物体会有加速效果 (变成蓝色)",
    Default = false
}, function(state)
    dragActive = state
    ToggleDragger(state)
end)

Section:Button({
    Title = "执行飞行脚本",
    Desc = "点击远程加载并运行 Pastebin 上的飞行脚本"
}, function()
    WindUI:Notify({
        Title = "封存NB",
        Content = "正在加载飞行脚本，请稍后...",
        Duration = 3
    })
    
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/ZBzcTm1f"))()
    end)
    
    if not success then
        WindUI:Notify({
            Title = "错误",
            Content = "加载失败，可能链接已失效或被执行器拦截。",
            Duration = 5
        })
    end
end)