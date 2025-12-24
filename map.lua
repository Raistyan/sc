--====================================================--
-- 📍 SECTION 1: TELEPORT LOCATIONS
--====================================================--

local locationSection = mapTab:CreateSection({ Name = "Teleport Locations" })

-- daftar lokasi teleport
local teleportLocations = {
    ["Hutan Kuno"] = CFrame.new(1469.27, 7.63, -342.92),
    ["Ancient Ruin"] = CFrame.new(6075.24, -585.92, 4610.32),
    ["Terumbu Karang"] = CFrame.new(-2934.81, 2.75, 2113.44),
    ["Pulau Kawah"] = CFrame.new(1079.68, 4.71, 5044.67),
    ["Kedalaman Esoterik"] = CFrame.new(3259.52, -1300.83, 1377.87),
    ["Pulau Nelayan"] = CFrame.new(92.81, 9.53, 2762.08),
    ["Kohana"] = CFrame.new(-643.31, 16.04, 622.36),
    ["Gunung Berapi Kohana"] = CFrame.new(-595.02, 40.52, 152.29),
    ["Lost Isle"] = CFrame.new(-3712.02, 10.93, -1014.16),
    ["Kuil Suci"] = CFrame.new(1443.38, -22.13, -630.15),
    ["Patung Sisyphus (Keramat)"] = CFrame.new(-3651.51, -134.55, -925.15),
    ["Kamar Harta Karun"] = CFrame.new(-3569.58, -266.57, -1583.04),
    ["Hutan Tropis"] = CFrame.new(-2113.34, 6.78, 3700.81),
    ["Ruang Bawah Tanah"] = CFrame.new(2096.15, -91.20, -715.09),
    ["Mesin Cuaca (Lautan)"] = CFrame.new(-1513.92, 6.50, 1892.11),
    ["Pulau Natal"] = CFrame.new(1174.79, 23.43, 1551.83)
}

-- ambil semua nama lokasi
local locationNames = {}
for name, _ in pairs(teleportLocations) do
    table.insert(locationNames, name)
end

-- variabel lokasi terpilih
local selectedLocation = nil

-- dropdown pilih lokasi
locationSection:CreateDropdown({
    Name = "Pilih Lokasi",
    Options = locationNames,
    Callback = function(value)
        selectedLocation = value
        print("📍 Lokasi dipilih:", value)
    end
})

-- tombol teleport
locationSection:CreateButton({
    Name = "Teleport Sekarang",
    Callback = function()
        if not selectedLocation then
            print("⚠️ Pilih lokasi dulu sebelum teleport!")
            return
        end
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = teleportLocations[selectedLocation]
        print("✅ Teleport ke " .. selectedLocation .. " berhasil!")
    end
})


--====================================================--
-- 👤 TELEPORT TO PLAYER (FIXED FOR PRIVATE SERVER)
--====================================================--

local playerSection = mapTab:CreateSection({ Name = "Teleport To Player" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local selectedPlayer = nil

local function refreshPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.DisplayName)
        end
    end
    return #list > 0 and list or {"(No Players)"} -- SAFE RETURN
end

local tpDropdown = playerSection:CreateDropdown({
    Name = "Pilih Player",
    Options = {"Cari Player"}, -- DEFAULT AMAN
    Callback = function(value)
        selectedPlayer = value
        print("Target:", selectedPlayer)
    end
})

-- Update setelah UI ready
task.wait(0.5)
tpDropdown:Refresh(refreshPlayerList())

-- Auto refresh setiap 5 detik
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            tpDropdown:Refresh(refreshPlayerList())
        end)
    end
end)

playerSection:CreateButton({
    Name = "Teleport",
    Callback = function()
        if not selectedPlayer or selectedPlayer == "(Loading...)" or selectedPlayer == "(No Players)" then
            warn("❌ Pilih player valid!")
            return
        end

        local target = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.DisplayName == selectedPlayer then
                target = plr
                break
            end
        end

        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:MoveTo(target.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0))
            print("✅ Teleported to", target.DisplayName)
        else
            warn("❌ Player tidak valid")
        end
    end
})

--====================================================--
-- 🌊 SECTION 3: EVENT TELEPORT + WALK ON WATER
--====================================================--

local eventSection = mapTab:CreateSection({ Name = "Teleport Game Event" })

-- Services
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local workspace = game:GetService("Workspace")

-- Walk on Water Variables
local walkOnWaterEnabled = false
local waterPlatform = nil
local platformConnection = nil

-- Create invisible platform
local function createWaterPlatform()
    local platform = Instance.new("Part")
    platform.Name = "WaterPlatform"
    platform.Size = Vector3.new(10, 0.5, 10)
    platform.Transparency = 1
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.ForceField
    platform.Parent = workspace
    
    return platform
end

-- Walk on Water Function
local function setWalkOnWater(state)
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if state then
        -- Create platform if doesn't exist
        if not waterPlatform then
            waterPlatform = createWaterPlatform()
        end
        
        -- Start platform following
        if platformConnection then
            platformConnection:Disconnect()
        end
        
        platformConnection = RunService.Heartbeat:Connect(function()
            if not walkOnWaterEnabled then return end
            if not char or not char.Parent then return end
            
            local humanoid = char:FindFirstChild("Humanoid")
            if not humanoid then return end
            
            -- Position platform under player (water level)
            local waterLevel = -1.4 -- Game water level
            local platformY = waterLevel + 0.25 -- Slightly above water
            
            waterPlatform.Position = Vector3.new(
                hrp.Position.X,
                platformY,
                hrp.Position.Z
            )
        end)
        
        print("🌊 Walk on Water: ENABLED")
    else
        -- Disable platform
        if platformConnection then
            platformConnection:Disconnect()
            platformConnection = nil
        end
        
        if waterPlatform then
            waterPlatform:Destroy()
            waterPlatform = nil
        end
        
        print("💧 Walk on Water: DISABLED")
    end
end

-- Event Data
local Events = {
    ["Megalodon Hunt"] = {
        Keywords = {"megalodon"},
        Coords = {
            Vector3.new(-1076.3, -1.3999, 1676.19),
            Vector3.new(-1191.8, -1.3999, 3597.30),
            Vector3.new(412.7,  -1.3999, 4134.39)
        },
        Offset = Vector3.new(0, 0, -35)
    },

    ["Worm Hunt"] = {
        Keywords = {"worm"},
        Coords = {
            Vector3.new(2190.85, -1.3999, 97.5749),
            Vector3.new(-2450.6, -1.3999, 139.731),
            Vector3.new(-267.47,  -1.3999, 5188.53)
        },
        Offset = Vector3.new(0, 5, -25)
    },

    ["Ghost Shark Hunt"] = {
        Keywords = {"ghost"},
        Coords = {
            Vector3.new(489.558,  -1.35, 25.406),
            Vector3.new(-1358.2,  -1.35, 4100.55),
            Vector3.new(627.859,  -1.35, 3798.08)
        },
        Offset = Vector3.new(0, 5, -30)
    },

    ["Shark Hunt"] = {
        Keywords = {"shark"},
        Exclude = {"ghost"},
        Coords = {
            Vector3.new(1.64999,  -1.35, 2095.72),
            Vector3.new(1369.94,  -1.35, 930.125),
            Vector3.new(-1585.5,  -1.35, 1242.87),
            Vector3.new(-1896.8,  -1.35, 2634.37)
        },
        Offset = Vector3.new(0, 5, -30)
    }
}

-- Find Event Model Function
local function findEventModel(event)
    local data = Events[event]
    if not data then return nil end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name = string.lower(obj.Name)
            local valid = false

            for _, key in ipairs(data.Keywords) do
                if string.find(name, key) then
                    valid = true
                end
            end

            if data.Exclude then
                for _, ex in ipairs(data.Exclude) do
                    if string.find(name, ex) then
                        valid = false
                    end
                end
            end

            if valid then
                local part =
                    obj:FindFirstChild("HumanoidRootPart")
                    or obj.PrimaryPart
                    or obj:FindFirstChildWhichIsA("BasePart")

                if part then
                    return part
                end
            end
        end
    end
    return nil
end

-- Event UI
local options = {}
for name in pairs(Events) do table.insert(options, name) end
table.sort(options)

local selectedEvent
local currentPos

eventSection:CreateDropdown({
    Name = "Pilih Event",
    Options = options,
    Callback = function(v)
        selectedEvent = v
        currentPos = nil
    end
})

eventSection:CreateButton({
    Name = "🔄 Refresh Location",
    Callback = function()
        if not selectedEvent then return end
        local data = Events[selectedEvent]
        currentPos = data.Coords[math.random(#data.Coords)]
        warn("🔄", selectedEvent, "area refreshed")
    end
})

eventSection:CreateToggle({
    Name = "Teleport & Walk on Water",
    CurrentValue = false,
    Callback = function(state)
        if not selectedEvent then
            warn("❌ Pilih event dulu")
            return
        end

        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local data = Events[selectedEvent]

        if state then
            -- PRIORITY 1: MODEL
            local modelPart = findEventModel(selectedEvent)
            if modelPart then
                hrp.CFrame = modelPart.CFrame * CFrame.new(data.Offset)
                setWalkOnWater(true)
                walkOnWaterEnabled = true
                warn("🎯 Teleport + Walk on Water ke MODEL:", selectedEvent)
                return
            end

            -- FALLBACK: COORDS
            if not currentPos then
                warn("❌ Model belum spawn & area belum di-refresh")
                return
            end

            hrp.CFrame = CFrame.new(currentPos + data.Offset)
            setWalkOnWater(true)
            walkOnWaterEnabled = true
            warn("📍 Teleport + Walk on Water ke AREA:", selectedEvent)
        else
            -- TOGGLE OFF
            setWalkOnWater(false)
            walkOnWaterEnabled = false
            warn("🟢 Walk on Water OFF (jalan normal)")
        end
    end
})


--====================================================--
-- 🔄 AUTO CLEANUP ON RESPAWN
--====================================================--

-- ✅ Cleanup SEBELUM character removed (anti leak)
player.CharacterRemoving:Connect(function()
    if platformConnection then
        platformConnection:Disconnect()
        platformConnection = nil
    end
    if waterPlatform then
        waterPlatform:Destroy()
        waterPlatform = nil
    end
    walkOnWaterEnabled = false
end)

player.CharacterAdded:Connect(function(char)
    task.wait(1)
    
    -- Reset walk on water
    if walkOnWaterEnabled then
        setWalkOnWater(false)
        walkOnWaterEnabled = false
    end
end)

-- Cleanup on script unload
game:GetService("Players").PlayerRemoving:Connect(function(plr)
    if plr == player then
        if platformConnection then
            platformConnection:Disconnect()
        end
        if waterPlatform then
            waterPlatform:Destroy()
        end
    end
end)
