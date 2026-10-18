local P=game:GetService("Players").LocalPlayer
local T=game:GetService("TweenService")
local R=game:GetService("RunService")
local L=game:GetService("Lighting")
local C=workspace.CurrentCamera
local PG=P:WaitForChild("PlayerGui")
local F=Instance.new("Folder");F.Name="LocalCinema";F.Parent=workspace
local rng=Random.new(42)
local running=false
local originalType=C.CameraType
local originalSubject=C.CameraSubject
local function part(n,s,p,c,m,sh,parent)
 local x=Instance.new("Part");x.Name=n;x.Size=s;x.CFrame=typeof(p)=="CFrame" and p or CFrame.new(p);x.Color=c;x.Material=m or Enum.Material.SmoothPlastic;x.Shape=sh or Enum.PartType.Block;x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.CanQuery=false;x.Parent=parent or F;return x
end
local function ball(n,p,r,c,m)return part(n,Vector3.one*r*2,p,c,m,Enum.PartType.Ball)end
local function tw(o,d,g,style)local t=T:Create(o,TweenInfo.new(d,style or Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),g);t:Play();return t end
local function waitFor(d)local t=os.clock();while running and os.clock()-t<d do R.RenderStepped:Wait()end end
local function cam(p,q,d,f)if not running then return end;C.CameraType=Enum.CameraType.Scriptable;local t=tw(C,d,{CFrame=CFrame.lookAt(p,q),FieldOfView=f or 70});t.Completed:Wait()end
local function say(s)
 if not running then return end
 local old=PG:FindFirstChild("CinemaCaption");if old then old:Destroy()end
 local g=Instance.new("ScreenGui");g.Name="CinemaCaption";g.IgnoreGuiInset=true;g.Parent=PG
 local a=Instance.new("TextLabel");a.Size=UDim2.new(.8,0,0,48);a.Position=UDim2.new(.1,0,.1,0);a.BackgroundTransparency=1;a.Text=s;a.TextColor3=Color3.fromRGB(90,220,255);a.TextTransparency=1;a.TextScaled=true;a.Font=Enum.Font.GothamBold;a.Parent=g
 tw(a,.4,{TextTransparency=0});task.delay(2.5,function()if g.Parent then tw(a,.4,{TextTransparency=1});task.wait(.5);g:Destroy()end end)
end
local ship=Instance.new("Model");ship.Name="ORION_IX";ship.Parent=F
local hull=part("Hull",Vector3.new(7,2,13),Vector3.zero,Color3.fromRGB(100,120,150),Enum.Material.Metal,nil,ship);ship.PrimaryPart=hull
part("Nose",Vector3.new(5,1.5,4),Vector3.new(0,.2,-7),Color3.fromRGB(180,195,215),Enum.Material.Metal,nil,ship)
part("Cockpit",Vector3.new(4,1.5,4),Vector3.new(0,1.4,-3),Color3.fromRGB(35,170,230),Enum.Material.Glass,nil,ship)
for _,v in ipairs({-1,1})do
 part("Wing",Vector3.new(7,.4,5),Vector3.new(v*6,-.5,1),Color3.fromRGB(65,80,105),Enum.Material.Metal,nil,ship)
 part("Engine",Vector3.new(1.4,1.4,1),Vector3.new(v*2,0,7),Color3.fromRGB(30,175,255),Enum.Material.Neon,nil,ship)
 part("EngineGlow",Vector3.new(1,1,4),Vector3.new(v*2,0,9),Color3.fromRGB(20,120,255),Enum.Material.Neon,nil,ship)
end
local base=Vector3.new(0,12000,0)
local worm=base+Vector3.new(0,0,-150)
for i=1,16 do local r=18+i*1.5;local q=part("WormholeRing",Vector3.new(r*2,.5,r*2),CFrame.new(worm)*CFrame.Angles(math.rad(90),0,math.rad(i*12)),i%2==0 and Color3.fromRGB(30,180,255) or Color3.fromRGB(165,45,255),Enum.Material.Neon,Enum.PartType.Cylinder);task.spawn(function()while q.Parent do q.CFrame=q.CFrame*CFrame.Angles(0,0,.01);R.Heartbeat:Wait()end end)end
ball("Singularity",worm,20,Color3.fromRGB(5,0,20),Enum.Material.Neon)
local data={{"SUN",Vector3.new(0,0,-400),45,Color3.fromRGB(255,170,55)},{"MERCURY",Vector3.new(70,10,-550),10,Color3.fromRGB(145,135,125)},{"VENUS",Vector3.new(-80,20,-700),17,Color3.fromRGB(220,170,100)},{"EARTH",Vector3.new(70,-10,-900),28,Color3.fromRGB(30,100,230)},{"MARS",Vector3.new(-100,15,-1100),17,Color3.fromRGB(200,75,45)},{"JUPITER",Vector3.new(100,25,-1350),45,Color3.fromRGB(205,155,115)},{"SATURN",Vector3.new(-120,0,-1600),38,Color3.fromRGB(220,190,135)},{"URANUS",Vector3.new(80,20,-1850),26,Color3.fromRGB(100,220,220)},{"NEPTUNE",Vector3.new(-90,0,-2100),25,Color3.fromRGB(40,75,230)},{"PLUTO",Vector3.new(50,10,-2300),10,Color3.fromRGB(180,145,125)}}
local planets={}
for _,v in ipairs(data)do
 local p=base+v[2];local m=Instance.new("Model");m.Name=v[1];m.Parent=F
 local b=ball(v[1],p,v[3],v[4],Enum.Material.SmoothPlastic);b.Parent=m;m.PrimaryPart=b
 for i=1,24 do local d=Vector3.new(rng:NextNumber(-1,1),rng:NextNumber(-1,1),rng:NextNumber(-1,1)).Unit;local patch=ball("SurfaceDetail",p+d*v[3]*.9,v[3]*rng:NextNumber(.08,.2),v[4]:Lerp(Color3.new(1,1,1),rng:NextNumber(0,.25)));patch.Parent=m end
 local at=ball("Atmosphere",p,v[3]*1.06,v[4],Enum.Material.ForceField);at.Transparency=.85;at.Parent=m
 if v[1]=="SATURN"then for i=1,3 do local r=v[3]*(2.5+i*.4);local ring=part("PlanetaryRing",Vector3.new(r*2,.2,r*2),CFrame.new(p)*CFrame.Angles(math.rad(90),0,math.rad(15)),Color3.fromRGB(190,160,115),Enum.Material.SmoothPlastic,Enum.PartType.Cylinder);ring.Parent=m end end
 table.insert(planets,{v[1],p,v[3]})
end
for i=1,250 do local d=Vector3.new(rng:NextNumber(-1,1),rng:NextNumber(-1,1),rng:NextNumber(-1,1)).Unit;local s=ball("Star",d*rng:NextNumber(300,1000),rng:NextNumber(.2,.7),Color3.fromRGB(190,220,255),Enum.Material.Neon);s.CastShadow=false end
for i=1,90 do local a=rng:NextNumber(0,math.pi*2);local r=rng:NextNumber(45,110);ball("Asteroid",base+Vector3.new(math.cos(a)*r,rng:NextNumber(-20,20),-1250+math.sin(a)*r),rng:NextNumber(1,4),Color3.fromRGB(95,90,85),Enum.Material.Slate)end
local function moveShip(p,d,target)
 if not running then return end
 local v=Instance.new("CFrameValue");v.Value=ship:GetPivot();local c=v:GetPropertyChangedSignal("Value"):Connect(function()if ship.Parent then ship:PivotTo(v.Value)end end)
 local t=tw(v,d,{Value=CFrame.lookAt(p,target or p+Vector3.new(0,0,-1))});t.Completed:Wait();c:Disconnect();v:Destroy()
end
local function movie()
 if running then return end
 running=true
 local cc=Instance.new("ColorCorrectionEffect");cc.Name="LocalCinemaGrade";cc.Contrast=.18;cc.Saturation=.08;cc.Parent=L
 local bloom=Instance.new("BloomEffect");bloom.Intensity=.8;bloom.Size=32;bloom.Parent=L
 ship:PivotTo(CFrame.new(base))
 local ok,err=pcall(function()
  say("ORION IX  |  DEEP SPACE");cam(base+Vector3.new(24,12,30),base,3,55);cam(base+Vector3.new(-20,7,20),base,3,60)
  say("WORMHOLE APPROACH");moveShip(worm+Vector3.new(0,0,45),3,worm);cam(worm+Vector3.new(20,12,80),worm,3,75)
  say("WORMHOLE TRANSIT")
  for i=1,10 do if not running then return end;local p=worm+Vector3.new(math.sin(i)*3,math.cos(i)*3,40-i*10);ship:PivotTo(CFrame.lookAt(p,p+Vector3.new(0,0,-1)));C.CFrame=CFrame.lookAt(p+Vector3.new(8,4,20),p);C.FieldOfView=95;cc.TintColor=Color3.fromRGB(150,100,255);R.RenderStepped:Wait()end
  cc.TintColor=Color3.fromRGB(190,215,255);C.FieldOfView=70;say("SOLAR SYSTEM");moveShip(base+Vector3.new(0,10,-300),2)
  for _,v in ipairs(planets)do if not running then return end;say(v[1]);local p,r=v[2],v[3];moveShip(p+Vector3.new(0,r*.4,r*2.5),2.2,p);cam(p+Vector3.new(r*2,r,r*3),p,1.7,65);waitFor(.3)end
  say("EARTH RETURN");local earth=base+Vector3.new(70,-10,-900);moveShip(earth+Vector3.new(0,20,-100),3,earth);cam(earth+Vector3.new(30,20,-60),earth,3,65)
  say("ATMOSPHERIC ENTRY");cc.TintColor=Color3.fromRGB(255,170,120);moveShip(base+Vector3.new(0,-20,-2500),4,base+Vector3.new(0,-30,-2600))
  local g=base+Vector3.new(0,-30,-2600);part("LandingGround",Vector3.new(500,4,500),g,Color3.fromRGB(45,95,55),Enum.Material.Grass);part("LandingPad",Vector3.new(60,1,60),g+Vector3.new(0,2.5,0),Color3.fromRGB(55,65,80),Enum.Material.Metal)
  cc.TintColor=Color3.fromRGB(190,215,255);say("LANDING SEQUENCE");moveShip(g+Vector3.new(0,12,0),3,g);moveShip(g+Vector3.new(0,5,0),2,g);cam(g+Vector3.new(25,12,30),g,3,55);say("MISSION COMPLETE");waitFor(3)
 end)
 running=false;C.CameraType=originalType;C.CameraSubject=originalSubject;cc:Destroy();bloom:Destroy()
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
top.Activated:Connect(function()small=not small;main:TweenSize(small and UDim2.fromOffset(235,35) or UDim2.fromOffset(235,125),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,.25,true);top.Text=small and "✦  ORION CINEMA     +" or "✦  ORION CINEMA     ─"end)
local dragging,dragStart,startPos
top.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;dragStart=i.Position;startPos=main.Position end end)
top.InputChanged:Connect(function(i)if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then local d=i.Position-dragStart;main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)end end)
top.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
start.Activated:Connect(function()if running then return end;start.Text="⏳  播放中...";task.spawn(function()movie();start.Text="▶   再次播放"end)end)