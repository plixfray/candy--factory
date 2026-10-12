
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PRICE = 50
local pendingCoins = 0

-- Création de l'usine
local factory = Instance.new("Model")
factory.Name = "CandyFactory"
factory.Parent = workspace

local function createPart(name, size, position, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.Parent = factory
    return p
end

local function createLabel(parent, text)
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.fromOffset(240, 60)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Text = text
    label.Parent = gui

    return label
end

-- Terrain et tapis roulant
createPart(
    "FactoryFloor",
    Vector3.new(40, 1, 24),
    Vector3.new(0, 0.5, 0),
    Color3.fromRGB(244, 211, 166)
)

createPart(
    "Conveyor",
    Vector3.new(22, 0.5, 5),
    Vector3.new(0, 1.5, 0),
    Color3.fromRGB(96, 59, 92),
    Enum.Material.Metal
)

-- Création des machines
local function createMachine(name, z, color, tankColor)
    createPart(
        name,
        Vector3.new(6, 6, 6),
        Vector3.new(-13, 4, z),
        color,
        Enum.Material.Metal
    )

    local tank = createPart(
        name .. "Tank",
        Vector3.new(4, 4, 4),
        Vector3.new(-13, 9, z),
        tankColor,
        Enum.Material.Glass
    )
    tank.Shape = Enum.PartType.Ball

    createPart(
        name .. "Outlet",
        Vector3.new(3, 2, 2),
        Vector3.new(-9.5, 4, z),
        tankColor,
        Enum.Material.Metal
    )
end

createMachine(
    "SugarMachine",
    0,
    Color3.fromRGB(235, 98, 166),
    Color3.fromRGB(255, 185, 70)
)

-- Tapis secondaire pour la future machine
createPart(
    "CaramelChute",
    Vector3.new(3, 0.5, 8),
    Vector3.new(-9, 1.5, 4),
    Color3.fromRGB(130, 83, 53),
    Enum.Material.Metal
)

-- Collecteur commun
local collector = createPart(
    "CandyCollector",
    Vector3.new(5, 2, 6),
    Vector3.new(13, 2, 0),
    Color3.fromRGB(96, 204, 159)
)

local collectorLabel = createLabel(collector, "A recolter : 0")

-- Argent du joueur
local function setupPlayer(player)
    local stats = player:FindFirstChild("leaderstats")

    if not stats then
        stats = Instance.new("Folder")
        stats.Name = "leaderstats"
        stats.Parent = player
    end

    local coins = stats:FindFirstChild("Coins")

    if not coins then
        coins = Instance.new("IntValue")
        coins.Name = "Coins"
        coins.Value = 0
        coins.Parent = stats
    end
end

Players.PlayerAdded:Connect(setupPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

-- Récolte
local collectPrompt = Instance.new("ProximityPrompt")
collectPrompt.ActionText = "Recolter"
collectPrompt.ObjectText = "Bonbons"
collectPrompt.MaxActivationDistance = 10
collectPrompt.Parent = collector

collectPrompt.Triggered:Connect(function(player)
    local stats = player:FindFirstChild("leaderstats")
    local coins = stats and stats:FindFirstChild("Coins")

    if not coins or pendingCoins <= 0 then
        return
    end

    coins.Value += pendingCoins
    pendingCoins = 0
    collectorLabel.Text = "A recolter : 0"
end)

-- Déplacement animé des bonbons
local function moveCandy(candy, destination, duration)
    local tween = TweenService:Create(
        candy,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Position = destination}
    )

    tween:Play()
    tween.Completed:Wait()
end

-- Production d'un bonbon
local function produceCandy(color, value, z)
    local candy = Instance.new("Part")
    candy.Name = "Candy"
    candy.Shape = Enum.PartType.Ball
    candy.Size = Vector3.new(1.5, 1.5, 1.5)
    candy.Position = Vector3.new(-9, 2.5, z)
    candy.Color = color
    candy.Material = Enum.Material.Neon
    candy.Anchored = true
    candy.CanCollide = false
    candy.Parent = factory

    if z ~= 0 then
        moveCandy(candy, Vector3.new(-9, 2.5, 0), 1.6)
    end

    moveCandy(candy, Vector3.new(10, 2.5, 0), 4)

    pendingCoins += value
    collectorLabel.Text = "A recolter : " .. pendingCoins

    candy:Destroy()
end

-- Boucle de production d'une machine
local function startProduction(color, value, interval, z)
    task.spawn(function()
        while factory.Parent do
            task.spawn(produceCandy, color, value, z)
            task.wait(interval)
        end
    end)
end

-- Machine de départ : 5 pièces / 3 secondes
startProduction(
    Color3.fromRGB(255, 80, 160),
    5,
    3,
    0
)

-- Boutique de la machine à caramel
local shop = createPart(
    "CaramelShop",
    Vector3.new(6, 1, 5),
    Vector3.new(7, 1.5, 8),
    Color3.fromRGB(165, 104, 211)
)

local shopLabel = createLabel(shop, "Machine Caramel : 50 pieces")

local buyPrompt = Instance.new("ProximityPrompt")
buyPrompt.ActionText = "Acheter"
buyPrompt.ObjectText = "Machine Caramel - 50 pieces"
buyPrompt.MaxActivationDistance = 10
buyPrompt.Parent = shop

local purchased = false

buyPrompt.Triggered:Connect(function(player)
    if purchased then
        return
    end

    local stats = player:FindFirstChild("leaderstats")
    local coins = stats and stats:FindFirstChild("Coins")

    if not coins then
        return
    end

    if coins.Value < PRICE then
        shopLabel.Text = "Il faut 50 pieces !"

        task.delay(2, function()
            if not purchased then
                shopLabel.Text = "Machine Caramel : 50 pieces"
            end
        end)
        return
    end

    -- Paiement validé sur le serveur
    coins.Value -= PRICE
    purchased = true
    buyPrompt.Enabled = false

    shop.Color = Color3.fromRGB(96, 204, 159)
    shopLabel.Text = "Machine Caramel debloquee !"

    -- Apparition de la nouvelle machine
    createMachine(
        "CaramelMachine",
        8,
        Color3.fromRGB(181, 106, 57),
        Color3.fromRGB(255, 197, 85)
    )

    -- Production : 20 pièces / 5 secondes
    startProduction(
        Color3.fromRGB(150, 75, 35),
        20,
        5,
        8
    )
end)
