(function(define)
	repeat
		game:GetService("RunService").Heartbeat:wait()
	until game:IsLoaded();

	local _CONFIGS = {
	   ["UI_NAME"] = define,
	   ["传送模式"] = 2,
	};
	
	local HONG = { GS = function(...) return game.GetService(game, ...); end; }
	HONG.RS = HONG.GS"RunService"
	HONG.RES = HONG.GS"ReplicatedStorage"
	HONG.LP = HONG.GS"Players".LocalPlayer
	HONG.WKSPC = HONG.GS"Workspace"
	HONG.COREGUI = HONG.GS "CoreGui";
	
	function HONG:DragModel(...)
		local Args = { ... };
		assert(Args[1]:IsA("Model") == true, "参数1必须是模型!");
		pcall(function() self.RES.Interaction.ClientIsDragging:FireServer(Args[1]) end);
		if not Args[1].PrimaryPart then Args[1].PrimaryPart = Args[1]:FindFirstChildOfClass("Part") end
		Args[1]:SetPrimaryPartCFrame(Args[2])
	end
	
	function HONG:Teleport(...)
		local Args = { ... };
		if self.LP.Character.Humanoid.SeatPart then
			spawn(function() for i = 1, 15 do self:DragModel(self.LP.Character.Humanoid.SeatPart.Parent, Args[1]); end end)
			return;
		end
		for i = 1, 3 do self:DragModel(self.LP.Character, Args[1]); task.wait(); end
	end
    
	local b = setmetatable({}, {
		__index = function(self, c) return game.GetService(game, c) end,
		__call = function(self, c) return game:GetService(c) end
	})
	if b.CoreGui:FindFirstChild(_CONFIGS.UI_NAME) then b.CoreGui[_CONFIGS.UI_NAME]:Destroy() end
	local dm, dn, dp, dq, dr = UDim.new, UDim2.new, Color3.fromRGB, Instance.new, function() end
	local ds = b.Players.LocalPlayer:GetMouse()
	getgenv().library = { flags = { GetState = function(dt, du) return library.flags[du].State end }, modules = {}, currentTab = nil }
	
	local dv = {}
	function dv:Tween(dw, dx, dy, dz, dA) return b.TweenService:Create(dx, TweenInfo.new(dy or 0.25, Enum.EasingStyle[dz or "Linear"], Enum.EasingDirection[dA or "InOut"]), dw) end
	function dv:SwitchTab(dB)
		local dC = library.currentTab
		if dC == dB then return end
		library.currentTab = dB
		dv:Tween({ Transparency = 1 }, dC[2].Glow):Play()
		dv:Tween({ Transparency = 0 }, dB[2].Glow):Play()
		dC[1].Visible = false
		dB[1].Visible = true
	end
	
	local dD, Open, dE, dF, dG, dH = dq("ScreenGui"), dq("TextButton"), dq("Frame"), dq("UICorner"), dq("TextLabel"), dq("UICorner")
	local dI, dJ, dK, dL, dM, dN, dO = dq("Frame"), dq("UICorner"), dq("ScrollingFrame"), dq("UIListLayout"), dq("UIPadding"), dq("Frame"), dq("UICorner")
	
	dD.Name = _CONFIGS.UI_NAME
	dD.Parent = b.CoreGui
	dE.Name = "Main"
	dE.Parent = dD
	dE.BackgroundColor3 = dp(52, 62, 72)
	dE.BorderSizePixel = 0
	dE.Position = dn(0.5, 0, 0.5, 0)
	dE.Size = dn(0, 448, 0, 280)
	dE.AnchorPoint = Vector2.new(0.5, 0.5)
	dE.Active = true
	dE.Draggable = true
	dF.CornerRadius = dm(0, 6)
	dF.Parent = dE
	dG.Parent = dE
	dG.BackgroundColor3 = dp(58, 69, 80)
	dG.BorderSizePixel = 0
	dG.Position = dn(0, 6, 0, 6)
	dG.Size = dn(0, 436, 0, 24)
	dG.Font = Enum.Font.GothamBold
	dG.Text = "  " .. _CONFIGS.UI_NAME;
	dG.TextColor3 = dp(255, 255, 255)
	dG.TextSize = 14.000
	dG.TextXAlignment = Enum.TextXAlignment.Left
	
	Open.Name = "Open"
	Open.Parent = dD
	Open.BackgroundColor3 = dE.BackgroundColor3;
	Open.Position = UDim2.new(0.839879155, 0, - 0.0123076923, 0)
	Open.BorderSizePixel = 2
	Open.BorderColor3 = dG.BackgroundColor3
	Open.Size = UDim2.new(0, 55, 0, 25)
	Open.Font = Enum.Font.SourceSans
	Open.Text = "隐藏"
	Open.TextColor3 = Color3.fromRGB(255, 255, 255)
	Open.TextSize = 14.000
	Open.Active = true
	Open.Draggable = true
	
	local TOGGLE = true;
	Open.MouseButton1Down:connect(function()
		TOGGLE = not TOGGLE
		dE.Visible = TOGGLE
		Open.Text = (TOGGLE and "隐藏" or "打开");
	end)
	
	dH.CornerRadius = dm(0, 6)
	dH.Parent = dG
	dI.Name = "Sidebar"
	dI.Parent = dE
	dI.BackgroundColor3 = dp(58, 69, 80)
	dI.BorderSizePixel = 0
	dI.Position = dn(0, 6, 0, 36)
	dI.Size = dn(0, 106, 0, 238)
	dJ.CornerRadius = dm(0, 6)
	dJ.Parent = dI
	dK.Name = "TabButtons"
	dK.Parent = dI
	dK.Active = true
	dK.BackgroundColor3 = dp(255, 255, 255)
	dK.BackgroundTransparency = 1.000
	dK.BorderSizePixel = 0
	dK.Size = dn(0, 106, 0, 238)
	dK.ScrollBarThickness = 0
	dL.Parent = dK
	dL.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dL.SortOrder = Enum.SortOrder.LayoutOrder
	dL.Padding = dm(0, 5)
	dM.Parent = dK
	dM.PaddingTop = dm(0, 6)
	dN.Name = "TabHolder"
	dN.Parent = dE
	dN.BackgroundColor3 = dp(58, 69, 80)
	dN.BorderSizePixel = 0
	dN.Position = dn(0, 118, 0, 36)
	dN.Size = dn(0, 324, 0, 238)
	dO.CornerRadius = dm(0, 6)
	dO.Parent = dN
	
	dL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		dK.CanvasSize = dn(0, 0, 0, dL.AbsoluteContentSize.Y + 12)
	end)
	
	function library:CreateTab(dZ)
		local d_ = dq("TextButton")
		local e0 = dq("UICorner")
		local e1 = dq("Frame")
		local e2 = dq("UICorner")
		local e3 = dq("UIGradient")
		local e4 = dq("ScrollingFrame")
		local e5 = dq("UIPadding")
		local e6 = dq("UIListLayout")
		
		d_.Parent = dK
		d_.BackgroundColor3 = dp(52, 62, 72)
		d_.BorderSizePixel = 0
		d_.Size = dn(0, 94, 0, 28)
		d_.AutoButtonColor = false
		d_.Font = Enum.Font.GothamSemibold
		d_.Text = dZ
		d_.TextColor3 = dp(255, 255, 255)
		d_.TextSize = 14.000
		e0.CornerRadius = dm(0, 6)
		e0.Parent = d_
		e1.Name = "Glow"
		e1.Parent = d_
		e1.BackgroundColor3 = dp(255, 255, 255)
		e1.BorderSizePixel = 0
		e1.Position = dn(0, 0, 0.928571463, 0)
		e1.Size = dn(0, 94, 0, 2)
		e1.Transparency = 1
		e2.CornerRadius = dm(0, 6)
		e2.Parent = e1
		e3.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0.00, dp(52, 62, 72)), ColorSequenceKeypoint.new(0.50, dp(255, 255, 255)), ColorSequenceKeypoint.new(1.00, dp(52, 62, 72)) }
		e3.Parent = e1
		e4.Name = "Tab"
		e4.Parent = dN
		e4.Active = true
		e4.BackgroundColor3 = dp(255, 255, 255)
		e4.BackgroundTransparency = 1.000
		e4.BorderSizePixel = 0
		e4.Size = dn(0, 324, 0, 238)
		e4.ScrollBarThickness = 0
		e4.Visible = false
		
		if library.currentTab == nil then
			library.currentTab = { e4, d_ }
			e1.Transparency = 0
			e4.Visible = true
		end
		
		e5.Parent = e4
		e5.PaddingTop = dm(0, 6)
		e6.Parent = e4
		e6.HorizontalAlignment = Enum.HorizontalAlignment.Center
		e6.SortOrder = Enum.SortOrder.LayoutOrder
		e6.Padding = dm(0, 5)
		e6:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			e4.CanvasSize = dn(0, 0, 0, e6.AbsoluteContentSize.Y + 12)
		end)
		d_.MouseButton1Click:Connect(function() dv:SwitchTab({ e4, d_ }) end)
		
		local e7 = {}
		function e7:NewButton(e9, ea)
			local eb = dq("TextButton")
			local ec = dq("UICorner")
			eb.Parent = e4
			eb.BackgroundColor3 = dp(52, 62, 72)
			eb.BorderSizePixel = 0
			eb.Size = dn(0, 312, 0, 28)
			eb.AutoButtonColor = false
			eb.Font = Enum.Font.GothamSemibold
			eb.Text = "  " .. e9
			eb.TextColor3 = dp(255, 255, 255)
			eb.TextSize = 14.000
			eb.TextXAlignment = Enum.TextXAlignment.Left
			ec.CornerRadius = dm(0, 6)
			ec.Parent = eb
			eb.MouseButton1Click:Connect(ea or dr)
		end
		
		function e7:NewSlider(e9, du, em, ey, ez, eA, ea)
			local eB = dq("TextButton")
			local eC = dq("UICorner")
			local eD = dq("Frame")
			local eE = dq("UICorner")
			local eF = dq("Frame")
			local eG = dq("UICorner")
			local eH = dq("TextBox")
			local eI = dq("UICorner")
			
			library.flags[du] = {
				State = em,
				SetValue = function(self, be)
					local eL = (ds.X - eD.AbsolutePosition.X) / eD.AbsoluteSize.X
					if be then eL = (be - ey) / (ez - ey) end
					eL = math.clamp(eL, 0, 1)
					if eA then be = be or tonumber(string.format("%.1f", tostring(ey + (ez - ey) * eL)))
					else be = be or math.floor(ey + (ez - ey) * eL) end
					library.flags[du].State = tonumber(be)
					eH.Text = tostring(be)
					eF.Size = dn(eL, 0, 1, 0)
					(ea or dr)(tonumber(be))
				end
			}
			
			eB.Parent = e4
			eB.BackgroundColor3 = dp(52, 62, 72)
			eB.BorderSizePixel = 0
			eB.Size = dn(0, 312, 0, 28)
			eB.AutoButtonColor = false
			eB.Font = Enum.Font.GothamSemibold
			eB.Text = "  " .. e9
			eB.TextColor3 = dp(255, 255, 255)
			eB.TextSize = 14.000
			eB.TextXAlignment = Enum.TextXAlignment.Left
			eC.CornerRadius = dm(0, 6)
			eC.Parent = eB
			eD.Name = "SliderBar"
			eD.Parent = eB
			eD.BackgroundColor3 = dp(58, 69, 80)
			eD.BorderSizePixel = 0
			eD.Position = dn(0.442307681, 0, 0.392857134, 0)
			eD.Size = dn(0, 108, 0, 6)
			eE.CornerRadius = dm(0, 2)
			eE.Parent = eD
			eF.Name = "SliderPart"
			eF.Parent = eD
			eF.BackgroundColor3 = dp(255, 255, 255)
			eF.BorderSizePixel = 0
			eF.Size = dn(0, 0, 0, 6)
			eG.CornerRadius = dm(0, 2)
			eG.Parent = eF
			eH.Name = "SliderValue"
			eH.Parent = eB
			eH.BackgroundColor3 = dp(58, 69, 80)
			eH.BorderSizePixel = 0
			eH.Position = dn(0.884615362, 0, 0.178571433, 0)
			eH.Size = dn(0, 32, 0, 18)
			eH.Font = Enum.Font.Gotham
			eH.Text = em or ey
			eH.TextColor3 = dp(255, 255, 255)
			eH.TextSize = 12.000
			eI.CornerRadius = dm(0, 4)
			eI.Parent = eH
			
			local dS = false
			eD.InputBegan:Connect(function(dX) if dX.UserInputType == Enum.UserInputType.MouseButton1 or dX.UserInputType == Enum.UserInputType.Touch then library.flags[du]:SetValue(); dS = true end end)
			b.UserInputService.InputEnded:Connect(function(dX) if dS and dX.UserInputType == Enum.UserInputType.MouseButton1 or dX.UserInputType == Enum.UserInputType.Touch then dS = false end end)
			b.UserInputService.InputChanged:Connect(function(dX) if dS == true then library.flags[du]:SetValue() end end)
			library.flags[du]:SetValue(em)
		end
		
		function e7:NewDropdown(e9, du, eP, ea)
			local ea = ea or dr
			library.flags[du] = { State = eP[1] }
			local eQ = dq("TextButton")
			local eR = dq("UICorner")
			local eS = dq("TextBox")
			local eT = dq("TextButton")
			local eU = dq("TextButton")
			local eV = dq("UICorner")
			local eW = dq("UIListLayout")
			local eX = dq("UIPadding")
			
			eQ.Parent = e4
			eQ.BackgroundColor3 = dp(52, 62, 72)
			eQ.BorderSizePixel = 0
			eQ.Size = dn(0, 312, 0, 28)
			eQ.AutoButtonColor = false
			eQ.Text = ""
			eR.CornerRadius = dm(0, 6)
			eR.Parent = eQ
			eS.Name = "DropdownText"
			eS.Parent = eQ
			eS.BackgroundTransparency = 1.000
			eS.Position = dn(0.025641026, 0, 0, 0)
			eS.Size = dn(0, 192, 0, 28)
			eS.Font = Enum.Font.GothamSemibold
			eS.PlaceholderText = e9
			eS.PlaceholderColor3 = dp(255, 255, 255)
			eS.TextColor3 = dp(255, 255, 255)
			eS.TextSize = 14.000
			eS.TextXAlignment = Enum.TextXAlignment.Left
			eS.Text = ""
			eT.Name = "OpenDropdown"
			eT.Parent = eQ
			eT.BackgroundTransparency = 1.000
			eT.Position = dn(0.907051265, 0, 0.178571433, 0)
			eT.Size = dn(0, 18, 0, 18)
			eT.Font = Enum.Font.Gotham
			eT.Text = "+"
			eT.TextColor3 = dp(255, 255, 255)
			eT.TextSize = 22.000
			eU.Name = "DropdownBottom"
			eU.Parent = e4
			eU.BackgroundColor3 = dp(52, 62, 72)
			eU.BorderSizePixel = 0
			eU.ClipsDescendants = true
			eU.Position = dn(0.0185185187, 0, 0.206896558, 0)
			eU.Size = dn(0, 312, 0, 0)
			eU.AutoButtonColor = false
			eU.Text = ""
			eU.Visible = false
			eV.CornerRadius = dm(0, 6)
			eV.Parent = eU
			eW.Parent = eU
			eW.HorizontalAlignment = Enum.HorizontalAlignment.Center
			eW.SortOrder = Enum.SortOrder.LayoutOrder
			eW.Padding = dm(0, 6)
			eX.Parent = eU
			eX.PaddingTop = dm(0, 6)
			
			local eY = false
			eW:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if not eY then return end
				dv:Tween({ Size = dn(0, 312, 0, eW.AbsoluteContentSize.Y + 12) }, eU, 0.1):Play()
			end)
			
			local f0 = function()
				eY = not eY
				if eY then
					eU.Visible = true
					for _, Element in next, eU:GetChildren() do
						if Element:IsA("TextButton") then
							if string.find(Element.Name:lower(), eS.Text:lower()) then Element.Visible = true else Element.Visible = false end
						end
					end
				else
					task.spawn(function() task.wait(0.35); eU.Visible = false end)
				end
				eT.Text = eY and "-" or "+"
				dv:Tween({ Size = dn(0, 312, 0, eY and eW.AbsoluteContentSize.Y + 12 or 0) }, eU, 0.35):Play()
			end
			eT.MouseButton1Click:Connect(f0)
			
			library.flags[du].SetOptions = function(self, eP)
				library.flags[du]:ClearOptions()
				for ai = 1, # eP do library.flags[du]:AddOption(eP[ai]) end
			end
			library.flags[du].ClearOptions = function(self)
				for ai, dx in pairs(eU:GetChildren()) do if dx:IsA("TextButton") then dx:Destroy() end end
			end
			library.flags[du].AddOption = function(self, bd)
				local f2 = dq("TextButton")
				local f3 = dq("UICorner")
				f2.Name = bd
				f2.Parent = eU
				f2.BackgroundColor3 = dp(58, 69, 80)
				f2.BorderSizePixel = 0
				f2.Size = dn(0, 300, 0, 28)
				f2.AutoButtonColor = false
				f2.Font = Enum.Font.GothamSemibold
				f2.Text = bd
				f2.TextColor3 = dp(255, 255, 255)
				f2.TextSize = 14.000
				f3.CornerRadius = dm(0, 6)
				f3.Parent = f2
				f2.MouseButton1Click:Connect(function()
					eS.PlaceholderText = bd
					eS.Text = ""
					library.flags[du].State = bd
					task.spawn(f0)
					ea(bd)
				end)
			end
			library.flags[du]:SetOptions(eP)
		end
		return e7
	end
	
	setmetatable(getgenv().library, {
		__newindex = function(self, i, v)
			if i == 'Name' then dG.Text = "   " .. v; return true end
			rawset(self, i, v)
		end
	})
	
	local Page4 = library:CreateTab("木材菜单");
	
	local function getDamage(tool)
		local modTool = require(game:GetService("ReplicatedStorage").AxeClasses[("AxeClass_%s"):format(tool.ToolName.Value)])
		local t = modTool.new()
		return t.Damage
	end
	
	local MIXI_ENDTIME_PART = function()
		if HONG.WKSPC:FindFirstChild"MIXI_EndTimeTree_OfPart" then return end
		local part = Instance.new("Part", HONG.WKSPC)
		part.Size = Vector3.new(300, 1, 300)
		part.CFrame = CFrame.new(- 45.1, - 216.15, - 1341.15)
		part.Anchored = true
		part.BrickColor = BrickColor.new("Bright red")
		part.Material = Enum.Material.DiamondPlate
		part.Name = "MIXI_EndTimeTree_OfPart"
	end
	
	local function cutTree(config)
		local config = config or {};
		config.Cutevent = config.Cutevent or nil;
		config.Tool = config.Tool or nil;
		config.Height = config.Height or 0.3;
		config.SectionId = config.SectionId or 1;
		config.FaceVector = config.FaceVector or Vector3.new(1, 0, 0);
		local damage
		
		if config.Tool.ToolName.Value == "EndTimesAxe" and config.Cutevent.Parent.TreeClass.Value == "LoneCave" then
			damage = 10000000;
			MIXI_ENDTIME_PART()
		else
			damage = getDamage(config.Tool);
		end
		
		game:GetService("ReplicatedStorage").Interaction.RemoteProxy:FireServer(
	    config.Cutevent, {
			["tool"] = config.Tool;
			["faceVector"] = config.FaceVector;
			["height"] = config.Height;
			["sectionId"] = config.SectionId;
			["hitPoints"] = tonumber(damage);
			["cooldown"] = 0.01;
			["cuttingClass"] = "Axe";
		})
	end
	
	local function getNo1Axe(tree)
		local axes = {};
		local bestTool
		for _, v in next, HONG.LP.Character:GetChildren() do
			if v:IsA("Tool") and v.Name ~= "BlueprintTool" and v:FindFirstChild("CuttingTool") then table.insert(axes, v) end
		end
		for _, v in next, HONG.LP.Backpack:GetChildren() do
			if v:IsA("Tool") and v.Name ~= "BlueprintTool" and v:FindFirstChild("CuttingTool") then table.insert(axes, v) end
		end
		local bbb = {}
		for i, v in next, axes do
			local damage
			if v.ToolName.Value == "EndTimesAxe" and tree == "LoneCave" then return v
			else table.insert(bbb, v) end
		end
		for i, v in next, bbb do
			if math.max(getDamage(v)) then bestTool = v; end
		end
		return bestTool
	end
	
	local getAxe = function(tree)
		local Axe = getNo1Axe(tree);
		if not Axe then return end
		return Axe
	end
	   
	local function bringTree(config)
		local config = config or {};
		config.TreeValue = config.TreeValue or "Generic";
		config.Quantity = config.Quantity or 1;
		local oldpos = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame;
		
		if not getAxe(config.TreeValue) then 
		    HONG:Teleport(oldpos)
		    return
		end
		    
		local woods = {}
		local sum = 0;
		while sum < config.Quantity  do
			local wood, treeToCut;
			local checkWoodSize = {};
			for _, v in next, game:GetService("Workspace"):GetDescendants() do
				if v.Name == "TreeRegion" then
					for _, model in next, v:children() do
						if model:FindFirstChild("CutEvent") then
							if model:FindFirstChild("WoodSection") then
								if model.Owner.Value == nil or model.Owner.Value == HONG.LP then
									if not model:FindFirstChild("RootCut") then
										if model.TreeClass.Value == config.TreeValue then
											wood = model;
											break;
										end
									end
								end
							end
						end
					end
				end
				if wood then break end
			end
			
			if wood == nil then
				HONG:Teleport(oldpos)
				return
			end
	       
			local woodPart;
			for _, v in next, wood:GetDescendants() do
				if v.Name == "WoodSection" then
					treeToCut = wood.CutEvent
					table.insert(woods, v)
					if v:FindFirstChild("ID") and v.ID.Value == 1 then woodPart = v end
				end
			end
			togggleInvisible(1)
			repeat
				HONG.WKSPC.Camera.CameraSubject = woodPart;
				HONG:Teleport(woodPart.CFrame + Vector3.new(0, 2.5, 3.5));
				task.wait()
				cutTree({
					Cutevent = treeToCut;
					Tool = getAxe(config.TreeValue);
					Height = 0.3;
				})
			until wood:FindFirstChild("RootCut")
			local Log
			for s, b in next, HONG.WKSPC.LogModels:GetDescendants() do
				if b:FindFirstChild"Owner" and b.Owner.Value == HONG.LP then Log = b end
			end
			for i = 1, 20 do
				newDragModel(Log, oldpos)
				task.wait(0.1)
			end
			task.wait()
			sum = sum + 1;
		end
		HONG:Teleport(oldpos)
		HONG.WKSPC.Camera.CameraSubject = HONG.LP.Character
		togggleInvisible(0)    
	end

	local function newDragModel(model, cframe)
	    if not model.PrimaryPart then model.PrimaryPart = model:FindFirstChildOfClass("Part") end
	    HONG.RES.Interaction.ClientIsDragging:FireServer(model)
	    model.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
	    model:PivotTo(cframe)
	end
	
	function togggleInvisible(num)
		for i, v in pairs(HONG.LP.Character:children()) do
			if v:IsA("Accessory") then
				for i, k in pairs(v:children()) do if k:IsA("Part") then k.Transparency = num end end
			end
			if v:IsA("Part") and v.Name ~= "HumanoidRootPart" then
				v.Transparency = num;
				if v.Name == "Head" and v:FindFirstChild"face" then v:FindFirstChild"face".Transparency = num end
			end
		end
	end
	
	getgenv()["带来树数量"] = 1;
	
	Page4:NewSlider("砍树数量", "砍树slider", 1, 1, 30, false, function(v)
	   getgenv()["带来树数量"] = v;
	end)
	
	local tree_list = {
		"电木 (Electric)", "胡桃木 (Walnut)", "星木 (Star)", "樱桃木 (Cherry)", "桦木 (Birch)", "冰霜木 (Frost)",
		"大理石木 (Marble)", "火山木 (Volcano)", "金沼泽 (GoldSwampy)", "普通金 (GenericGold)", "巨型橡木 (GreatOak)",
		"石头木 (Stone)", "辐射木 (Radioactive)", "洞穴木 (Cavern)", "岩浆木 (Magma)", "蓝木 (CaveCrawler)",
		"灵魂木 (Spirit)", "烈焰木 (Flame)", "星辰木 (Celestial)", "橡木 (Oak)", "绿沼泽 (GreenSwampy)", "幻影木 (LoneCave)",
		"沙子木 (Sand)", "松木 (Pine)", "玻璃木 (Glass)", "彩虹木 (Rainbow)", "普通木 (Generic)", "冰木 (Ice)"
	}
	local select_tree = "Generic";
	
	Page4:NewDropdown("选择树", "select_tree", tree_list, function(list)
		local m = string.match(list, "%((.+)%)")
		if m then select_tree = m else select_tree = list end
	end)
	
	Page4:NewButton("带来树", function()
		bringTree({
			TreeValue = select_tree;
			Quantity = tonumber(getgenv()["带来树数量"]);
		})
	end)
end)("纯伐木版")