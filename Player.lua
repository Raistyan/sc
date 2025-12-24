local saktiSection = saktiTab:CreateSection({ Name = "Power Features" })

-- 🌪️ Variabel utama
local flyEnabled = false
local hoverLock = false
local flySpeed = 80
local bodyVelocity, bodyGyro



-- ✈️ Fly Mode (PC + Mobile)
saktiSection:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Callback = function(state)
        flyEnabled = state
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local humanoid = char:WaitForChild("Humanoid")

        if state then
            print("✈️ Fly Mode Aktif (PC + Mobile)")

            bodyVelocity = Instance.new("BodyVelocity")
            bodyGyro = Instance.new("BodyGyro")
            bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
            bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
            bodyGyro.P = 9000
            bodyVelocity.Parent = hrp
            bodyGyro.Parent = hrp

            task.spawn(function()
                while flyEnabled and not hoverLock do
                    RunService.Heartbeat:Wait()
                    if not hrp or not bodyVelocity or not bodyGyro then break end

                    local cam = workspace.CurrentCamera
                    bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
                    local move = Vector3.zero

                    -- 🖥️ Keyboard (PC)
                    if not UserInputService.TouchEnabled then
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
                    else
                        -- 📱 Mobile: joystick + auto lift
                        local dir = humanoid.MoveDirection
                        if dir.Magnitude > 0 then
                            move = cam.CFrame:VectorToWorldSpace(Vector3.new(dir.X, 0.3, dir.Z))
                        else
                            move = Vector3.new(0, 0.2, 0)
                        end
                    end

                    if move.Magnitude > 0 then
                        bodyVelocity.Velocity = move.Unit * flySpeed
                    else
                        bodyVelocity.Velocity = Vector3.zero
                    end
                end
            end)
        else
            print("🛑 Fly Mode Nonaktif")
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
        end
    end
})

-- 🔧 Slider Fly Speed
saktiSection:CreateSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = flySpeed,
    Increment = 5,
    Callback = function(val)
        flySpeed = val
    end
})

-- 🌀 Hover Lock (PC + Mobile)
saktiSection:CreateToggle({
    Name = "Hover Lock (Ngambang)",
    CurrentValue = false,
    Callback = function(state)
        hoverLock = state
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        if state then
            print("🌀 Hover Lock Aktif — posisi terkunci di udara")
            local savedCFrame = hrp.CFrame

            -- matikan gaya terbang aktif
            if bodyVelocity then bodyVelocity.Velocity = Vector3.zero end

            task.spawn(function()
                while hoverLock do
                    RunService.Heartbeat:Wait()
                    if not hrp then break end
                    hrp.Velocity = Vector3.zero
                    hrp.CFrame = savedCFrame
                end
            end)
        else
            print("⚙️ Hover Lock Nonaktif")
        end
    end
})


-- ⚡ Speed Mode
local speedEnabled = false
local runSpeed = 50

saktiSection:CreateToggle({
    Name = "Speed Mode",
    CurrentValue = false,
    Callback = function(state)
        speedEnabled = state
        local hum = player.Character:WaitForChild("Humanoid")
        if state then
            hum.WalkSpeed = runSpeed
            print("⚡ Speed Mode Aktif")
        else
            hum.WalkSpeed = 16
            print("🛑 Speed Mode Nonaktif")
        end
    end
})

-- 🏃‍♂️ Slider Run Speed
saktiSection:CreateSlider({
    Name = "Run Speed",
    Min = 16,
    Max = 200,
    Default = runSpeed,
    Increment = 5,
    Callback = function(val)
        runSpeed = val
        if speedEnabled then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = val
            end
        end
    end
})
