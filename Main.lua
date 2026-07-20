--// SquidNoMo entry point

local BUILD_VERSION = "v0.8.3-beta"
local BUILD_TOKEN = string.gsub(BUILD_VERSION, "[^%w_%-]", "_")

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local previous = Environment.__SquidNoMoBootstrap
if type(previous) == "table" and previous.Loading == true then
    if type(previous.SetStatus) == "function" then
        previous:SetStatus("Already loading — please don't execute again.", 0.12)
    end
    if previous.Gui and previous.Gui.Parent then
        previous.Gui.Enabled = true
        previous.Gui.DisplayOrder = 1000000
    end
    warn("[SquidNoMo] A load is already in progress; duplicate execution ignored.")
    return previous.Loader
end

local bootstrap = {
    Loading = true,
    Version = BUILD_VERSION,
    StartedAt = os.clock(),
}
Environment.__SquidNoMoBootstrap = bootstrap

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    return game:GetService("CoreGui")
end

local gui = Instance.new("ScreenGui")
gui.Name = "SquidNoMoLoading"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if type(syn) == "table" and type(syn.protect_gui) == "function" then
    pcall(syn.protect_gui, gui)
end

gui.Parent = getGuiParent()
bootstrap.Gui = gui

local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = Color3.fromRGB(10, 9, 15)
shade.BackgroundTransparency = 0.12
shade.BorderSizePixel = 0
shade.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.86, 0, 0, 246)
panel.BackgroundColor3 = Color3.fromRGB(28, 25, 38)
panel.BorderSizePixel = 0
panel.Parent = shade

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(290, 230)
sizeConstraint.MaxSize = Vector2.new(560, 270)
sizeConstraint.Parent = panel

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(150, 92, 255)
stroke.Transparency = 0.15
stroke.Thickness = 2
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(22, 20)
title.Size = UDim2.new(1, -44, 0, 38)
title.Font = Enum.Font.GothamBold
title.Text = "SquidNoMo is loading"
title.TextColor3 = Color3.fromRGB(248, 246, 255)
title.TextSize = 25
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local warning = Instance.new("TextLabel")
warning.BackgroundTransparency = 1
warning.Position = UDim2.fromOffset(22, 58)
warning.Size = UDim2.new(1, -44, 0, 44)
warning.Font = Enum.Font.GothamMedium
warning.Text = "Please do not execute the script again. This window will close automatically."
warning.TextColor3 = Color3.fromRGB(205, 198, 220)
warning.TextSize = 15
warning.TextWrapped = true
warning.TextXAlignment = Enum.TextXAlignment.Left
warning.TextYAlignment = Enum.TextYAlignment.Top
warning.Parent = panel

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(22, 116)
status.Size = UDim2.new(1, -44, 0, 42)
status.Font = Enum.Font.GothamSemibold
status.Text = "Preparing startup..."
status.TextColor3 = Color3.fromRGB(230, 221, 255)
status.TextSize = 17
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

local track = Instance.new("Frame")
track.Position = UDim2.fromOffset(22, 174)
track.Size = UDim2.new(1, -44, 0, 14)
track.BackgroundColor3 = Color3.fromRGB(57, 52, 70)
track.BorderSizePixel = 0
track.Parent = panel
local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = track

local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0.04, 1)
fill.BackgroundColor3 = Color3.fromRGB(157, 94, 255)
fill.BorderSizePixel = 0
fill.Parent = track
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = fill

local detail = Instance.new("TextLabel")
detail.BackgroundTransparency = 1
detail.Position = UDim2.fromOffset(22, 198)
detail.Size = UDim2.new(1, -44, 0, 24)
detail.Font = Enum.Font.Gotham
detail.Text = BUILD_VERSION .. "  •  Starting safely"
detail.TextColor3 = Color3.fromRGB(157, 148, 174)
detail.TextSize = 13
detail.TextXAlignment = Enum.TextXAlignment.Left
detail.Parent = panel

function bootstrap:SetStatus(message, progress)
    if status and status.Parent then
        status.Text = tostring(message or "Loading...")
    end
    if fill and fill.Parent and progress ~= nil then
        local amount = math.clamp(tonumber(progress) or 0, 0.04, 1)
        fill:TweenSize(
            UDim2.fromScale(amount, 1),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.22,
            true
        )
    end
end

function bootstrap:Finish(loader)
    self.Loader = loader
    self.Loading = false
    self:SetStatus("Ready — opening SquidNoMo...", 1)
    task.delay(0.45, function()
        if self.Gui then
            self.Gui:Destroy()
            self.Gui = nil
        end
    end)
end

function bootstrap:Fail(message)
    self.Loading = false
    self:SetStatus("Loading failed", 1)
    warning.Text = tostring(message or "An unknown startup error occurred.")
    warning.TextColor3 = Color3.fromRGB(255, 165, 165)
    detail.Text = "You may close this panel and execute again after checking the console."

    local close = Instance.new("TextButton")
    close.AnchorPoint = Vector2.new(1, 1)
    close.Position = UDim2.new(1, -20, 1, -16)
    close.Size = UDim2.fromOffset(92, 34)
    close.BackgroundColor3 = Color3.fromRGB(104, 68, 156)
    close.BorderSizePixel = 0
    close.Font = Enum.Font.GothamBold
    close.Text = "Close"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.TextSize = 14
    close.Parent = panel
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = close
    close.Activated:Connect(function()
        gui:Destroy()
    end)
end

bootstrap:SetStatus("Connecting to the SquidNoMo repository...", 0.08)
print("[SquidNoMo] Starting " .. BUILD_VERSION)

local success, result = pcall(function()
    bootstrap:SetStatus("Downloading the main loader...", 0.14)
    local LoaderSource = game:HttpGet(
        "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/Loader.lua"
            .. "?squidnomo_build="
            .. BUILD_TOKEN
    )

    bootstrap:SetStatus("Compiling the main loader...", 0.2)
    local chunk, compileError = loadstring(LoaderSource)
    if not chunk then
        error("Loader compile failed: " .. tostring(compileError))
    end

    bootstrap:SetStatus("Starting core systems...", 0.24)
    return chunk()
end)

if not success then
    warn("[SquidNoMo] Startup failed: " .. tostring(result))
    bootstrap:Fail(tostring(result))
    return nil
end

bootstrap:Finish(result)
print("[SquidNoMo] Loader executed")
return result
