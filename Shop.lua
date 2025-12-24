--====================================================--
-- 🛒 SHOP - BUY ROD (UI SAFE)
--====================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

--====================================================--
-- 🔗 NET REMOTES (BENAR)
--====================================================--

local Net = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local PurchaseRod = Net:WaitForChild("RF/PurchaseFishingRod")
local EquipItem = Net:WaitForChild("RE/EquipItem")

--====================================================--
-- 📦 DATA ROD
--====================================================--

local Rods = {
    {Name="Carbon Rod",Id=76,Price=750},
    {Name="Grass Rod",Id=85,Price=1500},
    {Name="Demascus Rod",Id=77,Price=3000},
    {Name="Ice Rod",Id=78,Price=5000},
    {Name="Lucky Rod",Id=4,Price=15000},
    {Name="Midnight Rod",Id=80,Price=50000},
    {Name="Steampunk Rod",Id=6,Price=215000},
    {Name="Chrome Rod",Id=7,Price=437000},
    {Name="Fluorescent Rod",Id=255,Price=715000},
    {Name="Astral Rod",Id=5,Price=1000000},
    {Name="Ares Rod",Id=126,Price=3000000},
    {Name="Angler Rod",Id=168,Price=8000000},
    {Name="Bamboo Rod",Id=258,Price=12000000},
}

--====================================================--
-- 🧠 UTIL
--====================================================--

local function HasRod(name)
    local inv = player:FindFirstChild("Rods")
    return inv and inv:FindFirstChild(name)
end

local function FormatPrice(p)
    if p >= 1e6 then
        return (p/1e6).."m"
    elseif p >= 1e3 then
        return (p/1e3).."k"
    end
    return tostring(p)
end

--====================================================--
-- 🛒 UI
--====================================================--

local shopSection = shopTab:CreateSection({
    Name = "Buy Fishing Rod"
})

local dropdownList = {}
local rodByLabel = {}
local selectedLabel

for _, rod in ipairs(Rods) do
    local owned = HasRod(rod.Name)
    local label = rod.Name.." ("..FormatPrice(rod.Price)..")"
    if owned then
        label ..= " ✔"
    end

    dropdownList[#dropdownList+1] = label
    rodByLabel[label] = rod
end

shopSection:CreateDropdown({
    Name = "Select Rod",
    Options = dropdownList,
    Callback = function(v)
        selectedLabel = v
    end
})

shopSection:CreateButton({
    Name = "Buy Selected Rod",
    Callback = function()
        if not selectedLabel then return end

        local rod = rodByLabel[selectedLabel]
        if not rod then return end

        if HasRod(rod.Name) then
            warn("Rod already owned")
            return
        end

        PurchaseRod:InvokeServer(rod.Id)

        task.delay(0.4, function()
            EquipItem:FireServer(rod.Id, "Fishing Rods")
        end)
    end
})


--====================================================--
-- 🪱 BUY BAIT SYSTEM (FIXED & SAFE)
--====================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- 🔗 REMOTES (VALID DARI RSPY)
local Net = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local PurchaseBait = Net:WaitForChild("RF/PurchaseBait")
local EquipBait = Net:WaitForChild("RE/EquipBait")

--====================================================--
-- 📦 BAIT DATA
--====================================================--

local Baits = {
    {Name="Luck Bait", Id=2, Price=1000},
    {Name="Nature Bait", Id=17, Price=83500},
    {Name="Chroma Bait", Id=6, Price=290000},
    {Name="Dark Matter Bait", Id=8, Price=630000},
    {Name="Corrupt Bait", Id=15, Price=1148484},
    {Name="Aether Bait", Id=16, Price=3700000},
    {Name="Floral Bait", Id=20, Price=4000000},
}

--====================================================--
-- 🧠 UTIL
--====================================================--

local function FormatPrice(price)
    if price >= 1_000_000 then
        return string.format("%.1fm", price / 1_000_000):gsub("%.0","")
    elseif price >= 1_000 then
        return string.format("%.1fk", price / 1_000):gsub("%.0","")
    else
        return tostring(price)
    end
end

--====================================================--
-- 🛒 UI (PAKAI SHOP TAB YANG SUDAH ADA)
--====================================================--

local baitSection = shopTab:CreateSection({
    Name = "Buy Bait"
})

local BaitMap = {}
local DropdownList = {}

for _, bait in ipairs(Baits) do
    local label = bait.Name .. " (" .. FormatPrice(bait.Price) .. ")"
    DropdownList[#DropdownList+1] = label
    BaitMap[label] = bait
end

local SelectedBait = nil

baitSection:CreateDropdown({
    Name = "Select Bait",
    Options = DropdownList, -- ⚠️ STRING ONLY (ANTI ERROR)
    Callback = function(value)
        SelectedBait = BaitMap[value]
    end
})

baitSection:CreateButton({
    Name = "Buy & Equip Bait",
    Callback = function()
        if not SelectedBait then
            warn("No bait selected")
            return
        end

        -- 💰 BUY
        local success, result = pcall(function()
            return PurchaseBait:InvokeServer(SelectedBait.Id)
        end)

        if success then
            -- 🎣 AUTO EQUIP
            EquipBait:FireServer(SelectedBait.Id)
            print("✅ Bought & equipped:", SelectedBait.Name)
        else
            warn("❌ Failed to buy bait")
        end
    end
})

--====================================================--
-- ✅ END BUY BAIT
--====================================================--

--====================================================--
-- 🗿 TOTEM SHOP SYSTEM (NO PRICE VERSION)
--====================================================--

local totemSection = shopTab:CreateSection({
    Name = "Buy Totems"
})

--====================================================--
-- 📊 TOTEM DATA
--====================================================--

local Totems = {
    {Name = "Luck Totem", Id = 5, Icon = "rbxassetid://85563171162845"},
    {Name = "Mutation Totem", Id = 6, Icon = "rbxassetid://120458051113475"},
    {Name = "Shiny Totem", Id = 7, Icon = "rbxassetid://71168469297686"}
}

--====================================================--
-- 🔗 REMOTE
--====================================================--

local PurchaseMarketItem = Net:WaitForChild("RF/PurchaseMarketItem")

--====================================================--
-- 🛒 MANUAL BUY SYSTEM
--====================================================--

local selectedTotem = nil
local totemDropdownList = {}
local totemByLabel = {}

-- Build dropdown list
for _, totem in ipairs(Totems) do
    table.insert(totemDropdownList, totem.Name)
    totemByLabel[totem.Name] = totem
end

-- Dropdown untuk pilih totem
totemSection:CreateDropdown({
    Name = "Select Totem",
    Options = totemDropdownList,
    Callback = function(value)
        selectedTotem = totemByLabel[value]
        if selectedTotem then
            print("🗿 Selected:", selectedTotem.Name)
        end
    end
})

-- Button beli totem
totemSection:CreateButton({
    Name = "Buy Selected Totem",
    Callback = function()
        if not selectedTotem then
            warn("❌ Pilih totem dulu!")
            return
        end
        
        local success, result = pcall(function()
            return PurchaseMarketItem:InvokeServer(selectedTotem.Id)
        end)
        
        if success then
            print("✅ Bought:", selectedTotem.Name)
            
            -- Visual notification
            local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
            gui.Name = "TotemNotify"
            
            local label = Instance.new("TextLabel", gui)
            label.Size = UDim2.new(0, 300, 0, 50)
            label.Position = UDim2.new(0.5, -150, 0.8, 0)
            label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            label.TextColor3 = Color3.fromRGB(255, 215, 0)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 20
            label.Text = "🗿 " .. selectedTotem.Name .. " Purchased!"
            label.BackgroundTransparency = 1
            
            TweenService:Create(label, TweenInfo.new(0.4), {BackgroundTransparency = 0.3}):Play()
            task.wait(2.5)
            TweenService:Create(label, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            task.wait(0.5)
            gui:Destroy()
        else
            warn("❌ Failed to buy totem:", result)
        end
    end
})

totemSection:CreateLabel({
    Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
})

--====================================================--
-- 🔄 AUTO BUY TOTEM SYSTEM
--====================================================--

local autoBuyTotem = false
local autoBuyInterval = 3540  -- 59 menit (buffer 1 menit sebelum expire)
local selectedAutoTotem = nil



-- Dropdown untuk auto buy
totemSection:CreateDropdown({
    Name = "Auto Buy Totem",
    Options = totemDropdownList,
    Callback = function(value)
        selectedAutoTotem = totemByLabel[value]
        if selectedAutoTotem then
            print("🔄 Auto Buy Target:", selectedAutoTotem.Name)
        end
    end
})

-- Slider untuk interval (30-60 menit)
totemSection:CreateSlider({
    Name = "Re-buy Interval (minutes)",
    Min = 30,
    Max = 60,
    Default = 59,
    Increment = 1,
    Callback = function(value)
        autoBuyInterval = value * 60  -- Convert to seconds
        print("⏱️ Auto buy interval:", value, "minutes")
    end
})

-- Toggle auto buy
totemSection:CreateToggle({
    Name = "Enable Auto Buy Totem",
    CurrentValue = false,
    Callback = function(state)
        autoBuyTotem = state
        
        if state then
            if not selectedAutoTotem then
                warn("❌ Pilih totem untuk auto buy dulu!")
                autoBuyTotem = false
                return
            end
            
            print("🟢 AUTO BUY TOTEM: ON")
            print("🗿 Target:", selectedAutoTotem.Name)
            print("⏱️ Interval:", autoBuyInterval / 60, "minutes")
            
            -- Auto buy loop
            task.spawn(function()
                while autoBuyTotem do
                    -- Buy totem
                    local success, result = pcall(function()
                        return PurchaseMarketItem:InvokeServer(selectedAutoTotem.Id)
                    end)
                    
                    if success then
                        print("✅ Auto bought:", selectedAutoTotem.Name, "at", os.date("%H:%M:%S"))
                        
                        -- Notification
                        local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
                        gui.Name = "AutoTotemNotify"
                        
                        local label = Instance.new("TextLabel", gui)
                        label.Size = UDim2.new(0, 300, 0, 50)
                        label.Position = UDim2.new(0.5, -150, 0.8, 0)
                        label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        label.TextColor3 = Color3.fromRGB(0, 255, 127)
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 18
                        label.Text = "🔄 Auto Bought: " .. selectedAutoTotem.Name
                        label.BackgroundTransparency = 1
                        
                        TweenService:Create(label, TweenInfo.new(0.4), {BackgroundTransparency = 0.3}):Play()
                        task.wait(3)
                        TweenService:Create(label, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
                        task.wait(0.5)
                        gui:Destroy()
                    else
                        warn("❌ Auto buy failed:", result)
                    end
                    
                    -- Wait interval (dengan countdown)
                    local countdown = autoBuyInterval
                    while countdown > 0 and autoBuyTotem do
                        task.wait(60)  -- Check every minute
                        countdown = countdown - 60
                        
                        if countdown > 0 and countdown % 300 == 0 then  -- Every 5 minutes
                            print("⏱️ Next totem buy in", countdown / 60, "minutes")
                        end
                    end
                end
            end)
            
        else
            print("🔴 AUTO BUY TOTEM: OFF")
        end
    end
})


print("✅ TOTEM SHOP SYSTEM LOADED!")

-- ========================================
-- 🛍️ MERCHANT GUI OPENER (SIMPLE VERSION)
-- ========================================

local merchantSection = shopTab:CreateSection({ Name = "Open Merchant" })

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ========================================
-- 📦 GET MERCHANT GUI
-- ========================================

local function getMerchantGUI()
    local merchant = playerGui:FindFirstChild("Merchant")
    if not merchant then
        warn("❌ Merchant GUI not found!")
        return nil
    end
    return merchant
end

-- ========================================
-- 🔓 OPEN MERCHANT
-- ========================================

local function openMerchant()
    local merchant = getMerchantGUI()
    if not merchant then return end
    
    -- Enable GUI
    merchant.Enabled = true
    
    -- Make sure Main & Background visible
    local main = merchant:FindFirstChild("Main")
    if main then
        main.Visible = true
        
        local background = main:FindFirstChild("Background")
        if background then
            background.Visible = true
        end
    end
    
end

-- ========================================
-- 🔒 CLOSE MERCHANT
-- ========================================

local function closeMerchant()
    local merchant = getMerchantGUI()
    if not merchant then return end
    
    -- Try clicking close button first
    local closeBtn = merchant:FindFirstChild("Close", true)
    if closeBtn then
        pcall(function()
            for _, conn in pairs(getconnections(closeBtn.MouseButton1Click)) do
                conn:Fire()
            end
        end)
        task.wait(0.1)
    end
    
    -- Fallback: manual close
    merchant.Enabled = false
    
end

-- ========================================
-- 🎛️ UI BUTTONS
-- ========================================

merchantSection:CreateButton({
    Name = "Open Merchant",
    Callback = function()
        openMerchant()
    end
})

merchantSection:CreateButton({
    Name = "Close Merchant",
    Callback = function()
        closeMerchant()
    end
})



print("✅ Merchant GUI Controls Loaded!")
