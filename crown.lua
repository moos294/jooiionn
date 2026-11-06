local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "纯辅助工具盒",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(420, 320),
    Transparent = true,
    Theme = "Dark"
})

local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local Mouse = player:GetMouse()

local function DragModel(m, cf)
	pcall(function() RS.Interaction.ClientIsDragging:FireServer(m) end)
	if not m.PrimaryPart then m.PrimaryPart = m:FindFirstChildOfClass("Part") end
	if m.PrimaryPart then 
        m.PrimaryPart.Velocity = Vector3.zero
        m:SetPrimaryPartCFrame(cf) 
    end
end

local TabTP = Window:Tab({ Title = "树木传送", Icon = "rbxassetid://10734945123" })
local TabItem = Window:Tab({ Title = "物品传送", Icon = "rbxassetid://10882439086" })

local targetTree = "Generic"
local oldPos = nil

local tree_list = {
	"普通木 (Generic)", "幻影木 (LoneCave)", "电木 (Electric)", "胡桃木 (Walnut)", "星木 (Star)", "樱桃木 (Cherry)", "桦木 (Birch)", "冰霜木 (Frost)",
	"大理石木 (Marble)", "火山木 (Volcano)", "金色沼泽木 (GoldSwampy)", "普通金木 (GenericGold)", "巨型橡木 (GreatOak)", "石头木 (Stone)", "辐射木 (Radioactive)",
	"洞穴木 (Cavern)", "岩浆木 (Magma)", "蓝木 (CaveCrawler)", "灵魂木 (Spirit)", "烈焰木 (Flame)", "星辰木 (Celestial)", "橡木 (Oak)", "绿色沼泽木 (GreenSwampy)",
	"沙子木 (Sand)", "松木 (Pine)", "玻璃木 (Glass)", "彩虹木 (Rainbow)", "冰木 (Ice)"
}

TabTP:Dropdown({
    Title = "选择树木种类",
    Values = tree_list,
    Value = "普通木 (Generic)",
    Callback = function(option)
        local m = string.match(option, "%((.+)%)")
        if m then targetTree = m else targetTree = option end
    end
})

TabTP:Button({
    Title = "保存当前位置",
    Desc = "传送前先点一下这个，方便迷路后传回来",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            oldPos = player.Character.HumanoidRootPart.CFrame
            WindUI:Notify({ Title = "成功", Content = "已保存当前位置", Duration = 3 })
        end
    end
})

TabTP:Button({
    Title = "传送到树旁",
    Desc = "安全传送到树旁边的空地上，绝对不会卡树",
    Callback = function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local targetWood = nil
        for _, v in next, Workspace:GetDescendants() do
            if v.Name == "TreeRegion" then
                for _, m in next, v:GetChildren() do
                    if m:FindFirstChild("CutEvent") and not m:FindFirstChild("RootCut") then
                        if m:FindFirstChild("TreeClass") and m.TreeClass.Value == targetTree then 
                            if m:FindFirstChild("Owner") and (m.Owner.Value == nil or m.Owner.Value == player) then
                                targetWood = m
                                break
                            end
                        end
                    end
                end
            end
            if targetWood then break end
        end
        
        if targetWood then
            local baseWood = targetWood:FindFirstChild("WoodSection")
            if baseWood then
                local safePos = baseWood.CFrame + Vector3.new(0, 2.5, 3.5)
                player.Character.HumanoidRootPart.CFrame = safePos
                WindUI:Notify({ Title = "传送成功", Content = "请手动挥动斧头砍树", Duration = 3 })
            else
                WindUI:Notify({ Title = "提示", Content = "找不到树干部分", Duration = 3 })
            end
        else
            WindUI:Notify({ Title = "错误", Content = "附近没有找到这种树", Duration = 3 })
        end
    end
})

TabTP:Button({
    Title = "传送回原点",
    Desc = "回到你之前保存的安全位置",
    Callback = function()
        if oldPos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = oldPos
            WindUI:Notify({ Title = "传送成功", Content = "已回到原点", Duration = 3 })
        else
            WindUI:Notify({ Title = "错误", Content = "你还没有保存位置", Duration = 3 })
        end
    end
})

TabItem:Button({
    Title = "设置传送点位",
    Desc = "在你的脚下生成一个隐形的拉回点",
    Callback = function()
        if Workspace:FindFirstChild("BRING") then
            Workspace.BRING:Destroy()
        end
        local p = Instance.new("Part", Workspace)
        p.Name = "BRING"
        p.Transparency = 1
        p.Anchored = true
        p.CFrame = player.Character.HumanoidRootPart.CFrame
        p.CanCollide = false
        p.Size = player.Character.HumanoidRootPart.Size
        
        local posBox = Instance.new("SelectionBox", p)
        posBox.Name = "BRINGBOX"
        posBox.Color3 = Color3.new(0, 255, 0)
        posBox.Adornee = posBox.Parent
        WindUI:Notify({ Title = "设置成功", Content = "传送点位已设置在你的脚下", Duration = 3 })
    end
})

TabItem:Button({
    Title = "删除传送点位",
    Desc = "移除当前设置的拉回点",
    Callback = function()
        if Workspace:FindFirstChild("BRING") then
            Workspace.BRING:Destroy()
            WindUI:Notify({ Title = "删除成功", Content = "传送点位已移除", Duration = 3 })
        else
            WindUI:Notify({ Title = "提示", Content = "当前没有设置点位", Duration = 3 })
        end
    end
})

TabItem:Button({
    Title = "获取点击传送工具",
    Desc = "拿在手上，点击任何掉落物或模型即可拉回点位",
    Callback = function()
        if player.Backpack:FindFirstChild("点击传送任何物品") or player.Character:FindFirstChild("点击传送任何物品") then
            player.Backpack["点击传送任何物品"]:Destroy()
        end;
        local a = Instance.new("Tool", player.Backpack)
        a.Name = "点击传送任何物品"
        a.RequiresHandle = false;
        a.Activated:Connect(function()
            if Workspace:FindFirstChild("BRING") then
                local b = Workspace.BRING.CFrame;
                local c = Mouse.Target
                if c then
                    c = c.Parent
                else
                    return
                end
                
                if c:FindFirstChild("TreeClass") or c.Name == "Plank" or c:FindFirstChild("Type") then
                    if c:FindFirstChild("Owner") then
                        local e = c:FindFirstChildOfClass("Part")
                        pcall(function()
                            player.Character:MoveTo(e.CFrame.p)
                        end)
                        c.PrimaryPart = e;
                        for f = 1, 60 do
                            c.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
                            RS.Interaction.ClientIsDragging:FireServer(c)
                            c:PivotTo(b)
                            task.wait(0.01)
                        end
                    end
                end
            else
                WindUI:Notify({ Title = "错误", Content = "请先设置传送点位！", Duration = 3 })
            end
        end)
        WindUI:Notify({ Title = "获取成功", Content = "工具已发放至背包", Duration = 3 })
    end
})