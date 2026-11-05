local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存NB - 物理强绑定吸附 V2.0",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Size = UDim2.fromOffset(450, 350),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "主要功能 V2.0", Icon = "mouse-pointer" })
local Section = Tab:Section({ Title = "触屏防掉落引擎" })

local RS = game:GetService("ReplicatedStorage")
local LP = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local isAttaching = false
local attachConnection = nil
local currentTarget = nil
local isDragging = false

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

local function StartForceAttach()
    attachConnection = RunService.RenderStepped:Connect(function()
        if not isAttaching or not currentTarget or not currentTarget.Parent then return end
        
        local char = LP.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        if currentTarget:FindFirstChild("Owner") and currentTarget.Owner.Value ~= LP then
            if currentTarget.Owner.Value ~= nil then
                currentTarget = nil
                return
            end
        end

        local targetCFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 2, -6)
        
        local mainPart = currentTarget.PrimaryPart or currentTarget:FindFirstChild("Main") or currentTarget:FindFirstChild("WoodSection")
        if not mainPart then return end

        if currentTarget.PrimaryPart then
            currentTarget:PivotTo(targetCFrame)
        else
            mainPart.CFrame = targetCFrame
        end

        if not isDragging then
            isDragging = true
            task.spawn(function()
                while isAttaching and currentTarget and currentTarget.Parent do
                    pcall(function()
                        local args = {
                            "Refresh",
                            currentTarget,
                            1
                        }
                        RS:WaitForChild("Interaction"):WaitForChild("ClientIsDragging"):FireServer(unpack(args))
                    end)
                    task.wait(0.05)
                end
                isDragging = false
            end)
        end
    end)
end

UIS.TouchTap:Connect(function(touchPositions, gameProcessed)
    if gameProcessed or not isAttaching then return end
    
    if currentTarget then
        currentTarget = nil
    else
        local model = GetTouchedModel()
        if model then
            currentTarget = model
        end
    end
end)

Section:Toggle({
    Title = "开启手机点击吸附",
    Desc = "开启后，点一下物品强绑在面前，再点一下放下",
    Default = false
}, function(state)
    isAttaching = state
    if state then
        currentTarget = nil
        if not attachConnection then
            StartForceAttach()
        end
    else
        currentTarget = nil
        if attachConnection then
            attachConnection:Disconnect()
            attachConnection = nil
        end
    end
end)

Section:Button({
    Title = "强制刷新反斗城末日斧",
    Desc = "发送 Refresh 请求"
}, function()
    pcall(function()
        local args = {
            "Refresh",
            workspace:WaitForChild("Stores"):WaitForChild("WoodRUs"):WaitForChild("ShopItems"):WaitForChild("EndTimesAxe"),
            1
        }
        RS:WaitForChild("Interaction"):WaitForChild("ClientIsDragging"):FireServer(unpack(args))
    end)
    WindUI:Notify({Title = "封存NB V2.0", Content = "已发送请求", Duration = 3})
end)

Section:Button({
    Title = "执行飞行脚本",
    Desc = "加载 Pastebin 飞行"
}, function()
    pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/ZBzcTm1f"))() end)
end)