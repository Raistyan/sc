local section = tab:CreateSection({ Name = "Fishing Controls" })

-- 🧠 Variabel utama
local cancelDelay = 0
local waitDelay = 0
local autoFishing = false
local blatanFishing = false


-- 📡 Service & Remote references
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local remotes = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local chargeRod = remotes:WaitForChild("RF/ChargeFishingRod")
local startFishing = remotes:WaitForChild("RF/RequestFishingMinigameStarted")
local finishFishing = remotes:WaitForChild("RE/FishingCompleted")
local cancelFishing = remotes:WaitForChild("RF/CancelFishingInputs")

-- 🎣 Fungsi utama auto fishing
local function doFishing()
    while autoFishing do
        chargeRod:InvokeServer()
        task.wait(0.3)
        startFishing:InvokeServer(-1.233184814453125, 0.06081610394009457, 1762887821.300317)
        task.wait(waitDelay)
        finishFishing:FireServer()
        task.wait(cancelDelay)
        cancelFishing:InvokeServer()
    end
end

---------------------------------------
-- ⚡ MODE BLATAN (DOUBLE REMOTE)
---------------------------------------
local function doFishingBlatan()
    while blatanFishing do
        pcall(function()
            spawn(function()
                chargeRod:InvokeServer(1)
                startFishing:InvokeServer(
                    math.random(-1, 1),
                    1,
                    math.random(1000000, 9999999)
                )
            end)
            
            task.wait(waitDelay)
            finishFishing:FireServer()
            
            task.wait(cancelDelay)
            cancelFishing:InvokeServer()
        end)
    end
end

section:CreateToggle({
    Name = "Auto Fishing",
    Flag = "autoFishing",
    CurrentValue = false,
    Callback = function(state)
        autoFishing = state
        if state then
            print("🎣 Auto Fishing Started")
            task.spawn(doFishing)
        else
            print("🛑 Auto Fishing Stopped")
        end
    end
})

---------------------------------------
-- ⚡ TOGGLE MODE BLATAN
---------------------------------------
section:CreateToggle({
    Name = "Blatan Mode 2X",
    Flag = "blatanFishing",
    CurrentValue = false,
    Callback = function(state)
        blatanFishing = state

        if state then
            print("⚡ Blatan Auto Fishing Started")
            task.spawn(doFishingBlatan)
        else
            print("🛑 Blatan Auto Fishing Stopped")
        end
    end
})

    -- 📦 INPUT WAIT DELAY (TEXTBOX)
    section:CreateInput({
        Name = "Wait Delay (detik)",
        PlaceholderText = "0.1",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            local num = tonumber(text)
            if num then
                waitDelay = num
                print("WaitDelay =", waitDelay)
            else
                print("❌ Input WaitDelay harus angka!")
            end
        end
    })


    -- 📦 INPUT CANCEL DELAY (TEXBOX)
    section:CreateInput({
        Name = "Cancel Delay (detik)",
        PlaceholderText = "0.1",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            local num = tonumber(text)
            if num then
                cancelDelay = num
                print("CancelDelay =", cancelDelay)
            else
                print("❌ Input CancelDelay harus angka!")
            end
        end
    })


-- ================================ --
-- BLATANT FISH (OPTIMIZED VERSION) --
-- ================================ --
local blatantSection = tab:CreateSection({ Name = "Blatant Super (Beta)" })

BlatantFishingDelay = 0.70
BlatantCancelDelay = 0.30
AutoFishEnabled = false

-- SAFE PARALLEL EXECUTION
local function safeFire(func)
    task.spawn(function()
        pcall(func)
    end)
end

-- MAIN LOOP (PARAMETER SESUAI GAME)
local function UltimateBypassFishing()
    task.spawn(function()
        while AutoFishEnabled do
            local currentTime = workspace:GetServerTimeNow()
            
            -- CAST
            safeFire(function()
                chargeRod:InvokeServer({[1] = currentTime})
            end)
            safeFire(function()
                startFishing:InvokeServer(1, 0, currentTime)
            end)
            
            task.wait(BlatantFishingDelay)
            
            -- COMPLETE
            safeFire(function()
                finishFishing:FireServer()
            end)
            
            task.wait(BlatantCancelDelay)
            
            -- CANCEL
            safeFire(function()
                cancelFishing:InvokeServer()
            end)
            
            task.wait() -- anti-freeze
        end
    end)
end

-- ✅ BIKIN COLLAPSIBLE (ACCORDION)
local blatantCollapse = blatantSection:CreateCollapsible({
    Name = "Blatant Settings",
    DefaultExpanded = false  -- Mulai collapsed
})

-- ✅ ISI DENGAN INPUT & TOGGLE
blatantCollapse:CreateInput({
    Name = "Fish Delay (detik)",
    PlaceholderText = "0.70",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            BlatantFishingDelay = num
            print("🎣 Fish Delay:", num)
        end
    end
})

blatantCollapse:CreateInput({
    Name = "Cancel Delay (detik)",
    PlaceholderText = "0.30",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            BlatantCancelDelay = num
            print("⏱️ Cancel Delay:", num)
        end
    end
})

blatantCollapse:CreateToggle({
    Name = "ON/OFF Blatant Super",
    CurrentValue = false,
    Callback = function(state)
        AutoFishEnabled = state
        if state then
            print("🟢 BLATANT: ON")
            UltimateBypassFishing()
        else
            print("🔴 BLATANT: OFF")
        end
    end
})

-- ======================================== --
-- 🎯 AUTO CLICKER STANDALONE + LEGIT MODE  
-- ========================================

local legitAndTap = false
local tapSpeed = 0.05 -- 50ms
local updateAutoFishingState = remotes:WaitForChild("RF/UpdateAutoFishingState")

-- 🎯 Buat UI Bulatan Kecil yang bisa digeser
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoClickerUI"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 20, 0, 20) -- Bulatan kecil
dot.Position = UDim2.new(0.5, -10, 0.5, -10) -- Posisi tengah
dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
dot.BackgroundTransparency = 0.5
dot.BorderSizePixel = 0
dot.Visible = false

-- Buat bentuk bulatan
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0) -- Bulat sempurna
UICorner.Parent = dot

dot.Parent = screenGui

-- 🎯 Function untuk drag bulatan
local dragging = false
local dragInput, dragStart, startPos

dot.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = dot.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

dot.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input == dragInput) then
        local delta = input.Position - dragStart
        dot.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- 🎯 Function untuk klik di posisi bulatan
local function clickAtDotPosition()
    pcall(function()
        local dotPosition = dot.AbsolutePosition
        local centerX = dotPosition.X + 10 -- Tengah bulatan
        local centerY = dotPosition.Y + 10
        
        if game:GetService("VirtualInputManager") then
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
            task.wait(0.01)
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
        end
    end)
end

-- 🔒 SATU TOGGLE untuk Legit Mode + Auto Tap
section:CreateToggle({
    Name = "🔒 Legit Mode + Auto Tap",
    CurrentValue = false,
    Callback = function(state)
        legitAndTap = state
        
        if state then
            print("🔒 Legit Mode + Auto Tap NYALA - 50ms")
            dot.Visible = true -- Tampilkan bulatan
            
            -- 1. Aktifin fitur auto fishing game
            pcall(function()
                updateAutoFishingState:InvokeServer(true)
            end)
            
            -- 2. Start auto tap loop di posisi bulatan
            task.spawn(function()
                while legitAndTap do
                    clickAtDotPosition() -- Klik di posisi bulatan
                    task.wait(tapSpeed) -- 50ms
                end
            end)
            
        else
            print("🔒 Legit Mode + Auto Tap MATI")
            dot.Visible = false -- Sembunyikan bulatan
            
            -- Matiin fitur auto fishing game
            pcall(function()
                updateAutoFishingState:InvokeServer(false)
            end)
        end
    end
})

print("🔒 Auto Clicker Standalone Loaded!")


local section = tab:CreateSection({ Name = "Fishing Animation" })

-- 🐟 Hilangkan Semua Animasi Mancing (Full)
local disableAnim = false

-- Kata yang dianggap animasi mancing
local blockedAnims = { "fish", "fishing", "rod", "cast", "reel", "hold", "idle" }

local function isFishingAnimation(obj)
    local name = string.lower(obj.Name or "")
    for _,v in ipairs(blockedAnims) do
        if string.find(name, v) then
            return true
        end
    end
    return false
end

-- Stop animasi dari Humanoid Animator
local function hookAnimator(char)
    local humanoid = char:WaitForChild("Humanoid", 2)
    if not humanoid then return end

    local animator = humanoid:FindFirstChildWhichIsA("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    animator.AnimationPlayed:Connect(function(track)
        if disableAnim and isFishingAnimation(track.Animation) then
            task.defer(function()
                track:Stop()
            end)
        end
    end)
end

-- Stop animasi dari Tool (FishingRod Tool Animation)
local function hookTools(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and isFishingAnimation(child) then
            -- Stop Animation from Tool
            for _,v in ipairs(child:GetDescendants()) do
                if v:IsA("Animation") and disableAnim then
                    v:Destroy()  -- hapus animasi dari tool
                end
            end

            -- Stop animation track yang sempat dimainkan
            for _,track in ipairs(char.Humanoid:GetPlayingAnimationTracks()) do
                if isFishingAnimation(track.Animation) then
                    track:Stop()
                end
            end
        end
    end)
end

-- Setup awal
local character = player.Character or player.CharacterAdded:Wait()
hookAnimator(character)
hookTools(character)

player.CharacterAdded:Connect(function(char)
    task.wait(1)
    hookAnimator(char)
    hookTools(char)
end)

-- Toggle UI
section:CreateToggle({
    Name = "Hilangkan Semua Animasi Mancing",
    CurrentValue = false,
    Callback = function(state)
        disableAnim = state
        print(state and "🔥 Semua animasi mancing dimatikan" or "🎣 Animasi mancing aktif kembali")
    end
})


-- ═══════════════════════════════════════════════
-- 💰 JUAL SEMUA IKAN (CLEAN VERSION - NO POPUP)
-- ═══════════════════════════════════════════════

local section = tab:CreateSection({ Name = "Sell Fitur" })

section:CreateButton({
    Name = "Jual Semua Ikan",
    Callback = function()
        local sellAll = remotes:WaitForChild("RF/SellAllItems")
        sellAll:InvokeServer()
        print("💰 Semua ikan berhasil dijual!")
    end
})


-- ═══════════════════════════════════════════════
-- 💸 AUTO SELL TIAP 30 MENIT (CLEAN VERSION)
-- ═══════════════════════════════════════════════

local autoSellEnabled = false

section:CreateToggle({
    Name = "Auto Sell Tiap 30 menit",
    CurrentValue = false,
    Callback = function(state)
        autoSellEnabled = state
        if state then
            print("💰 Auto Sell aktif — ikan akan dijual tiap 30 menit.")
            task.spawn(function()
                while autoSellEnabled do
                    task.wait(1800) -- 30 menit
                    local sellAll = remotes:WaitForChild("RF/SellAllItems")
                    sellAll:InvokeServer()
                    print("🕒 Auto Sell: Semua ikan dijual otomatis.")
                end
            end)
        else
            print("🛑 Auto Sell dimatikan.")
        end
    end
})
