-- SquidNoMo game feature runtime, adaptive RLGL signal learner for beta 10.
-- All game modules use this single cooperative runtime. No game module starts its
-- own uncontrolled loop or performs an HTTP request.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end

local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table"
    and Environment.__SquidNoMoBuildManifest or {}
local Shared = Environment.__SquidNoMoFeatureRuntime
if type(Shared) ~= "table"
    or tostring(Shared.Revision) ~= tostring(Manifest.FeatureRuntimeRevision or "")
    or tonumber(Shared.BuildNumber) ~= tonumber(Manifest.BuildNumber)
then
    error("SquidNoMo shared runtime is unavailable; deploy and execute the complete build")
end

local GameRuntime = {
    Revision = tostring(Manifest.GameRuntimeRevision or "game-runtime-r10"),
    BuildNumber = tonumber(Manifest.BuildNumber) or 0,
    Shared = Shared,
    DetectionCache = nil,
    StableDetection = {Name = nil, Candidate = nil, Count = 0, ConfirmedAt = 0},
}
Environment.__SquidNoMoGameRuntime = GameRuntime

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function containsAny(value, tokens)
    local text = lower(value)
    for _, token in ipairs(tokens or {}) do
        token = lower(token)
        if token ~= "" and string.find(text, token, 1, true) then return true end
    end
    return false
end

local function getCharacter()
    local player = Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return player, character, humanoid, root
end

local function positionOf(instance)
    if not instance then return nil end
    if instance:IsA("BasePart") then return instance.Position end
    if instance:IsA("Attachment") then return instance.WorldPosition end
    if instance:IsA("Model") then
        local ok, pivot = pcall(instance.GetPivot, instance)
        if ok then return pivot.Position end
    end
    local part = instance:FindFirstChildWhichIsA("BasePart", true)
    return part and part.Position or nil
end

local function adorneeOf(instance)
    if not instance then return nil end
    if instance:IsA("Model") or instance:IsA("BasePart") then return instance end
    local parent = instance.Parent
    while parent and parent ~= Workspace do
        if parent:IsA("Model") then return parent end
        if parent:IsA("BasePart") then return parent end
        parent = parent.Parent
    end
    return instance
end

local function guiVisible(object)
    if not object or not object:IsA("GuiObject") or not object.Visible then return false end
    local current = object.Parent
    while current do
        if current:IsA("GuiObject") and not current.Visible then return false end
        if current:IsA("LayerCollector") and not current.Enabled then return false end
        current = current.Parent
    end
    return object.AbsoluteSize.X > 1 and object.AbsoluteSize.Y > 1
end

local function objectText(object)
    if not object then return "" end
    local parts = {object.Name, object.ClassName}
    local parent = object.Parent
    if parent then table.insert(parts, parent.Name) end
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        table.insert(parts, object.Text)
    elseif object:IsA("ValueBase") then
        table.insert(parts, tostring(object.Value))
    elseif object:IsA("ProximityPrompt") then
        table.insert(parts, object.ActionText)
        table.insert(parts, object.ObjectText)
    end
    return lower(table.concat(parts, " "))
end

local function isGreen(color)
    if typeof(color) ~= "Color3" then return false end
    return color.G > color.R * 1.18 and color.G > color.B * 1.08 and color.G > 0.38
end

local function isRed(color)
    if typeof(color) ~= "Color3" then return false end
    return color.R > color.G * 1.18 and color.R > color.B * 1.08 and color.R > 0.42
end

local Profiles = {
    {
        Name = "Red Light, Green Light",
        Aliases = {"red light green light", "red light, green light", "rlgl"},
        Visual = {"younghee", "young hee", "yeonghee", "mugunghwa", "do not move", "don't move", "reach the finish line", "green light", "red light"},
        World = {"younghee", "doll", "finishline", "finish line", "startingline", "start line", "redlightsignal", "greenlightsignal"},
        Groups = {{"younghee", "doll", "mugunghwa"}, {"finish", "red light", "green light", "do not move"}},
        Minimum = 42,
    },
    {
        Name = "Dalgona",
        Aliases = {"dalgona", "honeycomb"},
        Visual = {"cut the shape", "trace the shape", "carve", "cookie shape", "needle"},
        World = {"dalgona", "honeycomb", "cookie", "needle", "shape outline"},
        Groups = {{"dalgona", "honeycomb", "cookie"}, {"cut", "trace", "carve", "needle"}},
        Minimum = 38,
    },
    {
        Name = "Pentathlon",
        Aliases = {"pentathlon", "six legged pentathlon", "five legged pentathlon"},
        Visual = {"ddakji", "gonggi", "jegichagi", "jegi", "paengi", "biseokchigi", "spinning top"},
        World = {"pentathlon", "ddakji", "gonggi", "jegi", "paengi", "biseok"},
        Groups = {{"pentathlon", "ddakji", "gonggi", "jegi", "paengi", "biseok"}},
        Minimum = 34,
    },
    {
        Name = "Hide & Seek",
        Aliases = {"hide & seek", "hide and seek", "hide seek"},
        Visual = {"you are a hider", "you are a seeker", "find a key", "grab a knife", "unlock the exit", "keys & knives"},
        World = {"maze exit", "key room", "hide seek", "hider spawn", "seeker spawn"},
        Groups = {{"hider", "seeker", "hide & seek", "hide and seek"}, {"key", "knife", "exit", "maze"}},
        Minimum = 40,
    },
    {
        Name = "Jump Rope",
        Aliases = {"jump rope", "jumprope"},
        Visual = {"reach the other side", "make it to the other side", "cross the bridge", "swinging rope"},
        World = {"jump rope", "jumprope", "swinging bar", "rope bridge", "rope pivot"},
        Groups = {{"jump rope", "jumprope", "swinging rope"}, {"other side", "bridge", "finish"}},
        Minimum = 40,
    },
    {
        Name = "Marbles",
        Aliases = {"marbles", "marble game"},
        Visual = {"throw the marble", "ring shooter", "closest marble", "marble count"},
        World = {"marble", "ring target", "marble hole", "throw line"},
        Groups = {{"marble", "marbles"}, {"throw", "ring", "target", "hole"}},
        Minimum = 38,
    },
    {
        Name = "Mingle",
        Aliases = {"mingle"},
        Visual = {"find a room", "enter a room", "players per room", "group of", "room with", "carousel"},
        World = {"mingle", "carousel room", "room door", "room trigger"},
        Groups = {{"mingle", "carousel"}, {"room", "group of", "players"}},
        Minimum = 38,
    },
    {
        Name = "Fight Nights",
        Aliases = {"fight nights", "fight night", "night brawl", "lights out", "dinner fight"},
        Visual = {"survive the night", "lights out", "night brawl", "final dinner", "fight until"},
        World = {"night brawl", "lights out", "dinner arena", "brawl arena"},
        Groups = {{"night brawl", "lights out", "dinner fight", "fight night"}},
        Negative = {"rebellion", "uprising", "armory"},
        Minimum = 38,
    },
    {
        Name = "Glass Bridge",
        Aliases = {"glass bridge", "glass stepping stones", "glass stepping"},
        Visual = {"choose a glass", "cross the glass", "glass maker", "reach the other side"},
        World = {"glass bridge", "glass panels", "bridge glass", "glass tile"},
        Groups = {{"glass"}, {"bridge", "panel", "stepping"}},
        Minimum = 42,
    },
    {
        Name = "Rebellion",
        Aliases = {"rebellion", "uprising"},
        Visual = {"take the armory", "fight the guards", "reach the frontman", "steal a weapon"},
        World = {"rebellion", "uprising", "armory", "frontman room", "command room"},
        Groups = {{"rebellion", "uprising", "armory"}, {"guard", "frontman", "weapon"}},
        Minimum = 40,
    },
    {
        Name = "Rock, Paper, Scissors Minus One",
        Aliases = {"rock paper scissors minus one", "rock, paper, scissors minus one", "minus one"},
        Visual = {"remove one", "choose two", "rock", "paper", "scissors"},
        World = {"rps", "minus one"},
        Groups = {{"minus one", "remove one"}, {"rock", "paper", "scissors"}},
        Minimum = 42,
    },
    {
        Name = "Sky Squid",
        Aliases = {"sky squid", "sky squid game"},
        Visual = {"push a player off", "floating platform", "stay on the platform", "last platform"},
        World = {"sky squid", "floating platform", "sky platform"},
        Groups = {{"sky squid", "floating platform"}, {"push", "platform"}},
        Minimum = 40,
    },
    {
        Name = "Squid Game",
        Aliases = {"squid game final", "final squid game", "squid court"},
        Visual = {"attack the goal", "defend the goal", "offense team", "defense team", "cross the squid"},
        World = {"squid court", "squid game court", "offense spawn", "defense spawn"},
        Groups = {{"squid court", "attack the goal", "defend the goal", "offense team", "defense team"}},
        Negative = {"sky squid", "squidnomo", "squid game x"},
        Minimum = 42,
    },
    {
        Name = "Tug of War",
        Aliases = {"tug of war", "tugofwar"},
        Visual = {"pull meter", "keep the marker", "team rope", "tap to pull", "pull now"},
        World = {"tug of war", "tugofwar", "rope team", "pull station"},
        Groups = {{"tug of war", "tugofwar"}, {"pull", "rope", "meter"}},
        Minimum = 40,
    },
    {
        Name = "Escape",
        Aliases = {"island escape", "escape the island", "escape route"},
        Visual = {"extraction boat", "return to the boat", "leave the island", "reach the dock"},
        World = {"extraction boat", "escape island", "escape dock"},
        Groups = {{"escape", "extraction"}, {"island", "boat", "dock"}},
        Minimum = 44,
    },
}

local ProfileByName = {}
for _, profile in ipairs(Profiles) do ProfileByName[profile.Name] = profile end
GameRuntime.Profiles = Profiles

local function addEvidence(list, text, weight, source)
    text = lower(text)
    if text == "" then return end
    table.insert(list, {Text = text, Weight = tonumber(weight) or 1, Source = source or "unknown"})
end

local function addTableEvidence(list, value, prefix, depth, seen)
    if depth > 4 or type(value) ~= "table" or seen[value] then return end
    seen[value] = true
    for key, item in pairs(value) do
        local label = tostring(prefix or "") .. " " .. tostring(key)
        if type(item) == "table" then
            addTableEvidence(list, item, label, depth + 1, seen)
        elseif type(item) == "string" or type(item) == "number" or type(item) == "boolean" then
            addEvidence(list, label .. " " .. tostring(item), 42, "teleport")
        end
    end
end

function GameRuntime:_CollectEvidence()
    local evidence = {}
    local snapshot = Shared:GetVisualSnapshot(true)
    for _, item in ipairs(snapshot.Items or {}) do
        local weight = item.TextSize and item.TextSize >= 30 and 26 or 18
        addEvidence(evidence, tostring(item.Text or "") .. " " .. tostring(item.Context or ""), weight, "hud")
    end

    local player, character, _, root = getCharacter()
    if player then
        if player.Team then addEvidence(evidence, player.Team.Name, 8, "team") end
        for _, object in ipairs({player, character}) do
            if object then
                for _, attributeName in ipairs({
                    "CurrentGame", "Game", "GameName", "SelectedGame", "CurrentRound",
                    "Round", "RoundName", "Mode", "GameMode", "Minigame", "CurrentMap", "MapName", "Stage"
                }) do
                    local ok, value = pcall(object.GetAttribute, object, attributeName)
                    if ok and value ~= nil then
                        addEvidence(evidence, attributeName .. " " .. tostring(value), 48, "state")
                    end
                end
            end
        end
        pcall(function()
            addTableEvidence(evidence, player:GetJoinData(), "join", 0, {})
        end)
        local backpack = player:FindFirstChildOfClass("Backpack")
        for _, container in ipairs({character, backpack}) do
            if container then
                for _, child in ipairs(container:GetChildren()) do
                    if child:IsA("Tool") then addEvidence(evidence, child.Name, 9, "tool") end
                end
            end
        end
    end
    pcall(function()
        addTableEvidence(evidence, TeleportService:GetLocalPlayerTeleportData(), "teleport", 0, {})
    end)

    for _, service in ipairs({Workspace, ReplicatedStorage}) do
        for attributeName, value in pairs(service:GetAttributes()) do
            if containsAny(attributeName, {"game", "round", "mode", "stage", "map", "minigame"}) then
                addEvidence(evidence, attributeName .. " " .. tostring(value), 40, "state")
            end
        end
    end

    local stateObjects = Shared:FindTargets({
        Scope = "Workspace",
        TargetClasses = {"ValueBase", "ProximityPrompt", "Sound"},
        MaxTargets = 260,
        CacheTTL = 0.7,
    })
    for _, object in ipairs(stateObjects) do
        if object:IsA("ValueBase") then
            local name = lower(object.Name)
            if containsAny(name, {"game", "round", "mode", "stage", "map", "state", "minigame"}) then
                addEvidence(evidence, objectText(object), 38, "state")
            end
        elseif object:IsA("ProximityPrompt") and object.Enabled then
            addEvidence(evidence, objectText(object), 11, "world")
        elseif object:IsA("Sound") and object.Playing then
            addEvidence(evidence, objectText(object), 10, "world")
        end
    end

    if root then
        local parts = {}
        local ok, result = pcall(function()
            return Workspace:GetPartBoundsInRadius(root.Position, 520)
        end)
        if ok and type(result) == "table" then parts = result end
        local limit = math.min(#parts, 650)
        for index = 1, limit do
            local part = parts[index]
            if part and part.Parent and part.Transparency < 0.995 then
                local parent = part.Parent
                local grandparent = parent and parent.Parent
                addEvidence(evidence, part.Name .. " " .. (parent and parent.Name or "") .. " " .. (grandparent and grandparent.Name or ""), 5, "world")
            end
        end
    end
    return evidence
end

local function evidenceHas(evidence, tokens, sources)
    for _, item in ipairs(evidence) do
        if (not sources or sources[item.Source]) and containsAny(item.Text, tokens) then return true end
    end
    return false
end

local function profileScore(profile, evidence)
    local score, hits, strongest = 0, 0, 0
    for _, item in ipairs(evidence) do
        local matched = 0
        if containsAny(item.Text, profile.Aliases) then
            matched = (item.Source == "state" or item.Source == "teleport") and 95 or 42
        elseif containsAny(item.Text, profile.Visual) then
            matched = item.Source == "hud" and item.Weight * 1.25 or item.Weight * 0.75
        elseif containsAny(item.Text, profile.World) then
            matched = item.Source == "world" and item.Weight or item.Weight * 0.55
        end
        if matched > 0 then
            score = score + matched
            hits = hits + 1
            if matched > strongest then strongest = matched end
        end
        if profile.Negative and containsAny(item.Text, profile.Negative) then
            score = score - math.max(8, item.Weight * 0.9)
        end
    end
    if profile.Groups then
        local complete = true
        for _, group in ipairs(profile.Groups) do
            if not evidenceHas(evidence, group) then complete = false break end
        end
        if complete then score, hits = score + 32, hits + #profile.Groups end
    end
    return score, hits, strongest
end

function GameRuntime:DetectGame(force)
    local now = os.clock()
    if not force and self.DetectionCache and now - self.DetectionCache.Time < 0.34 then
        return self.DetectionCache.Name, self.DetectionCache.Score, self.DetectionCache.Detail
    end
    local evidence = self:_CollectEvidence()
    local ranked = {}
    for _, profile in ipairs(Profiles) do
        local score, hits, strongest = profileScore(profile, evidence)
        table.insert(ranked, {Name = profile.Name, Score = score, Hits = hits, Strongest = strongest, Minimum = profile.Minimum or 40})
    end
    table.sort(ranked, function(a, b)
        if a.Score == b.Score then return a.Name < b.Name end
        return a.Score > b.Score
    end)
    local best, second = ranked[1], ranked[2]
    local candidate = nil
    if best and best.Score >= best.Minimum and best.Hits >= 2
        and (best.Strongest >= 34 or best.Hits >= 4)
        and (not second or best.Score - second.Score >= 8)
    then
        candidate = best.Name
    end

    local hint = Environment.__SquidNoMoManualGameHint
    if not candidate and type(hint) == "table" and tonumber(hint.ExpiresAt or 0) > now then
        candidate = hint.Name
        best = {Name = hint.Name, Score = 31, Hits = 1, Strongest = 31, Minimum = 0}
    end

    local stable = self.StableDetection
    if candidate and candidate == stable.Candidate then
        stable.Count = stable.Count + 1
    elseif candidate then
        stable.Candidate = candidate
        stable.Count = 1
    else
        stable.Candidate = nil
        stable.Count = 0
    end
    if candidate and (stable.Count >= 2 or (best and best.Score >= 82)) then
        stable.Name = candidate
        stable.ConfirmedAt = now
    elseif not candidate and stable.Name and now - (stable.ConfirmedAt or 0) > 5.5 then
        stable.Name = nil
    end

    if stable.Name then
        Environment.__SquidNoMoDetectedGame = stable.Name
        Environment.__SquidNoMoDetectedGameAt = now
    end
    local detail = best and string.format("%s score %.0f", tostring(best.Name), tonumber(best.Score) or 0) or "no game evidence"
    self.DetectionCache = {Time = now, Name = stable.Name, Score = best and best.Score or 0, Detail = detail, Evidence = evidence}
    return stable.Name, best and best.Score or 0, detail
end

function GameRuntime:IsGameActive(name)
    local detected, score = self:DetectGame(false)
    if detected == name then return true, "Detected " .. name end
    if detected then return false, "Paused: " .. detected .. " is active" end

    local profile = ProfileByName[name]
    local evidence = self.DetectionCache and self.DetectionCache.Evidence or self:_CollectEvidence()
    if profile then
        local localScore, hits, strongest = profileScore(profile, evidence)
        if localScore >= (profile.Minimum or 40) + 12 and hits >= 3 and strongest >= 24 then
            return true, "Matched live " .. name .. " cues"
        end
    end
    return false, "Waiting for a confirmed " .. tostring(name) .. " round"
end

local LegacyDetect = Shared.DetectGameCategory
Shared.DetectGameCategory = function(_, force)
    return GameRuntime:DetectGame(force == true)
end
Shared.SetManualGameHint = function(_, name, ttl)
    if type(name) ~= "string" or name == "" then return false end
    Environment.__SquidNoMoManualGameHint = {Name = name, ExpiresAt = os.clock() + math.max(tonumber(ttl) or 14, 3)}
    GameRuntime.DetectionCache = nil
    return true
end

local Feature = {}
Feature.__index = Feature

function Feature:_SetStatus(state, detail)
    state, detail = tostring(state or "Unknown"), tostring(detail or "")
    if self.Status == state and self.StatusDetail == detail then return end
    self.Status, self.StatusDetail = state, detail
    for id, callback in pairs(self.StatusListeners) do
        local ok = pcall(callback, state, detail, self)
        if not ok then self.StatusListeners[id] = nil end
    end
end

function Feature:GetStatus() return self.Status, self.StatusDetail end
function Feature:GetLastError() return self.LastError end
function Feature:IsEnabled() return self.Enabled == true end
function Feature:GetState() return self.Enabled and "on" or "off" end
function Feature:Enable() return self:Toggle(true) end
function Feature:Disable() return self:Toggle(false) end

function Feature:SubscribeStatus(callback)
    self.NextListenerId = self.NextListenerId + 1
    local id = self.NextListenerId
    self.StatusListeners[id] = callback
    local disconnected = false
    return {Disconnect = function()
        if disconnected then return end
        disconnected = true
        self.StatusListeners[id] = nil
    end}
end

function Feature:_TrackInstance(instance)
    if instance then table.insert(self.Instances, instance) end
    return instance
end

function Feature:_TrackConnection(connection)
    if connection then table.insert(self.Connections, connection) end
    return connection
end

function Feature:_SetPresentationEnabled(state)
    state = state == true
    for _, instance in ipairs(self.Instances) do
        pcall(function()
            if instance:IsA("Highlight") or instance:IsA("UIStroke") then
                instance.Enabled = state
            elseif instance:IsA("ScreenGui") or instance:IsA("BillboardGui") then
                instance.Enabled = state
            end
        end)
    end
end

function Feature:_Pause(detail)
    pcall(function() Shared:StopMovement(self) end)
    pcall(function() Shared:ReleaseActions(self) end)
    if type(self.OnInactive) == "function" then pcall(self.OnInactive, self) end
    self:_SetPresentationEnabled(false)
    self:_SetStatus("Waiting", detail)
    return false
end

function Feature:_Cleanup()
    Shared.Scheduler:Remove(self)
    pcall(function() Shared:StopMovement(self) end)
    pcall(function() Shared:ReleaseActions(self) end)
    if type(self.Cleanup) == "function" then pcall(self.Cleanup, self) end
    for _, connection in ipairs(self.Connections) do pcall(function() connection:Disconnect() end) end
    for _, instance in ipairs(self.Instances) do pcall(function() instance:Destroy() end) end
    self.Connections, self.Instances = {}, {}
    self.Cleanup = nil
    self.OnInactive = nil
end

local Handlers = {}

local function findTarget(config, rootPosition)
    return Shared:FindBestTarget({
        Scope = config.Scope or "Workspace",
        TargetTokens = config.TargetTokens or {},
        TargetNames = config.TargetNames or {},
        RequiredTokens = config.RequiredTokens or {},
        ExcludeTokens = config.ExcludeTokens or {},
        TargetClasses = config.TargetClasses or {"Model", "BasePart", "Tool", "ProximityPrompt"},
        ReturnAdornee = true,
        MaxTargets = config.MaxTargets or 120,
        CacheTTL = config.CacheTTL or 0.55,
        PreferInteractive = config.PreferInteractive == true,
        MaxDistance = config.MaxDistance,
    }, rootPosition)
end

local function setHighlight(feature, target, color, label)
    target = adorneeOf(target)
    if not target or not target.Parent then return nil end
    feature.HighlightMap = feature.HighlightMap or setmetatable({}, {__mode = "k"})
    local existing = feature.HighlightMap[target]
    if existing and existing.Parent then
        existing.Enabled = true
        existing.FillColor = color
        existing.OutlineColor = color
        return existing
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "SquidNoMo_" .. feature.Id
    highlight.Adornee = target
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.72
    highlight.OutlineTransparency = 0.04
    highlight.Parent = target
    feature.HighlightMap[target] = highlight
    feature:_TrackInstance(highlight)
    if label then
        local part = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart", true)
        if part then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "SquidNoMoLabel"
            billboard.Size = UDim2.fromOffset(190, 32)
            billboard.StudsOffset = Vector3.new(0, 4, 0)
            billboard.AlwaysOnTop = true
            billboard.Adornee = part
            billboard.Parent = part
            local text = Instance.new("TextLabel")
            text.Size = UDim2.fromScale(1, 1)
            text.BackgroundTransparency = 1
            text.Font = Enum.Font.GothamBold
            text.TextSize = 14
            text.TextColor3 = color
            text.TextStrokeTransparency = 0.25
            text.Text = label
            text.Parent = billboard
            feature:_TrackInstance(billboard)
        end
    end
    return highlight
end

local function localRoleAllowed(config)
    if not config.Role then return true end
    if config.Role == "Hider" or config.Role == "Seeker" then
        local role = Shared:GetHideSeekRole()
        if not role then return false, "Waiting for a confirmed Hide & Seek role" end
        if role ~= config.Role then return false, "Waiting for " .. config.Role .. " role" end
    end
    return true
end

Handlers.Highlight = function(feature)
    local config = feature.Config
    local seen, count = {}, 0
    if config.PlayerMode then
        local localPlayer = Players.LocalPlayer
        local localRole = config.Game == "Hide & Seek" and Shared:GetHideSeekRole() or nil
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if player ~= localPlayer and character and humanoid and humanoid.Health > 0 then
                local include = true
                if config.PlayerTokens and #config.PlayerTokens > 0 then
                    include = containsAny(player.Name .. " " .. player.DisplayName .. " " .. (player.Team and player.Team.Name or "") .. " " .. objectText(character), config.PlayerTokens)
                elseif config.Game == "Hide & Seek" and localRole then
                    local text = lower(player.Name .. " " .. player.DisplayName .. " " .. (player.Team and player.Team.Name or "") .. " " .. objectText(character))
                    if localRole == "Hider" then include = containsAny(text, {"hunter", "seeker", "killer"}) end
                    if localRole == "Seeker" then include = not containsAny(text, {"hunter", "seeker", "killer"}) end
                end
                if include then
                    setHighlight(feature, character, config.Color or Color3.fromRGB(255, 80, 100), config.Label)
                    seen[character], count = true, count + 1
                end
            end
        end
    end
    for _, target in ipairs(Shared:FindTargets({
        Scope = config.Scope or "Workspace",
        TargetTokens = config.TargetTokens or {},
        ExcludeTokens = config.ExcludeTokens or {},
        TargetClasses = config.TargetClasses or {"Model", "BasePart", "Tool"},
        ReturnAdornee = true,
        MaxTargets = config.MaxTargets or 40,
        CacheTTL = config.CacheTTL or 0.8,
    })) do
        setHighlight(feature, target, config.Color or Color3.fromRGB(60, 220, 255), config.Label)
        seen[target], count = true, count + 1
    end
    if feature.HighlightMap then
        for target, highlight in pairs(feature.HighlightMap) do
            if not seen[target] and highlight and highlight.Parent then highlight.Enabled = false end
        end
    end
    return count > 0, count > 0 and ("Tracking " .. count .. " target(s)") or (config.WaitingMessage or "Waiting for matching targets")
end

Handlers.GuiHighlight = function(feature)
    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return false, "Waiting for PlayerGui" end
    local best, bestScore = nil, -math.huge
    for _, object in ipairs(playerGui:GetDescendants()) do
        if object:IsA("GuiObject") and guiVisible(object) then
            local text = objectText(object)
            if containsAny(text, feature.Config.TargetTokens) then
                local score = object.AbsoluteSize.X * object.AbsoluteSize.Y + object.ZIndex * 100
                if score > bestScore then best, bestScore = object, score end
            end
        end
    end
    if not best then return false, feature.Config.WaitingMessage or "Waiting for the matching game interface" end
    if feature.GuiTarget ~= best or not feature.GuiStroke or not feature.GuiStroke.Parent then
        if feature.GuiStroke then pcall(function() feature.GuiStroke:Destroy() end) end
        local stroke = Instance.new("UIStroke")
        stroke.Name = "SquidNoMoGameGuide"
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Color = feature.Config.Color or Color3.fromRGB(60, 220, 255)
        stroke.Thickness = feature.Config.Thickness or 4
        stroke.Transparency = 0.02
        stroke.Parent = best
        feature.GuiTarget, feature.GuiStroke = best, stroke
        feature:_TrackInstance(stroke)
    end
    return true, "Highlighting " .. tostring(best.Name)
end

Handlers.StateHUD = function(feature)
    if not feature.Hud then
        local parent
        if type(gethui) == "function" then pcall(function() parent = gethui() end) end
        if not parent then
            local player = Players.LocalPlayer
            parent = player and player:FindFirstChildOfClass("PlayerGui")
        end
        if not parent then pcall(function() parent = game:GetService("CoreGui") end) end
        if not parent then return false, "Waiting for a compatible UI parent" end
        local gui = Instance.new("ScreenGui")
        gui.Name = "SquidNoMoGameState"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 999985
        gui.Parent = parent
        local label = Instance.new("TextLabel")
        label.AnchorPoint = Vector2.new(0.5, 0)
        label.Position = UDim2.new(0.5, 0, 0, 72)
        label.Size = UDim2.fromOffset(260, 48)
        label.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
        label.BackgroundTransparency = 0.08
        label.BorderSizePixel = 0
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 18
        label.TextStrokeTransparency = 0.55
        label.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = label
        feature.Hud = label
        feature:_TrackInstance(gui)
    end
    local state, signal = Shared:GetRLGLStateDetail()
    local source = signal and signal.Source or "no live source"
    if state == "Green" then
        feature.Hud.Text = "GREEN LIGHT — MOVE"
        feature.Hud.TextColor3 = Color3.fromRGB(80, 255, 130)
        return true, "Green confirmed via " .. source
    elseif state == "Red" then
        feature.Hud.Text = "RED LIGHT — STOP"
        feature.Hud.TextColor3 = Color3.fromRGB(255, 78, 90)
        return true, "Red confirmed via " .. source
    end
    feature.Hud.Text = "SAFE STOP — LEARNING SIGNAL"
    feature.Hud.TextColor3 = Color3.fromRGB(255, 215, 85)
    local scores = signal and string.format(" (R:%d G:%d)", signal.RedScore or 0, signal.GreenScore or 0) or ""
    return false, "Learning chant, crowd, and doll cues" .. scores
end

local function rlglFallbackTarget(feature, root)
    local player = Players.LocalPlayer
    local farthestPosition, farthestDistance
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local character = other.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local otherRoot = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and otherRoot then
                local offset = otherRoot.Position - root.Position
                local horizontal = Vector3.new(offset.X, 0, offset.Z)
                local distance = horizontal.Magnitude
                if distance >= 18 and distance <= 500 and (not farthestDistance or distance > farthestDistance) then
                    farthestPosition, farthestDistance = otherRoot.Position, distance
                end
            end
        end
    end
    if farthestPosition then
        local direction = Vector3.new(
            farthestPosition.X - root.Position.X,
            0,
            farthestPosition.Z - root.Position.Z
        )
        if direction.Magnitude > 0.01 then
            direction = direction.Unit
            return farthestPosition + direction * 14, "furthest live contestant"
        end
    end

    if not feature.RLGLFieldDirection then
        local camera = Workspace.CurrentCamera
        local look = camera and camera.CFrame.LookVector or root.CFrame.LookVector
        look = Vector3.new(look.X, 0, look.Z)
        if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
        feature.RLGLFieldDirection = look.Unit
        feature.RLGLFieldOrigin = root.Position
    end
    return (feature.RLGLFieldOrigin or root.Position) + feature.RLGLFieldDirection * 220,
        "captured field heading"
end

Handlers.RLGLMove = function(feature)
    local _, _, humanoid, root = getCharacter()
    if not humanoid or not root then return false, "Waiting for the local character" end
    local state, signal = Shared:GetRLGLStateDetail()
    if state ~= "Green" then
        Shared:StopMovement(feature, state == "Red")
        if state == "Red" then
            return false, "Red confirmed via " .. tostring(signal and signal.Source or "live detector")
        end
        local scores = signal and string.format("R:%d G:%d", signal.RedScore or 0, signal.GreenScore or 0) or "no score"
        return false, "Signal uncertain — " .. scores
    end

    local target = findTarget(feature.Config, root.Position)
    local position = positionOf(target)
    local stopDistance = feature.Config.StopDistance or 8
    local targetSource = "finish zone"
    if not position then
        target = Shared:GetRLGLDoll()
        position = positionOf(target)
        stopDistance = math.max(stopDistance, 16)
        targetSource = "doll-side finish fallback"
    end
    if not position then
        position, targetSource = rlglFallbackTarget(feature, root)
        stopDistance = math.max(stopDistance, 10)
    end
    if not position then return false, "Green confirmed; no safe travel direction available" end

    local moved, detail = Shared:MoveTo(position, feature, {
        Direct = true,
        StopDistance = stopDistance,
        MovementPriority = feature.Config.MovementPriority or 95,
        CommandInterval = 0.18,
        LeaseDuration = 0.30,
    })
    local source = signal and signal.Source or "live detector"
    return moved, moved and ("Moving via " .. source .. " toward " .. targetSource) or detail
end

Handlers.AntiStuck = function(feature)
    local _, _, humanoid, root = getCharacter()
    if not humanoid or not root then return false, "Waiting for the local character" end
    local state, signal = Shared:GetRLGLStateDetail()
    if state ~= "Green" then
        feature.LastPosition, feature.LastProgressAt = root.Position, os.clock()
        return false, state == "Red"
            and ("Recovery stopped: red via " .. tostring(signal and signal.Source or "live detector"))
            or "Recovery waits for a confirmed green signal"
    end
    if humanoid.MoveDirection.Magnitude < 0.05 then
        feature.LastPosition, feature.LastProgressAt = root.Position, os.clock()
        return true, "No movement command to recover"
    end
    if not feature.LastPosition or (root.Position - feature.LastPosition).Magnitude >= (feature.Config.MinimumMovement or 0.4) then
        feature.LastPosition, feature.LastProgressAt = root.Position, os.clock()
        return true, "Movement progress detected"
    end
    if os.clock() - (feature.LastProgressAt or 0) >= (feature.Config.StuckSeconds or 2.1) then
        humanoid.Jump = true
        pcall(humanoid.ChangeState, humanoid, Enum.HumanoidStateType.Jumping)
        feature.LastPosition, feature.LastProgressAt = root.Position, os.clock()
        return true, "Applied one jump recovery"
    end
    return true, "Checking movement progress"
end

Handlers.JumpBoost = function(feature)
    local _, _, humanoid = getCharacter()
    if not humanoid then return false, "Waiting for the local character" end
    if feature.OriginalJumpPower == nil then
        feature.OriginalJumpPower = humanoid.JumpPower
        feature.OriginalJumpHeight = humanoid.JumpHeight
        feature.OriginalUseJumpPower = humanoid.UseJumpPower
        feature.TrackedHumanoid = humanoid
    end
    local function restore(owner)
        local tracked = owner.TrackedHumanoid
        if tracked and tracked.Parent then
            pcall(function()
                tracked.UseJumpPower = owner.OriginalUseJumpPower
                tracked.JumpPower = owner.OriginalJumpPower
                tracked.JumpHeight = owner.OriginalJumpHeight
            end)
        end
        owner.OriginalJumpPower = nil
        owner.OriginalJumpHeight = nil
        owner.OriginalUseJumpPower = nil
        owner.TrackedHumanoid = nil
    end
    feature.OnInactive = restore
    feature.Cleanup = restore
    if humanoid.UseJumpPower then
        humanoid.JumpPower = math.max(feature.OriginalJumpPower or 50, feature.Config.JumpPower or 62)
    else
        humanoid.JumpHeight = math.max(feature.OriginalJumpHeight or 7.2, feature.Config.JumpHeight or 10.5)
    end
    return true, "Jump boost is active only during Jump Rope"
end

Handlers.RopeJump = function(feature)
    local _, _, humanoid, root = getCharacter()
    if not humanoid or not root then return false, "Waiting for the local character" end
    local rope = Shared:ObserveRope(feature, root, feature.Config.TargetTokens or {"rope", "swing", "bar"})
    if not rope then return false, "Waiting for the moving rope" end
    if humanoid.FloorMaterial ~= Enum.Material.Air
        and os.clock() - (feature.LastAction or 0) >= (feature.Config.Cooldown or 0.62)
        and rope.Distance <= (feature.Config.TriggerDistance or 17)
        and math.abs(rope.Vertical or 0) <= 11
        and (rope.Approaching or rope.Distance <= 5)
    then
        humanoid.Jump = true
        pcall(humanoid.ChangeState, humanoid, Enum.HumanoidStateType.Jumping)
        feature.LastAction = os.clock()
        return true, string.format("Jumped approaching rope at %.1f studs", rope.Distance)
    end
    return true, string.format("Tracking rope at %.1f studs", rope.Distance)
end

Handlers.RopeCourse = function(feature)
    local _, character, humanoid, root = getCharacter()
    if not character or not humanoid or not root then return false, "Waiting for the local character" end
    local finish = findTarget(feature.Config, root.Position)
    local finishPosition = positionOf(finish)
    if not finishPosition then return false, "Waiting for the course finish" end
    local rope = Shared:ObserveRope(feature, root, feature.Config.ObstacleTokens or {"rope", "swing", "bar"})
    if rope and rope.Approaching and rope.Distance <= (feature.Config.JumpDistance or 17) then
        Shared:StopMovement(feature)
        if humanoid.FloorMaterial ~= Enum.Material.Air and os.clock() - (feature.LastAction or 0) >= 0.62 then
            humanoid.Jump = true
            pcall(humanoid.ChangeState, humanoid, Enum.HumanoidStateType.Jumping)
            feature.LastAction = os.clock()
            return true, "Jumping the approaching rope"
        end
        return true, "Holding for the rope window"
    end
    local direction = Vector3.new(finishPosition.X - root.Position.X, 0, finishPosition.Z - root.Position.Z)
    if direction.Magnitude > 1 and humanoid.FloorMaterial ~= Enum.Material.Air then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {character}
        local ahead = root.Position + direction.Unit * 5
        if not Workspace:Raycast(ahead + Vector3.new(0, 2, 0), Vector3.new(0, -9, 0), params)
            and os.clock() - (feature.LastAction or 0) >= 0.62
        then
            humanoid.Jump = true
            feature.LastAction = os.clock()
        end
    end
    local moved, detail = Shared:MoveTo(finishPosition, feature, {
        Direct = true,
        StopDistance = feature.Config.StopDistance or 7,
        MovementPriority = feature.Config.MovementPriority or 70,
        CommandInterval = 0.34,
        LeaseDuration = 0.46,
    })
    return moved, moved and "Advancing during a safe rope window" or detail
end

Handlers.LaneKeeper = function(feature)
    local _, _, _, root = getCharacter()
    if not root then return false, "Waiting for the local character" end
    if not feature.Anchor then feature.Anchor = root.Position return true, "Saved current lane" end
    local target = findTarget(feature.Config, root.Position)
    local finish = positionOf(target)
    if not finish then return false, "Waiting for the finish direction" end
    local direction = Vector3.new(finish.X - feature.Anchor.X, 0, finish.Z - feature.Anchor.Z)
    if direction.Magnitude < 1 then return false, "Finish direction is not ready" end
    direction = direction.Unit
    local displacement = Vector3.new(root.Position.X - feature.Anchor.X, 0, root.Position.Z - feature.Anchor.Z)
    local desired = feature.Anchor + direction * displacement:Dot(direction)
    desired = Vector3.new(desired.X, root.Position.Y, desired.Z)
    local errorDistance = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(desired.X, 0, desired.Z)).Magnitude
    if errorDistance > (feature.Config.MaxDistance or 7) then
        local moved, detail = Shared:MoveTo(desired, feature, {
            Direct = true,
            StopDistance = 1.5,
            MovementPriority = feature.Config.MovementPriority or 25,
            CommandInterval = 0.48,
        })
        return moved, moved and "Recentering in the lane" or detail
    end
    return true, string.format("Lane offset %.1f studs", errorDistance)
end

Handlers.PathTo = function(feature)
    local roleOk, roleDetail = localRoleAllowed(feature.Config)
    if not roleOk then return false, roleDetail end
    local _, _, _, root = getCharacter()
    if not root then return false, "Waiting for the local character" end
    if feature.Config.SkipIfToolTokens and Shared:FindTool(feature.Config.SkipIfToolTokens) then
        return true, "Required item already collected"
    end
    if feature.Config.RequireToolTokens and not Shared:FindTool(feature.Config.RequireToolTokens) then
        return false, "Waiting for the required key or tool"
    end
    local target, distance = findTarget(feature.Config, root.Position)
    local position = positionOf(target)
    if not position then return false, feature.Config.WaitingMessage or "Waiting for a target" end
    if distance <= (feature.Config.InteractDistance or 11) and feature.Config.Interact then
        local interacted, detail = Shared:Interact(target, feature, {Priority = feature.Config.ActionPriority or 70, Duration = 0.4})
        if interacted then return true, "Interacted with " .. tostring(target.Name) end
        if distance <= (feature.Config.StopDistance or 6) then return false, detail end
    end
    local moved, detail = Shared:MoveTo(position, feature, {
        Direct = feature.Config.Direct == true,
        StopDistance = feature.Config.StopDistance or 6,
        MovementPriority = feature.Config.MovementPriority or 70,
        CommandInterval = 0.42,
        LeaseDuration = 0.55,
    })
    return moved, moved and ("Moving toward " .. tostring(target.Name)) or detail
end

Handlers.Interact = function(feature)
    local _, _, _, root = getCharacter()
    if not root then return false, "Waiting for the local character" end
    local target, distance = findTarget(feature.Config, root.Position)
    if not target then return false, feature.Config.WaitingMessage or "Waiting for an interactable target" end
    if distance > (feature.Config.InteractDistance or 11) then
        if not feature.Config.Walk then return false, string.format("Target is %.1f studs away", distance) end
        local position = positionOf(target)
        local moved, detail = Shared:MoveTo(position, feature, {
            StopDistance = feature.Config.InteractDistance or 11,
            MovementPriority = feature.Config.MovementPriority or 55,
            CommandInterval = 0.5,
        })
        return moved, moved and "Moving into interaction range" or detail
    end
    local ok, detail = Shared:Interact(target, feature, {Priority = feature.Config.ActionPriority or 65, Duration = feature.Config.ActionCooldown or 0.45})
    return ok, ok and ("Interacted with " .. tostring(target.Name)) or detail
end

local function nearestOpponent(config, root)
    local best, distance = nil, math.huge
    local localPlayer = Players.LocalPlayer
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
        if player ~= localPlayer and humanoid and humanoid.Health > 0 and targetRoot then
            local include = true
            if config.PlayerTokens and #config.PlayerTokens > 0 then
                include = containsAny(player.Name .. " " .. player.DisplayName .. " " .. (player.Team and player.Team.Name or "") .. " " .. objectText(character), config.PlayerTokens)
            end
            local d = (targetRoot.Position - root.Position).Magnitude
            if include and d < distance then best, distance = character, d end
        end
    end
    if config.IncludeNPCs then
        local npc, npcDistance = findTarget({
            TargetTokens = config.TargetTokens or {},
            ExcludeTokens = config.ExcludeTokens or {},
            TargetClasses = {"Model"},
            MaxDistance = config.Range or 16,
            MaxTargets = 80,
        }, root.Position)
        if npc and npcDistance < distance then best, distance = npc, npcDistance end
    end
    return best, distance
end

Handlers.ToolPulse = function(feature)
    local tool = Shared:FindTool(feature.Config.ToolTokens or {})
    if not tool then return false, feature.Config.WaitingMessage or "Waiting for the required tool" end
    if os.clock() - (feature.LastAction or 0) < (feature.Config.ActionCooldown or 0.35) then
        return true, "Tool ready"
    end
    local ok, detail = Shared:ActivateTool(feature.Config.ToolTokens or {}, feature, {
        Priority = feature.Config.ActionPriority or 55,
        Duration = feature.Config.ActionCooldown or 0.35,
    })
    if ok then feature.LastAction = os.clock() end
    return ok, ok and ("Activated " .. tostring(tool.Name)) or detail
end

Handlers.ToolAura = function(feature)
    local _, _, _, root = getCharacter()
    if not root then return false, "Waiting for the local character" end
    local target, distance = nearestOpponent(feature.Config, root)
    if not target or distance > (feature.Config.Range or 11) then return false, feature.Config.WaitingMessage or "Waiting for a nearby valid target" end
    local targetPosition = positionOf(target)
    if feature.Config.FaceTarget and targetPosition then
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetPosition.X, root.Position.Y, targetPosition.Z))
    end
    if os.clock() - (feature.LastAction or 0) < (feature.Config.ActionCooldown or 0.24) then
        return true, string.format("Target in range (%.1f studs)", distance)
    end
    local ok, detail = Shared:ActivateTool(feature.Config.ToolTokens or {}, feature, {
        Priority = feature.Config.ActionPriority or 65,
        Duration = feature.Config.ActionCooldown or 0.24,
    })
    if ok then feature.LastAction = os.clock() end
    return ok, ok and ("Activated tool near " .. tostring(target.Name)) or detail
end

local function bestVisibleButton(tokens, excludeTokens)
    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end
    local best, bestScore = nil, -math.huge
    for _, object in ipairs(playerGui:GetDescendants()) do
        if object:IsA("GuiButton") and guiVisible(object) then
            local text = objectText(object)
            if containsAny(text, tokens) and not containsAny(text, excludeTokens or {"shop", "buy", "reward", "settings", "close", "donate"}) then
                local score = object.AbsoluteSize.X * object.AbsoluteSize.Y + object.ZIndex * 500
                if object:IsA("TextButton") and object.Text ~= "" then score = score + 5000 end
                if isGreen(object.BackgroundColor3) then score = score + 4000 end
                if score > bestScore then best, bestScore = object, score end
            end
        end
    end
    return best
end

Handlers.GuiPulse = function(feature)
    local button = bestVisibleButton(feature.Config.ActionTokens or feature.Config.TargetTokens or {}, feature.Config.ExcludeTokens)
    if not button then return false, feature.Config.WaitingMessage or "Waiting for the matching action control" end
    if os.clock() - (feature.LastAction or 0) < (feature.Config.ActionCooldown or 0.16) then return true, "Action control ready" end
    local ok, detail = Shared:ClickGui(button, feature, {
        Priority = feature.Config.ActionPriority or 65,
        Duration = feature.Config.ActionCooldown or 0.16,
    })
    if ok then feature.LastAction = os.clock() end
    return ok, ok and ("Pressed " .. tostring(button.Name)) or detail
end

local function guiColor(object, propertyName)
    local ok, value = pcall(function() return object[propertyName] end)
    if ok and typeof(value) == "Color3" then return value end
    return nil
end

Handlers.TimingPulse = function(feature)
    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return false, "Waiting for PlayerGui" end
    local ready = false
    for _, object in ipairs(playerGui:GetDescendants()) do
        if object:IsA("GuiObject") and guiVisible(object) then
            local text = objectText(object)
            if containsAny(text, feature.Config.ZoneTokens or {"perfect", "green", "target", "sweet spot"}) then
                ready = ready or isGreen(guiColor(object, "BackgroundColor3")) or isGreen(guiColor(object, "ImageColor3")) or containsAny(text, {"perfect", "hit", "now"})
            end
            if containsAny(text, feature.Config.IndicatorTokens or {"cursor", "needle", "indicator"}) and isGreen(object.BackgroundColor3) then
                ready = true
            end
        end
    end
    local button = bestVisibleButton(feature.Config.ActionTokens or {"tap", "pull", "play"}, feature.Config.ExcludeTokens)
    if not button then return false, feature.Config.WaitingMessage or "Waiting for the timing interface" end
    if not ready and feature.Config.RequireReady ~= false then return true, "Waiting for the timing zone" end
    if os.clock() - (feature.LastAction or 0) < (feature.Config.ActionCooldown or 0.18) then return true, "Timing action cooling down" end
    local ok, detail = Shared:ClickGui(button, feature, {Priority = feature.Config.ActionPriority or 85, Duration = feature.Config.ActionCooldown or 0.18})
    if ok then feature.LastAction = os.clock() end
    return ok, ok and "Triggered the visible timing action" or detail
end

Handlers.DalgonaCut = function(feature)
    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return false, "Waiting for PlayerGui" end
    local nodes = {}
    for _, object in ipairs(playerGui:GetDescendants()) do
        if object:IsA("GuiButton") and guiVisible(object) then
            local text = objectText(object)
            if containsAny(text, {"trace point", "cut point", "path point", "segment", "node"}) then table.insert(nodes, object) end
        end
    end
    table.sort(nodes, function(a, b)
        if math.abs(a.AbsolutePosition.Y - b.AbsolutePosition.Y) > 8 then return a.AbsolutePosition.Y < b.AbsolutePosition.Y end
        return a.AbsolutePosition.X < b.AbsolutePosition.X
    end)
    if #nodes == 0 then
        local button = bestVisibleButton(feature.Config.ActionTokens or {"cut", "carve", "trace", "finish"})
        if button then
            local ok, detail = Shared:ClickGui(button, feature, {Priority = 70, Duration = 0.18})
            return ok, ok and "Pressed the exposed Dalgona action" or detail
        end
        return false, "Waiting for client-visible Dalgona trace controls"
    end
    feature.NodeIndex = (feature.NodeIndex or 0) + 1
    if feature.NodeIndex > #nodes then feature.NodeIndex = 1 end
    local ok, detail = Shared:ClickGui(nodes[feature.NodeIndex], feature, {Priority = 78, Duration = 0.11})
    return ok, ok and string.format("Tracing point %d/%d", feature.NodeIndex, #nodes) or detail
end

Handlers.Evasion = function(feature)
    local _, _, _, root = getCharacter()
    if not root then return false, "Waiting for the local character" end
    local threat, distance = nearestOpponent(feature.Config, root)
    if not threat or distance > (feature.Config.Range or 24) then return true, "No nearby threat" end
    local threatPosition = positionOf(threat)
    if not threatPosition then return false, "Threat position unavailable" end
    local away = Vector3.new(root.Position.X - threatPosition.X, 0, root.Position.Z - threatPosition.Z)
    if away.Magnitude < 0.5 then away = root.CFrame.RightVector end
    local destination = root.Position + away.Unit * (feature.Config.EvadeDistance or 20)
    local moved, detail = Shared:MoveTo(destination, feature, {
        Direct = true,
        StopDistance = 2,
        MovementPriority = feature.Config.MovementPriority or 75,
        CommandInterval = 0.36,
    })
    return moved, moved and ("Evading threat at " .. string.format("%.1f", distance) .. " studs") or detail
end

Handlers.RoomESP = function(feature)
    local count, seen = 0, {}
    for _, room in ipairs(Shared:FindTargets({
        Scope = "Workspace",
        TargetTokens = feature.Config.TargetTokens or {"room", "door", "chamber"},
        ExcludeTokens = {"bathroom", "bedroom", "lobby"},
        TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
        ReturnAdornee = true,
        MaxTargets = 80,
        CacheTTL = 0.7,
    })) do
        local target = adorneeOf(room)
        setHighlight(feature, target, feature.Config.Color or Color3.fromRGB(60, 220, 255), "ROOM")
        seen[target] = true
        count = count + 1
    end
    if feature.HighlightMap then
        for target, highlight in pairs(feature.HighlightMap) do
            if highlight and highlight.Parent then highlight.Enabled = seen[target] == true end
        end
    end
    return count > 0, count > 0 and ("Tracking " .. count .. " room target(s)") or "Waiting for Mingle rooms"
end

local function roomOccupancy(room, radius)
    local position = positionOf(room)
    if not position then return 0 end
    local count = 0
    for _, player in ipairs(Players:GetPlayers()) do
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if root and humanoid and humanoid.Health > 0 and (root.Position - position).Magnitude <= radius then count = count + 1 end
    end
    return count
end

Handlers.RoomAssist = function(feature)
    local phase = Shared:GetMinglePhase()
    if phase == "Locked" then Shared:StopMovement(feature) return true, "Room locked — holding position" end
    if phase ~= "ChooseRoom" then return false, "Waiting for the room-selection phase" end
    local required = Shared:GetMingleRequiredCount()
    if not required then return false, "Waiting for the required player count" end
    local _, _, _, root = getCharacter()
    if not root then return false, "Waiting for the local character" end
    local best, bestScore, bestCount = nil, -math.huge, 0
    for _, room in ipairs(Shared:FindTargets({
        Scope = "Workspace",
        TargetTokens = {"room", "door", "chamber", "enter"},
        ExcludeTokens = {"bathroom", "bedroom", "lobby"},
        TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
        ReturnAdornee = true,
        MaxTargets = 100,
        CacheTTL = 0.45,
    })) do
        local position = positionOf(room)
        if position then
            local count = roomOccupancy(room, feature.Config.RoomRadius or 12)
            local distance = (position - root.Position).Magnitude
            local score = -distance - math.abs((required - 1) - count) * 38
            if count >= required then score = score - 300 end
            if score > bestScore then best, bestScore, bestCount = room, score, count end
        end
    end
    if not best then return false, "Waiting for an available room" end
    local position = positionOf(best)
    local distance = (position - root.Position).Magnitude
    if distance <= (feature.Config.InteractDistance or 10) then
        local ok = Shared:Interact(best, feature, {Priority = 80, Duration = 0.5})
        if ok then return true, string.format("Entering room (%d/%d nearby)", bestCount, required) end
    end
    local moved, detail = Shared:MoveTo(position, feature, {
        StopDistance = feature.Config.StopDistance or 5,
        MovementPriority = feature.Config.MovementPriority or 75,
        CommandInterval = 0.4,
    })
    return moved, moved and string.format("Moving to room (%d/%d nearby)", bestCount, required) or detail
end

local ObservedSafeGlass = setmetatable({}, {__mode = "k"})
local function updateObservedGlass()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and root and humanoid.Health > 0 and humanoid.FloorMaterial ~= Enum.Material.Air then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {character}
            local result = Workspace:Raycast(root.Position, Vector3.new(0, -8, 0), params)
            local part = result and result.Instance
            if part and containsAny(objectText(part), {"glass", "panel", "tile", "bridge"}) then ObservedSafeGlass[part] = os.clock() end
        end
    end
end

local function glassState(part)
    if not part then return nil end
    for _, name in ipairs({"Safe", "IsSafe", "Correct", "Real", "CanStand"}) do
        local ok, value = pcall(part.GetAttribute, part, name)
        if ok and type(value) == "boolean" then return value end
    end
    for _, name in ipairs({"Fake", "Unsafe", "Breakable", "Wrong"}) do
        local ok, value = pcall(part.GetAttribute, part, name)
        if ok and value == true then return false end
    end
    local parent = part.Parent
    if parent then
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("BoolValue") then
                local name = lower(child.Name)
                if containsAny(name, {"safe", "correct", "real"}) then return child.Value end
                if containsAny(name, {"fake", "unsafe", "wrong"}) and child.Value then return false end
            end
        end
    end
    if ObservedSafeGlass[part] then return true end
    return nil
end

local function glassPanels()
    local panels = {}
    for _, target in ipairs(Shared:FindTargets({
        Scope = "Workspace",
        TargetTokens = {"glass", "panel", "tile", "stepping"},
        ExcludeTokens = {"wall", "window", "decor"},
        TargetClasses = {"BasePart"},
        MaxTargets = 180,
        CacheTTL = 0.65,
    })) do
        if target:IsA("BasePart") and target.Size.X >= 2 and target.Size.Z >= 2 then table.insert(panels, target) end
    end
    return panels
end

Handlers.GlassESP = function(feature)
    updateObservedGlass()
    local count, known = 0, 0
    for _, panel in ipairs(glassPanels()) do
        local state = glassState(panel)
        local color = feature.Config.UnknownColor or Color3.fromRGB(255, 210, 70)
        local label = "UNKNOWN"
        if state == true then color, label, known = feature.Config.SafeColor or Color3.fromRGB(60, 255, 126), "SAFE", known + 1 end
        if state == false then color, label, known = feature.Config.UnsafeColor or Color3.fromRGB(255, 80, 90), "UNSAFE", known + 1 end
        setHighlight(feature, panel, color, label)
        count = count + 1
    end
    if count == 0 then return false, "Waiting for Glass Bridge panels" end
    return true, string.format("Tracking %d panels; %d verified", count, known)
end

Handlers.GlassWalk = function(feature)
    updateObservedGlass()
    local _, _, _, root = getCharacter()
    if not root then return false, "Waiting for the local character" end
    local best, bestDistance = nil, math.huge
    for _, panel in ipairs(glassPanels()) do
        if glassState(panel) == true then
            local distance = (panel.Position - root.Position).Magnitude
            if distance >= (feature.Config.MinimumDistance or 2) and distance <= (feature.Config.MaximumDistance or 55) and distance < bestDistance then
                best, bestDistance = panel, distance
            end
        end
    end
    if not best then return false, "Waiting for a verified safe panel; this feature never guesses" end
    local moved, detail = Shared:MoveTo(best.Position, feature, {
        Direct = true,
        StopDistance = 1.8,
        MovementPriority = feature.Config.MovementPriority or 75,
        CommandInterval = 0.4,
    })
    return moved, moved and ("Moving to verified safe panel " .. best.Name) or detail
end

Handlers.FallRecovery = function(feature)
    local _, character, humanoid, root = getCharacter()
    if not character or not humanoid or not root then return false, "Waiting for the local character" end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    local ground = Workspace:Raycast(root.Position, Vector3.new(0, -10, 0), params)
    if ground and humanoid.FloorMaterial ~= Enum.Material.Air then
        feature.LastSafe = root.Position
        return true, "Safe recovery point updated"
    end
    if not feature.LastSafe then return false, "Waiting for a grounded recovery point" end
    local falling = root.AssemblyLinearVelocity.Y < -(feature.Config.FallVelocity or 45)
        or root.Position.Y < feature.LastSafe.Y - (feature.Config.DropDistance or 10)
    if not falling then return true, "Monitoring fall distance" end
    humanoid.Jump = true
    local direction = Vector3.new(feature.LastSafe.X - root.Position.X, 0, feature.LastSafe.Z - root.Position.Z)
    if direction.Magnitude > 0.1 then
        local velocity = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(direction.Unit.X * 34, math.max(velocity.Y, 28), direction.Unit.Z * 34)
    end
    Shared:MoveTo(feature.LastSafe, feature, {
        Direct = true,
        StopDistance = 2,
        MovementPriority = feature.Config.RecoveryPriority or 85,
        CommandInterval = 0.18,
    })
    return true, "Attempting non-teleport fall recovery"
end

Handlers.PositionKeeper = function(feature)
    local _, _, _, root = getCharacter()
    if not root then return false, "Waiting for the local character" end
    if not feature.Anchor then feature.Anchor = root.Position return true, "Saved recovery position" end
    local distance = (root.Position - feature.Anchor).Magnitude
    if distance <= (feature.Config.MaxDistance or 9) then return true, "Within the recovery area" end
    local moved, detail = Shared:MoveTo(feature.Anchor, feature, {
        Direct = true,
        StopDistance = feature.Config.MaxDistance or 9,
        MovementPriority = feature.Config.MovementPriority or 30,
        CommandInterval = 0.55,
    })
    return moved, moved and "Returning to the saved position" or detail
end

Handlers.AimAssist = function(feature)
    local _, _, _, root = getCharacter()
    if not root then return false, "Waiting for the local character" end
    local tool = Shared:FindTool(feature.Config.ToolTokens or {})
    if not tool then return false, "Waiting for a marble tool" end
    local target, distance = findTarget(feature.Config, root.Position)
    local position = positionOf(target)
    if not target or not position or distance > (feature.Config.Range or 150) then return false, "Waiting for a visible marble target" end
    local camera = Workspace.CurrentCamera
    if camera then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, position) end
    if os.clock() - (feature.LastAction or 0) >= (feature.Config.ActionCooldown or 0.45) then
        local ok, detail = Shared:ActivateTool(feature.Config.ToolTokens or {}, feature, {Priority = feature.Config.ActionPriority or 70, Duration = 0.35})
        if ok then feature.LastAction = os.clock() end
        return ok, ok and ("Aimed and activated toward " .. target.Name) or detail
    end
    return true, string.format("Aiming at target %.1f studs away", distance)
end

Handlers.Boundary = function(feature)
    local _, _, _, root = getCharacter()
    if not root then return false, "Waiting for the local character" end
    local court = findTarget(feature.Config, root.Position)
    local center = positionOf(court)
    if not center then return false, feature.Config.WaitingMessage or "Waiting for the active play area" end
    local flat = Vector3.new(root.Position.X - center.X, 0, root.Position.Z - center.Z)
    local radius = feature.Config.Radius or 58
    if flat.Magnitude <= radius then return true, string.format("Inside boundary (%.1f/%.1f)", flat.Magnitude, radius) end
    local destination = center + flat.Unit * math.max(radius - 5, 2)
    destination = Vector3.new(destination.X, root.Position.Y, destination.Z)
    local moved, detail = Shared:MoveTo(destination, feature, {
        Direct = true,
        StopDistance = 2,
        MovementPriority = feature.Config.MovementPriority or 70,
        CommandInterval = 0.36,
    })
    return moved, moved and "Returning inside the active boundary" or detail
end

Handlers.RPS = function(feature)
    local snapshot = Shared:GetVisibleText()
    local wanted = nil
    if containsAny(snapshot, {"opponent rock", "enemy rock", "picked rock"}) then wanted = "paper" end
    if containsAny(snapshot, {"opponent paper", "enemy paper", "picked paper"}) then wanted = "scissors" end
    if containsAny(snapshot, {"opponent scissors", "enemy scissors", "picked scissors"}) then wanted = "rock" end
    if not wanted then
        local choices = {"rock", "paper", "scissors"}
        feature.Choice = (feature.Choice or 0) % #choices + 1
        wanted = choices[feature.Choice]
    end
    local button = bestVisibleButton({wanted})
    if not button then return false, "Waiting for Rock/Paper/Scissors choices" end
    local ok, detail = Shared:ClickGui(button, feature, {Priority = 78, Duration = 0.3})
    if not ok then return false, detail end
    local submit = bestVisibleButton({"submit", "confirm", "choose", "lock", "play"})
    if submit then Shared:ClickGui(submit, feature, {Priority = 78, Duration = 0.3}) end
    return true, "Selected " .. string.upper(wanted)
end

Handlers.Radar = function(feature)
    if not feature.RadarGui then
        local parent
        if type(gethui) == "function" then pcall(function() parent = gethui() end) end
        parent = parent or game:GetService("CoreGui")
        local gui = Instance.new("ScreenGui")
        gui.Name = "SquidNoMoRadar"
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 999980
        gui.Parent = parent
        local frame = Instance.new("Frame")
        frame.AnchorPoint = Vector2.new(1, 0)
        frame.Position = UDim2.new(1, -18, 0, 126)
        frame.Size = UDim2.fromOffset(150, 150)
        frame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
        frame.BackgroundTransparency = 0.12
        frame.BorderSizePixel = 0
        frame.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = frame
        feature.RadarGui, feature.RadarFrame = gui, frame
        feature.RadarDots = setmetatable({}, {__mode = "k"})
        feature:_TrackInstance(gui)
    end
    feature.RadarGui.Enabled = true
    local _, _, _, root = getCharacter()
    if not root then return false, "Waiting for the local character" end
    local seen, count, range = {}, 0, feature.Config.Range or 180
    local function dotFor(target, color)
        local dot = feature.RadarDots[target]
        if dot and dot.Parent then return dot end
        dot = Instance.new("Frame")
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Size = UDim2.fromOffset(7, 7)
        dot.BackgroundColor3 = color
        dot.BorderSizePixel = 0
        dot.Parent = feature.RadarFrame
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot
        feature.RadarDots[target] = dot
        return dot
    end
    for _, player in ipairs(Players:GetPlayers()) do
        local targetRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if player ~= Players.LocalPlayer and targetRoot then
            local offset = targetRoot.Position - root.Position
            if math.abs(offset.X) <= range and math.abs(offset.Z) <= range then
                local dot = dotFor(player.Character, feature.Config.PlayerColor or Color3.fromRGB(255, 80, 100))
                dot.Position = UDim2.fromScale(0.5 + math.clamp(offset.X / range, -1, 1) * 0.45, 0.5 + math.clamp(offset.Z / range, -1, 1) * 0.45)
                dot.Visible = true
                seen[player.Character], count = true, count + 1
            end
        end
    end
    for _, target in ipairs(Shared:FindTargets({
        Scope = "Workspace",
        TargetTokens = feature.Config.TargetTokens or {},
        TargetClasses = {"Model", "BasePart", "Tool", "ProximityPrompt"},
        ReturnAdornee = true,
        MaxTargets = 35,
        CacheTTL = 0.7,
    })) do
        local position = positionOf(target)
        if position then
            local offset = position - root.Position
            if math.abs(offset.X) <= range and math.abs(offset.Z) <= range then
                local dot = dotFor(target, feature.Config.TargetColor or Color3.fromRGB(60, 255, 126))
                dot.Position = UDim2.fromScale(0.5 + math.clamp(offset.X / range, -1, 1) * 0.45, 0.5 + math.clamp(offset.Z / range, -1, 1) * 0.45)
                dot.Visible = true
                seen[target], count = true, count + 1
            end
        end
    end
    for target, dot in pairs(feature.RadarDots) do if not seen[target] then dot.Visible = false end end
    return count > 0, count > 0 and ("Radar tracking " .. count .. " target(s)") or "Waiting for radar targets"
end

Handlers.NoGuess = function(feature)
    return false, feature.Config.WaitingMessage or "This feature needs a client-visible, verifiable game signal"
end

function Feature:_Tick()
    if not self.Enabled then return false end
    local roleOk, roleDetail = localRoleAllowed(self.Config)
    if not roleOk then return self:_Pause(roleDetail) end
    local active, gameDetail = GameRuntime:IsGameActive(self.Config.Game)
    if not active then return self:_Pause(gameDetail) end
    if self.Config.Stage then
        local stage = Shared:GetPentathlonStage()
        if not stage then return self:_Pause("Waiting for the " .. tostring(self.Config.Stage) .. " Pentathlon stage") end
        if stage ~= self.Config.Stage then
            return self:_Pause("Paused: " .. tostring(stage) .. " is the active Pentathlon stage")
        end
    end
    self:_SetPresentationEnabled(true)
    local handler = Handlers[self.Config.Handler]
    if not handler then
        self.LastError = "unsupported game handler: " .. tostring(self.Config.Handler)
        self:_SetStatus("Error", self.LastError)
        return false
    end
    local ok, working, detail = xpcall(function() return handler(self) end, debug.traceback)
    if not ok then
        self.LastError = tostring(working)
        pcall(function() Shared:StopMovement(self) end)
        pcall(function() Shared:ReleaseActions(self) end)
        self:_SetPresentationEnabled(false)
        self:_SetStatus("Error", self.LastError)
        warn("[SquidNoMo][GameRuntime][" .. self.Name .. "] " .. self.LastError)
        return false
    end
    self:_SetStatus(working and "Active" or "Waiting", detail or gameDetail)
    return working == true
end

function Feature:Toggle(state)
    state = state == true
    if self.Enabled == state then return true end
    self:_Cleanup()
    self.Enabled, self.LastError = state, nil
    if not state then self:_SetStatus("Off", "Disabled") return true end
    if type(self.Config.Game) ~= "string" or self.Config.Game == "" then
        self.Enabled = false
        self.LastError = "game profile is missing"
        self:_SetStatus("Error", self.LastError)
        return false, self.LastError
    end
    if not Handlers[self.Config.Handler] then
        self.Enabled = false
        self.LastError = "unsupported game handler: " .. tostring(self.Config.Handler)
        self:_SetStatus("Error", self.LastError)
        return false, self.LastError
    end
    self:_SetStatus("Starting", "Starting " .. self.Name)
    Shared.Scheduler:Add(self, self.Config.Interval or 0.25, self.Config.IdleInterval or math.max((self.Config.Interval or 0.25) * 4, 0.85), function(owner)
        return owner:_Tick()
    end)
    return true
end

function GameRuntime:CreateFeature(config)
    assert(type(config) == "table", "game feature config must be a table")
    assert(type(config.Id) == "string" and config.Id ~= "", "game feature Id is required")
    assert(type(config.Handler) == "string" and config.Handler ~= "", "game feature Handler is required")
    assert(type(config.Game) == "string" and config.Game ~= "", "game feature Game is required")
    return setmetatable({
        Id = config.Id,
        Name = tostring(config.Name or config.Id),
        Description = tostring(config.Description or ""),
        Config = config,
        Enabled = false,
        Status = "Off",
        StatusDetail = "Disabled",
        LastError = nil,
        LastAction = 0,
        Instances = {},
        Connections = {},
        StatusListeners = {},
        NextListenerId = 0,
    }, Feature)
end

return GameRuntime
