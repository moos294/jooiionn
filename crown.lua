local P=game:GetService("Players")
local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local L=game:GetService("Lighting")
local plr=P.LocalPlayer
local pg=plr:WaitForChild("PlayerGui")
local function clearOld()
for _,v in ipairs(pg:GetChildren()) do if v.Name=="GojoV14" or v.Name=="GojoSkillUI" or v.Name=="GojoSkillUI_V2" or v.Name=="GojoSkillDemo" then v:Destroy() end end
local f=workspace:FindFirstChild("GojoSkillEffects")
if f then f:Destroy() end
end
clearOld()
local fx=Instance.new("Folder",workspace)
fx.Name="GojoSkillEffects"
local gui=Instance.new("ScreenGui")
gui.Name="GojoV14"
gui.ResetOnSpawn=false
gui.DisplayOrder=50
gui.Parent=pg
local char,hum,root
local busy=false
local token=0
local cons={}
local original={}
local savedLight={}
local function bind()
char=plr.Character or plr.CharacterAdded:Wait()
hum=char:WaitForChild("Humanoid")
root=char:WaitForChild("HumanoidRootPart")
original={}
for _,v in ipairs(char:GetDescendants()) do if v:IsA("Motor6D") then original[v]=v.Transform end end
end
bind()
plr.CharacterAdded:Connect(function() task.wait(.5) bind() end)
local function alive()
return char and char.Parent and hum and hum.Health>0 and root and root.Parent
end
local function valid(t)
return token==t and alive()
end
local function addConn(c)
table.insert(cons,c)
return c
end
local function tw(o,d,p,s)
if not o or not o.Parent then return end
local x=TS:Create(o,TweenInfo.new(d,s or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p)
x:Play()
return x
end
local function mk(parent,name,size,cf,color,mat,trans,shape)
local p=Instance.new("Part")
p.Name=name
p.Size=size
p.CFrame=cf
p.Color=color
p.Material=mat or Enum.Material.Neon
p.Transparency=trans or 0
p.Shape=shape or Enum.PartType.Block
p.Anchored=true
p.CanCollide=false
p.CanTouch=false
p.CanQuery=false
p.CastShadow=false
p.Parent=parent
return p
end
local function ball(pos,size,color,name)
local p=mk(fx,name,Vector3.one*size,CFrame.new(pos),color,Enum.Material.Neon,.04,Enum.PartType.Ball)
local l=Instance.new("PointLight",p)
l.Color=color
l.Brightness=3
l.Range=size*7
local a=Instance.new("Attachment",p)
local e=Instance.new("ParticleEmitter",a)
e.Color=ColorSequence.new(color)
e.LightEmission=1
e.Rate=35
e.Lifetime=NumberRange.new(.3,.8)
e.Speed=NumberRange.new(1,6)
e.SpreadAngle=Vector2.new(180,180)
e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,size*.09),NumberSequenceKeypoint.new(.5,size*.05),NumberSequenceKeypoint.new(1,0)})
return p
end
local function ring(pos,r,color,d)
local p=mk(fx,"EnergyRing",Vector3.new(.15,r*2,r*2),CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2),color,Enum.Material.Neon,.1,Enum.PartType.Cylinder)
tw(p,d,{Size=Vector3.new(.05,r*3,r*3),Transparency=1})
task.delay(d+.1,function() if p.Parent then p:Destroy() end end)
return p
end
local function burst(pos,color,n)
local p=mk(fx,"Burst",Vector3.one*.1,CFrame.new(pos),color,Enum.Material.Neon,1)
local a=Instance.new("Attachment",p)
local e=Instance.new("ParticleEmitter",a)
e.Color=ColorSequence.new(color)
e.LightEmission=1
e.Speed=NumberRange.new(8,32)
e.Lifetime=NumberRange.new(.3,1)
e.SpreadAngle=Vector2.new(180,180)
e.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.8),NumberSequenceKeypoint.new(1,0)})
e:Emit(n)
task.delay(1.5,function() if p.Parent then p:Destroy() end end)
end
local function beam(a,b,color,w)
local p=mk(fx,"EnergyBeam",Vector3.new(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,Enum.Material.Neon,.05)
tw(p,.5,{Size=Vector3.new(.03,.03,(b-a).Magnitude),Transparency=1})
task.delay(.6,function() if p.Parent then p:Destroy() end end)
return p
end
local function motor(n)
for _,v in ipairs(char:GetDescendants()) do if v:IsA("Motor6D") and v.Name==n then return v end end
end
local function pose(t,d,target)
local names={"Root","Waist","Neck","RightShoulder","LeftShoulder","RightElbow","LeftElbow"}
local ms={}
for _,n in ipairs(names) do local m=motor(n) if m then ms[n]=m end end
local elapsed=0
local c
c=RS.Heartbeat:Connect(function(dt)
if not valid(t) then c:Disconnect() return end
elapsed+=dt
local a=math.clamp(elapsed/d,0,1)
a=a*a*(3-2*a)
for n,m in pairs(ms) do
local base=original[m] or CFrame.identity
m.Transform=base:Lerp(base*(target[n] or CFrame.identity),a)
end
if a>=1 then c:Disconnect() end
end)
addConn(c)
end
local function resetPose()
for m,v in pairs(original) do if m.Parent then m.Transform=v end end
end
local function finish(t)
if token~=t then return end
busy=false
resetPose()
end
local function begin()
if busy or not alive() then return end
busy=true
token+=1
return token
end
local function blue()
local t=begin() if not t then return end
pose(t,.4,{RightShoulder=CFrame.Angles(-1.7,0,.4),LeftShoulder=CFrame.Angles(-.7,0,-.3),Neck=CFrame.Angles(-.1,0,0)})
local pos=root.Position+root.CFrame.LookVector*5+Vector3.new(0,2,0)
local b=ball(pos,1.5,Color3.fromRGB(50,165,255),"LapseBlue")
local core=ball(pos,.6,Color3.fromRGB(210,245,255),"BlueCore")
for i=1,4 do ring(pos,1+i*.5,Color3.fromRGB(55,180,255),1.4) end
for i=1,14 do
if not valid(t) then break end
local p=root.Position+root.CFrame.LookVector*(5+i*1.8)+Vector3.new(0,2,0)
tw(b,.12,{Position=p})
tw(core,.12,{Position=p})
ring(p,1.5,Color3.fromRGB(65,180,255),.4)
task.wait(.12)
end
if valid(t) then burst(b.Position,Color3.fromRGB(60,180,255),50) end
b:Destroy() core:Destroy()
finish(t)
end
local function red()
local t=begin() if not t then return end
pose(t,.4,{RightShoulder=CFrame.Angles(-1.5,0,.4),LeftShoulder=CFrame.Angles(-1.5,0,-.4),Neck=CFrame.Angles(-.1,0,0)})
local pos=root.Position+root.CFrame.LookVector*4+Vector3.new(0,2,0)
local b=ball(pos,1.4,Color3.fromRGB(255,45,65),"ReversalRed")
for i=1,5 do ring(pos,1+i*.55,Color3.fromRGB(255,40,65),.7) task.wait(.12) end
for i=1,3 do
if not valid(t) then break end
local target=root.Position+root.CFrame.LookVector*(12+i*10)+Vector3.new(0,2,0)
beam(b.Position,target,Color3.fromRGB(255,45,65),1.5)
burst(target,Color3.fromRGB(255,40,65),30)
ring(target,2,Color3.fromRGB(255,40,65),.5)
task.wait(.1)
end
b:Destroy()
finish(t)
end
local function purple()
local t=begin() if not t then return end
pose(t,.5,{RightShoulder=CFrame.Angles(-1.6,0,.65),LeftShoulder=CFrame.Angles(-1.6,0,-.65),Neck=CFrame.Angles(-.15,0,0)})
local base=root.Position+root.CFrame.LookVector*7+Vector3.new(0,3,0)
local blueOrb=ball(base+Vector3.new(-2,0,0),1.5,Color3.fromRGB(40,150,255),"PurpleBlue")
local redOrb=ball(base+Vector3.new(2,0,0),1.5,Color3.fromRGB(255,35,65),"PurpleRed")
for i=1,12 do
if not valid(t) then break end
local a=i/12
blueOrb.Position=base+Vector3.new(-2+2*a,math.sin(a*math.pi)*.6,0)
redOrb.Position=base+Vector3.new(2-2*a,-math.sin(a*math.pi)*.6,0)
ring(base,2+a,Color3.fromRGB(125,80,255),.3)
task.wait(.09)
end
if valid(t) then
local core=ball(base,2.3,Color3.fromRGB(160,65,255),"HollowPurple")
local glow=ball(base,1.4,Color3.fromRGB(220,180,255),"PurpleCore")
for i=1,6 do ring(base,2+i*.4,Color3.fromRGB(135,65,255),.5) end
task.wait(.5)
local dir=root.CFrame.LookVector
local endPos=base+dir*85
beam(base,endPos,Color3.fromRGB(145,55,255),7)
beam(base,endPos,Color3.fromRGB(220,185,255),2)
for i=1,7 do
local p=base+dir*(i*11)
burst(p,Color3.fromRGB(155,65,255),35)
ring(p,3,Color3.fromRGB(130,65,255),.6)
end
task.wait(.6)
core:Destroy()
glow:Destroy()
cameraPunch(12,.7)
end
blueOrb:Destroy()
redOrb:Destroy()
finish(t)
end
local function domain()
local t=begin() if not t then return end
pose(t,.7,{Root=CFrame.Angles(0,0,0),RightShoulder=CFrame.Angles(-2,0,.4),LeftShoulder=CFrame.Angles(-2,0,-.4),Neck=CFrame.Angles(-.15,0,0)})
local center=root.Position
local cc=Instance.new("ColorCorrectionEffect")
cc.Name="GojoDomainColor"
cc.TintColor=Color3.fromRGB(185,165,255)
cc.Contrast=.3
cc.Saturation=-.15
cc.Brightness=-.05
cc.Parent=L
savedLight[cc]={}
local dome=mk(fx,"DomainBarrier",Vector3.one, CFrame.new(center),Color3.fromRGB(85,65,190),Enum.Material.ForceField,.82,Enum.PartType.Ball)
dome.Size=Vector3.new(2,2,2)
tw(dome,1.2,{Size=Vector3.new(95,95,95),Transparency=.9})
for i=1,8 do
local r=mk(fx,"DomainRing",Vector3.new(.12,24+i*3,24+i*3),CFrame.new(center+Vector3.new(0,i*2-8,0))*CFrame.Angles(math.rad(i*20),0,math.rad(90)),Color3.fromRGB(150,125,255),Enum.Material.Neon,.25,Enum.PartType.Cylinder)
tw(r,8,{CFrame=r.CFrame*CFrame.Angles(math.rad(360),math.rad(i*90),math.rad(360))})
end
for i=1,24 do
local a=i/24*math.pi*2
local p=center+Vector3.new(math.cos(a)*18,math.sin(a*3)*3,math.sin(a)*18)
local star=ball(p,.25,Color3.fromRGB(200,190,255),"DomainStar")
tw(star,3,{Position=p+Vector3.new(0,math.random(4,18),0),Transparency=1})
task.delay(3,function() if star.Parent then star:Destroy() end end)
end
ring(center,15,Color3.fromRGB(150,115,255),1)
cameraPunch(8,1)
task.wait(7)
if cc.Parent then cc:Destroy() end
if dome.Parent then dome:Destroy() end
finish(t)
end
local function teleport()
local t=begin() if not t then return end
local old=root.CFrame
burst(root.Position,Color3.fromRGB(100,180,255),35)
for i=1,4 do
local ghost=mk(fx,"AfterImage",Vector3.new(2,4,1),old*CFrame.new(0,0,i*.15),Color3.fromRGB(80,170,255),Enum.Material.Neon,.6)
task.delay(.4,function() if ghost.Parent then ghost:Destroy() end end)
end
root.CFrame=old+root.CFrame.LookVector*12
burst(root.Position,Color3.fromRGB(100,180,255),35)
ring(root.Position,3,Color3.fromRGB(80,170,255),.6)
finish(t)
end
local function infinity()
local t=begin() if not t then return end
local start=os.clock()
local conn
conn=RS.Heartbeat:Connect(function()
if not valid(t) or os.clock()-start>8 then conn:Disconnect() return end
if math.random()<.18 then
local p=root.Position+Vector3.new(math.random(-5,5),math.random(-2,4),math.random(-5,5))
local r=ring(p,math.random(1,3),Color3.fromRGB(70,190,255),.4)
end
end)
addConn(conn)
local halo=ball(root.Position+Vector3.new(0,2,0),3,Color3.fromRGB(70,175,255),"InfinityShield")
halo.Transparency=.8
tw(halo,8,{Transparency=1})
task.wait(8)
if halo.Parent then halo:Destroy() end
finish(t)
end
local panel=Instance.new("Frame")
panel.Name="Main"
panel.Size=UDim2.fromOffset(235,310)
panel.Position=UDim2.new(0,18,.35,0)
panel.BackgroundColor3=Color3.fromRGB(12,15,30)
panel.BackgroundTransparency=.08
panel.Parent=gui
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,12)
local stroke=Instance.new("UIStroke",panel)
stroke.Color=Color3.fromRGB(110,100,255)
stroke.Thickness=1.5
local title=Instance.new("TextButton")
title.Size=UDim2.new(1,0,0,42)
title.BackgroundColor3=Color3.fromRGB(30,35,70)
title.Text="GOJO v1.4   —   SKILLS"
title.TextColor3=Color3.new(1,1,1)
title.TextSize=15
title.Font=Enum.Font.GothamBold
title.Parent=panel
Instance.new("UICorner",title).CornerRadius=UDim.new(0,10)
local list=Instance.new("Frame")
list.Size=UDim2.new(1,-16,1,-54)
list.Position=UDim2.fromOffset(8,49)
list.BackgroundTransparency=1
list.Parent=panel
local layout=Instance.new("UIListLayout",list)
layout.Padding=UDim.new(0,5)
layout.SortOrder=Enum.SortOrder.LayoutOrder
local function button(text,color,fn)
local b=Instance.new("TextButton")
b.Size=UDim2.new(1,0,0,34)
b.BackgroundColor3=color
b.Text=text
b.TextColor3=Color3.new(1,1,1)
b.TextSize=14
b.Font=Enum.Font.GothamSemibold
b.AutoButtonColor=true
b.Parent=list
Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
b.Activated:Connect(function()
if busy then return end
task.spawn(fn)
end)
return b
end
button("苍  |  Blue",Color3.fromRGB(25,105,190),blue)
button("赫  |  Red",Color3.fromRGB(175,35,55),red)
button("茈  |  Hollow Purple",Color3.fromRGB(105,45,175),purple)
button("无量空处  |  Domain",Color3.fromRGB(70,50,135),domain)
button("瞬移  |  Teleport",Color3.fromRGB(35,90,130),teleport)
button("无下限  |  Infinity",Color3.fromRGB(30,115,150),infinity)
button("清除特效  |  Clear",Color3.fromRGB(65,65,80),function()
token+=1
busy=false
for _,c in ipairs(cons) do pcall(function() c:Disconnect() end) end
table.clear(cons)
for _,v in ipairs(fx:GetChildren()) do v:Destroy() end
for _,v in ipairs(tweens) do pcall(function() v:Cancel() end) end
table.clear(tweens)
for _,v in ipairs(L:GetChildren()) do if v.Name=="GojoDomainColor" then v:Destroy() end end
resetPose()
end)
local minimized=false
title.Activated:Connect(function()
minimized=not minimized
list.Visible=not minimized
panel.Size=minimized and UDim2.fromOffset(235,42) or UDim2.fromOffset(235,310)
end)
local dragging=false
local dragStart
local startPos
title.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=true
dragStart=input.Position
startPos=panel.Position
end
end)
UIS.InputChanged:Connect(function(input)
if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
local d=input.Position-dragStart
panel.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
end
end)
UIS.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
gui.Destroying:Connect(function()
token+=1
for _,c in ipairs(cons) do pcall(function() c:Disconnect() end) end
resetPose()
for _,v in ipairs(L:GetChildren()) do if v.Name=="GojoDomainColor" then v:Destroy() end end
if fx.Parent then fx:Destroy() end
end)