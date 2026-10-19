local VERSION = "1.2"
local GUI_NAME = "GojoSkillUI"
local EFFECT_NAME = "GojoSkillEffects"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

for _, name in ipairs({GUI_NAME, "GojoSkillUI_V2", "GojoSkillDemo"}) do
    local old = playerGui:FindFirstChild(name)
    if old then
        old:Destroy()
    end
end

local oldEffects = workspace:FindFirstChild(EFFECT_NAME)
if oldEffects then
    oldEffects:Destroy()
end

local effects = Instance.new("Folder")
effects.Name = EFFECT_NAME
effects.Parent = workspace

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = playerGui

local COLORS = {
    Blue = Color3.fromRGB(55, 155, 255),
    BlueLight = Color3.fromRGB(165, 235, 255),
    Red = Color3.fromRGB(255, 55, 90),
    Purple = Color3.fromRGB(160, 75, 255),
    PurpleLight = Color3.fromRGB(220, 170, 255),
    White = Color3.fromRGB(245, 250, 255),
    Dark = Color3.fromRGB(12, 15, 30)
}

local busy = false
local minimized = false
local currentLighting = nil
local savedLighting = nil
local activeTweens = {}
local activeConnections = {}
local actionToken = 0

local function tween(object, duration, properties, style, direction)
    if not object or not object.Parent then
        return
    end

    local info = TweenInfo.new(
        duration,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )

    local animation = TweenService:Create(object, info, properties)
    table.insert(activeTweens, animation)
    animation:Play()

    return animation
end

local function createPart(name, size, cf, color, material, transparency, shape)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cf
    part.Color = color
    part.Material = material or Enum.Material.Neon
    part.Transparency = transparency or 0
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false

    if shape then
        part.Shape = shape
    end

    part.Parent = effects
    return part
end

local function sphere(name, position, size, color, transparency)
    return createPart(
        name,
        Vector3.new(size, size, size),
        CFrame.new(position),
        color,
        Enum.Material.Neon,
        transparency or 0,
        Enum.PartType.Ball
    )
end

local function ring(name, position, radius, thickness, color, transparency, rotation)
    local part = createPart(
        name,
        Vector3.new(thickness, radius * 2, radius * 2),
        CFrame.new(position) * (rotation or CFrame.Angles(0, 0, math.rad(90))),
        color,
        Enum.Material.Neon,
        transparency or 0.1,
        Enum.PartType.Cylinder
    )

    return part
end

local function character()
    return player.Character
end

local function root()
    local model = character()
    return model and model:FindFirstChild("HumanoidRootPart")
end

local function humanoid()
    local model = character()
    return model and model:FindFirstChildOfClass("Humanoid")
end

local function hand()
    local model = character()
    if not model then
        return nil
    end

    return model:FindFirstChild("RightHand")
        or model:FindFirstChild("Right Arm")
        or model:FindFirstChild("HumanoidRootPart")
end

local function forwardPosition(distance, height)
    local r = root()
    if not r then
        return nil
    end

    return r.Position + r.CFrame.LookVector * distance + Vector3.new(0, height or 2, 0)
end

local function attachLight(part, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Parent = part
    return light
end

local function particleBurst(position, color, count, spread, size)
    for i = 1, count do
        local direction = Vector3.new(
            math.random(-100, 100) / 100,
            math.random(-100, 100) / 100,
            math.random(-100, 100) / 100
        )

        if direction.Magnitude < 0.05 then
            direction = Vector3.new(0, 1, 0)
        end

        direction = direction.Unit

        local part = sphere(
            "EnergyParticle",
            position,
            math.random(5, 12) / 10 * size,
            color,
            0.05
        )

        local destination = position + direction * math.random(50, 100) / 100 * spread

        tween(part, math.random(6, 13) / 10, {
            Position = destination,
            Transparency = 1,
            Size = Vector3.new(0.03, 0.03, 0.03)
        }, Enum.EasingStyle.Quint)
    end
end

local function flash(position, color, size)
    local part = sphere("EnergyFlash", position, 0.5, color, 0.15)
    attachLight(part, color, 3, size * 2)

    tween(part, 0.22, {
        Size = Vector3.new(size, size, size),
        Transparency = 0.65
    })

    task.delay(0.25, function()
        if part.Parent then
            tween(part, 0.4, {
                Transparency = 1,
                Size = Vector3.new(size * 1.4, size * 1.4, size * 1.4)
            })
        end
    end)
end

local function beamBetween(a, b, color, thickness, transparency)
    local distance = (b - a).Magnitude
    local midpoint = (a + b) / 2

    return createPart(
        "EnergyBeam",
        Vector3.new(thickness, thickness, distance),
        CFrame.lookAt(midpoint, b),
        color,
        Enum.Material.Neon,
        transparency or 0
    )
end

local function cleanupEffects()
    for _, animation in ipairs(activeTweens) do
        pcall(function()
            animation:Cancel()
        end)
    end

    table.clear(activeTweens)

    for _, connection in ipairs(activeConnections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end

    table.clear(activeConnections)

    if effects and effects.Parent then
        effects:ClearAllChildren()
    end
end

local function resetLighting()
    if currentLighting then
        currentLighting:Destroy()
        currentLighting = nil
    end

    if savedLighting then
        Lighting.ClockTime = savedLighting.ClockTime
        Lighting.Brightness = savedLighting.Brightness
        Lighting.Ambient = savedLighting.Ambient
        Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
        Lighting.FogEnd = savedLighting.FogEnd
        Lighting.FogColor = savedLighting.FogColor
        savedLighting = nil
    end
end

local function pose(kind, duration)
    local model = character()
    if not model then
        return
    end

    local poses = {}

    if kind == "Blue" then
        poses.RightShoulder = CFrame.Angles(math.rad(-55), 0, math.rad(35))
        poses.LeftShoulder = CFrame.Angles(math.rad(-20), 0, math.rad(-15))
        poses.Neck = CFrame.Angles(math.rad(-8), 0, 0)
    elseif kind == "Red" then
        poses.RightShoulder = CFrame.Angles(math.rad(-65), 0, math.rad(40))
        poses.LeftShoulder = CFrame.Angles(math.rad(-65), 0, math.rad(-40))
        poses.Neck = CFrame.Angles(math.rad(-5), 0, 0)
    elseif kind == "Purple" then
        poses.RightShoulder = CFrame.Angles(math.rad(-75), 0, math.rad(35))
        poses.LeftShoulder = CFrame.Angles(math.rad(-75), 0, math.rad(-35))
        poses.Neck = CFrame.Angles(math.rad(-10), 0, 0)
    elseif kind == "Domain" then
        poses.RightShoulder = CFrame.Angles(math.rad(-85), 0, math.rad(25))
        poses.LeftShoulder = CFrame.Angles(math.rad(-85), 0, math.rad(-25))
        poses.Neck = CFrame.Angles(math.rad(-12), 0, 0)
        poses.Waist = CFrame.Angles(math.rad(-5), 0, 0)
    end

    local motors = {}

    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("Motor6D") and poses[object.Name] then
            local original = object.Transform
            motors[#motors + 1] = {
                Motor = object,
                Original = original
            }

            tween(object, 0.25, {
                Transform = poses[object.Name]
            }, Enum.EasingStyle.Sine)
        end
    end

    task.delay(duration, function()
        for _, data in ipairs(motors) do
            if data.Motor.Parent then
                tween(data.Motor, 0.3, {
                    Transform = data.Original
                }, Enum.EasingStyle.Sine)
            end
        end
    end)
end

local function blueSkill()
    local position = forwardPosition(5, 1.5)
    if not position then
        return
    end

    pose("Blue", 2.5)

    local core = sphere("BlueCore", position, 0.6, COLORS.BlueLight)
    attachLight(core, COLORS.Blue, 3, 16)

    local r1 = ring("BlueRingA", position, 2, 0.12, COLORS.BlueLight)
    local r2 = ring("BlueRingB", position, 3, 0.12, COLORS.Blue, 0.15, CFrame.Angles(0, math.rad(60), math.rad(35)))
    local r3 = ring("BlueRingC", position, 1.5, 0.1, COLORS.White, 0.15, CFrame.Angles(math.rad(45), 0, math.rad(20)))

    tween(core, 0.8, {
        Size = Vector3.new(3, 3, 3)
    })

    tween(r1, 0.9, {
        Size = Vector3.new(0.12, 8, 8)
    })

    tween(r2, 0.9, {
        Size = Vector3.new(0.12, 11, 11)
    })

    tween(r3, 0.9, {
        Size = Vector3.new(0.1, 6, 6)
    })

    for i = 1, 3 do
        local offset = Vector3.new(
            math.random(-15, 15) / 10,
            math.random(-15, 15) / 10,
            math.random(-15, 15) / 10
        )

        local small = sphere("BlueOrbit", position + offset, 0.25, COLORS.BlueLight, 0.1)

        tween(small, 0.7, {
            Position = position,
            Transparency = 1
        })
    end

    particleBurst(position, COLORS.BlueLight, 18, 8, 0.6)

    task.delay(1.2, function()
        if core.Parent then
            tween(core, 0.45, {
                Transparency = 1,
                Size = Vector3.new(5, 5, 5)
            })
        end

        for _, part in ipairs({r1, r2, r3}) do
            if part.Parent then
                tween(part, 0.4, {
                    Transparency = 1
                })
            end
        end
    end)
end

local function redSkill()
    local position = forwardPosition(5, 1.5)
    if not position then
        return
    end

    pose("Red", 2.5)

    local core = sphere("RedCore", position, 0.5, COLORS.Red)
    attachLight(core, COLORS.Red, 4, 18)

    local r1 = ring("RedRingA", position, 1.8, 0.15, COLORS.Red)
    local r2 = ring("RedRingB", position, 2.8, 0.12, COLORS.White, 0.2, CFrame.Angles(0, math.rad(40), math.rad(30)))

    tween(core, 0.75, {
        Size = Vector3.new(3.2, 3.2, 3.2)
    })

    tween(r1, 0.8, {
        Size = Vector3.new(0.15, 8, 8)
    })

    tween(r2, 0.8, {
        Size = Vector3.new(0.12, 12, 12)
    })

    task.delay(0.8, function()
        flash(position, COLORS.Red, 10)
        particleBurst(position, COLORS.Red, 30, 14, 0.7)

        for _, part in ipairs({core, r1, r2}) do
            if part.Parent then
                tween(part, 0.4, {
                    Transparency = 1
                })
            end
        end
    end)
end

local function purpleSkill()
    local origin = forwardPosition(5, 2)
    if not origin then
        return
    end

    pose("Purple", 4.5)

    local blueStart = origin + Vector3.new(-3, 0, 0)
    local redStart = origin + Vector3.new(3, 0, 0)

    local blue = sphere("PurpleBlueOrb", blueStart, 0.5, COLORS.Blue)
    local red = sphere("PurpleRedOrb", redStart, 0.5, COLORS.Red)

    attachLight(blue, COLORS.Blue, 3, 12)
    attachLight(red, COLORS.Red, 3, 12)

    local blueRing = ring("PurpleBlueRing", blueStart, 1.4, 0.12, COLORS.BlueLight)
    local redRing = ring("PurpleRedRing", redStart, 1.4, 0.12, COLORS.Red, 0.1, CFrame.Angles(0, math.rad(60), math.rad(40)))

    tween(blue, 0.7, {
        Position = origin + Vector3.new(-1.2, 0.5, 0),
        Size = Vector3.new(2.4, 2.4, 2.4)
    })

    tween(red, 0.7, {
        Position = origin + Vector3.new(1.2, -0.5, 0),
        Size = Vector3.new(2.4, 2.4, 2.4)
    })

    tween(blueRing, 0.7, {
        Position = origin + Vector3.new(-1.2, 0.5, 0),
        Size = Vector3.new(0.12, 5, 5)
    })

    tween(redRing, 0.7, {
        Position = origin + Vector3.new(1.2, -0.5, 0),
        Size = Vector3.new(0.12, 5, 5)
    })

    task.wait(0.8)

    local center = origin + Vector3.new(0, 0, 0)

    if blue.Parent and red.Parent then
        tween(blue, 0.45, {
            Position = center,
            Color = COLORS.Purple,
            Size = Vector3.new(2.8, 2.8, 2.8)
        })

        tween(red, 0.45, {
            Position = center,
            Color = COLORS.PurpleLight,
            Size = Vector3.new(2.8, 2.8, 2.8)
        })

        tween(blueRing, 0.45, {
            Position = center
        })

        tween(redRing, 0.45, {
            Position = center
        })
    end

    task.wait(0.5)

    if blue.Parent then
        blue:Destroy()
    end

    if red.Parent then
        red:Destroy()
    end

    if blueRing.Parent then
        blueRing:Destroy()
    end

    if redRing.Parent then
        redRing:Destroy()
    end

    local core = sphere("HollowPurpleCore", center, 1, COLORS.PurpleLight)
    attachLight(core, COLORS.Purple, 6, 28)

    local rings = {}

    for i = 1, 4 do
        rings[i] = ring(
            "PurpleFusionRing",
            center,
            2 + i,
            0.15,
            i % 2 == 0 and COLORS.PurpleLight or COLORS.Purple,
            0.1,
            CFrame.Angles(math.rad(i * 35), math.rad(i * 45), math.rad(i * 25))
        )
    end

    tween(core, 0.5, {
        Size = Vector3.new(5, 5, 5)
    })

    for _, part in ipairs(rings) do
        tween(part, 0.5, {
            Size = Vector3.new(0.15, 10, 10)
        })
    end

    flash(center, COLORS.PurpleLight, 14)
    particleBurst(center, COLORS.Purple, 40, 18, 0.8)

    task.wait(0.55)

    local direction = root() and root().CFrame.LookVector or Vector3.new(0, 0, -1)
    local destination = center + direction * 65

    local projectile = sphere("HollowPurpleProjectile", center, 3.5, COLORS.Purple)
    attachLight(projectile, COLORS.PurpleLight, 8, 35)

    local projectileRing = ring("HollowPurpleProjectileRing", center, 4, 0.15, COLORS.PurpleLight)

    local travelTime = 1.1

    tween(projectile, travelTime, {
        Position = destination,
        Size = Vector3.new(8, 8, 8)
    }, Enum.EasingStyle.Linear)

    tween(projectileRing, travelTime, {
        Position = destination,
        Size = Vector3.new(0.15, 15, 15)
    }, Enum.EasingStyle.Linear)

    beamBetween(center, center + direction * 30, COLORS.Purple, 2, 0.35)

    task.wait(travelTime)

    flash(destination, COLORS.PurpleLight, 22)
    particleBurst(destination, COLORS.Purple, 45, 25, 1)

    for _, part in ipairs({core, projectile, projectileRing}) do
        if part.Parent then
            tween(part, 0.35, {
                Transparency = 1
            })
        end
    end

    for _, part in ipairs(rings) do
        if part.Parent then
            tween(part, 0.35, {
                Transparency = 1
            })
        end
    end
end

local function domainSkill()
    local r = root()
    if not r then
        return
    end

    pose("Domain", 8)

    savedLighting = {
        ClockTime = Lighting.ClockTime,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor
    }

    currentLighting = Instance.new("ColorCorrectionEffect")
    currentLighting.Name = "GojoDomainColor"
    currentLighting.TintColor = COLORS.White
    currentLighting.Contrast = 0
    currentLighting.Saturation = 0
    currentLighting.Brightness = 0
    currentLighting.Parent = Lighting

    tween(currentLighting, 0.8, {
        TintColor = Color3.fromRGB(155, 165, 255),
        Contrast = 0.25,
        Saturation = -0.3,
        Brightness = -0.05
    })

    local center = r.Position
    local ground = center - Vector3.new(0, 2.7, 0)

    local groundCircle = createPart(
        "DomainGround",
        Vector3.new(0.15, 2, 2),
        CFrame.new(ground) * CFrame.Angles(0, 0, math.rad(90)),
        COLORS.Purple,
        Enum.Material.Neon,
        0.35,
        Enum.PartType.Cylinder
    )

    tween(groundCircle, 1.2, {
        Size = Vector3.new(0.15, 65, 65)
    })

    local domainRings = {}

    for i = 1, 7 do
        local radius = 7 + i * 4

        local rotation = CFrame.Angles(
            math.rad(i * 18),
            math.rad(i * 37),
            math.rad(i * 22)
        )

        local part = ring(
            "DomainSpaceRing",
            center,
            radius,
            0.12,
            i % 2 == 0 and COLORS.BlueLight or COLORS.Purple,
            0.3,
            rotation
        )

        domainRings[#domainRings + 1] = part

        tween(part, 1.4, {
            Size = Vector3.new(0.12, radius * 2.5, radius * 2.5),
            Transparency = 0.12
        }, Enum.EasingStyle.Quint)
    end

    local shell = sphere("DomainShell", center, 4, COLORS.Purple, 0.9)
    tween(shell, 1.5, {
        Size = Vector3.new(90, 90, 90),
        Transparency = 0.93
    }, Enum.EasingStyle.Quint)

    flash(center, COLORS.BlueLight, 16)
    particleBurst(center, COLORS.PurpleLight, 45, 25, 0.7)

    for i = 1, 22 do
        local angle = i / 22 * math.pi * 2
        local radius = math.random(10, 35)

        local position = center + Vector3.new(
            math.cos(angle) * radius,
            math.random(-18, 18),
            math.sin(angle) * radius
        )

        local star = sphere(
            "DomainStar",
            position,
            math.random(3, 7) / 10,
            i % 2 == 0 and COLORS.BlueLight or COLORS.PurpleLight,
            0.15
        )

        tween(star, math.random(8, 18) / 10, {
            Position = position + Vector3.new(0, math.random(5, 18), 0),
            Transparency = 1
        })
    end

    for i = 1, 12 do
        local angle = i / 12 * math.pi * 2

        local a = center + Vector3.new(
            math.cos(angle) * 25,
            math.random(-10, 10),
            math.sin(angle) * 25
        )

        local b = center + Vector3.new(
            math.cos(angle + 0.2) * 35,
            math.random(-12, 12),
            math.sin(angle + 0.2) * 35
        )

        beamBetween(a, b, COLORS.PurpleLight, 0.12, 0.3)
    end

    local started = os.clock()
    local duration = 6

    local connection

    connection = RunService.Heartbeat:Connect(function()
        if not effects.Parent then
            connection:Disconnect()
            return
        end

        local elapsed = os.clock() - started

        if elapsed >= duration then
            connection:Disconnect()
            return
        end

        local currentRoot = root()
        if not currentRoot then
            return
        end

        local position = currentRoot.Position

        for index, part in ipairs(domainRings) do
            if part.Parent then
                local angle = elapsed * (index % 2 == 0 and 0.4 or -0.35)
                part.CFrame = CFrame.new(position) * CFrame.Angles(
                    math.rad(index * 18) + angle,
                    math.rad(index * 37) + angle,
                    math.rad(index * 22)
                )
            end
        end

        if groundCircle.Parent then
            groundCircle.CFrame = CFrame.new(
                position - Vector3.new(0, 2.7, 0)
            ) * CFrame.Angles(0, 0, math.rad(90))
        end
    end)

    table.insert(activeConnections, connection)

    task.wait(duration)

    for _, part in ipairs(domainRings) do
        if part.Parent then
            tween(part, 0.8, {
                Transparency = 1
            })
        end
    end

    for _, part in ipairs(effects:GetChildren()) do
        if part.Name == "DomainShell" or part.Name == "DomainGround" then
            tween(part, 0.8, {
                Transparency = 1
            })
        end
    end

    resetLighting()
end

local function teleportVisual()
    local r = root()
    if not r then
        return
    end

    local position = r.Position
    flash(position, COLORS.BlueLight, 7)

    for i = 1, 4 do
        local clone = sphere(
            "TeleportAfterimage",
            position + Vector3.new(0, i * 0.2, 0),
            2 + i * 0.3,
            i % 2 == 0 and COLORS.Blue or COLORS.Purple,
            0.55
        )

        tween(clone, 0.65, {
            Transparency = 1,
            Size = Vector3.new(4, 4, 4)
        })
    end

    particleBurst(position, COLORS.BlueLight, 18, 8, 0.5)
end

local function infinityShield()
    local r = root()
    if not r then
        return
    end

    local center = r.Position

    local shield = sphere("InfinityShield", center, 7, COLORS.Blue, 0.88)
    local rings = {}

    for i = 1, 3 do
        rings[i] = ring(
            "InfinityRing",
            center,
            3 + i * 1.2,
            0.12,
            i == 2 and COLORS.PurpleLight or COLORS.BlueLight,
            0.2,
            CFrame.Angles(math.rad(i * 35), math.rad(i * 50), math.rad(i * 25))
        )
    end

    local started = os.clock()
    local connection

    connection = RunService.Heartbeat:Connect(function()
        local currentRoot = root()

        if not currentRoot or not shield.Parent or os.clock() - started > 5 then
            connection:Disconnect()
            return
        end

        local position = currentRoot.Position

        shield.Position = position

        for i, part in ipairs(rings) do
            if part.Parent then
                part.CFrame = CFrame.new(position) * CFrame.Angles(
                    math.rad(i * 35) + os.clock() * (i % 2 == 0 and 0.8 or -0.7),
                    math.rad(i * 50),
                    math.rad(i * 25)
                )
            end
        end
    end)

    table.insert(activeConnections, connection)

    task.delay(4.5, function()
        if shield.Parent then
            tween(shield, 0.5, {
                Transparency = 1
            })
        end

        for _, part in ipairs(rings) do
            if part.Parent then
                tween(part, 0.5, {
                    Transparency = 1
                })
            end
        end
    end)
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(260, 360)
main.Position = UDim2.new(0, 20, 0.35, 0)
main.BackgroundColor3 = COLORS.Dark
main.BackgroundTransparency = 0.08
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.Purple
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.15
mainStroke.Parent = main

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(23, 25, 48)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -75, 1, 0)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "GOJO SKILLS  v" .. VERSION
title.TextColor3 = COLORS.White
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(32, 30)
minimize.Position = UDim2.new(1, -42, 0, 9)
minimize.BackgroundColor3 = Color3.fromRGB(55, 45, 90)
minimize.Text = "−"
minimize.TextColor3 = COLORS.White
minimize.TextSize = 22
minimize.Font = Enum.Font.GothamBold
minimize.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimize

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.fromOffset(10, 58)
content.Size = UDim2.new(1, -20, 1, -68)
content.BackgroundTransparency = 1
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, 0, 0, 25)
status.BackgroundTransparency = 1
status.Text = "R15  |  LOCAL DEMO"
status.TextColor3 = COLORS.BlueLight
status.TextSize = 11
status.Font = Enum.Font.GothamMedium
status.LayoutOrder = 0
status.Parent = content

local function createButton(text, color, order, callback)
    local button = Instance.new("TextButton")
    button.Name = text:gsub("%s+", "") .. "Button"
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = color
    button.BackgroundTransparency = 0.12
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.White
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.LayoutOrder = order
    button.AutoButtonColor = true
    button.Parent = content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = color:Lerp(COLORS.White, 0.35)
    stroke.Transparency = 0.55
    stroke.Thickness = 1
    stroke.Parent = button

    button.Activated:Connect(function()
        if busy then
            return
        end

        callback()
    end)

    return button
end

local function runSkill(name, callback)
    if busy then
        return
    end

    busy = true
    status.Text = name .. "  ·  CASTING"
    status.TextColor3 = COLORS.PurpleLight

    task.spawn(function()
        local success, err = pcall(callback)

        if not success then
            warn("Gojo Skills error:", err)
        end

        task.wait(0.4)

        busy = false

        if status.Parent then
            status.Text = "R15  |  LOCAL DEMO"
            status.TextColor3 = COLORS.BlueLight
        end
    end)
end

createButton("🔵  苍 · BLUE", COLORS.Blue, 1, function()
    runSkill("BLUE", blueSkill)
end)

createButton("🔴  赫 · RED", COLORS.Red, 2, function()
    runSkill("RED", redSkill)
end)

createButton("🟣  茈 · HOLLOW PURPLE", COLORS.Purple, 3, function()
    runSkill("HOLLOW PURPLE", purpleSkill)
end)

createButton("🌌  无量空处 · DOMAIN", Color3.fromRGB(65, 55, 130), 4, function()
    runSkill("UNLIMITED VOID", domainSkill)
end)

createButton("✨  瞬移视觉", Color3.fromRGB(35, 95, 135), 5, teleportVisual)

createButton("🛡️  无限护盾", Color3.fromRGB(40, 65, 125), 6, infinityShield)

createButton("🧹  清理本地特效", Color3.fromRGB(70, 45, 65), 7, function()
    actionToken += 1
    cleanupEffects()
    resetLighting()
    status.Text = "EFFECTS CLEARED"
end)

local dragging = false
local dragInput
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragInput and dragStart and startPosition then
        local delta = dragInput.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

minimize.Activated:Connect(function()
    minimized = not minimized

    content.Visible = not minimized
    main.Size = minimized and UDim2.fromOffset(260, 48) or UDim2.fromOffset(260, 360)
    minimize.Text = minimized and "+" or "−"
end)

gui.Destroying:Connect(function()
    cleanupEffects()
    resetLighting()
end)

player.CharacterAdded:Connect(function()
    cleanupEffects()
    resetLighting()
end)