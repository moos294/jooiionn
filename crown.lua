local VERSION = "1.3"
local GUI_NAME = "GojoSkillUI"
local EFFECT_NAME = "GojoSkillEffects"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

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

local COLORS = {
    Blue = Color3.fromRGB(45, 145, 255),
    BlueLight = Color3.fromRGB(170, 230, 255),
    Red = Color3.fromRGB(255, 55, 85),
    Purple = Color3.fromRGB(150, 65, 255),
    PurpleLight = Color3.fromRGB(225, 185, 255),
    White = Color3.fromRGB(245, 250, 255),
    Dark = Color3.fromRGB(12, 15, 30)
}

local busy = false
local minimized = false
local destroyed = false
local activeTweens = {}
local activeConnections = {}
local savedLighting
local domainEffect
local actionId = 0

local function addTween(instance, duration, properties, style, direction)
    if not instance or not instance.Parent then
        return
    end

    local animation = TweenService:Create(
        instance,
        TweenInfo.new(
            duration,
            style or Enum.EasingStyle.Quad,
            direction or Enum.EasingDirection.Out
        ),
        properties
    )

    activeTweens[#activeTweens + 1] = animation
    animation:Play()

    return animation
end

local function addConnection(connection)
    activeConnections[#activeConnections + 1] = connection
    return connection
end

local function getCharacter()
    return player.Character
end

local function getRoot()
    local model = getCharacter()
    return model and model:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local model = getCharacter()
    return model and model:FindFirstChildOfClass("Humanoid")
end

local function getHand()
    local model = getCharacter()
    if not model then
        return nil
    end

    return model:FindFirstChild("RightHand")
        or model:FindFirstChild("Right Arm")
        or model:FindFirstChild("HumanoidRootPart")
end

local function forwardPosition(distance, height)
    local root = getRoot()
    if not root then
        return nil
    end

    return root.Position
        + root.CFrame.LookVector * distance
        + Vector3.new(0, height or 2, 0)
end

local function createPart(name, size, cframe, color, material, transparency, shape)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.Neon
    part.Transparency = transparency or 0
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Shape = shape or Enum.PartType.Block
    part.Parent = effects

    return part
end

local function createSphere(name, position, size, color, transparency)
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

local function createRing(name, position, radius, thickness, color, transparency, rotation)
    return createPart(
        name,
        Vector3.new(thickness, radius * 2, radius * 2),
        CFrame.new(position)
            * (rotation or CFrame.Angles(0, 0, math.rad(90))),
        color,
        Enum.Material.Neon,
        transparency or 0.1,
        Enum.PartType.Cylinder
    )
end

local function addLight(part, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Parent = part
    return light
end

local function createFlash(position, color, size)
    local flash = createSphere("EnergyFlash", position, 0.5, color, 0.1)
    addLight(flash, color, 4, size * 2)

    addTween(flash, 0.2, {
        Size = Vector3.new(size, size, size),
        Transparency = 0.65
    })

    task.delay(0.22, function()
        if flash.Parent then
            addTween(flash, 0.35, {
                Size = Vector3.new(size * 1.5, size * 1.5, size * 1.5),
                Transparency = 1
            })
        end
    end)

    return flash
end

local function createParticles(position, color, count, spread, size)
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

        local particle = createSphere(
            "EnergyParticle",
            position,
            math.random(5, 12) / 10 * size,
            color,
            0.05
        )

        local distance = math.random(50, 100) / 100 * spread

        addTween(particle, math.random(6, 13) / 10, {
            Position = position + direction * distance,
            Transparency = 1,
            Size = Vector3.new(0.03, 0.03, 0.03)
        }, Enum.EasingStyle.Quint)
    end
end

local function createBeam(startPosition, endPosition, color, thickness, transparency)
    local distance = (endPosition - startPosition).Magnitude
    local midpoint = (startPosition + endPosition) / 2

    return createPart(
        "EnergyBeam",
        Vector3.new(thickness, thickness, distance),
        CFrame.lookAt(midpoint, endPosition),
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
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(activeConnections)

    if effects and effects.Parent then
        effects:ClearAllChildren()
    end
end

local function restoreLighting()
    if domainEffect then
        domainEffect:Destroy()
        domainEffect = nil
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

local function clearAll()
    actionId += 1
    cleanupEffects()
    restoreLighting()
    busy = false
end

local function playPose(kind, duration)
    local model = getCharacter()
    if not model then
        return
    end

    local poses = {
        Blue = {
            RightShoulder = CFrame.Angles(math.rad(-65), 0, math.rad(35)),
            LeftShoulder = CFrame.Angles(math.rad(-25), 0, math.rad(-15)),
            Neck = CFrame.Angles(math.rad(-8), 0, 0)
        },
        Red = {
            RightShoulder = CFrame.Angles(math.rad(-60), 0, math.rad(40)),
            LeftShoulder = CFrame.Angles(math.rad(-60), 0, math.rad(-40)),
            Neck = CFrame.Angles(math.rad(-5), 0, 0)
        },
        Purple = {
            RightShoulder = CFrame.Angles(math.rad(-75), 0, math.rad(35)),
            LeftShoulder = CFrame.Angles(math.rad(-75), 0, math.rad(-35)),
            Neck = CFrame.Angles(math.rad(-10), 0, 0)
        },
        Domain = {
            RightShoulder = CFrame.Angles(math.rad(-85), 0, math.rad(25)),
            LeftShoulder = CFrame.Angles(math.rad(-85), 0, math.rad(-25)),
            Neck = CFrame.Angles(math.rad(-12), 0, 0),
            Waist = CFrame.Angles(math.rad(-5), 0, 0)
        }
    }

    local selected = poses[kind]
    if not selected then
        return
    end

    local thisAction = actionId
    local motors = {}

    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("Motor6D") and selected[object.Name] then
            local data = {
                Motor = object,
                Original = object.Transform
            }

            motors[#motors + 1] = data

            addTween(object, 0.25, {
                Transform = selected[object.Name]
            }, Enum.EasingStyle.Sine)
        end
    end

    task.delay(duration, function()
        if thisAction ~= actionId then
            return
        end

        for _, data in ipairs(motors) do
            if data.Motor.Parent then
                addTween(data.Motor, 0.35, {
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

    playPose("Blue", 2.2)

    local core = createSphere("BlueCore", position, 0.5, COLORS.BlueLight)
    addLight(core, COLORS.Blue, 4, 20)

    local rings = {
        createRing("BlueRingA", position, 2, 0.12, COLORS.BlueLight),
        createRing("BlueRingB", position, 3, 0.12, COLORS.Blue, 0.15,
            CFrame.Angles(0, math.rad(60), math.rad(35))),
        createRing("BlueRingC", position, 1.5, 0.1, COLORS.White, 0.15,
            CFrame.Angles(math.rad(45), 0, math.rad(20)))
    }

    addTween(core, 0.8, {
        Size = Vector3.new(3, 3, 3)
    })

    for index, part in ipairs(rings) do
        addTween(part, 0.9, {
            Size = Vector3.new(0.12, 7 + index * 2, 7 + index * 2)
        })
    end

    createParticles(position, COLORS.BlueLight, 22, 9, 0.6)

    task.delay(1, function()
        if core.Parent then
            addTween(core, 0.4, {
                Size = Vector3.new(5, 5, 5),
                Transparency = 1
            })
        end

        for _, part in ipairs(rings) do
            if part.Parent then
                addTween(part, 0.4, {
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

    playPose("Red", 2.4)

    local core = createSphere("RedCore", position, 0.5, COLORS.Red)
    addLight(core, COLORS.Red, 5, 22)

    local ringA = createRing("RedRingA", position, 1.8, 0.15, COLORS.Red)
    local ringB = createRing("RedRingB", position, 2.8, 0.12, COLORS.White, 0.2,
        CFrame.Angles(0, math.rad(40), math.rad(30)))

    addTween(core, 0.75, {
        Size = Vector3.new(3.2, 3.2, 3.2)
    })

    addTween(ringA, 0.8, {
        Size = Vector3.new(0.15, 8, 8)
    })

    addTween(ringB, 0.8, {
        Size = Vector3.new(0.12, 12, 12)
    })

    task.delay(0.8, function()
        createFlash(position, COLORS.Red, 10)
        createParticles(position, COLORS.Red, 32, 14, 0.7)

        for _, part in ipairs({core, ringA, ringB}) do
            if part.Parent then
                addTween(part, 0.4, {
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

    playPose("Purple", 4.5)

    local bluePosition = origin + Vector3.new(-3, 0, 0)
    local redPosition = origin + Vector3.new(3, 0, 0)

    local blue = createSphere("PurpleBlueOrb", bluePosition, 0.5, COLORS.Blue)
    local red = createSphere("PurpleRedOrb", redPosition, 0.5, COLORS.Red)

    addLight(blue, COLORS.BlueLight, 3, 14)
    addLight(red, COLORS.Red, 3, 14)

    local blueRing = createRing("PurpleBlueRing", bluePosition, 1.4, 0.12, COLORS.BlueLight)
    local redRing = createRing("PurpleRedRing", redPosition, 1.4, 0.12, COLORS.Red)

    addTween(blue, 0.7, {
        Position = origin + Vector3.new(-1.2, 0.5, 0),
        Size = Vector3.new(2.4, 2.4, 2.4)
    })

    addTween(red, 0.7, {
        Position = origin + Vector3.new(1.2, -0.5, 0),
        Size = Vector3.new(2.4, 2.4, 2.4)
    })

    addTween(blueRing, 0.7, {
        Position = origin + Vector3.new(-1.2, 0.5, 0),
        Size = Vector3.new(0.12, 5, 5)
    })

    addTween(redRing, 0.7, {
        Position = origin + Vector3.new(1.2, -0.5, 0),
        Size = Vector3.new(0.12, 5, 5)
    })

    task.wait(0.75)

    local center = origin

    addTween(blue, 0.45, {
        Position = center,
        Color = COLORS.Purple,
        Size = Vector3.new(2.8, 2.8, 2.8)
    })

    addTween(red, 0.45, {
        Position = center,
        Color = COLORS.PurpleLight,
        Size = Vector3.new(2.8, 2.8, 2.8)
    })

    addTween(blueRing, 0.45, {
        Position = center
    })

    addTween(redRing, 0.45, {
        Position = center
    })

    task.wait(0.5)

    for _, part in ipairs({blue, red, blueRing, redRing}) do
        if part.Parent then
            part:Destroy()
        end
    end

    local core = createSphere("HollowPurpleCore", center, 1, COLORS.PurpleLight)
    addLight(core, COLORS.Purple, 7, 32)

    local rings = {}

    for index = 1, 4 do
        rings[index] = createRing(
            "PurpleFusionRing",
            center,
            2 + index,
            0.15,
            index % 2 == 0 and COLORS.PurpleLight or COLORS.Purple,
            0.1,
            CFrame.Angles(
                math.rad(index * 35),
                math.rad(index * 45),
                math.rad(index * 25)
            )
        )

        addTween(rings[index], 0.5, {
            Size = Vector3.new(0.15, 10 + index * 2, 10 + index * 2)
        })
    end

    addTween(core, 0.5, {
        Size = Vector3.new(5, 5, 5)
    })

    createFlash(center, COLORS.PurpleLight, 14)
    createParticles(center, COLORS.Purple, 36, 15, 0.8)

    task.wait(0.55)

    local currentRoot = getRoot()
    if not currentRoot then
        return
    end

    local direction = currentRoot.CFrame.LookVector
    local destination = center + direction * 60

    local projectile = createSphere("HollowPurpleProjectile", center, 3.5, COLORS.Purple)
    addLight(projectile, COLORS.PurpleLight, 8, 35)

    local projectileRing = createRing("HollowPurpleProjectileRing", center, 4, 0.15, COLORS.PurpleLight)

    addTween(projectile, 1.1, {
        Position = destination,
        Size = Vector3.new(8, 8, 8)
    }, Enum.EasingStyle.Linear)

    addTween(projectileRing, 1.1, {
        Position = destination,
        Size = Vector3.new(0.15, 15, 15)
    }, Enum.EasingStyle.Linear)

    createBeam(center, center + direction * 30, COLORS.Purple, 2, 0.35)

    task.wait(1.1)

    createFlash(destination, COLORS.PurpleLight, 22)
    createParticles(destination, COLORS.Purple, 40, 24, 1)

    for _, part in ipairs({core, projectile, projectileRing}) do
        if part.Parent then
            addTween(part, 0.35, {
                Transparency = 1
            })
        end
    end

    for _, part in ipairs(rings) do
        if part.Parent then
            addTween(part, 0.35, {
                Transparency = 1
            })
        end
    end
end

local function domainSkill()
    local rootPart = getRoot()
    if not rootPart then
        return
    end

    playPose("Domain", 7)

    savedLighting = {
        ClockTime = Lighting.ClockTime,
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor
    }

    domainEffect = Instance.new("ColorCorrectionEffect")
    domainEffect.Name = "GojoDomainColor"
    domainEffect.TintColor = COLORS.White
    domainEffect.Contrast = 0
    domainEffect.Saturation = 0
    domainEffect.Brightness = 0
    domainEffect.Parent = Lighting

    addTween(domainEffect, 0.8, {
        TintColor = Color3.fromRGB(155, 165, 255),
        Contrast = 0.25,
        Saturation = -0.3,
        Brightness = -0.05
    })

    local center = rootPart.Position
    local groundPosition = center - Vector3.new(0, 2.7, 0)

    local ground = createPart(
        "DomainGround",
        Vector3.new(0.15, 2, 2),
        CFrame.new(groundPosition) * CFrame.Angles(0, 0, math.rad(90)),
        COLORS.Purple,
        Enum.Material.Neon,
        0.3,
        Enum.PartType.Cylinder
    )

    addTween(ground, 1.2, {
        Size = Vector3.new(0.15, 65, 65)
    }, Enum.EasingStyle.Quint)

    local domainRings = {}

    for index = 1, 8 do
        local radius = 7 + index * 3.5

        local part = createRing(
            "DomainSpaceRing",
            center,
            radius,
            0.12,
            index % 2 == 0 and COLORS.BlueLight or COLORS.Purple,
            0.3,
            CFrame.Angles(
                math.rad(index * 18),
                math.rad(index * 37),
                math.rad(index * 22)
            )
        )

        domainRings[#domainRings + 1] = part

        addTween(part, 1.4, {
            Size = Vector3.new(0.12, radius * 2.3, radius * 2.3),
            Transparency = 0.12
        }, Enum.EasingStyle.Quint)
    end

    local shell = createSphere("DomainShell", center, 4, COLORS.Purple, 0.92)
    addTween(shell, 1.5, {
        Size = Vector3.new(90, 90, 90),
        Transparency = 0.94
    }, Enum.EasingStyle.Quint)

    createFlash(center, COLORS.BlueLight, 16)
    createParticles(center, COLORS.PurpleLight, 40, 25, 0.7)

    for index = 1, 28 do
        local angle = index / 28 * math.pi * 2
        local radius = math.random(10, 38)

        local position = center + Vector3.new(
            math.cos(angle) * radius,
            math.random(-18, 18),
            math.sin(angle) * radius
        )

        local star = createSphere(
            "DomainStar",
            position,
            math.random(3, 7) / 10,
            index % 2 == 0 and COLORS.BlueLight or COLORS.PurpleLight,
            0.15
        )

        addTween(star, math.random(8, 18) / 10, {
            Position = position + Vector3.new(0, math.random(5, 18), 0),
            Transparency = 1
        })
    end

    for index = 1, 16 do
        local angle = index / 16 * math.pi * 2

        local a = center + Vector3.new(
            math.cos(angle) * 22,
            math.random(-12, 12),
            math.sin(angle) * 22
        )

        local b = center + Vector3.new(
            math.cos(angle + 0.25) * 36,
            math.random(-15, 15),
            math.sin(angle + 0.25) * 36
        )

        createBeam(a, b, COLORS.PurpleLight, 0.12, 0.3)
    end

    local started = os.clock()
    local duration = 6

    local connection = RunService.Heartbeat:Connect(function()
        if not effects.Parent then
            return
        end

        local elapsed = os.clock() - started

        if elapsed >= duration then
            return
        end

        local currentRoot = getRoot()
        if not currentRoot then
            return
        end

        local position = currentRoot.Position

        for index, part in ipairs(domainRings) do
            if part.Parent then
                local rotation = elapsed * (index % 2 == 0 and 0.45 or -0.35)

                part.CFrame = CFrame.new(position) * CFrame.Angles(
                    math.rad(index * 18) + rotation,
                    math.rad(index * 37) + rotation,
                    math.rad(index * 22)
                )
            end
        end

        if ground.Parent then
            ground.CFrame = CFrame.new(
                position - Vector3.new(0, 2.7, 0)
            ) * CFrame.Angles(0, 0, math.rad(90))
        end

        if shell.Parent then
            shell.Position = position
        end
    end)

    addConnection(connection)

    task.wait(duration)

    for _, part in ipairs(domainRings) do
        if part.Parent then
            addTween(part, 0.8, {
                Transparency = 1
            })
        end
    end

    for _, part in ipairs(effects:GetChildren()) do
        if part.Name == "DomainShell" or part.Name == "DomainGround" then
            addTween(part, 0.8, {
                Transparency = 1
            })
        end
    end

    restoreLighting()
end

local function teleportVisual()
    local rootPart = getRoot()
    if not rootPart then
        return
    end

    local position = rootPart.Position

    createFlash(position, COLORS.BlueLight, 7)

    for index = 1, 4 do
        local afterimage = createSphere(
            "TeleportAfterimage",
            position + Vector3.new(0, index * 0.2, 0),
            2 + index * 0.3,
            index % 2 == 0 and COLORS.Blue or COLORS.Purple,
            0.55
        )

        addTween(afterimage, 0.65, {
            Transparency = 1,
            Size = Vector3.new(4, 4, 4)
        })
    end

    createParticles(position, COLORS.BlueLight, 18, 8, 0.5)
end

local function infinityShield()
    local rootPart = getRoot()
    if not rootPart then
        return
    end

    local shield = createSphere(
        "InfinityShield",
        rootPart.Position,
        7,
        COLORS.Blue,
        0.88
    )

    local rings = {}

    for index = 1, 3 do
        rings[index] = createRing(
            "InfinityRing",
            rootPart.Position,
            3 + index * 1.2,
            0.12,
            index == 2 and COLORS.PurpleLight or COLORS.BlueLight,
            0.2,
            CFrame.Angles(
                math.rad(index * 35),
                math.rad(index * 50),
                math.rad(index * 25)
            )
        )
    end

    local started = os.clock()

    local connection = RunService.Heartbeat:Connect(function()
        local currentRoot = getRoot()

        if not currentRoot or not shield.Parent or os.clock() - started > 4.5 then
            return
        end

        local position = currentRoot.Position
        shield.Position = position

        for index, part in ipairs(rings) do
            if part.Parent then
                part.CFrame = CFrame.new(position) * CFrame.Angles(
                    math.rad(index * 35) + os.clock() * (index % 2 == 0 and 0.8 or -0.7),
                    math.rad(index * 50),
                    math.rad(index * 25)
                )
            end
        end
    end)

    addConnection(connection)

    task.delay(4.5, function()
        if shield.Parent then
            addTween(shield, 0.5, {
                Transparency = 1
            })
        end

        for _, part in ipairs(rings) do
            if part.Parent then
                addTween(part, 0.5, {
                    Transparency = 1
                })
            end
        end
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(230, 300)
main.Position = UDim2.new(0, 16, 0.35, 0)
main.BackgroundColor3 = COLORS.Dark
main.BackgroundTransparency = 0.06
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.Purple
mainStroke.Thickness = 1.3
mainStroke.Transparency = 0.15
mainStroke.Parent = main

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(23, 25, 48)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -65, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "GOJO  v" .. VERSION
title.TextColor3 = COLORS.White
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(28, 26)
minimize.Position = UDim2.new(1, -36, 0, 7)
minimize.BackgroundColor3 = Color3.fromRGB(55, 45, 90)
minimize.Text = "−"
minimize.TextColor3 = COLORS.White
minimize.TextSize = 20
minimize.Font = Enum.Font.GothamBold
minimize.Parent = header

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 7)
minimizeCorner.Parent = minimize

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.fromOffset(8, 46)
content.Size = UDim2.new(1, -16, 1, -52)
content.BackgroundTransparency = 1
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, 0, 0, 20)
status.BackgroundTransparency = 1
status.Text = "R15  |  LOCAL DEMO"
status.TextColor3 = COLORS.BlueLight
status.TextSize = 10
status.Font = Enum.Font.GothamMedium
status.LayoutOrder = 0
status.Parent = content

local function createButton(text, color, order, callback)
    local button = Instance.new("TextButton")
    button.Name = "SkillButton" .. order
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = color
    button.BackgroundTransparency = 0.1
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.White
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.LayoutOrder = order
    button.AutoButtonColor = true
    button.Parent = content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = color:Lerp(COLORS.White, 0.35)
    stroke.Transparency = 0.6
    stroke.Thickness = 1
    stroke.Parent = button

    button.Activated:Connect(function()
        if busy or destroyed then
            return
        end

        callback()
    end)

    return button
end

local function runSkill(name, callback)
    if busy or destroyed then
        return
    end

    busy = true
    status.Text = name .. "  |  CASTING"
    status.TextColor3 = COLORS.PurpleLight

    task.spawn(function()
        local success, err = pcall(callback)

        if not success then
            warn("Gojo Skills:", err)
        end

        if not destroyed and status.Parent then
            busy = false
            status.Text = "R15  |  LOCAL DEMO"
            status.TextColor3 = COLORS.BlueLight
        end
    end)
end

createButton("BLUE  |  苍", COLORS.Blue, 1, function()
    runSkill("BLUE", blueSkill)
end)

createButton("RED  |  赫", COLORS.Red, 2, function()
    runSkill("RED", redSkill)
end)

createButton("HOLLOW PURPLE  |  茈", COLORS.Purple, 3, function()
    runSkill("HOLLOW PURPLE", purpleSkill)
end)

createButton("UNLIMITED VOID  |  领域", Color3.fromRGB(65, 55, 130), 4, function()
    runSkill("UNLIMITED VOID", domainSkill)
end)

createButton("瞬移视觉", Color3.fromRGB(35, 95, 135), 5, teleportVisual)

createButton("无限护盾", Color3.fromRGB(40, 65, 125), 6, infinityShield)

createButton("清理特效", Color3.fromRGB(85, 45, 65), 7, function()
    clearAll()
    status.Text = "EFFECTS CLEARED"
    status.TextColor3 = COLORS.White
end)

local dragging = false
local dragStart
local startPosition
local dragInput

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

addConnection(UserInputService.InputChanged:Connect(function(input)
    if dragging and dragStart and startPosition then
        if input == dragInput
            or input.UserInputType == Enum.UserInputType.MouseMovement then

            local delta = input.Position - dragStart

            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end
end))

minimize.Activated:Connect(function()
    minimized = not minimized
    content.Visible = not minimized

    main.Size = minimized
        and UDim2.fromOffset(230, 40)
        or UDim2.fromOffset(230, 300)

    minimize.Text = minimized and "+" or "−"
end)

gui.Destroying:Connect(function()
    destroyed = true
    clearAll()
end)

player.CharacterAdded:Connect(function()
    clearAll()
end)