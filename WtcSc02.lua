-- Enhanced Aimbot dengan UI Toggle & FOV Control
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
local UIToggleKey = Enum.KeyCode.Insert -- Tombol untuk toggle UI
local LeadTime = 0.1
local PredictionEnabled = true
local TeamCheck = true
local TargetPart = "Head"
local FOVVisible = true
local FOVThickness = 2
local TargetPriority = "Closest"
local UIVisible = true -- State UI visible/hidden

-- Prediction Variables
local PreviousPositions = {}
local VelocityHistory = {}

-- Settings file name
local SETTINGS_FILE_NAME = "aimbot_settings.json"

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EnhancedAimbotGUI"
ScreenGui.Parent = game.CoreGui

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 390)
Frame.Position = UDim2.new(0.5, -150, 0, 10)
Frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Frame.BackgroundTransparency = 0.15
Frame.Visible = UIVisible
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.new(0.7, 0.7, 0.7)
UIStroke.Parent = Frame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 25)
Title.Position = UDim2.new(0, 0, 0, -30)
Title.BackgroundTransparency = 1
Title.Text = "🎯 Enhanced Aimbot"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -30, 0, -30)
MinimizeButton.Text = "─"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 16
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Parent = Frame

-- 🎯 FOV Circle CLEAN (hanya garis tepi putih)
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, FOVCircleRadius * 2, 0, FOVCircleRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1 -- FULL TRANSPARANT
FOVCircle.BorderSizePixel = 0
FOVCircle.ZIndex = 10
FOVCircle.Visible = FOVVisible
FOVCircle.Parent = ScreenGui

-- UIStroke untuk garis tepi (CLEAN WHITE)
local circleStroke = Instance.new("UIStroke")
circleStroke.Thickness = FOVThickness
circleStroke.Color = Color3.fromRGB(255, 255, 255) -- PUTIH
circleStroke.Transparency = 0.2 -- Sedikit transparan untuk lebih clean
circleStroke.LineJoinMode = Enum.LineJoinMode.Round
circleStroke.Parent = FOVCircle

-- UICorner untuk membuat lingkaran sempurna
local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = FOVCircle

-- Minimize Frame
local MinimizeFrame = Instance.new("Frame")
MinimizeFrame.Size = UDim2.new(0, 40, 0, 25)
MinimizeFrame.Position = UDim2.new(0.5, -20, 0, 10)
MinimizeFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MinimizeFrame.BackgroundTransparency = 0.15
MinimizeFrame.Visible = false
MinimizeFrame.Parent = ScreenGui

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeFrame

local MinimizeStroke = Instance.new("UIStroke")
MinimizeStroke.Thickness = 1
MinimizeStroke.Color = Color3.new(0.7, 0.7, 0.7)
MinimizeStroke.Parent = MinimizeFrame

local MaximizeButton = Instance.new("TextButton")
MaximizeButton.Size = UDim2.new(1, 0, 1, 0)
MaximizeButton.Text = "🎯"
MaximizeButton.TextColor3 = Color3.new(1, 1, 1)
MaximizeButton.Font = Enum.Font.GothamBold
MaximizeButton.TextSize = 12
MaximizeButton.BackgroundTransparency = 1
MaximizeButton.Parent = MinimizeFrame

-- UI Toggle Indicator (muncul saat UI hidden)
local UIToggleIndicator = Instance.new("TextLabel")
UIToggleIndicator.Size = UDim2.new(0, 150, 0, 30)
UIToggleIndicator.Position = UDim2.new(0, 10, 1, -40)
UIToggleIndicator.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
UIToggleIndicator.BackgroundTransparency = 0.3
UIToggleIndicator.Text = "📱 UI Hidden (Press " .. tostring(UIToggleKey):match("%w+$") .. ")"
UIToggleIndicator.TextColor3 = Color3.new(1, 1, 1)
UIToggleIndicator.Font = Enum.Font.Gotham
UIToggleIndicator.TextSize = 12
UIToggleIndicator.Visible = false
UIToggleIndicator.Parent = ScreenGui

local IndicatorCorner = Instance.new("UICorner")
IndicatorCorner.CornerRadius = UDim.new(0, 6)
IndicatorCorner.Parent = UIToggleIndicator

local IndicatorStroke = Instance.new("UIStroke")
IndicatorStroke.Thickness = 1
IndicatorStroke.Color = Color3.new(0.7, 0.7, 0.7)
IndicatorStroke.Parent = UIToggleIndicator

-- Button Creation Function
local function createButton(name, position, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -20, 0, 28)
    button.Position = position
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    button.AutoButtonColor = false
    button.Parent = Frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    end)
    
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    end)
    
    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
    end)
    
    return button
end

-- Create Control Buttons
local StatusLabel = createButton("StatusLabel", UDim2.new(0, 10, 0, 10), "🔒 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim")
local FOVSlider = createButton("FOVSlider", UDim2.new(0, 10, 0, 45), "🎯 FOV: " .. FOVCircleRadius)
local FOVToggle = createButton("FOVToggle", UDim2.new(0, 10, 0, 80), "👁️ FOV: ON")
local SmoothSlider = createButton("SmoothSlider", UDim2.new(0, 10, 0, 115), "📏 Smooth: " .. AimbotSmoothness)
local LeadSlider = createButton("LeadSlider", UDim2.new(0, 10, 0, 150), "⏱️ Lead: " .. string.format("%.2f", LeadTime) .. "s")
local PriorityToggle = createButton("PriorityToggle", UDim2.new(0, 10, 0, 185), "🎯 Priority: Closest")
local PredictionToggle = createButton("PredictionToggle", UDim2.new(0, 10, 0, 220), "🎯 Prediction: ON")
local TeamCheckToggle = createButton("TeamCheckToggle", UDim2.new(0, 10, 0, 255), "👥 Team Check: ON")
local PartSelector = createButton("PartSelector", UDim2.new(0, 10, 0, 290), "🎯 Target: " .. TargetPart)
local KeybindButton = createButton("KeybindButton", UDim2.new(0, 10, 0, 325), "⌨️ Key: " .. tostring(AimbotToggleKey):match("%w+$"))
local UIToggleKeyButton = createButton("UIToggleKeyButton", UDim2.new(0, 10, 0, 360), "📱 UI Key: " .. tostring(UIToggleKey):match("%w+$"))
local SaveButton = createButton("SaveButton", UDim2.new(0, 10, 0, 395), "💾 Save Settings")
local LoadButton = createButton("LoadButton", UDim2.new(0, 10, 0, 430), "📂 Load Settings")

-- Fungsi untuk update FOV circle
local function updateFOV()
    FOVCircle.Size = UDim2.new(0, FOVCircleRadius * 2, 0, FOVCircleRadius * 2)
    FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    FOVSlider.Text = "🎯 FOV: " .. FOVCircleRadius
    
    -- Update stroke thickness
    if FOVCircle:FindFirstChild("UIStroke") then
        FOVCircle.UIStroke.Thickness = FOVThickness
    end
end

-- Fungsi untuk toggle UI visibility
local function toggleUI()
    UIVisible = not UIVisible
    
    if UIVisible then
        -- Show UI based on current state
        if Frame.Visible then
            -- UI is in normal mode
            Frame.Visible = true
            MinimizeFrame.Visible = false
        else
            -- UI is in minimized mode
            Frame.Visible = false
            MinimizeFrame.Visible = true
        end
        UIToggleIndicator.Visible = false
    else
        -- Hide all UI
        Frame.Visible = false
        MinimizeFrame.Visible = false
        UIToggleIndicator.Visible = true
    end
    
    -- Update UI toggle indicator text
    UIToggleIndicator.Text = "📱 UI Hidden (Press " .. tostring(UIToggleKey):match("%w+$") .. ")"
end

-- Fungsi untuk update semua GUI text
local function updateGUI()
    updateFOV()
    SmoothSlider.Text = "📏 Smooth: " .. string.format("%.2f", AimbotSmoothness)
    LeadSlider.Text = "⏱️ Lead: " .. string.format("%.2f", LeadTime) .. "s"
    PriorityToggle.Text = "🎯 Priority: " .. TargetPriority
    PredictionToggle.Text = PredictionEnabled and "🎯 Prediction: ON" or "🎯 Prediction: OFF"
    TeamCheckToggle.Text = TeamCheck and "👥 Team Check: ON" or "👥 Team Check: OFF"
    PartSelector.Text = "🎯 Target: " .. TargetPart
    KeybindButton.Text = "⌨️ Key: " .. tostring(AimbotToggleKey):match("%w+$")
    UIToggleKeyButton.Text = "📱 UI Key: " .. tostring(UIToggleKey):match("%w+$")
    StatusLabel.Text = "🔒 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
    FOVToggle.Text = FOVVisible and "👁️ FOV: ON" or "👁️ FOV: OFF"
    UIToggleIndicator.Text = "📱 UI Hidden (Press " .. tostring(UIToggleKey):match("%w+$") .. ")"
end

-- Save Settings Function
local function saveSettings()
    local settings = {
        FOVCircleRadius = FOVCircleRadius,
        AimbotSmoothness = AimbotSmoothness,
        LeadTime = LeadTime,
        TargetPriority = TargetPriority,
        PredictionEnabled = PredictionEnabled,
        TeamCheck = TeamCheck,
        TargetPart = TargetPart,
        FOVVisible = FOVVisible,
        FOVThickness = FOVThickness,
        AimbotToggleKey = tostring(AimbotToggleKey),
        UIToggleKey = tostring(UIToggleKey)
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
            StatusLabel.Text = "✅ Settings Saved!"
            StatusLabel.BackgroundColor3 = Color3.new(0, 0.5, 0)
            task.wait(1.5)
            StatusLabel.Text = "🔒 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
            StatusLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            print("Settings saved successfully!")
        else
            StatusLabel.Text = "❌ Save Failed"
            StatusLabel.BackgroundColor3 = Color3.new(0.8, 0, 0)
            task.wait(1.5)
            StatusLabel.Text = "🔒 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
            StatusLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            warn("Could not save settings: writefile not available")
        end
    else
        StatusLabel.Text = "❌ Save Error"
        StatusLabel.BackgroundColor3 = Color3.new(0.8, 0, 0)
        task.wait(1.5)
        StatusLabel.Text = "🔒 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
        StatusLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
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
            TeamCheck = settings.TeamCheck ~= nil and settings.TeamCheck or TeamCheck
            TargetPart = settings.TargetPart or TargetPart
            FOVVisible = settings.FOVVisible ~= nil and settings.FOVVisible or FOVVisible
            FOVThickness = settings.FOVThickness or FOVThickness
            
            -- Load AimbotToggleKey
            if settings.AimbotToggleKey then
                local keyName = settings.AimbotToggleKey:match("Enum%.KeyCode%.(.+)") or settings.AimbotToggleKey:match("%w+$")
                if keyName then
                    local keyCode = Enum.KeyCode[keyName]
                    if keyCode then
                        AimbotToggleKey = keyCode
                    end
                end
            end
            
            -- Load UIToggleKey
            if settings.UIToggleKey then
                local keyName = settings.UIToggleKey:match("Enum%.KeyCode%.(.+)") or settings.UIToggleKey:match("%w+$")
                if keyName then
                    local keyCode = Enum.KeyCode[keyName]
                    if keyCode then
                        UIToggleKey = keyCode
                    end
                end
            end
            
            updateGUI()
            FOVCircle.Visible = FOVVisible
            
            StatusLabel.Text = "✅ Settings Loaded!"
            StatusLabel.BackgroundColor3 = Color3.new(0, 0.5, 0)
            print("Settings loaded successfully!")
            
            task.wait(1.5)
            StatusLabel.Text = "🔒 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
            StatusLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        else
            StatusLabel.Text = "❌ Load Error"
            StatusLabel.BackgroundColor3 = Color3.new(0.8, 0, 0)
            task.wait(1.5)
            StatusLabel.Text = "🔒 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
            StatusLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            warn("Failed to decode settings from JSON")
        end
    else
        StatusLabel.Text = "❌ No Saved Settings"
        StatusLabel.BackgroundColor3 = Color3.new(0.8, 0, 0)
        task.wait(1.5)
        StatusLabel.Text = "🔒 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
        StatusLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
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
        if TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then continue end
        
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
                StatusLabel.Text = string.format("🎯 %.0f studs", distance)
            end
        end
    end
    
    return bestTarget
end

-- Fixed Aimbot Function
local function fixedAimbot()
    local targetPlayer = getBestTarget()
    if not targetPlayer then 
        StatusLabel.Text = "🎯 No Target"
        StatusLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
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
    
    StatusLabel.BackgroundColor3 = Color3.new(0.8, 0.1, 0.1)
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
    FOVToggle.Text = FOVVisible and "👁️ FOV: ON" or "👁️ FOV: OFF"
end)

SmoothSlider.MouseButton1Click:Connect(function()
    AimbotSmoothness = AimbotSmoothness + 0.05
    if AimbotSmoothness > 0.5 then AimbotSmoothness = 0.05 end
    SmoothSlider.Text = "📏 Smooth: " .. string.format("%.2f", AimbotSmoothness)
end)

LeadSlider.MouseButton1Click:Connect(function()
    LeadTime = LeadTime + 0.05
    if LeadTime > 0.3 then LeadTime = 0.05 end
    LeadSlider.Text = "⏱️ Lead: " .. string.format("%.2f", LeadTime) .. "s"
end)

PriorityToggle.MouseButton1Click:Connect(function()
    if TargetPriority == "Closest" then
        TargetPriority = "Center"
    else
        TargetPriority = "Closest"
    end
    PriorityToggle.Text = "🎯 Priority: " .. TargetPriority
end)

PredictionToggle.MouseButton1Click:Connect(function()
    PredictionEnabled = not PredictionEnabled
    PredictionToggle.Text = PredictionEnabled and "🎯 Prediction: ON" or "🎯 Prediction: OFF"
end)

TeamCheckToggle.MouseButton1Click:Connect(function()
    TeamCheck = not TeamCheck
    TeamCheckToggle.Text = TeamCheck and "👥 Team Check: ON" or "👥 Team Check: OFF"
end)

PartSelector.MouseButton1Click:Connect(function()
    if TargetPart == "Head" then
        TargetPart = "HumanoidRootPart"
    elseif TargetPart == "HumanoidRootPart" then
        TargetPart = "UpperTorso"
    else
        TargetPart = "Head"
    end
    PartSelector.Text = "🎯 Target: " .. TargetPart
end)

-- Aimbot Keybind Handler
local aimbotKeybindConnection
KeybindButton.MouseButton1Click:Connect(function()
    KeybindButton.Text = "⌨️ Press any key..."
    KeybindButton.BackgroundColor3 = Color3.new(0.3, 0.2, 0)
    
    if aimbotKeybindConnection then
        aimbotKeybindConnection:Disconnect()
    end
    
    aimbotKeybindConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            AimbotToggleKey = input.KeyCode
            KeybindButton.Text = "⌨️ Key: " .. tostring(AimbotToggleKey):match("%w+$")
            StatusLabel.Text = "🔒 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
            KeybindButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            aimbotKeybindConnection:Disconnect()
            aimbotKeybindConnection = nil
        end
    end)
end)

-- UI Toggle Keybind Handler
local uiKeybindConnection
UIToggleKeyButton.MouseButton1Click:Connect(function()
    UIToggleKeyButton.Text = "📱 Press any key..."
    UIToggleKeyButton.BackgroundColor3 = Color3.new(0.3, 0.2, 0)
    
    if uiKeybindConnection then
        uiKeybindConnection:Disconnect()
    end
    
    uiKeybindConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            UIToggleKey = input.KeyCode
            UIToggleKeyButton.Text = "📱 UI Key: " .. tostring(UIToggleKey):match("%w+$")
            UIToggleIndicator.Text = "📱 UI Hidden (Press " .. tostring(UIToggleKey):match("%w+$") .. ")"
            UIToggleKeyButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
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
local IsMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    IsMinimized = true
    Frame.Visible = false
    MinimizeFrame.Visible = true
end)

MaximizeButton.MouseButton1Click:Connect(function()
    IsMinimized = false
    Frame.Visible = true
    MinimizeFrame.Visible = false
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
        StatusLabel.Text = "🔒 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to Aim"
        StatusLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
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

print("🎯 Enhanced Aimbot loaded successfully!")
print("✅ New Features: UI Toggle & FOV Visibility Control")
print("📱 Press " .. tostring(UIToggleKey):match("%w+$") .. " to toggle UI visibility")
print("👁️ Press FOV button to toggle FOV circle visibility")
print("🎯 Hold " .. tostring(AimbotToggleKey):match("%w+$") .. " to activate aimbot")
