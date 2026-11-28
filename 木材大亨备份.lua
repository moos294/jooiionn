local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/UI.lua"))()
local Window = UI.Window
local WindUI = UI.WindUI

for _, v in ipairs(UI.Gui.Panel:GetDescendants()) do
    if v:IsA("TextLabel") then
        if v.Text == "ORIGAMI" then v.Text = "封存力量 猫化版" end
        if v.Text == "BUILD TOOL" then v.Text = "Author: 封存" end
    end
end

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local muscleEvent = LP:WaitForChild("muscleEvent")

Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

local FastTrain
do
    local CONFIG = {
        Rate = 500,
        TokenBurst = 20,
    }
    local state = {
        running = false,
        tokens = 0,
        lastTick = os.clock(),
        sendRate = CONFIG.Rate,
        lastControlAt = 0,
        lastStrength = 0,
        stalledCount = 0,
    }
    local function unlockTools()
        local tools = {
            { name = "Weight", prop = "repTime" },
            { name = "Pushups", prop = "repTime" },
            { name = "Situps", prop = "repTime" },
            { name = "Handstands", prop = "repTime" },
        }
        local function process(container)
            for _, toolData in ipairs(tools) do
                local tool = container:FindFirstChild(toolData.name)
                if tool then
                    local timeObj = tool:FindFirstChild(toolData.prop)
                    if timeObj then
                        timeObj.Value = 0
                    end
                end
            end
        end
        local backpack = LP:FindFirstChild("Backpack")
        if backpack then process(backpack) end
        local char = LP.Character
        if char then process(char) end
    end
    RunService.Heartbeat:Connect(unlockTools)
    local function updateRate(now)
        if now - state.lastControlAt < 0.5 then return end
        state.lastControlAt = now
        local Strength = LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Strength")
        if not Strength then return end
        local currentStr = Strength.Value
        if currentStr > state.lastStrength then
            state.stalledCount = 0
            state.sendRate = math.min(CONFIG.Rate, state.sendRate + 50)
        else
            state.stalledCount = state.stalledCount + 1
        end
        if state.stalledCount >= 2 then
            state.sendRate = math.max(100, state.sendRate - 100)
            state.stalledCount = 0
            state.tokens = 0
        end
        state.lastStrength = currentStr
    end
    RunService.Heartbeat:Connect(function()
        if not state.running then return end
        if not muscleEvent then return end
        local now = os.clock()
        local dt = now - state.lastTick
        state.lastTick = now
        updateRate(now)
        state.tokens = math.min(CONFIG.TokenBurst, state.tokens + state.sendRate * dt)
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local sent = 0
            while state.tokens >= 1 do
                muscleEvent:FireServer("rep")
                state.tokens = state.tokens - 1
                sent = sent + 1
                if sent >= CONFIG.TokenBurst then break end
            end
        else
            state.tokens = 0
        end
    end)
    FastTrain = {}
    function FastTrain.SetRate(rate)
        local n = tonumber(rate)
        if n and n > 0 then
            CONFIG.Rate = math.floor(n)
            if state.sendRate > CONFIG.Rate then
                state.sendRate = CONFIG.Rate
            end
        end
    end
    function FastTrain.Start()
        if state.running then return end
        state.running = true
        state.lastTick = os.clock()
        state.lastControlAt = os.clock()
        state.sendRate = CONFIG.Rate
        state.tokens = 0
        local Strength = LP:FindFirstChild("leaderstats") and LP.leaderstats:FindFirstChild("Strength")
        if Strength then
            state.lastStrength = Strength.Value
        end
    end
    function FastTrain.Stop()
        state.running = false
        state.tokens = 0
    end
    function FastTrain.IsRunning()
        return state.running
    end
end

local TabMain = Window:Tab({ Title = "主要引擎" })
local autowork = false
local autorebirth = false
local workType = ""
TabMain:Dropdown({
    Title = "选择锻炼类型",
    Values = { "哑铃", "倒立", "仰卧起坐", "俯卧撑", "--" },
    Default = "",
    Callback = function(val) workType = val end
})
TabMain:Toggle({
    Title = "自动锻炼",
    Default = false,
    Callback = function(state)
        autowork = state
        if state then
            task.spawn(function()
                while autowork do
                    pcall(function()
                        local char = LP.Character
                        local backpack = LP.Backpack
                        if not char then return end
                        LP.muscleEvent:FireServer("rep")
                        local toolName = ""
                        if workType == "哑铃" then toolName = "Weight"
                        elseif workType == "倒立" then toolName = "Handstands"
                        elseif workType == "仰卧起坐" then toolName = "Situps"
                        elseif workType == "俯卧撑" then toolName = "Pushups"
                        end
                        if toolName ~= "" and backpack:FindFirstChild(toolName) then
                            char.Humanoid:EquipTool(backpack[toolName])
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end
})
local rebirthTarget = 0
TabMain:Input({
    Title = "自定义重生次数",
    Placeholder = "输入数值",
    Default = "",
    Callback = function(val) rebirthTarget = tonumber(val) or 0 end
})
TabMain:Toggle({
    Title = "自动重生",
    Default = false,
    Callback = function(state)
        autorebirth = state
        if state then
            task.spawn(function()
                while autorebirth do
                    pcall(function()
                        local rebirthRemote = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("rebirthRemote")
                        if rebirthRemote then
                            rebirthRemote:InvokeServer("rebirthRequest")
                            repeat task.wait() until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        end
                    end)
                    if rebirthTarget > 0 and LP.leaderstats.Rebirths.Value >= rebirthTarget then
                        autorebirth = false
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})
TabMain:Input({
    Title = "快速锻炼速率",
    Placeholder = "500",
    Default = "500",
    Callback = function(v) FastTrain.SetRate(v) end
})
TabMain:Toggle({
    Title = "快速锻炼 (防封)",
    Default = false,
    Callback = function(state)
        if state then FastTrain.Start() else FastTrain.Stop() end
    end
})

local TabPets = Window:Tab({ Title = "宠物与光环" })
local TRIBAL_NAME = "Tribal Overlord"
local SWIFT_NAME = "Swift Samurai"
local autoRebirthEnabled = false
local function getEquippedMaxSlots()
    local equipped = LP:FindFirstChild("equippedPets")
    if not equipped then return 0 end
    local count = 0
    for _, child in ipairs(equipped:GetChildren()) do
        if child:IsA("ValueBase") and child.Name:match("^pet%d+$") then count = count + 1 end
    end
    return count
end
local function findPetInstance(petName)
    local pf = LP:FindFirstChild("petsFolder")
    if pf then
        for _, folder in ipairs(pf:GetChildren()) do
            for _, pet in ipairs(folder:GetChildren()) do
                if pet.Name == petName then return pet end
            end
        end
    end
    return nil
end
local function unequipAllPets()
    pcall(function()
        local eq = LP:FindFirstChild("equippedPets")
        if not eq then return end
        local rEvents = ReplicatedStorage:WaitForChild("rEvents")
        for _, slot in ipairs(eq:GetChildren()) do
            if slot:IsA("ValueBase") and slot.Value then
                local petName = tostring(slot.Value)
                if petName ~= "nil" and petName ~= "" and petName ~= "Instance" then
                    for _, folder in ipairs(LP.petsFolder:GetChildren()) do
                        for _, pet in ipairs(folder:GetChildren()) do
                            if pet.Name == petName then rEvents.equipPetEvent:FireServer("unequipPet", pet) end
                        end
                    end
                end
            end
        end
    end)
end
local function equipAllPets(petName)
    local rEvents = ReplicatedStorage:WaitForChild("rEvents")
    for _, folder in ipairs(LP.petsFolder:GetChildren()) do
        for i, pet in ipairs(folder:GetChildren()) do
            if pet.Name == petName then
                rEvents.equipPetEvent:FireServer("equipPet", pet)
                if i % 3 == 0 then task.wait() end
            end
        end
    end
end
local function allEquipped(targetName)
    local equippedNames = {}
    pcall(function()
        local eq = LP:FindFirstChild("equippedPets")
        if eq then
            for _, slot in ipairs(eq:GetChildren()) do
                if slot:IsA("ValueBase") and slot.Value then
                    local name = tostring(slot.Value)
                    if name ~= "nil" and name ~= "" and name ~= "Instance" then table.insert(equippedNames, name) end
                end
            end
        end
    end)
    if #equippedNames == 0 then return false end
    for _, name in ipairs(equippedNames) do if name ~= targetName then return false end end
    return true
end

TabPets:Toggle({
    Title = "自动切宠重生 (快速/部落)",
    Default = false,
    Callback = function(state)
        autoRebirthEnabled = state
        if state then
            task.spawn(function()
                while autoRebirthEnabled do
                    local ok, err = pcall(function()
                        local current = LP.leaderstats.Strength.Value
                        local rebirths = LP.leaderstats.Rebirths.Value
                        local required = math.max(1, math.floor((10000 + 5000 * rebirths) * 0.5))
                        local rEvents = ReplicatedStorage:WaitForChild("rEvents")
                        if current < required then
                            if not allEquipped(SWIFT_NAME) then
                                unequipAllPets() task.wait()
                                equipAllPets(SWIFT_NAME)
                            end
                            for i = 1, 15 do LP.muscleEvent:FireServer("rep") end
                        else
                            if not allEquipped(TRIBAL_NAME) then
                                unequipAllPets() task.wait()
                                equipAllPets(TRIBAL_NAME)
                            end
                            rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end
})
local TabGym = Window:Tab({ Title = "原版全图挂机" })

local function createMachineToggle(name, cf, machineName)
    local active = false
    TabGym:Toggle({
        Title = name,
        Default = false,
        Callback = function(state)
            active = state
            if state then
                task.spawn(function()
                    while active do
                        pcall(function()
                            local char = LP.Character
                            local root = char and char:FindFirstChild("HumanoidRootPart")
                            if not root then return end
                            local machineInUse = LP:FindFirstChild("machineInUse")
                            local isUsing = machineInUse and machineInUse.Value ~= nil
                            if not isUsing then
                                root.CFrame = cf
                                task.wait(0.15)
                                local vim = game:GetService("VirtualInputManager")
                                vim:SendKeyEvent(true, "E", false, game)
                                task.wait(0.05)
                                vim:SendKeyEvent(false, "E", false, game)
                                task.wait(0.3)
                            else
                                local seat = machineInUse.Value
                                if seat and LP:FindFirstChild("muscleEvent") then
                                    LP.muscleEvent:FireServer("rep", seat)
                                end
                            end
                        end)
                        task.wait(0.1)
                    end
                end)
            else
                pcall(function()
                    local char = LP.Character
                    if char then char:WaitForChild("Humanoid").Jump = true end
                end)
            end
        end
    })
end

local function createTreadmillToggle(name, cf)
    local running = false
    local bindName = "Treadmill_" .. name
    TabGym:Toggle({
        Title = name,
        Default = false,
        Callback = function(state)
            running = state
            if state then
                task.spawn(function()
                    local char = LP.Character
                    local originalSpeed = 16
                    if char and char:FindFirstChild("Humanoid") then
                        originalSpeed = char.Humanoid.WalkSpeed
                    end
                    while running do
                        pcall(function()
                            char = LP.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.Humanoid.WalkSpeed = 10
                                char.HumanoidRootPart.CFrame = cf
                                RunService:BindToRenderStep(bindName, Enum.RenderPriority.Character.Value + 1, function()
                                    if char and char:FindFirstChild("Humanoid") then
                                        char.Humanoid:Move(Vector3.new(10000, 0, -1), true)
                                    end
                                end)
                            end
                        end)
                        task.wait()
                    end
                    RunService:UnbindFromRenderStep(bindName)
                    pcall(function()
                        char = LP.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid.WalkSpeed = originalSpeed
                        end
                    end)
                end)
            else
                RunService:UnbindFromRenderStep(bindName)
                pcall(function()
                    local char = LP.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.WalkSpeed = 16
                    end
                end)
            end
        end
    })
end

local deadliftFuncs = {
    { name = "①硬拉1500(右上角)", cf = CFrame.new(135.838379, 3.30565023, 97.185379, 0, 0, 1, 0, 1, 0, -1, 0, 0) },
    { name = "①硬拉2500(右上角)", cf = CFrame.new(138.122299, 3.30565, 66.0853577, 0, 0, 1, 0, 1, 0, -1, 0, 0) },
    { name = "①硬拉4000(右上角)", cf = CFrame.new(141.232071, 3.30565, 26.4854164, 0, 0, 1, 0, 1, 0, -1, 0, 0) },
    { name = "②硬拉1500(右上角)", cf = CFrame.new(182.817261, 3.30565023, 97.1852036, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
    { name = "②硬拉2500(右上角)", cf = CFrame.new(180.733276, 3.30565023, 66.0851135, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
    { name = "②硬拉4000(右上角)", cf = CFrame.new(177.823456, 3.30565, 26.4850807, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
}
for idx, item in ipairs(deadliftFuncs) do createMachineToggle(item.name, item.cf, "Deadlift") end

local benchPressFuncs = {
    { name = "①仰卧推举(右下角)", cf = CFrame.new(111.400826, 6.71424437, 352.656433, 0.998808622, 4.62216354e-09, -0.0487988107, -4.46773907e-09, 1, 3.27358518e-09, 0.0487988107, -3.0516647e-09, 0.998808622) },
    { name = "①仰卧推举10(前方)", cf = CFrame.new(4.74278641, 6.71424484, 46.4786491, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { name = "①仰卧推举150(前方)", cf = CFrame.new(-15.1012564, 7.55120468, 45.4072647, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
}
for idx, item in ipairs(benchPressFuncs) do createMachineToggle(item.name, item.cf, "Bench Press") end

local squatFuncs = {
    { name = "①深蹲架1000(右上角)", cf = CFrame.new(234.779938, 3.30564976, 97.0440903, 0, 0, 1, 0, 1, 0, -1, 0, 0) },
    { name = "①深蹲架1000(前方)", cf = CFrame.new(-42.9242592, 3.30565047, 39.5736923, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    { name = "①深蹲架1000(左上角)", cf = CFrame.new(-235.653976, 3.30564952, 136.869431, 0, 0, -1, 0, 1, 0, 1, 0, 0) },
}
for idx, item in ipairs(squatFuncs) do createMachineToggle(item.name, item.cf, "Squat Rack") end

local pullupFuncs = {
    { name = "①引体向上1000(左上角)", cf = CFrame.new(-185.000092, 3.30564976, 137.263672, 0, 0, 1, 0, 1, 0, -1, 0, 0) },
    { name = "①引体向上2500(左上角)", cf = CFrame.new(-185.000092, 3.30564976, 67.5385132, 0, 0, 1, 0, 1, 0, -1, 0, 0) },
}
for idx, item in ipairs(pullupFuncs) do createMachineToggle(item.name, item.cf, "Legends Pullup") end

local treadmillFuncs = {
    { name = "①跑步机0(雕像下)", cf = CFrame.new(-27.8830738, 4.41672897, 261.175507, 0.564802229, -5.11192644e-09, -0.825226307, 3.02890241e-10, 1, -5.98727068e-09, 0.825226307, 3.1316707e-09, 0.564802229) },
    { name = "①跑步机10(右边)", cf = CFrame.new(238.671112, 5.40315914, 387.713165, -0.0160072874, -2.90710176e-08, -0.99987185, -3.3434191e-09, 1, -2.90212157e-08, 0.99987185, 2.87843993e-09, -0.0160072874) },
}
for idx, item in ipairs(treadmillFuncs) do createTreadmillToggle(item.name, item.cf) end
local TabBeautify = Window:Tab({ Title = "美化" })
local function ensurePetsFolder()
    local petsFolder = LP:FindFirstChild("petsFolder")
    if not petsFolder then
        petsFolder = Instance.new("Folder")
        petsFolder.Name = "petsFolder"
        petsFolder.Parent = LP
    end
    local unique = petsFolder:FindFirstChild("Unique")
    if not unique then
        unique = Instance.new("Folder")
        unique.Name = "Unique"
        unique.Parent = petsFolder
    end
    return unique
end
local function AddMightyMonster()
    local unique = ensurePetsFolder()
    local a1 = Instance.new("StringValue")
    a1.Name = "Mighty Monster"
    a1.Value = "rbxassetid://17601660151"
    a1.Parent = unique
    local a2 = Instance.new("Folder")
    a2.Name = "perksFolder"
    a2.Parent = a1
    Instance.new("IntValue", a2).Name = "agility"; a2.agility.Value = 1000
    Instance.new("IntValue", a2).Name = "strength"; a2.strength.Value = 2250
    Instance.new("IntValue", a2).Name = "durability"; a2.durability.Value = 5000
    Instance.new("StringValue", a1).Name = "chosenName"; a1.chosenName.Value = "强大的怪物"
    Instance.new("BoolValue", a1).Name = "evolved"; a1.evolved.Value = true
    Instance.new("IntValue", a1).Name = "exp"; a1.exp.Value = 0
    Instance.new("IntValue", a1).Name = "level"; a1.level.Value = 1
end
local function AddSwiftSamurai()
    local unique = ensurePetsFolder()
    local b1 = Instance.new("StringValue")
    b1.Name = "Swift Samurai"
    b1.Value = "rbxassetid://17601657920"
    b1.Parent = unique
    local b2 = Instance.new("Folder")
    b2.Name = "perksFolder"
    b2.Parent = b1
    Instance.new("IntValue", b2).Name = "agility"; b2.agility.Value = 2500
    Instance.new("IntValue", b2).Name = "strength"; b2.strength.Value = 1750
    Instance.new("IntValue", b2).Name = "durability"; b2.durability.Value = 3250
    Instance.new("StringValue", b1).Name = "chosenName"; b1.chosenName.Value = "快速武士"
    Instance.new("BoolValue", b1).Name = "evolved"; b1.evolved.Value = true
    Instance.new("IntValue", b1).Name = "exp"; b1.exp.Value = 0
    Instance.new("IntValue", b1).Name = "level"; b1.level.Value = 1
end
local function AddTribalOverlord()
    local unique = ensurePetsFolder()
    local c1 = Instance.new("StringValue")
    c1.Name = "Tribal Overlord"
    c1.Value = "rbxassetid://17601550091"
    c1.Parent = unique
    local c2 = Instance.new("Folder")
    c2.Name = "perksFolder"
    c2.Parent = c1
    Instance.new("IntValue", c2).Name = "strength"; c2.strength.Value = 3750
    Instance.new("IntValue", c2).Name = "durability"; c2.durability.Value = 2500
    Instance.new("IntValue", c2).Name = "damage"; c2.damage.Value = 50000
    Instance.new("StringValue", c1).Name = "chosenName"; c1.chosenName.Value = "部落霸主"
    Instance.new("BoolValue", c1).Name = "evolved"; c1.evolved.Value = true
    Instance.new("IntValue", c1).Name = "exp"; c1.exp.Value = 0
    Instance.new("IntValue", c1).Name = "level"; c1.level.Value = 1
end
local function AddWildWizard()
    local unique = ensurePetsFolder()
    local d1 = Instance.new("StringValue")
    d1.Name = "Wild Wizard"
    d1.Value = "rbxassetid://17601661532"
    d1.Parent = unique
    local d2 = Instance.new("Folder")
    d2.Name = "perksFolder"
    d2.Parent = d1
    Instance.new("IntValue", d2).Name = "agility"; d2.agility.Value = 750
    Instance.new("IntValue", d2).Name = "damage"; d2.damage.Value = 75000
    Instance.new("IntValue", d2).Name = "durability"; d2.durability.Value = 4000
    Instance.new("StringValue", d1).Name = "chosenName"; d1.chosenName.Value = "狂野巫师"
    Instance.new("BoolValue", d1).Name = "evolved"; d1.evolved.Value = true
    Instance.new("IntValue", d1).Name = "exp"; d1.exp.Value = 0
    Instance.new("IntValue", d1).Name = "level"; d1.level.Value = 1
end
TabBeautify:Button({ Title = "一键获得所有宠物", Callback = function()
    AddMightyMonster(); AddSwiftSamurai(); AddTribalOverlord(); AddWildWizard()
end })
TabBeautify:Button({ Title = "强大的怪物", Callback = function() AddMightyMonster() end })
TabBeautify:Button({ Title = "快速武士", Callback = function() AddSwiftSamurai() end })
TabBeautify:Button({ Title = "部落霸主", Callback = function() AddTribalOverlord() end })
TabBeautify:Button({ Title = "狂野巫师", Callback = function() AddWildWizard() end })
TabBeautify:Button({ Title = "解锁全部通行证", Callback = function()
    for _, v in ipairs(ReplicatedStorage:WaitForChild("gamepassIds"):GetChildren()) do v.Parent = LP.ownedGamepasses end
end })

local TabAuto = Window:Tab({ Title = "全自动福利" })
local autowheel, autobr, autocollect = false, false, false
local autoClaimGift = false
local autoDailyReward = false
local function getGiftRemote()
    local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
    if not rEvents then return nil end
    return rEvents:FindFirstChild("freeGiftClaimRemote")
end
TabAuto:Toggle({ Title = "自动领取在线奖励", Default = false, Callback = function(s)
    autoClaimGift = s
    if s then task.spawn(function() while autoClaimGift do
        local remote = getGiftRemote()
        if remote then for i = 1, 8 do
            if not autoClaimGift then break end
            pcall(function() remote:InvokeServer("claimGift", i) end)
            task.wait(0.15)
        end end
        task.wait(0.8)
    end end) end
end })
TabAuto:Toggle({ Title = "自动签到", Default = false, Callback = function(s)
    autoDailyReward = s
    if s then task.spawn(function() while autoDailyReward do
        pcall(function()
            local Event = ReplicatedStorage:WaitForChild("rEvents").dailyRewardRemote
            for i = 1, 7 do
                if not autoDailyReward then break end
                Event:InvokeServer("claim")
                task.wait(0.2)
            end
        end)
        task.wait(1)
    end end) end
end })
TabAuto:Toggle({ Title = "自动转盘抽奖", Default = false, Callback = function(s)
    autowheel = s
    if s then task.spawn(function()
        local Event = ReplicatedStorage:WaitForChild("rEvents").openFortuneWheelRemote
        while autowheel do pcall(function()
            Event:InvokeServer("openFortuneWheel", ReplicatedStorage:WaitForChild("shared"):WaitForChild("catalogs"):WaitForChild("fortuneWheelChances"):WaitForChild("Fortune Wheel"))
        end) task.wait() end
    end) end
end })
local redeemCodes = {"mightygems2500","ultimate250","spacegems50","megalift50","speedy50","epicreward500","MillionWarriors","frostgems10","Musclestorm50","Skyagility50","galaxycrystal50","supermuscle100","superpunch100","launch250","junglegym500","epicmusle20","musclestorm50","ASCENSION","STRONGBLOXIAN","HALLOWEENPART2","BLOODMOON","FROSTBITE","ZERODEGREES","ALIENINVASION"}
TabAuto:Button({ Title = "一键兑换兑换码", Callback = function()
    task.spawn(function()
        local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
        local codeRemote = rEvents and rEvents:FindFirstChild("codeRemote")
        if not codeRemote then return end
        for _, code in ipairs(redeemCodes) do
            pcall(function() codeRemote:InvokeServer(code) end)
            task.wait(0.5)
        end
    end)
end })

local TabBoss = Window:Tab({ Title = "自动打Boss" })
TabBoss:Toggle({ Title = "自动击杀Boss", Default = false, Callback = function(state)
    if state then task.spawn(function() while state do pcall(function()
        local c = LP.Character local root = c and c:FindFirstChild("HumanoidRootPart")
        if root then
            local arena = workspace:FindFirstChild("Events") and workspace.Events:FindFirstChild("BossArena")
            local bRoot = nil
            if arena then for _, slot in ipairs(arena:GetChildren()) do local b = slot:FindFirstChild("Boss") if b then bRoot = b:FindFirstChild("HumanoidRootPart") or b.PrimaryPart break end end end
            if bRoot then
                c.Humanoid.AutoRotate = false
                root.CFrame = CFrame.new(bRoot.Position + Vector3.new(0, bRoot.Size.Y/2 + 2, 0))
                local me = LP:FindFirstChild("muscleEvent") if me then me:FireServer("punch", "leftHand") me:FireServer("punch", "rightHand") end
                local p = c:FindFirstChild("Punch") or LP.Backpack:FindFirstChild("Punch") if p then c.Humanoid:EquipTool(p) p:Activate() end
            else c.Humanoid.AutoRotate = true end
        end
    end) task.wait(0.05) end end) end
end })