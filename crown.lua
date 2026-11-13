local player = game.Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

local function showMsg(title, text)
    StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 10})
end

local function CheckWhitelist()
    local url = "https://raw.githubusercontent.com/moos294/jooiionn/main/whitelist.txt"
    local success, content = pcall(function() return game:HttpGet(url) end)
    if not success or not content then return false end
    if string.find(content, player.Name) then return true end
    return false
end

showMsg("体检开始", "正在获取白名单...")
if not CheckWhitelist() then
    showMsg("❌ 报错", "你并没有白名单，或网络请求失败")
    return 
end
showMsg("✅ 验证成功", "欢迎尊贵的白名单使用此脚本")

showMsg("体检继续", "正在加载 UI.lua...")
local ok, UI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/UI.lua"))()
end)

if not ok or not UI then
    showMsg("❌ 报错", "UI 链接加载失败，请检查网络或链接")
    return
end

showMsg("✅ 成功", "UI 源码加载成功，正在生成界面...")

local ok2, err2 = pcall(function()
    for _, v in ipairs(UI.Gui.Panel:GetDescendants()) do
        if v:IsA("TextLabel") then
            if v.Text == "ORIGAMI" then v.Text = "封存木材 V0.1" end
            if v.Text == "BUILD TOOL" then v.Text = "Author: 封存" end
        end
    end

    local Window = UI.Window
    local WindUI = UI.WindUI
    
    local TabHome = Window:Tab({ Title = "个人主页" })
    local TabTree = Window:Tab({ Title = "带来树" })
    local TabBuy = Window:Tab({ Title = "自动购买" })
    local TabCraft = Window:Tab({ Title = "快速合成剑" })
    local TabTP = Window:Tab({ Title = "传送" })
    local TabExtra = Window:Tab({ Title = "其他功能" })

    TabHome:Paragraph({ Title = "【 属性修改 】" })
    TabHome:Input({ Title = "移动速度", Value = "16", Callback = function() end })
    TabHome:Input({ Title = "跳跃高度", Value = "50", Callback = function() end })
    TabHome:Toggle({ Title = "无限跳跃", Value = false, Callback = function() end })
    TabHome:Button({ Title = "开启飞行", Callback = function() end })
    
    TabHome:Paragraph({ Title = "【 鸭鸭获取辅助 】" })
    TabHome:Button({ Title = "恶魔鸭材料破解", Callback = function() end })
    TabHome:Button({ Title = "自动敲击天使序列", Callback = function() end })
    TabHome:Paragraph({ Title = "【 系统防踢 】" })
    TabHome:Button({ Title = "开启反挂机防踢", Callback = function() end })

    TabTree:Paragraph({ Title = "【 自动砍树设置 】" })
    TabTree:Dropdown({ Title = "选择树木种类", Values = {"普通树", "幻影木", "电木"}, Value = "普通树", Callback = function() end })
    TabTree:Input({ Title = "砍伐数量", Value = "1", Callback = function() end })
    TabTree:Button({ Title = "开始带来树", Callback = function() end })
    TabTree:Button({ Title = "停止任务", Callback = function() end })

    TabBuy:Paragraph({ Title = "【 购买普通鸭 】" })
    TabBuy:Input({ Title = "目标获取数量", Value = "1", Callback = function() end })
    TabBuy:Button({ Title = "开始自动购买普通鸭", Callback = function() end })
    TabBuy:Button({ Title = "停止购买", Callback = function() end })
    TabBuy:Button({ Title = "重置 NPC ID 缓存", Callback = function() end })
    TabBuy:Paragraph({ Title = "【 购买恶魔鸭材料 】" })
    TabBuy:Button({ Title = "一键购买材料拉回脚下", Callback = function() end })

    TabCraft:Paragraph({ Title = "【 恶魔鸭全自动合成 】" })
    TabCraft:Input({ Title = "合成次数", Value = "1", Callback = function() end })
    TabCraft:Button({ Title = "开始全自动合成恶魔鸭", Callback = function() end })
    TabCraft:Button({ Title = "停止自动合成", Callback = function() end })

    TabCraft:Paragraph({ Title = "【 三叉戟合成 】" })
    TabCraft:Button({ Title = "传送到三叉戟祭坛", Callback = function() end })
    TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂鸭子 (左)", "星星鸭子 (中)", "恶魔鸭子 (右)"}, Value = "天堂鸭子 (左)", Callback = function() end })
    TabCraft:Button({ Title = "获取【三叉戟空投工具】", Callback = function() end })

    TabCraft:Paragraph({ Title = "【 永恒剑合成 】" })
    TabCraft:Button({ Title = "传送到永恒剑祭坛", Callback = function() end })
    TabCraft:Dropdown({ Title = "选择材料位置", Values = {"三叉戟 (左)", "复仇剑 (中)", "恶魔鸭子 (右)"}, Value = "三叉戟 (左)", Callback = function() end })
    TabCraft:Button({ Title = "获取【永恒剑空投工具】", Callback = function() end })

    TabCraft:Paragraph({ Title = "【 复仇剑合成 】" })
    TabCraft:Button({ Title = "传送到复仇剑祭坛", Callback = function() end })
    TabCraft:Dropdown({ Title = "选择材料位置", Values = {"恶魔鸭子", "天堂鸭子"}, Value = "恶魔鸭子", Callback = function() end })
    TabCraft:Button({ Title = "获取【复仇剑空投工具】", Callback = function() end })

    TabCraft:Paragraph({ Title = "【 星星鸭子合成 】" })
    TabCraft:Button({ Title = "传送到星星鸭子祭坛", Callback = function() end })
    TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂鸭", "普通鸭", "恶魔鸭"}, Value = "天堂鸭", Callback = function() end })
    TabCraft:Button({ Title = "获取【星星鸭子空投工具】", Callback = function() end })

    TabCraft:Paragraph({ Title = "【 地狱火合成 】" })
    TabCraft:Button({ Title = "传送到地狱火祭坛", Callback = function() end })
    TabCraft:Dropdown({ Title = "选择材料位置", Values = {"三叉戟", "恶魔鸭"}, Value = "三叉戟", Callback = function() end })
    TabCraft:Button({ Title = "获取【地狱火空投工具】", Callback = function() end })

    TabCraft:Paragraph({ Title = "【 天堂光环合成 】" })
    TabCraft:Button({ Title = "传送到天堂光环祭坛", Callback = function() end })
    TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂鸭", "永恒剑"}, Value = "天堂鸭", Callback = function() end })
    TabCraft:Button({ Title = "获取【天堂光环空投工具】", Callback = function() end })

    TabCraft:Paragraph({ Title = "【 天堂剑合成 】" })
    TabCraft:Button({ Title = "传送到雪山天堂剑祭坛", Callback = function() end })
    TabCraft:Button({ Title = "获取【天堂剑空投工具】", Callback = function() end })

    TabCraft:Paragraph({ Title = "【 月牙合成 】" })
    TabCraft:Button({ Title = "传送到月牙祭坛", Callback = function() end })
    TabCraft:Dropdown({ Title = "选择材料位置", Values = {"天堂剑", "地狱火"}, Value = "天堂剑", Callback = function() end })
    TabCraft:Button({ Title = "获取【月牙空投工具】", Callback = function() end })

    TabCraft:Paragraph({ Title = "【 月神剑合成 】" })
    TabCraft:Button({ Title = "传送到月神剑祭坛", Callback = function() end })
    TabCraft:Button({ Title = "获取【月神剑空投工具】", Callback = function() end })

    TabTP:Paragraph({ Title = "【 树木传送 】" })
    TabTP:Dropdown({ Title = "选择树木种类", Values = {"普通木", "幻影木", "电木"}, Value = "普通木", Callback = function() end })
    TabTP:Button({ Title = "传送到树旁", Callback = function() end })
    TabTP:Paragraph({ Title = "【 自定义传送点 】" })
    TabTP:Button({ Title = "保存当前位置为 传送点1", Callback = function() end })
    TabTP:Button({ Title = "传送到 传送点1", Callback = function() end })
    TabTP:Button({ Title = "保存当前位置为 传送点2", Callback = function() end })
    TabTP:Button({ Title = "传送到 传送点2", Callback = function() end })
    TabTP:Button({ Title = "保存当前位置为 传送点3", Callback = function() end })
    TabTP:Button({ Title = "传送到 传送点3", Callback = function() end })

    TabExtra:Paragraph({ Title = "【 物品传送 】" })
    TabExtra:Dropdown({ Title = "选择物品拉回的目标点", Values = {"拉回点位1", "拉回点位2", "拉回点位3"}, Value = "拉回点位1", Callback = function() end })
    TabExtra:Button({ Title = "设置 物品点位1", Callback = function() end })
    TabExtra:Button({ Title = "设置 物品点位2", Callback = function() end })
    TabExtra:Button({ Title = "设置 物品点位3", Callback = function() end })
    TabExtra:Button({ Title = "获取点击传送工具", Callback = function() end })
    TabExtra:Button({ Title = "获取多选框选工具", Callback = function() end })
    TabExtra:Button({ Title = "一键传送所有选中物品", Callback = function() end })
    TabExtra:Button({ Title = "清除所有选中(蓝框)", Callback = function() end })

    TabExtra:Paragraph({ Title = "【 卖木头与拉回鸭子 】" })
    TabExtra:Button({ Title = "一键卖掉所有原木", Callback = function() end })
    TabExtra:Dropdown({ Title = "选择鸭子", Values = {"天堂鸭", "恶魔鸭", "月亮鸭", "普通鸭", "礼物鸭"}, Value = "天堂鸭", Callback = function() end })
    TabExtra:Button({ Title = "拉回全图【自己的】鸭子", Callback = function() end })

    TabExtra:Paragraph({ Title = "【 玩家追踪与反挂机 】" })
    TabExtra:Dropdown({ Title = "选择目标玩家", Values = {"玩家1", "玩家2"}, Value = "玩家1", Callback = function() end })
    TabExtra:Button({ Title = "刷新玩家列表", Callback = function() end })
    TabExtra:Button({ Title = "传送到目标玩家身边", Callback = function() end })
    TabExtra:Toggle({ Title = "循环锁定传送", Value = false, Callback = function() end })

    TabExtra:Paragraph({ Title = "【 建筑整理工具 】" })
    TabExtra:Button({ Title = "获取建筑整理工具", Callback = function() end })
    TabExtra:Paragraph({ Title = "【 系统清理 】" })
    TabExtra:Button({ Title = "彻底关闭并清理缓存", Callback = function() end })
end)

if not ok2 then
    showMsg("❌ 报错", "UI生成中断: " .. tostring(err2))
else
    showMsg("🎉 完美", "纯UI骨架加载成功，没有语法错误！")
end