local P=game:GetService("Players").LocalPlayer
local T=game:GetService("TweenService")
local R=game:GetService("RunService")
local L=game:GetService("Lighting")
local W=workspace
local PG=P:WaitForChild("PlayerGui")
local old=W:FindFirstChild("LocalCinema")
if old then old:Destroy()end
local oldUI=PG:FindFirstChild("CinemaControl")
if oldUI then oldUI:Destroy()end
local F=Instance.new("Folder",W);F.Name="LocalCinema"
local rng=Random.new(42)
local running=false
local C=W.CurrentCamera
local originalType,originalSubject=C.CameraType,C.CameraSubject
local function part(n,s,p,c,m,sh,parent)
 local x=Instance.new("Part");x.Name=n;x.Size=s;x.CFrame=typeof(p)=="CFrame"and p or CFrame.new(p);x.Color=c;x.Material=m or Enum.Material.SmoothPlastic;x.Shape=sh or Enum.PartType.Block;x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.CanQuery=false;x.CastShadow=true;x.Parent=parent or F;return x
end
local function ball(n,p,r,c,m,parent)
 return part(n,Vector3.one*r*2,p,c,m,Enum.PartType.Ball,parent)
end
local function tween(o,d,g,s)
 local t=T:Create(o,TweenInfo.new(d,s or Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),g);t:Play();return t
end
local function waitFor(d)
 local e=os.clock()+d
 while running and os.clock()<e do R.RenderStepped:Wait()end
end
local function caption(s)
 local g=Instance.new("ScreenGui");g.Name="CinemaCaption";g.IgnoreGuiInset=true;g.Parent=PG
 local a=Instance.new("TextLabel");a.Size=UDim2.new(.8,0,0,48);a.Position=UDim2.new(.1,0,.1,0);a.BackgroundTransparency=1;a.Text=s;a.TextColor3=Color3.fromRGB(100,220,255);a.TextTransparency=1;a.TextScaled=true;a.Font=Enum.Font.GothamBold;a.Parent=g
 tween(a,.5,{TextTransparency=0});task.delay(2.5,function()if g.Parent then tween(a,.5,{TextTransparency=1});task.wait(.6);g:Destroy()end end)
end
local function cam(p,q,d,f)
 if not running then return end
 C.CameraType=Enum.CameraType.Scriptable
 local t=tween(C,d,{CFrame=CFrame.lookAt(p,q),FieldOfView=f or 70})
 while running and t.PlaybackState==Enum.PlaybackState.Playing do R.RenderStepped:Wait()end
end
local base=Vector3.new(0,12000,0)
local ship=Instance.new("Model",F);ship.Name="ORION_IX"
local function sp(n,s,p,c,m)
 return part(n,s,p,c,m,nil,ship)
end
local hull=sp("MainHull",Vector3.new(7,2,15),base,Color3.fromRGB(65,78,100),Enum.Material.Metal);ship.PrimaryPart=hull
sp("Nose",Vector3.new(5,.9,5),base+Vector3.new(0,.2,-9),Color3.fromRGB(160,180,200),Enum.Material.Metal)
sp("LowerHull",Vector3.new(5,.7,11),base+Vector3.new(0,-1.1,0),Color3.fromRGB(35,42,56),Enum.Material.Metal)
sp("CockpitFrame",Vector3.new(4,1.8,4),base+Vector3.new(0,1.3,-4),Color3.fromRGB(20,80,110),Enum.Material.Glass)
sp("CockpitGlass",Vector3.new(3.5,1.2,3),base+Vector3.new(0,1.8,-4),Color3.fromRGB(60,190,235),Enum.Material.Glass)
for _,v in ipairs({-1,1})do
 sp("Wing",Vector3.new(9,.35,5),base+Vector3.new(v*6,-.4,1),Color3.fromRGB(60,72,92),Enum.Material.Metal)
 sp("WingTip",Vector3.new(1,.5,4),base+Vector3.new(v*10,-.3,1),Color3.fromRGB(30,150,220),Enum.Material.Neon)
 sp("Engine",Vector3.new(1.5,1.5,2),base+Vector3.new(v*2,0,8),Color3.fromRGB(40,170,255),Enum.Material.Neon)
 sp("EngineFlame",Vector3.new(.8,.8,4),base+Vector3.new(v*2,0,11),Color3.fromRGB(40,110,255),Enum.Material.Neon)
 sp("LandingGear",Vector3.new(.3,2,.3),base+Vector3.new(v*2,-2,3),Color3.fromRGB(130,140,150),Enum.Material.Metal)
 for i=1,5 do sp("HullPanel",Vector3.new(.12,.12,1.5),base+Vector3.new(v*3.55,-.05,-5+i*2),Color3.fromRGB(100,130,155),Enum.Material.Metal)end
end
for i=1,8 do
 local z=-5+i*1.3
 sp("HullLight",Vector3.new(.12,.12,.5),base+Vector3.new(3.6,.2,z),Color3.fromRGB(40,200,255),Enum.Material.Neon)
end
local function pivot(p,look,d)
 if not running then return end
 local v=Instance.new("CFrameValue");v.Value=ship:GetPivot()
 local c=v:GetPropertyChangedSignal("Value"):Connect(function()if ship.Parent then ship:PivotTo(v.Value)end end)
 local t=tween(v,d,{Value=CFrame.lookAt(p,look)})
 while running and t.PlaybackState==Enum.PlaybackState.Playing do R.RenderStepped:Wait()end
 c:Disconnect();v:Destroy()
end
local function modelBall(n,p,r,col,seed)
 local m=Instance.new("Model",F);m.Name=n
 local b=ball(n,p,r,col,Enum.Material.SmoothPlastic,m);m.PrimaryPart=b
 local rr=Random.new(seed)
 for i=1,90 do
  local u=rr:NextNumber(-1,1);local a=rr:NextNumber(0,math.pi*2)
  local d=Vector3.new(math.sqrt(1-u*u)*math.cos(a),u,math.sqrt(1-u*u)*math.sin(a))
  local size=r*rr:NextNumber(.025,.09)
  local q=ball("SurfaceRelief",p+d*(r*.97),size,col:Lerp(Color3.new(1,1,1),rr:NextNumber(0,.22)),Enum.Material.SmoothPlastic,m)
  q.CFrame=CFrame.lookAt(q.Position,q.Position+d)
 end
 local at=ball("Atmosphere",p,r*1.04,col,Enum.Material.ForceField,m);at.Transparency=.88
 return m
end
local sun=ball("SUN",base,100,Color3.fromRGB(255,150,35),Enum.Material.Neon)
for i=1,4 do
 local a=ball("SolarCorona",base,100+i*7,Color3.fromRGB(255,100+i*20,25),Enum.Material.ForceField);a.Transparency=.8+i*.035
end
local data={
 {"MERCURY",Vector3.new(180,0,0),12,Color3.fromRGB(125,120,112)},
 {"VENUS",Vector3.new(300,0,0),24,Color3.fromRGB(215,175,110)},
 {"EARTH",Vector3.new(440,0,0),28,Color3.fromRGB(35,110,220)},
 {"MARS",Vector3.new(590,0,0),20,Color3.fromRGB(190,75,45)},
 {"JUPITER",Vector3.new(850,0,0),70,Color3.fromRGB(200,155,115)},
 {"SATURN",Vector3.new(1120,0,0),58,Color3.fromRGB(215,185,130)},
 {"URANUS",Vector3.new(1390,0,0),40,Color3.fromRGB(100,210,215)},
 {"NEPTUNE",Vector3.new(1630,0,0),39,Color3.fromRGB(40,75,220)},
 {"PLUTO",Vector3.new(1840,0,0),13,Color3.fromRGB(165,140,120)}
}
local planets={}
for i,v in ipairs(data)do
 local p=base+v[2]
 local m=modelBall(v[1],p,v[3],v[4],i*91)
 if v[1]=="EARTH"then
  for j=1,9 do
   local a=j*math.pi*2/9
   ball("Cloud",p+Vector3.new(math.cos(a)*v[3]*.65,math.sin(a*2)*v[3]*.3,math.sin(a)*v[3]*.65),v[3]*.17,Color3.fromRGB(235,245,255),Enum.Material.Glass,m)
  end
 end
 if v[1]=="SATURN"then
  for j=1,5 do
   local r=v[3]*(1.6+j*.23)
   local ring=part("SaturnRing",Vector3.new(r*2,.5,r*2),CFrame.new(p)*CFrame.Angles(math.rad(15),0,0),j%2==0 and Color3.fromRGB(175,145,105)or Color3.fromRGB(225,200,160),Enum.Material.SmoothPlastic,Enum.PartType.Cylinder,m)
   ring.Transparency=j==3 and .3 or .05
  end
 end
 table.insert(planets,{v[1],p,v[3]})
end
local worm=base+Vector3.new(0,0,-500)
local rings={}
for i=1,22 do
 local r=12+i*4
 local q=part("WormholeRing",Vector3.new(r*2,.8,r*2),CFrame.new(worm)*CFrame.Angles(math.rad(90),0,0),i%2==0 and Color3.fromRGB(30,190,255)or Color3.fromRGB(165,40,255),Enum.Material.Neon,Enum.PartType.Cylinder)
 q.Transparency=1;table.insert(rings,q)
end
local hole=ball("WormholeCore",worm,12,Color3.fromRGB(3,0,15),Enum.Material.Neon);hole.Transparency=1
local stars={}
for i=1,500 do
 local d=Vector3.new(rng:NextNumber(-1,1),rng:NextNumber(-1,1),rng:NextNumber(-1,1)).Unit
 local s=ball("Star",base+d*rng:NextNumber(400,2200),rng:NextNumber(.4,1.3),Color3.fromRGB(180,215,255),Enum.Material.Neon);s.CastShadow=false;table.insert(stars,s)
end
for i=1,220 do
 local a=rng:NextNumber(0,math.pi*2);local r=rng:NextNumber(500,900)
 local p=base+Vector3.new(math.cos(a)*r,rng:NextNumber(-20,20),math.sin(a)*r)
 local b=ball("Asteroid",p,rng:NextNumber(1,5),Color3.fromRGB(95,88,80),Enum.Material.Slate)
 b.Size=Vector3.new(b.Size.X*1.7,b.Size.Y*.7,b.Size.Z*1.2)
end
local function movie()
 if running then return end
 running=true
 local cc=Instance.new("ColorCorrectionEffect",L);cc.Name="LocalCinemaGrade";cc.Contrast=.15;cc.Saturation=.1
 local bloom=Instance.new("BloomEffect",L);bloom.Intensity=.8;bloom.Size=32
 local oldFov=C.FieldOfView
 local ok,err=pcall(function()
  ship:PivotTo(CFrame.new(base+Vector3.new(-80,10,40)))
  caption("ORION IX  |  FLIGHT INITIATION")
  cam(base+Vector3.new(-35,16,45),base,3,55)
  pivot(base+Vector3.new(0,3,15),base+Vector3.new(0,0,-100),4)
  caption("BOARDING SEQUENCE")
  waitFor(1)
  caption("HATCH SEALED  |  ENGINES ONLINE")
  waitFor(1)
  caption("LIFTOFF")
  pivot(base+Vector3.new(0,40,0),base+Vector3.new(0,40,-100),3)
  caption("WORMHOLE FORMATION")
  for i,q in ipairs(rings)do q.Transparency=.05;tween(q,1,{Transparency=.05});waitFor(.07)end
  hole.Transparency=0
  for i=1,6 do
   for _,q in ipairs(rings)do q.CFrame=q.CFrame*CFrame.Angles(0,0,.03)end
   waitFor(.12)
  end
  caption("WARP DRIVE ENGAGED")
  pivot(worm+Vector3.new(0,0,100),worm,3)
  for i=1,18 do
   if not running then break end
   local p=worm+Vector3.new(math.sin(i*.5)*5,math.cos(i*.7)*4,90-i*9)
   ship:PivotTo(CFrame.lookAt(p,p+Vector3.new(0,0,-1)))
   C.CFrame=CFrame.lookAt(p+Vector3.new(10,5,24),p);C.FieldOfView=95
   cc.TintColor=Color3.fromRGB(150,90,255)
   for _,q in ipairs(rings)do q.Transparency=math.max(.05,math.min(.9,q.Transparency+.015))end
   R.RenderStepped:Wait()
  end
  cc.TintColor=Color3.fromRGB(190,220,255);C.FieldOfView=70
  for _,q in ipairs(rings)do q.Transparency=1 end;hole.Transparency=1
  caption("SOL SYSTEM  |  EXPLORATION")
  pivot(base+Vector3.new(0,30,150),base,3)
  cam(base+Vector3.new(0,100,600),base,4,55)
  for _,v in ipairs(planets)do
   if not running then break end
   local n,p,r=v[1],v[2],v[3]
   caption("DESTINATION  |  "..n)
   pivot(p+Vector3.new(0,r*.6,r*3),p,3)
   cam(p+Vector3.new(r*2,r,r*3),p,2,65)
   local start=os.clock()
   while running and os.clock()-start<3 do
    local a=(os.clock()-start)*.4
    C.CFrame=CFrame.lookAt(p+Vector3.new(math.cos(a)*r*3,r,math.sin(a)*r*3),p)
    R.RenderStepped:Wait()
   end
  end
  caption("EARTH RETURN")
  local earth=base+Vector3.new(440,0,0)
  pivot(earth+Vector3.new(0,40,100),earth,4)
  cam(earth+Vector3.new(40,25,80),earth,3,65)
  caption("ATMOSPHERIC ENTRY")
  cc.TintColor=Color3.fromRGB(255,170,120)
  local ground=base+Vector3.new(440,-100,0)
  part("LandingGround",Vector3.new(600,5,600),ground,Color3.fromRGB(45,95,55),Enum.Material.Grass)
  part("LandingPad",Vector3.new(70,1,70),ground+Vector3.new(0,3,0),Color3.fromRGB(55,65,80),Enum.Material.Metal)
  pivot(ground+Vector3.new(0,40,80),ground,4)
  pivot(ground+Vector3.new(0,8,0),ground,4)
  caption("LANDING COMPLETE")
  cam(ground+Vector3.new(35,18,45),ground,3,55)
  waitFor(3)
 end)
 running=false
 C.CameraType=originalType;C.CameraSubject=originalSubject;C.FieldOfView=oldFov
 cc:Destroy();bloom:Destroy()
 if not ok then warn(err)end
end
local G=Instance.new("ScreenGui");G.Name="CinemaControl";G.ResetOnSpawn=false;G.IgnoreGuiInset=true;G.Parent=PG
local main=Instance.new("Frame");main.Name="Panel";main.Size=UDim2.fromOffset(235,125);main.Position=UDim2.new(.04,0,.35,0);main.BackgroundColor3=Color3.fromRGB(12,17,29);main.BackgroundTransparency=.08;main.Parent=G
Instance.new("UICorner",main).CornerRadius=UDim.new(0,10)
local stroke=Instance.new("UIStroke",main);stroke.Color=Color3.fromRGB(35,170,255);stroke.Transparency=.25
local top=Instance.new("TextButton");top.Size=UDim2.new(1,0,0,35);top.BackgroundColor3=Color3.fromRGB(20,30,48);top.Text="✦  ORION CINEMA     ─";top.TextColor3=Color3.fromRGB(130,220,255);top.Font=Enum.Font.GothamBold;top.TextSize=13;top.Parent=main
Instance.new("UICorner",top).CornerRadius=UDim.new(0,9)
local start=Instance.new("TextButton");start.Size=UDim2.new(1,-24,0,42);start.Position=UDim2.new(0,12,0,52);start.BackgroundColor3=Color3.fromRGB(20,110,170);start.Text="▶   启动电影";start.TextColor3=Color3.new(1,1,1);start.Font=Enum.Font.GothamBold;start.TextSize=15;start.Parent=main
Instance.new("UICorner",start).CornerRadius=UDim.new(0,8)
local small=false
top.Activated:Connect(function()
 small=not small
 main:TweenSize(small and UDim2.fromOffset(235,35)or UDim2.fromOffset(235,125),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,.25,true)
 top.Text=small and"✦  ORION CINEMA     +"or"✦  ORION CINEMA     ─"
end)
local dragging,dragStart,startPos
top.InputBegan:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;dragStart=i.Position;startPos=main.Position end
end)
top.InputChanged:Connect(function(i)
 if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then
  local d=i.Position-dragStart;main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
 end
end)
top.InputEnded:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
start.Activated:Connect(function()
 if running then return end
 start.Text="⏳  播放中..."
 task.spawn(function()movie();start.Text="▶   再次播放"end)
end)