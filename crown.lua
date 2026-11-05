local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存NB - 终极防掉落版",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Size = UDim2.fromOffset(450, 350),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "主要功能", Icon = "mouse-pointer" })
local Section = Tab:Section({ Title = "飞行防掉落" })

local RS = game:GetService("ReplicatedStorage")
local LP = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local isAttaching = false
local currentTarget = nil
local alignPos = nil
local alignOri = nil
local dragConnection = nil
local _G_OrigDrag = nil

local function ClearConstraints()
    if alignPos then alignPos:Destroy() alignPos = nil end
    if alignOri then alignOri:Destroy() alignOri = nil end
    if dragConnection then dragConnection:Disconnect() dragConnection = nil end
end

local function GetTouchedModel()
    local mouseLocation = UIS:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LP.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    if result and result.Instance then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChild("Owner") then
            if model.Owner.Value == LP or model.Owner.Value == nil then
                return model
            end
        end
    end
    return nil
end

local function StartAttach()
    if currentTarget then
        ClearConstraints()
        
        local mainPart = currentTarget.PrimaryPart or currentTarget:FindFirstChild("Main") or currentTarget:FindFirstChild("WoodSection")
        if not mainPart then return end

        pcall(function()
            mainPart:SetNetworkOwner(LP)
        end)

        alignPos = Instance.new("AlignPosition")
        alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
        alignPos.Attachment0 = Instance.new("Attachment", mainPart)
        alignPos.MaxForce = math.huge
        alignPos.Responsiveness = 200
        alignPos.Position = LP.Character.HumanoidRootPart.Position
        alignPos.Parent = mainPart

        alignOri = Instance.new("AlignOrientation")
        alignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
        alignOri.Attachment0 = alignPos.Attachment0
        alignOri.MaxTorque = math.huge
        alignOri.Responsiveness = 200
        alignOri.Parent = mainPart

        dragConnection = RunService.Heartbeat:Connect(function()
            if not isAttaching or not currentTarget or not currentTarget.Parent then
                ClearConstraints()
                return
            end
            
            local char = LP.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            pcall(function()
                mainPart:SetNetworkOwner(LP)
            end)
            
            local root = char.HumanoidRootPart
            local targetPos = root.Position + (root.CFrame.LookVector * 8) + Vector3.new(0, 3, 0)
            alignPos.Position = targetPos
            alignOri.CFrame = root.CFrame
            
            pcall(function()
                RS:WaitForChild("Interaction"):WaitForChild("ClientIsDragging"):FireServer(currentTarget)
            end)
        end)
    end
end

UIS.TouchTap:Connect(function(touchPositions, gameProcessed)
    if gameProcessed or not isAttaching then return end
    
    if currentTarget then
        currentTarget = nil
        ClearConstraints()
    else
        local model = GetTouchedModel()
        if model then
            currentTarget = model
            StartAttach()
        end
    end
end)

Section:Toggle({
    Title = "开启防掉落锁定",
    Desc = "点一下物品锁定，再点一下放下。物品悬浮在前方8格，绝不贴脸掉落",
    Default = false
}, function(state)
    isAttaching = state
    if state then
        pcall(function()
            local gui = LP.PlayerGui:FindFirstChild("ItemDraggingGUI")
            if gui and gui:FindFirstChild("Dragger") and not _G_OrigDrag then
                _G_OrigDrag = getsenv(gui.Dragger).canDrag
                getsenv(gui.Dragger).canDrag = function(f)
                    return true 
                end
            end
        end)
    else
        currentTarget = nil
        ClearConstraints()
        pcall(function()
            if _G_OrigDrag then
                local gui = LP.PlayerGui:FindFirstChild("ItemDraggingGUI")
                if gui and gui:FindFirstChild("Dragger") then
                    getsenv(gui.Dragger).canDrag = _G_OrigDrag
                end
                _G_OrigDrag = nil
            end
        end)
    end
end)

Section:Button({
    Title = "执行飞行脚本",
    Desc = "加载 Pastebin 飞行"
}, function()
    pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/ZBzcTm1f"))() end)
end)