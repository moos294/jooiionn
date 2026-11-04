print("[白Hub] 开始加载 WindUI...")
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/v1.6.66/main.lua"))()

local success, err = pcall(function()
    WindUI:SetNotificationLower(true)

    local Window = WindUI:CreateWindow({
        Title = "白--伐木大亨2",
        Author = "WindUI 重制版",
        Folder = "BaiHub",
        Size = UDim2.fromOffset(580, 420),
        Theme = "Dark",
        Transparent = true,
        Resizable = true
    })

    local TabMain = Window:Tab({ Title = "主要功能", Icon = "home" })
    local SecAxe = TabMain:Section({ Title = "斧头功能", Opened = true })

    SecAxe:Button({ Title = "加载复制斧头", Callback = function() CanClientLoad(); wait(1); lp.Character.Head:Destroy(); wait(bai.loaddupeaxewaittime); LoadSlot(GetLoadedSlot()); wait(6); lp.Character.HumanoidRootPart.CFrame = oldpos end })
    SecAxe:Button({ Title = "远程装备斧头", Callback = function() farAxeEquip() end })
    SecAxe:Toggle({ Title = "斧头跟随鼠标", Callback = function(state) bai.whthmose = state end })
    SecAxe:Toggle({ Title = "斧头炸家", Callback = function(state)
        if state then axefily() else
            if bai.axeFling then bai.axeFling:Disconnect(0.1); bai.axeFling = nil; end
        end
    end })

    local SecBase = TabMain:Section({ Title = "基地功能", Opened = false })
    SecBase:Button({ Title = "点击土地免费获得", Callback = function()
        freeland=nil
        notify("白","请你点击一个空的土地",4)
        ClickToSelectClick = Mouse.Button1Up:Connect(function()
            Clicked = Mouse.Target
            if tostring(Clicked.Parent.Name) == "Property" then
                local v =Clicked.Parent
                if v:FindFirstChild("Owner") and v.Owner.Value==nil then
                    game.ReplicatedStorage.PropertyPurchasing.ClientPurchasedProperty:FireServer(v, v.OriginSquare.OriginCFrame.Value.p + Vector3.new(0, 3, 0))
                    wait(0.5)
                    freeland=true
                    Instance.new('RemoteEvent', game:service 'ReplicatedStorage'.Interaction).Name = "Ban"
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.OriginSquare.CFrame +Vector3.new(0, 10, 0)
                else notify("白","这个土地有主人了",4) end
            end
        end)
        repeat task.wait() until freeland~=nil
        ClickToSelectClick:Disconnect()
        ClickToSelectClick=nil
    end })
    
    SecBase:Input({ Title = "选择存档加载 (1-6)", Placeholder = "1", Callback = function(s) bai.soltnumber = s end })
    
    SecBase:Button({ Title = "一键复制存档", Callback = function()
        DupeSlot=tonumber(bai.soltnumber)
        local ItemAdded, ItemAdded = game:GetService("Workspace").PlayerModels.ChildAdded:Connect(function(v)
            if v:WaitForChild("Owner") and v.Owner.Value == game.Players.LocalPlayer then
                game:GetService('RunService').Stepped:wait(); game:Shutdown()
            end
        end)
        game:GetService("ReplicatedStorage").LoadSaveRequests.RequestLoad:InvokeServer(DupeSlot, game.Players.LocalPlayer)
    end })

    local TabWood = Window:Tab({ Title = "木头功能", Icon = "trees" })
    local SecBring = TabWood:Section({ Title = "砍树与挂机", Opened = true })

    local treeTypes = {"普通树", '幻影木', "沼泽黄金", "樱花", "蓝木", "冰木", "火山木", "橡木", "巧克力木", "白桦木", "黄金木", "雪地松", "僵尸木", "大巧克力树", "椰子树", '南瓜木', '幽灵木'}
    SecBring:Dropdown({ Title = "选择树木类型", Values = treeTypes, Callback = function(b)
        if b == '普通树' then bai.cuttreeselect = "Generic"
        elseif b == '沼泽黄金' then bai.cuttreeselect = "GoldSwampy"
        elseif b == '樱花' then bai.cuttreeselect = "Cherry"
        elseif b == '蓝木' then bai.cuttreeselect = "CaveCrawler"
        elseif b == '冰木' then bai.cuttreeselect = "Frost"
        elseif b == '火山木' then bai.cuttreeselect = "Volcano"
        elseif b == '橡木' then bai.cuttreeselect = "Oak"
        elseif b == '巧克力木' then bai.cuttreeselect = "Walnut"
        elseif b == '白桦木' then bai.cuttreeselect = "Birch"
        elseif b == '黄金木' then bai.cuttreeselect = "SnowGlow"
        elseif b == '雪地松' then bai.cuttreeselect = "Pine"
        elseif b == '僵尸木' then bai.cuttreeselect = "GreenSwampy"
        elseif b == '大巧克力树' then bai.cuttreeselect = "Koa"
        elseif b == '椰子树' then bai.cuttreeselect = "Palm"
        elseif b == '幽灵木' then bai.cuttreeselect = "Spooky"
        elseif b == '南瓜木' then bai.cuttreeselect = "SpookyNeon"
        elseif b == '幻影木' then bai.cuttreeselect = "LoneCave" end
    end })

    SecBring:Input({ Title = "带来树的数量", Placeholder = "1", Callback = function(txt) bai.bringamount = txt end })
    SecBring:Button({ Title = "带来树", Callback = function()
        bai.bringtree = true; bai.treecutset = lp.Character.HumanoidRootPart.CFrame; task.wait(0.2)
        for i = 1, bai.bringamount do if bai.bringtree == true then task.wait(); bringTree(bai.cuttreeselect) end end
    end })
    SecBring:Toggle({ Title = "自动砍树", Callback = function(state)
        if state then
            bai.autofarm = true
            task.spawn(function() while task.wait(0.3) do if bai.autofarm == true then bringTree(bai.cuttreeselect) end end end)
        else bai.autofarm = false end
    end })

    local SecSell = TabWood:Section({ Title = "卖木头与传送", Opened = false })
    SecSell:Button({ Title = "传送木头", Callback = function()
        OldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        for i, v in next, game:GetService("Workspace").LogModels:GetChildren() do
            if v:FindFirstChild("Owner") and v.Owner.Value == game.Players.LocalPlayer then
                if not v.PrimaryPart then v.PrimaryPart = v:FindFirstChild("WoodSection") end
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v:FindFirstChild("WoodSection").CFrame.p)
                spawn(function() for i = 1, 50 do game.ReplicatedStorage.Interaction.ClientIsDragging:FireServer(v); task.wait() end end)
                for i = 1, 50 do task.wait(); v:PivotTo(OldPos) end
                task.wait()
            end
        end
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = OldPos
    end })
    SecSell:Button({ Title = "卖木头", Callback = function() sellwood() end })
    SecSell:Toggle({ Title = "自动卖木头", Callback = function(state)
        local oldpos = lp.Character.HumanoidRootPart.CFrame
        while wait() do if state then sellwood() end end
    end })

    local TabPlayer = Window:Tab({ Title = "玩家功能", Icon = "user" })
    local SecMove = TabPlayer:Section({ Title = "移动与视角", Opened = true })

    SecMove:Slider({ Title = "行走速度", Value = { Min = 16, Max = 300, Default = 16 }, Callback = function(s) bai.walkspeed = s; spawn(function() while task.wait() do if game:GetService("Players").LocalPlayer.Character then game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = bai.walkspeed end end) end })
    SecMove:Slider({ Title = "跳跃力", Value = { Min = 50, Max = 500, Default = 50 }, Callback = function(s) bai.JumpPower = s; spawn(function() while task.wait() do if game:GetService("Players").LocalPlayer.Character then game:GetService("Players").LocalPlayer.Character.Humanoid.JumpPower = bai.JumpPower end end) end })
    SecMove:Toggle({ Title = "穿墙", Callback = function(state) NoClip(state) end })
    SecMove:Toggle({ Title = "隐身", Callback = function(state) if state then TurnInvisible() else TurnVisible() end end })

    local SecTp = TabPlayer:Section({ Title = "普通传送", Opened = false })
    local locs = {'出生点', '木材反斗城', '土地商店', '桥', '码头', '椰子岛', '洞穴', '鲨鱼斧合成', '火山', '沼泽', '家具店', '盒子车行', '连锁逻辑店', '鲍勃的小店', '画廊', '雪山', '灵视神殿', '怪人', '小绿盒', '滑雪小屋', '黄金木洞穴', '小鸟斧头', "灯塔", '回家'}
    SecTp:Dropdown({ Title = "传送地点", Values = locs, Callback = function(b)
        if b == '木材反斗城' then tp(CFrame.new(270, 4, 60)) elseif b == '出生点' then tp(CFrame.new(174, 10.5, 66)) elseif b == '土地商店' then tp(CFrame.new(270, 3, -98)) elseif b == '桥' then tp(CFrame.new(112, 37, -892)) elseif b == '码头' then tp(CFrame.new(1136, 0, -206)) elseif b == '椰子岛' then tp(CFrame.new(2614, -4, -34)) elseif b == '洞穴' then tp(CFrame.new(3590, -177, 415)) elseif b == '火山' then tp(CFrame.new(-1588, 623, 1069)) elseif b == '沼泽' then tp(CFrame.new(-1216, 131, -822)) elseif b == '家具店' then tp(CFrame.new(486, 3, -1722)) elseif b == '盒子车行' then tp(CFrame.new(509, 3, -1458)) elseif b == '雪山' then tp(CFrame.new(1487, 415, 3259)) elseif b == '连锁逻辑店' then tp(CFrame.new(4615, 7, -794)) elseif b == '鲍勃的小店' then tp(CFrame.new(292, 8, -2544)) elseif b == '画廊' then tp(CFrame.new(5217, -166, 721)) elseif b == '灵视神殿' then tp(CFrame.new(-1608, 195, 928)) elseif b == '怪人' then tp(CFrame.new(1071, 16, 1141)) elseif b == '小绿盒' then tp(CFrame.new(-1667, 349, 1474)) elseif b == '滑雪小屋' then tp(CFrame.new(1244, 59, 2290)) elseif b == '黄金木洞穴' then tp(CFrame.new(-1080, -5, -942)) elseif b == '鲨鱼斧合成' then tp(CFrame.new(330.259735, 45.7998505, 1943.30823)) elseif b == '小鸟斧头' then tp(CFrame.new(4813.1, 33.5, -978.8)) elseif b == '灯塔' then tp(CFrame.new(1464.8, 356.3, 3257.2)) elseif b == '回家' then for i, v in pairs(game.Workspace.Properties:GetChildren()) do if v.Owner.Value == game.Players.LocalPlayer then tp(v.OriginSquare.CFrame + Vector3.new(0, 10, 0)) end end end
    end })

    local TabEnv = Window:Tab({ Title = "环境与魔鬼", Icon = "zap" })
    local SecEnv = TabEnv:Section({ Title = "环境", Opened = true })

    SecEnv:Toggle({ Title = "终日白天", Callback = function(state) if state then bai.awaysday = true; while task.wait() do if bai.awaysday == true then game:GetService('Lighting').TimeOfDay = ('12:00:00') end end else bai.awaysday = false end end })
    SecEnv:Toggle({ Title = "终日黑天", Callback = function(state) if state then bai.awaysdnight = true; while task.wait() do if bai.awaysdnight == true then game:GetService('Lighting').TimeOfDay = ('2:00:00') end end else bai.awaysdnight = false end end })
    
    SecEnv:Button({ Title = "删除火山/雪山石头", Callback = function()
        for i, v in pairs(workspace["Region_Volcano"]:children()) do if v.Name == "PartSpawner" then v.Parent = game.Lighting end end
        for i, v in pairs(workspace["Region_Snow"]:children()) do if v.Name == "PartSpawner" then v.Parent = game.Lighting end end
    end })

    local SecDevil = TabEnv:Section({ Title = "魔鬼功能 (慎用)", Opened = false })
    local playerNames = {}
    for _, p in ipairs(game.Players:GetPlayers()) do table.insert(playerNames, p.Name) end

    SecDevil:Dropdown({ Title = "选择目标玩家", Values = playerNames, Callback = function(v) bai.playernamedied = v end })
    SecDevil:Button({ Title = "传送到玩家旁边", Callback = function()
        local tp_player = game:GetService("Players")[bai.playernamedied]
        if tp_player then for i = 1, 5 do wait(); game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = tp_player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0) end end
    end })
    
    SecDevil:Button({ Title = "斧头杀人", Callback = function()
        local tool = getTool(); if not tool then return notify("白", "你需要斧头", 4) end
        local KillPlayer = bai.playernamedied; local Player = gplr(KillPlayer)
        if Player[1] then
            Player = Player[1]; local LocalPlayer = game.Players.LocalPlayer
            if LocalPlayer.Character.PrimaryPart ~= nil then
                local Character = LocalPlayer.Character; local previous = LocalPlayer.Character.PrimaryPart.CFrame
                Character.Archivable = true; local Clone = Character:Clone(); LocalPlayer.Character = Clone; wait(0.5); LocalPlayer.Character = Character; wait(0.2)
                if LocalPlayer.Character and Player.Character and Player.Character.PrimaryPart ~= nil then
                    if LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):Destroy() end
                    local Humanoid = Instance.new("Humanoid"); Humanoid.Parent = LocalPlayer.Character
                    local Tool = nil
                    if LocalPlayer.Character:FindFirstChildOfClass("Tool") then Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") elseif LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChildOfClass("Tool") then Tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") end
                    if Tool ~= nil then
                        Tool.Parent = LocalPlayer.Backpack; Player.Character.HumanoidRootPart.Anchored = true
                        local Arm = game.Players.LocalPlayer.Character['Right Arm'].CFrame * CFrame.new(0, -1, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0)
                        Tool.Grip = Arm:ToObjectSpace(Player.Character.PrimaryPart.CFrame):Inverse()
                        Tool.Parent = LocalPlayer.Character; Workspace.CurrentCamera.CameraSubject = Tool.Handle
                        repeat wait() until not Tool or Tool and (Tool.Parent == Workspace or Tool.Parent == Player.Character)
                        Player.Character.HumanoidRootPart.Anchored = false; wait(0.1); Humanoid.Health = 0; LocalPlayer.Character = nil
                    end
                end
                spawn(function()
                    LocalPlayer.CharacterAdded:Wait(); Player.Character.HumanoidRootPart.Anchored = false
                    if Player.Character.Humanoid.Health <= 15 then notify("白", "成功", 4); repeat wait() until LocalPlayer.Character.PrimaryPart ~= nil; wait(0.4); LocalPlayer.Character:SetPrimaryPartCFrame(previous) end
                end)
            end
        end
    end })
end)

if success then
    print("[白Hub] UI 加载大成功！")
else
    warn("[白Hub] UI 加载报错啦，原因: " .. tostring(err))
end