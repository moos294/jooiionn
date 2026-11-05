local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "木材大亨 - 智能收割机",
    Icon = "rbxassetid://10882439086",
    Author = "Bypass",
    Size = UDim2.fromOffset(450, 420),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "自动化控制", Icon = "rbxassetid://10734898355" })

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")

local isRunning = false
local runThread = nil
local basePosition = nil
local targetTreeName = ""
local maxChopCount = 10
local currentChopCount = 0

local translationMap = {
    ["Tree"] = "普通树",
    ["TreeModel"] = "原木树",
    ["AppleTree"] = "苹果树",
    ["oak"] = "橡树",
    ["DogWood"] = "山茱萸木",
    ["PumpkinWood"] = "南瓜树",
    ["GlobeWood"] = "球状木",
    ["Loose_Koa"] = "夏威夷相思木",
    ["Pine"] = "松树",
    ["Birch"] = "白桦树",
    ["Cherry"] = "樱桃树",
    ["Walnut"] = "核桃木",
    ["Spruce"] = "云杉",
    ["Maple"] = "枫树",
    ["Cedar"] = "雪松",
    ["Gold"] = "黄金树",
    ["Lava"] = "熔岩木",
    ["Cavecrawler"] = "洞穴木",
    ["Zombie"] = "僵尸木"
}

local StatusParagraph = Tab:Paragraph({
    Title = "运行状态",
    Desc = "等待开启 | 基地: 未记录",
    Color = "Red"
})

local treeOptions = {}
local displayToRealName = {}
local logModels = workspace:FindFirstChild("LogModels")

if logModels then
    for _, tree in pairs(logModels:GetChildren()) do
        if tree:FindFirstChild("CutEvent") then
            local realName = tree.Name
            local cnName = translationMap[realName] or "未知树种"
            local displayName = realName .. " (" .. cnName .. ")"
            
            if not displayToRealName[displayName] then
                table.insert(treeOptions, displayName)
                displayToRealName[displayName] = realName
            end
        end
    end
end

if #treeOptions == 0 then
    table.insert(treeOptions, "未找到树木(请重新注入)")
end

Tab:Dropdown({
    Title = "选择要砍的树木类型",
    Desc = "已为你翻译为中文",
    Values = treeOptions,
    Default = treeOptions[1],
    Callback = function(option)
        targetTreeName = displayToRealName[option] or option
    end
})

targetTreeName = displayToRealName[treeOptions[1]] or treeOptions[1]

Tab:Slider({
    Title = "自定义砍伐数量",
    Desc = "砍满此数量后自动停止并回城",
    Value = {
        Min = 1,
        Max = 100,
        Default = 10,
    },
    Callback = function(value)
        maxChopCount = value
    end
})

Tab:Button({
    Title = "记录当前点为基地",
    Desc = "把目前站立的位置设为回城点",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            basePosition = char.HumanoidRootPart.CFrame
            StatusParagraph:SetTitle("运行状态: 基地已记录")
            StatusParagraph:SetDesc("基地坐标: " .. math.floor(basePosition.X) .. ", " .. math.floor(basePosition.Z))
            StatusParagraph:SetColor("Green")
            WindUI:Notify({ Title = "成功", Content = "基地坐标已记录！", Duration = 3 })
        end
    end
})
local function getProxy()
    return rs:WaitForChild("Interaction"):WaitForChild("RemoteProxy", 5)
end

local function getSpecificTree(name)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart
    
    local logModels = workspace:FindFirstChild("LogModels")
    if not logModels then return nil end

    local nearestTree, shortestDist = nil, 99999
    for _, tree in pairs(logModels:GetChildren()) do
        if tree.Name == name and tree:FindFirstChild("CutEvent") then
            local pos = tree:IsA("Model") and tree:GetPivot().Position or tree.Position
            local dist = (hrp.Position - pos).Magnitude
            if dist < shortestDist then
                shortestDist, nearestTree = dist, tree
            end
        end
    end
    return nearestTree
end

local function doChop()
    local char = player.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local proxy = getProxy()
    if not proxy then return false end
    
    local tool = char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
    local tree = getSpecificTree(targetTreeName)
    
    if not tree or not tool then return false end
    
    local treePos = tree:IsA("Model") and tree:GetPivot().Position or tree.Position
    local cutEvent = tree:FindFirstChild("CutEvent")
    
    hrp.CFrame = CFrame.new(treePos + Vector3.new(0, 3, 0))
    task.wait(0.1)
    
    local args = {
        cutEvent,
        {
            height = math.random(1, 10),
            faceVector = Vector3.new(-1, 0, 0),
            cooldown = -0.1,
            sectionId = math.random(1, 10),
            hitPoints = 18000,
            tool = tool,
            cuttingClass = "Axe"
        }
    }
    pcall(function()
        proxy:FireServer(unpack(args))
    end)
    
    task.wait(0.2)
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
            local objName = string.lower(obj.Name)
            local isWood = string.find(objName, "log") or string.find(objName, "wood") or string.find(objName, "plank")
            local isNotStore = obj.Name ~= "WoodRUs" and obj.Name ~= "WOODDROPOFF" and obj.Name ~= "WoodSection"
            
            if isWood and isNotStore then
                pcall(function()
                    if obj:IsA("Model") then
                        obj:PivotTo(hrp.CFrame * CFrame.new(0, -2, 0))
                    else
                        obj.CFrame = hrp.CFrame * CFrame.new(0, -2, 0)
                    end
                end)
            end
        end
    end
    
    currentChopCount = currentChopCount + 1
    StatusParagraph:SetDesc("进度: " .. currentChopCount .. " / " .. maxChopCount)
    return true
end

local function autoLoop()
    currentChopCount = 0
    
    while isRunning do
        if currentChopCount >= maxChopCount then
            isRunning = false
            
            if basePosition then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = basePosition
                end
            end
            
            StatusParagraph:SetTitle("运行状态: 已完成砍伐任务")
            StatusParagraph:SetColor("Green")
            WindUI:Notify({ Title = "任务完成", Content = "已砍满 " .. maxChopCount .. " 棵树，已回城。", Duration = 5 })
            
            local toggleObj = Window:GetToggle("开启自动瞬移收割")
            if toggleObj then toggleObj:Set(false) end
            break
        end

        local success = doChop()
        if not success then
            task.wait(1)
        else
            task.wait(0.3)
        end
    end
end

Tab:Toggle({
    Title = "开启自动瞬移收割",
    Desc = "按照设定的数量和树种开始工作",
    Default = false,
    Callback = function(state)
        isRunning = state
        if isRunning then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if not basePosition then
                    basePosition = char.HumanoidRootPart.CFrame
                end
                StatusParagraph:SetTitle("运行状态: 正在干活中...")
                StatusParagraph:SetColor("Green")
                runThread = task.spawn(autoLoop)
            else
                WindUI:Notify({ Title = "错误", Content = "角色未加载", Duration = 3 })
                isRunning = false
            end
        else
            StatusParagraph:SetTitle("运行状态: 已暂停")
            StatusParagraph:SetColor("Red")
            if runThread then
                task.cancel(runThread)
                runThread = nil
            end
        end
    end
})