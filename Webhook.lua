local webhookSection = webhookTab:CreateSection({ Name = "Discord Configuration" })

-- ==========================================
-- WEBHOOK CONFIG VARIABLES
-- ==========================================
local WEBHOOK_URL = ""  -- User custom webhook
local WEBHOOK_ENABLED = false
local DiscordUserID = ""  -- Discord User ID untuk mention
local CustomUsername = player.Name  -- Default username

-- Filter Rarity (default semua aktif)
local rarityFilters = {
    Common = true,
    Uncommon = true,
    Rare = true,
    Epic = true,
    Legendary = true,
    Mythic = true,
    SECRET = true
}

-- ==========================================
-- DATA TIER MAPPING
-- ==========================================
local TIER_NAMES = {
    [1] = "Common",
    [2] = "Uncommon", 
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "SECRET"
}

local TIER_COLORS = {
    [1] = 11184810,  -- Gray (Common)
    [2] = 5763719,   -- Green (Uncommon)
    [3] = 2067276,   -- Blue (Rare)
    [4] = 10181046,  -- Purple (Epic)
    [5] = 15844367,  -- Orange (Legendary)
    [6] = 16711935,  -- Magenta (Mythic)
    [7] = 16711680   -- Red (SECRET)
}

-- ==========================================
-- HELPER FUNCTIONS
-- ==========================================
local function getTierName(tierNumber)
    return TIER_NAMES[tierNumber] or "Unknown"
end

local function getTierColor(tierNumber)
    return TIER_COLORS[tierNumber] or 0
end

-- Fungsi untuk cari ikan berdasarkan Item ID
local function getFishData(itemId)
    local itemsModule = require(ReplicatedStorage:WaitForChild("Items"))
    for _, fish in pairs(itemsModule) do
        if fish.Data and fish.Data.Id == itemId then
            return fish
        end
    end
    return nil
end

-- Fungsi untuk cari variant berdasarkan Variant ID
local function getVariantData(variantId)
    if not variantId then return nil end
    
    local variantsModule = require(ReplicatedStorage:WaitForChild("Variants"))
    for _, variant in pairs(variantsModule) do
        if variant.Data and variant.Data.Id == variantId then
            return variant
        end
    end
    return nil
end

-- ==========================================
-- SEND TO DISCORD FUNCTION
-- ==========================================
local function sendToDiscord(fishName, weight, tierNumber, sellPrice, icon, variantData, displayName, userID)
    if not WEBHOOK_ENABLED or WEBHOOK_URL == "" then 
        print("⚠️ Webhook disabled atau URL kosong")
        return 
    end
    
    -- Cek filter rarity
    local tierName = getTierName(tierNumber)
    if not rarityFilters[tierName] then
        print("⏭️ Skipped:", fishName, "(" .. tierName .. ") - Filter OFF")
        return
    end
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🚀 Sending to Discord...")
    print("Player:", displayName)
    print("Fish:", fishName)
    print("Weight:", weight, "kg")
    print("Tier:", tierName)
    
    -- Validasi icon URL
    local validIcon = (icon and icon ~= "" and string.match(icon, "^http")) and icon or "https://i.imgur.com/placeholder.png"
    
    -- Build fields
    local fields = {
        {["name"] = "👤 Player", ["value"] = displayName, ["inline"] = true},
        {["name"] = "🐟 Fish Name", ["value"] = tostring(fishName), ["inline"] = true},
        {["name"] = "⚖️ Weight", ["value"] = tostring(weight) .. " kg", ["inline"] = true},
        {["name"] = "✨ Rarity", ["value"] = tierName, ["inline"] = true}
    }
    
    -- Mutation field
    if variantData then
        local mutationValue = "✨ " .. variantData.Data.Name .. " (" .. tostring(variantData.SellMultiplier) .. "x)"
        table.insert(fields, {
            ["name"] = "🧬 Mutation", 
            ["value"] = mutationValue, 
            ["inline"] = true
        })
        print("Mutation:", variantData.Data.Name, "(" .. variantData.SellMultiplier .. "x)")
    else
        table.insert(fields, {
            ["name"] = "🧬 Mutation", 
            ["value"] = "None", 
            ["inline"] = true
        })
    end
    
    -- Calculate final sell price with variant multiplier
    local finalSellPrice = sellPrice
    if variantData and variantData.SellMultiplier then
        finalSellPrice = sellPrice * variantData.SellMultiplier
    end
    
    table.insert(fields, {
        ["name"] = "💰 Sell Price", 
        ["value"] = "$" .. tostring(math.floor(finalSellPrice)), 
        ["inline"] = true
    })
    
    print("Sell Price: $" .. math.floor(finalSellPrice))
    
    -- Get tier color
    local embedColor = getTierColor(tierNumber)
    if variantData then
        embedColor = 16776960  -- Gold color for mutation
    end
    
    -- Build mention string
    local mentionText = ""
    if userID and userID ~= "" then
        mentionText = "<@" .. userID .. "> "
    end
    
    -- Build embed
    local embed = {
        ["content"] = mentionText .. "🎣 **New Fish Caught!**",
        ["embeds"] = {{
            ["title"] = "🐟 " .. fishName .. " Caught!",
            ["description"] = "**" .. tierName .. "** rarity fish has been caught!",
            ["color"] = embedColor,
            ["fields"] = fields,
            ["thumbnail"] = {["url"] = validIcon},
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            ["footer"] = {
                ["text"] = "Ghost Fish Logger",
                ["icon_url"] = "https://i.imgur.com/fishing.png"
            }
        }}
    }

    local jsonData = game:GetService("HttpService"):JSONEncode(embed)

    -- Send webhook
    local success, response = pcall(function()
        local request = (syn and syn.request) or 
                       (http and http.request) or 
                       (http_request) or 
                       (request)
        
        if not request then
            error("❌ HTTP request function not found!")
        end
        
        return request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        })
    end)
    
    if success then
        print("✅ Webhook sent successfully!")
        if response then
            print("📡 Status:", response.StatusCode or "N/A")
        end
    else
        warn("❌ Failed to send webhook!")
        warn("Error:", tostring(response))
    end
    
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end

-- ==========================================
-- LISTEN FISH EVENT
-- ==========================================
local fishEvent = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RE/ObtainedNewFishNotification")

fishEvent.OnClientEvent:Connect(function(itemId, metadata, extraData, boolFlag)
    if not WEBHOOK_ENABLED then return end
    
    local fishData = getFishData(itemId)
    if not fishData then 
        print("⚠️ Fish data not found for ID:", itemId)
        return 
    end

    -- Get variant data if exists
    local variantData = nil
    if metadata and metadata.Variant then
        variantData = getVariantData(metadata.Variant)
    end

    -- Send to Discord
    sendToDiscord(
        fishData.Data.Name,
        metadata.Weight or 0,
        fishData.Data.Tier,
        fishData.SellPrice or 0,
        fishData.Data.Icon,
        variantData,
        CustomUsername,
        DiscordUserID
    )
end)

-- ==========================================
-- UI ELEMENTS
-- ==========================================

-- Toggle Enable/Disable Webhook
webhookSection:CreateToggle({
    Name = "Enable Webhook",
    CurrentValue = false,
    Callback = function(state)
        WEBHOOK_ENABLED = state
        print(state and "🔔 Webhook ENABLED" or "🔕 Webhook DISABLED")
    end
})

-- Input Webhook URL
webhookSection:CreateInput({
    Name = "Discord Webhook URL",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        if text and text ~= "" and string.match(text, "^https://discord.com/api/webhooks/") then
            WEBHOOK_URL = text
            print("✅ Webhook URL Set!")
        else
            print("❌ Invalid Webhook URL!")
        end
    end
})


-- Input Custom Username
webhookSection:CreateInput({
    Name = "Display Username (Optional)",
    PlaceholderText = player.Name,
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        if text and text ~= "" then
            CustomUsername = text
            print("✅ Custom Username Set:", text)
        else
            CustomUsername = player.Name
            print("⚠️ Username Reset to:", player.Name)
        end
    end
})

-- ==========================================
-- RARITY FILTER SECTION
-- ==========================================
local filterSection = webhookTab:CreateSection({ Name = "Rarity Filter" })

filterSection:CreateLabel({
    Text = "Select which rarities to send to Discord:"
})

-- Common Filter
filterSection:CreateToggle({
    Name = "Common",
    CurrentValue = true,
    Callback = function(state)
        rarityFilters.Common = state
        print("Common Filter:", state and "ON" or "OFF")
    end
})

-- Uncommon Filter
filterSection:CreateToggle({
    Name = "Uncommon",
    CurrentValue = true,
    Callback = function(state)
        rarityFilters.Uncommon = state
        print("Uncommon Filter:", state and "ON" or "OFF")
    end
})

-- Rare Filter
filterSection:CreateToggle({
    Name = "Rare",
    CurrentValue = true,
    Callback = function(state)
        rarityFilters.Rare = state
        print("Rare Filter:", state and "ON" or "OFF")
    end
})

-- Epic Filter
filterSection:CreateToggle({
    Name = "Epic",
    CurrentValue = true,
    Callback = function(state)
        rarityFilters.Epic = state
        print("Epic Filter:", state and "ON" or "OFF")
    end
})

-- Legendary Filter
filterSection:CreateToggle({
    Name = "Legendary",
    CurrentValue = true,
    Callback = function(state)
        rarityFilters.Legendary = state
        print("Legendary Filter:", state and "ON" or "OFF")
    end
})

-- Mythic Filter
filterSection:CreateToggle({
    Name = "Mythic",
    CurrentValue = true,
    Callback = function(state)
        rarityFilters.Mythic = state
        print("Mythic Filter:", state and "ON" or "OFF")
    end
})

-- SECRET Filter
filterSection:CreateToggle({
    Name = "SECRET",
    CurrentValue = true,
    Callback = function(state)
        rarityFilters.SECRET = state
        print("SECRET Filter:", state and "ON" or "OFF")
    end
})

-- ==========================================
-- HELPER INFO SECTION
-- ==========================================
local infoSection = webhookTab:CreateSection({ Name = "Setup Guide" })

infoSection:CreateLabel({
    Text = "📖 How to Get Discord Webhook:"
})

infoSection:CreateLabel({
    Text = "1. Open Discord Server Settings"
})

infoSection:CreateLabel({
    Text = "2. Go to 'Integrations' → 'Webhooks'"
})

infoSection:CreateLabel({
    Text = "3. Click 'New Webhook' or 'Create Webhook'"
})

infoSection:CreateLabel({
    Text = "4. Choose a channel and copy the URL"
})

infoSection:CreateLabel({
    Text = "5. Paste it in the textbox above!"
})

infoSection:CreateLabel({
    Text = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
})



print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔔 Webhook Tab Loaded!")
print("✅ Fish Logger Active!")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
