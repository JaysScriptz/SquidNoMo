--// SquidNoMo standalone round recorder
-- Execute this file separately from Main.lua. It intentionally does not build or
-- depend on the SquidNoMo application interface.

local REPOSITORY = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end

local function httpGet(url, timeoutSeconds)
    local complete, success, result = false, false, nil
    task.spawn(function()
        success, result = pcall(function() return game:HttpGet(url) end)
        complete = true
    end)
    local started = os.clock()
    local timeout = tonumber(timeoutSeconds) or 20
    while not complete and os.clock() - started < timeout do task.wait(0.05) end
    if not complete then error("HTTP request timed out: " .. tostring(url)) end
    if not success then error("HTTP request failed: " .. tostring(result)) end
    if type(result) ~= "string" or result == "" then error("HTTP response was empty: " .. tostring(url)) end
    return result
end

local function compile(source, name)
    local chunk, compileError = loadstring(source, "=" .. tostring(name or "SquidNoMoRecorder"))
    if not chunk then error(tostring(name) .. " compile failed: " .. tostring(compileError)) end
    local ok, result = pcall(chunk)
    if not ok then error(tostring(name) .. " execution failed: " .. tostring(result)) end
    return result
end

local function loadManifest()
    local cached = Environment.__SquidNoMoBuildManifest
    if type(cached) == "table" and cached.BuildNumber then return cached end
    local nonce = tostring(math.floor(os.clock() * 1000000))
    local manifest = compile(httpGet(REPOSITORY .. "BuildManifest.lua?recorder=" .. nonce, 18), "BuildManifest.lua")
    if type(manifest) ~= "table" then error("BuildManifest.lua did not return a table") end
    Environment.__SquidNoMoBuildManifest = manifest
    return manifest
end

local Manifest = loadManifest()
local BuildToken = tostring(Manifest.BuildToken or "")
local BuildNumber = tonumber(Manifest.BuildNumber) or 0
local Version = tostring(Manifest.Version or "SquidNoMo")

local existingUI = Environment.__SquidNoMoStandaloneRecorderUI
if type(existingUI) == "table" and existingUI.Gui and existingUI.Gui.Parent then
    existingUI.Gui.Enabled = true
    existingUI.Gui.DisplayOrder = 1000001
    if type(existingUI.Restore) == "function" then pcall(existingUI.Restore) end
    return existingUI.Recorder
end

local Sources = Environment.__SquidNoMoSourceBundle
local sourceToken = tostring(Environment.__SquidNoMoSourceBundleToken or "")
if type(Sources) ~= "table" or sourceToken ~= BuildToken then
    local bundleName = tostring(Manifest.StartupBundle or "SourceBundle.lua")
    local bundle = compile(httpGet(REPOSITORY .. bundleName .. "?recorder_build=" .. BuildToken, 30), bundleName)
    if type(bundle) ~= "table" or type(bundle.Sources) ~= "table" then
        error("SourceBundle.lua is invalid")
    end
    if tostring(bundle.BuildToken or "") ~= BuildToken then
        error("Build mismatch between BuildManifest.lua and SourceBundle.lua")
    end
    Sources = bundle.Sources
    Environment.__SquidNoMoSourceBundle = Sources
    Environment.__SquidNoMoSourceBundleToken = BuildToken
end

local function loadBundled(path)
    local source = Sources[path]
    if type(source) ~= "string" or source == "" then error("Recorder bundle is missing " .. tostring(path)) end
    return compile(source, path)
end

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table"
    or tostring(Runtime.Revision) ~= tostring(Manifest.FeatureRuntimeRevision or "")
    or tonumber(Runtime.BuildNumber) ~= BuildNumber
then
    Runtime = loadBundled("Features/Shared/Runtime.lua")
end

local GameRuntime = Environment.__SquidNoMoGameRuntime
if type(GameRuntime) ~= "table"
    or tostring(GameRuntime.Revision) ~= tostring(Manifest.GameRuntimeRevision or "")
    or tonumber(GameRuntime.BuildNumber) ~= BuildNumber
then
    GameRuntime = loadBundled("Features/Games/GameRuntime.lua")
end

local Recorder = Environment.__SquidNoMoLearningRecorder
if type(Recorder) ~= "table" or tonumber(Recorder.BuildNumber) ~= BuildNumber then
    Recorder = loadBundled("Features/Shared/LearningRecorder.lua")
end

local recorderLoader = {
    BuildVersion = Version,
    BuildNumber = BuildNumber,
    BuildRevision = tostring(Manifest.Revision or "unknown"),
    Features = {Shared = {Runtime = Runtime, GameRuntime = GameRuntime}},
}
Recorder:Initialize(recorderLoader, nil)

local function guiParent()
    if type(gethui) == "function" then
        local ok, parent = pcall(gethui)
        if ok and parent then return parent end
    end
    return CoreGui
end

local function corner(parent, radius)
    local value = Instance.new("UICorner")
    value.CornerRadius = UDim.new(0, radius or 12)
    value.Parent = parent
    return value
end

local function stroke(parent, color, transparency, thickness)
    local value = Instance.new("UIStroke")
    value.Color = color
    value.Transparency = transparency or 0
    value.Thickness = thickness or 1
    value.Parent = parent
    return value
end

local function label(parent, text, size, position, options)
    options = options or {}
    local value = Instance.new("TextLabel")
    value.BackgroundTransparency = 1
    value.BorderSizePixel = 0
    value.Text = tostring(text or "")
    value.TextColor3 = options.Color or Color3.fromRGB(235, 239, 240)
    value.Font = options.Font or Enum.Font.GothamMedium
    value.TextSize = options.TextSize or 14
    value.TextWrapped = options.Wrapped == true
    value.TextXAlignment = options.XAlignment or Enum.TextXAlignment.Left
    value.TextYAlignment = options.YAlignment or Enum.TextYAlignment.Center
    value.Size = size
    value.Position = position
    value.ZIndex = options.ZIndex or 2
    value.Parent = parent
    return value
end

local function button(parent, text, size, position, color)
    local value = Instance.new("TextButton")
    value.AutoButtonColor = false
    value.BackgroundColor3 = color or Color3.fromRGB(41, 164, 84)
    value.BorderSizePixel = 0
    value.Text = text
    value.TextColor3 = Color3.new(1, 1, 1)
    value.Font = Enum.Font.GothamBold
    value.TextSize = 15
    value.TextWrapped = true
    value.Size = size
    value.Position = position
    value.ZIndex = 4
    value.Parent = parent
    corner(value, 11)
    return value
end

local Profiles = {
    "Red Light, Green Light",
    "Dalgona",
    "Pentathlon - Biseokchigi",
    "Pentathlon - Ddakji",
    "Pentathlon - Gonggi",
    "Pentathlon - Jegichagi",
    "Pentathlon - Paengi",
    "Hide & Seek",
    "Jump Rope",
    "Mingle",
    "Tug of War",
    "Marbles",
    "Glass Bridge",
    "Rock, Paper, Scissors Minus One",
    "Fight Nights",
    "Rebellion",
    "Sky Squid",
    "Squid Game",
    "Escape",
}

local selectedIndex = 1
local mobile = UserInputService.TouchEnabled
local gui = Instance.new("ScreenGui")
gui.Name = "SquidNoMoStandaloneRecorder"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000001
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if type(syn) == "table" and type(syn.protect_gui) == "function" then pcall(syn.protect_gui, gui) end
gui.Parent = guiParent()

local panel = Instance.new("Frame")
panel.Name = "RecorderPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = mobile and UDim2.new(0.92, 0, 0, 360) or UDim2.fromOffset(520, 360)
panel.BackgroundColor3 = Color3.fromRGB(10, 16, 21)
panel.BackgroundTransparency = 0.02
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Parent = gui
corner(panel, 18)
stroke(panel, Color3.fromRGB(53, 226, 108), 0.06, 2)

local constraint = Instance.new("UISizeConstraint")
constraint.MinSize = Vector2.new(330, 350)
constraint.MaxSize = Vector2.new(560, 380)
constraint.Parent = panel

local title = label(panel, "SQUIDNOMO ROUND RECORDER", UDim2.new(1, -116, 0, 28), UDim2.fromOffset(18, 12), {
    Font = Enum.Font.GothamBlack, TextSize = 18, Color = Color3.fromRGB(58, 235, 113),
})
local versionLabel = label(panel, Version .. " • STANDALONE", UDim2.new(1, -116, 0, 18), UDim2.fromOffset(18, 39), {
    Font = Enum.Font.GothamBold, TextSize = 11, Color = Color3.fromRGB(154, 163, 166),
})

local minimize = button(panel, "—", UDim2.fromOffset(42, 34), UDim2.new(1, -94, 0, 12), Color3.fromRGB(83, 64, 148))
minimize.TextSize = 21
local close = button(panel, "×", UDim2.fromOffset(42, 34), UDim2.new(1, -48, 0, 12), Color3.fromRGB(142, 48, 61))
close.TextSize = 20

local profileCard = Instance.new("Frame")
profileCard.Position = UDim2.fromOffset(16, 70)
profileCard.Size = UDim2.new(1, -32, 0, 78)
profileCard.BackgroundColor3 = Color3.fromRGB(17, 27, 34)
profileCard.BorderSizePixel = 0
profileCard.Parent = panel
corner(profileCard, 13)
stroke(profileCard, Color3.fromRGB(68, 91, 103), 0.36, 1)

label(profileCard, "RECORDING PROFILE", UDim2.new(1, -24, 0, 20), UDim2.fromOffset(12, 7), {
    Font = Enum.Font.GothamBold, TextSize = 11, Color = Color3.fromRGB(135, 145, 151),
})
local previousProfile = button(profileCard, "◀", UDim2.fromOffset(48, 42), UDim2.fromOffset(10, 29), Color3.fromRGB(58, 73, 84))
local nextProfile = button(profileCard, "▶", UDim2.fromOffset(48, 42), UDim2.new(1, -58, 0, 29), Color3.fromRGB(58, 73, 84))
local profileLabel = label(profileCard, Profiles[selectedIndex], UDim2.new(1, -126, 0, 42), UDim2.fromOffset(63, 29), {
    Font = Enum.Font.GothamBold, TextSize = mobile and 14 or 15, Color = Color3.fromRGB(245, 248, 249),
    Wrapped = true, XAlignment = Enum.TextXAlignment.Center,
})

local statusCard = Instance.new("Frame")
statusCard.Position = UDim2.fromOffset(16, 158)
statusCard.Size = UDim2.new(1, -32, 0, 74)
statusCard.BackgroundColor3 = Color3.fromRGB(17, 27, 34)
statusCard.BorderSizePixel = 0
statusCard.Parent = panel
corner(statusCard, 13)

local statusTitle = label(statusCard, "READY", UDim2.new(1, -24, 0, 22), UDim2.fromOffset(12, 8), {
    Font = Enum.Font.GothamBlack, TextSize = 14, Color = Color3.fromRGB(58, 235, 113),
})
local statusDetail = label(statusCard, "Choose a profile, then tap START RECORDING before the round begins.", UDim2.new(1, -24, 0, 38), UDim2.fromOffset(12, 30), {
    Font = Enum.Font.GothamMedium, TextSize = 12, Color = Color3.fromRGB(185, 193, 196), Wrapped = true,
})

local start = button(panel, "START RECORDING", UDim2.new(1, -32, 0, 50), UDim2.fromOffset(16, 242), Color3.fromRGB(42, 171, 86))
local finish = button(panel, "FINISH & SAVE", UDim2.new(0.5, -20, 0, 48), UDim2.fromOffset(16, 300), Color3.fromRGB(43, 151, 100))
local cancel = button(panel, "CANCEL", UDim2.new(0.5, -20, 0, 48), UDim2.new(0.5, 4, 0, 300), Color3.fromRGB(151, 51, 64))

local bubble = Instance.new("TextButton")
bubble.Name = "RecorderBubble"
bubble.AnchorPoint = Vector2.new(1, 0)
bubble.Position = UDim2.new(1, -16, 0, 72)
bubble.Size = UDim2.fromOffset(230, 58)
bubble.BackgroundColor3 = Color3.fromRGB(10, 16, 21)
bubble.BorderSizePixel = 0
bubble.Font = Enum.Font.GothamBold
bubble.Text = "SquidNoMo Recorder • READY"
bubble.TextColor3 = Color3.fromRGB(58, 235, 113)
bubble.TextSize = 13
bubble.Visible = false
bubble.ZIndex = 10
bubble.Parent = gui
corner(bubble, 14)
stroke(bubble, Color3.fromRGB(53, 226, 108), 0.08, 2)

local function setEnabled(control, enabled)
    control.Active = enabled
    control.Selectable = enabled
    control.BackgroundTransparency = enabled and 0 or 0.55
    control.TextTransparency = enabled and 0 or 0.4
end

local function render(state)
    state = state or Recorder:GetStatus()
    local active = state.Active == true
    profileLabel.Text = active and tostring(state.Game or Profiles[selectedIndex]) or Profiles[selectedIndex]
    previousProfile.Visible = not active
    nextProfile.Visible = not active
    setEnabled(start, not active)
    setEnabled(finish, active)
    setEnabled(cancel, active)

    if active then
        local samples = tonumber(state.Samples) or 0
        local events = tonumber(state.Events) or 0
        statusTitle.Text = "● RECORDING"
        statusTitle.TextColor3 = Color3.fromRGB(255, 93, 111)
        statusDetail.Text = string.format("%d samples • %d events\nFinish only after completing the selected task successfully.", samples, events)
        bubble.Text = string.format("● RECORDING • %d samples", samples)
        bubble.TextColor3 = Color3.fromRGB(255, 93, 111)
    else
        statusTitle.Text = state.SavedPath and "SAVED" or "READY"
        statusTitle.TextColor3 = state.SavedPath and Color3.fromRGB(58, 235, 113) or Color3.fromRGB(58, 235, 113)
        statusDetail.Text = tostring(state.Message or "Choose a profile, then tap START RECORDING before the round begins.")
        bubble.Text = state.SavedPath and ("Recorder • SAVED TO " .. tostring(state.SavedPath)) or "SquidNoMo Recorder • READY"
        bubble.TextColor3 = Color3.fromRGB(58, 235, 113)
    end
end

local function changeProfile(offset)
    if Recorder.Active then return end
    selectedIndex = ((selectedIndex - 1 + offset) % #Profiles) + 1
    profileLabel.Text = Profiles[selectedIndex]
end
previousProfile.Activated:Connect(function() changeProfile(-1) end)
nextProfile.Activated:Connect(function() changeProfile(1) end)

start.Activated:Connect(function()
    local ok, detail = Recorder:Start(Profiles[selectedIndex])
    if not ok then
        statusTitle.Text = "START FAILED"
        statusTitle.TextColor3 = Color3.fromRGB(255, 100, 116)
        statusDetail.Text = tostring(detail)
    end
    render()
end)

finish.Activated:Connect(function()
    local ok, detail = Recorder:MarkSuccess()
    render()
    if not ok then
        statusTitle.Text = "SAVE FAILED"
        statusTitle.TextColor3 = Color3.fromRGB(255, 100, 116)
        statusDetail.Text = tostring(detail)
    else
        statusDetail.Text = "Successful trace saved to " .. tostring(detail) .. ". Upload that JSON here."
    end
end)

cancel.Activated:Connect(function()
    local ok, detail = Recorder:Stop(false)
    render()
    if not ok then statusDetail.Text = tostring(detail) end
end)

local minimized = false
local function setMinimized(state)
    minimized = state == true
    panel.Visible = not minimized
    bubble.Visible = minimized
end
minimize.Activated:Connect(function() setMinimized(true) end)
bubble.Activated:Connect(function() setMinimized(false) end)
close.Activated:Connect(function()
    if Recorder.Active then
        setMinimized(true)
    else
        gui:Destroy()
        Environment.__SquidNoMoStandaloneRecorderUI = nil
    end
end)

local subscription = Recorder:Subscribe(render)
gui.Destroying:Connect(function()
    if subscription then pcall(function() subscription:Disconnect() end) end
end)

Environment.__SquidNoMoStandaloneRecorderUI = {
    Gui = gui,
    Recorder = Recorder,
    Restore = function() setMinimized(false) end,
}

render()
return Recorder
