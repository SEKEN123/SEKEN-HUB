-- Enhanced Aimbot SEKEN HUB - Premium UI
-- Optimized for Solara Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Configuration dengan default values
local AimbotActive = false
local FOVCircleRadius = 80
local AimbotSmoothness = 0.15
local AimbotToggleKey = Enum.KeyCode.T
local UIToggleKey = Enum.KeyCode.Insert
local LeadTime = 0.1
local PredictionEnabled = true
local TargetPart = "Head"
local FOVVisible = true
local FOVThickness = 2
local TargetPriority = "Closest"
local UIVisible = true
local IsMinimized = false

-- UI Dragging Variables
local Dragging = false
local DragInput, DragStart, StartPosition

-- Prediction Variables
local PreviousPositions = {}
local VelocityHistory = {}

-- Settings file name
local SETTINGS_FILE_NAME = "seken_hub_settings.json"

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SekenHubGUI"
ScreenGui.Parent = game.CoreGui

-- Main Frame dengan design premium - TINGGI DIPERBESAR LAGI
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 460) -- Diperbesar dari 420 menjadi 460
Frame.Position = UDim2.new(0.5, -160, 0.5, -230) -- Center position yang disesuaikan (230 = 460/2)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Dark grey
Frame.BackgroundTransparency = 0.1 -- Slight transparency
Frame.Visible = UIVisible and not IsMinimized
Frame.Parent = ScreenGui

-- Make frame draggable
Frame.Active = true
Frame.Selectable = true
Frame.Draggable = false -- We'll handle dragging manually for better control

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12) -- More rounded corners
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255) -- White border
UIStroke.Transparency = 0.2
UIStroke.Parent = Frame

-- Header dengan gradient effect
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Header.BackgroundTransparency = 0.1
Header.Parent = Frame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12, 0, 0)
HeaderCorner.Parent = Header

-- Title: SEKEN HUB dengan style premium
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ SEKEN HUB ⚡"
Title.TextColor3 = Color3.fromRGB(220, 220, 220) -- Light grey
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextStrokeColor3 = Color3.fromRGB(100, 100, 255) -- Blue stroke
Title.TextStrokeTransparency = 0.5
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0.5, -15)
MinimizeButton.Text = "─"
MinimizeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Parent = Header

-- 🎯 FOV Circle CLEAN
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, FOVCircleRadius * 2, 0, FOVCircleRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.ZIndex = 10
FOVCircle.Visible = FOVVisible
FOVCircle.Parent = ScreenGui

local circleStroke = Instance.new("UIStroke")
circleStroke.Thickness = FOVThickness
circleStroke.Color = Color3.fromRGB(255, 255, 255)
circleStroke.Transparency = 0.2
circleStroke.LineJoinMode = Enum.LineJoinMode.Round
circleStroke.Parent = FOVCircle

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = FOVCircle

-- Minimize Frame
local MinimizeFrame = Instance.new("Frame")
MinimizeFrame.Size = UDim2.new(0, 50, 0, 30)
MinimizeFrame.Position = Frame.Position
MinimizeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeFrame.BackgroundTransparency = 0.1
MinimizeFrame.Visible = UIVisible and IsMinimized
MinimizeFrame.Parent = ScreenGui

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeFrame

local MinimizeStroke = Instance.new("UIStroke")
MinimizeStroke.Thickness = 2
MinimizeStroke.Color = Color3.fromRGB(255, 255, 255)
MinimizeStroke.Transparency = 0.2
MinimizeStroke.Parent = MinimizeFrame

local MaximizeButton = Instance.new("TextButton")
MaximizeButton.Size = UDim2.new(1, 0, 1, 0)
MaximizeButton.Text = "⚡"
MaximizeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
MaximizeButton.Font = Enum.Font.GothamBold
MaximizeButton.TextSize = 14
MaximizeButton.BackgroundTransparency = 1
MaximizeButton.Parent = MinimizeFrame

-- Content Area - DIBUAT LEBIH PANJANG
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -80) -- Diperbesar dari -70 menjadi -80
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = Frame

-- Function untuk membuat tombol premium
local function createPremiumButton(name, position, text, icon)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 36)
    button.Position = position
    button.Text = "  " .. icon .. "  " .. text
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.AutoButtonColor = false
    button.Parent = Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Thickness = 1
    buttonStroke.Color = Color3.fromRGB(80, 80, 80)
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = button
    
    -- Hover effects dengan animasi
    local originalSize = button.Size
    local originalPos = button.Position
    local originalColor = button.BackgroundColor3
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        buttonStroke.Color = Color3.fromRGB(100, 100, 255)
        buttonStroke.Transparency = 0
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
        buttonStroke.Color = Color3.fromRGB(80, 80, 80)
        buttonStroke.Transparency = 0.5
    end)
    
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    
    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    return button
end

-- Create Control Buttons dengan layout yang lebih baik
local buttonY = 5 -- Padding atas
local buttonHeight = 36
local buttonSpacing = 4 -- Spacing antar tombol

local StatusLabel = createPremiumButton("StatusLabel", UDim2.new(0, 0, 0, buttonY), "Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim", "🔒")
buttonY = buttonY + buttonHeight + buttonSpacing

local FOVSlider = createPremiumButton("FOVSlider", UDim2.new(0, 0, 0, buttonY), "FOV: " .. FOVCircleRadius, "🎯")
buttonY = buttonY + buttonHeight + buttonSpacing

local FOVToggle = createPremiumButton("FOVToggle", UDim2.new(0, 0, 0, buttonY), "FOV: ON", "👁️")
buttonY = buttonY + buttonHeight + buttonSpacing

local SmoothSlider = createPremiumButton("SmoothSlider", UDim2.new(0, 0, 0, buttonY), "Smooth: " .. AimbotSmoothness, "📏")
buttonY = buttonY + buttonHeight + buttonSpacing

local LeadSlider = createPremiumButton("LeadSlider", UDim2.new(0, 0, 0, buttonY), "Lead: " .. string.format("%.2f", LeadTime) .. "s", "⏱️")
buttonY = buttonY + buttonHeight + buttonSpacing

local PriorityToggle = createPremiumButton("PriorityToggle", UDim2.new(0, 0, 0, buttonY), "Priority: " .. TargetPriority, "🎯")
buttonY = buttonY + buttonHeight + buttonSpacing

local PredictionToggle = createPremiumButton("PredictionToggle", UDim2.new(0, 0, 0, buttonY), "Prediction: ON", "⚡")
buttonY = buttonY + buttonHeight + buttonSpacing

local PartSelector = createPremiumButton("PartSelector", UDim2.new(0, 0, 0, buttonY), "Target: " .. TargetPart, "🎯")
buttonY = buttonY + buttonHeight + buttonSpacing

local KeybindButton = createPremiumButton("KeybindButton", UDim2.new(0, 0, 0, buttonY), "Key: " .. tostring(AimbotToggleKey):match("%w+$"), "⌨️")
buttonY = buttonY + buttonHeight + buttonSpacing

local UIToggleKeyButton = createPremiumButton("UIToggleKeyButton", UDim2.new(0, 0, 0, buttonY), "UI Key: " .. tostring(UIToggleKey):match("%w+$"), "📱")
buttonY = buttonY + buttonHeight + buttonSpacing

local SaveButton = createPremiumButton("SaveButton", UDim2.new(0, 0, 0, buttonY), "Save Settings", "💾")
buttonY = buttonY + buttonHeight + buttonSpacing

local LoadButton = createPremiumButton("LoadButton", UDim2.new(0, 0, 0, buttonY), "Load Settings", "📂")

-- Fungsi untuk membuat UI draggable
local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    
    local function update(input)
        local delta = input.Position - DragStart
        frame.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + delta.Y
        )
    end
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPosition = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            update(input)
        end
    end)
end

-- Apply draggable to main frame and minimize frame
makeDraggable(Frame, Header)
makeDraggable(MinimizeFrame, MaximizeButton)

-- Fungsi untuk update FOV circle
local function updateFOV()
    FOVCircle.Size = UDim2.new(0, FOVCircleRadius * 2, 0, FOVCircleRadius * 2)
    FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    FOVSlider.Text = "  🎯  FOV: " .. FOVCircleRadius
    
    if FOVCircle:FindFirstChild("UIStroke") then
        FOVCircle.UIStroke.Thickness = FOVThickness
    end
end

-- Fungsi untuk toggle UI visibility
local function toggleUI()
    UIVisible = not UIVisible
    
    if UIVisible then
        if IsMinimized then
            Frame.Visible = false
            MinimizeFrame.Visible = true
        else
            Frame.Visible = true
            MinimizeFrame.Visible = false
        end
    else
        Frame.Visible = false
        MinimizeFrame.Visible = false
    end
end

-- Fungsi untuk update semua GUI text
local function updateGUI()
    updateFOV()
    SmoothSlider.Text = "  📏  Smooth: " .. string.format("%.2f", AimbotSmoothness)
    LeadSlider.Text = "  ⏱️  Lead: " .. string.format("%.2f", LeadTime) .. "s"
    PriorityToggle.Text = "  🎯  Priority: " .. TargetPriority
    PredictionToggle.Text = "  ⚡  Prediction: " .. (PredictionEnabled and "ON" or "OFF")
    PartSelector.Text = "  🎯  Target: " .. TargetPart
    KeybindButton.Text = "  ⌨️  Key: " .. tostring(AimbotToggleKey):match("%w+$")
    UIToggleKeyButton.Text = "  📱  UI Key: " .. tostring(UIToggleKey):match("%w+$")
    StatusLabel.Text = "  🔒  Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
    FOVToggle.Text = "  👁️  FOV: " .. (FOVVisible and "ON" or "OFF")
end

-- Save Settings Function
local function saveSettings()
    local settings = {
        FOVCircleRadius = FOVCircleRadius,
        AimbotSmoothness = AimbotSmoothness,
        LeadTime = LeadTime,
        TargetPriority = TargetPriority,
        PredictionEnabled = PredictionEnabled,
        TargetPart = TargetPart,
        FOVVisible = FOVVisible,
        FOVThickness = FOVThickness,
        AimbotToggleKey = tostring(AimbotToggleKey),
        UIToggleKey = tostring(UIToggleKey),
        FramePosition = {Frame.Position.X.Scale, Frame.Position.X.Offset, Frame.Position.Y.Scale, Frame.Position.Y.Offset},
        FrameSize = {Frame.Size.X.Scale, Frame.Size.X.Offset, Frame.Size.Y.Scale, Frame.Size.Y.Offset}
    }
    
    local success, jsonString = pcall(function()
        return HttpService:JSONEncode(settings)
    end)
    
    if success then
        local writeSuccess = pcall(function()
            if writefile then
                writefile(SETTINGS_FILE_NAME, jsonString)
                return true
            end
            return false
        end)
        
        if writeSuccess then
            StatusLabel.Text = "  ✅  Settings Saved!"
            task.wait(1.5)
            StatusLabel.Text = "  🔒  Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
            print("Settings saved successfully!")
        else
            StatusLabel.Text = "  ❌  Save Failed"
            task.wait(1.5)
            StatusLabel.Text = "  🔒  Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
            warn("Could not save settings")
        end
    else
        StatusLabel.Text = "  ❌  Save Error"
        task.wait(1.5)
        StatusLabel.Text = "  🔒  Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
        warn("Failed to encode settings to JSON")
    end
end

-- Load Settings Function
local function loadSettings()
    local readSuccess, fileContent = pcall(function()
        if readfile then
            return readfile(SETTINGS_FILE_NAME)
        end
        return nil
    end)
    
    if readSuccess and fileContent then
        local decodeSuccess, settings = pcall(function()
            return HttpService:JSONDecode(fileContent)
        end)
        
        if decodeSuccess and settings then
            FOVCircleRadius = settings.FOVCircleRadius or FOVCircleRadius
            AimbotSmoothness = settings.AimbotSmoothness or AimbotSmoothness
            LeadTime = settings.LeadTime or LeadTime
            TargetPriority = settings.TargetPriority or "Closest"
            PredictionEnabled = settings.PredictionEnabled ~= nil and settings.PredictionEnabled or PredictionEnabled
            TargetPart = settings.TargetPart or TargetPart
            FOVVisible = settings.FOVVisible ~= nil and settings.FOVVisible or FOVVisible
            FOVThickness = settings.FOVThickness or FOVThickness
            
            if settings.AimbotToggleKey then
                local keyName = settings.AimbotToggleKey:match("Enum%.KeyCode%.(.+)") or settings.AimbotToggleKey:match("%w+$")
                if keyName then
                    local keyCode = Enum.KeyCode[keyName]
                    if keyCode then
                        AimbotToggleKey = keyCode
                    end
                end
            end
            
            if settings.UIToggleKey then
                local keyName = settings.UIToggleKey:match("Enum%.KeyCode%.(.+)") or settings.UIToggleKey:match("%w+$")
                if keyName then
                    local keyCode = Enum.KeyCode[keyName]
                    if keyCode then
                        UIToggleKey = keyCode
                    end
                end
            end
            
            if settings.FramePosition then
                Frame.Position = UDim2.new(settings.FramePosition[1], settings.FramePosition[2], 
                                          settings.FramePosition[3], settings.FramePosition[4])
            end
            
            if settings.FrameSize then
                Frame.Size = UDim2.new(settings.FrameSize[1], settings.FrameSize[2],
                                      settings.FrameSize[3], settings.FrameSize[4])
            end
            
            updateGUI()
            FOVCircle.Visible = FOVVisible
            
            StatusLabel.Text = "  ✅  Settings Loaded!"
            print("Settings loaded successfully!")
            
            task.wait(1.5)
            StatusLabel.Text = "  🔒  Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
        else
            StatusLabel.Text = "  ❌  Load Error"
            task.wait(1.5)
            StatusLabel.Text = "  🔒  Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
            warn("Failed to decode settings from JSON")
        end
    else
        StatusLabel.Text = "  ❌  No Saved Settings"
        task.wait(1.5)
        StatusLabel.Text = "  🔒  Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
        print("No saved settings found. Using default settings.")
    end
end

-- Auto-load settings on script start
local function autoLoadSettings()
    task.wait(0.5)
    loadSettings()
end

-- Simple dan Accurate Prediction
local function updatePlayerData(player, position, velocity)
    if not PreviousPositions[player] then
        PreviousPositions[player] = {}
        VelocityHistory[player] = {}
    end
    
    table.insert(PreviousPositions[player], 1, {
        Position = position,
        Time = tick()
    })
    
    table.insert(VelocityHistory[player], 1, velocity)
    
    if #PreviousPositions[player] > 5 then
        table.remove(PreviousPositions[player])
    end
    if #VelocityHistory[player] > 5 then
        table.remove(VelocityHistory[player])
    end
end

local function calculateSimplePrediction(player, targetPart)
    if not PredictionEnabled or not VelocityHistory[player] or #VelocityHistory[player] == 0 then
        return targetPart.Position
    end
    
    local totalVelocity = Vector3.new(0, 0, 0)
    for _, vel in ipairs(VelocityHistory[player]) do
        totalVelocity = totalVelocity + vel
    end
    local averageVelocity = totalVelocity / #VelocityHistory[player]
    
    local predictedPosition = targetPart.Position + (averageVelocity * LeadTime)
    
    return predictedPosition
end

-- Auto Closest Target Selection
local function getBestTarget()
    local bestTarget = nil
    local closestDistance = math.huge
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    
    local validTargets = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local targetPart = character:FindFirstChild(TargetPart) or character:FindFirstChild("HumanoidRootPart")
        if not targetPart then continue end
        
        local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
        local distanceToCenter = (screenPos - screenCenter).Magnitude
        
        if distanceToCenter <= FOVCircleRadius then
            local cameraPosition = Camera.CFrame.Position
            local targetPosition = targetPart.Position
            local realDistance = (targetPosition - cameraPosition).Magnitude
            
            table.insert(validTargets, {
                Player = player,
                ScreenDistance = distanceToCenter,
                RealDistance = realDistance,
                ScreenPos = screenPos,
                TargetPart = targetPart
            })
        end
    end
    
    if #validTargets == 0 then
        return nil
    end
    
    if TargetPriority == "Closest" then
        for _, target in ipairs(validTargets) do
            if target.RealDistance < closestDistance then
                closestDistance = target.RealDistance
                bestTarget = target.Player
            end
        end
    else
        local closestScreenDistance = FOVCircleRadius
        for _, target in ipairs(validTargets) do
            if target.ScreenDistance < closestScreenDistance then
                closestScreenDistance = target.ScreenDistance
                bestTarget = target.Player
            end
        end
    end
    
    if bestTarget then
        local char = bestTarget.Character
        if char then
            local targetPart = char:FindFirstChild(TargetPart) or char:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude
                StatusLabel.Text = string.format("  🎯  %.0f studs", distance)
            end
        end
    end
    
    return bestTarget
end

-- Fixed Aimbot Function
local function fixedAimbot()
    local targetPlayer = getBestTarget()
    if not targetPlayer then 
        StatusLabel.Text = "  🎯  No Target"
        return 
    end
    
    local character = targetPlayer.Character
    if not character then return end
    
    local targetPart = character:FindFirstChild(TargetPart) or character:FindFirstChild("HumanoidRootPart")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not targetPart or not humanoidRootPart then return end
    
    updatePlayerData(targetPlayer, humanoidRootPart.Position, humanoidRootPart.Velocity)
    
    local targetPosition
    if PredictionEnabled then
        targetPosition = calculateSimplePrediction(targetPlayer, targetPart)
    else
        targetPosition = targetPart.Position
    end
    
    local currentCameraPosition = Camera.CFrame.Position
    local direction = (targetPosition - currentCameraPosition).Unit
    
    local targetCFrame = CFrame.new(currentCameraPosition, currentCameraPosition + direction)
    
    local newCFrame = Camera.CFrame:Lerp(targetCFrame, AimbotSmoothness)
    Camera.CFrame = newCFrame
end

-- Button Click Handlers
FOVSlider.MouseButton1Click:Connect(function()
    FOVCircleRadius = FOVCircleRadius + 10
    if FOVCircleRadius > 200 then FOVCircleRadius = 50 end
    updateFOV()
end)

FOVToggle.MouseButton1Click:Connect(function()
    FOVVisible = not FOVVisible
    FOVCircle.Visible = FOVVisible
    FOVToggle.Text = "  👁️  FOV: " .. (FOVVisible and "ON" or "OFF")
end)

SmoothSlider.MouseButton1Click:Connect(function()
    AimbotSmoothness = AimbotSmoothness + 0.05
    if AimbotSmoothness > 0.5 then AimbotSmoothness = 0.05 end
    SmoothSlider.Text = "  📏  Smooth: " .. string.format("%.2f", AimbotSmoothness)
end)

LeadSlider.MouseButton1Click:Connect(function()
    LeadTime = LeadTime + 0.05
    if LeadTime > 0.3 then LeadTime = 0.05 end
    LeadSlider.Text = "  ⏱️  Lead: " .. string.format("%.2f", LeadTime) .. "s"
end)

PriorityToggle.MouseButton1Click:Connect(function()
    if TargetPriority == "Closest" then
        TargetPriority = "Center"
    else
        TargetPriority = "Closest"
    end
    PriorityToggle.Text = "  🎯  Priority: " .. TargetPriority
end)

PredictionToggle.MouseButton1Click:Connect(function()
    PredictionEnabled = not PredictionEnabled
    PredictionToggle.Text = "  ⚡  Prediction: " .. (PredictionEnabled and "ON" or "OFF")
end)

PartSelector.MouseButton1Click:Connect(function()
    if TargetPart == "Head" then
        TargetPart = "HumanoidRootPart"
    elseif TargetPart == "HumanoidRootPart" then
        TargetPart = "UpperTorso"
    else
        TargetPart = "Head"
    end
    PartSelector.Text = "  🎯  Target: " .. TargetPart
end)

-- Aimbot Keybind Handler
local aimbotKeybindConnection
KeybindButton.MouseButton1Click:Connect(function()
    KeybindButton.Text = "  ⌨️  Press any key..."
    
    if aimbotKeybindConnection then
        aimbotKeybindConnection:Disconnect()
    end
    
    aimbotKeybindConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            AimbotToggleKey = input.KeyCode
            KeybindButton.Text = "  ⌨️  Key: " .. tostring(AimbotToggleKey):match("%w+$")
            StatusLabel.Text = "  🔒  Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
            aimbotKeybindConnection:Disconnect()
            aimbotKeybindConnection = nil
        end
    end)
end)

-- UI Toggle Keybind Handler
local uiKeybindConnection
UIToggleKeyButton.MouseButton1Click:Connect(function()
    UIToggleKeyButton.Text = "  📱  Press any key..."
    
    if uiKeybindConnection then
        uiKeybindConnection:Disconnect()
    end
    
    uiKeybindConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            UIToggleKey = input.KeyCode
            UIToggleKeyButton.Text = "  📱  UI Key: " .. tostring(UIToggleKey):match("%w+$")
            uiKeybindConnection:Disconnect()
            uiKeybindConnection = nil
        end
    end)
end)

-- Save/Load Button Handlers
SaveButton.MouseButton1Click:Connect(function()
    saveSettings()
end)

LoadButton.MouseButton1Click:Connect(function()
    loadSettings()
end)

-- MINIMIZE FUNCTIONALITY
MinimizeButton.MouseButton1Click:Connect(function()
    IsMinimized = true
    if UIVisible then
        Frame.Visible = false
        MinimizeFrame.Position = Frame.Position
        MinimizeFrame.Visible = true
    end
end)

MaximizeButton.MouseButton1Click:Connect(function()
    IsMinimized = false
    if UIVisible then
        Frame.Visible = true
        Frame.Position = MinimizeFrame.Position
        MinimizeFrame.Visible = false
    end
end)

-- Input Handling
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == AimbotToggleKey then
        AimbotActive = true
    end
    
    if input.KeyCode == UIToggleKey then
        toggleUI()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == AimbotToggleKey then
        AimbotActive = false
        StatusLabel.Text = "  🔒  Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
    end
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if AimbotActive then
        fixedAimbot()
    end
end)

-- Clean up
Players.PlayerRemoving:Connect(function(player)
    PreviousPositions[player] = nil
    VelocityHistory[player] = nil
end)

-- Initialize FOV
updateFOV()

-- Auto-load settings on startup
autoLoadSettings()

print("⚡ SEKEN HUB - Enhanced Aimbot loaded successfully!")
print("📱 Press " .. tostring(UIToggleKey):match("%w+$") .. " to toggle UI visibility")
print("🎯 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to activate aimbot")
print("✨ Features: Draggable UI, Premium Design, No Team Check")
