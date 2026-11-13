local player = game.Players.LocalPlayer

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/moos294/ghghjj/refs/heads/main/UI.lua"))()
local Window = UI.Window
local WindUI = UI.WindUI

local TabHome = Window:Tab({ Title = "个人主页" })
local TabTree = Window:Tab({ Title = "带来树" })
local TabBuy = Window:Tab({ Title = "自动购买" })
local TabCraft = Window:Tab({ Title = "快速合成剑" })
local TabTP = Window:Tab({ Title = "传送" })
local TabExtra = Window:Tab({ Title = "其他功能" })

local function testClick(name)
    return function()
        print("[UI 测试] 你点击了: " .. name)
    end
end

TabHome:Paragraph({ Title = "【 属性修改 (纯测试) 】" })
TabHome:Input({ Title = "移动速度", Value = "16", Callback = function(v) print("输入框修改为:", v) end })
TabHome:Input({ Title = "跳跃高度", Value = "50", Callback = function(v) print("输入框修改为:", v) end })
TabHome:Toggle({ Title = "无限跳跃", Value = false, Callback = function(s) print("开关状态:", s) end })
TabHome:Button({ Title = "开启飞行", Callback = testClick("开启飞行") })

TabHome:Paragraph({ Title = "【 鸭鸭获取辅助 (纯测试) 】" })
TabHome:Button({ Title = "恶魔鸭材料破解", Callback = testClick("破解材料") })
TabHome:Button({ Title = "自动敲击天使序列", Callback = testClick("天使序列") })

TabTree:Paragraph({ Title = "【 自动砍树设置 (纯测试) 】" })
TabTree:Dropdown({ 
    Title = "选择树木种类", 
    Values = {"普通木", "幻影木", "电木", "胡桃木", "星木", "樱桃木", "桦木", "冰霜木", "大理石木", "火山木"}, 
    Value = "普通木", 
    Callback = function(opt) print("下拉框选择了:", opt) end 
})
TabTree:Input({ Title = "砍伐数量", Value = "1", Callback = function(v) print("输入框修改为:", v) end })
TabTree:Button({ Title = "开始带来树", Callback = testClick("开始砍树") })
TabTree:Button({ Title = "停止任务", Callback = testClick("停止砍树") })

TabBuy:Paragraph({ Title = "【 购买普通鸭 (纯测试) 】" })
TabBuy:Input({ Title = "目标获取数量", Value = "1", Callback = function(v) print("输入框修改为:", v) end })
TabBuy:Button({ Title = "开始自动购买普通鸭", Callback = testClick("开始买鸭") })
TabBuy:Button({ Title = "停止购买", Callback = testClick("停止买鸭") })

TabCraft:Paragraph({ Title = "【 祭坛传送与空投 (纯测试) 】" })
TabCraft:Button({ Title = "传送到三叉戟祭坛", Callback = testClick("传送三叉戟") })
TabCraft:Button({ Title = "获取【三叉戟空投工具】", Callback = testClick("获取三叉戟") })
TabCraft:Button({ Title = "传送到永恒剑祭坛", Callback = testClick("传送永恒剑") })
TabCraft:Button({ Title = "获取【永恒剑空投工具】", Callback = testClick("获取永恒剑") })
TabCraft:Button({ Title = "传送到复仇剑祭坛", Callback = testClick("传送复仇剑") })
TabCraft:Button({ Title = "获取【复仇剑空投工具】", Callback = testClick("获取复仇剑") })

TabTP:Paragraph({ Title = "【 树木传送 (纯测试) 】" })
TabTP:Dropdown({ Title = "选择树木种类", Values = {"普通木", "幻影木", "电木"}, Value = "普通木", Callback = function(opt) print("下拉框选择了:", opt) end })
TabTP:Button({ Title = "传送到树旁", Callback = testClick("传送到树旁") })

TabTP:Paragraph({ Title = "【 自定义传送点 (纯测试) 】" })
TabTP:Button({ Title = "保存当前位置为 传送点1", Callback = testClick("保存点1") })
TabTP:Button({ Title = "传送到 传送点1", Callback = testClick("传送点1") })
TabTP:Button({ Title = "保存当前位置为 传送点2", Callback = testClick("保存点2") })
TabTP:Button({ Title = "传送到 传送点2", Callback = testClick("传送点2") })

TabExtra:Paragraph({ Title = "【 物品传送 (纯测试) 】" })
TabExtra:Dropdown({ Title = "选择物品拉回的目标点", Values = {"点位1", "点位2", "点位3"}, Value = "点位1", Callback = function(opt) print("下拉框选择了:", opt) end })
TabExtra:Button({ Title = "设置 物品点位1", Callback = testClick("设置物品1") })
TabExtra:Button({ Title = "设置 物品点位2", Callback = testClick("设置物品2") })
TabExtra:Button({ Title = "获取点击传送工具", Callback = testClick("点击传送") })
TabExtra:Button({ Title = "获取多选框选工具", Callback = testClick("框选工具") })
TabExtra:Button({ Title = "一键传送所有选中物品", Callback = testClick("传送选中") })

TabExtra:Paragraph({ Title = "【 卖木头与拉回鸭子 (纯测试) 】" })
TabExtra:Button({ Title = "一键卖掉所有原木", Callback = testClick("卖木头") })
TabExtra:Dropdown({ Title = "选择鸭子类型", Values = {"天堂鸭", "恶魔鸭", "普通鸭"}, Value = "天堂鸭", Callback = function(opt) print("下拉框选择了:", opt) end })
TabExtra:Button({ Title = "拉回全图【自己的】鸭子", Callback = testClick("拉回鸭子") })

TabExtra:Paragraph({ Title = "【 玩家追踪与反挂机 (纯测试) 】" })
TabExtra:Dropdown({ Title = "选择目标玩家", Values = {"玩家1", "玩家2"}, Value = "玩家1", Callback = function(opt) print("下拉框选择了:", opt) end })
TabExtra:Button({ Title = "刷新玩家列表", Callback = testClick("刷新玩家") })
TabExtra:Button({ Title = "传送到目标玩家身边", Callback = testClick("传玩家") })
TabExtra:Toggle({ Title = "循环锁定传送", Value = false, Callback = function(s) print("开关状态:", s) end })
TabExtra:Button({ Title = "开启反挂机防踢", Callback = testClick("反挂机") })

TabExtra:Paragraph({ Title = "【 建筑整理工具 (纯测试) 】" })
TabExtra:Button({ Title = "获取建筑整理工具", Callback = testClick("整理工具") })