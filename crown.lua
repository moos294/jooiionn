local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local response = game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua")
local WindUI = loadstring(response)()

local Window = WindUI:CreateWindow({
	Title = "专用",
	Author = "专用",
	Folder = "Dedicated",
	HideSearchBar = true,
	Icon = "zap",
	OpenButton = {
		Title = "专用",
		Color = ColorSequence.new(Color3.fromHex("00FFA3")),
		CornerRadius = UDim.new(0, 8),
		Draggable = true,
		Enabled = true,
		Icon = "zap"
	}
})

local Weight = 1
local isTraining = false
local isRebirthing = false

local Tab1 = Window:Tab({ Title = "缝合测试", Icon = "link" })

Tab1:Input({
	Title = "自定义重量 (Weight)",
	Placeholder = "输入重量数值",
	Value = "1",
	Callback = function(text)
		if tonumber(text) then
			Weight = tonumber(text)
		end
	end
})

Tab1:Toggle({
	Title = "带重量自动锻炼",
	Value = false,
	Callback = function(state)
		isTraining = state
		task.spawn(function()
			while isTraining do
				local remote = Players.LocalPlayer:FindFirstChild("muscleEvent")
				if remote then
					remote:FireServer("rep", Weight)
				end
				task.wait(0.1)
			end
		end)
	end
})

Tab1:Toggle({
	Title = "带重量指定重生",
	Value = false,
	Callback = function(state)
		isRebirthing = state
		task.spawn(function()
			while isRebirthing do
				local remote = Players.LocalPlayer:FindFirstChild("muscleEvent")
				if remote then
					remote:FireServer("rep", Weight)
				end
				task.wait(0.1)
			end
		end)
	end
})

Tab1:Toggle({
	Title = "狂暴极速锻炼 (原版协议)",
	Value = false,
	Callback = function(state)
		task.spawn(function()
			while state do
				local remote = Players.LocalPlayer:FindFirstChild("muscleEvent")
				if remote then
					remote:FireServer("rep")
					remote:FireServer("rep")
					remote:FireServer("rep")
					remote:FireServer("rep")
					remote:FireServer("rep")
				end
				task.wait(0.1)
			end
		end)
	end
})