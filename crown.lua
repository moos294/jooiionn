local player = game.Players.LocalPlayer
local TS = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Mouse = player:GetMouse()
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

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
    isDragEnabled = false
    if dragConn then
        dragConn:Disconnect()
        dragConn = nil
    end
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
    Title = "封存木材 V1.0",
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
    Desc = "清理背包里多余的合成工具",
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

TabCraft:Paragraph({ Title = "【 恶魔鸭材料破解 】", Desc = "自动解析商店的摩斯密码", Color = Color3.fromRGB(255, 105, 180) })
local resultLabel = TabCraft:Paragraph({ Title = "点击下方按钮获取今日材料", Desc = "请先确保自己在私服内加载完地图" })
local evilNoteItemMap = { ["I CANT SEE"] = "Eye3", ["HATCHES INTO SOMETHING GREAT"] = "Egg", ["KEEP ME WARM"] = "Cocoa", ["GRANT ME LIGHT"] = "LightBulb", ["QUACK QUACK"] = "Duck", ["GRANT MY WISH"] = "MagicLamp", ["GREAT WITH COOKIES"] = "Milk", ["CHEAT CODE"] = "NESController", ["GIVE ME POWER"] = "Battery", ["IM THIRSTY"] = "BloxyCola", ["CLAIMS TO BE HAPPY"] = "HappyBall" }
local morse = { [".-"]="A",["-..."]="B",["-.-."]="C",["-.."]="D",["."]="E",["..-."]="F",["--."]="G",["...."]="H",[".."]="I",[".---"]="J",["-.-"]="K",[".-.."]="L",["--"]="M",["-."]="N",["---"]="O",[".--."]="P",["--.-"]="Q",[".-."]="R",["..."]="S",["-"]="T",["..-"]="U",["...-"]="V",[".--"]="W",["-..-"]="X",["-.--"]="Y",["--.."]="Z",["-----"]="0",[".----"]="1",["..---"]="2",["...--"]="3",["....-"]="4",["....."]="5",["-...."]="6",["--..."]="7",["---.."]="8",["----."]="9" }

TabCraft:Button({
    Title = "自动破解恶魔鸭合成材料",
    Callback = function()
        local stoneRUs = Workspace:FindFirstChild("Stores") and Workspace.Stores:FindFirstChild("StoneRUs")
        local parts = stoneRUs and stoneRUs:FindFirstChild("Parts")
        if not parts then WindUI:Notify({ Title = "失败", Content = "未找到 StoneRUs 商店", Duration = 3 }) return end
        local text = ""
        for i = 1, 3 do
            local raw = ""
            local note = parts:FindFirstChild("Note"..i)
            if note then
                local gui = note:FindFirstChildOfClass("SurfaceGui")
                if gui then for _, obj in pairs(gui:GetDescendants()) do if obj:IsA("TextLabel") then raw = obj.Text break end end end
            end
            if raw ~= "" then
                local words = {}
                for w in raw:gmatch("[^/]+") do
                    local letters = {}
                    for l in w:gmatch("%S+") do table.insert(letters, morse[l] or "?") end
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
    Title = "自动敲击天使序列 (获取天堂鸭)",
    Callback = function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local oldCF = hrp.CFrame
        hrp.CFrame = CFrame.new(184, 12, -2666)
        task.wait(0.2)
        local controller = Workspace:FindFirstChild("Stores") and Workspace.Stores:FindFirstChild("PlantomicsChoice") and Workspace.Stores.PlantomicsChoice:FindFirstChild("Parts") and Workspace.Stores.PlantomicsChoice.Parts:FindFirstChild("Controller") and Workspace.Stores.PlantomicsChoice.Parts.Controller:FindFirstChild("yes")
        if controller then
            for _, name in ipairs({"Up", "Up", "Down", "Down", "Left", "Right", "Left", "Right", "B", "A", "Start"}) do
                local part = controller:FindFirstChild(name)
                local click = part and part:FindFirstChildOfClass("ClickDetector")
                if click then fireclickdetector(click, 1) task.wait(0.2) end
            end
            WindUI:Notify({ Title = "序列完成", Content = "请检查鸭子是否掉落", Duration = 3 })
        end
        hrp.CFrame = oldCF
    end
})

TabCraft:Paragraph({ Title = "【 三叉戟合成 】", Desc = "天堂鸭 / 星星鸭 / 恶魔鸭", Color = Color3.fromRGB(0, 255, 255) })
local Pos_Heaven, Pos_Star, Pos_Demon, Pos_Altar = CFrame.new(-360.262, 14.753, -1333.273), CFrame.new(-372.022, 15.158, -1330.268), CFrame.new(-383.149, 15.565, -1327.575), CFrame.new(-365.610, 12.621, -1319.532)
local dropTarget_Trident = Pos_Heaven
TabCraft:Button({ Title = "传送到三叉戟祭坛", Callback = function() if player.Character then player.Character.HumanoidRootPart.CFrame = Pos_Altar end end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂鸭子 (左)", "星星鸭子 (中)", "恶魔鸭子 (右)"}, Value = "天堂鸭子 (左)", Callback = function(opt) if opt == "天堂鸭子 (左)" then dropTarget_Trident = Pos_Heaven elseif opt == "星星鸭子 (中)" then dropTarget_Trident = Pos_Star else dropTarget_Trident = Pos_Demon end end })
TabCraft:Button({ Title = "获取【三叉戟空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack) tool.Name = "空投工具" tool.RequiresHandle = false
    tool.Activated:Connect(function() local t = Mouse.Target if t then for i=1, 30 do DragModel(t.Parent, dropTarget_Trident) task.wait(0.01) end end end)
end })

TabCraft:Paragraph({ Title = "【 永恒剑合成 】", Desc = "三叉戟 / 复仇剑 / 恶魔鸭", Color = Color3.fromRGB(255, 150, 0) })
local Pos_Eternal_Trident, Pos_Eternal_Revenge, Pos_Eternal_Demon, Pos_Eternal_Altar = CFrame.new(-360.408, 14.757, -1333.086), CFrame.new(-371.428, 15.148, -1330.260), CFrame.new(-382.908, 15.561, -1327.481), CFrame.new(-367.265, 12.692, -1317.212)
local dropTarget_Eternal = Pos_Eternal_Trident
TabCraft:Button({ Title = "传送到永恒剑祭坛", Callback = function() if player.Character then player.Character.HumanoidRootPart.CFrame = Pos_Eternal_Altar end end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"三叉戟 (左)", "复仇剑 (中)", "恶魔鸭子 (右)"}, Value = "三叉戟 (左)", Callback = function(opt) if opt == "三叉戟 (左)" then dropTarget_Eternal = Pos_Eternal_Trident elseif opt == "复仇剑 (中)" then dropTarget_Eternal = Pos_Eternal_Revenge else dropTarget_Eternal = Pos_Eternal_Demon end end })
TabCraft:Button({ Title = "获取【永恒剑空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack) tool.Name = "空投工具(永恒)" tool.RequiresHandle = false
    tool.Activated:Connect(function() local t = Mouse.Target if t then for i=1, 30 do DragModel(t.Parent, dropTarget_Eternal) task.wait(0.01) end end end)
end })

TabCraft:Paragraph({ Title = "【 复仇剑合成 】", Desc = "恶魔鸭 / 天堂鸭", Color = Color3.fromRGB(255, 0, 0) })
local Pos_Revenge_Demon, Pos_Revenge_Heaven, Pos_Revenge_Altar = CFrame.new(6487.173, -92.148, -4551.805), CFrame.new(6448.009, -93.535, -4523.665), CFrame.new(6462.440, -94.916, -4543.508)
local dropTarget_Revenge = Pos_Revenge_Demon
TabCraft:Button({ Title = "传送到复仇剑祭坛", Callback = function() if player.Character then player.Character.HumanoidRootPart.CFrame = Pos_Revenge_Altar end end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"恶魔鸭子", "天堂鸭子"}, Value = "恶魔鸭子", Callback = function(opt) if opt == "恶魔鸭子" then dropTarget_Revenge = Pos_Revenge_Demon else dropTarget_Revenge = Pos_Revenge_Heaven end end })
TabCraft:Button({ Title = "获取【复仇剑空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack) tool.Name = "空投工具(复仇)" tool.RequiresHandle = false
    tool.Activated:Connect(function() local t = Mouse.Target if t then for i=1, 30 do DragModel(t.Parent, dropTarget_Revenge) task.wait(0.01) end end end)
end })

TabCraft:Paragraph({ Title = "【 星星鸭子合成 】", Desc = "天堂鸭 / 普通鸭 / 恶魔鸭", Color = Color3.fromRGB(200, 0, 255) })
local Pos_StarDuck_Heaven, Pos_StarDuck_Normal, Pos_StarDuck_Demon, Pos_StarDuck_Altar = CFrame.new(-7041.764, 391.973, 4906.096), CFrame.new(-7066.685, 392.111, 4898.619), CFrame.new(-7092.101, 392.085, 4890.774), CFrame.new(-7064.089, 390.357, 4885.606)
local dropTarget_StarDuck = Pos_StarDuck_Heaven
TabCraft:Button({ Title = "传送到星星鸭子祭坛", Callback = function() if player.Character then player.Character.HumanoidRootPart.CFrame = Pos_StarDuck_Altar end end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂鸭", "普通鸭", "恶魔鸭"}, Value = "天堂鸭", Callback = function(opt) if opt == "天堂鸭" then dropTarget_StarDuck = Pos_StarDuck_Heaven elseif opt == "普通鸭" then dropTarget_StarDuck = Pos_StarDuck_Normal else dropTarget_StarDuck = Pos_StarDuck_Demon end end })
TabCraft:Button({ Title = "获取【星星鸭子空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack) tool.Name = "空投工具(星星)" tool.RequiresHandle = false
    tool.Activated:Connect(function() local t = Mouse.Target if t then for i=1, 30 do DragModel(t.Parent, dropTarget_StarDuck) task.wait(0.01) end end end)
end })

TabCraft:Paragraph({ Title = "【 地狱火合成 】", Desc = "三叉戟 / 恶魔鸭", Color = Color3.fromRGB(255, 69, 0) })
local Pos_Hellfire_Trident, Pos_Hellfire_Demon, Pos_Hellfire_Altar = CFrame.new(-1755.451, 346.302, 1478.264), CFrame.new(-1785.906, 346.302, 1495.925), CFrame.new(-1682.328, 349.602, 1477.501)
local dropTarget_Hellfire = Pos_Hellfire_Trident
TabCraft:Button({ Title = "传送到地狱火祭坛", Callback = function() if player.Character then player.Character.HumanoidRootPart.CFrame = Pos_Hellfire_Altar end end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"三叉戟", "恶魔鸭"}, Value = "三叉戟", Callback = function(opt) if opt == "三叉戟" then dropTarget_Hellfire = Pos_Hellfire_Trident else dropTarget_Hellfire = Pos_Hellfire_Demon end end })
TabCraft:Button({ Title = "获取【地狱火空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack) tool.Name = "空投工具(地狱火)" tool.RequiresHandle = false
    tool.Activated:Connect(function() local t = Mouse.Target if t then for i=1, 30 do DragModel(t.Parent, dropTarget_Hellfire) task.wait(0.01) end end end)
end })

TabCraft:Paragraph({ Title = "【 天堂光环合成 】", Desc = "天堂鸭 / 永恒剑 (需去辐射商店开444门)", Color = Color3.fromRGB(255, 255, 150) })
local Pos_Halo_HeavenDuck, Pos_Halo_EternalSword, Pos_Halo_Altar = CFrame.new(-678.179, 25.500, -404.403), CFrame.new(-680.807, 25.500, -413.101), CFrame.new(-670.157, 21.800, -412.872)
local dropTarget_Halo = Pos_Halo_HeavenDuck
TabCraft:Button({ Title = "传送到天堂光环祭坛", Callback = function() if player.Character then player.Character.HumanoidRootPart.CFrame = Pos_Halo_Altar end end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂鸭", "永恒剑"}, Value = "天堂鸭", Callback = function(opt) if opt == "天堂鸭" then dropTarget_Halo = Pos_Halo_HeavenDuck else dropTarget_Halo = Pos_Halo_EternalSword end end })
TabCraft:Button({ Title = "获取【天堂光环空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack) tool.Name = "空投工具(光环)" tool.RequiresHandle = false
    tool.Activated:Connect(function() local t = Mouse.Target if t then for i=1, 30 do DragModel(t.Parent, dropTarget_Halo) task.wait(0.01) end end end)
end })

TabCraft:Paragraph({ Title = "【 天堂剑合成 】", Desc = "天堂光环 (雪山)", Color = Color3.fromRGB(255, 255, 255) })
local Pos_HeavenSword_Halo, Pos_HeavenSword_Altar = CFrame.new(1662.831, 402.424, 3280.203), CFrame.new(1659.923, 399.730, 3273.653)
local dropTarget_HeavenSword = Pos_HeavenSword_Halo
TabCraft:Button({ Title = "传送到雪山天堂剑祭坛", Callback = function() if player.Character then player.Character.HumanoidRootPart.CFrame = Pos_HeavenSword_Altar end end })
TabCraft:Button({ Title = "获取【天堂剑空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack) tool.Name = "空投工具(天堂剑)" tool.RequiresHandle = false
    tool.Activated:Connect(function() local t = Mouse.Target if t then for i=1, 30 do DragModel(t.Parent, dropTarget_HeavenSword) task.wait(0.01) end end end)
end })

local TimeLabel = TabCraft:Paragraph({ Title = "【 月牙合成 (限定傍晚) 】", Desc = "读取时间中...", Color = Color3.fromRGB(255, 215, 0) })
task.spawn(function() while task.wait(1) do local t = Lighting.ClockTime local str = string.format("%02d:%02d", math.floor(t), math.floor((t%1)*60)) if t>=17 and t<=19 then TimeLabel:SetTitle("【 月牙合成 (已开启) 】") TimeLabel:SetDesc("当前："..str) TimeLabel:SetColor(Color3.fromRGB(0,255,0)) else TimeLabel:SetTitle("【 月牙合成 (未开启) 】") TimeLabel:SetDesc("当前："..str.." | 需等到17:00") TimeLabel:SetColor(Color3.fromRGB(255,100,100)) end end end)

local Pos_Moon_HeavenSword, Pos_Moon_Hellfire, Pos_Moon_Altar = CFrame.new(1491.958, 415.623, 3322.311), CFrame.new(1477.948, 415.623, 3327.516), CFrame.new(1482.868, 413.256, 3318.388)
local dropTarget_Moon = Pos_Moon_HeavenSword
local function IsEvening() return Lighting.ClockTime >= 17 and Lighting.ClockTime <= 19 end
TabCraft:Button({ Title = "传送到月牙祭坛", Callback = function() if not IsEvening() then return WindUI:Notify({Title="时间未到",Content="必须是17:00-19:00"}) end if player.Character then player.Character.HumanoidRootPart.CFrame = Pos_Moon_Altar end end })
TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂剑", "地狱火"}, Value = "天堂剑", Callback = function(opt) if opt == "天堂剑" then dropTarget_Moon = Pos_Moon_HeavenSword else dropTarget_Moon = Pos_Moon_Hellfire end end })
TabCraft:Button({ Title = "获取【月牙空投工具】", Callback = function()
    if not IsEvening() then return WindUI:Notify({Title="拒绝",Content="当前不是傍晚"}) end
    local tool = Instance.new("Tool", player.Backpack) tool.Name = "空投工具(月牙)" tool.RequiresHandle = false
    tool.Activated:Connect(function() if not IsEvening() then return end local t = Mouse.Target if t then for i=1, 30 do DragModel(t.Parent, dropTarget_Moon) task.wait(0.01) end end end)
end })

TabCraft:Paragraph({ Title = "【 月神剑合成 】", Desc = "月牙", Color = Color3.fromRGB(200, 200, 255) })
local Pos_MoonSword_Crescent, Pos_MoonSword_Altar = CFrame.new(-7648.661, 322.803, 4233.530), CFrame.new(-7642.798, 320.995, 4227.344)
local dropTarget_MoonSword = Pos_MoonSword_Crescent
TabCraft:Button({ Title = "传送到月神剑祭坛", Callback = function() if player.Character then player.Character.HumanoidRootPart.CFrame = Pos_MoonSword_Altar end end })
TabCraft:Button({ Title = "获取【月神剑空投工具】", Callback = function()
    local tool = Instance.new("Tool", player.Backpack) tool.Name = "空投工具(月神剑)" tool.RequiresHandle = false
    tool.Activated:Connect(function() local t = Mouse.Target if t then for i=1, 30 do DragModel(t.Parent, dropTarget_MoonSword) task.wait(0.01) end end end)
end })

local TabTP = Window:Tab({ Title = "安全传送", Icon = "rbxassetid://10734945123" })
local targetTree = "Generic"
local playerPos = {nil, nil, nil}
TabTP:Dropdown({ Title = "选择树木种类", Values = {"普通木 (Generic)", "幻影木 (LoneCave)", "电木 (Electric)", "胡桃木 (Walnut)", "星木 (Star)", "樱桃木 (Cherry)", "桦木 (Birch)", "冰霜木 (Frost)", "大理石木 (Marble)", "火山木 (Volcano)", "巨型橡木 (GreatOak)", "石头木 (Stone)", "辐射木 (Radioactive)", "洞穴木 (Cavern)", "岩浆木 (Magma)", "蓝木 (CaveCrawler)", "灵魂木 (Spirit)", "烈焰木 (Flame)", "星辰木 (Celestial)", "橡木 (Oak)", "沙子木 (Sand)", "松木 (Pine)", "玻璃木 (Glass)", "彩虹木 (Rainbow)", "冰木 (Ice)"}, Value = "普通木 (Generic)", Callback = function(option) local m = string.match(option, "%((.+)%)") if m then targetTree = m else targetTree = option end end })
TabTP:Button({ Title = "传送到树旁", Callback = function()
    if not player.Character then return end local targetWood = nil
    for _, v in next, Workspace:GetDescendants() do if v.Name == "TreeRegion" then for _, m in next, v:GetChildren() do if m:FindFirstChild("CutEvent") and not m:FindFirstChild("RootCut") then if m:FindFirstChild("TreeClass") and m.TreeClass.Value == targetTree then if m:FindFirstChild("Owner") and (m.Owner.Value == nil or m.Owner.Value == player) then targetWood = m break end end end end end if targetWood then break end end
    if targetWood and targetWood:FindFirstChild("WoodSection") then player.Character.HumanoidRootPart.CFrame = targetWood.WoodSection.CFrame + Vector3.new(0, 2.5, 3.5) else WindUI:Notify({Title="错误",Content="没找到树"}) end
end })
for i = 1, 3 do
    TabTP:Button({ Title = "保存当前位置为传送点"..i, Callback = function() if player.Character then playerPos[i] = player.Character.HumanoidRootPart.CFrame WindUI:Notify({Title="成功",Content="已保存"}) end end })
    TabTP:Button({ Title = "传送到传送点"..i, Callback = function() if playerPos[i] and player.Character then player.Character.HumanoidRootPart.CFrame = playerPos[i] else WindUI:Notify({Title="错误",Content="未保存"}) end end })
end

local TabItem = Window:Tab({ Title = "物品传送", Icon = "rbxassetid://10882439086" })
local selectedBringTarget = "BRING1"
local selectedObjects = {}
TabItem:Dropdown({ Title = "选择拉回目标点", Values = {"点位1", "点位2", "点位3"}, Value = "点位1", Callback = function(opt) if opt == "点位1" then selectedBringTarget = "BRING1" elseif opt == "点位2" then selectedBringTarget = "BRING2" else selectedBringTarget = "BRING3" end end })
for i = 1, 3 do
    TabItem:Button({ Title = "设置物品点位"..i, Callback = function()
        if Workspace:FindFirstChild("BRING"..i) then Workspace:FindFirstChild("BRING"..i):Destroy() end
        local p = Instance.new("Part", Workspace) p.Name = "BRING"..i p.Transparency = 1 p.Anchored = true p.CFrame = player.Character.HumanoidRootPart.CFrame p.CanCollide = false p.Size = player.Character.HumanoidRootPart.Size
        local posBox = Instance.new("SelectionBox", p) posBox.Color3 = Color3.new(0, 255, 0) posBox.Adornee = p
    end })
end
TabItem:Button({ Title = "获取点击传送工具", Callback = function()
    if player.Backpack:FindFirstChild("点击传送") then player.Backpack["点击传送"]:Destroy() end
    local a = Instance.new("Tool", player.Backpack) a.Name = "点击传送" a.RequiresHandle = false
    a.Activated:Connect(function() if Workspace:FindFirstChild(selectedBringTarget) then local targetCF = Workspace[selectedBringTarget].CFrame local t = Mouse.Target if not t then return end if t.Parent and (t.Parent.Name == "Plank" or t.Parent:FindFirstChild("WoodSection") or t.Parent:FindFirstChild("Owner")) then for i=1, 40 do DragModel(t.Parent, targetCF) task.wait(0.02) end end end end)
end })
TabItem:Button({ Title = "获取【多选框选工具】", Callback = function()
    if player.Backpack:FindFirstChild("多选框选工具") then player.Backpack["多选框选工具"]:Destroy() end
    local tool = Instance.new("Tool", player.Backpack) tool.Name = "多选框选工具" tool.RequiresHandle = false
    tool.Activated:Connect(function() local t = Mouse.Target if not t then return end local targetModel = t.Parent if targetModel then local isSel = false for i, obj in pairs(selectedObjects) do if obj == targetModel then table.remove(selectedObjects, i) isSel = true if t:FindFirstChild("BlueSelectBox") then t.BlueSelectBox:Destroy() end break end end if not isSel then table.insert(selectedObjects, targetModel) local box = Instance.new("SelectionBox", targetModel) box.Name = "BlueSelectBox" box.Adornee = targetModel box.Color3 = Color3.fromRGB(0,150,255) end end end)
end })
TabItem:Button({ Title = "一键传送所有选中物品", Callback = function()
    if not Workspace:FindFirstChild(selectedBringTarget) then return end
    for i = #selectedObjects, 1, -1 do local obj = selectedObjects[i] if obj and obj.Parent then for j=1, 40 do DragModel(obj, Workspace[selectedBringTarget].CFrame) task.wait(0.02) end if obj:FindFirstChild("BlueSelectBox") then obj.BlueSelectBox:Destroy() end table.remove(selectedObjects, i) end end
end })

local TabNewItem = TabItem:Section({ Title = "新增：卖木头 & 鸭子拉回", TextXAlignment = Enum.TextXAlignment.Left })
local function New_SellAllWood()
    local lm = Workspace:FindFirstChild("LogModels") if not lm then return end
    local list = {} for _, m in pairs(lm:GetChildren()) do if m:FindFirstChild("Owner") and m.Owner.Value == player and m:FindFirstChild("TreeClass") then table.insert(list, m) end end
    if #list == 0 then return WindUI:Notify({Title="提示",Content="没有木头"}) end
    local SELL_CF = CFrame.new(314.508514, -0.303692758, 86.5952911) local orig = player.Character.HumanoidRootPart.CFrame
    for _, m in ipairs(list) do if m.Parent then local p = m.PrimaryPart or m:FindFirstChild("WoodSection") if p then player.Character.HumanoidRootPart.CFrame = p.CFrame + Vector3.new(0,3,0) task.wait(0.1) for i=1, 40 do DragModel(m, SELL_CF) task.wait(0.01) end player.Character.HumanoidRootPart.CFrame = SELL_CF + Vector3.new(0,3,0) task.wait(0.5) end end end
    player.Character.HumanoidRootPart.CFrame = orig WindUI:Notify({Title="完成",Content="木头已卖完"})
end
TabNewItem:Button({ Title = "一键卖掉所有原木", Callback = function() task.spawn(New_SellAllWood) end })
local duckList = {"DuckAngel", "DuckEvil", "LunarDuck", "Duck", "2018CGift_Duck"} local selectedDuck = "DuckAngel"
TabNewItem:Dropdown({ Title = "选择鸭子", Values = {"天堂鸭", "恶魔鸭", "月亮鸭", "普通鸭", "礼物鸭"}, Value = "天堂鸭", Callback = function(opt) if opt == "天堂鸭" then selectedDuck = "DuckAngel" elseif opt == "恶魔鸭" then selectedDuck = "DuckEvil" elseif opt == "月亮鸭" then selectedDuck = "LunarDuck" elseif opt == "普通鸭" then selectedDuck = "Duck" else selectedDuck = "2018CGift_Duck" end end })
TabNewItem:Button({ Title = "拉回全图【自己的】鸭子", Callback = function()
    local start = player.Character.HumanoidRootPart.CFrame local count = 0
    for _, m in pairs(Workspace.PlayerModels:GetChildren()) do if m.Name == selectedDuck and m:FindFirstChild("Owner") and m.Owner.Value == player then local p = m.PrimaryPart or m:FindFirstChild("Main") or m:FindFirstChildWhichIsA("BasePart") if p then player.Character.HumanoidRootPart.CFrame = p.CFrame + Vector3.new(0,2,0) task.wait(0.1) for i=1, 30 do DragModel(m, start) task.wait(0.01) end count = count + 1 end end end
    player.Character.HumanoidRootPart.CFrame = start WindUI:Notify({Title="完成",Content="拉回 "..count.." 只"})
end })

local TabServer = Window:Tab({ Title = "服务器", Icon = "rbxassetid://10882439086" })
TabServer:Button({ Title = "刷新当前服务器 (原地重连)", Callback = function()
    WindUI:Notify({Title="重连中",Content="3秒后重连..."}) task.wait(3)
    local ok = pcall(function() if game.PrivateServerId ~= "" then TS:TeleportToPrivateServer(game.PlaceId, game.PrivateServerId, {player}) else TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end end)
    if not ok then player:Kick("重连刷新") end
end })

local TabExtra = Window:Tab({ Title = "其他功能", Icon = "rbxassetid://10882439086" })
local isDragEnabled, dragConn = false, nil
TabExtra:Toggle({ Title = "开启拖拽器", Callback = function(state)
    isDragEnabled = state
    if state then if dragConn then dragConn:Disconnect() end dragConn = Workspace.ChildAdded:Connect(function(obj) if obj.Name == "Dragger" and isDragEnabled then obj.BrickColor = BrickColor.new("Bright green") task.spawn(function() local b, c = obj:WaitForChild("BodyGyro", 2), obj:WaitForChild("BodyPosition", 2) if b and c then task.wait(0.1) obj.CanCollide, obj.CanTouch = false, false while obj.Parent == Workspace and isDragEnabled do c.P, c.D, c.maxForce = 120000, 1000, Vector3.new(1,1,1)*1000000 b.MaxTorque, b.P, b.D = Vector3.new(1,1,1)*200, 1200, 140 task.wait() end end end) end end) end
end })

local TabNewAuto = TabExtra:Section({ Title = "全自动获取普通鸭", TextXAlignment = Enum.TextXAlignment.Left })
local autoDuckTarget = 1
local isAutoBuyingDuck = false
TabNewAuto:Input({ Title = "目标数量", Value = "1", Callback = function(t) local n = tonumber(t) if n and n>0 then autoDuckTarget = math.floor(n) end end })
TabNewAuto:Button({ Title = "开始自动获取", Callback = function()
    if isAutoBuyingDuck then return end isAutoBuyingDuck = true
    task.spawn(function()
        local function getMyDucks() local d = {} for _, m in pairs(Workspace.PlayerModels:GetChildren()) do if m.Name == "2018CGift_Duck" and m:FindFirstChild("Owner") and m.Owner.Value == player then table.insert(d, m) end end return d end
        local startPos, initialDucks, successCount = player.Character.HumanoidRootPart.CFrame, {}, 0
        for _, d in ipairs(getMyDucks()) do initialDucks[d] = true end
        while isAutoBuyingDuck and successCount < autoDuckTarget do
            local fineFinds = Workspace.Stores:FindFirstChild("FineFinds")
            local npc, counter, shopItems = fineFinds and fineFinds:FindFirstChild("Manachron"), fineFinds and fineFinds:FindFirstChild("Counter"), fineFinds and fineFinds:FindFirstChild("ShopItems")
            if not npc or not counter or not shopItems then break end
            local crate = shopItems:FindFirstChild("Crate")
            if crate then
                local p = crate.PrimaryPart or crate:FindFirstChild("Main") or crate:FindFirstChildWhichIsA("BasePart")
                if p then player.Character.HumanoidRootPart.CFrame = p.CFrame + Vector3.new(0,3,0) task.wait(0.1) for i=1, 40 do DragModel(crate, counter.CFrame + Vector3.new(0,0.6,0)) task.wait(0.01) end player.Character.HumanoidRootPart.CFrame = counter.CFrame + Vector3.new(0,3,0) task.wait(0.1) pcall(function() RS.NPCDialog.PlayerChatted:InvokeServer(table.unpack({{ID=0, Character=npc, Name="Manachron"}, "ConfirmPurchase"})) end) task.wait(0.4) end
            end
            for _, m in pairs(Workspace.PlayerModels:GetChildren()) do if m.Name == "Crate" or m.Name:find("Crate Purchased by") then pcall(function() RS.Interaction.ClientInteracted:FireServer(m, 'Open box') end) local btn = m:FindFirstChild("ButtonRemote_Main") if btn then pcall(function() RS.Interaction.RemoteProxy:FireServer(btn) end) end end end
            task.wait(0.4)
            local current = getMyDucks()
            for _, d in ipairs(current) do if not initialDucks[d] and d.Parent then local p = d.PrimaryPart or d:FindFirstChild("Main") or d:FindFirstChildWhichIsA("BasePart") if p then player.Character.HumanoidRootPart.CFrame = p.CFrame + Vector3.new(0,2,0) task.wait(0.2) for i=1, 30 do DragModel(d, startPos) task.wait(0.01) end initialDucks[d] = true successCount = successCount + 1 break end end end
            player.Character.HumanoidRootPart.CFrame = startPos task.wait(0.2)
        end
        isAutoBuyingDuck = false WindUI:Notify({Title="完成",Content="成功获取 "..successCount.." 只"})
    end)
end })
TabNewAuto:Button({ Title = "停止任务", Callback = function() isAutoBuyingDuck = false end })

TabExtra:Button({ Title = "开启飞行", Callback = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/385j8888/ZOUMAGUIX/refs/heads/main/%E9%A3%9E%E8%A1%8C%E8%84%9A%E6%9C%ACV3(%E5%85%A8%E6%B8%B8%E6%88%8F%E9%80%9A%E7%94%A8).txt"))() end) end })
TabExtra:Button({ Title = "彻底关闭并清理缓存", Callback = function() CleanupAll() end })