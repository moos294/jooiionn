queue_on_teleport([[loadstring(game:HttpGet("123自动"))()]])
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local placeId = game.PlaceId
local running = true

local slapDistance = 3.5
local stayTime = 0.3

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function equipDefault()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ClickDetector") and v.Parent and v.Parent.Name == "Default" then
            fireclickdetector(v)
            print("[装备] 已点击 Default 手套架")
            return true
        end
    end
    local char = getChar()
    if char:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool") then
        return true
    end
    warn("[装备] 没找到 Default 手套架")
    return false
end

local function enterArena()
    local hrp = getChar():WaitForChild("HumanoidRootPart")
    local portal = workspace:FindFirstChild("Teleport1", true)
        or workspace:FindFirstChild("NormalArenaPortal", true)
    if portal and portal:IsA("BasePart") then
        firetouchinterest(hrp, portal, 0)
        task.wait(0.1)
        firetouchinterest(hrp, portal, 1)
        print("[进场] 已触碰传送门")
        return true
    end
    warn("[进场] 没找到传送门")
    return false
end

local function slapEveryone()
    local char = getChar()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local tool = char:FindFirstChildOfClass("Tool")
        or player.Backpack:FindFirstChildOfClass("Tool")
    if tool then tool.Parent = char end

    for _, target in ipairs(Players:GetPlayers()) do
        if not running then break end
        if target ~= player and target.Character then
            local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
            local hum = target.Character:FindFirstChildOfClass("Humanoid")
            if tHrp and hum and hum.Health > 0 then
                hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, slapDistance)
                                * CFrame.Angles(0, math.rad(180), 0)
                task.wait(0.05)
                if tool then tool:Activate() end
                task.wait(stayTime)
            end
        end
    end
    print("[打人] 本轮完成")
end

local function hopServer()
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(placeId)
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if ok and res and res.data then
        for _, s in ipairs(res.data) do
            if s.id ~= game.JobId and s.playing > 1 and s.playing < s.maxPlayers then
                print("[换服] 前往:", s.id)
                TeleportService:TeleportToPlaceInstance(placeId, s.id, player)
                return
            end
        end
    end
    TeleportService:Teleport(placeId, player)
end

local function main()
    task.wait(3)
    equipDefault()
    task.wait(1)
    enterArena()
    task.wait(3)
    while running do
        slapEveryone()
        if not running then break end
        task.wait(1)
        hopServer() queue_on_teleport
        break
    end
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.H then
        running = not running
        print("[总开关]", running and "启动" or "停止")
        if running then task.spawn(main) end
    end
end)

task.spawn(main)
