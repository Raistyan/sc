-- Tambahkan di bagian Tab Cuaca

-- Tambahkan di bagian Tab Cuaca

local cuacaSection = cuacaTab:CreateSection({ Name = "Weather Machine System" })

-- ==========================================
-- VARIABLES
-- ==========================================
local AutoBuyWeather = false
local SelectedWeathers = {}

-- ✅ DEKLARASI VARIABLE DI LUAR (SCOPE GLOBAL KE SECTION)
local weather1 = nil
local weather2 = nil
local weather3 = nil

-- ==========================================
-- REMOTE FUNCTION
-- ==========================================
local RFPurchaseWeatherEvent = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RF/PurchaseWeatherEvent")

-- ==========================================
-- DAFTAR CUACA
-- ==========================================
local AllWeathers = {
    "Cloudy",
    "Storm", 
    "Wind",
    "Snow",
    "Radiant",
    "Shark Hunt"
}

-- ==========================================
-- FUNCTION BUY WEATHER
-- ==========================================
local function BuyWeather(weatherName)
    local success, err = pcall(function()
        RFPurchaseWeatherEvent:InvokeServer(weatherName)
    end)
    
    if success then
        print("🌤️ Beli cuaca:", weatherName)
    else
        warn("❌ Gagal beli cuaca:", weatherName)
    end
end

-- ==========================================
-- FUNCTION UPDATE SELECTED WEATHERS
-- ==========================================
local function updateSelectedWeathers()
    SelectedWeathers = {}
    if weather1 then table.insert(SelectedWeathers, weather1) end
    if weather2 then table.insert(SelectedWeathers, weather2) end
    if weather3 then table.insert(SelectedWeathers, weather3) end
    print("📋 Selected:", table.concat(SelectedWeathers, ", "))
end

-- ==========================================
-- COMPACT SELECTION SYSTEM
-- ==========================================

cuacaSection:CreateLabel({
    Text = "Pilih Cuaca (Klik 3x untuk pilih 3 cuaca)"
})

-- Dropdown untuk Weather 1
cuacaSection:CreateDropdown({
    Name = "Weather Slot 1",
    Options = AllWeathers,
    Callback = function(value)
        weather1 = value
        updateSelectedWeathers()
    end
})

-- Dropdown untuk Weather 2
cuacaSection:CreateDropdown({
    Name = "Weather Slot 2",
    Options = AllWeathers,
    Callback = function(value)
        weather2 = value
        updateSelectedWeathers()
    end
})

-- Dropdown untuk Weather 3
cuacaSection:CreateDropdown({
    Name = "Weather Slot 3",
    Options = AllWeathers,
    Callback = function(value)
        weather3 = value
        updateSelectedWeathers()
    end
})

-- ==========================================
-- AUTO MAINTAIN WEATHER
-- ==========================================

cuacaSection:CreateToggle({
    Name = "🔄 Auto Maintain Weather",
    CurrentValue = false,
    Callback = function(state)
        AutoBuyWeather = state
        
        if state then
            if #SelectedWeathers == 0 then
                warn("❌ Pilih minimal 1 cuaca dulu!")
                return
            end
            
            print("🟢 AUTO WEATHER: ON")
            print("📌 Maintaining:", table.concat(SelectedWeathers, ", "))
            
            -- AUTO BUY LOOP
            task.spawn(function()
                while AutoBuyWeather do
                    for _, weather in ipairs(SelectedWeathers) do
                        if not AutoBuyWeather then break end
                        BuyWeather(weather)
                        task.wait(0.3)
                    end
                    task.wait(15)
                end
            end)
            
        else
            print("🔴 AUTO WEATHER: OFF")
        end
    end
})

-- ==========================================
-- MANUAL CONTROL
-- ==========================================

cuacaSection:CreateButton({
    Name = "Beli Semua Sekarang",
    Callback = function()
        if #SelectedWeathers == 0 then
            warn("❌ Belum ada cuaca yang dipilih!")
            return
        end
        
        print("💰 Membeli", #SelectedWeathers, "cuaca...")
        for _, weather in ipairs(SelectedWeathers) do
            BuyWeather(weather)
            task.wait(1)
        end
        print("✅ Selesai membeli!")
    end
})

print("✅ COMPACT WEATHER SYSTEM LOADED!")
