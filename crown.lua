local player = game.Players.LocalPlayer
local TS = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Mouse = player:GetMouse()
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local WhitelistURL = "https://raw.githubusercontent.com/moos294/jooiionn/main/whitelist.txt"

local function CheckWhitelist()
    local success, response = pcall(function() return game:HttpGet(WhitelistURL) end)
    if not success or not response then return false end
    if string.find(response, player.Name) or string.find(response, tostring(player.UserId)) then return true end
    return false
end

if not CheckWhitelist() then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "系统提示", Text = "你并没有白名单无法用此脚本", Duration = 5})
    return 
end

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "验证成功", Text = "欢迎尊贵的白名单使用此脚本", Duration = 5})

local function CleanupAll()
    for i = 1, 3 do
        local bringPoint = Workspace:FindFirstChild("BRING"..i)
        if bringPoint then bringPoint:Destroy() end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, v in pairs(backpack:GetChildren()) do
            if v:IsA("Tool") and (string.find(v.Name, "空投工具") or v.Name == "点击传送" or v.Name == "多选框选工具") then
                v:Destroy()
            end
        end
    end
    local char = player.Character
    if char then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") and (string.find(v.Name, "空投工具") or v.Name == "点击传送" or v.Name == "多选框选工具") then
                v:Destroy()
            end
        end
    end
    local oldGui = CoreGui:FindFirstChild("封存木材")
    if oldGui then oldGui:Destroy() end
end

CleanupAll()

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "封存木材 V0.2",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Size = UDim2.fromOffset(420, 380),
    Transparent = true,
    Theme = "Dark"
})

local function DragModel(m, cf)
    pcall(function() 
        RS.Interaction.ClientIsDragging:FireServer("Begin", m, 4) 
        RS.Interaction.ClientIsDragging:FireServer("Refresh", m, 5)
    end)
    if not m.PrimaryPart then m.PrimaryPart = m:FindFirstChildOfClass("Part") end
    if m.PrimaryPart then 
        m.PrimaryPart.Velocity = Vector3.zero
        m:SetPrimaryPartCFrame(cf) 
    end
end

local TabCraft = Window:Tab({ Title = "合成物品", Icon = "rbxassetid://10734945123" })

TabCraft:Button({
    Title = "【一键清理】消除所有空投工具",
    Callback = function()
        local count = 0
        local backpack = player:FindFirstChild("Backpack")
        local char = player.Character
        if backpack then
            for _, v in pairs(backpack:GetChildren()) do
                if v:IsA("Tool") and string.find(v.Name, "空投工具") then
                    v:Destroy()
                    count = count + 1
                end
            end
        end
        if char then
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("Tool") and string.find(v.Name, "空投工具") then
                    v:Destroy()
                    count = count + 1
                end
            end
        end
        WindUI:Notify({ Title = "清理完毕", Content = "共消除了 "..count.." 个空投工具", Duration = 3 })
    end
})

TabCraft:Paragraph({ Title = "【 恶魔鸭材料破解 】", Color = Color3.fromRGB(255, 105, 180) })
local resultLabel = TabCraft:Paragraph({ Title = "点击下方按钮获取今日材料", Desc = "请先确保自己在私服内加载完地图" })

local evilNoteItemMap = {
    ["I CANT SEE"] = "老虎眼 (Eye3)",
    ["HATCHES INTO SOMETHING GREAT"] = "蛋 (Egg)",
    ["KEEP ME WARM"] = "热可可 (Cocoa)",
    ["GRANT ME LIGHT"] = "灯泡 (LightBulb)",
    ["QUACK QUACK"] = "鸭子 (Duck)",
    ["GRANT MY WISH"] = "神灯 (MagicLamp)",
    ["GREAT WITH COOKIES"] = "牛奶 (Milk)",
    ["CHEAT CODE"] = "游戏机 (NESController)",
    ["GIVE ME POWER"] = "电池 (Battery)",
    ["IM THIRSTY"] = "可乐 (BloxyCola)",
    ["CLAIMS TO BE HAPPY"] = "快乐球 (HappyBall)",
    ["WIELDED BY SOMEONE POWERFUL"] = "未知新物品"
}

local morse = {
    [".-"]="A",["-..."]="B",["-.-."]="C",["-.."]="D",["."]="E",["..-."]="F",["--."]="G",["...."]="H",
    [".."]="I",[".---"]="J",["-.-"]="K",[".-.."]="L",["--"]="M",["-."]="N",["---"]="O",[".--."]="P",
    ["--.-"]="Q",[".-."]="R",["..."]="S",["-"]="T",["..-"]="U",["...-"]="V",[".--"]="W",["-..-"]="X",
    ["-.--"]="Y",["--.."]="Z",["-----"]="0",[".----"]="1",["..---"]="2",["...--"]="3",["....-"]="4",
    ["....."]="5",["-...."]="6",["--..."]="7",["---.."]="8",["----."]="9"
}

TabCraft:Button({
    Title = "自动破解恶魔鸭合成材料",
    Callback = function()
        local stoneRUs = Workspace:FindFirstChild("Stores") and Workspace.Stores:FindFirstChild("StoneRUs")
        local parts = stoneRUs and stoneRUs:FindFirstChild("Parts")
        if not parts then
            WindUI:Notify({ Title = "失败", Content = "未找到 StoneRUs 商店", Duration = 3 })
            return
        end
        local text = ""
        for i = 1, 3 do
            local raw = ""
            local note = parts:FindFirstChild("Note"..i)
            if note then
                local gui = note:FindFirstChildOfClass("SurfaceGui")
                if gui then
                    for _, obj in pairs(gui:GetDescendants()) do
                        if obj:IsA("TextLabel") then
                            raw = obj.Text
                            break
                        end
                    end
                end
            end
            if raw ~= "" then
                local words = {}
                for w in raw:gmatch("[^/]+") do
                    local letters = {}
                    for l in w:gmatch("%S+") do
                        table.insert(letters, morse[l] or "?")
                    end
                    table.insert(words, table.concat(letters))
                end
                local decoded = table.concat(words, " ")
                text = text .. "Note"..i..": "..decoded.." ➔ 【 "..(evilNoteItemMap[decoded] or "未知").." 】\n"
            else
                text = text .. "Note"..i..": 内容为空\n"
            end
        end
        resultLabel:SetTitle("今日合成材料：")
        resultLabel:SetDesc(text)
    end
})

TabCraft:Button({
    Title = "自动敲击天使序列 (获取并拉回天堂鸭)",
    Callback = function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local oldCF = hrp.CFrame
        local preDucks = {}
        for _, m in pairs(Workspace.PlayerModels:GetChildren()) do
            if m.Name == "DuckAngel" then preDucks[m] = true end
        end
        hrp.CFrame = CFrame.new(184, 12, -2666)
        task.wait(0.2)
        local controller = Workspace:FindFirstChild("Stores") and Workspace.Stores:FindFirstChild("PlantomicsChoice") and Workspace.Stores.PlantomicsChoice:FindFirstChild("Parts") and Workspace.Stores.PlantomicsChoice.Parts:FindFirstChild("Controller") and Workspace.Stores.PlantomicsChoice.Parts.Controller:FindFirstChild("yes")
        if controller then
            for _, name in ipairs({"Up", "Up", "Down", "Down", "Left", "Right", "Left", "Right", "B", "A", "Start"}) do
                local part = controller:FindFirstChild(name)
                local click = part and part:FindFirstChildOfClass("ClickDetector")
                if click then
                    fireclickdetector(click, 1)
                    task.wait(0.2)
                end
            end
            WindUI:Notify({ Title = "序列完成", Content = "正在寻找掉落的天堂鸭...", Duration = 3 })
            local newDuck = nil
            for _=1, 20 do
                for _, m in pairs(Workspace.PlayerModels:GetChildren()) do
                    if m.Name == "DuckAngel" and not preDucks[m] then
                        newDuck = m
                        break
                    end
                end
                if newDuck then break end
                task.wait(0.2)
            end
            if newDuck then
                local p = newDuck.PrimaryPart or newDuck:FindFirstChild("Main") or newDuck:FindFirstChildWhichIsA("BasePart")
                if p then
                    hrp.CFrame = p.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.2)
                    for i = 1, 40 do
                        DragModel(newDuck, oldCF)
                        task.wait(0.02)
                    end
                    WindUI:Notify({ Title = "成功", Content = "天堂鸭已拉回原位", Duration = 3 })
                end
            else
                WindUI:Notify({ Title = "提示", Content = "未检测到新掉落的天堂鸭", Duration = 3 })
            end
        end
        hrp.CFrame = oldCF
    end
})

TabCraft:Paragraph({ Title = "【 三叉戟合成 】", Desc = "天堂鸭 / 星星鸭 / 恶魔鸭", Color = Color3.fromRGB(0, 255, 255) })
local Pos_Heaven = CFrame.new(-360.262, 14.753, -1333.273)
local Pos_Star = CFrame.new(-372.022, 15.158, -1330.268)
local Pos_Demon = CFrame.new(-383.149, 15.565, -1327.575)
local Pos_Altar = CFrame.new(-365.610, 12.621, -1319.532)
local dropTarget_Trident = Pos_Heaven

TabCraft:Button({
    Title = "传送到三叉戟祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达三叉戟祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择材料位置",
    Values = {"天堂鸭子 (左)", "星星鸭子 (中)", "恶魔鸭子 (右)"},
    Value = "天堂鸭子 (左)",
    Callback = function(opt)
        if opt == "天堂鸭子 (左)" then dropTarget_Trident = Pos_Heaven
        elseif opt == "星星鸭子 (中)" then dropTarget_Trident = Pos_Star
        else dropTarget_Trident = Pos_Demon end
    end
})

TabCraft:Button({
    Title = "获取【三叉戟空投工具】",
    Desc = "点击地上的物品直接瞬移入阵",
    Callback = function()
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具"
        tool.RequiresHandle = false
        tool.Activated:Connect(function()
            local t = Mouse.Target
            if t then
                for i = 1, 30 do DragModel(t.Parent, dropTarget_Trident) task.wait(0.01) end
            end
        end)
    end
})

TabCraft:Paragraph({ Title = "【 永恒剑合成 】", Desc = "三叉戟 / 复仇剑 / 恶魔鸭", Color = Color3.fromRGB(255, 150, 0) })
local Pos_Eternal_Trident = CFrame.new(-360.408, 14.757, -1333.086)
local Pos_Eternal_Revenge = CFrame.new(-371.428, 15.148, -1330.260)
local Pos_Eternal_Demon = CFrame.new(-382.908, 15.561, -1327.481)
local Pos_Eternal_Altar = CFrame.new(-367.265, 12.692, -1317.212)
local dropTarget_Eternal = Pos_Eternal_Trident

TabCraft:Button({
    Title = "传送到永恒剑祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Eternal_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达永恒剑祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择材料位置",
    Values = {"三叉戟 (左)", "复仇剑 (中)", "恶魔鸭子 (右)"},
    Value = "三叉戟 (左)",
    Callback = function(opt)
        if opt == "三叉戟 (左)" then dropTarget_Eternal = Pos_Eternal_Trident
        elseif opt == "复仇剑 (中)" then dropTarget_Eternal = Pos_Eternal_Revenge
        else dropTarget_Eternal = Pos_Eternal_Demon end
    end
})

TabCraft:Button({
    Title = "获取【永恒剑空投工具】",
    Desc = "点击地上的物品直接瞬移入阵",
    Callback = function()
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(永恒)"
        tool.RequiresHandle = false
        tool.Activated:Connect(function()
            local t = Mouse.Target
            if t then
                for i = 1, 30 do DragModel(t.Parent, dropTarget_Eternal) task.wait(0.01) end
            end
        end)
    end
})

TabCraft:Paragraph({ Title = "【 复仇剑合成 】", Desc = "恶魔鸭 / 天堂鸭", Color = Color3.fromRGB(255, 0, 0) })
local Pos_Revenge_Demon = CFrame.new(6487.173, -92.148, -4551.805)
local Pos_Revenge_Heaven = CFrame.new(6448.009, -93.535, -4523.665)
local Pos_Revenge_Altar = CFrame.new(6462.440, -94.916, -4543.508)
local dropTarget_Revenge = Pos_Revenge_Demon

TabCraft:Button({
    Title = "传送到复仇剑祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Revenge_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达复仇剑祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择材料位置",
    Values = {"恶魔鸭子", "天堂鸭子"},
    Value = "恶魔鸭子",
    Callback = function(opt)
        if opt == "恶魔鸭子" then dropTarget_Revenge = Pos_Revenge_Demon
        else dropTarget_Revenge = Pos_Revenge_Heaven end
    end
})

TabCraft:Button({
    Title = "获取【复仇剑空投工具】",
    Desc = "点击地上的物品直接瞬移入阵",
    Callback = function()
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(复仇)"
        tool.RequiresHandle = false
        tool.Activated:Connect(function()
            local t = Mouse.Target
            if t then
                for i = 1, 30 do DragModel(t.Parent, dropTarget_Revenge) task.wait(0.01) end
            end
        end)
    end
})

TabCraft:Paragraph({ Title = "【 星星鸭子合成 】", Desc = "天堂鸭 / 普通鸭 / 恶魔鸭", Color = Color3.fromRGB(200, 0, 255) })
local Pos_StarDuck_Heaven = CFrame.new(-7041.764, 391.973, 4906.096)
local Pos_StarDuck_Normal = CFrame.new(-7066.685, 392.111, 4898.619)
local Pos_StarDuck_Demon = CFrame.new(-7092.101, 392.085, 4890.774)
local Pos_StarDuck_Altar = CFrame.new(-7064.089, 390.357, 4885.606)
local dropTarget_StarDuck = Pos_StarDuck_Heaven

TabCraft:Button({
    Title = "传送到星星鸭子祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_StarDuck_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达星星鸭子祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择材料位置",
    Values = {"天堂鸭", "普通鸭", "恶魔鸭"},
    Value = "天堂鸭",
    Callback = function(opt)
        if opt == "天堂鸭" then dropTarget_StarDuck = Pos_StarDuck_Heaven
        elseif opt == "普通鸭" then dropTarget_StarDuck = Pos_StarDuck_Normal
        else dropTarget_StarDuck = Pos_StarDuck_Demon end
    end
})

TabCraft:Button({
    Title = "获取【星星鸭子空投工具】",
    Desc = "点击地上的物品直接瞬移入阵",
    Callback = function()
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(星星)"
        tool.RequiresHandle = false
        tool.Activated:Connect(function()
            local t = Mouse.Target
            if t then
                for i = 1, 30 do DragModel(t.Parent, dropTarget_StarDuck) task.wait(0.01) end
            end
        end)
    end
})

TabCraft:Paragraph({ Title = "【 地狱火合成 】", Desc = "三叉戟 / 恶魔鸭", Color = Color3.fromRGB(255, 69, 0) })
local Pos_Hellfire_Trident = CFrame.new(-1755.451, 346.302, 1478.264)
local Pos_Hellfire_Demon = CFrame.new(-1785.906, 346.302, 1495.925)
local Pos_Hellfire_Altar = CFrame.new(-1682.328, 349.602, 1477.501)
local dropTarget_Hellfire = Pos_Hellfire_Trident

TabCraft:Button({
    Title = "传送到地狱火祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Hellfire_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达地狱火祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择材料位置",
    Values = {"三叉戟", "恶魔鸭"},
    Value = "三叉戟",
    Callback = function(opt)
        if opt == "三叉戟" then dropTarget_Hellfire = Pos_Hellfire_Trident
        else dropTarget_Hellfire = Pos_Hellfire_Demon end
    end
})

TabCraft:Button({
    Title = "获取【地狱火空投工具】",
    Desc = "点击地上的物品直接瞬移入阵",
    Callback = function()
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(地狱火)"
        tool.RequiresHandle = false
        tool.Activated:Connect(function()
            local t = Mouse.Target
            if t then
                for i = 1, 30 do DragModel(t.Parent, dropTarget_Hellfire) task.wait(0.01) end
            end
        end)
    end
})

TabCraft:Paragraph({ Title = "【 天堂光环合成 】", Desc = "天堂鸭 / 永恒剑", Color = Color3.fromRGB(255, 255, 150) })
TabCraft:Paragraph({ Title = "⚠️ 前置任务提醒 ⚠️", Desc = "合成前，请先去【辐射商店】输入密码 444 把门打开！", Color = Color3.fromRGB(255, 0, 0) })
local Pos_Halo_HeavenDuck = CFrame.new(-678.179, 25.500, -404.403)
local Pos_Halo_EternalSword = CFrame.new(-680.807, 25.500, -413.101)
local Pos_Halo_Altar = CFrame.new(-670.157, 21.800, -412.872)
local dropTarget_Halo = Pos_Halo_HeavenDuck

TabCraft:Button({
    Title = "传送到天堂光环祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Halo_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达天堂光环祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择材料位置",
    Values = {"天堂鸭", "永恒剑"},
    Value = "天堂鸭",
    Callback = function(opt)
        if opt == "天堂鸭" then dropTarget_Halo = Pos_Halo_HeavenDuck
        else dropTarget_Halo = Pos_Halo_EternalSword end
    end
})

TabCraft:Button({
    Title = "获取【天堂光环空投工具】",
    Desc = "点击地上的物品直接瞬移入阵",
    Callback = function()
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(光环)"
        tool.RequiresHandle = false
        tool.Activated:Connect(function()
            local t = Mouse.Target
            if t then
                for i = 1, 30 do DragModel(t.Parent, dropTarget_Halo) task.wait(0.01) end
            end
        end)
    end
})

TabCraft:Paragraph({ Title = "【 天堂剑合成 】", Desc = "天堂光环 (雪山)", Color = Color3.fromRGB(255, 255, 255) })
local Pos_HeavenSword_Halo = CFrame.new(1662.831, 402.424, 3280.203)
local Pos_HeavenSword_Altar = CFrame.new(1659.923, 399.730, 3273.653)
local dropTarget_HeavenSword = Pos_HeavenSword_Halo

TabCraft:Button({
    Title = "传送到雪山天堂剑祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_HeavenSword_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达天堂剑祭坛", Duration = 3 })
        end
    end
})

TabCraft:Button({
    Title = "获取【天堂剑空投工具】",
    Desc = "点击地上的光环直接瞬移入阵",
    Callback = function()
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(天堂剑)"
        tool.RequiresHandle = false
        tool.Activated:Connect(function()
            local t = Mouse.Target
            if t then
                for i = 1, 30 do DragModel(t.Parent, dropTarget_HeavenSword) task.wait(0.01) end
            end
        end)
    end
})

local TimeLabel = TabCraft:Paragraph({ Title = "【 月牙合成 (限定傍晚) 】", Desc = "读取时间中...", Color = Color3.fromRGB(255, 215, 0) })

task.spawn(function()
    while task.wait(1) do
        local timeValue = Lighting.ClockTime
        local hour = math.floor(timeValue)
        local minute = math.floor((timeValue % 1) * 60)
        local timeStr = string.format("%02d:%02d", hour, minute)
        if timeValue >= 17 and timeValue <= 19 then
            TimeLabel:SetTitle("【 月牙合成 (已开启) 】")
            TimeLabel:SetDesc("游戏当前时间：" .. timeStr .. " | 祭坛已出现！")
            TimeLabel:SetColor(Color3.fromRGB(0, 255, 0))
        else
            TimeLabel:SetTitle("【 月牙合成 (未开启) 】")
            TimeLabel:SetDesc("游戏当前时间：" .. timeStr .. " | 祭坛未出现，需等待 17:00")
            TimeLabel:SetColor(Color3.fromRGB(255, 100, 100))
        end
    end
end)

local Pos_Moon_HeavenSword = CFrame.new(1491.958, 415.623, 3322.311)
local Pos_Moon_Hellfire = CFrame.new(1477.948, 415.623, 3327.516)
local Pos_Moon_Altar = CFrame.new(1482.868, 413.256, 3318.388)
local dropTarget_Moon = Pos_Moon_HeavenSword
local function IsEvening() return Lighting.ClockTime >= 17 and Lighting.ClockTime <= 19 end

TabCraft:Button({
    Title = "传送到月牙祭坛",
    Desc = "瞬间移动过去 (仅限傍晚)",
    Callback = function()
        if not IsEvening() then
            WindUI:Notify({ Title = "时间未到", Content = "当前不是傍晚 (17:00-19:00)，祭坛没有显现！", Duration = 5 })
            return
        end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_Moon_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达月牙祭坛", Duration = 3 })
        end
    end
})

TabCraft:Dropdown({
    Title = "选择材料位置",
    Values = {"天堂剑", "地狱火"},
    Value = "天堂剑",
    Callback = function(opt)
        if opt == "天堂剑" then dropTarget_Moon = Pos_Moon_HeavenSword
        else dropTarget_Moon = Pos_Moon_Hellfire end
    end
})

TabCraft:Button({
    Title = "获取【月牙空投工具】",
    Desc = "点击地上的物品直接瞬移入阵 (仅限傍晚)",
    Callback = function()
        if not IsEvening() then
            WindUI:Notify({ Title = "拒绝提供工具", Content = "游戏内当前时间：".. string.format("%.1f", Lighting.ClockTime) .."点，不是傍晚。请等到 17:00 再来！", Duration = 5 })
            return
        end
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(月牙)"
        tool.RequiresHandle = false
        tool.Activated:Connect(function()
            if not IsEvening() then
                WindUI:Notify({ Title = "时间过了", Content = "祭坛消失，物品无法放入！", Duration = 4 })
                return
            end
            local t = Mouse.Target
            if t then
                for i = 1, 30 do DragModel(t.Parent, dropTarget_Moon) task.wait(0.01) end
            end
        end)
    end
})

TabCraft:Paragraph({ Title = "【 月神剑合成 】", Desc = "月牙", Color = Color3.fromRGB(200, 200, 255) })
local Pos_MoonSword_Crescent = CFrame.new(-7648.661, 322.803, 4233.530)
local Pos_MoonSword_Altar = CFrame.new(-7642.798, 320.995, 4227.344)
local dropTarget_MoonSword = Pos_MoonSword_Crescent

TabCraft:Button({
    Title = "传送到月神剑祭坛",
    Desc = "瞬间移动到合成台前面",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = Pos_MoonSword_Altar
            WindUI:Notify({ Title = "传送成功", Content = "已到达月神剑祭坛", Duration = 3 })
        end
    end
})

TabCraft:Button({
    Title = "获取【月神剑空投工具】",
    Desc = "点击地上的月牙直接瞬移入阵",
    Callback = function()
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "空投工具(月神剑)"
        tool.RequiresHandle = false
        tool.Activated:Connect(function()
            local t = Mouse.Target
            if t then
                for i = 1, 30 do DragModel(t.Parent, dropTarget_MoonSword) task.wait(0.01) end
            end
        end)
    end
})

local TabTP = Window:Tab({ Title = "安全传送", Icon = "rbxassetid://10734945123" })
local targetTree = "Generic"
local playerPos = {nil, nil, nil}

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
    Title = "传送到树旁",
    Desc = "安全传送到树旁边的空地上",
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
        if targetWood and targetWood:FindFirstChild("WoodSection") then
            player.Character.HumanoidRootPart.CFrame = targetWood.WoodSection.CFrame + Vector3.new(0, 2.5, 3.5)
            WindUI:Notify({ Title = "成功", Content = "传送成功", Duration = 3 })
        else
            WindUI:Notify({ Title = "错误", Content = "没找到这种树", Duration = 3 })
        end
    end
})

for i = 1, 3 do
    TabTP:Button({
        Title = "保存当前位置为 传送点"..i,
        Callback = function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                playerPos[i] = player.Character.HumanoidRootPart.CFrame
                WindUI:Notify({ Title = "成功", Content = "已保存传送点"..i, Duration = 3 })
            end
        end
    })
    TabTP:Button({
        Title = "传送到 传送点"..i,
        Callback = function()
            if playerPos[i] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = playerPos[i]
                WindUI:Notify({ Title = "成功", Content = "已回到传送点"..i, Duration = 3 })
            else
                WindUI:Notify({ Title = "错误", Content = "未保存传送点"..i, Duration = 3 })
            end
        end
    })
end

local TabItem = Window:Tab({ Title = "物品传送", Icon = "rbxassetid://10882439086" })
local selectedBringTarget = "BRING1"
local selectedObjects = {}

TabItem:Dropdown({
    Title = "选择物品拉回的目标点",
    Values = {"拉回点位1", "拉回点位2", "拉回点位3"},
    Value = "拉回点位1",
    Callback = function(option)
        if option == "拉回点位1" then selectedBringTarget = "BRING1"
        elseif option == "拉回点位2" then selectedBringTarget = "BRING2"
        else selectedBringTarget = "BRING3" end
    end
})

for i = 1, 3 do
    TabItem:Button({
        Title = "设置 物品点位"..i,
        Callback = function()
            if Workspace:FindFirstChild("BRING"..i) then Workspace:FindFirstChild("BRING"..i):Destroy() end
            local p = Instance.new("Part", Workspace)
            p.Name = "BRING"..i
            p.Transparency = 1
            p.Anchored = true
            p.CFrame = player.Character.HumanoidRootPart.CFrame
            p.CanCollide = false
            p.Size = player.Character.HumanoidRootPart.Size
            
            local posBox = Instance.new("SelectionBox", p)
            posBox.Color3 = Color3.new(0, 255, 0)
            posBox.Adornee = p
            WindUI:Notify({ Title = "成功", Content = "物品点位"..i.."已设置", Duration = 3 })
        end
    })
end

TabItem:Button({
    Title = "获取点击传送工具",
    Desc = "拿在手上点击木头，直接拉回选中的点位",
    Callback = function()
        if player.Backpack:FindFirstChild("点击传送") or player.Character:FindFirstChild("点击传送") then
            player.Backpack["点击传送"]:Destroy()
        end
        local a = Instance.new("Tool", player.Backpack)
        a.Name = "点击传送"
        a.RequiresHandle = false
        a.Activated:Connect(function()
            if Workspace:FindFirstChild(selectedBringTarget) then
                local targetCFrame = Workspace[selectedBringTarget].CFrame
                local targetPart = Mouse.Target
                if not targetPart then return end
                local targetModel = targetPart.Parent
                if targetModel and (targetModel.Name == "Plank" or targetModel:FindFirstChild("WoodSection") or targetModel:FindFirstChild("Owner")) then
                    for i = 1, 40 do
                        DragModel(targetModel, targetCFrame)
                        task.wait(0.02)
                    end
                    WindUI:Notify({ Title = "传送成功", Content = "物品已拉回", Duration = 3 })
                end
            else
                WindUI:Notify({ Title = "错误", Content = "请先设置拉回点位", Duration = 3 })
            end
        end)
        WindUI:Notify({ Title = "成功", Content = "工具已放入背包", Duration = 3 })
    end
})

TabItem:Paragraph({ Title = "【 多选批量传送 】", Desc = "使用工具点击物品进行多选，然后一键传送", Color = Color3.fromRGB(0, 150, 255) })

TabItem:Button({
    Title = "获取【多选框选工具】",
    Desc = "点击物品添加蓝框，再次点击取消",
    Callback = function()
        if player.Backpack:FindFirstChild("多选框选工具") or player.Character:FindFirstChild("多选框选工具") then
            player.Backpack["多选框选工具"]:Destroy()
        end
        local tool = Instance.new("Tool", player.Backpack)
        tool.Name = "多选框选工具"
        tool.RequiresHandle = false
        tool.Activated:Connect(function()
            local targetPart = Mouse.Target
            if not targetPart then return end
            local targetModel = targetPart.Parent
            if targetModel and (targetModel:IsA("Model") or targetModel:IsA("BasePart")) then
                local isSelected = false
                for i, obj in pairs(selectedObjects) do
                    if obj == targetModel then
                        table.remove(selectedObjects, i)
                        isSelected = true
                        if targetPart:FindFirstChild("BlueSelectBox") then
                            targetPart.BlueSelectBox:Destroy()
                        elseif targetModel:FindFirstChild("BlueSelectBox") then
                            targetModel.BlueSelectBox:Destroy()
                        end
                        WindUI:Notify({ Title = "取消选中", Content = targetModel.Name, Duration = 2 })
                        break
                    end
                end
                if not isSelected then
                    table.insert(selectedObjects, targetModel)
                    local box = Instance.new("SelectionBox")
                    box.Name = "BlueSelectBox"
                    box.Adornee = targetModel
                    box.Color3 = Color3.fromRGB(0, 150, 255)
                    box.LineThickness = 0.05
                    box.Parent = targetModel
                    WindUI:Notify({ Title = "已选中", Content = targetModel.Name, Duration = 2 })
                end
            end
        end)
        WindUI:Notify({ Title = "成功", Content = "多选框选工具已放入背包", Duration = 3 })
    end
})

TabItem:Button({
    Title = "清除所有选中(蓝框)",
    Callback = function()
        for i = #selectedObjects, 1, -1 do
            local obj = selectedObjects[i]
            if obj then
                if obj:FindFirstChild("BlueSelectBox") then obj.BlueSelectBox:Destroy() end
                table.remove(selectedObjects, i)
            end
        end
        WindUI:Notify({ Title = "已清空", Content = "所有选中的物品已取消", Duration = 3 })
    end
})

TabItem:Button({
    Title = "【一键传送所有选中物品】",
    Desc = "将所有蓝框物品拉到选定的拉回点位",
    Callback = function()
        if not Workspace:FindFirstChild(selectedBringTarget) then
            WindUI:Notify({ Title = "错误", Content = "请先设置拉回点位", Duration = 3 })
            return
        end
        local targetCFrame = Workspace[selectedBringTarget].CFrame
        local count = 0
        for i = #selectedObjects, 1, -1 do
            local obj = selectedObjects[i]
            if obj and obj.Parent then
                for j = 1, 40 do DragModel(obj, targetCFrame) task.wait(0.02) end
                if obj:FindFirstChild("BlueSelectBox") then obj.BlueSelectBox:Destroy() end
                table.remove(selectedObjects, i)
                count = count + 1
            else
                table.remove(selectedObjects, i)
            end
        end
        WindUI:Notify({ Title = "传送完毕", Content = "成功传送了 "..count.." 个物品", Duration = 3 })
    end
})

TabItem:Paragraph({ Title = "新增：卖木头 & 鸭子拉回", Color = Color3.fromRGB(0, 150, 255) })

local function New_SellAllWood()
    local lm = Workspace:FindFirstChild("LogModels")
    if not lm then return end
    local list = {}
    for _, m in pairs(lm:GetChildren()) do
        if m:FindFirstChild("Owner") and m.Owner.Value == player and m:FindFirstChild("TreeClass") then
            table.insert(list, m)
        end
    end
    if #list == 0 then return WindUI:Notify({Title="提示",Content="没有木头"}) end
    local SELL_CF = CFrame.new(314.508514, -0.303692758, 86.5952911)
    local orig = player.Character.HumanoidRootPart.CFrame
    for _, m in ipairs(list) do
        if m.Parent then
            local p = m.PrimaryPart or m:FindFirstChild("WoodSection")
            if p then
                player.Character.HumanoidRootPart.CFrame = p.CFrame + Vector3.new(0,3,0)
                task.wait(0.1)
                for i=1, 40 do DragModel(m, SELL_CF) task.wait(0.01) end
                player.Character.HumanoidRootPart.CFrame = SELL_CF + Vector3.new(0,3,0)
                task.wait(0.5)
            end
        end
    end
    player.Character.HumanoidRootPart.CFrame = orig
    WindUI:Notify({Title="完成",Content="木头已卖完"})
end

TabItem:Button({ Title = "一键卖掉所有原木", Callback = function() task.spawn(New_SellAllWood) end })

local duckList = {"DuckAngel", "DuckEvil", "LunarDuck", "Duck", "2018CGift_Duck"}
local selectedDuck = "DuckAngel"

TabItem:Dropdown({
    Title = "选择鸭子",
    Values = {"天堂鸭", "恶魔鸭", "月亮鸭", "普通鸭", "礼物鸭"},
    Value = "天堂鸭",
    Callback = function(opt)
        if opt == "天堂鸭" then selectedDuck = "DuckAngel"
        elseif opt == "恶魔鸭" then selectedDuck = "DuckEvil"
        elseif opt == "月亮鸭" then selectedDuck = "LunarDuck"
        elseif opt == "普通鸭" then selectedDuck = "Duck"
        else selectedDuck = "2018CGift_Duck" end
    end
})

TabItem:Button({
    Title = "拉回全图【自己的】鸭子",
    Callback = function()
        local start = player.Character.HumanoidRootPart.CFrame
        local count = 0
        for _, m in pairs(Workspace.PlayerModels:GetChildren()) do
            if m.Name == selectedDuck and m:FindFirstChild("Owner") and m.Owner.Value == player then
                local p = m.PrimaryPart or m:FindFirstChild("Main") or m:FindFirstChildWhichIsA("BasePart")
                if p then
                    player.Character.HumanoidRootPart.CFrame = p.CFrame + Vector3.new(0,2,0)
                    task.wait(0.1)
                    for i=1, 30 do DragModel(m, start) task.wait(0.01) end
                    count = count + 1
                end
            end
        end
        player.Character.HumanoidRootPart.CFrame = start
        WindUI:Notify({Title="完成",Content="拉回 "..count.." 只"})
    end
})

local TabServer = Window:Tab({ Title = "服务器", Icon = "rbxassetid://10882439086" })
local targetPlaceId = tostring(game.PlaceId)

TabServer:Input({
    Title = "指定服务器 ID",
    Value = tostring(game.PlaceId),
    Callback = function(text) targetPlaceId = text end
})

local function getServerList(pid)
    local candidates = {}
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(pid)
    local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if ok and res and res.data then
        for _, s in ipairs(res.data) do
            if s.id ~= game.JobId and s.playing >= 2 and s.playing <= s.maxPlayers - 2 then
                table.insert(candidates, s.id)
            end
        end
    end
    return candidates
end

TabServer:Button({
    Title = "重进当前服务器",
    Desc = "经典底层重连法",
    Callback = function()
        local success, err = pcall(function()
            if game.PrivateServerId and game.PrivateServerId ~= "" then
                TS:TeleportToPrivateServer(game.PlaceId, game.PrivateServerId, {player})
            else
                TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            end
        end)
        if not success then
            WindUI:Notify({ Title = "传送失败", Content = "请稍等10秒后再试 (773防刷限制)", Duration = 5 })
        end
    end
})

TabServer:Button({
    Title = "刷新当前服务器 (原地重连)",
    Desc = "拿天堂鸭专用，不换服，刷新一次拿取状态",
    Callback = function()
        WindUI:Notify({Title="重连中",Content="3秒后断开重连...", Duration=3})
        task.wait(3)
        local success, err = pcall(function()
            if game.PrivateServerId and game.PrivateServerId ~= "" then
                TS:TeleportToPrivateServer(game.PlaceId, game.PrivateServerId, {player})
            else
                TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            end
        end)
        if not success then
            player:Kick("重连刷新中...")
        end
    end
})

TabServer:Button({
    Title = "指定服务器换服",
    Desc = "需在上方填写 PlaceId，精准抓取新服",
    Callback = function()
        local id = tonumber(targetPlaceId)
        if id then
            local servers = getServerList(id)
            if #servers > 0 then
                local randomJobId = servers[math.random(1, #servers)]
                pcall(function() TS:TeleportToPlaceInstance(id, randomJobId, player) end)
            else
                pcall(function() TS:Teleport(id, player) end)
            end
        else
            WindUI:Notify({ Title = "错误", Content = "服务器 ID 格式不正确", Duration = 3 })
        end
    end
})

TabServer:Button({
    Title = "随机换服",
    Desc = "使用官方API获取真实JobId，秒进",
    Callback = function()
        local servers = getServerList(game.PlaceId)
        if #servers > 0 then
            local randomJobId = servers[math.random(1, #servers)]
            pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, randomJobId, player) end)
        else
            pcall(function() TS:Teleport(game.PlaceId, player) end)
        end
    end
})

local TabExtra = Window:Tab({ Title = "其他功能", Icon = "rbxassetid://10882439086" })

TabExtra:Paragraph({ Title = "【 自动购买普通鸭子 】", Desc = "靠近 FineFinds 商店附近，点开始自动购买并拉回", Color = Color3.fromRGB(0, 180, 255) })

local function notify(title, desc, duration)
    WindUI:Notify({
        Title = tostring(title or "通知"),
        Content = tostring(desc or ""),
        Duration = tonumber(duration) or 3,
    })
end

local DUCK_DRAG_TOTAL = 60
local DUCK_DRAG_SET_START = 28
local DUCK_DRAG_SET_COUNT = 2
local DUCK_DRAG_SET_INTERVAL = 0.01
local DUCK_DRAG_REFRESH_INTERVAL = 0.01
local DUCK_DRAG_AFTER_WAIT = 0.01
local duckDragIDCounter = 0
local duckLockConn = nil
local duckNpcIdCache = nil

local function duckGetNextDragID()
    duckDragIDCounter = duckDragIDCounter + 1
    return duckDragIDCounter
end

local function duckUprightCFrame(hrp, cf)
    local pos = cf.Position
    local yRot = hrp and hrp.Orientation.Y or 0
    return CFrame.new(pos) * CFrame.Angles(0, math.rad(yRot), 0)
end

local function duckSafeTeleport(cf)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = duckUprightCFrame(hrp, cf)
        task.wait(0.05)
        if hrp.Position.Y < -100 then
            hrp.CFrame = duckUprightCFrame(hrp, cf) + Vector3.new(0, 10, 0)
        end
    end
end

local function duckUnlockPlayer()
    if duckLockConn then
        duckLockConn:Disconnect()
        duckLockConn = nil
    end
end

local function duckLockPlayerAt(cf)
    duckUnlockPlayer()
    local function hold()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = duckUprightCFrame(hrp, cf)
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
    hold()
    duckLockConn = RunService.Heartbeat:Connect(hold)
end

local function duckDragToPosition(model, targetCF, callback, waitFinish)
    if not model or not model.Parent then
        if callback then callback() end
        return
    end
    local primary = model.PrimaryPart
        or model:FindFirstChild("WoodSection")
        or model:FindFirstChild("Main")
        or model:FindFirstChildWhichIsA("BasePart")
    if not primary then
        if callback then callback() end
        return
    end
    if not model.PrimaryPart then model.PrimaryPart = primary end

    duckLockPlayerAt(primary.CFrame + Vector3.new(0, 3, 0))

    local dragID = duckGetNextDragID()
    local remote = RS.Interaction.ClientIsDragging
    pcall(function() RS.Interaction.ClientRequestOwnership:FireServer(primary) end)
    pcall(function() remote:FireServer("Begin", model, dragID) end)

    local lastSet = DUCK_DRAG_SET_START + DUCK_DRAG_SET_COUNT - 1
    for i = 1, lastSet do
        if not model.Parent or not model.PrimaryPart then
            pcall(function() remote:FireServer("End", model, dragID) end)
            if callback then callback() end
            return
        end
        local shouldSet = (i >= DUCK_DRAG_SET_START)
        pcall(function()
            remote:FireServer("Refresh", model, dragID)
            if shouldSet then
                RS.Interaction.ClientRequestOwnership:FireServer(primary)
                model:SetPrimaryPartCFrame(targetCF)
            end
        end)
        if i < lastSet then
            if shouldSet then
                task.wait(DUCK_DRAG_SET_INTERVAL)
            else
                task.wait(DUCK_DRAG_REFRESH_INTERVAL)
            end
        end
    end

    task.wait(DUCK_DRAG_AFTER_WAIT)

    local dragEnded = false
    task.spawn(function()
        for i = lastSet + 1, DUCK_DRAG_TOTAL do
            if not model.Parent or not model.PrimaryPart then break end
            pcall(function() remote:FireServer("Refresh", model, dragID) end)
            if i < DUCK_DRAG_TOTAL then
                task.wait(DUCK_DRAG_REFRESH_INTERVAL)
            end
        end
        pcall(function() remote:FireServer("End", model, dragID) end)
        dragEnded = true
    end)

    if waitFinish then
        local w = 0
        while w < 1.5 and not dragEnded do
            task.wait(0.05)
            w = w + 0.05
        end
        for _ = 1, 3 do
            if not model.Parent or not model.PrimaryPart then break end
            local d = (model.PrimaryPart.Position - targetCF.Position).Magnitude
            if d <= 3 then break end
            pcall(function() remote:FireServer("Refresh", model, dragID) end)
        end
    end

    task.wait(0.4)

    local verify = 0
    while model.Parent and model.PrimaryPart and verify < 2 do
        local dist = (model.PrimaryPart.Position - targetCF.Position).Magnitude
        if dist <= 3 then break end
        verify = verify + 1
        duckLockPlayerAt(primary.CFrame + Vector3.new(0, 3, 0))
        task.wait(0.15)
        local retryID = duckGetNextDragID()
        pcall(function() RS.Interaction.ClientRequestOwnership:FireServer(primary) end)
        pcall(function() remote:FireServer("Begin", model, retryID) end)
        for _ = 1, 10 do
            if not model.Parent then break end
            pcall(function() RS.Interaction.ClientRequestOwnership:FireServer(primary) end)
            pcall(function() remote:FireServer("Refresh", model, retryID) end)
            pcall(function() model:SetPrimaryPartCFrame(targetCF) end)
            task.wait(0.05)
        end
        pcall(function() remote:FireServer("End", model, retryID) end)
        task.wait(0.15)
    end

    duckUnlockPlayer()
    if callback then callback() end
end

local function duckGetAllCashierIds()
    local cashierIds = {}
    local conn = RS.NPCDialog.PromptChat.OnClientEvent:Connect(function(...)
        local pack = { ... }
        for _, v in ipairs(pack) do
            if type(v) == "table" and v.Name ~= nil and v.ID ~= nil then
                if not cashierIds[v.Name] then
                    cashierIds[v.Name] = v.ID
                end
            end
        end
    end)
    pcall(function() RS.NPCDialog.SetChattingValue:InvokeServer(1) end)
    local startTime = tick()
    while not cashierIds["Manachron"] and tick() - startTime < 15 do
        task.wait(0.2)
    end
    conn:Disconnect()
    pcall(function() RS.NPCDialog.SetChattingValue:InvokeServer(0) end)
    return cashierIds
end

local function duckGetNpcId()
    if duckNpcIdCache then return duckNpcIdCache end
    local ids = duckGetAllCashierIds()
    duckNpcIdCache = ids["Manachron"]
    return duckNpcIdCache
end

local function duckBuyCrate()
    local fineFinds = Workspace.Stores:FindFirstChild("FineFinds")
    if not fineFinds then return nil, "找不到商店" end
    local npcChar = fineFinds:FindFirstChild("Manachron")
    if not npcChar then return nil, "找不到NPC" end

    local npcId = duckGetNpcId()
    if not npcId then return nil, "无法获取NPC ID（可点重置缓存再试）" end

    local counter = fineFinds:FindFirstChild("Counter")
    if not counter or not counter:IsA("BasePart") then return nil, "找不到Counter" end

    local shopItems = fineFinds:FindFirstChild("ShopItems")
    if not shopItems then return nil, "无ShopItems" end

    local crateItem = shopItems:FindFirstChild("Crate")
    if not crateItem then
        for _ = 1, 10 do
            crateItem = shopItems:FindFirstChild("Crate")
            if crateItem then break end
            task.wait(0.15)
        end
        if not crateItem then return nil, "Crate不在货架" end
    end

    local primary = crateItem.PrimaryPart
        or crateItem:FindFirstChild("WoodSection")
        or crateItem:FindFirstChild("Main")
        or crateItem:FindFirstChildWhichIsA("BasePart")
    if not primary then return nil, "无法定位商品" end
    if not crateItem.PrimaryPart then crateItem.PrimaryPart = primary end

    duckLockPlayerAt(primary.CFrame + Vector3.new(0, 3, 0))
    task.wait(0.2)

    local counterSurface = counter.CFrame + Vector3.new(0, 0.6, 0)
    duckDragToPosition(crateItem, counterSurface, nil, true)

    duckLockPlayerAt(counter.CFrame + Vector3.new(0, 3, 0))
    task.wait(0.1)

    local NPCDialog = RS:WaitForChild("NPCDialog")
    local purchased = {}
    local conn = Workspace.PlayerModels.ChildAdded:Connect(function(m)
        if m:IsA("Model") and m:FindFirstChild("Owner") and m.Owner.Value == player then
            table.insert(purchased, m)
        end
    end)
    local args = { { ID = npcId, Character = npcChar, Name = "Manachron" }, "ConfirmPurchase" }
    local ok, err = pcall(function()
        NPCDialog.PlayerChatted:InvokeServer(table.unpack(args))
    end)
    task.wait(0.5)
    conn:Disconnect()
    duckUnlockPlayer()

    if not ok then return nil, "购买请求失败: " .. tostring(err) end
    return purchased[1], "成功"
end

local autoDuckTarget = 1
local isAutoBuyingDuck = false
local duckStopFlag = false

local function autoGetGiftDuckDirect(targetCount)
    targetCount = targetCount or 1
    if isAutoBuyingDuck then
        notify("自动购买普通鸭", "任务已在运行中", 2)
        return
    end
    isAutoBuyingDuck = true
    duckStopFlag = false

    local successCount = 0
    local startPos = player.Character and player.Character.HumanoidRootPart.CFrame
    if not startPos then
        notify("自动购买普通鸭", "无法获取玩家起始位置", 3)
        isAutoBuyingDuck = false
        return
    end

    local function getPlayerPos()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        return hrp and hrp.Position or nil
    end

    local function getMyDucks()
        local ducks = {}
        for _, m in pairs(Workspace.PlayerModels:GetChildren()) do
            if m:IsA("Model") and m.Name == "2018CGift_Duck" then
                local owner = m:FindFirstChild("Owner")
                if owner and owner.Value == player then
                    table.insert(ducks, m)
                end
            end
        end
        return ducks
    end

    local initialDucks = {}
    for _, d in ipairs(getMyDucks()) do initialDucks[d] = true end
    local initialCount = #getMyDucks()
    notify("自动购买普通鸭", "初始鸭子数: " .. initialCount, 2)

    local function syncDragToPosition(model, targetCF, timeout)
        timeout = timeout or 5
        local done, success = false, false
        duckDragToPosition(model, targetCF, function()
            done = true
            success = true
        end)
        local startTime = tick()
        while not done and tick() - startTime < timeout do
            task.wait(0.1)
        end
        return success
    end

    local attempt = 0
    while isAutoBuyingDuck and not duckStopFlag and successCount < targetCount do
        attempt = attempt + 1
        notify("自动购买普通鸭", string.format("购买 #%d (已获得 %d/%d)", attempt, successCount, targetCount), 2)

        local crate, msg = duckBuyCrate()
        if not crate then
            notify("自动购买普通鸭", "购买失败: " .. tostring(msg), 2)
            task.wait(0.15)
            if duckStopFlag then break end
            local currentDucks = getMyDucks()
            if #currentDucks > initialCount then
                for _, d in ipairs(currentDucks) do
                    if not initialDucks[d] and d.Parent then
                        if not d.PrimaryPart then
                            local prim = d:FindFirstChild("Main") or d:FindFirstChildWhichIsA("BasePart")
                            if prim then d.PrimaryPart = prim end
                        end
                        if d.PrimaryPart then
                            duckSafeTeleport(d.PrimaryPart.CFrame + Vector3.new(0, 2, 0))
                            task.wait(0.2)
                            if syncDragToPosition(d, startPos) then
                                duckSafeTeleport(startPos)
                                successCount = successCount + 1
                                initialDucks[d] = true
                                initialCount = initialCount + 1
                                notify("自动购买普通鸭", string.format("鸭子已带回 (%d/%d)", successCount, targetCount), 3)
                                break
                            end
                        end
                    end
                end
            end
            if duckStopFlag then break end
            continue
        end

        local playerPos = getPlayerPos()
        if not playerPos then
            notify("自动购买普通鸭", "位置丢失", 2)
            continue
        end

        local candidates = {}
        for _, m in pairs(Workspace.PlayerModels:GetChildren()) do
            if m:IsA("Model") and m:FindFirstChild("Owner") and m.Owner.Value == player then
                local name = m.Name
                if name:find("Crate Purchased by") or name:find("crate purchased by") then
                    local prim = m.PrimaryPart or m:FindFirstChild("Main") or m:FindFirstChildWhichIsA("BasePart")
                    if prim then
                        local d = (prim.Position - playerPos).Magnitude
                        if d <= 50 then
                            table.insert(candidates, { model = m, dist = d })
                        end
                    end
                end
            end
        end

        if #candidates == 0 then
            notify("自动购买普通鸭", "未找到板条箱（50米）", 2)
            continue
        end

        notify("自动购买普通鸭", string.format("找到 %d 个板条箱，全部打开", #candidates), 2)
        table.sort(candidates, function(a, b) return a.dist < b.dist end)

        for _, cand in ipairs(candidates) do
            if duckStopFlag then break end
            pcall(function()
                RS.Interaction.ClientInteracted:FireServer(cand.model, "Open box")
            end)
            task.wait(0.1)
        end

        task.wait(0.2)

        local buttonCrates = {}
        for _, m in pairs(Workspace.PlayerModels:GetChildren()) do
            if m:IsA("Model") and m.Name == "Crate" then
                local owner = m:FindFirstChild("Owner")
                if owner and owner.Value == player then
                    local prim = m.PrimaryPart or m:FindFirstChild("Main") or m:FindFirstChildWhichIsA("BasePart")
                    if prim and (prim.Position - playerPos).Magnitude <= 50 then
                        table.insert(buttonCrates, m)
                    end
                end
            end
        end

        if #buttonCrates > 0 then
            notify("自动购买普通鸭", string.format("找到 %d 个可点击的 Crate", #buttonCrates), 2)
            for _, crateModel in ipairs(buttonCrates) do
                if duckStopFlag then break end
                local btn = crateModel:FindFirstChild("ButtonRemote_Main")
                if btn then
                    pcall(function()
                        RS.Interaction.RemoteProxy:FireServer(btn)
                    end)
                end
                task.wait(0.04)
            end
        else
            notify("自动购买普通鸭", "未找到可点击的 Crate", 2)
        end

        task.wait(0.5)

        local currentDucks = getMyDucks()
        if #currentDucks > initialCount then
            for _, d in ipairs(currentDucks) do
                if not initialDucks[d] and d.Parent then
                    if not d.PrimaryPart then
                        local prim = d:FindFirstChild("Main") or d:FindFirstChildWhichIsA("BasePart")
                        if prim then d.PrimaryPart = prim end
                    end
                    if d.PrimaryPart then
                        duckSafeTeleport(d.PrimaryPart.CFrame + Vector3.new(0, 2, 0))
                        task.wait(0.2)
                        if syncDragToPosition(d, startPos) then
                            duckSafeTeleport(startPos)
                            successCount = successCount + 1
                            initialDucks[d] = true
                            initialCount = initialCount + 1
                            notify("自动购买普通鸭", string.format("鸭子已带回 (%d/%d)", successCount, targetCount), 3)
                        end
                    end
                end
            end
        else
            notify("自动购买普通鸭", "未出鸭", 2)
        end

        if successCount >= targetCount then break end
        notify("自动购买普通鸭", "未达标，继续购买", 2)
        task.wait(0.08)
    end

    if duckStopFlag then
        notify("自动购买普通鸭", "已停止", 2)
    elseif successCount >= targetCount then
        notify("自动购买普通鸭", string.format("成功获取 %d 只鸭子", successCount), 3)
    else
        notify("自动购买普通鸭", "任务结束，未达到目标", 3)
    end

    duckSafeTeleport(startPos)
    isAutoBuyingDuck = false
    duckStopFlag = false
end

TabExtra:Input({
    Title = "目标获取数量",
    Value = "1",
    Callback = function(v)
        local n = tonumber(v)
        if n and n > 0 then autoDuckTarget = math.floor(n) end
    end,
})

TabExtra:Button({
    Title = "开始自动购买普通鸭",
    Desc = "首次点会花 5~15 秒自动获取 NPC ID，请耐心等",
    Callback = function()
        task.spawn(function() autoGetGiftDuckDirect(autoDuckTarget) end)
    end,
})

TabExtra:Button({
    Title = "停止自动购买普通鸭",
    Callback = function()
        if isAutoBuyingDuck then
            duckStopFlag = true
            notify("自动购买普通鸭", "正在停止...", 2)
        else
            notify("自动购买普通鸭", "当前没有运行中的任务", 2)
        end
    end,
})

TabExtra:Button({
    Title = "重置 NPC ID 缓存",
    Desc = "如果首次获取 ID 失败，点此重置再试",
    Callback = function()
        duckNpcIdCache = nil
        notify("自动购买普通鸭", "NPC ID 缓存已重置", 2)
    end,
})

TabExtra:Button({
    Title = "开启飞行",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/385j8888/ZOUMAGUIX/refs/heads/main/%E9%A3%9E%E8%A1%8C%E8%84%9A%E6%9C%ACV3(%E5%85%A8%E6%B8%B8%E6%88%8F%E9%80%9A%E7%94%A8).txt"))()
        end)
    end
})

TabExtra:Button({
    Title = "彻底关闭并清理缓存",
    Desc = "关闭UI并清除所有残留工具与点位",
    Callback = function() CleanupAll() end
})