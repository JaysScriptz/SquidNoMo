-- SquidNoMo v1.0.0 | Complete 1-to-1 Premium Design
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Destroy old UI
if PlayerGui:FindFirstChild("SquidNoMo") then PlayerGui.SquidNoMo:Destroy() end

-- State Management (Cheats Logic)
local States = {
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = 196.2,
    Noclip = false,
    InfJump = false,
    SpeedBoost = false
}

-- Cheat Loop Connections
RunService.Stepped:Connect(function()
    if States.Noclip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if States.InfJump and Player.Character then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Create Base ScreenGui
local SG = Instance.new("ScreenGui", PlayerGui)
SG.Name = "SquidNoMo"
SG.IgnoreGuiInset = true

-- Main Panel
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 750, 0, 500)
Main.Position = UDim2.new(0.5, -375, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(13, 13, 15) -- Sleek Dark background
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Top Header Bar
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0.12, 0)
Header.BackgroundTransparency = 1

-- Pink Squid Logo
local LogoIcon = Instance.new("ImageLabel", Header)
LogoIcon.Size = UDim2.new(0, 32, 0, 32)
LogoIcon.Position = UDim2.new(0, 15, 0.5, -16)
LogoIcon.Image = "rbxassetid://10825287515" -- Stylized Octopus/Squid ID
LogoIcon.ImageColor3 = Color3.fromRGB(244, 67, 105) -- Squid Pink
LogoIcon.BackgroundTransparency = 1

-- Logo Text
local LogoText = Instance.new("TextLabel", Header)
LogoText.Size = UDim2.new(0, 200, 1, 0)
LogoText.Position = UDim2.new(0, 55, 0, 0)
LogoText.Text = "Squid<font color='rgb(0, 230, 118)'>NoMo</font>"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 20
LogoText.RichText = true
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.BackgroundTransparency = 1

-- Version Label
local VersionLabel = Instance.new("TextLabel", Header)
VersionLabel.Size = UDim2.new(0, 50, 0, 15)
VersionLabel.Position = UDim2.new(0, 55, 0.65, 0)
VersionLabel.Text = "v1.0.0"
VersionLabel.TextColor3 = Color3.fromRGB(100, 100, 105)
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 9
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.BackgroundTransparency = 1

-- Window Controls (Minimize & Close)
local WindowControls = Instance.new("Frame", Header)
WindowControls.Size = UDim2.new(0, 80, 1, 0)
WindowControls.Position = UDim2.new(1, -90, 0, 0)
WindowControls.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", WindowControls)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 155)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

-- Left Sidebar Layout
local LeftSidebar = Instance.new("Frame", Main)
LeftSidebar.Size = UDim2.new(0.2, 0, 0.88, 0)
LeftSidebar.Position = UDim2.new(0, 0, 0.12, 0)
LeftSidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
LeftSidebar.BorderSizePixel = 0

local NavFrame = Instance.new("Frame", LeftSidebar)
NavFrame.Size = UDim2.new(1, 0, 0.7, 0)
NavFrame.BackgroundTransparency = 1

local NavLayout = Instance.new("UIListLayout", NavFrame)
NavLayout.Padding = UDim.new(0, 4)
NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Helper to Generate Tabs Exactly Like Image
local function AddTab(name, iconId, isSelected)
    local btn = Instance.new("TextButton", NavFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.Text = "         " .. name
    btn.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
    btn.BackgroundColor3 = isSelected and Color3.fromRGB(26, 26, 32) or Color3.fromRGB(18, 18, 22)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    
    local icon = Instance.new("ImageLabel", btn)
    icon.Size = UDim2.new(0, 18, 0, 18)
    icon.Position = UDim2.new(0, 10, 0.5, -9)
    icon.Image = iconId
    icon.ImageColor3 = isSelected and Color3.fromRGB(0, 230, 118) or Color3.fromRGB(160, 160, 165)
    icon.BackgroundTransparency = 1
    
    if isSelected then
        local indicator = Instance.new("Frame", btn)
        indicator.Size = UDim2.new(0, 3, 0.6, 0)
        indicator.Position = UDim2.new(0, 0, 0.2, 0)
        indicator.BackgroundColor3 = Color3.fromRGB(0, 230, 118)
        indicator.BorderSizePixel = 0
    end
end

AddTab("Player", "rbxassetid://10747373176", true)
AddTab("Games", "rbxassetid://10747373012", false)
AddTab("Guard", "rbxassetid://10747384356", false)
AddTab("Detective", "rbxassetid://10747372314", false)
AddTab("VIP", "rbxassetid://10747371945", false)
AddTab("Settings", "rbxassetid://10747373117", false)

-- Profile Card (Bottom Left)
local ProfileCard = Instance.new("Frame", LeftSidebar)
ProfileCard.Size = UDim2.new(0.9, 0, 0.22, 0)
ProfileCard.Position = UDim2.new(0.05, 0, 0.75, 0)
ProfileCard.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
ProfileCard.BorderSizePixel = 0

local ProfileCorner = Instance.new("UICorner", ProfileCard)
ProfileCorner.CornerRadius = UDim.new(0, 8)

-- User Thumbnail
local Avatar = Instance.new("ImageLabel", ProfileCard)
Avatar.Size = UDim2.new(0, 32, 0, 32)
Avatar.Position = UDim2.new(0, 8, 0, 8)
Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Player.UserId .. "&width=150&height=150&format=png"
Avatar.BackgroundTransparency = 1
local AvatarCorner = Instance.new("UICorner", Avatar)
AvatarCorner.CornerRadius = UDim.new(1, 0)

local DisplayName = Instance.new("TextLabel", ProfileCard)
DisplayName.Size = UDim2.new(0.65, 0, 0, 16)
DisplayName.Position = UDim2.new(0, 48, 0, 6)
DisplayName.Text = Player.DisplayName
DisplayName.TextColor3 = Color3.fromRGB(255, 255, 255)
DisplayName.Font = Enum.Font.GothamBold
DisplayName.TextSize = 12
DisplayName.TextXAlignment = Enum.TextXAlignment.Left
DisplayName.BackgroundTransparency = 1

local Username = Instance.new("TextLabel", ProfileCard)
Username.Size = UDim2.new(0.65, 0, 0, 12)
Username.Position = UDim2.new(0, 48, 0, 20)
Username.Text = "@" .. Player.Name
Username.TextColor3 = Color3.fromRGB(0, 230, 118)
Username.Font = Enum.Font.Gotham
Username.TextSize = 10
Username.TextXAlignment = Enum.TextXAlignment.Left
Username.BackgroundTransparency = 1

-- Purple Level Bar
local LevelLabel = Instance.new("TextLabel", ProfileCard)
LevelLabel.Size = UDim2.new(1, -16, 0, 12)
LevelLabel.Position = UDim2.new(0, 8, 0, 38)
LevelLabel.Text = "Level 150"
LevelLabel.TextColor3 = Color3.fromRGB(200, 200, 205)
LevelLabel.Font = Enum.Font.GothamBold
LevelLabel.TextSize = 10
LevelLabel.TextXAlignment = Enum.TextXAlignment.Left
LevelLabel.BackgroundTransparency = 1

local ProgressBarBG = Instance.new("Frame", ProfileCard)
ProgressBarBG.Size = UDim2.new(1, -16, 0, 4)
ProgressBarBG.Position = UDim2.new(0, 8, 0, 52)
ProgressBarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
ProgressBarBG.BorderSizePixel = 0
local ProgressCorner = Instance.new("UICorner", ProgressBarBG)

local ProgressBarFill = Instance.new("Frame", ProgressBarBG)
ProgressBarFill.Size = UDim2.new(0.71, 0, 1, 0) -- 71% representation
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(145, 70, 255) -- Vibrant Purple
ProgressBarFill.BorderSizePixel = 0
local FillCorner = Instance.new("UICorner", ProgressBarFill)

-- Delta Tag Details
local DeltaTag = Instance.new("TextLabel", ProfileCard)
DeltaTag.Size = UDim2.new(1, -16, 0, 12)
DeltaTag.Position = UDim2.new(0, 8, 0, 62)
DeltaTag.Text = "Injection: <font color='rgb(0, 230, 118)'>Delta</font>"
DeltaTag.TextColor3 = Color3.fromRGB(150, 150, 155)
DeltaTag.Font = Enum.Font.Gotham
DeltaTag.TextSize = 10
DeltaTag.RichText = true
DeltaTag.TextXAlignment = Enum.TextXAlignment.Left
DeltaTag.BackgroundTransparency = 1

local StatusTag = Instance.new("TextLabel", ProfileCard)
StatusTag.Size = UDim2.new(1, -16, 0, 12)
StatusTag.Position = UDim2.new(0, 8, 0, 74)
StatusTag.Text = "Status: <font color='rgb(0, 230, 118)'>Undetected</font>"
StatusTag.TextColor3 = Color3.fromRGB(150, 150, 155)
StatusTag.Font = Enum.Font.Gotham
StatusTag.TextSize = 10
StatusTag.RichText = true
StatusTag.TextXAlignment = Enum.TextXAlignment.Left
StatusTag.BackgroundTransparency = 1


-- Center Panel (Scrollable Features)
local CenterPanel = Instance.new("ScrollingFrame", Main)
CenterPanel.Size = UDim2.new(0.55, -20, 0.88, -40)
CenterPanel.Position = UDim2.new(0.2, 10, 0.12, 10)
CenterPanel.BackgroundTransparency = 1
CenterPanel.BorderSizePixel = 0
CenterPanel.ScrollBarThickness = 3
CenterPanel.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)

local CenterLayout = Instance.new("UIListLayout", CenterPanel)
CenterLayout.Padding = UDim.new(0, 10)

-- Header text inside scrolling window
local CenterHeader = Instance.new("TextLabel", CenterPanel)
CenterHeader.Size = UDim2.new(1, 0, 0, 20)
CenterHeader.Text = "MOVEMENT"
CenterHeader.TextColor3 = Color3.fromRGB(0, 230, 118)
CenterHeader.Font = Enum.Font.GothamBold
CenterHeader.TextSize = 14
CenterHeader.TextXAlignment = Enum.TextXAlignment.Left
CenterHeader.BackgroundTransparency = 1

local CenterDesc = Instance.new("TextLabel", CenterPanel)
CenterDesc.Size = UDim2.new(1, 0, 0, 15)
CenterDesc.Text = "Enhance your movement and player capabilities."
CenterDesc.TextColor3 = Color3.fromRGB(130, 130, 135)
CenterDesc.Font = Enum.Font.Gotham
CenterDesc.TextSize = 11
CenterDesc.TextXAlignment = Enum.TextXAlignment.Left
CenterDesc.BackgroundTransparency = 1

-- Card Generation Helper (For WalkSpeed, JumpPower, Gravity)
local function CreateSliderCard(title, desc, iconId, defaultVal, minVal, maxVal, stepArr, updateCallback)
    local card = Instance.new("Frame", CenterPanel)
    card.Size = UDim2.new(0.96, 0, 0, 110)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local icon = Instance.new("ImageLabel", card)
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 12, 0, 12)
    icon.Image = iconId
    icon.ImageColor3 = Color3.fromRGB(0, 230, 118)
    icon.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.5, 0, 0, 18)
    lbl.Position = UDim2.new(0, 44, 0, 10)
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    
    local descLbl = Instance.new("TextLabel", card)
    descLbl.Size = UDim2.new(0.5, 0, 0, 15)
    descLbl.Position = UDim2.new(0, 44, 0, 26)
    descLbl.Text = desc
    descLbl.TextColor3 = Color3.fromRGB(130, 130, 135)
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.BackgroundTransparency = 1

    -- Value Display Container
    local valBox = Instance.new("TextBox", card)
    valBox.Size = UDim2.new(0, 50, 0, 24)
    valBox.Position = UDim2.new(0.62, 0, 0, 12)
    valBox.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    valBox.Text = tostring(defaultVal)
    valBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    valBox.Font = Enum.Font.GothamBold
    valBox.TextSize = 12
    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 4)

    -- Slider Track
    local sliderBG = Instance.new("Frame", card)
    sliderBG.Size = UDim2.new(0.24, 0, 0, 4)
    sliderBG.Position = UDim2.new(0.72, 0, 0, 22)
    sliderBG.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderBG.BorderSizePixel = 0
    Instance.new("UICorner", sliderBG)

    local sliderFill = Instance.new("Frame", sliderBG)
    sliderFill.Size = UDim2.new((defaultVal - minVal)/(maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 230, 118)
    sliderFill.BorderSizePixel = 0
    Instance.new("UICorner", sliderFill)

    local sliderBtn = Instance.new("ImageButton", sliderBG)
    sliderBtn.Size = UDim2.new(0, 10, 0, 10)
    sliderBtn.Position = UDim2.new((defaultVal - minVal)/(maxVal - minVal), -5, 0.5, -5)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(0, 230, 118)
    Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(1, 0)

    -- Step Increments Frame
    local stepFrame = Instance.new("Frame", card)
    stepFrame.Size = UDim2.new(1, -24, 0, 30)
    stepFrame.Position = UDim2.new(0, 12, 0, 65)
    stepFrame.BackgroundTransparency = 1

    local stepLayout = Instance.new("UIListLayout", stepFrame)
    stepLayout.FillDirection = Enum.FillDirection.Horizontal
    stepLayout.Padding = UDim.new(0.02, 0)
    stepLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function updateValue(newVal)
        newVal = math.clamp(math.round(newVal), minVal, maxVal)
        valBox.Text = tostring(newVal)
        sliderFill.Size = UDim2.new((newVal - minVal)/(maxVal - minVal), 0, 1, 0)
        sliderBtn.Position = UDim2.new((newVal - minVal)/(maxVal - minVal), -5, 0.5, -5)
        updateCallback(newVal)
    end

    -- Create quick adjust buttons
    for _, step in ipairs(stepArr) do
        local stepBtn = Instance.new("TextButton", stepFrame)
        stepBtn.Size = UDim2.new(0.18, 0, 1, 0)
        stepBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
        stepBtn.Text = tostring(step)
        stepBtn.TextColor3 = Color3.fromRGB(200, 200, 205)
        stepBtn.Font = Enum.Font.GothamBold
        stepBtn.TextSize = 11
        Instance.new("UICorner", stepBtn).CornerRadius = UDim.new(0, 4)
        
        stepBtn.MouseButton1Click:Connect(function()
            local current = tonumber(valBox.Text) or defaultVal
            if step:sub(1,1) == "+" or step:sub(1,1) == "-" then
                updateValue(current + tonumber(step))
            else
                updateValue(tonumber(step))
            end
        end)
    end

    -- Dragging slider functionality
    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            local value = minVal + relativeX * (maxVal - minVal)
            updateValue(value)
        end
    end)
end

-- Create Movement Sliders
CreateSliderCard("WalkSpeed", "Adjust your walking speed.", "rbxassetid://10747373176", 16, 16, 250, {"-10", "-1", "100", "+1", "+10"}, function(val)
    States.WalkSpeed = val
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
    end
end)

CreateSliderCard("Jump Power", "Adjust your jump power.", "rbxassetid://10747373012", 50, 50, 300, {"-10", "-1", "50", "+1", "+10"}, function(val)
    States.JumpPower = val
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        hum.UseJumpPower = true
        hum.JumpPower = val
    end
end)

CreateSliderCard("Gravity", "Adjust your gravity.", "rbxassetid://10747371945", 196, 0, 500, {"-50", "-10", "196", "+10", "+50"}, function(val)
    States.Gravity = val
    workspace.Gravity = val
end)

-- Standard Toggle Switch Generator Helper
local function CreateToggleCard(title, desc, iconId, stateKey, onCallback)
    local card = Instance.new("Frame", CenterPanel)
    card.Size = UDim2.new(0.96, 0, 0, 55)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local icon = Instance.new("ImageLabel", card)
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 12, 0.5, -10)
    icon.Image = iconId
    icon.ImageColor3 = Color3.fromRGB(0, 230, 118)
    icon.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", card)
    lbl.Size = UDim2.new(0.5, 0, 0, 18)
    lbl.Position = UDim2.new(0, 44, 0, 10)
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.BackgroundTransparency = 1
    
    local descLbl = Instance.new("TextLabel", card)
    descLbl.Size = UDim2.new(0.5, 0, 0, 15)
    descLbl.Position = UDim2.new(0, 44, 0, 26)
    descLbl.Text = desc
    descLbl.TextColor3 = Color3.fromRGB(130, 130, 135)
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextSize = 10
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.BackgroundTransparency = 1

    -- Switch GUI Element
    local switchBG = Instance.new("TextButton", card)
    switchBG.Size = UDim2.new(0, 42, 0, 22)
    switchBG.Position = UDim2.new(0.9, -10, 0.5, -11)
    switchBG.BackgroundColor3 = States[stateKey] and Color3.fromRGB(0, 230, 118) or Color3.fromRGB(50, 50, 55)
    switchBG.Text = ""
    Instance.new("UICorner", switchBG).CornerRadius = UDim.new(1, 0)

    local switchBall = Instance.new("Frame", switchBG)
    switchBall.Size = UDim2.new(0, 18, 0, 18)
    switchBall.Position = States[stateKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    switchBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", switchBall).CornerRadius = UDim.new(1, 0)

    switchBG.MouseButton1Click:Connect(function()
        States[stateKey] = not States[stateKey]
        local endPos = States[stateKey] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        local endColor = States[stateKey] and Color3.fromRGB(0, 230, 118) or Color3.fromRGB(50, 50, 55)
        
        TweenService:Create(switchBall, TweenInfo.new(0.2), {Position = endPos}):Play()
        TweenService:Create(switchBG, TweenInfo.new(0.2), {BackgroundColor3 = endColor}):Play()
        
        onCallback(States[stateKey])
    end)
end

-- Create Standard Movement Toggles
CreateToggleCard("Noclip", "Walk through any wall.", "rbxassetid://10747373117", "Noclip", function(val) States.Noclip = val end)
CreateToggleCard("Infinite Jump", "Jump without any limit.", "rbxassetid://10747372314", "InfJump", function(val) States.InfJump = val end)
CreateToggleCard("Speed Boost", "Temporarily boost your speed.", "rbxassetid://10747373012", "SpeedBoost", function(val)
    States.SpeedBoost = val
    if val then
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = States.WalkSpeed * 2
        end
    else
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
         
