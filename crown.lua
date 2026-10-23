local RunService = game:GetService("RunService")
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
local TargetCount = 0
local isTraining = false
local isRebirthing = false
local trainConnection = nil
local rebConnection = nil

local Tab = Window:Tab({ Title = "主要", Icon = "zap" })

Tab:Input({
	Title = "目标次数",
	Placeholder = "自定义重生数量",
	Value = "",
	Callback = function(state)
		if tonumber(state) then
			TargetCount = tonumber(state)
		end
	end
})

Tab:Input({
	Title = "调倍率 (Weight)",
	Placeholder = "自己调节",
	Value = "1",
	Callback = function(state)
		if tonumber(state) then
			Multiplier = tonumber(state)
			WindUI:Notify({ Title = "倍率更新", Content = "当前倍率: " .. tostring(Multiplier), Duration = 2 })
		end
	end
})

Tab:Toggle({
	Title = "快速锻炼",
	Value = false,
	Callback = function(state)
		isTraining = state
		if trainConnection then trainConnection:Disconnect() end
		
		if state then
			trainConnection = RunService.Heartbeat:Connect(function()
				local remote = ReplicatedStorage:FindFirstChild("muscleEvent")
				if remote then
					pcall(function()
						remote:FireServer("rep", Multiplier)
					end)
				end
			end)
		end
	end
})

Tab:Toggle({
	Title = "重生",
	Value = false,
	Callback = function(state)
		isRebirthing = state
		if rebConnection then rebConnection:Disconnect() end
		
		if state then
			rebConnection = RunService.Heartbeat:Connect(function()
				local remote = ReplicatedStorage:FindFirstChild("muscleEvent")
				if remote then
					pcall(function()
						remote:FireServer("rep", Multiplier)
					end)
				end
			end)
		end
	end
})