-- SquidNoMo v1.0.0 | Master Shell Build
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- 1. Base Setup (Prevent UI duplicates on re-execution)
if PlayerGui:FindFirstChild("SquidNoMo") then PlayerGui.SquidNoMo:Destroy() end

local SG = Instance.new("ScreenGui", PlayerGui)
SG.Name = "SquidNoMo"
SG.IgnoreGuiInset = true

-- 2. Main Frame (Exact Aspect Ratio from your reference image)
local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0.8, 0, 0.75, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 17) -- Ultra Dark Gray
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

-- 3. Left Sidebar (Navigation & Profile)
local LeftSidebar = Instance.new("Frame", Main)
LeftSidebar.Size = UDim2.new(0.2, 0, 1, 0)
LeftSidebar.BackgroundColor3 = Color3.fromRGB(21, 21, 24)
LeftSidebar.BorderSizePixel = 0

local LeftCorner = Instance.new("UICorner", LeftSidebar)
LeftCorner.CornerRadius = UDim.new(0, 12)

-- Left Sidebar Cover (Cleans up right rounded corners of sidebar)
local LeftCover = Instance.new("Frame", LeftSidebar)
LeftCover.Size = UDim2.new(0.1, 0, 1, 0)
LeftCover.Position = UDim2.new(0.9, 0, 0, 0)
LeftCover.BackgroundColor3 = Color3.fromRGB(21, 21, 24)
LeftCover.BorderSizePixel = 0

-- 4. Logo Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(0.8, 0, 0.12, 0)
Header.Position = UDim2.new(0.2, 0, 0, 0)
Header.BackgroundTransparency = 1

local LogoText = Instance.new("TextLabel", Header)
LogoText.Size = UDim2.new(0.5, 0, 1, 0)
LogoText.Position = UDim2.new(0.02, 0, 0, 0)
LogoText.Text = "SquidNoMo"
LogoText.TextColor3 = Color3.fromRGB(0, 230, 118) -- Bright Green Accent
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 22
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.BackgroundTransparency = 1

-- 5. Left Sidebar Navigation Frame
local NavFrame = Instance.new("Frame", LeftSidebar)
NavFrame.Size = UDim2.new(1, 0, 0.6, 0)
NavFrame.Position = UDim2.new(0, 0, 0.12, 0)
NavFrame.BackgroundTransparency = 1

local NavLayout = Instance.new("UIListLayout", NavFrame)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 5)

-- Navigation Buttons Helper
local function AddNavButton(name, layoutOrder)
    local btn = Instance.new("TextButton", NavFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, 0)
    btn.Text = "      " .. name
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.BackgroundColor3 = Color3.fromRGB(21, 21, 24)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = layoutOrder
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(21, 21, 24)
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end)
    
    return btn
end

-- Render the Exact Screenshot Tabs
AddNavButton("Player", 1)
AddNavButton("Games", 2)
AddNavButton("Guard", 3)
AddNavButton("Detective", 4)
AddNavButton("VIP", 5)
AddNavButton("Settings", 6)

-- 6. Profile Card (Bottom Left Corner)
local ProfileCard = Instance.new("Frame", LeftSidebar)
ProfileCard.Size = UDim2.new(0.9, 0, 0.15, 0)
ProfileCard.Position = UDim2.new(0.05, 0, 0.82, 0)
ProfileCard.BackgroundColor3 = Color3.fromRGB(26, 26, 31)
ProfileCard.BorderSizePixel = 0

local CardCorner = Instance.new("UICorner", ProfileCard)
CardCorner.CornerRadius = UDim.new(0, 8)

local Avatar = Instance.new("ImageLabel", ProfileCard)
Avatar.Size = UDim2.new(0.3, 0, 0.8, 0)
Avatar.Position = UDim2.new(0.05, 0, 0.1, 0)
Avatar.Image = "rbxassetid://6074003007" -- Clean fallback Avatar silhouette
Avatar.BackgroundTransparency = 1

local ProfileName = Instance.new("TextLabel", ProfileCard)
ProfileName.Size = UDim2.new(0.6, 0, 0.4, 0)
ProfileName.Position = UDim2.new(0.4, 0, 0.1, 0)
ProfileName.Text = Player.DisplayName or "Jasmine"
ProfileName.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfileName.Font = Enum.Font.GothamBold
ProfileName.TextSize = 12
ProfileName.TextXAlignment = Enum.TextXAlignment.Left
ProfileName.BackgroundTransparency = 1

local ProfileSub = Instance.new("TextLabel", ProfileCard)
ProfileSub.Size = UDim2.new(0.6, 0, 0.3, 0)
ProfileSub.Position = UDim2.new(0.4, 0, 0.5, 0)
ProfileSub.Text = "@" .. Player.Name
ProfileSub.TextColor3 = Color3.fromRGB(0, 230, 118)
ProfileSub.Font = Enum.Font.Gotham
ProfileSub.TextSize = 10
ProfileSub.TextXAlignment = Enum.TextXAlignment.Left
ProfileSub.BackgroundTransparency = 1

-- 7. Center Content Area Container (Where your hacks/controls live)
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size = UDim2.new(0.53, 0, 0.88, 0)
ContentArea.Position = UDim2.new(0.21, 0, 0.12, 0)
ContentArea.BackgroundTransparency = 1

-- 8. Right Sidebar (Favorites & Quick Toggles)
local RightSidebar = Instance.new("Frame", Main)
RightSidebar.Size = UDim2.new(0.24, 0, 0.88, 0)
RightSidebar.Position = UDim2.new(0.75, 0, 0.12, 0)
RightSidebar.BackgroundColor3 = Color3.fromRGB(21, 21, 24)
RightSidebar.BorderSizePixel = 0

local RightCorner = Instance.new("UICorner", RightSidebar)
RightCorner.CornerRadius = UDim.new(0, 12)

print("SquidNoMo visual structure successfully generated!")
