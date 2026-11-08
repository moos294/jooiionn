local TabServer = Window:Tab({ Title = "服务器", Icon = "rbxassetid://10882439086" })
local targetPlaceId = tostring(game.PlaceId)

TabServer:Input({
    Title = "指定服务器 ID",
    Value = tostring(game.PlaceId),
    Callback = function(text) targetPlaceId = text end
})

local function getServerList(pid)
	local candidates = {}
	local url = ("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(pid)
	local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
	if ok and res and res.data then
		for _, s in ipairs(res.data) do
			if s.id ~= game.JobId and s.playing >= 2 and s.playing <= s.maxPlayers - 2 then
				table.insert(candidates, s.id)
			end
		end
	end
	return candidates
end

TabServer:Button({
    Title = "重进当前服务器 (防773终极版)",
    Desc = "强制重连防限制，私人服/公服通用",
    Callback = function()
        local TS = game:GetService("TeleportService")
        
        WindUI:Notify({ Title = "准备重连", Content = "正在解除网络锁，请等待 3 秒...", Duration = 3 })
        
        task.spawn(function()
            task.wait(3)
            
            local success = pcall(function()
                if game.PrivateServerId and game.PrivateServerId ~= "" then
                    local privateServerId = game.PrivateServerId
                    local privateServerAccessCode = ""
                    
                    if game.PrivateServerOwnerId == player.UserId then
                        privateServerAccessCode = game.JobId
                    end
                    
                    TS:TeleportToPrivateServer(game.PlaceId, privateServerId, {player}, privateServerAccessCode)
                else
                    local servers = getServerList(game.PlaceId)
                    if #servers > 0 then
                        local newJobId = servers[math.random(1, #servers)]
                        TS:TeleportToPlaceInstance(game.PlaceId, newJobId, player)
                    else
                        TS:Teleport(game.PlaceId, player)
                    end
                end
            end)
            
            if not success then
                WindUI:Notify({ Title = "重连被拦截", Content = "请退到游戏大厅重新加入，或尝试下方随机换服", Duration = 5 })
            end
        end)
    end
})

TabServer:Button({
    Title = "指定服务器换服",
    Desc = "需在上方填写 PlaceId，精准抓取新服",
    Callback = function()
        local TS = game:GetService("TeleportService")
        local id = tonumber(targetPlaceId)
        if id then
            local servers = getServerList(id)
            if #servers > 0 then
                local randomJobId = servers[math.random(1, #servers)]
                pcall(function() TS:TeleportToPlaceInstance(id, randomJobId, player) end)
            else
                pcall(function() TS:Teleport(id, player) end)
            end
        else
            WindUI:Notify({ Title = "错误", Content = "服务器 ID 格式不正确", Duration = 3 })
        end
    end
})

TabServer:Button({
    Title = "随机换服 (公服)",
    Desc = "使用官方API获取真实JobId，秒进",
    Callback = function()
        local TS = game:GetService("TeleportService")
        local servers = getServerList(game.PlaceId)
        if #servers > 0 then
            local randomJobId = servers[math.random(1, #servers)]
            pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, randomJobId, player) end)
        else
            pcall(function() TS:Teleport(game.PlaceId, player) end)
        end
    end
})