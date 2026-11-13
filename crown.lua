local player = game.Players.LocalPlayer

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/1794604968783_OrigamiUI_Lite.lua"))()
local WindUI = UI.WindUI
local TabHome = UI.Tabs.TabHome
local TabTree = UI.Tabs.TabTree
local TabBuy = UI.Tabs.TabBuy
local TabCraft = UI.Tabs.TabCraft
local TabTP = UI.Tabs.TabTP
local TabExtra = UI.Tabs.TabExtra

local function emptyCallback(msg)
    return function()
        print("[UI 测试] 点击了: " .. tostring(msg))
    end
end

TabHome:Paragraph({ Title = "【 属性修改 】" })
TabHome:Input({ Title = "移动速度", Value = "16", Callback = function() end })
TabHome:Input({ Title = "跳跃高度", Value = "50", Callback = function() end })
TabHome:Toggle({ Title = "无限跳跃", Value = false, Callback = function() end })
TabHome:Button({ Title = "开启飞行", Callback = emptyCallback("开启飞行") })

TabHome:Paragraph({ Title = "【 鸭鸭获取辅助 】" })
TabHome:Button({ Title = "恶魔鸭材料破解", Callback = emptyCallback("破解材料") })
TabHome:Button({ Title = "自动敲击天使序列", Callback = emptyCallback("天使序列") })

TabTree:Paragraph({ Title = "【 自动砍树设置 】" })
TabTree:Dropdown({ 
    Title = "选择树木种类", 
    Values = {"普通木", "幻影木", "电木", "胡桃木", "星木", "樱桃木", "桦木", "冰霜木", "大理石木", "火山木"}, 
    Value = "普通木", 
    Callback = function() end 
})
TabTree:Input({ Title = "砍伐数量", Value = "1", Callback = function() end })
TabTree:Button({ Title = "开始带来树", Callback = emptyCallback("开始砍树") })
TabTree:Button({ Title = "停止任务", Callback = emptyCallback("停止砍树") })

TabBuy:Paragraph({ Title = "【 购买普通鸭 】" })
TabBuy:Input({ Title = "目标获取数量", Value = "1", Callback = function() end })
TabBuy:Button({ Title = "开始自动购买普通鸭", Callback = emptyCallback("开始买鸭") })
TabBuy:Button({ Title = "停止购买", Callback = emptyCallback("停止买鸭") })
TabBuy:Button({ Title = "重置 NPC ID 缓存", Callback = emptyCallback("重置缓存") })

TabBuy:Paragraph({ Title = "【 购买恶魔鸭材料 】" })
TabBuy:Button({ Title = "一键购买材料拉回脚下", Callback = emptyCallback("买材料") })

TabCraft:Paragraph({ Title = "【 恶魔鸭全自动合成 】" })
TabCraft:Input({ Title = "合成次数", Value = "1", Callback = function() end })
TabCraft:Button({ Title = "开始全自动合成恶魔鸭", Callback = emptyCallback("合成恶魔鸭") })
TabCraft:Button({ Title = "停止自动合成", Callback = emptyCallback("停止合成") })

TabCraft:Paragraph({ Title = "【 祭坛传送与空投工具 】" })
TabCraft:Button({ Title = "传送到三叉戟祭坛", Callback = emptyCallback("传送三叉戟") })
TabCraft:Button({ Title = "获取【三叉戟空投工具】", Callback = emptyCallback("三叉戟工具") })
TabCraft:Button({ Title = "传送到永恒剑祭坛", Callback = emptyCallback("传送永恒剑") })
TabCraft:Button({ Title = "获取【永恒剑空投工具】", Callback = emptyCallback("永恒剑工具") })
TabCraft:Button({ Title = "传送到复仇剑祭坛", Callback = emptyCallback("传送复仇剑") })
TabCraft:Button({ Title = "获取【复仇剑空投工具】", Callback = emptyCallback("复仇剑工具") })
TabCraft:Button({ Title = "传送到星星鸭子祭坛", Callback = emptyCallback("传送星星鸭") })
TabCraft:Button({ Title = "获取【星星鸭子空投工具】", Callback = emptyCallback("星星鸭工具") })
TabCraft:Button({ Title = "传送到地狱火祭坛", Callback = emptyCallback("传送地狱火") })
TabCraft:Button({ Title = "获取【地狱火空投工具】", Callback = emptyCallback("地狱火工具") })
TabCraft:Button({ Title = "传送到天堂光环祭坛", Callback = emptyCallback("传送光环") })
TabCraft:Button({ Title = "获取【天堂光环空投工具】", Callback = emptyCallback("光环工具") })
TabCraft:Button({ Title = "传送到雪山天堂剑祭坛", Callback = emptyCallback("传送天堂剑") })
TabCraft:Button({ Title = "获取【天堂剑空投工具】", Callback = emptyCallback("天堂剑工具") })
TabCraft:Button({ Title = "传送到月牙祭坛", Callback = emptyCallback("传送月牙") })
TabCraft:Button({ Title = "获取【月牙空投工具】", Callback = emptyCallback("月牙工具") })
TabCraft:Button({ Title = "传送到月神剑祭坛", Callback = emptyCallback("传送月神剑") })
TabCraft:Button({ Title = "获取【月神剑空投工具】", Callback = emptyCallback("月神剑工具") })

TabTP:Paragraph({ Title = "【 树木传送 】" })
TabTP:Dropdown({ Title = "选择树木种类", Values = {"普通木", "幻影木", "电木"}, Value = "普通木", Callback = function() end })
TabTP:Button({ Title = "传送到树旁", Callback = emptyCallback("传送到树旁") })

TabTP:Paragraph({ Title = "【 自定义传送点 】" })
TabTP:Button({ Title = "保存当前位置为 传送点1", Callback = emptyCallback("保存点1") })
TabTP:Button({ Title = "传送到 传送点1", Callback = emptyCallback("传送点1") })
TabTP:Button({ Title = "保存当前位置为 传送点2", Callback = emptyCallback("保存点2") })
TabTP:Button({ Title = "传送到 传送点2", Callback = emptyCallback("传送点2") })
TabTP:Button({ Title = "保存当前位置为 传送点3", Callback = emptyCallback("保存点3") })
TabTP:Button({ Title = "传送到 传送点3", Callback = emptyCallback("传送点3") })

TabExtra:Paragraph({ Title = "【 环境与视野 】" })
TabExtra:Toggle({ Title = "夜视功能 (全图高光)", Value = false, Callback = function() end })

TabExtra:Paragraph({ Title = "【 物品传送 】" })
TabExtra:Dropdown({ Title = "选择物品拉回的目标点", Values = {"点位1", "点位2", "点位3"}, Value = "点位1", Callback = function() end })
TabExtra:Button({ Title = "设置 物品点位1", Callback = emptyCallback("设置物品1") })
TabExtra:Button({ Title = "设置 物品点位2", Callback = emptyCallback("设置物品2") })
TabExtra:Button({ Title = "设置 物品点位3", Callback = emptyCallback("设置物品3") })
TabExtra:Button({ Title = "获取点击传送工具", Callback = emptyCallback("点击传送") })
TabExtra:Button({ Title = "获取多选框选工具", Callback = emptyCallback("框选工具") })
TabExtra:Button({ Title = "一键传送所有选中物品", Callback = emptyCallback("传送选中") })
TabExtra:Button({ Title = "清除所有选中(蓝框)", Callback = emptyCallback("清除框") })

TabExtra:Paragraph({ Title = "【 卖木头与拉回鸭子 】" })
TabExtra:Button({ Title = "一键卖掉所有原木", Callback = emptyCallback("卖木头") })
TabExtra:Dropdown({ Title = "选择鸭子类型", Values = {"天堂鸭", "恶魔鸭", "普通鸭"}, Value = "天堂鸭", Callback = function() end })
TabExtra:Button({ Title = "拉回全图【自己的】鸭子", Callback = emptyCallback("拉回鸭子") })

TabExtra:Paragraph({ Title = "【 玩家追踪与反挂机 】" })
TabExtra:Dropdown({ Title = "选择目标玩家", Values = {"玩家1", "玩家2"}, Value = "玩家1", Callback = function() end })
TabExtra:Button({ Title = "刷新玩家列表", Callback = emptyCallback("刷新玩家") })
TabExtra:Button({ Title = "传送到目标玩家身边", Callback = emptyCallback("传玩家") })
TabExtra:Toggle({ Title = "循环锁定传送", Value = false, Callback = function() end })
TabExtra:Button({ Title = "开启反挂机防踢", Callback = emptyCallback("反挂机") })

TabExtra:Paragraph({ Title = "【 建筑整理工具 】" })
TabExtra:Button({ Title = "获取建筑整理工具", Callback = emptyCallback("整理工具") })

TabExtra:Paragraph({ Title = "【 系统清理 】" })
TabExtra:Button({ Title = "彻底关闭并清理缓存", Callback = emptyCallback("清理") })