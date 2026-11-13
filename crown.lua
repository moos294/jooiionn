local player = game.Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

local function showAlert(title, text)
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 80)
    label.Position = UDim2.new(0, 0, 0.5, -40)
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.BackgroundTransparency = 0.2
    label.TextColor3 = Color3.new(1, 1, 0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = tostring(title) .. " | " .. tostring(text)
    label.Parent = gui
    task.wait(3)
    gui:Destroy()
end

showAlert("STEP 1", "Checking Whitelist...")

local url = "https://raw.githubusercontent.com/moos294/jooiionn/main/whitelist.txt"
local success, content = pcall(function() return game:HttpGet(url) end)

if not success or not content then
    showAlert("ERROR", "Whitelist Download Failed!")
    return
end

if not string.find(content, player.Name) then
    showAlert("ERROR", "You are not in the whitelist!")
    return
end

showAlert("SUCCESS", "Whitelist Verified!")

showAlert("STEP 2", "Loading UI Code...")

local ok, UI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/UI.lua"))()
end)

if not ok or not UI then
    showAlert("ERROR", "UI Download Failed!")
    return
end

showAlert("SUCCESS", "UI Code Downloaded!")

local ok2, err2 = pcall(function()
    for _, v in ipairs(UI.Gui.Panel:GetDescendants()) do
        if v:IsA("TextLabel") then
            if v.Text == "ORIGAMI" then v.Text = "Fengcun Wood V0.1" end
            if v.Text == "BUILD TOOL" then v.Text = "Author: Fengcun" end
        end
    end

    local Window = UI.Window
    local WindUI = UI.WindUI

    local TabHome = Window:Tab({ Title = "Home" })
    local TabTree = Window:Tab({ Title = "Tree" })
    local TabBuy = Window:Tab({ Title = "Buy" })
    local TabCraft = Window:Tab({ Title = "Craft" })
    local TabTP = Window:Tab({ Title = "Teleport" })
    local TabExtra = Window:Tab({ Title = "Extra" })

    TabHome:Paragraph({ Title = "Stats" })
    TabHome:Input({ Title = "WalkSpeed", Value = "16", Callback = function() end })
    TabHome:Input({ Title = "JumpPower", Value = "50", Callback = function() end })
    TabHome:Toggle({ Title = "Infinite Jump", Value = false, Callback = function() end })
    TabHome:Button({ Title = "Fly", Callback = function() end })
    
    TabHome:Paragraph({ Title = "Duck Assist" })
    TabHome:Button({ Title = "Decode Materials", Callback = function() end })
    TabHome:Button({ Title = "Angel Sequence", Callback = function() end })
    TabHome:Paragraph({ Title = "Anti-AFK" })
    TabHome:Button({ Title = "Enable Anti-AFK", Callback = function() end })

    TabTree:Paragraph({ Title = "Auto Chop" })
    TabTree:Dropdown({ Title = "Tree Type", Values = {"Generic", "LoneCave", "Electric"}, Value = "Generic", Callback = function() end })
    TabTree:Input({ Title = "Amount", Value = "1", Callback = function() end })
    TabTree:Button({ Title = "Start Chop", Callback = function() end })
    TabTree:Button({ Title = "Stop", Callback = function() end })

    TabBuy:Paragraph({ Title = "Buy Normal Duck" })
    TabBuy:Input({ Title = "Target Amount", Value = "1", Callback = function() end })
    TabBuy:Button({ Title = "Start Buy", Callback = function() end })
    TabBuy:Button({ Title = "Stop", Callback = function() end })
    TabBuy:Button({ Title = "Reset NPC Cache", Callback = function() end })
    
    TabBuy:Paragraph({ Title = "Buy Evil Duck Materials" })
    TabBuy:Button({ Title = "Buy and Bring", Callback = function() end })

    TabCraft:Paragraph({ Title = "Auto Craft Evil Duck" })
    TabCraft:Input({ Title = "Craft Amount", Value = "1", Callback = function() end })
    TabCraft:Button({ Title = "Start Auto Craft", Callback = function() end })
    TabCraft:Button({ Title = "Stop", Callback = function() end })

    TabCraft:Paragraph({ Title = "Trident" })
    TabCraft:Button({ Title = "Teleport to Altar", Callback = function() end })
    TabCraft:Dropdown({ Title = "Material Pos", Values = {"Heaven (Left)", "Star (Mid)", "Demon (Right)"}, Value = "Heaven (Left)", Callback = function() end })
    TabCraft:Button({ Title = "Get Airdrop Tool", Callback = function() end })

    TabCraft:Paragraph({ Title = "Eternal Sword" })
    TabCraft:Button({ Title = "Teleport to Altar", Callback = function() end })
    TabCraft:Dropdown({ Title = "Material Pos", Values = {"Trident (Left)", "Revenge (Mid)", "Demon (Right)"}, Value = "Trident (Left)", Callback = function() end })
    TabCraft:Button({ Title = "Get Airdrop Tool", Callback = function() end })

    TabCraft:Paragraph({ Title = "Revenge Sword" })
    TabCraft:Button({ Title = "Teleport to Altar", Callback = function() end })
    TabCraft:Dropdown({ Title = "Material Pos", Values = {"Demon", "Heaven"}, Value = "Demon", Callback = function() end })
    TabCraft:Button({ Title = "Get Airdrop Tool", Callback = function() end })

    TabCraft:Paragraph({ Title = "Star Duck" })
    TabCraft:Button({ Title = "Teleport to Altar", Callback = function() end })
    TabCraft:Dropdown({ Title = "Material Pos", Values = {"Heaven", "Normal", "Demon"}, Value = "Heaven", Callback = function() end })
    TabCraft:Button({ Title = "Get Airdrop Tool", Callback = function() end })

    TabCraft:Paragraph({ Title = "Hellfire" })
    TabCraft:Button({ Title = "Teleport to Altar", Callback = function() end })
    TabCraft:Dropdown({ Title = "Material Pos", Values = {"Trident", "Demon"}, Value = "Trident", Callback = function() end })
    TabCraft:Button({ Title = "Get Airdrop Tool", Callback = function() end })

    TabCraft:Paragraph({ Title = "Heaven Halo" })
    TabCraft:Button({ Title = "Teleport to Altar", Callback = function() end })
    TabCraft:Dropdown({ Title = "Material Pos", Values = {"Heaven Duck", "Eternal Sword"}, Value = "Heaven Duck", Callback = function() end })
    TabCraft:Button({ Title = "Get Airdrop Tool", Callback = function() end })

    TabCraft:Paragraph({ Title = "Heaven Sword" })
    TabCraft:Button({ Title = "Teleport to Altar", Callback = function() end })
    TabCraft:Button({ Title = "Get Airdrop Tool", Callback = function() end })

    TabCraft:Paragraph({ Title = "Crescent" })
    TabCraft:Button({ Title = "Teleport to Altar", Callback = function() end })
    TabCraft:Dropdown({ Title = "Material Pos", Values = {"Heaven Sword", "Hellfire"}, Value = "Heaven Sword", Callback = function() end })
    TabCraft:Button({ Title = "Get Airdrop Tool", Callback = function() end })

    TabCraft:Paragraph({ Title = "Moon Sword" })
    TabCraft:Button({ Title = "Teleport to Altar", Callback = function() end })
    TabCraft:Button({ Title = "Get Airdrop Tool", Callback = function() end })

    TabTP:Paragraph({ Title = "Tree Teleport" })
    TabTP:Dropdown({ Title = "Tree Type", Values = {"Generic", "LoneCave"}, Value = "Generic", Callback = function() end })
    TabTP:Button({ Title = "Teleport to Tree", Callback = function() end })
    
    TabTP:Paragraph({ Title = "Custom Teleport" })
    TabTP:Button({ Title = "Save Point 1", Callback = function() end })
    TabTP:Button({ Title = "Teleport to Point 1", Callback = function() end })
    TabTP:Button({ Title = "Save Point 2", Callback = function() end })
    TabTP:Button({ Title = "Teleport to Point 2", Callback = function() end })
    TabTP:Button({ Title = "Save Point 3", Callback = function() end })
    TabTP:Button({ Title = "Teleport to Point 3", Callback = function() end })

    TabExtra:Paragraph({ Title = "Item Teleport" })
    TabExtra:Dropdown({ Title = "Bring Pos", Values = {"Point 1", "Point 2", "Point 3"}, Value = "Point 1", Callback = function() end })
    TabExtra:Button({ Title = "Set Bring 1", Callback = function() end })
    TabExtra:Button({ Title = "Set Bring 2", Callback = function() end })
    TabExtra:Button({ Title = "Set Bring 3", Callback = function() end })
    TabExtra:Button({ Title = "Get Click TP Tool", Callback = function() end })
    TabExtra:Button({ Title = "Get Multi-Select Tool", Callback = function() end })
    TabExtra:Button({ Title = "TP Selected Items", Callback = function() end })
    TabExtra:Button({ Title = "Clear Selected", Callback = function() end })

    TabExtra:Paragraph({ Title = "Sell and Bring Ducks" })
    TabExtra:Button({ Title = "Sell All Wood", Callback = function() end })
    TabExtra:Dropdown({ Title = "Duck Type", Values = {"Angel", "Evil", "Lunar", "Normal", "Gift"}, Value = "Angel", Callback = function() end })
    TabExtra:Button({ Title = "Bring My Ducks", Callback = function() end })

    TabExtra:Paragraph({ Title = "Player Tracker" })
    TabExtra:Dropdown({ Title = "Player", Values = {"Player1", "Player2"}, Value = "Player1", Callback = function() end })
    TabExtra:Button({ Title = "Refresh Players", Callback = function() end })
    TabExtra:Button({ Title = "TP to Player", Callback = function() end })
    TabExtra:Toggle({ Title = "Loop TP to Player", Value = false, Callback = function() end })

    TabExtra:Paragraph({ Title = "Building Tools" })
    TabExtra:Button({ Title = "Get Sort Tool", Callback = function() end })
    
    TabExtra:Paragraph({ Title = "Cleanup" })
    TabExtra:Button({ Title = "Clean All Cache", Callback = function() end })
end)

if not ok2 then
    showAlert("UI ERROR", tostring(err2))
else
    showAlert("SUCCESS", "UI Skeleton Loaded Perfectly!")
end