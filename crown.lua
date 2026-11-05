local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "封存NB - 手机专属吸附",
    Icon = "rbxassetid://10882439086",
    Author = "封存NB",
    Folder = "BaiScript",
    Size = UDim2.fromOffset(450, 350),
    Transparent = true,
    Theme = "Dark"
})

local Tab = Window:Tab({ Title = "主要功能", Icon = "mouse-pointer" })
local Section = Tab:Section({ Title = "触屏功能" })

local RS = game:GetService("ReplicatedStorage")
local LP = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local isAttaching = false
local attachConnection = nil
local currentTarget = nil

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
        
        local targetPos = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -6)
        
        if currentTarget.PrimaryPart then
            currentTarget:PivotTo(targetPos)
        elseif currentTarget:FindFirstChild("Main") then
            currentTarget.Main.CFrame = targetPos
        elseif currentTarget:FindFirstChild("WoodSection") then
            currentTarget.WoodSection.CFrame = targetPos
        end
        
        pcall(function()
            local args = {
                "Refresh",
                currentTarget,
                1
            }
            RS:WaitForChild("Interaction"):WaitForChild("ClientIsDragging"):FireServer(unpack(args))
        end)
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
    Desc = "开启后，点一下物品它就死贴在你面前，再点一下放下",
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
    Desc = "发送你抓到的 Refresh 请求"
}, function()
    local success, err = pcall(function()
        local args = {
            "Refresh",
            workspace:WaitForChild("Stores"):WaitForChild("WoodRUs"):WaitForChild("ShopItems"):WaitForChild("EndTimesAxe"),
            1
        }
        RS:WaitForChild("Interaction"):WaitForChild("ClientIsDragging"):FireServer(unpack(args))
    end)
    if success then
        WindUI:Notify({Title = "成功", Content = "已发送末日斧刷新指令", Duration = 3})
    else
        WindUI:Notify({Title = "失败", Content = "刷新失败，可能不在对应服务器", Duration = 3})
    end
end)

Section:Button({
    Title = "执行飞行脚本",
    Desc = "加载 Pastebin 飞行"
}, function()
    pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/ZBzcTm1f"))() end)
end)