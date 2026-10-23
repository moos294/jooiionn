local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local response = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
local WindUI = loadstring(response)()

local Window = WindUI:CreateWindow({
	Title = "专用0.1",
	Author = "专用",
	Folder = "Dedicated",
	HideSearchBar = true,
	Icon = "zap",
	OpenButton = {
		Title = "专用0.1",
		Color = ColorSequence.new(Color3.fromHex("00FFA3")),
		CornerRadius = UDim.new(0, 8),
		Draggable = true,
		Enabled = true,
		Icon = "zap"
	}
})

local Multiplier = 1
local Tab = Window:Tab({ Title = "主要", Icon = "zap" })

Tab:Input({
	Title = "调倍率 (Weight)",
	Placeholder = "自己调节",
	Value = "1",
	Callback = function(state)
		local num = tonumber(state)
		if num then
			Multiplier = num
			WindUI:Notify({ Title = "设置成功", Content = "当前倍率: " .. tostring(Multiplier), Duration = 2 })
		end
	end
})

Tab:Toggle({
	Title = "快速锻炼",
	Value = false,
	Callback = function(state)
		if state then
			task.spawn(function()
				while state do
					local remote = ReplicatedStorage:FindFirstChild("muscleEvent")
					if remote then
						pcall(function()
							remote:FireServer("rep", Multiplier)
						end)
					end
					task.wait(0.2)
				end
			end)
		end
	end
})

Tab:Toggle({
	Title = "重生",
	Value = false,
	Callback = function(state)
		if state then
			task.spawn(function()
				while state do
					local remote = ReplicatedStorage:FindFirstChild("muscleEvent")
					if remote then
						pcall(function()
							remote:FireServer("rep", Multiplier)
						end)
					end
					task.wait(0.2)
				end
			end)
		end
	end
})