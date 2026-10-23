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

local Tab1 = Window:Tab({ Title = "外服缝合", Icon = "link" })

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

Tab1:Button({
	Title = "执行偷来的聊天代码",
	Callback = function()
		local remote = ReplicatedStorage:FindFirstChild("CustomChatRemote")
		if remote then
			remote:FireServer("Hello")
			WindUI:Notify({ Title = "发送成功", Content = "已发送 Hello", Duration = 2 })
		else
			WindUI:Notify({ Title = "报错", Content = "找不到 CustomChatRemote", Duration = 2 })
		end
	end
})

Tab1:Toggle({
	Title = "偷来的带重量自动锻炼",
	Value = false,
	Callback = function(state)
		isTraining = state
		task.spawn(function()
			while isTraining do
				local remote = ReplicatedStorage:FindFirstChild("muscleEvent")
				if remote then
					remote:FireServer("rep", Weight)
				end
				task.wait(0.1)
			end
		end)
	end
})

Tab1:Toggle({
	Title = "偷来的带重量指定重生",
	Value = false,
	Callback = function(state)
		isRebirthing = state
		task.spawn(function()
			while isRebirthing do
				local remote = ReplicatedStorage:FindFirstChild("muscleEvent")
				if remote then
					remote:FireServer("rep", Weight)
				end
				task.wait(0.1)
			end
		end)
	end
})

local Tab2 = Window:Tab({ Title = "原版器材", Icon = "dumbbell" })

Tab2:Toggle({
	Title = "原版 自动锻炼",
	Value = false,
	Callback = function(state)
		task.spawn(function()
			while state do
				local ev = Players.LocalPlayer:FindFirstChild("muscleEvent")
				if ev then ev:FireServer("rep") end
				task.wait(0.1)
			end
		end)
	end
})

Tab2:Toggle({
	Title = "原版 超载硬拉",
	Value = false,
	Callback = function(state)
		if state then
			task.spawn(function()
				local ev = Players.LocalPlayer:FindFirstChild("muscleEvent")
				while state do
					if ev and workspace:FindFirstChild("machinesFolder") and workspace.machinesFolder:FindFirstChild("Overcharged Bar Lift") then
						ev:FireServer("rep", workspace.machinesFolder["Overcharged Bar Lift"].interactSeat)
					end
					task.wait(0.1)
				end
			end)
		end
	end
})

Tab2:Toggle({
	Title = "原版 超载跑步机",
	Value = false,
	Callback = function(state)
		if state then
			task.spawn(function()
				local Character = Players.LocalPlayer.Character
				if Character then
					local HRP = Character:FindFirstChild("HumanoidRootPart")
					local Hum = Character:FindFirstChild("Humanoid")
					if HRP and Hum then
						HRP.CFrame = CFrame.new(-2548.9, 181.38, 5484.23)
						task.wait(0.2)
						VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
						task.wait(0.05)
						VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
						task.wait(0.5)
						Hum.WalkSpeed = 10
						Hum.PlatformStand = true
					end
				end
			end)
		else
			local Character = Players.LocalPlayer.Character
			if Character then
				local Hum = Character:FindFirstChildOfClass("Humanoid")
				if Hum then
					Hum.WalkSpeed = 16
					Hum.PlatformStand = false
				end
			end
		end
	end
})