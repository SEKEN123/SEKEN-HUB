-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Variables
local Aiming = false
local Target = nil
local Tween = nil
local UIMinimized = false

-- Settings
local Settings = {
    Enabled = false,
    Fov = 120,
    ShowFov = true,
    Smoothness = 0.15,
    Keybind = "Q",
    KeybindMode = "Hold", -- Hold or Toggle
    TargetPart = "Head",
    Prediction = false,
    PredictionAmount = 0.165,
    TeamCheck = true,
    WallCheck = false,
    FovColor = Color3.fromRGB(255, 255, 255)
}

-- Drawing FOV Circle
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = Settings.ShowFov and Settings.Enabled
FovCircle.Radius = Settings.Fov
FovCircle.Color = Settings.FovColor
FovCircle.Thickness = 1
FovCircle.Transparency = 1
FovCircle.Filled = false

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SEKENHUB"
ScreenGui.Parent = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(60, 60, 70)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8, 0, 0)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SEKEN HUB - Aimbot"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Name = "SubTitle"
SubTitle.Size = UDim2.new(1, -80, 0, 20)
SubTitle.Position = UDim2.new(0, 10, 0, 18)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "by SEKEN"
SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TitleBar

-- Minimize Button (icon garis bawah)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0.5, -15)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "‒"  -- Karakter garis horizontal (Unicode)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 20
MinimizeButton.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeButton

-- Close Button (ubah menjadi hide UI)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Content Frame
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -45)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ContentFrame.Visible = true
ContentFrame.Parent = MainFrame

-- Minimize/Maximize Functionality
local originalSize = UDim2.new(0, 300, 0, 400)
local minimizedSize = UDim2.new(0, 300, 0, 40)

local function MinimizeUI()
    if not UIMinimized then
        UIMinimized = true
        ContentFrame.Visible = false
        MinimizeButton.Text = "+"  -- Ganti icon menjadi plus/maximize
        MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        
        -- Animate minimize
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = minimizedSize
        })
        tween:Play()
    end
end

local function MaximizeUI()
    if UIMinimized then
        UIMinimized = false
        MinimizeButton.Text = "‒"  -- Ganti icon kembali menjadi minimize
        MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        
        -- Animate maximize
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = originalSize
        })
        tween:Play()
        
        -- Wait for animation to finish before showing content
        tween.Completed:Wait()
        ContentFrame.Visible = true
    end
end

MinimizeButton.MouseButton1Click:Connect(function()
    if UIMinimized then
        MaximizeUI()
    else
        MinimizeUI()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
    if not ScreenGui.Enabled then
        -- Jika UI disembunyikan, pastikan kembali ke state maximize saat ditampilkan kembali
        UIMinimized = false
        MainFrame.Size = originalSize
        ContentFrame.Visible = true
        MinimizeButton.Text = "‒"
        MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

-- Function to create toggle
local function CreateToggle(text, defaultValue, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
    ToggleFrame.Position = UDim2.new(0, 10, 0, #ContentFrame:GetChildren() * 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ContentFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 14
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleButton.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner2 = Instance.new("UICorner")
    ToggleCorner2.CornerRadius = UDim.new(0, 10)
    ToggleCorner2.Parent = ToggleButton
    
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Parent = ToggleButton
    
    local ToggleCorner3 = Instance.new("UICorner")
    ToggleCorner3.CornerRadius = UDim.new(1, 0)
    ToggleCorner3.Parent = ToggleIndicator
    
    if defaultValue then
        TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
            Position = UDim2.new(1, -18, 0.5, -8)
        }):Play()
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        if defaultValue then
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -18, 0.5, -8)
            }):Play()
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        else
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -8)
            }):Play()
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        end
        callback(defaultValue)
    end)
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, #ContentFrame:GetChildren() * 35)
    
    return ToggleButton
end

-- Function to create slider
local function CreateSlider(text, min, max, defaultValue, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 50)
    SliderFrame.Position = UDim2.new(0, 10, 0, #ContentFrame:GetChildren() * 35)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = ContentFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -20, 0, 20)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text .. ": " .. defaultValue
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextSize = 14
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -20, 0, 5)
    SliderTrack.Position = UDim2.new(0, 10, 0, 30)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = SliderFrame
    
    local SliderCornerTrack = Instance.new("UICorner")
    SliderCornerTrack.CornerRadius = UDim.new(1, 0)
    SliderCornerTrack.Parent = SliderTrack
    
    local SliderThumb = Instance.new("Frame")
    SliderThumb.Size = UDim2.new(0, 15, 0, 15)
    SliderThumb.Position = UDim2.new((defaultValue - min) / (max - min), -7.5, 0.5, -7.5)
    SliderThumb.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SliderThumb.BorderSizePixel = 0
    SliderThumb.Parent = SliderTrack
    
    local SliderCornerThumb = Instance.new("UICorner")
    SliderCornerThumb.CornerRadius = UDim.new(1, 0)
    SliderCornerThumb.Parent = SliderThumb
    
    local isDragging = false
    
    local function update(value)
        local percent = math.clamp((value - min) / (max - min), 0, 1)
        SliderThumb.Position = UDim2.new(percent, -7.5, 0.5, -7.5)
        SliderLabel.Text = text .. ": " .. string.format("%.2f", value)
        callback(value)
    end
    
    SliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    SliderThumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
            local value = min + (relativeX * (max - min))
            value = math.clamp(value, min, max)
            update(value)
        end
    end)
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, #ContentFrame:GetChildren() * 35)
    
    return {update = update}
end

-- Function to create dropdown
local function CreateDropdown(text, options, defaultValue, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -20, 0, 30)
    DropdownFrame.Position = UDim2.new(0, 10, 0, #ContentFrame:GetChildren() * 35)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Parent = ContentFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownFrame
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Size = UDim2.new(0.6, 0, 1, 0)
    DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = text
    DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownLabel.Font = Enum.Font.Gotham
    DropdownLabel.TextSize = 14
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(0, 100, 0, 25)
    DropdownButton.Position = UDim2.new(1, -110, 0.5, -12.5)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    DropdownButton.BorderSizePixel = 0
    DropdownButton.Text = defaultValue
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextSize = 12
    DropdownButton.Parent = DropdownFrame
    
    local DropdownCorner2 = Instance.new("UICorner")
    DropdownCorner2.CornerRadius = UDim.new(0, 6)
    DropdownCorner2.Parent = DropdownButton
    
    local DropdownMenu = Instance.new("Frame")
    DropdownMenu.Size = UDim2.new(0, 100, 0, 0)
    DropdownMenu.Position = UDim2.new(1, -110, 1, 5)
    DropdownMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    DropdownMenu.BorderSizePixel = 0
    DropdownMenu.Visible = false
    DropdownMenu.ClipsDescendants = true
    DropdownMenu.Parent = DropdownFrame
    
    local DropdownCorner3 = Instance.new("UICorner")
    DropdownCorner3.CornerRadius = UDim.new(0, 6)
    DropdownCorner3.Parent = DropdownMenu
    
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 25)
        OptionButton.Position = UDim2.new(0, 0, 0, (i-1)*25)
        OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        OptionButton.BorderSizePixel = 0
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 12
        OptionButton.Parent = DropdownMenu
        
        OptionButton.MouseButton1Click:Connect(function()
            DropdownButton.Text = option
            DropdownMenu.Visible = false
            DropdownMenu.Size = UDim2.new(0, 100, 0, 0)
            callback(option)
        end)
        
        DropdownMenu.Size = UDim2.new(0, 100, 0, i*25)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        DropdownMenu.Visible = not DropdownMenu.Visible
    end)
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, #ContentFrame:GetChildren() * 35)
    
    return DropdownButton
end

-- Function to create keybind button
local function CreateKeybind(text, defaultValue, callback)
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Size = UDim2.new(1, -20, 0, 30)
    KeybindFrame.Position = UDim2.new(0, 10, 0, #ContentFrame:GetChildren() * 35)
    KeybindFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    KeybindFrame.BorderSizePixel = 0
    KeybindFrame.Parent = ContentFrame
    
    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 6)
    KeybindCorner.Parent = KeybindFrame
    
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    KeybindLabel.Position = UDim2.new(0, 10, 0, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = text
    KeybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindLabel.Font = Enum.Font.Gotham
    KeybindLabel.TextSize = 14
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.Parent = KeybindFrame
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Size = UDim2.new(0, 80, 0, 25)
    KeybindButton.Position = UDim2.new(1, -90, 0.5, -12.5)
    KeybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    KeybindButton.BorderSizePixel = 0
    KeybindButton.Text = defaultValue
    KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.TextSize = 12
    KeybindButton.Parent = KeybindFrame
    
    local KeybindCorner2 = Instance.new("UICorner")
    KeybindCorner2.CornerRadius = UDim.new(0, 6)
    KeybindCorner2.Parent = KeybindButton
    
    local listening = false
    
    KeybindButton.MouseButton1Click:Connect(function()
        listening = true
        KeybindButton.Text = "..."
        KeybindButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end)
    
    local function setKey(key)
        local keyName = tostring(key):gsub("Enum.KeyCode.", "")
        KeybindButton.Text = keyName
        KeybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        callback(keyName)
        listening = false
    end
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                setKey(input.KeyCode)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                setKey("MouseButton1")
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                setKey("MouseButton2")
            end
        end
    end)
    
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, #ContentFrame:GetChildren() * 35)
    
    return KeybindButton
end

-- Create UI Elements
CreateToggle("Enable Aimbot", Settings.Enabled, function(value)
    Settings.Enabled = value
    FovCircle.Visible = value and Settings.ShowFov
end)

local fovSlider = CreateSlider("FOV Size", 10, 500, Settings.Fov, function(value)
    Settings.Fov = value
    FovCircle.Radius = value
end)

CreateToggle("Show FOV", Settings.ShowFov, function(value)
    Settings.ShowFov = value
    FovCircle.Visible = value and Settings.Enabled
end)

local smoothSlider = CreateSlider("Smoothness", 0, 1, Settings.Smoothness, function(value)
    Settings.Smoothness = value
end)

CreateDropdown("Target Part", {"Head", "HumanoidRootPart", "UpperTorso"}, Settings.TargetPart, function(value)
    Settings.TargetPart = value
end)

CreateToggle("Prediction", Settings.Prediction, function(value)
    Settings.Prediction = value
end)

local predictionSlider = CreateSlider("Prediction Amount", 0, 1, Settings.PredictionAmount, function(value)
    Settings.PredictionAmount = value
end)

CreateDropdown("Keybind Mode", {"Hold", "Toggle"}, Settings.KeybindMode, function(value)
    Settings.KeybindMode = value
end)

local keybindButton = CreateKeybind("Aimbot Key", Settings.Keybind, function(value)
    Settings.Keybind = value
end)

CreateToggle("Team Check", Settings.TeamCheck, function(value)
    Settings.TeamCheck = value
end)

CreateToggle("Wall Check", Settings.WallCheck, function(value)
    Settings.WallCheck = value
end)

-- Hide/Show Toggle UI Button (di luar frame utama)
local ToggleUIButton = Instance.new("TextButton")
ToggleUIButton.Size = UDim2.new(0, 100, 0, 30)
ToggleUIButton.Position = UDim2.new(0, 10, 0, 10)
ToggleUIButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleUIButton.BorderSizePixel = 0
ToggleUIButton.Text = "Show UI"
ToggleUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleUIButton.Font = Enum.Font.GothamBold
ToggleUIButton.TextSize = 14
ToggleUIButton.Parent = ScreenGui

local ToggleUICorner = Instance.new("UICorner")
ToggleUICorner.CornerRadius = UDim.new(0, 6)
ToggleUICorner.Parent = ToggleUIButton

ToggleUIButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleUIButton.Text = MainFrame.Visible and "Hide UI" or "Show UI"
    
    -- Jika UI ditampilkan, pastikan dalam state maximize
    if MainFrame.Visible then
        MaximizeUI()
    end
end)

-- Aimbot Functions
function IsPlayerVisible(player)
    if not Settings.WallCheck then return true end
    
    local character = player.Character
    if not character then return false end
    
    local targetPart = character:FindFirstChild(Settings.TargetPart)
    if not targetPart then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 1000
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult then
        local hitParent = raycastResult.Instance:FindFirstAncestorOfClass("Model")
        return hitParent == character
    end
    
    return true
end

function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.Fov
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local part = character:FindFirstChild(Settings.TargetPart)
        if not part then continue end
        
        if not IsPlayerVisible(player) then continue end
        
        local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
        
        if onScreen then
            local mousePos = UserInputService:GetMouseLocation()
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
            
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

function AimAtTarget(targetPlayer)
    if not targetPlayer then return end
    
    local character = targetPlayer.Character
    if not character then return end
    
    local part = character:FindFirstChild(Settings.TargetPart)
    if not part then return end
    
    local targetPosition = part.Position
    
    if Settings.Prediction then
        local velocity = part.Velocity or Vector3.new(0, 0, 0)
        targetPosition = targetPosition + (velocity * Settings.PredictionAmount)
    end
    
    local currentCamera = Camera.CFrame
    local targetCamera = CFrame.lookAt(currentCamera.Position, targetPosition)
    local smoothness = Settings.Smoothness
    
    if smoothness > 0 then
        if Tween then
            Tween:Cancel()
        end
        
        Tween = TweenService:Create(
            Camera,
            TweenInfo.new(smoothness, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {CFrame = targetCamera}
        )
        Tween:Play()
    else
        Camera.CFrame = targetCamera
    end
end

-- Main Aimbot Loop
local debounce = false
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FovCircle.Position = mousePos
    
    if Settings.Enabled then
        local shouldAim = false
        
        if Settings.KeybindMode == "Hold" then
            local keyCode = Enum.KeyCode[Settings.Keybind]
            if keyCode then
                shouldAim = UserInputService:IsKeyDown(keyCode)
            else
                -- For mouse buttons
                if Settings.Keybind == "MouseButton1" then
                    shouldAim = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                elseif Settings.Keybind == "MouseButton2" then
                    shouldAim = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                end
            end
        else
            -- Toggle mode
            local keyCode = Enum.KeyCode[Settings.Keybind]
            if keyCode and UserInputService:IsKeyDown(keyCode) then
                if not debounce then
                    debounce = true
                    Aiming = not Aiming
                    task.wait(0.2)
                end
            else
                debounce = false
            end
            shouldAim = Aiming
        end
        
        if shouldAim then
            local closestPlayer = GetClosestPlayer()
            if closestPlayer then
                AimAtTarget(closestPlayer)
            elseif Tween then
                Tween:Cancel()
                Tween = nil
            end
        elseif Tween then
            Tween:Cancel()
            Tween = nil
        end
    elseif Tween then
        Tween:Cancel()
        Tween = nil
    end
end)

-- Notification
local Notification = Instance.new("TextLabel")
Notification.Size = UDim2.new(0, 200, 0, 40)
Notification.Position = UDim2.new(0.5, -100, 0, 60)
Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Notification.BorderSizePixel = 0
Notification.Text = "KR0SS HUB Loaded!\nPress 'H' to hide/show UI"
Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
Notification.Font = Enum.Font.GothamBold
Notification.TextSize = 12
Notification.TextYAlignment = Enum.TextYAlignment.Top
Notification.Visible = false
Notification.Parent = ScreenGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 6)
NotifCorner.Parent = Notification

-- Show notification
Notification.Visible = true
task.wait(3)
Notification.Visible = false

-- Hotkey untuk toggle UI (H)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.H then
            ToggleUIButton.MouseButton1Click()
        end
    end
end)

-- Inisialisasi UI state
MainFrame.Visible = true
UIMinimized = false
ContentFrame.Visible = true
