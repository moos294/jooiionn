(function(define)
	repeat task.wait() until game:IsLoaded();
	
	local _CONFIGS = { ["UI_NAME"] = define };
	
	local HONG = { GS = function(...) return game.GetService(game, ...); end; }
	HONG.RS = HONG.GS"RunService"; HONG.RES = HONG.GS"ReplicatedStorage"; HONG.LP = HONG.GS"Players".LocalPlayer; HONG.WKSPC = HONG.GS"Workspace"; HONG.COREGUI = HONG.GS "CoreGui";
	local Mouse = HONG.LP:GetMouse()
	
	function HONG:DragModel(...)
		local Args = { ... };
		assert(Args[1]:IsA("Model") == true, "参数1必须是模型!");
		if _CONFIGS["传送模式"] == 1 then
			pcall(function() self.RES.Interaction.ClientIsDragging:FireServer(Args[1]) end);
			Args[1]:PivotTo(Args[2]);
		elseif _CONFIGS["传送模式"] == 2 then
			pcall(function() self.RES.Interaction.ClientIsDragging:FireServer(Args[1]) end);
			if not Args[1].PrimaryPart then Args[1].PrimaryPart = Args[1]:FindFirstChildOfClass("Part") end
			Args[1]:SetPrimaryPartCFrame(Args[2])
		end
	end
	
	function HONG:Teleport(...)
		local Args = { ... };
		if self.LP.Character and self.LP.Character:FindFirstChild("Humanoid") and self.LP.Character.Humanoid.SeatPart then
			for i = 1, 15 do self:DragModel(self.LP.Character.Humanoid.SeatPart.Parent, Args[1]); task.wait() end
			return;
		end
		for i = 1, 3 do self:DragModel(self.LP.Character, Args[1]); task.wait(); end
	end

	local b = setmetatable({}, { __index = function(self, c) return game.GetService(game, c) end, __call = function(self, c) return game:GetService(c) end })
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
		dv:Tween({ Transparency = 1 }, dC[2].Glow):Play(); dv:Tween({ Transparency = 0 }, dB[2].Glow):Play()
		dC[1].Visible = false; dB[1].Visible = true
	end
	
	local dD, Open, dE, dF, dG, dH = dq("ScreenGui"), dq("TextButton"), dq("Frame"), dq("UICorner"), dq("TextLabel"), dq("UICorner")
	local dI, dJ, dK, dL, dM, dN, dO = dq("Frame"), dq("UICorner"), dq("ScrollingFrame"), dq("UIListLayout"), dq("UIPadding"), dq("Frame"), dq("UICorner")
	
	dD.Name = _CONFIGS.UI_NAME; dD.Parent = b.CoreGui
	dE.Name = "Main"; dE.Parent = dD; dE.BackgroundColor3 = dp(52, 62, 72); dE.Size = dn(0, 448, 0, 280); dE.Position = dn(0.5, 0, 0.5, 0); dE.AnchorPoint = Vector2.new(0.5, 0.5); dE.Active = true; dE.Draggable = true
	dF.CornerRadius = dm(0, 6); dF.Parent = dE
	dG.Parent = dE; dG.BackgroundColor3 = dp(58, 69, 80); dG.Size = dn(0, 436, 0, 24); dG.Position = dn(0, 6, 0, 6); dG.Text = "  " .. _CONFIGS.UI_NAME; dG.TextColor3 = dp(255, 255, 255); dG.TextXAlignment = Enum.TextXAlignment.Left; dG.Font = Enum.Font.GothamBold
	dH.CornerRadius = dm(0, 6); dH.Parent = dG
	
	Open.Parent = dD; Open.BackgroundColor3 = dE.BackgroundColor3; Open.Position = UDim2.new(0.839, 0, -0.012, 0); Open.Size = UDim2.new(0, 55, 0, 25); Open.Text = "隐藏"; Open.TextColor3 = dp(255, 255, 255); Open.Active = true; Open.Draggable = true
	local TOGGLE = true; Open.MouseButton1Down:connect(function() TOGGLE = not TOGGLE; dE.Visible = TOGGLE; Open.Text = (TOGGLE and "隐藏" or "打开") end)
	
	dI.Name = "Sidebar"; dI.Parent = dE; dI.BackgroundColor3 = dp(58, 69, 80); dI.Size = dn(0, 106, 0, 238); dI.Position = dn(0, 6, 0, 36)
	dJ.CornerRadius = dm(0, 6); dJ.Parent = dI
	dK.Parent = dI; dK.BackgroundTransparency = 1; dK.Size = dn(0, 106, 0, 238); dK.ScrollBarThickness = 0
	dL.Parent = dK; dL.HorizontalAlignment = Enum.HorizontalAlignment.Center; dL.Padding = dm(0, 5)
	dM.Parent = dK; dM.PaddingTop = dm(0, 6)
	
	dN.Parent = dE; dN.BackgroundColor3 = dp(58, 69, 80); dN.Size = dn(0, 324, 0, 238); dN.Position = dn(0, 118, 0, 36)
	dO.CornerRadius = dm(0, 6); dO.Parent = dN
	dL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() dK.CanvasSize = dn(0, 0, 0, dL.AbsoluteContentSize.Y + 12) end)
	
	function library:CreateTab(dZ)
		local d_, e0, e1, e2, e3, e4, e5, e6 = dq("TextButton"), dq("UICorner"), dq("Frame"), dq("UICorner"), dq("UIGradient"), dq("ScrollingFrame"), dq("UIPadding"), dq("UIListLayout")
		d_.Parent = dK; d_.BackgroundColor3 = dp(52, 62, 72); d_.Size = dn(0, 94, 0, 28); d_.Text = dZ; d_.TextColor3 = dp(255, 255, 255); d_.Font = Enum.Font.GothamSemibold
		e0.CornerRadius = dm(0, 6); e0.Parent = d_
		e1.Parent = d_; e1.BackgroundColor3 = dp(255, 255, 255); e1.Size = dn(0, 94, 0, 2); e1.Position = dn(0, 0, 0.928, 0); e1.Transparency = 1
		e2.CornerRadius = dm(0, 6); e2.Parent = e1
		e3.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, dp(52, 62, 72)), ColorSequenceKeypoint.new(0.5, dp(255, 255, 255)), ColorSequenceKeypoint.new(1, dp(52, 62, 72)) }; e3.Parent = e1
		e4.Parent = dN; e4.BackgroundTransparency = 1; e4.Size = dn(0, 324, 0, 238); e4.ScrollBarThickness = 0; e4.Visible = false
		if not library.currentTab then library.currentTab = { e4, d_ }; e1.Transparency = 0; e4.Visible = true end
		e5.Parent = e4; e5.PaddingTop = dm(0, 6)
		e6.Parent = e4; e6.HorizontalAlignment = Enum.HorizontalAlignment.Center; e6.Padding = dm(0, 5)
		e6:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() e4.CanvasSize = dn(0, 0, 0, e6.AbsoluteContentSize.Y + 12) end)
		d_.MouseButton1Click:Connect(function() dv:SwitchTab({ e4, d_ }) end)
		
		local e7 = {}
		function e7:NewButton(e9, ea)
			local eb, ec = dq("TextButton"), dq("UICorner")
			eb.Parent = e4; eb.BackgroundColor3 = dp(52, 62, 72); eb.Size = dn(0, 312, 0, 28); eb.Text = "  " .. e9; eb.TextColor3 = dp(255, 255, 255); eb.TextXAlignment = Enum.TextXAlignment.Left; eb.Font = Enum.Font.GothamSemibold
			ec.CornerRadius = dm(0, 6); ec.Parent = eb
			eb.MouseButton1Click:Connect(ea or dr)
		end
		function e7:NewSlider(e9, du, em, ey, ez, ea)
			local eB, eC, eD, eE, eF, eG, eH, eI = dq("TextButton"), dq("UICorner"), dq("Frame"), dq("UICorner"), dq("Frame"), dq("UICorner"), dq("TextBox"), dq("UICorner")
			library.flags[du] = { State = em, SetValue = function(self, be)
				local eL = be and (be - ey) / (ez - ey) or math.clamp((ds.X - eD.AbsolutePosition.X) / eD.AbsoluteSize.X, 0, 1)
				be = be or math.floor(ey + (ez - ey) * eL); self.State = be; eH.Text = tostring(be); eF.Size = dn(eL, 0, 1, 0); (ea or dr)(be)
			end }
			eB.Parent = e4; eB.BackgroundColor3 = dp(52, 62, 72); eB.Size = dn(0, 312, 0, 28); eB.Text = "  " .. e9; eB.TextColor3 = dp(255, 255, 255); eB.TextXAlignment = Enum.TextXAlignment.Left
			eC.CornerRadius = dm(0, 6); eC.Parent = eB
			eD.Parent = eB; eD.BackgroundColor3 = dp(58, 69, 80); eD.Size = dn(0, 108, 0, 6); eD.Position = dn(0.44, 0, 0.39, 0)
			eE.CornerRadius = dm(0, 2); eE.Parent = eD
			eF.Parent = eD; eF.BackgroundColor3 = dp(255, 255, 255); eF.Size = dn(0, 0, 1, 0)
			eG.CornerRadius = dm(0, 2); eG.Parent = eF
			eH.Parent = eB; eH.BackgroundColor3 = dp(58, 69, 80); eH.Size = dn(0, 32, 0, 18); eH.Position = dn(0.88, 0, 0.18, 0); eH.Text = em; eH.TextColor3 = dp(255, 255, 255)
			eI.CornerRadius = dm(0, 4); eI.Parent = eH
			local dS = false
			eD.InputBegan:Connect(function(dX) if dX.UserInputType == Enum.UserInputType.MouseButton1 then library.flags[du]:SetValue(); dS = true end end)
			b.UserInputService.InputEnded:Connect(function(dX) if dX.UserInputType == Enum.UserInputType.MouseButton1 then dS = false end end)
			b.UserInputService.InputChanged:Connect(function(dX) if dS then library.flags[du]:SetValue() end end)
			library.flags[du]:SetValue(em)
		end
		function e7:NewDropdown(e9, du, eP, ea)
			local eQ, eR, eS, eT, eU, eV, eW, eX = dq("TextButton"), dq("UICorner"), dq("TextBox"), dq("TextButton"), dq("TextButton"), dq("UICorner"), dq("UIListLayout"), dq("UIPadding")
			library.flags[du] = { State = eP[1] }
			eQ.Parent = e4; eQ.BackgroundColor3 = dp(52, 62, 72); eQ.Size = dn(0, 312, 0, 28); eQ.Text = ""
			eR.CornerRadius = dm(0, 6); eR.Parent = eQ
			eS.Parent = eQ; eS.BackgroundTransparency = 1; eS.Size = dn(0, 192, 0, 28); eS.Position = dn(0.02, 0, 0, 0); eS.PlaceholderText = e9; eS.TextColor3 = dp(255, 255, 255); eS.TextXAlignment = Enum.TextXAlignment.Left
			eT.Parent = eQ; eT.BackgroundTransparency = 1; eT.Size = dn(0, 18, 0, 18); eT.Position = dn(0.9, 0, 0.18, 0); eT.Text = "+"; eT.TextColor3 = dp(255, 255, 255); eT.TextSize = 22
			eU.Parent = e4; eU.BackgroundColor3 = dp(52, 62, 72); eU.Size = dn(0, 312, 0, 0); eU.Text = ""; eU.Visible = false; eU.ClipsDescendants = true
			eV.CornerRadius = dm(0, 6); eV.Parent = eU
			eW.Parent = eU; eW.HorizontalAlignment = Enum.HorizontalAlignment.Center; eW.Padding = dm(0, 6)
			eX.Parent = eU; eX.PaddingTop = dm(0, 6)
			local eY = false
			local function f0()
				eY = not eY; eU.Visible = eY; eT.Text = eY and "-" or "+"
				if eY then
					for _, child in pairs(eU:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
					for _, opt in pairs(eP) do
						local o = dq("TextButton", eU); o.Size = dn(0, 300, 0, 28); o.BackgroundColor3 = dp(58, 69, 80); o.Text = opt; o.TextColor3 = dp(255, 255, 255)
						dq("UICorner", o).CornerRadius = dm(0, 6)
						o.MouseButton1Click:Connect(function() eS.PlaceholderText = opt; library.flags[du].State = opt; f0(); (ea or dr)(opt) end)
					end
					eU.Size = dn(0, 312, 0, eW.AbsoluteContentSize.Y + 12)
				else eU.Size = dn(0, 312, 0, 0) end
			end
			eT.MouseButton1Click:Connect(f0)
		end
		return e7
	end

	local Page1 = library:CreateTab("设置");
	local Page4 = library:CreateTab("木材菜单");
	
	Page1:NewButton("关闭脚本", function()
		for _, v in next, b.CoreGui:GetDescendants() do if v.Name == _CONFIGS.UI_NAME then v:Destroy() end end
	end)

	local function getDamage(tool)
		local modTool = require(HONG.RES.AxeClasses[("AxeClass_%s"):format(tool.ToolName.Value)])
		return modTool.new().Damage
	end
	
	local function cutTree(config)
		local damage = 0
		if config.Tool.ToolName.Value == "EndTimesAxe" and config.Cutevent.Parent.TreeClass.Value == "LoneCave" then damage = 10000000
		else damage = getDamage(config.Tool) end
		
		HONG.RES.Interaction.RemoteProxy:FireServer(config.Cutevent, {
			["tool"] = config.Tool; ["faceVector"] = Vector3.new(1,0,0); ["height"] = 0.3;
			["sectionId"] = 1; ["hitPoints"] = tonumber(damage); ["cooldown"] = 0.01; ["cuttingClass"] = "Axe";
		})
	end
	
	local function getAxe()
		for _, v in next, HONG.LP.Character:GetChildren() do if v:IsA("Tool") and v:FindFirstChild("CuttingTool") then return v end end
		for _, v in next, HONG.LP.Backpack:GetChildren() do if v:IsA("Tool") and v:FindFirstChild("CuttingTool") then return v end end
		return nil
	end

	local function newDragModel(model, cframe)
		if not model.PrimaryPart then model.PrimaryPart = model:FindFirstChildOfClass("Part") end
		HONG.RES.Interaction.ClientIsDragging:FireServer(model); model:PivotTo(cframe)
	end
	
	function togggleInvisible(num)
		for i, v in pairs(HONG.LP.Character:children()) do
			if v:IsA("Accessory") then for i, k in pairs(v:children()) do if k:IsA("Part") then k.Transparency = num end end end
			if v:IsA("Part") and v.Name ~= "HumanoidRootPart" then
				v.Transparency = num;
				if v.Name == "Head" and v:FindFirstChild"face" then v:FindFirstChild"face".Transparency = num end
			end
		end
	end

	getgenv()["数量"] = 1
	Page4:NewSlider("砍树数量", "qty", 1, 1, 30, function(v) getgenv()["数量"] = v end)

	local tree_list = {
		"电木 (Electric)", "胡桃木 (Walnut)", "星木 (Star)", "樱桃木 (Cherry)", "桦木 (Birch)", "冰霜木 (Frost)",
		"大理石木 (Marble)", "火山木 (Volcano)", "金沼泽 (GoldSwampy)", "普通金 (GenericGold)", "巨型橡木 (GreatOak)",
		"石头木 (Stone)", "辐射木 (Radioactive)", "洞穴木 (Cavern)", "岩浆木 (Magma)", "蓝木 (CaveCrawler)",
		"灵魂木 (Spirit)", "烈焰木 (Flame)", "星辰木 (Celestial)", "橡木 (Oak)", "绿沼泽 (GreenSwampy)", "幻影木 (LoneCave)",
		"沙子木 (Sand)", "松木 (Pine)", "玻璃木 (Glass)", "彩虹木 (Rainbow)", "普通木 (Generic)", "冰木 (Ice)"
	}
	local select_tree = "Generic"
	
	Page4:NewDropdown("选择树", "tree", tree_list, function(list)
		local m = string.match(list, "%((.+)%)")
		if m then select_tree = m else select_tree = list end
	end)

	Page4:NewButton("带来树", function()
		local oldpos = HONG.LP.Character.HumanoidRootPart.CFrame
		local axe = getAxe()
		if not axe then return end
		local qty = tonumber(getgenv()["数量"])
		local count = 0
		
		while count < qty do
			local wood = nil
			for _, v in next, HONG.WKSPC:GetDescendants() do
				if v.Name == "TreeRegion" then
					for _, m in next, v:children() do
						if m:FindFirstChild("CutEvent") and m:FindFirstChild("WoodSection") and not m:FindFirstChild("RootCut") then
							if m.Owner.Value == nil or m.Owner.Value == HONG.LP then
								if m.TreeClass.Value == select_tree then wood = m; break; end
							end
						end
					end
				end
				if wood then break end
			end
			if wood then
				togggleInvisible(1)
				local woodPart = wood:FindFirstChild("WoodSection")
				repeat
					HONG:Teleport(woodPart.CFrame + Vector3.new(0, 2.5, 3.5))
					task.wait()
					cutTree({Cutevent = wood.CutEvent; Tool = axe;})
				until wood:FindFirstChild("RootCut")
				
				local Log
				for _, b2 in next, HONG.WKSPC.LogModels:GetDescendants() do
					if b2:FindFirstChild"Owner" and b2.Owner.Value == HONG.LP then Log = b2 end
				end
				for i = 1, 20 do newDragModel(Log, oldpos); task.wait(0.1) end
				count = count + 1
			else
				break
			end
		end
		HONG:Teleport(oldpos)
		togggleInvisible(0)
	end)
end)("木材 纯净砍树版")