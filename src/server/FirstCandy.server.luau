local candy = Instance.new("Part")

candy.Name = "PremierBonbon"
candy.Shape = Enum.PartType.Ball
candy.Size = Vector3.new(3, 3, 3)
candy.Position = Vector3.new(0, 5, 0)

candy.Color = Color3.fromRGB(255, 80, 160)
candy.Material = Enum.Material.Neon
candy.Anchored = true

candy.Parent = workspace

print("Candy Factory : premier bonbon créé !")