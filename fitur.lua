-- BUAT SECTION-NYA DULU
local PerformanceSection = performanceTab:CreateSection("Boost / Optimization")

local renderOff = false
local RunService = game:GetService("RunService")

PerformanceSection:CreateToggle({
    Name = "Disable Render 3D",
    CurrentValue = false,
    Callback = function(state)
        renderOff = state

        -- Matikan / hidupkan render 3D
        RunService:Set3dRenderingEnabled(not state)

        print(state and "🔇 Render 3D Disabled (Layar Gelap)" or "🔆 Render 3D Enabled (Normal)")
    end
})

-- BOOST FPS - TEXTURE SMOOTHER
local textureBoost = false

local function ApplyTextureBoost()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1 -- sembunyikan tekstur berat
        end
    end

    -- Kurangi kualitas rendering
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

    print("⚡ Texture Boost Applied")
end

local function RemoveTextureBoost()
    -- Kualitas auto
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

    -- Kembalikan decal / texture
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 0
        end
    end

    print("♻ Texture Boost Removed")
end

PerformanceSection:CreateToggle({
    Name = "Boost FPS",
    CurrentValue = false,
    Callback = function(state)
        textureBoost = state

        if state then
            ApplyTextureBoost()
        else
            RemoveTextureBoost()
        end
    end
})



local disableSmallNotification = false
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Toggle di tab Fitur
PerformanceSection:CreateToggle({
    Name = "Disable POP UP",
    CurrentValue = false,
    Callback = function(state)
        disableSmallNotification = state
        

        if state then
            -- Hapus yang sudah ada
            for _, obj in ipairs(playerGui:GetChildren()) do
                if obj.Name == "Small Notification" then
                    obj:Destroy()
                    
                end
            end
        end
    end
})

-- Listener untuk setiap anak baru PlayerGui
playerGui.ChildAdded:Connect(function(child)
    if disableSmallNotification and child.Name == "Small Notification" then
        child:Destroy()
        
    end
end)


local performanceSection = performanceTab:CreateSection({ Name = "Utility" })

local hideNameEnabled = false
local hideNameTask

performanceSection:CreateToggle({
    Name = "Hide Name",
    CurrentValue = false,
    Callback = function(state)
        hideNameEnabled = state
        
        -- Hentikan task lama
        if hideNameTask then
            task.cancel(hideNameTask)
            hideNameTask = nil
        end
        
        if state then
            print("👻 Hide Name: AKTIF - Menyembunyikan name tag")

            local function hideTags()
                if player.Character then
                    for _, v in ipairs(player.Character:GetDescendants()) do
                        if v:IsA("BillboardGui") then
                            v.Enabled = false
                        end
                    end
                end
            end

            -- Jalankan sekarang
            hideTags()

            -- Loop biar tetap hidden
            hideNameTask = task.spawn(function()
                while hideNameEnabled and task.wait(1) do
                    hideTags()
                end
            end)

        else
            print("👤 Hide Name: NONAKTIF - Menampilkan name tag kembali")

            if player.Character then
                for _, v in ipairs(player.Character:GetDescendants()) do
                    if v:IsA("BillboardGui") then
                        v.Enabled = true
                    end
                end
            end
        end
    end
})

-- Auto apply saat respawn
player.CharacterAdded:Connect(function(char)
    task.wait(2)
    if hideNameEnabled then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BillboardGui") then
                v.Enabled = false
            end
        end
    else
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BillboardGui") then
                v.Enabled = true
            end
        end
    end
end)

performanceSection:CreateLabel({
    Text = "Sembunyikan name tag karakter kamu 👻"
})

local tambahanSection = performanceTab:CreateSection({
    Name = "Anti AFK"
})

-- 💤 ANTI AFK HYBRID (Camera Move + Fake Touch)
local antiAFK = false
local UIS = game:GetService("UserInputService")
local VU = game:GetService("VirtualUser")

local function AntiAfkPing()
    VU:CaptureController()
    VU:ClickButton2(Vector2.new(), game:GetService("Workspace").CurrentCamera.CFrame)

    local cam = workspace.CurrentCamera
    cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(1), 0)

    print("🔄 Anti AFK Hybrid Triggered")
end

tambahanSection:CreateToggle({
    Name = "Anti AFK Hybrid",
    CurrentValue = false,
    Callback = function(state)
        antiAFK = state
        print(state and "🟢 Anti AFK Hybrid ON" or "🔴 Anti AFK Hybrid OFF")

        if state then
            task.spawn(function()
                while antiAFK do
                    task.wait(math.random(240, 360))
                    if not antiAFK then break end
                    AntiAfkPing()
                end
            end)
        end
    end
})


-- ============================
-- 🪄 Disable Skin Effects (VFX)
-- ============================
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Buat section khusus di tab "Fitur Tambahan"
local vfxSection = performanceTab:CreateSection({ Name = "Disable Skin Effect" })

local disableVFX = false
local VFXFolder = ReplicatedStorage:FindFirstChild("VFX")
local VFXBackup = nil

-- ✅ FIXED: Hapus backup lama sebelum bikin baru
local function createBackup()
    -- Destroy backup lama dulu (anti memory leak)
    if VFXBackup then
        pcall(function() VFXBackup:Destroy() end)
        VFXBackup = nil
    end
    
    VFXFolder = ReplicatedStorage:FindFirstChild("VFX")
    if VFXFolder then
        VFXBackup = Instance.new("Folder")
        VFXBackup.Name = "VFXBackup"
        for _, obj in ipairs(VFXFolder:GetChildren()) do
            pcall(function() obj:Clone().Parent = VFXBackup end)
        end
        print("✅ VFX Backup created:", #VFXBackup:GetChildren(), "objects")
    else
        VFXBackup = nil
    end
end

-- Buat backup saat script load
createBackup()

-- Jika folder VFX dibuat/dihapus ulang di runtime, update backup otomatis
ReplicatedStorage.ChildAdded:Connect(function(child)
    if child.Name == "VFX" then
        task.wait(0.1)
        createBackup()
    end
end)
ReplicatedStorage.ChildRemoved:Connect(function(child)
    if child.Name == "VFX" then
        VFXFolder = nil
        VFXBackup = nil
    end
end)

-- Toggle UI (pakai CreateToggle sesuai style UI kamu)
vfxSection:CreateToggle({
    Name = "Disable Skin Effect",
    CurrentValue = false,
    Callback = function(state)
        disableVFX = state

        -- Pastikan folder ada (coba cari lagi)
        VFXFolder = ReplicatedStorage:FindFirstChild("VFX")
        if not VFXFolder then
            warn("⚠ Folder VFX tidak ditemukan di ReplicatedStorage!")
            return
        end

        if disableVFX then
            -- Hapus semua child di VFX
            for _, obj in ipairs(VFXFolder:GetChildren()) do
                pcall(function() obj:Destroy() end)
            end
            print("✨ Semua efek skin telah di-disable")
        else
            -- Restore dari backup (jika ada)
            if VFXBackup then
                -- Hapus isi sekarang dulu (aman)
                for _, obj in ipairs(VFXFolder:GetChildren()) do
                    pcall(function() obj:Destroy() end)
                end
                -- Clone backup kembali
                for _, obj in ipairs(VFXBackup:GetChildren()) do
                    pcall(function() obj:Clone().Parent = VFXFolder end)
                end
                print("🔄 Efek skin telah di-restore")
            else
                warn("⚠ Tidak ada backup VFX. Tidak dapat me-restore.")
            end
        end
    end
})


-- 📸 Unlimited Camera Zoom Out
local unlimitedZoom = false
local Players = game:GetService("Players")
local player = Players.LocalPlayer

performanceSection:CreateToggle({
    Name = "Unlimited Camera Zoom",
    CurrentValue = false,
    Callback = function(state)
        unlimitedZoom = state

        if state then
            print("📸 Unlimited Camera Zoom: ON")

            -- Set zoom max tinggi banget
            player.CameraMaxZoomDistance = 999999
            player.CameraMinZoomDistance = 0

            -- Auto enforce bila game mereset
            task.spawn(function()
                while unlimitedZoom do
                    task.wait(0.2)
                    player.CameraMaxZoomDistance = 999999
                    player.CameraMinZoomDistance = 0
                end
            end)

        else
            print("📸 Unlimited Camera Zoom: OFF")

            -- Kembalikan default Roblox
            player.CameraMaxZoomDistance = 128
            player.CameraMinZoomDistance = 0.5
        end
    end
})



local animSection = performanceTab:CreateSection({ Name = "Skin Animation" })

--====================================================--
-- 🎨 CUSTOM SKIN ANIMATION - FISH CAUGHT ONLY
--====================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local Animator = humanoid:FindFirstChildOfClass("Animator")
if not Animator then
    Animator = Instance.new("Animator", humanoid)
end

--====================================================--
-- 📦 SKIN ANIMATION DATABASE (FISH CAUGHT ONLY)
--====================================================--

local SkinAnimations = {
    ["Holy Trident"] = "rbxassetid://128167068291703",
    ["Soul Scythe"] = "rbxassetid://82259219343456",
    ["Oceanic Harpoon"] = "rbxassetid://76325124055693",
    ["Binary Edge"] = "rbxassetid://109653945741202",
    ["The Vanquisher"] = "rbxassetid://93884986836266",
    ["Frozen Krampus Scythe"] = "rbxassetid://134934781977605",
    ["1x1x1x1 Ban Hammer"] = "rbxassetid://96285280763544",
    ["Corruption Edge"] = "rbxassetid://126613975718573",
    ["Eclipse Katana"] = "rbxassetid://107940819382815",
    ["Princess Parasol"] = "rbxassetid://99143072029495"
}

--====================================================--
-- 🎬 VARIABLES
--====================================================--

local SelectedSkin = "Holy Trident" -- Default
local FishCaughtAnim = nil
local FishCaughtTrack = nil
local AutoReplaceEnabled = false
local activeConnection = nil

--====================================================--
-- 🔄 LOAD SELECTED SKIN ANIMATION
--====================================================--

local function LoadSkinAnimation(skinName)
    local animId = SkinAnimations[skinName]
    if not animId then
        warn("❌ Skin not found:", skinName)
        return
    end
    
    -- Stop old animation
    if FishCaughtTrack and FishCaughtTrack.IsPlaying then
        FishCaughtTrack:Stop()
    end
    
    -- Create new animation
    FishCaughtAnim = Instance.new("Animation")
    FishCaughtAnim.AnimationId = animId
    FishCaughtAnim.Name = skinName .. "_FishCaught"
    
    -- Load animation track
    FishCaughtTrack = Animator:LoadAnimation(FishCaughtAnim)
    FishCaughtTrack.Priority = Enum.AnimationPriority.Action4
    FishCaughtTrack.Looped = false
    
    print("✅ Loaded:", skinName, "FishCaught Animation")
end

--====================================================--
-- 🐟 DETECTION & REPLACEMENT
--====================================================--

local function ReplaceFishCaughtAnimation()
    if not AutoReplaceEnabled or not FishCaughtTrack then return end
    
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        local trackName = string.lower(track.Name or "")
        local animName = string.lower(track.Animation.Name or "")
        
        -- Skip our custom animation
        if string.find(trackName, "fishcaught") and string.find(trackName, string.lower(SelectedSkin)) then
            continue
        end
        
        -- Detect Fish Caught animation
        if (string.find(trackName, "fish") or 
            string.find(animName, "caught") or 
            string.find(animName, "fish")) and
           not track.Looped and 
           track.Priority == Enum.AnimationPriority.Action4 then
            
            -- Stop default
            track:Stop()
            
            -- Play custom
            FishCaughtTrack:Play()
            
        end
    end
end

--====================================================--
-- 🖥 DUNHILL UI INTEGRATION
--====================================================--

-- Build skin list for dropdown
local skinList = {}
for skinName, _ in pairs(SkinAnimations) do
    table.insert(skinList, skinName)
end
table.sort(skinList)

-- Dropdown untuk pilih skin
animSection:CreateDropdown({
    Name = "Pilih Skin Animation",
    Options = skinList,
    Default = "Holy Trident",
    Callback = function(selected)
        SelectedSkin = selected
        print("🎨 Selected Skin:", selected)
        
        -- Load animation langsung
        LoadSkinAnimation(selected)
    end
})

-- Toggle ON/OFF
animSection:CreateToggle({
    Name = "Enable Custom Animation",
    CurrentValue = false,
    Callback = function(state)
        AutoReplaceEnabled = state
        
        if state then
            print("⚡ Custom Animation: ON -", SelectedSkin)
            
            -- Load selected skin animation
            LoadSkinAnimation(SelectedSkin)
            
            -- Setup monitoring
            if activeConnection then
                activeConnection:Disconnect()
            end
            
            activeConnection = RunService.Heartbeat:Connect(function()
                ReplaceFishCaughtAnimation()
            end)
            
        else
            print("🛑 Custom Animation: OFF")
            
            -- Stop monitoring
            if activeConnection then
                activeConnection:Disconnect()
                activeConnection = nil
            end
            
            -- Stop custom animation if playing
            if FishCaughtTrack and FishCaughtTrack.IsPlaying then
                FishCaughtTrack:Stop()
            end
        end
    end
})

-- Info label

--====================================================--
-- 🔄 AUTO REAPPLY ON RESPAWN
--====================================================--

player.CharacterAdded:Connect(function(newChar)
    task.wait(2)
    char = newChar
    humanoid = char:WaitForChild("Humanoid")
    Animator = humanoid:FindFirstChildOfClass("Animator")
    if not Animator then
        Animator = Instance.new("Animator", humanoid)
    end
    
    -- Reload animation jika toggle masih ON
    if AutoReplaceEnabled then
        LoadSkinAnimation(SelectedSkin)
        print("🔄 Reapplying", SelectedSkin, "FishCaught after respawn")
    end
end)

print("🎨 Custom Skin Animation System Loaded!")
