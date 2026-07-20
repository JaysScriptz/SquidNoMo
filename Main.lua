--// SquidNoMo entry point

local BUILD_VERSION = "v0.8.4-beta"
local BUILD_TOKEN = string.gsub(BUILD_VERSION, "[^%w_%-]", "_")
local REPOSITORY = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
local BANNER_PATH = "Images/BannerGuards.png"

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
        previous:SetStatus("Already loading — please do not execute again.", previous.Progress or 0.08)
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
    Progress = 0.02,
}
Environment.__SquidNoMoBootstrap = bootstrap

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then
            return result
        end
    end
    return game:GetService("CoreGui")
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Transparency = transparency or 0
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
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
shade.BackgroundColor3 = Color3.fromRGB(5, 6, 10)
shade.BackgroundTransparency = 0.04
shade.BorderSizePixel = 0
shade.Parent = gui

local panel = Instance.new("ScrollingFrame")
panel.Name = "LoaderPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.92, 0, 0.92, 0)
panel.BackgroundColor3 = Color3.fromRGB(9, 15, 19)
panel.BackgroundTransparency = 0.03
panel.BorderSizePixel = 0
panel.ScrollBarThickness = 4
panel.ScrollBarImageColor3 = Color3.fromRGB(52, 225, 104)
panel.CanvasSize = UDim2.fromOffset(0, 700)
panel.AutomaticCanvasSize = Enum.AutomaticSize.None
panel.ScrollingDirection = Enum.ScrollingDirection.Y
panel.Parent = shade
addCorner(panel, 18)
addStroke(panel, Color3.fromRGB(50, 223, 102), 0.12, 2)

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(300, 410)
sizeConstraint.MaxSize = Vector2.new(760, 860)
sizeConstraint.Parent = panel

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -28, 0, 680)
content.Position = UDim2.fromOffset(14, 12)
content.BackgroundTransparency = 1
content.Parent = panel

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)
layout.Parent = content

local version = Instance.new("TextLabel")
version.LayoutOrder = 1
version.Size = UDim2.new(1, -12, 0, 24)
version.BackgroundTransparency = 1
version.Font = Enum.Font.GothamSemibold
version.Text = BUILD_VERSION
version.TextColor3 = Color3.fromRGB(55, 235, 111)
version.TextSize = 15
version.TextXAlignment = Enum.TextXAlignment.Left
version.Parent = content

local bannerCard = Instance.new("Frame")
bannerCard.LayoutOrder = 2
bannerCard.Size = UDim2.new(1, -12, 0, 150)
bannerCard.BackgroundColor3 = Color3.fromRGB(5, 10, 14)
bannerCard.BorderSizePixel = 0
bannerCard.ClipsDescendants = true
bannerCard.Parent = content
addCorner(bannerCard, 14)
addStroke(bannerCard, Color3.fromRGB(41, 151, 75), 0.35, 1)

local bannerImage = Instance.new("ImageLabel")
bannerImage.Name = "AppBanner"
bannerImage.Size = UDim2.fromScale(1, 1)
bannerImage.BackgroundTransparency = 1
bannerImage.Image = ""
bannerImage.ScaleType = Enum.ScaleType.Crop
bannerImage.Visible = false
bannerImage.Parent = bannerCard

local bannerShade = Instance.new("Frame")
bannerShade.Size = UDim2.fromScale(1, 1)
bannerShade.BackgroundColor3 = Color3.fromRGB(2, 8, 10)
bannerShade.BackgroundTransparency = 0.48
bannerShade.BorderSizePixel = 0
bannerShade.ZIndex = 2
bannerShade.Parent = bannerCard

local bannerFallback = Instance.new("TextLabel")
bannerFallback.Size = UDim2.fromScale(1, 1)
bannerFallback.BackgroundTransparency = 1
bannerFallback.Font = Enum.Font.GothamBlack
bannerFallback.Text = "SQUID NO MO"
bannerFallback.TextColor3 = Color3.fromRGB(242, 246, 243)
bannerFallback.TextSize = 34
bannerFallback.TextScaled = true
bannerFallback.ZIndex = 3
bannerFallback.Parent = bannerCard
local fallbackConstraint = Instance.new("UITextSizeConstraint")
fallbackConstraint.MinTextSize = 24
fallbackConstraint.MaxTextSize = 48
fallbackConstraint.Parent = bannerFallback

local heading = Instance.new("TextLabel")
heading.LayoutOrder = 3
heading.Size = UDim2.new(1, -12, 0, 34)
heading.BackgroundTransparency = 1
heading.Font = Enum.Font.GothamBold
heading.Text = "LOADING SQUID NO MO..."
heading.TextColor3 = Color3.fromRGB(59, 236, 111)
heading.TextSize = 23
heading.TextXAlignment = Enum.TextXAlignment.Center
heading.Parent = content

local warningCard = Instance.new("Frame")
warningCard.LayoutOrder = 4
warningCard.Size = UDim2.new(1, -12, 0, 72)
warningCard.BackgroundColor3 = Color3.fromRGB(25, 26, 24)
warningCard.BorderSizePixel = 0
warningCard.Parent = content
addCorner(warningCard, 12)
addStroke(warningCard, Color3.fromRGB(235, 194, 61), 0.3, 1)

local warningIcon = Instance.new("TextLabel")
warningIcon.Size = UDim2.fromOffset(54, 72)
warningIcon.BackgroundTransparency = 1
warningIcon.Font = Enum.Font.GothamBold
warningIcon.Text = "!"
warningIcon.TextColor3 = Color3.fromRGB(255, 208, 45)
warningIcon.TextSize = 34
warningIcon.Parent = warningCard

local warning = Instance.new("TextLabel")
warning.Position = UDim2.fromOffset(54, 8)
warning.Size = UDim2.new(1, -66, 1, -16)
warning.BackgroundTransparency = 1
warning.Font = Enum.Font.GothamMedium
warning.Text = "DO NOT EXECUTE AGAIN\nThe loader is already working. Re-executing can cause errors."
warning.TextColor3 = Color3.fromRGB(238, 239, 235)
warning.TextSize = 15
warning.TextWrapped = true
warning.TextXAlignment = Enum.TextXAlignment.Left
warning.TextYAlignment = Enum.TextYAlignment.Center
warning.Parent = warningCard

local progressCard = Instance.new("Frame")
progressCard.LayoutOrder = 5
progressCard.Size = UDim2.new(1, -12, 0, 104)
progressCard.BackgroundColor3 = Color3.fromRGB(12, 22, 27)
progressCard.BorderSizePixel = 0
progressCard.Parent = content
addCorner(progressCard, 12)
addStroke(progressCard, Color3.fromRGB(48, 136, 77), 0.45, 1)

local progressTitle = Instance.new("TextLabel")
progressTitle.Position = UDim2.fromOffset(16, 10)
progressTitle.Size = UDim2.new(1, -110, 0, 25)
progressTitle.BackgroundTransparency = 1
progressTitle.Font = Enum.Font.GothamBold
progressTitle.Text = "OVERALL PROGRESS"
progressTitle.TextColor3 = Color3.fromRGB(57, 229, 106)
progressTitle.TextSize = 16
progressTitle.TextXAlignment = Enum.TextXAlignment.Left
progressTitle.Parent = progressCard

local percent = Instance.new("TextLabel")
percent.AnchorPoint = Vector2.new(1, 0)
percent.Position = UDim2.new(1, -16, 0, 8)
percent.Size = UDim2.fromOffset(86, 30)
percent.BackgroundTransparency = 1
percent.Font = Enum.Font.GothamBold
percent.Text = "2%"
percent.TextColor3 = Color3.fromRGB(57, 229, 106)
percent.TextSize = 23
percent.TextXAlignment = Enum.TextXAlignment.Right
percent.Parent = progressCard

local track = Instance.new("Frame")
track.Position = UDim2.fromOffset(16, 43)
track.Size = UDim2.new(1, -32, 0, 14)
track.BackgroundColor3 = Color3.fromRGB(41, 49, 53)
track.BorderSizePixel = 0
track.Parent = progressCard
addCorner(track, 20)

local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0.02, 1)
fill.BackgroundColor3 = Color3.fromRGB(49, 222, 98)
fill.BorderSizePixel = 0
fill.Parent = track
addCorner(fill, 20)

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(16, 65)
status.Size = UDim2.new(1, -32, 0, 26)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamSemibold
status.Text = "Preparing startup..."
status.TextColor3 = Color3.fromRGB(224, 232, 227)
status.TextSize = 15
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = progressCard

local stagesCard = Instance.new("Frame")
stagesCard.LayoutOrder = 6
stagesCard.Size = UDim2.new(1, -12, 0, 214)
stagesCard.BackgroundColor3 = Color3.fromRGB(10, 19, 23)
stagesCard.BorderSizePixel = 0
stagesCard.Parent = content
addCorner(stagesCard, 12)
addStroke(stagesCard, Color3.fromRGB(55, 94, 70), 0.52, 1)

local stagesLayout = Instance.new("UIListLayout")
stagesLayout.Padding = UDim.new(0, 2)
stagesLayout.SortOrder = Enum.SortOrder.LayoutOrder
stagesLayout.Parent = stagesCard

local stageDefinitions = {
    {"Connecting to repository", 0.08},
    {"Downloading core loader", 0.20},
    {"Loading core systems", 0.47},
    {"Loading feature modules", 0.86},
    {"Building interface", 0.96},
    {"Finalizing startup", 1.00},
}

local stageRows = {}
for index, definition in ipairs(stageDefinitions) do
    local row = Instance.new("Frame")
    row.LayoutOrder = index
    row.Size = UDim2.new(1, 0, 0, 33)
    row.BackgroundTransparency = 1
    row.Parent = stagesCard

    local dot = Instance.new("TextLabel")
    dot.Position = UDim2.fromOffset(12, 0)
    dot.Size = UDim2.fromOffset(28, 33)
    dot.BackgroundTransparency = 1
    dot.Font = Enum.Font.GothamBold
    dot.Text = "○"
    dot.TextColor3 = Color3.fromRGB(105, 113, 112)
    dot.TextSize = 20
    dot.Parent = row

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(43, 0)
    label.Size = UDim2.new(1, -128, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = definition[1]
    label.TextColor3 = Color3.fromRGB(215, 222, 218)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local state = Instance.new("TextLabel")
    state.AnchorPoint = Vector2.new(1, 0)
    state.Position = UDim2.new(1, -12, 0, 0)
    state.Size = UDim2.fromOffset(78, 33)
    state.BackgroundTransparency = 1
    state.Font = Enum.Font.GothamBold
    state.Text = "PENDING"
    state.TextColor3 = Color3.fromRGB(128, 136, 133)
    state.TextSize = 11
    state.TextXAlignment = Enum.TextXAlignment.Right
    state.Parent = row

    stageRows[index] = {Dot = dot, State = state, Threshold = definition[2]}
end

local tip = Instance.new("TextLabel")
tip.LayoutOrder = 7
tip.Size = UDim2.new(1, -12, 0, 42)
tip.BackgroundColor3 = Color3.fromRGB(12, 27, 23)
tip.BorderSizePixel = 0
tip.Font = Enum.Font.GothamMedium
tip.Text = "TIP  •  The interface opens automatically when loading reaches 100%."
tip.TextColor3 = Color3.fromRGB(190, 224, 202)
tip.TextSize = 14
tip.TextWrapped = true
tip.Parent = content
addCorner(tip, 11)

local function updateStageRows(progress)
    local activeAssigned = false
    for index, row in ipairs(stageRows) do
        local priorThreshold = index == 1 and 0 or stageRows[index - 1].Threshold
        if progress >= row.Threshold then
            row.Dot.Text = "✓"
            row.Dot.TextColor3 = Color3.fromRGB(53, 230, 105)
            row.State.Text = "COMPLETE"
            row.State.TextColor3 = Color3.fromRGB(53, 230, 105)
        elseif not activeAssigned and progress >= priorThreshold then
            activeAssigned = true
            row.Dot.Text = "◉"
            row.Dot.TextColor3 = Color3.fromRGB(53, 230, 105)
            row.State.Text = "LOADING"
            row.State.TextColor3 = Color3.fromRGB(53, 230, 105)
        else
            row.Dot.Text = "○"
            row.Dot.TextColor3 = Color3.fromRGB(105, 113, 112)
            row.State.Text = "PENDING"
            row.State.TextColor3 = Color3.fromRGB(128, 136, 133)
        end
    end
end

local function resolveBanner()
    local customAsset = nil
    if type(getcustomasset) == "function" then
        customAsset = getcustomasset
    elseif type(getsynasset) == "function" then
        customAsset = getsynasset
    end

    if not customAsset or type(writefile) ~= "function" then
        return
    end

    local folder = "SquidNoMo"
    local imageFolder = folder .. "/Images"
    local localPath = imageFolder .. "/" .. BUILD_TOKEN .. "_BannerGuards.png"

    pcall(function()
        if type(isfolder) == "function" and type(makefolder) == "function" then
            if not isfolder(folder) then makefolder(folder) end
            if not isfolder(imageFolder) then makefolder(imageFolder) end
        end
    end)

    local shouldDownload = true
    if type(isfile) == "function" then
        pcall(function()
            shouldDownload = not isfile(localPath)
        end)
    end

    if shouldDownload then
        local ok, data = pcall(function()
            return game:HttpGet(REPOSITORY .. BANNER_PATH .. "?squidnomo_build=" .. BUILD_TOKEN)
        end)
        if not ok or type(data) ~= "string" or #data == 0 then
            return
        end
        local wrote = pcall(function()
            writefile(localPath, data)
        end)
        if not wrote then
            return
        end
    end

    local ok, asset = pcall(function()
        return customAsset(localPath)
    end)
    if ok and asset and bannerImage.Parent then
        bannerImage.Image = asset
        bannerImage.Visible = true
        bannerFallback.Visible = false
    end
end

task.spawn(resolveBanner)

function bootstrap:SetStatus(message, progress)
    if status and status.Parent then
        status.Text = tostring(message or "Loading...")
    end

    if progress ~= nil then
        local amount = math.clamp(tonumber(progress) or 0, 0.02, 1)
        self.Progress = math.max(self.Progress or 0.02, amount)
        amount = self.Progress

        if fill and fill.Parent then
            fill:TweenSize(
                UDim2.fromScale(amount, 1),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.22,
                true
            )
        end
        if percent and percent.Parent then
            percent.Text = tostring(math.floor(amount * 100 + 0.5)) .. "%"
        end
        updateStageRows(amount)
    end
end

function bootstrap:Finish(loader)
    self.Loader = loader
    self.Loading = false
    self:SetStatus("Ready — opening SquidNoMo...", 1)
    heading.Text = "SQUID NO MO IS READY"
    task.delay(0.55, function()
        if self.Gui then
            self.Gui:Destroy()
            self.Gui = nil
        end
    end)
end

function bootstrap:Fail(message)
    self.Loading = false
    heading.Text = "LOADING FAILED"
    heading.TextColor3 = Color3.fromRGB(255, 120, 120)
    self:SetStatus("Startup stopped. Check the message below.", self.Progress or 0.2)
    warning.Text = tostring(message or "An unknown startup error occurred.")
    warning.TextColor3 = Color3.fromRGB(255, 180, 180)
    warningIcon.Text = "×"
    warningIcon.TextColor3 = Color3.fromRGB(255, 115, 115)
    tip.Text = "You can close this screen, check the console, and execute again after fixing the error."

    local close = Instance.new("TextButton")
    close.LayoutOrder = 8
    close.Size = UDim2.new(1, -12, 0, 40)
    close.BackgroundColor3 = Color3.fromRGB(119, 45, 52)
    close.BorderSizePixel = 0
    close.Font = Enum.Font.GothamBold
    close.Text = "CLOSE LOADER"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.TextSize = 15
    close.Parent = content
    addCorner(close, 10)
    close.Activated:Connect(function()
        gui:Destroy()
    end)
end

bootstrap:SetStatus("Connecting to the SquidNoMo repository...", 0.05)
print("[SquidNoMo] Starting " .. BUILD_VERSION)

local success, result = pcall(function()
    bootstrap:SetStatus("Downloading the main loader...", 0.14)
    local LoaderSource = game:HttpGet(
        REPOSITORY .. "Loader.lua?squidnomo_build=" .. BUILD_TOKEN
    )

    bootstrap:SetStatus("Compiling the main loader...", 0.20)
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
