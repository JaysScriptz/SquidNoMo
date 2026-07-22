-- SquidNoMo feature runtime
-- Runtime identity is supplied by BuildManifest.lua so feature fixes can advance builds automatically.

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Manifest = type(Environment.__SquidNoMoBuildManifest) == "table"
    and Environment.__SquidNoMoBuildManifest
    or {}
local BUILD_NUMBER = tonumber(Manifest.BuildNumber) or 0
local Runtime = {
    Revision = tostring(Manifest.FeatureRuntimeRevision or "visual-gameplay-runtime-r2"),
    BuildNumber = BUILD_NUMBER,
}
Environment.__SquidNoMoFeatureRuntime = Runtime
if Environment.__SquidNoMoDetectionBuild ~= BUILD_NUMBER then
    Environment.__SquidNoMoDetectedGame = nil
    Environment.__SquidNoMoDetectedGameAt = nil
    Environment.__SquidNoMoManualGameHint = nil
    Environment.__SquidNoMoDetectionBuild = BUILD_NUMBER
end


-- One cooperative scheduler is shared by every game, guard, detective, and player
-- feature. It prevents dozens of independent while-loops from waking on the same
-- frame and automatically backs off features that are waiting for a round.
local Scheduler = Environment.__SquidNoMoScheduler
if type(Scheduler) ~= "table" or Scheduler.Revision ~= ("shared-scheduler-r2-build-" .. tostring(BUILD_NUMBER)) then
    Scheduler = {
        Revision = "shared-scheduler-r2-build-" .. tostring(BUILD_NUMBER),
        Tasks = setmetatable({}, {__mode = "k"}),
        Running = false,
        Lightweight = true,
    }

    function Scheduler:SetLightweight(state)
        self.Lightweight = state ~= false
    end

    function Scheduler:Add(owner, interval, idleInterval, callback)
        interval = math.max(tonumber(interval) or 0.25, 0.03)
        idleInterval = math.max(tonumber(idleInterval) or math.max(interval * 4, 1.0), interval)
        self.Tasks[owner] = {
            Interval = interval,
            IdleInterval = idleInterval,
            Callback = callback,
            NextRun = os.clock(),
            Busy = false,
        }
        self:_Ensure()
    end

    function Scheduler:Remove(owner)
        self.Tasks[owner] = nil
    end

    function Scheduler:_Ensure()
        if self.Running then return end
        self.Running = true
        task.spawn(function()
            while next(self.Tasks) do
                local now = os.clock()
                local launched = 0
                local launchBudget = self.Lightweight and 3 or 8
                for owner, job in pairs(self.Tasks) do
                    if launched >= launchBudget then break end
                    if not owner or owner.Enabled ~= true then
                        self.Tasks[owner] = nil
                    elseif not job.Busy and now >= job.NextRun then
                        job.Busy = true
                        launched = launched + 1
                        task.spawn(function()
                            local ok, active = xpcall(function()
                                return job.Callback(owner)
                            end, debug.traceback)
                            if not ok and owner and owner.Enabled then
                                owner.LastError = tostring(active)
                                if type(owner._SetStatus) == "function" then
                                    owner:_SetStatus("Error", owner.LastError)
                                end
                                warn("[SquidNoMo][Scheduler] " .. owner.LastError)
                                active = false
                            end
                            job.Busy = false
                            job.NextRun = os.clock() + (active and job.Interval or job.IdleInterval)
                        end)
                    end
                end
                task.wait(self.Lightweight and 0.035 or 0.02)
            end
            self.Running = false
        end)
    end

    Environment.__SquidNoMoScheduler = Scheduler
end
Runtime.Scheduler = Scheduler
Runtime.LightweightMode = true
Runtime.QueryCache = {}
Runtime.MovementLease = {Owner = nil, Priority = -math.huge, ExpiresAt = 0}
Runtime.ActionLeases = {}

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function containsAny(value, tokens)
    local text = lower(value)
    for _, token in ipairs(tokens or {}) do
        token = lower(token)
        if token ~= "" and string.find(text, token, 1, true) then
            return true
        end
    end
    return false
end

local function containsAll(value, tokens)
    local text = lower(value)
    for _, token in ipairs(tokens or {}) do
        token = lower(token)
        if token ~= "" and not string.find(text, token, 1, true) then
            return false
        end
    end
    return true
end

local InstanceTextCache = setmetatable({}, {__mode = "k"})
local function instanceText(instance)
    if not instance then return "" end

    local dynamic = instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")
        or instance:IsA("ValueBase") or instance:IsA("ProximityPrompt")
    local parent = instance.Parent
    local parentName = parent and parent.Name or ""
    local grandparent = parent and parent.Parent
    local grandparentName = grandparent and grandparent.Name or ""
    local signature = instance.Name .. "|" .. parentName .. "|" .. grandparentName
    if not dynamic then
        local cached = InstanceTextCache[instance]
        if cached and cached.Signature == signature then return cached.Text end
    end

    local parts = {instance.Name, instance.ClassName, parentName, grandparentName}
    local current = grandparent and grandparent.Parent
    if current then table.insert(parts, current.Name) end
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        table.insert(parts, instance.Text)
    elseif instance:IsA("ValueBase") then
        table.insert(parts, tostring(instance.Value))
    end
    local ok, actionText, objectText = pcall(function()
        if instance:IsA("ProximityPrompt") then
            return instance.ActionText, instance.ObjectText
        end
        return nil, nil
    end)
    if ok then
        if actionText and actionText ~= "" then table.insert(parts, actionText) end
        if objectText and objectText ~= "" then table.insert(parts, objectText) end
    end
    local text = lower(table.concat(parts, " "))
    if not dynamic then InstanceTextCache[instance] = {Signature = signature, Text = text} end
    return text
end

local function classAllowed(instance, classes)
    if type(classes) ~= "table" or #classes == 0 then return true end
    for _, className in ipairs(classes) do
        if instance:IsA(className) then return true end
    end
    return false
end

local function getLocalPlayer()
    return Players.LocalPlayer
end

local function getCharacter()
    local player = getLocalPlayer()
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return player, character, humanoid, root
end

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    local coreGui
    pcall(function() coreGui = game:GetService("CoreGui") end)
    if coreGui then return coreGui end
    local player = getLocalPlayer()
    return player and player:FindFirstChildOfClass("PlayerGui") or nil
end

local function getLocalContextText()
    local player, character = getCharacter()
    if not player then return "" end
    local parts = {player.Name, player.DisplayName, player.Team and player.Team.Name or ""}
    for _, attributeName in ipairs({"Role", "Class", "Team", "Job", "Rank", "GameRole"}) do
        local ok, value = pcall(player.GetAttribute, player, attributeName)
        if ok and value ~= nil then table.insert(parts, tostring(value)) end
        if character then
            local characterOk, characterValue = pcall(character.GetAttribute, character, attributeName)
            if characterOk and characterValue ~= nil then table.insert(parts, tostring(characterValue)) end
        end
    end
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then table.insert(parts, child.Name) end
        end
    end
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") then table.insert(parts, child.Name) end
        end
    end
    return lower(table.concat(parts, " "))
end

function Runtime:ContextAllowed(config)
    config = config or {}
    local context = getLocalContextText()
    if config.ExcludeLocalRoleTokens and containsAny(context, config.ExcludeLocalRoleTokens) then
        return false, "This option does not match the current local role"
    end
    if config.LocalRoleTokens and #config.LocalRoleTokens > 0 and not containsAny(context, config.LocalRoleTokens) then
        local known = config.KnownLocalRoleTokens or {
            "hunter", "seeker", "killer", "hider", "runner", "guard", "staff", "detective", "player"
        }
        if config.StrictLocalRole or containsAny(context, known) then
            return false, "Waiting for the matching local role"
        end
    end
    return true
end

local function getPosition(instance)
    if not instance then return nil end
    if instance:IsA("BasePart") then return instance.Position end
    if instance:IsA("Attachment") then return instance.WorldPosition end
    if instance:IsA("Model") then
        local ok, pivot = pcall(instance.GetPivot, instance)
        if ok then return pivot.Position end
    end
    if instance:IsA("ProximityPrompt") or instance:IsA("ClickDetector") then
        return getPosition(instance.Parent)
    end
    return nil
end

local function getAdornee(instance)
    if not instance then return nil end
    if instance:IsA("Model") or instance:IsA("BasePart") then return instance end
    local model = instance:FindFirstAncestorOfClass("Model")
    if model then return model end
    return instance:FindFirstAncestorWhichIsA("BasePart")
end

-- A live, event-maintained index replaces repeated Workspace/GetDescendants scans.
-- Each data-model tree is enumerated once and then updated incrementally as objects
-- are created or removed. Feature queries usually inspect only the requested class
-- buckets (BasePart, Model, Tool, prompt, and so on).
local INDEX_REVISION = "object-index-r3-build-" .. tostring(BUILD_NUMBER)
local IndexManager = Environment.__SquidNoMoObjectIndex
if type(IndexManager) ~= "table" or IndexManager.Revision ~= INDEX_REVISION then
    if type(IndexManager) == "table" and type(IndexManager.Connections) == "table" then
        for _, connection in ipairs(IndexManager.Connections) do
            pcall(function() connection:Disconnect() end)
        end
    end

    IndexManager = {
        Revision = INDEX_REVISION,
        Indices = {},
        Connections = {},
        Generation = 0,
    }

    local broadClasses = {
        "BasePart", "Model", "Folder", "Tool", "ProximityPrompt", "ClickDetector",
        "ValueBase", "GuiObject", "GuiButton", "TextLabel", "TextButton", "TextBox",
        "RemoteEvent", "RemoteFunction", "BindableEvent", "BindableFunction", "Sound",
    }

    local function weakSet()
        return setmetatable({}, {__mode = "k"})
    end

    function IndexManager:_Bucket(index, className)
        local bucket = index.Buckets[className]
        if not bucket then
            bucket = weakSet()
            index.Buckets[className] = bucket
        end
        return bucket
    end

    function IndexManager:_Add(index, instance)
        if not instance or index.All[instance] then return end
        index.All[instance] = true
        self:_Bucket(index, instance.ClassName)[instance] = true
        for _, className in ipairs(broadClasses) do
            if instance.ClassName ~= className and instance:IsA(className) then
                self:_Bucket(index, className)[instance] = true
            end
        end
        index.Generation = index.Generation + 1
        self.Generation = self.Generation + 1
    end

    function IndexManager:_Remove(index, instance)
        if not instance or not index.All[instance] then return end
        index.All[instance] = nil
        for _, bucket in pairs(index.Buckets) do
            bucket[instance] = nil
        end
        index.Generation = index.Generation + 1
        self.Generation = self.Generation + 1
    end

    function IndexManager:_Build(key, root)
        local previous = self.Indices[key]
        if previous and previous.Root == root and root and root.Parent then
            return previous
        end
        if previous then
            previous.Alive = false
            for _, connection in ipairs(previous.Connections or {}) do
                pcall(function() connection:Disconnect() end)
            end
        end
        if not root then
            self.Indices[key] = nil
            return nil
        end

        local index = {
            Root = root,
            All = weakSet(),
            Buckets = {},
            Connections = {},
            Generation = 0,
            Alive = true,
            Ready = false,
        }
        self.Indices[key] = index
        self:_Add(index, root)

        -- Subscribe first, then build the initial index cooperatively. Walking the
        -- tree in small batches avoids one large frame spike on map-heavy servers.
        local added = root.DescendantAdded:Connect(function(instance)
            if index.Alive then self:_Add(index, instance) end
        end)
        local removing = root.DescendantRemoving:Connect(function(instance)
            if index.Alive then self:_Remove(index, instance) end
        end)
        table.insert(index.Connections, added)
        table.insert(index.Connections, removing)
        table.insert(self.Connections, added)
        table.insert(self.Connections, removing)

        task.spawn(function()
            local queue = root:GetChildren()
            local cursor, processed = 1, 0
            while index.Alive and cursor <= #queue do
                local instance = queue[cursor]
                cursor = cursor + 1
                if instance and instance.Parent then
                    self:_Add(index, instance)
                    local children = instance:GetChildren()
                    for _, child in ipairs(children) do
                        table.insert(queue, child)
                    end
                end
                processed = processed + 1
                if processed % 240 == 0 then task.wait() end
            end
            if index.Alive then index.Ready = true end
        end)
        return index
    end

    function IndexManager:GetIndices(scope)
        scope = lower(scope)
        local indices = {}
        if scope == "gui" then
            local player = getLocalPlayer()
            local gui = player and player:FindFirstChildOfClass("PlayerGui")
            local index = self:_Build("PlayerGui", gui)
            if index then table.insert(indices, index) end
        elseif scope == "replicatedstorage" or scope == "remotes" then
            table.insert(indices, self:_Build("ReplicatedStorage", ReplicatedStorage))
        elseif scope == "both" then
            table.insert(indices, self:_Build("Workspace", Workspace))
            local player = getLocalPlayer()
            local gui = player and player:FindFirstChildOfClass("PlayerGui")
            local guiIndex = self:_Build("PlayerGui", gui)
            if guiIndex then table.insert(indices, guiIndex) end
        else
            table.insert(indices, self:_Build("Workspace", Workspace))
        end
        return indices
    end

    function IndexManager:ForEach(scope, classes, callback)
        local candidateSeen = weakSet()
        for _, index in ipairs(self:GetIndices(scope)) do
            local pools = {}
            if type(classes) == "table" and #classes > 0 then
                for _, className in ipairs(classes) do
                    local bucket = index.Buckets[className]
                    if bucket then table.insert(pools, bucket) end
                end
            else
                table.insert(pools, index.All)
            end
            for _, pool in ipairs(pools) do
                for instance in pairs(pool) do
                    if instance and instance.Parent and not candidateSeen[instance] then
                        candidateSeen[instance] = true
                        if callback(instance) == false then return false end
                    end
                end
            end
        end
        return true
    end

    Environment.__SquidNoMoObjectIndex = IndexManager
end
Runtime.IndexManager = IndexManager

function Runtime:WarmIndices()
    -- Starts the cooperative tree walk while the app is still on its loader.
    -- Calls are idempotent and return immediately with partially built indices.
    IndexManager:GetIndices("workspace")
    IndexManager:GetIndices("replicatedstorage")
    IndexManager:GetIndices("gui")
end

local function forEachIndexed(scope, classes, callback)
    return IndexManager:ForEach(scope, classes, callback)
end

local function isVisibleGui(instance)
    if not instance:IsA("GuiObject") or not instance.Visible then return false end
    local size = instance.AbsoluteSize
    if size.X < 2 or size.Y < 2 then return false end
    if (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox"))
        and instance.TextTransparency >= 0.96
    then
        return false
    end
    if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
        if instance.ImageTransparency >= 0.98 and instance.BackgroundTransparency >= 0.98 then
            return false
        end
    end
    local current = instance.Parent
    while current do
        if current:IsA("GuiObject") and not current.Visible then return false end
        if current:IsA("CanvasGroup") and current.GroupTransparency >= 0.96 then return false end
        if current:IsA("LayerCollector") and not current.Enabled then return false end
        current = current.Parent
    end
    return true
end


-- Visual-first gameplay context -------------------------------------------------
-- Squid Game X exposes many of its useful round and role cues through the same
-- HUD the player sees. The runtime keeps a small cached snapshot of that HUD so
-- features can use current objective text, counters, buttons, and meter geometry
-- without repeatedly walking the whole PlayerGui tree.
local function isSquidNoMoGui(instance)
    local current = instance
    while current do
        if current:IsA("ScreenGui") then
            local name = lower(current.Name)
            if string.find(name, "squidnomo", 1, true)
                or string.find(name, "squid no mo", 1, true)
            then
                return true
            end
        end
        current = current.Parent
    end
    return false
end

local function safeGuiNumber(instance, property, fallback)
    local ok, value = pcall(function() return instance[property] end)
    if ok and type(value) == "number" then return value end
    return fallback
end

local function safeGuiVector(instance, property)
    local ok, value = pcall(function() return instance[property] end)
    if ok and typeof(value) == "Vector2" then return value end
    return Vector2.zero
end

local function safeGuiColor(instance, property)
    local ok, value = pcall(function() return instance[property] end)
    if ok and typeof(value) == "Color3" then return value end
    return Color3.new(0, 0, 0)
end

function Runtime:GetVisualSnapshot(force)
    local now = os.clock()
    local cached = self._VisualSnapshot
    if not force and cached and now - cached.Time < 0.14 then
        return cached
    end

    local items, textParts = {}, {}
    local seen = setmetatable({}, {__mode = "k"})
    local textCount, supportingCount = 0, 0

    local function addInstance(instance, supporting)
        if not instance or seen[instance] or not isVisibleGui(instance) or isSquidNoMoGui(instance) then
            return true
        end
        seen[instance] = true

        local rawText = ""
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            rawText = tostring(instance.Text or "")
        end
        local context = instanceText(instance)
        local relevantSupporting = instance:IsA("GuiButton") or containsAny(context, {
            "meter", "progress", "objective", "role", "round", "game", "evidence",
            "backpack", "light", "signal", "timer", "status"
        })
        if rawText == "" and supporting and not relevantSupporting then return true end

        local item = {
            Instance = instance,
            Text = lower(rawText),
            RawText = rawText,
            Context = context,
            Name = lower(instance.Name),
            ClassName = instance.ClassName,
            Position = safeGuiVector(instance, "AbsolutePosition"),
            Size = safeGuiVector(instance, "AbsoluteSize"),
            TextSize = safeGuiNumber(instance, "TextSize", 0),
            TextColor = safeGuiColor(instance, "TextColor3"),
            BackgroundColor = safeGuiColor(instance, "BackgroundColor3"),
        }
        table.insert(items, item)
        if item.Text ~= "" then table.insert(textParts, item.Text) end
        return true
    end

    -- Text is scanned first. The old mixed 260-object cap could fill with Frames
    -- before the actual objective label was reached, which made game detection
    -- effectively random on UI-heavy mobile servers.
    forEachIndexed("Gui", {"TextLabel", "TextButton", "TextBox"}, function(instance)
        if textCount >= 720 then return false end
        textCount = textCount + 1
        return addInstance(instance, false)
    end)
    forEachIndexed("Gui", {"GuiButton", "ImageLabel", "ImageButton", "Frame"}, function(instance)
        if supportingCount >= 180 then return false end
        supportingCount = supportingCount + 1
        return addInstance(instance, true)
    end)

    cached = {
        Time = now,
        Items = items,
        Text = table.concat(textParts, " | "),
    }
    self._VisualSnapshot = cached
    return cached
end

function Runtime:GetVisibleText()
    return self:GetVisualSnapshot().Text
end

function Runtime:VisualContains(tokens, requireAll)
    local text = self:GetVisibleText()
    return requireAll and containsAll(text, tokens) or containsAny(text, tokens)
end

function Runtime:GetRoundTimerSeconds()
    local best
    for _, item in ipairs(self:GetVisualSnapshot().Items) do
        local minutes, seconds = string.match(item.RawText or "", "(%d+)%s*:%s*(%d%d)")
        minutes, seconds = tonumber(minutes), tonumber(seconds)
        if minutes and seconds and seconds <= 59 then
            local value = minutes * 60 + seconds
            if not best or value < best then best = value end
        end
    end
    return best
end

function Runtime:GetRoundPhase()
    local text = self:GetVisibleText()
    if containsAny(text, {
        "round complete", "game complete", "you survived", "survived the game",
        "you were eliminated", "victory", "game over", "round results", "match results"
    }) then
        return "Ended"
    end
    if containsAny(text, {
        "follow the beam to start", "waiting for players", "intermission",
        "game starting", "round starting", "starting in", "choose your role"
    }) then
        return "Lobby"
    end
    if self:DetectGameCategory() then
        return "Active"
    end
    return "Unknown"
end

function Runtime:GetGuardDuty()
    local text = self:GetVisibleText()
    local scores = {Kitchen = 0, Morgue = 0, Moderation = 0}
    local sources = {}
    local function add(duty, value, detail)
        scores[duty] = scores[duty] + value
        if detail then sources[duty] = sources[duty] or detail end
    end
    local function score(duty, tokens, weight, detail)
        for _, token in ipairs(tokens) do
            if string.find(text, token, 1, true) then
                add(duty, weight or 1, detail or "visible objective")
            end
        end
    end

    -- Objective text is the strongest signal because Guard maps may remain
    -- replicated while another duty is active.
    score("Kitchen", {
        "kitchen duty", "cook the food", "prepare food", "collect ingredients",
        "bring ingredients", "store cooked", "serve the food", "meal tray"
    }, 5, "guard objective")
    score("Kitchen", {
        "kitchen", "cook", "cooking", "ingredient", "raw food",
        "storage", "serve food", "supply crate"
    }, 2, "visible kitchen cue")
    score("Morgue", {
        "morgue duty", "collect the body", "collect bodies", "grab a coffin",
        "dispose the coffin", "dispose body", "take it to the incinerator"
    }, 5, "guard objective")
    score("Morgue", {
        "morgue", "coffin", "body bag", "incinerator", "cremation", "dead player"
    }, 2, "visible morgue cue")
    score("Moderation", {
        "moderation duty", "moderate the game", "eliminate rule breakers",
        "remove contestant", "guard orders", "discipline contestant"
    }, 5, "guard objective")
    score("Moderation", {
        "moderation", "moderate", "taser", "stun baton", "player cleanup"
    }, 2, "visible moderation cue")

    -- Held tools are useful secondary evidence after the duty selection HUD has
    -- closed. They never override a strong visible objective by themselves.
    local player, character = getCharacter()
    local containers = {}
    if character then table.insert(containers, character) end
    local backpack = player and player:FindFirstChildOfClass("Backpack")
    if backpack then table.insert(containers, backpack) end
    for _, container in ipairs(containers) do
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local name = lower(item.Name)
                if containsAny(name, {"ingredient", "food", "meal", "tray", "cook", "pan"}) then
                    add("Kitchen", 3, "held kitchen tool")
                elseif containsAny(name, {"coffin", "body", "corpse", "incinerator"}) then
                    add("Morgue", 3, "held morgue tool")
                elseif containsAny(name, {"taser", "stun", "baton", "rifle", "pistol"}) then
                    add("Moderation", 3, "held moderation tool")
                end
            end
        end
    end

    local bestDuty, bestScore, secondScore = nil, 0, 0
    for duty, value in pairs(scores) do
        if value > bestScore then
            secondScore = bestScore
            bestDuty, bestScore = duty, value
        elseif value > secondScore then
            secondScore = value
        end
    end
    if bestScore >= 4 and bestScore - secondScore >= 2 then
        return bestDuty, bestScore, sources[bestDuty]
    end
    return nil, bestScore, "guard duty is not yet unambiguous"
end

function Runtime:GetPentathlonStage()
    local text = self:GetVisibleText()
    local stages = {
        {Name = "Ddakji", Tokens = {"ddakji", "paper tile", "flip tile"}},
        {Name = "Gonggi", Tokens = {"gonggi", "stone toss", "pick up stones"}},
        {Name = "Jegichagi", Tokens = {"jegichagi", "jegi", "kick the shuttle"}},
        {Name = "Paengi", Tokens = {"paengi", "spinning top", "spin the top"}},
        {Name = "Biseokchigi", Tokens = {"biseokchigi", "biseok", "flying stone", "standing stone"}},
    }
    for _, stage in ipairs(stages) do
        if containsAny(text, stage.Tokens) then return stage.Name end
    end
    return nil
end

function Runtime:GetMingleRequiredCount()
    local snapshot = self:GetVisualSnapshot()
    local text = snapshot.Text
    local patterns = {
        "(%d+)%s*players", "players%s*[:%-]?%s*(%d+)",
        "group%s*of%s*(%d+)", "rooms?%s*for%s*(%d+)",
        "room%s*with%s*(%d+)", "enter%s+a%s+room%s+with%s+(%d+)",
        "number%s*[:%-]?%s*(%d+)", "mingle%s*[:%-]?%s*(%d+)",
    }
    for _, pattern in ipairs(patterns) do
        local number = tonumber(string.match(text, pattern))
        if number and number >= 1 and number <= 20 then return number end
    end

    -- During Mingle the required number is often displayed as one large central
    -- label. Only accept a standalone large number when the rest of the HUD
    -- confirms that Mingle is active.
    if containsAny(text, {"mingle", "find a room", "enter a room", "players per room"}) then
        local best, bestSize = nil, 0
        for _, item in ipairs(snapshot.Items) do
            local number = tonumber(string.match(item.RawText or "", "^%s*(%d+)%s*$"))
            if number and number >= 1 and number <= 20 and item.TextSize >= bestSize then
                best, bestSize = number, item.TextSize
            end
        end
        return best
    end
    return nil
end

function Runtime:GetMinglePhase()
    local text = self:GetVisibleText()
    if containsAny(text, {
        "room locked", "doors closed", "door closed", "stay in the room",
        "room accepted", "group complete"
    }) then
        return "Locked"
    end
    if containsAny(text, {
        "find a room", "enter a room", "get in a room", "players per room",
        "group of", "rooms open", "choose a room"
    }) or self:GetMingleRequiredCount() then
        return "ChooseRoom"
    end
    if containsAny(text, {
        "mingle", "carousel", "wait for the number", "music is playing",
        "keep moving"
    }) then
        return "Carousel"
    end
    return nil
end

function Runtime:GetHideSeekRole()
    local text = self:GetVisibleText()
    local scores = {Hider = 0, Seeker = 0}
    local function score(role, tokens, weight)
        for _, token in ipairs(tokens) do
            if string.find(text, token, 1, true) then
                scores[role] = scores[role] + weight
            end
        end
    end
    score("Hider", {
        "you are a hider", "playing as hider", "hider objective", "find a key",
        "collect a key", "unlock the exit", "escape before"
    }, 5)
    score("Seeker", {
        "you are a seeker", "playing as seeker", "seeker objective", "find the hiders",
        "eliminate the hiders", "grab a knife", "collect a knife"
    }, 5)

    if self:FindTool({"key", "door key", "exit key"}) then scores.Hider = scores.Hider + 6 end
    if self:FindTool({"knife", "blade"}) then scores.Seeker = scores.Seeker + 6 end

    if scores.Hider >= 5 and scores.Hider >= scores.Seeker + 2 then return "Hider", scores.Hider end
    if scores.Seeker >= 5 and scores.Seeker >= scores.Hider + 2 then return "Seeker", scores.Seeker end
    return nil, math.max(scores.Hider, scores.Seeker)
end

local function readProgressRatioNear(label)
    if not label or not label.Parent then return nil end
    local bestRatio, bestScore
    local root = label.Parent
    for depth = 1, 3 do
        local scanned = 0
        for _, object in ipairs(root:GetDescendants()) do
            if scanned >= 80 then break end
            if object:IsA("GuiObject") and object ~= label and object.Parent and isVisibleGui(object) then
                local context = instanceText(object)
                if containsAny(context, {"fill", "bar", "progress", "meter", "detection"}) then
                    local parentSize = object.Parent:IsA("GuiObject") and object.Parent.AbsoluteSize or Vector2.zero
                    local size = object.AbsoluteSize
                    if parentSize.X > 2 and parentSize.Y > 2 and size.X > 1 and size.Y > 1 then
                        local ratio
                        if parentSize.Y > parentSize.X * 1.25 then
                            ratio = math.clamp(size.Y / parentSize.Y, 0, 1)
                        else
                            ratio = math.clamp(size.X / parentSize.X, 0, 1)
                        end
                        local score = object.ZIndex + (containsAny(context, {"fill", "progress"}) and 10 or 0)
                        if ratio < 0.995 and (not bestScore or score > bestScore) then
                            bestRatio, bestScore = ratio, score
                        end
                    end
                end
                scanned = scanned + 1
            end
        end
        if bestRatio then break end
        root = root.Parent
        if not root then break end
    end
    return bestRatio
end

function Runtime:GetDetectiveState()
    local snapshot = self:GetVisualSnapshot()
    local state = {
        Stage = nil,
        Evidence = nil,
        Capacity = nil,
        Detection = nil,
        HasHint = false,
    }

    for _, item in ipairs(snapshot.Items) do
        local text = item.Text
        local current, maximum = string.match(text, "evidence%s*backpack%s*[:%-]?%s*(%d+)%s*/%s*(%d+)")
        if not current then current, maximum = string.match(text, "(%d+)%s*/%s*(%d+)%s*evidence") end
        if current and maximum then
            state.Evidence, state.Capacity = tonumber(current), tonumber(maximum)
        end
        if containsAny(text, {"detection meter", "detection"}) and not state.Detection then
            state.Detection = readProgressRatioNear(item.Instance)
        end
        if containsAny(text, {"hint", "next evidence", "evidence nearby", "clue nearby"}) then
            state.HasHint = true
        end
    end

    local text = snapshot.Text
    -- The objective list can show every step at once, so backpack state and live
    -- action prompts take priority over merely finding words in the list.
    if state.Evidence and state.Capacity and state.Evidence >= state.Capacity and state.Capacity > 0 then
        state.Stage = "Deposit Evidence"
    elseif containsAny(text, {"deposit evidence now", "return to the boat", "return to your boat", "deposit at the boat"}) then
        state.Stage = "Deposit Evidence"
    elseif containsAny(text, {"collect evidence", "gather the evidence", "search for evidence", "evidence nearby"}) then
        state.Stage = "Gather Evidence"
    elseif containsAny(text, {"find the island", "locate the island", "identify the island", "island picture"}) then
        state.Stage = "Find Island"
    elseif state.Evidence and state.Evidence > 0 then
        state.Stage = "Gather Evidence"
    end
    return state
end

function Runtime:GetVisualRole()
    local player, character = getCharacter()
    if not player then return nil, 0, "local player unavailable" end
    local scores = {Player = 0, Guard = 0, Detective = 0, Frontman = 0}
    local source = {}
    local function add(role, weight, detail)
        scores[role] = (scores[role] or 0) + weight
        source[role] = source[role] or detail
    end
    local function scoreValue(value, weight, detail)
        local valueText = lower(value)
        if containsAny(valueText, {"frontman", "front man", "manager"}) then add("Frontman", weight, detail)
        elseif containsAny(valueText, {"detective", "investigator"}) then add("Detective", weight, detail)
        elseif containsAny(valueText, {
            "guard", "soldier", "staff", "worker", "guard mask",
            "triangle guard", "square guard", "circle guard"
        }) then add("Guard", weight, detail)
        elseif containsAny(valueText, {"player", "contestant", "participant"}) then add("Player", weight, detail) end
    end

    if player.Team then scoreValue(player.Team.Name, 12, "team") end
    for _, object in ipairs({player, character}) do
        if object then
            for _, attributeName in ipairs({"Role", "TeamRole", "PlayerRole", "Class", "Job", "SelectedRole", "CurrentRole"}) do
                local ok, value = pcall(object.GetAttribute, object, attributeName)
                if ok and value ~= nil then scoreValue(value, 14, attributeName) end
            end
        end
    end
    if character then
        local scanned = 0
        for _, child in ipairs(character:GetDescendants()) do
            scoreValue(child.Name, 1, "character appearance")
            scanned = scanned + 1
            if scanned >= 100 then break end
        end
    end

    local visualText = self:GetVisibleText()
    local phrases = {
        Guard = {"playing as guard", "role: guard", "guard duties", "guard mode active"},
        Detective = {"playing as detective", "role: detective", "detective objectives", "evidence backpack"},
        Frontman = {"playing as frontman", "role: frontman", "frontman mode"},
        Player = {"playing as player", "role: player", "contestant mode active"},
    }
    for role, tokens in pairs(phrases) do
        if containsAny(visualText, tokens) then add(role, 10, "visible role HUD") end
    end

    local bestRole, bestScore, secondScore = nil, 0, 0
    for role, score in pairs(scores) do
        if score > bestScore then
            secondScore = bestScore
            bestRole, bestScore = role, score
        elseif score > secondScore then
            secondScore = score
        end
    end
    if bestScore >= 8 and bestScore - secondScore >= 3 then
        return bestRole, bestScore, source[bestRole] or "role signal"
    end
    return nil, bestScore, "role is not yet unambiguous"
end

function Runtime:Matches(instance, config)
    if not instance then return false end
    if not classAllowed(instance, config.TargetClasses) then return false end
    local text = instanceText(instance)
    if config.TargetNames and #config.TargetNames > 0 then
        local exact = false
        for _, name in ipairs(config.TargetNames) do
            if lower(instance.Name) == lower(name) then exact = true break end
        end
        if not exact and not containsAny(text, config.TargetTokens) then return false end
    elseif config.TargetTokens and #config.TargetTokens > 0 and not containsAny(text, config.TargetTokens) then
        return false
    end
    if config.RequiredTokens and #config.RequiredTokens > 0 and not containsAll(text, config.RequiredTokens) then
        return false
    end
    if config.ExcludeTokens and containsAny(text, config.ExcludeTokens) then return false end
    if config.VisibleOnly and instance:IsA("GuiObject") and not isVisibleGui(instance) then return false end
    if type(config.Predicate) == "function" then
        local ok, result = pcall(config.Predicate, instance)
        if not ok or not result then return false end
    end
    return true
end

local function stableList(values)
    local result = {}
    for _, value in ipairs(values or {}) do
        table.insert(result, lower(value))
    end
    table.sort(result)
    return table.concat(result, ",")
end

local function querySignature(config)
    if type(config.Predicate) == "function" or config.NoCache then return nil end
    return table.concat({
        lower(config.Scope or "workspace"),
        stableList(config.TargetNames),
        stableList(config.TargetTokens),
        stableList(config.RequiredTokens),
        stableList(config.ExcludeTokens),
        stableList(config.TargetClasses),
        tostring(config.ReturnAdornee == true),
        tostring(config.VisibleOnly == true),
        tostring(config.MaxTargets or 0),
    }, "|")
end

function Runtime:SetLightweightMode(state)
    self.LightweightMode = state ~= false
    Scheduler:SetLightweight(self.LightweightMode)
    self.QueryCache = {}
end

function Runtime:FindTargets(config)
    config = config or {}
    local signature = querySignature(config)
    local now = os.clock()
    local cache = signature and self.QueryCache[signature] or nil
    local defaultTTL = lower(config.Scope) == "gui" and 0.30 or (self.LightweightMode and 1.35 or 0.65)
    local ttl = tonumber(config.CacheTTL) or defaultTTL
    if cache and #cache.Results == 0 then
        ttl = math.min(ttl, 0.20)
    end

    if cache and cache.Generation == IndexManager.Generation and now - cache.Time <= ttl then
        local results = {}
        for _, target in ipairs(cache.Results) do
            if target and target.Parent then
                table.insert(results, target)
                if config.MaxTargets and #results >= config.MaxTargets then break end
            end
        end
        return results
    end

    local results = {}
    local seen = setmetatable({}, {__mode = "k"})
    forEachIndexed(config.Scope, config.TargetClasses, function(instance)
        if self:Matches(instance, config) then
            local target = config.ReturnAdornee and getAdornee(instance) or instance
            if target and not seen[target] then
                seen[target] = true
                table.insert(results, target)
                if config.MaxTargets and #results >= config.MaxTargets then
                    return false
                end
            end
        end
        return true
    end)

    if signature then
        self.QueryCache[signature] = {
            Time = now,
            Results = results,
            Generation = IndexManager.Generation,
        }
    end
    return results
end

function Runtime:FindNearest(config, origin)
    local nearest, nearestDistance = nil, math.huge
    for _, target in ipairs(self:FindTargets(config)) do
        local position = getPosition(target)
        if position then
            local distance = origin and (position - origin).Magnitude or 0
            if distance < nearestDistance then
                nearest, nearestDistance = target, distance
            end
        end
    end
    return nearest, nearestDistance
end

local function resolveInteractionObjects(target)
    if not target then return nil, nil, nil end
    local prompt = target:IsA("ProximityPrompt") and target
        or target:FindFirstChildWhichIsA("ProximityPrompt", true)
    local detector = target:IsA("ClickDetector") and target
        or target:FindFirstChildWhichIsA("ClickDetector", true)
    local touchPart
    if target:IsA("Tool") then
        touchPart = target:FindFirstChild("Handle") or target:FindFirstChildWhichIsA("BasePart", true)
    elseif target:IsA("BasePart") then
        touchPart = target
    else
        touchPart = target:FindFirstChildWhichIsA("BasePart", true)
    end
    return prompt, detector, touchPart
end

function Runtime:ScoreTarget(target, origin, config)
    config = config or {}
    local position = getPosition(target)
    if not position then return nil, math.huge end
    local distance = origin and (position - origin).Magnitude or 0
    if config.MaxDistance and distance > config.MaxDistance then
        return nil, distance
    end

    local score = -distance
    local text = instanceText(target)
    local name = lower(target.Name)
    for _, token in ipairs(config.TargetTokens or {}) do
        token = lower(token)
        if token ~= "" then
            if name == token then
                score = score + 90
            elseif string.find(name, token, 1, true) then
                score = score + 36
            elseif string.find(text, token, 1, true) then
                score = score + 14
            end
        end
    end
    for _, exactName in ipairs(config.TargetNames or {}) do
        if name == lower(exactName) then score = score + 120 end
    end

    local prompt, detector, touchPart = resolveInteractionObjects(target)
    if prompt and prompt.Enabled then
        score = score + 145
        local actionText = lower(prompt.ActionText)
        local objectText = lower(prompt.ObjectText)
        for _, token in ipairs(config.TargetTokens or {}) do
            token = lower(token)
            if token ~= "" and (string.find(actionText, token, 1, true) or string.find(objectText, token, 1, true)) then
                score = score + 48
            end
        end
        if distance <= math.max(4, tonumber(prompt.MaxActivationDistance) or 0) then
            score = score + 28
        end
    end
    if detector then score = score + 90 end
    if target:IsA("Tool") then score = score + 70 end
    if touchPart then
        score = score + 18
        local transmitter = touchPart:FindFirstChildOfClass("TouchTransmitter")
        if transmitter then score = score + 42 end
    end
    if config.PreferInteractive and not prompt and not detector and not touchPart then
        score = score - 150
    end
    return score, distance
end

function Runtime:FindBestTarget(config, origin)
    config = config or {}
    local best, bestDistance, bestScore = nil, math.huge, -math.huge
    for _, target in ipairs(self:FindTargets(config)) do
        local score, distance = self:ScoreTarget(target, origin, config)
        if score and score > bestScore then
            best, bestDistance, bestScore = target, distance, score
        end
    end
    return best, bestDistance, bestScore
end

function Runtime:FindTool(tokens)
    local player, character = getCharacter()
    local containers = {}
    if character then table.insert(containers, character) end
    local backpack = player and player:FindFirstChildOfClass("Backpack")
    if backpack then table.insert(containers, backpack) end
    for _, container in ipairs(containers) do
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and (#(tokens or {}) == 0 or containsAny(item.Name, tokens)) then
                return item
            end
        end
    end
    return nil
end

function Runtime:EquipTool(tool)
    local _, character, humanoid = getCharacter()
    if not tool or not character or not humanoid then return false end
    if tool.Parent ~= character then
        local ok = pcall(humanoid.EquipTool, humanoid, tool)
        if not ok then return false end
    end
    return true
end

function Runtime:ActivateTool(tokens, feature, options)
    options = options or {}
    -- Do not reserve the shared tool channel until a usable tool actually exists.
    -- This prevents a waiting feature from starving another enabled tool feature.
    local tool = self:FindTool(tokens or {})
    if not tool then return false, "matching tool not found" end
    if not self:EquipTool(tool) then return false, "matching tool could not be equipped" end
    local claimed, ownerName = self:ClaimAction(
        feature,
        options.Resource or "ToolAction",
        options.Priority,
        options.Duration or options.Cooldown or 0.35
    )
    if not claimed then return false, "action is currently controlled by " .. tostring(ownerName) end
    local ok, err = pcall(tool.Activate, tool)
    return ok, ok and nil or tostring(err)
end

function Runtime:Interact(target, feature, options)
    if not target then return false, "target not found" end
    options = options or {}

    local prompt, detector, touchPart = resolveInteractionObjects(target)
    local _, _, _, root = getCharacter()
    local virtualInput
    pcall(function() virtualInput = game:GetService("VirtualInputManager") end)

    local promptSupported = prompt and prompt.Enabled
        and (type(fireproximityprompt) == "function" or virtualInput ~= nil)
    local detectorSupported = detector and type(fireclickdetector) == "function"
    local touchSupported = touchPart and root and type(firetouchinterest) == "function"
    if not promptSupported and not detectorSupported and not touchSupported then
        return false, "no supported prompt, click, or touch interaction is available"
    end

    local claimed, ownerName = self:ClaimAction(
        feature,
        options.Resource or "Interaction",
        options.Priority,
        options.Duration or 0.4
    )
    if not claimed then return false, "interaction is currently controlled by " .. tostring(ownerName) end

    local errors = {}
    if promptSupported then
        if type(fireproximityprompt) == "function" then
            local ok, err = pcall(function()
                -- Some executors accept the hold duration argument and others do not.
                local hold = math.max(0, tonumber(prompt.HoldDuration) or 0)
                local worked = pcall(fireproximityprompt, prompt, hold)
                if not worked then
                    fireproximityprompt(prompt)
                end
            end)
            if ok then return true end
            table.insert(errors, "prompt helper: " .. tostring(err))
        end
        if virtualInput then
            local key = prompt.KeyboardKeyCode
            if key == Enum.KeyCode.Unknown then key = Enum.KeyCode.E end
            local ok, err = pcall(function()
                virtualInput:SendKeyEvent(true, key, false, game)
                task.wait(math.max(0.06, math.min(tonumber(prompt.HoldDuration) or 0.08, 0.35)))
                virtualInput:SendKeyEvent(false, key, false, game)
            end)
            if ok then return true end
            table.insert(errors, "prompt key input: " .. tostring(err))
        end
    end

    if detectorSupported then
        local ok, err = pcall(fireclickdetector, detector)
        if ok then return true end
        table.insert(errors, "click detector: " .. tostring(err))
    end

    if touchSupported then
        local ok, err = pcall(function()
            firetouchinterest(root, touchPart, 0)
            task.wait()
            firetouchinterest(root, touchPart, 1)
        end)
        if ok then return true end
        table.insert(errors, "touch pickup: " .. tostring(err))
    end

    return false, #errors > 0 and table.concat(errors, " | ") or "interaction attempt failed"
end

function Runtime:ClaimAction(feature, resource, priority, duration)
    if not feature then return true end
    resource = tostring(resource or "General")
    local lease = self.ActionLeases[resource]
    if not lease then
        lease = {Owner = nil, Priority = -math.huge, ExpiresAt = 0}
        self.ActionLeases[resource] = lease
    end
    local now = os.clock()
    priority = tonumber(priority) or tonumber(feature.Config and feature.Config.ActionPriority) or 50
    duration = tonumber(duration) or 0.35
    local owner = lease.Owner
    if owner == feature or owner == nil or owner.Enabled ~= true or now >= lease.ExpiresAt or priority > lease.Priority then
        lease.Owner = feature
        lease.Priority = priority
        lease.ExpiresAt = now + duration
        return true
    end
    return false, owner and owner.Name or "another feature"
end

function Runtime:ReleaseActions(feature)
    for _, lease in pairs(self.ActionLeases) do
        if not feature or lease.Owner == feature then
            lease.Owner = nil
            lease.Priority = -math.huge
            lease.ExpiresAt = 0
        end
    end
end

function Runtime:CanUseMovement(feature, priority)
    local lease = self.MovementLease
    local now = os.clock()
    priority = tonumber(priority) or tonumber(feature and feature.Config and feature.Config.MovementPriority) or 50
    local owner = lease.Owner
    if owner == feature or owner == nil or owner.Enabled ~= true or now >= lease.ExpiresAt or priority > lease.Priority then
        return true
    end
    return false, owner and owner.Name or "another movement feature"
end

function Runtime:ClaimMovement(feature, priority, duration)
    if not feature then return true end
    local lease = self.MovementLease
    local now = os.clock()
    priority = tonumber(priority) or tonumber(feature.Config and feature.Config.MovementPriority) or 50
    duration = tonumber(duration) or 0.9
    local owner = lease.Owner
    if owner == feature or owner == nil or owner.Enabled ~= true or now >= lease.ExpiresAt or priority > lease.Priority then
        lease.Owner = feature
        lease.Priority = priority
        lease.ExpiresAt = now + duration
        return true
    end
    return false, owner and owner.Name or "another movement feature"
end

function Runtime:StopMovement(feature, force)
    local lease = self.MovementLease
    if not force and feature and lease.Owner and lease.Owner ~= feature then return false end
    local _, _, humanoid, root = getCharacter()
    if humanoid and root then
        pcall(humanoid.MoveTo, humanoid, root.Position)
        pcall(humanoid.Move, humanoid, Vector3.zero, false)
    end
    if force or lease.Owner == feature or not feature then
        if lease.Owner and type(lease.Owner) == "table" then lease.Owner._MoveState = nil end
        lease.Owner = nil
        lease.Priority = -math.huge
        lease.ExpiresAt = 0
    end
    if feature then feature._MoveState = nil end
    return true
end

function Runtime:MoveTo(position, feature, options)
    options = options or {}
    local _, _, humanoid, root = getCharacter()
    if not humanoid or not root then return false, "character is not ready" end
    if not position then return false, "target has no position" end

    local stopDistance = tonumber(options.StopDistance) or 5
    local distance = (root.Position - position).Magnitude
    if distance <= stopDistance then
        if feature then
            local claimed, ownerName = self:ClaimMovement(
                feature,
                options.MovementPriority,
                options.HoldLeaseAtTarget or 0.9
            )
            if not claimed then return false, "movement is currently controlled by " .. tostring(ownerName) end
            pcall(humanoid.MoveTo, humanoid, root.Position)
            pcall(humanoid.Move, humanoid, Vector3.zero, false)
            if feature._MoveState then feature._MoveState.ReachedAt = os.clock() end
        end
        return true, "target reached"
    end

    local claimed, ownerName = self:ClaimMovement(feature, options.MovementPriority, options.LeaseDuration)
    if not claimed then return false, "movement is currently controlled by " .. tostring(ownerName) end

    local state = feature and feature._MoveState or self._AnonymousMoveState
    if type(state) ~= "table" then state = {} end
    if feature then feature._MoveState = state else self._AnonymousMoveState = state end

    local now = os.clock()
    local targetChanged = not state.Target or (state.Target - position).Magnitude > (tonumber(options.TargetChangeDistance) or 7)
    local direct = options.Direct == true or options.UsePathfinding == false
    local repathInterval = tonumber(options.RepathInterval) or (self.LightweightMode and 1.65 or 1.0)

    if direct then
        state.Waypoints = nil
        state.Index = nil
    elseif targetChanged or not state.Waypoints or now - (state.ComputedAt or 0) >= repathInterval then
        state.Target = position
        state.ComputedAt = now
        state.Waypoints = nil
        state.Index = 2
        local path = PathfindingService:CreatePath({
            AgentRadius = tonumber(options.AgentRadius) or 2,
            AgentHeight = tonumber(options.AgentHeight) or 5,
            AgentCanJump = true,
            WaypointSpacing = tonumber(options.WaypointSpacing) or 6,
        })
        local ok = pcall(path.ComputeAsync, path, root.Position, position)
        if ok and path.Status == Enum.PathStatus.Success then
            state.Waypoints = path:GetWaypoints()
        end
    end

    local destination = position
    local waypoint
    if state.Waypoints and #state.Waypoints >= 2 then
        local index = math.clamp(state.Index or 2, 2, #state.Waypoints)
        waypoint = state.Waypoints[index]
        if (root.Position - waypoint.Position).Magnitude <= (tonumber(options.WaypointReachDistance) or 4) and index < #state.Waypoints then
            index = index + 1
            state.Index = index
            waypoint = state.Waypoints[index]
        end
        destination = waypoint.Position
        if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
    end

    local commandInterval = tonumber(options.CommandInterval) or 0.45
    if targetChanged or now - (state.LastCommandAt or 0) >= commandInterval then
        state.Target = position
        state.LastCommandAt = now
        pcall(humanoid.MoveTo, humanoid, destination)
    end

    return true, waypoint and "following cached path" or "moving directly to target"
end

function Runtime:ClickGui(target, feature, options)
    if not target then return false, "GUI target not found" end
    options = options or {}
    local claimed, ownerName = self:ClaimAction(
        feature,
        options.Resource or "GuiAction",
        options.Priority,
        options.Duration or 0.25
    )
    if not claimed then return false, "GUI action is currently controlled by " .. tostring(ownerName) end

    local button = target:IsA("GuiButton") and target
        or target:FindFirstChildWhichIsA("GuiButton", true)
    if button and not button.Active then
        pcall(function() button.Active = true end)
    end

    -- Executors expose different signal helpers. Try all normal button signals,
    -- rather than only Activated, before falling back to simulated pointer input.
    if button and type(firesignal) == "function" then
        local fired = false
        for _, signalName in ipairs({"Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up"}) do
            local ok, signal = pcall(function() return button[signalName] end)
            if ok and signal then
                local signalOk = pcall(firesignal, signal)
                fired = fired or signalOk
            end
        end
        if fired then return true end
    end

    if button and type(getconnections) == "function" then
        local invoked = false
        for _, signalName in ipairs({"Activated", "MouseButton1Click"}) do
            local ok, signal = pcall(function() return button[signalName] end)
            if ok and signal then
                local connectionOk, connections = pcall(getconnections, signal)
                if connectionOk and type(connections) == "table" then
                    for _, connection in ipairs(connections) do
                        local callback = connection.Function or connection.Fire
                        if type(callback) == "function" then
                            invoked = pcall(callback) or invoked
                        elseif type(connection.Fire) == "function" then
                            invoked = pcall(connection.Fire, connection) or invoked
                        end
                    end
                end
            end
        end
        if invoked then return true end
    end

    local guiObject = button or (target:IsA("GuiObject") and target)
    if guiObject then
        local center = guiObject.AbsolutePosition + guiObject.AbsoluteSize / 2
        local virtualInput
        pcall(function() virtualInput = game:GetService("VirtualInputManager") end)
        if virtualInput then
            local ok, err = pcall(function()
                virtualInput:SendMouseMoveEvent(center.X, center.Y, game)
                virtualInput:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
                task.wait()
                virtualInput:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
            end)
            if ok then return true end
            if err then self.LastGuiInputError = tostring(err) end
        end

        local virtualUser
        pcall(function() virtualUser = game:GetService("VirtualUser") end)
        if virtualUser then
            local ok = pcall(function()
                virtualUser:CaptureController()
                virtualUser:Button1Down(Vector2.new(center.X, center.Y), workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new())
                task.wait()
                virtualUser:Button1Up(Vector2.new(center.X, center.Y), workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new())
            end)
            if ok then return true end
        end
    end
    return false, "executor cannot press the detected GUI control"
end

local FeatureMethods = {}
FeatureMethods.__index = FeatureMethods

function FeatureMethods:_SetStatus(state, detail)
    local nextStatus = tostring(state or "Unknown")
    local nextDetail = tostring(detail or "")
    if self.Status == nextStatus and self.StatusDetail == nextDetail then return end
    self.Status = nextStatus
    self.StatusDetail = nextDetail
    for id, callback in pairs(self.StatusListeners) do
        local ok = pcall(callback, self.Status, self.StatusDetail, self)
        if not ok then self.StatusListeners[id] = nil end
    end
end

function FeatureMethods:GetStatus()
    return self.Status, self.StatusDetail
end

function FeatureMethods:GetLastError()
    return self.LastError
end

function FeatureMethods:SubscribeStatus(callback)
    self.NextListenerId = self.NextListenerId + 1
    local id = self.NextListenerId
    self.StatusListeners[id] = callback
    local disconnected = false
    return {
        Disconnect = function()
            if disconnected then return end
            disconnected = true
            self.StatusListeners[id] = nil
        end,
    }
end

function FeatureMethods:_TrackConnection(connection)
    if connection then table.insert(self.Connections, connection) end
    return connection
end

function FeatureMethods:_TrackInstance(instance)
    if instance then table.insert(self.Instances, instance) end
    return instance
end

function FeatureMethods:_Spawn(callback)
    local thread = task.spawn(function()
        local ok, err = xpcall(callback, debug.traceback)
        if not ok and self.Enabled then
            self.LastError = tostring(err)
            self:_SetStatus("Error", self.LastError)
            warn("[SquidNoMo][" .. self.Name .. "] " .. self.LastError)
        end
    end)
    table.insert(self.Threads, thread)
    return thread
end

function FeatureMethods:_Loop(interval, callback)
    interval = tonumber(interval) or tonumber(self.Config.Interval) or 0.5
    local idleInterval = tonumber(self.Config.IdleInterval) or math.max(interval * 4, 1.0)
    Scheduler:Add(self, interval, idleInterval, function(owner)
        local contextAllowed, contextDetail = Runtime:FeatureContextAllowed(owner)
        if not contextAllowed then
            Runtime:StopMovement(owner)
            if type(owner.OnContextBlocked) == "function" then
                pcall(owner.OnContextBlocked, owner, contextDetail)
            end
            owner:_SetStatus("Waiting", contextDetail)
            return false
        end

        local ok, active, detail = pcall(callback, owner)
        if not ok then error(active) end
        local hint = Runtime:GetFeatureVisualHint(owner)
        if hint and hint ~= "" then
            detail = tostring(detail or (active and "Working" or owner.Config.WaitingMessage or "Waiting")) .. " • " .. hint
        end
        if active then
            owner:_SetStatus("Active", detail or "Working")
        else
            owner:_SetStatus("Waiting", detail or owner.Config.WaitingMessage or "Waiting for the matching game objects")
        end
        return active == true
    end)
end

function FeatureMethods:_Clear()
    Scheduler:Remove(self)
    Runtime:StopMovement(self)
    Runtime:ReleaseActions(self)
    for _, connection in ipairs(self.Connections) do
        pcall(function() connection:Disconnect() end)
    end
    self.Connections = {}
    for _, thread in ipairs(self.Threads) do
        pcall(task.cancel, thread)
    end
    self.Threads = {}
    for _, instance in ipairs(self.Instances) do
        pcall(function() instance:Destroy() end)
    end
    self.Instances = {}
    if type(self.Restore) == "function" then pcall(self.Restore, self) end
    self.Restore = nil
    self.OnContextBlocked = nil
end

local function addHighlight(feature, target, config)
    local adornee = getAdornee(target)
    if not adornee then return false end
    if feature.HighlightByTarget[adornee] and feature.HighlightByTarget[adornee].Parent then return false end
    local highlight = Instance.new("Highlight")
    highlight.Name = "SquidNoMo_" .. feature.Id
    highlight.Adornee = adornee
    highlight.FillColor = config.Color or Color3.fromRGB(42, 255, 126)
    highlight.OutlineColor = config.OutlineColor or Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = config.FillTransparency or 0.55
    highlight.OutlineTransparency = config.OutlineTransparency or 0.05
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = adornee
    feature.HighlightByTarget[adornee] = highlight
    feature:_TrackInstance(highlight)
    return true
end

local getOtherCharacterTargets

local function startHighlight(feature)
    feature.HighlightByTarget = {}
    feature:_Loop(feature.Config.Interval or 0.8, function(self)
        local targets
        if self.Config.PlayerMode then
            targets = getOtherCharacterTargets(self.Config)
        else
            targets = Runtime:FindTargets({
                Scope = self.Config.Scope or "Workspace",
                TargetNames = self.Config.TargetNames,
                TargetTokens = self.Config.TargetTokens,
                RequiredTokens = self.Config.RequiredTokens,
                ExcludeTokens = self.Config.ExcludeTokens,
                TargetClasses = self.Config.TargetClasses or {"Model", "BasePart"},
                ReturnAdornee = true,
                MaxTargets = self.Config.MaxTargets or 80,
                VisibleOnly = self.Config.VisibleOnly,
            })
        end
        local added = 0
        for _, target in ipairs(targets) do
            if addHighlight(self, target, self.Config) then added = added + 1 end
        end
        local alive = 0
        for target, highlight in pairs(self.HighlightByTarget) do
            if target.Parent and highlight.Parent then
                alive = alive + 1
            else
                self.HighlightByTarget[target] = nil
            end
        end
        return alive > 0, alive > 0 and ("Tracking " .. alive .. " target(s)") or self.Config.WaitingMessage
    end)
end

local function startWalkTo(feature)
    feature:_Loop(feature.Config.Interval or 0.7, function(self)
        local _, _, _, root = getCharacter()
        if not root then return false, "Waiting for the local character" end
        local contextAllowed, contextDetail = Runtime:ContextAllowed(self.Config)
        if not contextAllowed then return false, contextDetail end
        if self.Config.SkipIfToolTokens and Runtime:FindTool(self.Config.SkipIfToolTokens) then
            return false, self.Config.CompletedMessage or "Required item is already in the inventory"
        end
        if self.Config.RequireToolTokens and not Runtime:FindTool(self.Config.RequireToolTokens) then
            return false, "Waiting for " .. table.concat(self.Config.RequireToolTokens, "/") .. " tool"
        end
        local movementAvailable, movementOwner = Runtime:CanUseMovement(self, self.Config.MovementPriority)
        if not movementAvailable then return false, "Movement is currently controlled by " .. tostring(movementOwner) end

        local targetTokens = self.Config.TargetTokens
        local targetNames = self.Config.TargetNames
        local excludeTokens = self.Config.ExcludeTokens
        local waitingMessage = self.Config.WaitingMessage
        local id = lower(self.Id)

        -- Detective navigation follows the visible objective rather than assuming
        -- evidence is already spawned as soon as the role begins.
        if string.find(id, "mapped.detective.island_navigation.islandnavigator", 1, true) then
            local detective = Runtime:GetDetectiveState()
            if detective.Stage == "Deposit Evidence" then
                Runtime:StopMovement(self)
                return false, "Evidence is ready to deposit; use Boat Depositor"
            elseif detective.Stage == "Find Island" then
                targetTokens = {"objective", "island", "shore", "landing", "dock", "waypoint", "marker", "hint"}
                excludeTokens = {"wrong island", "decoy", "deposit", "submitted"}
                waitingMessage = "Waiting for the island objective marker or landing point"
            else
                targetTokens = {"evidence", "clue", "file", "document", "keycard", "fingerprint", "objective", "hint"}
                excludeTokens = {"boat deposit", "submitted", "evidence box"}
                waitingMessage = "Waiting for an evidence marker on the island"
            end
        end

        local targetQuery = {
            Scope = self.Config.Scope or "Workspace",
            TargetNames = targetNames,
            TargetTokens = targetTokens,
            RequiredTokens = self.Config.RequiredTokens,
            ExcludeTokens = excludeTokens,
            TargetClasses = self.Config.TargetClasses or {"Model", "BasePart", "ProximityPrompt", "ClickDetector", "Tool"},
            ReturnAdornee = self.Config.ReturnAdornee,
            MaxTargets = self.Config.MaxTargets or 120,
            PreferInteractive = self.Config.Interact == true,
        }
        local target, distance
        if self.Config.Interact then
            target, distance = Runtime:FindBestTarget(targetQuery, root.Position)
        else
            target, distance = Runtime:FindNearest(targetQuery, root.Position)
        end
        if not target then return false, waitingMessage end
        local position = getPosition(target)
        local moved, moveDetail = Runtime:MoveTo(position, self, self.Config)
        if self.Enabled and self.Config.Interact and position then
            local _, _, _, currentRoot = getCharacter()
            if currentRoot and (currentRoot.Position - position).Magnitude <= (self.Config.InteractDistance or 12) then
                local cooldown = self.Config.ActionCooldown or 0.8
                if os.clock() - (self.LastAction or 0) < cooldown then
                    return true, "Reached " .. target.Name .. " — interaction cooling down"
                end
                local interacted, interactDetail = Runtime:Interact(target, self, {Priority = self.Config.ActionPriority or 55, Duration = cooldown})
                if interacted then
                    self.LastAction = os.clock()
                    return true, "Reached and interacted with " .. target.Name
                end
                return moved, interactDetail or moveDetail
            end
        end
        return moved, moved and ("Walking to " .. target.Name .. " (" .. math.floor(distance) .. " studs)") or moveDetail
    end)
end

local function startInteract(feature)
    feature:_Loop(feature.Config.Interval or 0.55, function(self)
        local _, _, _, root = getCharacter()
        if not root then return false, "Waiting for the local character" end
        local contextAllowed, contextDetail = Runtime:ContextAllowed(self.Config)
        if not contextAllowed then return false, contextDetail end

        local id = lower(self.Id)
        if string.find(id, "mapped.detective.evidence.evidencecollector", 1, true) then
            local detective = Runtime:GetDetectiveState()
            if detective.Evidence and detective.Capacity and detective.Evidence >= detective.Capacity then
                return false, "Evidence backpack is full; return to the boat"
            elseif detective.Stage == "Deposit Evidence" then
                return false, "Current detective objective is to deposit evidence"
            end
        end

        if self.Config.SkipIfToolTokens and Runtime:FindTool(self.Config.SkipIfToolTokens) then
            return false, self.Config.CompletedMessage or "Required item is already in the inventory"
        end
        if self.Config.ToolTokens and not Runtime:FindTool(self.Config.ToolTokens) then
            return false, "Waiting for " .. table.concat(self.Config.ToolTokens, "/") .. " tool"
        end
        if self.Config.Walk then
            local movementAvailable, movementOwner = Runtime:CanUseMovement(self, self.Config.MovementPriority)
            if not movementAvailable then return false, "Movement is currently controlled by " .. tostring(movementOwner) end
        end

        local query = {
            Scope = self.Config.Scope or "Workspace",
            TargetNames = self.Config.TargetNames,
            TargetTokens = self.Config.TargetTokens,
            RequiredTokens = self.Config.RequiredTokens,
            ExcludeTokens = self.Config.ExcludeTokens,
            TargetClasses = self.Config.TargetClasses or {"Model", "BasePart", "ProximityPrompt", "ClickDetector"},
            MaxTargets = self.Config.MaxTargets or 140,
        }
        query.PreferInteractive = true
        query.MaxDistance = self.Config.Walk and nil or self.Config.MaxDistance
        local target, distance = Runtime:FindBestTarget(query, root.Position)

        if not target then return false, self.Config.WaitingMessage end
        if self.Config.MaxDistance and distance > self.Config.MaxDistance then
            if self.Config.Walk then
                local moved, detail = Runtime:MoveTo(getPosition(target), self, self.Config)
                return moved, moved and ("Walking to " .. target.Name) or detail
            end
            return false, "Nearest target is " .. math.floor(distance) .. " studs away"
        end
        if self.Config.ToolTokens then Runtime:EquipTool(Runtime:FindTool(self.Config.ToolTokens)) end
        local cooldown = self.Config.ActionCooldown or 0.45
        if os.clock() - (self.LastAction or 0) < cooldown then
            return true, "Target detected — interaction cooling down"
        end
        local ok, detail = Runtime:Interact(target, self, {Priority = self.Config.ActionPriority or 55, Duration = cooldown})
        if ok then self.LastAction = os.clock() end
        return ok, ok and ("Interacted with " .. target.Name) or detail
    end)
end

getOtherCharacterTargets = function(config)
    local targets = {}
    local localPlayer = getLocalPlayer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local text = lower(player.Name .. " " .. player.DisplayName .. " " .. (player.Team and player.Team.Name or ""))
            if humanoid and root and humanoid.Health > 0
                and (not config.PlayerTokens or #config.PlayerTokens == 0 or containsAny(text, config.PlayerTokens))
                and not containsAny(text, config.ExcludePlayerTokens)
            then
                table.insert(targets, player.Character)
            end
        end
    end
    if config.IncludeNPCs then
        local now = os.clock()
        local cache = Runtime._NPCCharacterCache
        if not cache or now - cache.Time > 1.0 then
            local models = {}
            forEachIndexed("Workspace", {"Model"}, function(instance)
                if not Players:GetPlayerFromCharacter(instance) then
                    local humanoid = instance:FindFirstChildOfClass("Humanoid")
                    local root = instance:FindFirstChild("HumanoidRootPart")
                    if humanoid and root then table.insert(models, instance) end
                end
                return true
            end)
            cache = {Time = now, Models = models}
            Runtime._NPCCharacterCache = cache
        end
        for _, instance in ipairs(cache.Models) do
            if instance.Parent then
                local humanoid = instance:FindFirstChildOfClass("Humanoid")
                local root = instance:FindFirstChild("HumanoidRootPart")
                if humanoid and root and humanoid.Health > 0
                    and (not config.TargetTokens or containsAny(instanceText(instance), config.TargetTokens))
                then
                    table.insert(targets, instance)
                end
            end
        end
    end
    return targets
end

local function nearestCharacter(config, origin)
    local best, distance = nil, math.huge
    for _, character in ipairs(getOtherCharacterTargets(config)) do
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local d = (root.Position - origin).Magnitude
            if d < distance then best, distance = character, d end
        end
    end
    return best, distance
end

local function startToolAura(feature)
    feature:_Loop(feature.Config.Interval or 0.18, function(self)
        local contextAllowed, contextDetail = Runtime:ContextAllowed(self.Config)
        if not contextAllowed then return false, contextDetail end
        local _, character, _, root = getCharacter()
        if not character or not root then return false, "Waiting for the local character" end
        local target, distance = nearestCharacter(self.Config, root.Position)
        if not target or distance > (self.Config.Range or 10) then
            return false, "Waiting for a target within " .. tostring(self.Config.Range or 10) .. " studs"
        end
        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        if self.Config.FaceTarget and targetRoot then
            pcall(function()
                root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetRoot.Position.X, root.Position.Y, targetRoot.Position.Z))
            end)
        end
        local ok, detail = Runtime:ActivateTool(self.Config.ToolTokens or {}, self, {
            Resource = "CombatAction",
            Priority = self.Config.ActionPriority or 60,
            Duration = math.max(self.Config.Interval or 0.18, 0.22),
        })
        return ok, ok and ("Activated tool near " .. target.Name) or detail
    end)
end

local function rectsOverlap(a, b)
    if not a or not b then return false end
    local aMin, aMax = a.AbsolutePosition, a.AbsolutePosition + a.AbsoluteSize
    local bMin, bMax = b.AbsolutePosition, b.AbsolutePosition + b.AbsoluteSize
    return aMin.X <= bMax.X and aMax.X >= bMin.X and aMin.Y <= bMax.Y and aMax.Y >= bMin.Y
end

local function directGuiText(instance)
    if not instance then return "" end
    local parts = {instance.Name}
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        table.insert(parts, instance.Text)
    elseif instance:IsA("ImageButton") or instance:IsA("ImageLabel") then
        local ok, image = pcall(function() return instance.Image end)
        if ok and image then table.insert(parts, image) end
    end
    return lower(table.concat(parts, " "))
end

local function scoreGuiCandidate(instance, tokens)
    local direct = directGuiText(instance)
    local context = instanceText(instance)
    local score, hits = 0, 0
    for _, rawToken in ipairs(tokens or {}) do
        local token = lower(rawToken)
        if token ~= "" then
            if direct == token then
                score = score + 80 + math.min(#token, 24)
                hits = hits + 1
            elseif string.find(direct, token, 1, true) then
                score = score + 36 + math.min(#token, 20)
                hits = hits + 1
            elseif string.find(context, token, 1, true) then
                score = score + 12 + math.min(#token, 12)
                hits = hits + 1
            end
        end
    end
    if hits == 0 then return nil end

    if instance:IsA("GuiButton") then
        score = score + 18
        local ok, active = pcall(function() return instance.Active end)
        if ok and active then score = score + 8 end
        local okSelectable, selectable = pcall(function() return instance.Selectable end)
        if okSelectable and selectable then score = score + 4 end
    end
    local size = safeGuiVector(instance, "AbsoluteSize")
    local area = math.max(0, size.X) * math.max(0, size.Y)
    if area >= 400 then score = score + math.min(12, math.log(area + 1)) end
    score = score + math.min(10, safeGuiNumber(instance, "ZIndex", 0))

    -- Generic menu controls are common in the experience and can contain words
    -- such as "play" or "button" in their ancestors. Penalize them unless the
    -- requested token explicitly names that control.
    local menuWords = {"shop", "daily reward", "settings", "inventory", "purchase", "buy", "donate", "close", "cancel"}
    for _, word in ipairs(menuWords) do
        if string.find(context, word, 1, true) and not containsAny(word, tokens or {}) then
            score = score - 55
        end
    end
    return score
end

local function findVisibleGui(tokens, classes)
    local player = getLocalPlayer()
    local gui = player and player:FindFirstChildOfClass("PlayerGui")
    if not gui then return nil end
    local key = stableList(tokens) .. "|" .. stableList(classes or {"GuiObject"})
    Runtime._GuiQueryCache = Runtime._GuiQueryCache or {}
    local cached = Runtime._GuiQueryCache[key]
    local now = os.clock()
    if cached and now - cached.Time < 0.18 then
        if cached.Instance and cached.Instance.Parent and isVisibleGui(cached.Instance) then
            return cached.Instance
        elseif cached.Instance == nil then
            return nil
        end
    end

    local found, bestScore = nil, -math.huge
    forEachIndexed("Gui", classes or {"GuiObject"}, function(instance)
        if classAllowed(instance, classes or {"GuiObject"}) and isVisibleGui(instance)
            and not isSquidNoMoGui(instance)
        then
            local score = scoreGuiCandidate(instance, tokens or {})
            if score and score > bestScore then
                found, bestScore = instance, score
            end
        end
        return true
    end)
    Runtime._GuiQueryCache[key] = {Time = now, Instance = found}
    return found
end

local function startTiming(feature)
    feature:_Loop(feature.Config.Interval or 0.03, function(self)
        local indicator = findVisibleGui(self.Config.IndicatorTokens or {"indicator", "pointer", "cursor", "needle"})
        local zone = findVisibleGui(self.Config.ZoneTokens or {"sweetspot", "sweet spot", "safezone", "safe zone", "bluezone", "greenzone", "target"})
        if indicator and zone then
            local claimed, ownerName = Runtime:ClaimAction(
                self,
                "GuiAction",
                self.Config.ActionPriority or 80,
                math.max(self.Config.Interval or 0.05, 0.22)
            )
            if not claimed then
                return false, "Timing input is currently controlled by " .. tostring(ownerName)
            end
            if rectsOverlap(indicator, zone) then
                if os.clock() - self.LastAction >= (self.Config.ActionCooldown or 0.35) then
                    local action = findVisibleGui(self.Config.ActionTokens or {"pull", "throw", "hit", "play", "tap", "button"}, {"GuiButton"})
                    local ok, detail = Runtime:ClickGui(action or indicator, self, {
                        Resource = "GuiAction",
                        Priority = self.Config.ActionPriority or 80,
                        Duration = self.Config.ActionCooldown or 0.35,
                    })
                    if ok then self.LastAction = os.clock() end
                    return ok, ok and "Pressed at the target timing zone" or detail
                end
                return true, "Timing zone detected"
            end
            return true, "Timing meter detected — waiting for the target zone"
        end
        local action = findVisibleGui(self.Config.ActionTokens or {}, {"GuiButton"})
        if self.Config.ClickActionWhenVisible and action and os.clock() - self.LastAction >= (self.Config.ActionCooldown or 0.5) then
            local ok, detail = Runtime:ClickGui(action, self, {
                Resource = "GuiAction",
                Priority = self.Config.ActionPriority or 80,
                Duration = self.Config.ActionCooldown or 0.5,
            })
            if ok then self.LastAction = os.clock() end
            return ok, ok and ("Pressed " .. action.Name) or detail
        end
        return false, self.Config.WaitingMessage or "Waiting for the minigame timing interface"
    end)
end

local function startGuiAction(feature)
    feature:_Loop(feature.Config.Interval or 0.2, function(self)
        local action = findVisibleGui(self.Config.ActionTokens or self.Config.TargetTokens or {}, {"GuiButton"})
        if not action then return false, self.Config.WaitingMessage or "Waiting for the matching game button" end
        if os.clock() - self.LastAction < (self.Config.ActionCooldown or 0.5) then return true, "Action control detected" end
        local ok, detail = Runtime:ClickGui(action, self, {
            Resource = "GuiAction",
            Priority = self.Config.ActionPriority or 50,
            Duration = self.Config.ActionCooldown or 0.5,
        })
        if ok then self.LastAction = os.clock() end
        return ok, ok and ("Pressed " .. action.Name) or detail
    end)
end

local SharedGroundSample = {Time = 0, Character = nil, Root = nil, Hit = nil, CFrame = nil}
local SharedGroundRayParams = RaycastParams.new()
SharedGroundRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function sampleGround(character, humanoid, root)
    local now = os.clock()
    if SharedGroundSample.Character == character and SharedGroundSample.Root == root
        and now - SharedGroundSample.Time < 0.075
    then
        return SharedGroundSample.Hit, SharedGroundSample.CFrame
    end
    SharedGroundRayParams.FilterDescendantsInstances = character and {character} or {}
    local hit = Workspace:Raycast(root.Position, Vector3.new(0, -8, 0), SharedGroundRayParams)
    local safeCFrame = hit and humanoid.FloorMaterial ~= Enum.Material.Air and root.CFrame or nil
    SharedGroundSample = {
        Time = now,
        Character = character,
        Root = root,
        Hit = hit,
        CFrame = safeCFrame,
    }
    return hit, safeCFrame
end

local function startAntiFall(feature)
    feature.SafeCFrame = nil
    feature:_Loop(feature.Config.Interval or 0.12, function(self)
        local _, character, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        local _, safeCFrame = sampleGround(character, humanoid, root)
        if safeCFrame then
            self.SafeCFrame = safeCFrame
            return true, "Safe position tracked"
        end
        if self.SafeCFrame and (root.Position.Y < self.SafeCFrame.Position.Y - (self.Config.DropDistance or 18)
            or root.AssemblyLinearVelocity.Y < -(self.Config.FallVelocity or 75))
        then
            local claimed, ownerName = Runtime:ClaimAction(
                self,
                "Recovery",
                self.Config.RecoveryPriority or 70,
                0.8
            )
            if not claimed then
                return true, "Fall recovery is currently controlled by " .. tostring(ownerName)
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = self.SafeCFrame + Vector3.new(0, 2.5, 0)
            return true, "Recovered from a fall"
        end
        return true, "Monitoring fall state"
    end)
end

local function statusWord(value)
    local text = lower(value)
    if text == "red" or text == "redlight" or text == "red light" then return "Red" end
    if text == "green" or text == "greenlight" or text == "green light" then return "Green" end
    if string.find(text, "red light", 1, true) or string.find(text, "stop moving", 1, true)
        or string.find(text, "movement forbidden", 1, true) or string.find(text, "freeze", 1, true)
    then
        return "Red"
    end
    if string.find(text, "green light", 1, true) or string.find(text, "you may move", 1, true)
        or string.find(text, "movement allowed", 1, true) or string.find(text, "go now", 1, true)
    then
        return "Green"
    end
    return nil
end

local function contextualStatusWord(value, context)
    local state = statusWord(value)
    if state then return state end
    if not containsAny(context, {
        "light", "rlgl", "doll", "younghee", "young hee", "yeonghee",
        "mugunghwa", "signal", "phase", "round state", "can move", "movement"
    }) then
        return nil
    end
    local text = lower(value)
    if text == "stop" or text == "freeze" or text == "false" or text == "0"
        or text == "locked" or text == "watching"
    then
        return "Red"
    end
    if text == "go" or text == "move" or text == "true" or text == "1"
        or text == "allowed" or text == "singing"
    then
        return "Green"
    end
    return nil
end

local function rlglColorState(color)
    if typeof(color) ~= "Color3" then return nil end
    local r, g, b = color.R, color.G, color.B
    if g >= 0.42 and g > r * 1.24 and g > b * 1.08 then return "Green" end
    if r >= 0.46 and r > g * 1.24 and r > b * 1.08 then return "Red" end
    return nil
end

local RLGL_CONTEXT = {
    "rlgl", "red light", "green light", "redlight", "greenlight",
    "younghee", "young hee", "yeonghee", "mugunghwa", "robot doll", "doll signal"
}
local RLGL_DOLL_TOKENS = {
    "younghee", "young hee", "yeonghee", "mugunghwa", "robot doll", "doll"
}
local RLGL_AMBIENT_SOUND_EXCLUDES = {
    "gun", "shot", "rifle", "kill", "death", "hit", "impact", "footstep",
    "walk", "run", "jump", "button", "click", "purchase", "reward", "lobby",
    "background", "ambient", "theme", "emote", "interface"
}
local RLGL_GENERIC_MODEL_EXCLUDES = {
    "tree", "grass", "wall", "floor", "ground", "terrain", "field", "map",
    "bridge", "door", "cloud", "building", "spawn", "finish", "start", "camera",
    "light", "lamp", "speaker", "decoration", "prop", "effect", "particle"
}

local function horizontalUnit(vector)
    if typeof(vector) ~= "Vector3" then return nil end
    local horizontal = Vector3.new(vector.X, 0, vector.Z)
    if horizontal.Magnitude < 0.001 then return nil end
    return horizontal.Unit
end

local function modelSize(instance)
    if not instance then return Vector3.zero end
    if instance:IsA("BasePart") then return instance.Size end
    if instance:IsA("Model") then
        local ok, size = pcall(function() return instance:GetExtentsSize() end)
        if ok and typeof(size) == "Vector3" then return size end
    end
    return Vector3.zero
end

local function candidateFacingPart(candidate)
    if not candidate then return nil end
    if candidate:IsA("BasePart") then return candidate end
    if not candidate:IsA("Model") then return nil end
    local part = candidate:FindFirstChild("Head", true)
        or candidate:FindFirstChild("head", true)
        or candidate:FindFirstChild("Face", true)
        or candidate.PrimaryPart
        or candidate:FindFirstChildWhichIsA("BasePart", true)
    return part and part:IsA("BasePart") and part or nil
end

local function updateSentinelRotation(part)
    if not part or not part.Parent then return 0 end
    Runtime._RLGLSentinelRotation = Runtime._RLGLSentinelRotation or setmetatable({}, {__mode = "k"})
    local history = Runtime._RLGLSentinelRotation[part]
    local look = horizontalUnit(part.CFrame.LookVector)
    if not look then return 0 end
    local now = os.clock()
    if not history then
        history = {Look = look, Time = now, Turns = 0, LastTurnAt = 0}
        Runtime._RLGLSentinelRotation[part] = history
        return 0
    end
    local dot = math.clamp(history.Look:Dot(look), -1, 1)
    if dot <= 0.45 and now - (history.LastTurnAt or 0) >= 0.35 then
        history.Turns = (history.Turns or 0) + 1
        history.LastTurnAt = now
    end
    history.Look = look
    history.Time = now
    return history.Turns or 0
end

local function findActiveRLGLDoll()
    local now = os.clock()
    local cached = Runtime._RLGLDollCache
    if cached and now - cached.Time < 0.45 and cached.Instance and cached.Instance.Parent then
        updateSentinelRotation(cached.Part)
        return cached.Instance, cached.Part, cached.Source
    end

    local _, character, _, root = getCharacter()
    local origin = root and root.Position
    local seen = setmetatable({}, {__mode = "k"})
    local best, bestPart, bestScore, bestSource = nil, nil, -math.huge, nil

    local function consider(instance)
        if not instance or not instance.Parent then return end
        local candidate = instance:IsA("Model") and instance or instance:FindFirstAncestorOfClass("Model") or instance
        if not candidate or seen[candidate] or (character and candidate == character) then return end
        seen[candidate] = true

        local text = instanceText(candidate) .. " " .. instanceText(instance)
        local named = containsAny(text, RLGL_DOLL_TOKENS)
        if not named and containsAny(candidate.Name, RLGL_GENERIC_MODEL_EXCLUDES) then return end

        local position = getPosition(candidate)
        local part = candidateFacingPart(candidate)
        if not position or not part then return end
        local distance = origin and (position - origin).Magnitude or 0
        if origin and (distance < 20 or distance > 1200) then return end

        local size = modelSize(candidate)
        local score = 0
        if named then
            score = score + 120
            if containsAny(text, {"younghee", "young hee", "yeonghee", "mugunghwa"}) then score = score + 45 end
        else
            if size.Y < 4 or size.Y > 90 then return end
            if candidate:IsA("Model") and candidate:FindFirstChildOfClass("Humanoid") then return end
            if candidate:IsA("Model") and candidate:FindFirstChildWhichIsA("AnimationController", true) then score = score + 34 end
            if candidate:IsA("Model") and candidate:FindFirstChild("Head", true) then score = score + 24 end
            if candidate:IsA("Model") and candidate:FindFirstChildWhichIsA("Motor6D", true) then score = score + 20 end
            score = score + math.min(size.Y, 35)
        end

        local turns = updateSentinelRotation(part)
        if turns > 0 then score = score + 85 + math.min(turns, 4) * 12 end
        if origin and distance >= 45 and distance <= 900 then score = score + 18 end
        if part:FindFirstChildWhichIsA("Decal") then score = score + 8 end

        local source = named and "named RLGL doll" or (turns > 0 and "rotating arena sentinel" or "generic arena sentinel")
        local minimum = named and 80 or 78
        if score >= minimum and score > bestScore then
            best, bestPart, bestScore, bestSource = candidate, part, score, source
        end
    end

    forEachIndexed("Workspace", {"Model"}, function(instance)
        consider(instance)
        return true
    end)

    -- Some experiences build the doll from loose parts rather than a named model.
    if not best then
        forEachIndexed("Workspace", {"BasePart"}, function(instance)
            if containsAny(instanceText(instance), RLGL_DOLL_TOKENS) then consider(instance) end
            return true
        end)
    end

    Runtime._RLGLDollCache = {
        Time = now,
        Instance = best,
        Part = bestPart,
        Score = bestScore,
        Source = bestSource,
    }
    return best, bestPart, bestSource
end

local function faceNormal(part)
    if not part or not part:IsA("BasePart") then return nil end
    local decal = part:FindFirstChildWhichIsA("Decal")
    local face = decal and decal.Face
    if face == Enum.NormalId.Back then return -part.CFrame.LookVector end
    if face == Enum.NormalId.Right then return part.CFrame.RightVector end
    if face == Enum.NormalId.Left then return -part.CFrame.RightVector end
    if face == Enum.NormalId.Top then return part.CFrame.UpVector end
    if face == Enum.NormalId.Bottom then return -part.CFrame.UpVector end
    return part.CFrame.LookVector
end

local function crowdMovementEvidence()
    local now = os.clock()
    local cached = Runtime._RLGLCrowdCache
    if cached and now - cached.Time < 0.12 then
        return cached.State, cached.Weight, nil, cached.Source, cached.Ratio, cached.Total
    end
    local player, _, _, root = getCharacter()
    if not player or not root then return nil end

    local total, moving = 0, 0
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local character = other.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local otherRoot = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and otherRoot and (otherRoot.Position - root.Position).Magnitude <= 420 then
                total = total + 1
                local velocity = Vector3.new(otherRoot.AssemblyLinearVelocity.X, 0, otherRoot.AssemblyLinearVelocity.Z).Magnitude
                if velocity >= 1.65 or humanoid.MoveDirection.Magnitude >= 0.16 then moving = moving + 1 end
            end
        end
    end

    if total < 2 then
        Runtime._RLGLCrowdCache = {Time = now, State = nil, Weight = 0, Ratio = 0, Total = total}
        return nil, 0, nil, "not enough nearby players", 0, total
    end

    local ratio = moving / total
    local state, weight, source
    if moving >= 2 and ratio >= 0.20 then
        Runtime._RLGLCrowdMotionSeenAt = now
        state, weight, source = "Green", 10, string.format("crowd moving (%d/%d)", moving, total)
    elseif ratio <= 0.08 and Runtime._RLGLCrowdMotionSeenAt and now - Runtime._RLGLCrowdMotionSeenAt <= 8.0 then
        state, weight, source = "Red", 10, string.format("crowd stopped (%d tracked)", total)
    end

    Runtime._RLGLCrowdCache = {
        Time = now,
        State = state,
        Weight = weight or 0,
        Source = source,
        Ratio = ratio,
        Total = total,
    }
    return state, weight or 0, nil, source, ratio, total
end

local function soundPlaying(sound)
    if not sound or not sound.Parent then return false end
    if sound:IsA("Sound") then
        local ok, playing = pcall(function() return sound.Playing end)
        local okVolume, volume = pcall(function() return sound.Volume end)
        return ok and playing == true and (not okVolume or volume > 0.001)
    end
    local ok, playing = pcall(function() return sound.IsPlaying end)
    return ok and playing == true
end

local function soundSignature(sound)
    local id = ""
    pcall(function()
        id = tostring(sound.SoundId or sound.Asset or "")
    end)
    local parent = sound.Parent
    return table.concat({id, sound.Name, parent and parent.Name or "", parent and parent.ClassName or ""}, "|")
end

local function soundDuration(sound)
    local value = 0
    pcall(function() value = tonumber(sound.TimeLength) or 0 end)
    return value
end

local function collectRLGLAudioInstances()
    local now = os.clock()
    local cached = Runtime._RLGLAudioInstances
    if cached and now - cached.Time < 0.8 then return cached.Items end

    local items, seen = {}, setmetatable({}, {__mode = "k"})
    local function add(instance)
        if not instance or not instance.Parent or seen[instance] then return end
        local isSound = instance:IsA("Sound")
        local isAudio = false
        if not isSound then pcall(function() isAudio = instance:IsA("AudioPlayer") end) end
        if not isSound and not isAudio then return end
        seen[instance] = true
        table.insert(items, instance)
    end

    forEachIndexed("Workspace", {"Sound"}, function(instance) add(instance) return true end)
    forEachIndexed("Gui", {"Sound"}, function(instance) add(instance) return true end)
    for _, instance in ipairs(SoundService:GetDescendants()) do add(instance) end

    Runtime._RLGLAudioInstances = {Time = now, Items = items}
    return items
end

local function adaptiveAudioEvidence(crowdState)
    Runtime._RLGLAudioHistory = Runtime._RLGLAudioHistory or {}
    local now = os.clock()
    local bestRecord, bestInstance, bestScore = nil, nil, -math.huge

    for _, instance in ipairs(collectRLGLAudioInstances()) do
        local context = instanceText(instance)
        if not containsAny(context, RLGL_AMBIENT_SOUND_EXCLUDES) then
            local duration = soundDuration(instance)
            local looped = false
            pcall(function() looped = instance.Looped == true or instance.Looping == true end)
            if not looped or duration <= 14 or duration == 0 then
                local signature = soundSignature(instance)
                local record = Runtime._RLGLAudioHistory[signature]
                if not record then
                    record = {
                        LastPlaying = false,
                        SeenPlaying = false,
                        SeenStopped = false,
                        ToggleCount = 0,
                        LastChangeAt = now,
                        LastPlayedAt = 0,
                        GreenCorrelation = 0,
                        RedCorrelation = 0,
                    }
                    Runtime._RLGLAudioHistory[signature] = record
                end

                local playing = soundPlaying(instance)
                if playing ~= record.LastPlaying then
                    if record.SeenPlaying or playing then record.ToggleCount = record.ToggleCount + 1 end
                    record.LastChangeAt = now
                    record.LastPlaying = playing
                    if not playing and record.SeenPlaying then record.SeenStopped = true end
                end
                if playing then
                    record.SeenPlaying = true
                    record.LastPlayedAt = now
                end
                record.LastSeenAt = now
                record.Instance = instance
                record.Duration = duration

                if crowdState == "Green" and playing then
                    record.GreenCorrelation = math.min((record.GreenCorrelation or 0) + 0.18, 12)
                elseif crowdState == "Red" and not playing and record.SeenPlaying then
                    record.RedCorrelation = math.min((record.RedCorrelation or 0) + 0.18, 12)
                end

                local score = 0
                if containsAny(context, RLGL_CONTEXT) then score = score + 18 end
                score = score + math.min(record.ToggleCount, 5) * 5
                score = score + (record.SeenStopped and 5 or 0)
                score = score + (record.GreenCorrelation or 0) + (record.RedCorrelation or 0)
                if duration >= 0.65 and duration <= 12 then score = score + 7 end
                if not looped then score = score + 3 end
                local position = getPosition(instance.Parent)
                local _, _, _, root = getCharacter()
                if position and root then
                    local distance = (position - root.Position).Magnitude
                    if distance >= 25 and distance <= 1000 then score = score + 4 end
                end

                -- A first-cycle short spatial sound is allowed to bootstrap the
                -- detector even before it has completed a full play/stop cycle.
                if playing and duration >= 0.65 and duration <= 12 then score = score + 4 end

                if score > bestScore then
                    bestRecord, bestInstance, bestScore = record, instance, score
                end
            end
        end
    end

    -- Keep a recently destroyed/recreated chant signature useful for the red
    -- transition. Some games clone the sound each time instead of reusing it.
    for _, record in pairs(Runtime._RLGLAudioHistory) do
        if record.SeenPlaying and record.LastSeenAt and now - record.LastSeenAt <= 4.0 then
            local score = math.min(record.ToggleCount or 0, 5) * 5
                + (record.SeenStopped and 5 or 0)
                + (record.GreenCorrelation or 0) + (record.RedCorrelation or 0)
            if score > bestScore then
                bestRecord, bestInstance, bestScore = record, record.Instance, score
            end
        end
    end

    if not bestRecord or bestScore < 7 then return nil end
    if bestRecord.LastPlaying then
        return "Green", math.clamp(math.floor(bestScore), 8, 16), bestInstance,
            string.format("adaptive chant audio (score %d)", math.floor(bestScore))
    end
    if bestRecord.SeenPlaying and now - (bestRecord.LastPlayedAt or 0) <= 12 then
        return "Red", math.clamp(math.floor(bestScore), 9, 17), bestInstance,
            string.format("chant audio stopped (score %d)", math.floor(bestScore))
    end
    return nil
end

local function adaptiveDollFacingEvidence(calibrationState)
    local _, _, _, root = getCharacter()
    if not root then return nil end
    local doll, part, dollSource = findActiveRLGLDoll()
    if not doll or not part then return nil end

    local front = horizontalUnit(faceNormal(part))
    if not front then return nil end
    local now = os.clock()
    Runtime._RLGLFacingCalibration = Runtime._RLGLFacingCalibration or {}
    local calibration = Runtime._RLGLFacingCalibration

    if calibrationState == "Green" then
        calibration.Green = front
        calibration.GreenAt = now
    elseif calibrationState == "Red" then
        calibration.Red = front
        calibration.RedAt = now
    end

    if calibration.Green then
        local greenDot = front:Dot(calibration.Green)
        local redDot = calibration.Red and front:Dot(calibration.Red) or -greenDot
        if greenDot >= 0.82 and greenDot > redDot + 0.18 then
            return "Green", 13, doll, (dollSource or "doll") .. " learned green orientation"
        end
    end
    if calibration.Red then
        local redDot = front:Dot(calibration.Red)
        local greenDot = calibration.Green and front:Dot(calibration.Green) or -redDot
        if redDot >= 0.82 and redDot > greenDot + 0.18 then
            return "Red", 14, doll, (dollSource or "doll") .. " learned red orientation"
        end
    end

    -- Named dolls can use a conservative geometric fallback before calibration.
    if dollSource == "named RLGL doll" then
        local toPlayer = horizontalUnit(root.Position - part.Position)
        if toPlayer then
            local dot = front:Dot(toPlayer)
            if dot >= 0.35 then
                return "Red", 9, doll, string.format("named doll facing field (%.2f)", dot)
            elseif dot <= -0.28 then
                return "Green", 8, doll, string.format("named doll facing away (%.2f)", dot)
            end
        end
    end
    return nil
end

local function discoverRLGLSignals()
    local candidates = {}
    local stateNames = {"light", "signal", "traffic", "doll", "red", "green", "canmove", "moveallowed"}

    forEachIndexed("Workspace", {"ValueBase"}, function(instance)
        local context = instanceText(instance)
        if containsAny(context, RLGL_CONTEXT)
            or (containsAny(instance.Name, stateNames) and contextualStatusWord(instance.Value, context))
        then
            table.insert(candidates, instance)
        end
        return true
    end)
    forEachIndexed("ReplicatedStorage", {"ValueBase"}, function(instance)
        local context = instanceText(instance)
        if containsAny(context, RLGL_CONTEXT) then table.insert(candidates, instance) end
        return true
    end)

    Runtime._RLGLColorHistory = Runtime._RLGLColorHistory or setmetatable({}, {__mode = "k"})
    forEachIndexed("Gui", {"TextLabel", "TextButton", "Frame", "ImageLabel", "ImageButton"}, function(instance)
        if isSquidNoMoGui(instance) or not isVisibleGui(instance) then return true end
        local context = instanceText(instance)
        local rawText = (instance:IsA("TextLabel") or instance:IsA("TextButton")) and instance.Text or ""
        local colorState
        pcall(function() colorState = rlglColorState(instance.BackgroundColor3) end)
        if not colorState and (instance:IsA("ImageLabel") or instance:IsA("ImageButton")) then
            pcall(function() colorState = rlglColorState(instance.ImageColor3) end)
        end
        if colorState then
            local history = Runtime._RLGLColorHistory[instance] or {SeenRed = false, SeenGreen = false}
            history.SeenRed = history.SeenRed or colorState == "Red"
            history.SeenGreen = history.SeenGreen or colorState == "Green"
            history.State = colorState
            history.Time = os.clock()
            Runtime._RLGLColorHistory[instance] = history
        end
        local history = Runtime._RLGLColorHistory[instance]
        local flippedColorSignal = history and history.SeenRed and history.SeenGreen
        if containsAny(context, RLGL_CONTEXT)
            or (containsAny(context, {"light", "signal", "doll", "move"}) and statusWord(rawText))
            or flippedColorSignal
        then
            table.insert(candidates, instance)
        end
        return true
    end)

    Runtime._RLGLSignalCandidates = candidates
    Runtime._RLGLSignalsScannedAt = os.clock()
    return candidates
end

local function addRLGLScore(result, state, weight, instance, source)
    if not state or not weight or weight <= 0 then return end
    result.Scores[state] = result.Scores[state] + weight
    table.insert(result.Evidence, {State = state, Weight = weight, Instance = instance, Source = source})
    if weight > result.BestWeight[state] then
        result.BestWeight[state] = weight
        result.BestInstance[state] = instance
        result.BestSource[state] = source
    end
end

local function findStatusText()
    local now = os.clock()
    local cached = Runtime._StatusTextCache
    if cached and now - cached.Time < 0.07 then
        return cached.Value, cached.Instance, cached.Detail
    end

    local result = {
        Scores = {Red = 0, Green = 0},
        BestInstance = {Red = nil, Green = nil},
        BestWeight = {Red = 0, Green = 0},
        BestSource = {Red = nil, Green = nil},
        Evidence = {},
    }
    local candidates = Runtime._RLGLSignalCandidates
    if not candidates or now - (Runtime._RLGLSignalsScannedAt or 0) > 0.65 then
        candidates = discoverRLGLSignals()
    end

    local liveCount = 0
    for _, instance in ipairs(candidates) do
        if instance and instance.Parent then
            liveCount = liveCount + 1
            local state, weight, source
            if instance:IsA("ValueBase") then
                local context = instanceText(instance)
                state = contextualStatusWord(instance.Value, context)
                weight = state and (containsAny(context, RLGL_CONTEXT) and 15 or 9) or 0
                source = "live value: " .. tostring(instance.Name)
                if instance:IsA("BoolValue") then
                    local name = lower(instance.Name)
                    if string.find(name, "red", 1, true) then
                        state, weight = instance.Value and "Red" or "Green", 15
                    elseif string.find(name, "green", 1, true) or string.find(name, "canmove", 1, true) then
                        state, weight = instance.Value and "Green" or "Red", 15
                    end
                end
            elseif isVisibleGui(instance) then
                local rawText = (instance:IsA("TextLabel") or instance:IsA("TextButton")) and instance.Text or ""
                local context = instanceText(instance)
                state = contextualStatusWord(rawText, context)
                weight = state and 13 or 0
                source = state and "visible HUD text" or nil
                local history = Runtime._RLGLColorHistory and Runtime._RLGLColorHistory[instance]
                local colorAllowed = containsAny(context, {"light", "signal", "doll", "rlgl", "move"})
                    or (history and history.SeenRed and history.SeenGreen)
                if not state and colorAllowed then
                    local okText, textColor = pcall(function() return instance.TextColor3 end)
                    local okBackground, backgroundColor = pcall(function() return instance.BackgroundColor3 end)
                    local okImage, imageColor = pcall(function() return instance.ImageColor3 end)
                    state = (okText and rlglColorState(textColor))
                        or (okBackground and rlglColorState(backgroundColor))
                        or (okImage and rlglColorState(imageColor))
                    weight = state and (history and history.SeenRed and history.SeenGreen and 11 or 7) or 0
                    source = state and "switching HUD color" or nil
                end
            end
            addRLGLScore(result, state, weight, instance, source)
        end
    end

    local crowdState, crowdWeight, crowdInstance, crowdSource, crowdRatio, crowdTotal = crowdMovementEvidence()
    local audioState, audioWeight, audioInstance, audioSource = adaptiveAudioEvidence(crowdState)
    local calibrationState = audioState or crowdState
    local facingState, facingWeight, facingInstance, facingSource = adaptiveDollFacingEvidence(calibrationState)

    addRLGLScore(result, crowdState, crowdWeight, crowdInstance, crowdSource)
    addRLGLScore(result, audioState, audioWeight, audioInstance, audioSource)
    addRLGLScore(result, facingState, facingWeight, facingInstance, facingSource)

    if liveCount == 0 or now - (Runtime._RLGLSignalsScannedAt or 0) > 0.45 then
        Runtime._RLGLSignalCandidates = nil
    end

    local value, selectedInstance, selectedSource
    local red, green = result.Scores.Red, result.Scores.Green
    local margin = math.abs(red - green)
    if red >= 7 and red >= green and (margin >= 1 or result.BestWeight.Red >= 13) then
        value, selectedInstance, selectedSource = "Red", result.BestInstance.Red, result.BestSource.Red
    elseif green >= 7 and green > red and (margin >= 1 or result.BestWeight.Green >= 13) then
        value, selectedInstance, selectedSource = "Green", result.BestInstance.Green, result.BestSource.Green
    end

    -- Never remain permanently uncertain during an active RLGL round. Until a
    -- reliable green cue is learned, the safe fallback is Red. This makes the
    -- feature deterministic while the adaptive audio/sentinel learner observes
    -- its first real play/stop cycle.
    if not value then
        value = "Red"
        selectedSource = "safe stop while learning chant/doll signal"
        selectedInstance = result.BestInstance.Red or result.BestInstance.Green
        result.Scores.Red = math.max(result.Scores.Red, 1)
    end

    local doll, _, dollSource = findActiveRLGLDoll()
    local detail = {
        State = value,
        Source = selectedSource,
        RedScore = result.Scores.Red,
        GreenScore = result.Scores.Green,
        Doll = doll,
        DollSource = dollSource,
        CrowdRatio = crowdRatio or 0,
        CrowdTotal = crowdTotal or 0,
        AudioSource = audioSource,
    }
    Runtime._StatusTextCache = {Time = now, Value = value, Instance = selectedInstance, Detail = detail}
    return value, selectedInstance, detail
end

function Runtime:GetRLGLStateDetail()
    local candidate, instance, detail = findStatusText()
    local now = os.clock()
    if candidate ~= self._RLGLCandidate then
        self._RLGLCandidate = candidate
        self._RLGLCandidateAt = now
    end

    -- Red is applied immediately. Green is confirmed briefly to avoid moving
    -- during the turn animation. A missing cue falls back to Red in findStatusText.
    local required = candidate == "Red" and 0.01 or 0.10
    if candidate and now - (self._RLGLCandidateAt or now) >= required then
        self._RLGLStableState = candidate
        self._RLGLStableDetail = detail
        self._RLGLStableAt = now
    end

    local stableDetail = self._RLGLStableDetail or detail or {}
    stableDetail.Instance = instance
    stableDetail.State = self._RLGLStableState or "Red"
    if not self._RLGLStableState then
        self._RLGLStableState = "Red"
        self._RLGLStableDetail = detail
        self._RLGLStableAt = now
    end
    return self._RLGLStableState, stableDetail
end

function Runtime:GetRLGLState()
    local state = self:GetRLGLStateDetail()
    return state
end

function Runtime:GetRLGLDoll()
    return findActiveRLGLDoll()
end

local function startRLGLAutoMove(feature)
    feature.Config.MovementPriority = feature.Config.MovementPriority or 95
    feature:_Loop(feature.Config.Interval or 0.10, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        local state = Runtime:GetRLGLState()
        if state ~= "Green" then
            Runtime:StopMovement(self, state == "Red")
            if state == "Red" then return false, "Red light detected — fully stopped" end
            return false, "Waiting for an unambiguous red/green signal"
        end

        local target = Runtime:FindNearest({
            Scope = "Workspace",
            TargetTokens = self.Config.TargetTokens or {"finish", "end zone", "safe zone", "goal"},
            ExcludeTokens = {"start", "spawn"},
            TargetClasses = {"BasePart", "Model"},
            ReturnAdornee = true,
            MaxTargets = 40,
            CacheTTL = 2.0,
        }, root.Position)
        if not target then
            target = Runtime:FindNearest({
                Scope = "Workspace",
                TargetTokens = {"doll", "younghee", "young hee", "mugunghwa"},
                TargetClasses = {"Model", "BasePart"},
                ReturnAdornee = true,
                MaxTargets = 20,
                CacheTTL = 2.0,
            }, root.Position)
        end
        local position = getPosition(target)
        if not position then
            Runtime:StopMovement(self)
            return false, "Green light detected; waiting for the finish area"
        end

        local moved, detail = Runtime:MoveTo(position, self, {
            StopDistance = 8,
            Direct = true,
            MovementPriority = 95,
            CommandInterval = 0.65,
            LeaseDuration = 0.9,
        })
        return moved, moved and "Green light detected — moving at normal character speed" or detail
    end)
end

local function closestPointOnPart(part, worldPosition)
    if not part or not part:IsA("BasePart") then return nil end
    local localPoint = part.CFrame:PointToObjectSpace(worldPosition)
    local half = part.Size * 0.5
    local clamped = Vector3.new(
        math.clamp(localPoint.X, -half.X, half.X),
        math.clamp(localPoint.Y, -half.Y, half.Y),
        math.clamp(localPoint.Z, -half.Z, half.Z)
    )
    return part.CFrame:PointToWorldSpace(clamped)
end

local RopeGeometryHistory = setmetatable({}, {__mode = "k"})

local function findGeometricRope(root)
    if not root then return nil end
    local now = os.clock()
    local cached = Runtime._RopeGeometryCache
    if cached and now - cached.Time < 0.12 and cached.Target and cached.Target.Parent then
        return cached.Target
    end

    local best, bestScore = nil, -math.huge
    local scanned = 0
    forEachIndexed("Workspace", {"BasePart"}, function(part)
        if scanned >= 520 then return false end
        scanned = scanned + 1
        if not part.Parent or part:IsDescendantOf(root.Parent) then return true end

        local offset = part.Position - root.Position
        local distance = offset.Magnitude
        if distance > 120 or math.abs(offset.Y) > 36 then return true end

        local size = part.Size
        local longest = math.max(size.X, size.Y, size.Z)
        local shortest = math.min(size.X, size.Y, size.Z)
        local middle = size.X + size.Y + size.Z - longest - shortest
        if longest < 8 or shortest > 5.5 or middle > math.max(8, longest * 0.55) then return true end

        local history = RopeGeometryHistory[part]
        local elapsed = history and math.max(now - history.Time, 0.001) or 0
        local positionalSpeed = 0
        local rotationalSpeed = 0
        if history and elapsed <= 2.0 then
            positionalSpeed = (part.Position - history.Position).Magnitude / elapsed
            local lookDelta = 1 - math.abs(math.clamp(part.CFrame.LookVector:Dot(history.LookVector), -1, 1))
            local upDelta = 1 - math.abs(math.clamp(part.CFrame.UpVector:Dot(history.UpVector), -1, 1))
            rotationalSpeed = math.max(lookDelta, upDelta) * longest / elapsed
        end
        RopeGeometryHistory[part] = {
            Time = now,
            Position = part.Position,
            LookVector = part.CFrame.LookVector,
            UpVector = part.CFrame.UpVector,
        }

        local physicsSpeed = part.AssemblyLinearVelocity.Magnitude
            + part.AssemblyAngularVelocity.Magnitude * math.min(longest, 40)
        local motion = math.max(physicsSpeed, positionalSpeed, rotationalSpeed)
        if motion < 0.35 then return true end

        local score = motion * 2.4 + math.min(longest, 45) - distance * 0.10 - math.abs(offset.Y) * 0.25
        if containsAny(instanceText(part), {"rope", "bar", "swing", "spinner"}) then score = score + 35 end
        if score > bestScore then
            best, bestScore = part, score
        end
        return true
    end)
    Runtime._RopeGeometryCache = {Time = now, Target = best}
    return best
end

function Runtime:ObserveRope(feature, root, tokens)
    if not root then return nil end
    local target = self:FindNearest({
        Scope = "Workspace",
        TargetTokens = tokens or {"rope", "bar", "swing", "spinner", "sweep"},
        TargetClasses = {"BasePart"},
        MaxTargets = 100,
        CacheTTL = 0.08,
    }, root.Position)
    if not target then
        -- Current Jump Rope builds can use generic part names. Fall back to the
        -- long, slender moving obstacle the player can actually see instead of
        -- depending only on a guessed internal object name.
        target = findGeometricRope(root)
    end
    if not target then return nil end

    local point = closestPointOnPart(target, root.Position) or target.Position
    local distance = (point - root.Position).Magnitude
    local now = os.clock()
    local previous = feature._RopeObservation
    local approaching, speed = false, 0
    if previous and previous.Target == target then
        local elapsed = math.max(now - previous.Time, 0.001)
        speed = (point - previous.Point).Magnitude / elapsed
        approaching = distance < previous.Distance - 0.06
    end
    local observation = {
        Target = target,
        Point = point,
        Distance = distance,
        Vertical = point.Y - root.Position.Y,
        Approaching = approaching,
        Speed = speed,
        Time = now,
    }
    feature._RopeObservation = observation
    return observation
end

local function startAutoJump(feature)
    feature.LastJumpAt = 0
    feature:_Loop(feature.Config.Interval or 0.045, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        local observation = Runtime:ObserveRope(self, root, self.Config.TargetTokens or {"rope", "bar", "swing", "spinner", "sweep"})
        if not observation then return false, "Waiting for the moving rope" end

        local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
        local trigger = self.Config.TriggerDistance or 17
        local closeEnough = observation.Distance <= trigger and math.abs(observation.Vertical) <= 10
        local emergency = observation.Distance <= math.max(4.5, trigger * 0.32)
        local cooldownReady = os.clock() - (self.LastJumpAt or 0) >= (self.Config.JumpCooldown or 0.62)

        if grounded and cooldownReady and closeEnough and (observation.Approaching or emergency) then
            humanoid.Jump = true
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            self.LastJumpAt = os.clock()
            return true, string.format("Jumped as rope approached (%.1f studs)", observation.Distance)
        end
        if closeEnough then
            return true, observation.Approaching and "Rope approaching — preparing jump" or "Rope nearby — waiting for its next approach"
        end
        return false, string.format("Tracking rope (%.1f studs away)", observation.Distance)
    end)
end

local function startEvasion(feature)
    feature:_Loop(feature.Config.Interval or 0.2, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        local movementAvailable, movementOwner = Runtime:CanUseMovement(self, self.Config.MovementPriority or 70)
        if not movementAvailable then return false, "Movement is currently controlled by " .. tostring(movementOwner) end
        local target, distance = nearestCharacter(self.Config, root.Position)
        if not target or distance > (self.Config.Range or 20) then return false, "No nearby threat detected" end
        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return false, "Threat has no root part" end
        local direction = root.Position - targetRoot.Position
        if direction.Magnitude < 0.1 then direction = root.CFrame.RightVector end
        local moved, detail = Runtime:MoveTo(
            root.Position + direction.Unit * (self.Config.EvadeDistance or 18),
            self,
            {Direct = true, StopDistance = 3, MovementPriority = self.Config.MovementPriority or 70, CommandInterval = 0.35}
        )
        return moved, moved and ("Moving away from " .. target.Name) or detail
    end)
end

local function startBoundary(feature)
    feature:_Loop(feature.Config.Interval or 0.35, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        local movementAvailable, movementOwner = Runtime:CanUseMovement(self, self.Config.MovementPriority or 65)
        if not movementAvailable then return false, "Movement is currently controlled by " .. tostring(movementOwner) end
        local zone = Runtime:FindNearest({
            Scope = "Workspace",
            TargetNames = self.Config.TargetNames,
            TargetTokens = self.Config.TargetTokens,
            TargetClasses = {"BasePart", "Model"},
            ReturnAdornee = true,
        }, root.Position)
        local position = getPosition(zone)
        if not zone or not position then return false, self.Config.WaitingMessage end
        local radius = self.Config.Radius or 60
        if zone:IsA("BasePart") then radius = math.max(zone.Size.X, zone.Size.Z) * 0.45 end
        if (root.Position - position).Magnitude > radius then
            local moved, detail = Runtime:MoveTo(position, self, {
                Direct = true,
                StopDistance = math.max(6, radius * 0.35),
                MovementPriority = self.Config.MovementPriority or 65,
                CommandInterval = 0.5,
            })
            return moved, moved and "Returning to the active play area" or detail
        end
        return true, "Inside the active play area"
    end)
end

local function parseRequiredCount()
    return Runtime:GetMingleRequiredCount()
end

local function treeContainsNumber(target, number)
    local wanted = tostring(number)
    if string.find(instanceText(target), wanted, 1, true) then return true end
    local scanned = 0
    for _, child in ipairs(target:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ValueBase") or child:IsA("ProximityPrompt") then
            if string.find(instanceText(child), wanted, 1, true) then return true end
            scanned = scanned + 1
            if scanned >= 50 then break end
        end
    end
    return false
end

local function roomOccupancy(target)
    for _, valueName in ipairs({"Occupants", "Occupancy", "PlayerCount", "PlayersInside", "Count"}) do
        local value = target:FindFirstChild(valueName, true)
        if value and value:IsA("ValueBase") then
            local number = tonumber(value.Value)
            if number then return number end
        end
    end

    local center, size
    if target:IsA("Model") then
        local ok, cframe, bounds = pcall(target.GetBoundingBox, target)
        if ok then center, size = cframe, bounds end
    elseif target:IsA("BasePart") then
        center, size = target.CFrame, target.Size
    else
        local adornee = getAdornee(target)
        if adornee and adornee:IsA("Model") then
            local ok, cframe, bounds = pcall(adornee.GetBoundingBox, adornee)
            if ok then center, size = cframe, bounds end
        elseif adornee and adornee:IsA("BasePart") then
            center, size = adornee.CFrame, adornee.Size
        end
    end
    if not center or not size then return nil end

    local count = 0
    for _, other in ipairs(Players:GetPlayers()) do
        local otherRoot = other.Character and other.Character:FindFirstChild("HumanoidRootPart")
        if otherRoot then
            local point = center:PointToObjectSpace(otherRoot.Position)
            if math.abs(point.X) <= size.X * 0.6
                and math.abs(point.Y) <= math.max(size.Y * 0.7, 8)
                and math.abs(point.Z) <= size.Z * 0.6
            then
                count = count + 1
            end
        end
    end
    return count
end

local function startRoomAssist(feature)
    feature:_Loop(feature.Config.Interval or 0.32, function(self)
        local phase = Runtime:GetMinglePhase()
        if phase == "Carousel" then return false, "Waiting for the Mingle room number" end
        if phase == "Locked" then
            Runtime:StopMovement(self)
            return true, "Room is locked — holding position"
        end
        local count = parseRequiredCount()
        if not count then return false, "Waiting for the visible Mingle room count" end
        local _, _, _, root = getCharacter()
        if not root then return false, "Waiting for the local character" end
        local movementAvailable, movementOwner = Runtime:CanUseMovement(self, self.Config.MovementPriority or 60)
        if not movementAvailable then return false, "Movement is currently controlled by " .. tostring(movementOwner) end

        local candidates = Runtime:FindTargets({
            Scope = "Workspace",
            TargetTokens = {"room", "door", "mingle", "capacity", "enter", "join", "open"},
            TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
            MaxTargets = 220,
            CacheTTL = 0.28,
        })
        local best, bestScore, bestOccupancy = nil, -math.huge, nil
        for _, target in ipairs(candidates) do
            local capacity = target:FindFirstChild("Capacity", true)
            local capacityNumber = capacity and capacity:IsA("ValueBase") and tonumber(capacity.Value) or nil
            local capacityMatch = capacityNumber == count or treeContainsNumber(target, count)
            local position = getPosition(target)
            if capacityMatch and position then
                local occupancy = roomOccupancy(target)
                local hasSpace = occupancy == nil or occupancy < count
                if hasSpace then
                    local distance = (position - root.Position).Magnitude
                    -- Prefer a partly filled matching room, then the nearest one.
                    local fillBonus = occupancy and occupancy * 18 or 0
                    local score = fillBonus - distance
                    if score > bestScore then
                        best, bestScore, bestOccupancy = target, score, occupancy
                    end
                end
            end
        end
        if not best then return false, "No open room matching " .. count .. " players was detected" end

        local position = getPosition(best)
        local moved, detail = Runtime:MoveTo(position, self, {
            StopDistance = 6,
            MaxWaypoints = 4,
            MovementPriority = self.Config.MovementPriority or 60,
            HoldLeaseAtTarget = 0.75,
            RepathInterval = 0.65,
        })
        local _, _, _, currentRoot = getCharacter()
        if self.Config.Interact and currentRoot and (currentRoot.Position - position).Magnitude <= 10 then
            Runtime:Interact(best, self, {Priority = self.Config.ActionPriority or 60, Duration = self.Config.ActionCooldown or 0.6})
        end
        local occupancyText = bestOccupancy ~= nil and ("; " .. bestOccupancy .. "/" .. count .. " inside") or ""
        return moved, moved and ("Heading to a " .. count .. "-player room" .. occupancyText) or detail
    end)
end

local function startAimActivate(feature)
    feature:_Loop(feature.Config.Interval or 0.12, function(self)
        local _, _, _, root = getCharacter()
        if not root then return false, "Waiting for the local character" end
        local target, distance = Runtime:FindNearest({
            Scope = self.Config.Scope or "Workspace",
            TargetTokens = self.Config.TargetTokens,
            TargetNames = self.Config.TargetNames,
            ExcludeTokens = self.Config.ExcludeTokens,
            TargetClasses = {"Model", "BasePart"},
            ReturnAdornee = true,
        }, root.Position)
        local position = getPosition(target)
        if not position or distance > (self.Config.Range or 100) then return false, self.Config.WaitingMessage end
        local camera = Workspace.CurrentCamera
        if camera then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, position) end
        local ok, detail = Runtime:ActivateTool(self.Config.ToolTokens or {}, self, {
            Resource = "AimAction",
            Priority = self.Config.ActionPriority or 65,
            Duration = math.max(self.Config.Interval or 0.12, 0.25),
        })
        return ok, ok and ("Aimed at " .. target.Name .. " and activated the tool") or detail
    end)
end

local function startDisguise(feature)
    feature:_Loop(feature.Config.Interval or 0.5, function(self)
        local player, character, _, root = getCharacter()
        if not player or not character or not root then return false, "Waiting for the local character" end

        local detective = Runtime:GetDetectiveState()
        local detectionHigh = detective.Detection and detective.Detection >= (self.Config.DetectionThreshold or 0.58)
        local guardNearby = false
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player and other.Character then
                local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
                local roleText = lower((other.Team and other.Team.Name or "") .. " " .. other.Name .. " " .. other.DisplayName)
                if otherRoot and containsAny(roleText, self.Config.PlayerTokens or {"guard", "staff"})
                    and (otherRoot.Position - root.Position).Magnitude <= (self.Config.Range or 35)
                then
                    guardNearby = true
                    break
                end
            end
        end

        if not guardNearby and not detectionHigh then
            return false, detective.Detection
                and ("Detection meter is " .. math.floor(detective.Detection * 100 + 0.5) .. "%")
                or "No nearby guard or high detection warning"
        end

        local tool = Runtime:FindTool(self.Config.ToolTokens or {})
        if tool then
            local ok = Runtime:EquipTool(tool)
            if ok then
                pcall(tool.Activate, tool)
                return true, detectionHigh and "Changed disguise before detection became critical" or "Equipped disguise near a guard"
            end
        end

        local station, distance = Runtime:FindNearest({
            Scope = "Workspace",
            TargetTokens = self.Config.ToolTokens or {"disguise", "uniform", "mask", "guard outfit"},
            TargetClasses = {"ProximityPrompt", "ClickDetector", "Model", "BasePart", "Tool"},
            MaxTargets = 80,
        }, root.Position)
        if station then
            if distance > 11 then
                local moved, detail = Runtime:MoveTo(getPosition(station), self, {
                    StopDistance = 9,
                    MovementPriority = self.Config.MovementPriority or 82,
                    MaxWaypoints = 4,
                })
                return moved, moved and "Moving to a disguise station" or detail
            end
            local ok, detail = Runtime:Interact(station, self, {Priority = 82, Duration = 0.7})
            return ok, ok and "Activated a disguise station" or detail
        end
        return false, "Detection risk found, but no disguise tool or station is available"
    end)
end

local function startRadar(feature)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SquidNoMo_Radar_" .. feature.Id
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999985
    local guiParent = getGuiParent()
    if not guiParent then error("no compatible GUI parent is available") end
    gui.Parent = guiParent
    feature:_TrackInstance(gui)

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -18, 0, 84)
    frame.Size = UDim2.fromOffset(176, 176)
    frame.BackgroundColor3 = Color3.fromRGB(10, 15, 21)
    frame.BackgroundTransparency = 0.12
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = feature.Config.Color or Color3.fromRGB(42, 255, 126)
    stroke.Transparency = 0.2
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = feature.Config.Title or "MAP RADAR"
    title.TextColor3 = Color3.fromRGB(235, 240, 245)
    title.TextSize = 14
    title.Parent = frame

    local field = Instance.new("Frame")
    field.Position = UDim2.fromOffset(10, 32)
    field.Size = UDim2.new(1, -20, 1, -42)
    field.BackgroundColor3 = Color3.fromRGB(15, 23, 30)
    field.BackgroundTransparency = 0.18
    field.BorderSizePixel = 0
    field.ClipsDescendants = true
    field.Parent = frame
    local fieldCorner = Instance.new("UICorner")
    fieldCorner.CornerRadius = UDim.new(0, 12)
    fieldCorner.Parent = field

    local center = Instance.new("Frame")
    center.AnchorPoint = Vector2.new(0.5, 0.5)
    center.Position = UDim2.fromScale(0.5, 0.5)
    center.Size = UDim2.fromOffset(8, 8)
    center.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    center.BorderSizePixel = 0
    center.Parent = field
    local centerCorner = Instance.new("UICorner")
    centerCorner.CornerRadius = UDim.new(1, 0)
    centerCorner.Parent = center

    feature.RadarDots = {}

    local function getDot(self, target, color)
        local dot = self.RadarDots[target]
        if dot and dot.Parent then
            dot.BackgroundColor3 = color
            return dot
        end
        dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Size = UDim2.fromOffset(7, 7)
        dot.BackgroundColor3 = color
        dot.BorderSizePixel = 0
        dot.Parent = field
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        self.RadarDots[target] = dot
        self:_TrackInstance(dot)
        return dot
    end

    feature:_Loop(feature.Config.Interval or 0.16, function(self)
        local _, _, _, root = getCharacter()
        if not root then return false, "Waiting for the local character" end

        local range = feature.Config.Range or 150
        local seen = {}
        local count = 0

        for _, character in ipairs(getOtherCharacterTargets({
            PlayerTokens = feature.Config.PlayerTokens,
            ExcludePlayerTokens = feature.Config.ExcludePlayerTokens,
        })) do
            local targetRoot = character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local offset = targetRoot.Position - root.Position
                local x = math.clamp(offset.X / range, -1, 1)
                local y = math.clamp(offset.Z / range, -1, 1)
                local dot = getDot(feature, character, feature.Config.PlayerColor or Color3.fromRGB(255, 86, 110))
                dot.Position = UDim2.fromScale(0.5 + x * 0.46, 0.5 + y * 0.46)
                dot.Visible = math.abs(offset.X) <= range and math.abs(offset.Z) <= range
                seen[character] = true
                count = count + 1
            end
        end

        if feature.Config.TargetTokens then
            for _, target in ipairs(Runtime:FindTargets({
                Scope = "Workspace",
                TargetTokens = feature.Config.TargetTokens,
                TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
                ReturnAdornee = true,
                MaxTargets = feature.Config.MaxTargets or 24,
            })) do
                local position = getPosition(target)
                if position then
                    local offset = position - root.Position
                    local x = math.clamp(offset.X / range, -1, 1)
                    local y = math.clamp(offset.Z / range, -1, 1)
                    local dot = getDot(feature, target, feature.Config.TargetColor or Color3.fromRGB(255, 220, 80))
                    dot.Position = UDim2.fromScale(0.5 + x * 0.46, 0.5 + y * 0.46)
                    dot.Visible = math.abs(offset.X) <= range and math.abs(offset.Z) <= range
                    seen[target] = true
                    count = count + 1
                end
            end
        end

        for target, dot in pairs(self.RadarDots) do
            local alive = false
            pcall(function() alive = target ~= nil and target.Parent ~= nil end)
            if not seen[target] or not alive then
                if dot and dot.Parent then dot.Visible = false end
                if not alive then self.RadarDots[target] = nil end
            end
        end
        return count > 0, count > 0 and ("Radar tracking " .. count .. " target(s)") or "Waiting for radar targets"
    end)
end

local function startCourseAssist(feature)
    feature.LastJumpAt = 0
    feature:_Loop(feature.Config.Interval or 0.10, function(self)
        local _, character, humanoid, root = getCharacter()
        if not humanoid or not root or not character then return false, "Waiting for the local character" end
        local movementAvailable, movementOwner = Runtime:CanUseMovement(self, self.Config.MovementPriority or 65)
        if not movementAvailable then return false, "Movement is currently controlled by " .. tostring(movementOwner) end

        local finish = Runtime:FindNearest({
            Scope = "Workspace",
            TargetTokens = self.Config.TargetTokens or {"finish", "end", "goal", "exit", "safe zone"},
            ExcludeTokens = {"start", "spawn"},
            TargetClasses = {"BasePart", "Model", "ProximityPrompt"},
            ReturnAdornee = true,
            MaxTargets = 120,
            CacheTTL = 0.65,
        }, root.Position)
        local finishPosition = getPosition(finish)
        if not finishPosition then return false, self.Config.WaitingMessage or "Waiting for the Jump Rope finish area" end

        local rope = Runtime:ObserveRope(self, root, self.Config.ObstacleTokens or {"rope", "swing", "bar", "spinner", "sweep"})
        local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
        if rope then
            local dangerDistance = self.Config.JumpDistance or 17
            if grounded and os.clock() - (self.LastJumpAt or 0) >= 0.62
                and rope.Distance <= dangerDistance
                and math.abs(rope.Vertical) <= 10
                and (rope.Approaching or rope.Distance <= 5)
            then
                Runtime:StopMovement(self)
                humanoid.Jump = true
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                self.LastJumpAt = os.clock()
                return true, string.format("Jumping the approaching rope (%.1f studs)", rope.Distance)
            elseif rope.Approaching and rope.Distance <= dangerDistance * 1.18 then
                Runtime:StopMovement(self)
                return true, "Holding position until the approaching rope can be jumped"
            end
        end

        -- The visual course has a gap in the bridge. Check a short distance ahead
        -- toward the finish and jump instead of walking into empty space.
        local flatDirection = Vector3.new(finishPosition.X - root.Position.X, 0, finishPosition.Z - root.Position.Z)
        if grounded and flatDirection.Magnitude > 0.1 and os.clock() - (self.LastJumpAt or 0) >= 0.62 then
            local ahead = root.Position + flatDirection.Unit * 5
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {character}
            local groundAhead = Workspace:Raycast(ahead + Vector3.new(0, 2, 0), Vector3.new(0, -9, 0), params)
            if not groundAhead then
                humanoid.Jump = true
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                self.LastJumpAt = os.clock()
                return true, "Jumping the bridge gap"
            end
        end

        local moved, detail = Runtime:MoveTo(finishPosition, self, {
            Direct = true,
            StopDistance = self.Config.StopDistance or 7,
            MovementPriority = self.Config.MovementPriority or 65,
            CommandInterval = 0.38,
            LeaseDuration = 0.48,
            TargetChangeDistance = 4,
        })
        return moved, moved and "Advancing during a safe rope window" or detail
    end)
end

local function startPositionKeeper(feature)
    local _, _, _, initialRoot = getCharacter()
    feature.AnchorPosition = initialRoot and initialRoot.Position or nil
    feature:_Loop(feature.Config.Interval or 0.25, function(self)
        local _, _, _, root = getCharacter()
        if not root then return false, "Waiting for the local character" end
        if not self.AnchorPosition then
            self.AnchorPosition = root.Position
            return true, "Saved the preferred lane"
        end

        if string.find(lower(self.Id), "mapped.games.jump_rope.", 1, true) then
            local finish = Runtime:FindNearest({
                Scope = "Workspace",
                TargetTokens = {"finish", "end", "goal", "exit", "safe zone"},
                ExcludeTokens = {"start", "spawn"},
                TargetClasses = {"BasePart", "Model"},
                ReturnAdornee = true,
                MaxTargets = 100,
                CacheTTL = 1.0,
            }, root.Position)
            local finishPosition = getPosition(finish)
            if not finishPosition then return false, "Waiting for the Jump Rope finish direction" end
            local direction = Vector3.new(finishPosition.X - self.AnchorPosition.X, 0, finishPosition.Z - self.AnchorPosition.Z)
            if direction.Magnitude < 1 then return false, "Finish direction is not ready" end
            direction = direction.Unit
            local displacement = Vector3.new(root.Position.X - self.AnchorPosition.X, 0, root.Position.Z - self.AnchorPosition.Z)
            local forwardDistance = displacement:Dot(direction)
            local desired = self.AnchorPosition + direction * forwardDistance
            desired = Vector3.new(desired.X, root.Position.Y, desired.Z)
            local lateralError = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(desired.X, 0, desired.Z)).Magnitude
            if lateralError > (self.Config.MaxDistance or 7) then
                local moved, detail = Runtime:MoveTo(desired, self, {
                    Direct = true,
                    StopDistance = 1.5,
                    MovementPriority = self.Config.MovementPriority or 25,
                    CommandInterval = 0.45,
                    LeaseDuration = 0.5,
                })
                return moved, moved and "Recentering in the Jump Rope lane" or detail
            end
            return true, string.format("Centered in lane (%.1f studs lateral)", lateralError)
        end

        local distance = (root.Position - self.AnchorPosition).Magnitude
        if distance > (self.Config.MaxDistance or 8) then
            local moved, detail = Runtime:MoveTo(self.AnchorPosition, self, {
                Direct = true,
                StopDistance = self.Config.MaxDistance or 8,
                MovementPriority = 25,
                CommandInterval = 0.5,
            })
            return moved, moved and "Returning to the preferred position" or detail
        end
        return true, "Holding the preferred position"
    end)
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
            local hit = Workspace:Raycast(root.Position, Vector3.new(0, -8, 0), params)
            local part = hit and hit.Instance
            if part and part:IsA("BasePart") and containsAny(instanceText(part), {"glass", "panel", "tile", "bridge"}) then
                ObservedSafeGlass[part] = os.clock()
            end
        end
    end
end

local function glassSafety(part)
    for _, attributeName in ipairs({"Safe", "IsSafe", "Correct", "Real", "CanStand"}) do
        local ok, value = pcall(part.GetAttribute, part, attributeName)
        if ok and type(value) == "boolean" then return value end
    end
    local parent = part.Parent
    if parent then
        for _, valueName in ipairs({"Safe", "IsSafe", "Correct", "Real"}) do
            local value = parent:FindFirstChild(valueName)
            if value and value:IsA("BoolValue") then return value.Value end
        end
    end
    if ObservedSafeGlass[part] then return true end
    if part.CanCollide == false or part.Transparency > 0.85 then return false end
    return nil
end

local function glassParts()
    local now = os.clock()
    local cache = Runtime._GlassPartsCache
    if cache and now - cache.Time < 1.0 then
        local alive = {}
        for _, part in ipairs(cache.Results) do
            if part and part.Parent then table.insert(alive, part) end
        end
        return alive
    end
    local results = Runtime:FindTargets({
        Scope = "Workspace",
        TargetTokens = {"glass", "panel", "tile", "bridge"},
        TargetClasses = {"BasePart"},
        MaxTargets = 240,
        CacheTTL = 1.0,
    })
    Runtime._GlassPartsCache = {Time = now, Results = results}
    return results
end

local function startSafeTileWalk(feature)
    feature:_Loop(feature.Config.Interval or 0.35, function(self)
        local _, _, _, root = getCharacter()
        if not root then return false, "Waiting for the local character" end
        local movementAvailable, movementOwner = Runtime:CanUseMovement(self, self.Config.MovementPriority or 70)
        if not movementAvailable then return false, "Movement is currently controlled by " .. tostring(movementOwner) end
        updateObservedGlass()
        local best, bestDistance = nil, math.huge
        for _, part in ipairs(glassParts()) do
            local distance = (part.Position - root.Position).Magnitude
            if distance > (self.Config.MinimumDistance or 2) and distance < (self.Config.MaximumDistance or 55)
                and glassSafety(part) == true and distance < bestDistance
            then
                best, bestDistance = part, distance
            end
        end
        if not best then
            return false, "Waiting for a panel verified by attributes or another standing player"
        end
        local moved, detail = Runtime:MoveTo(best.Position + Vector3.new(0, 2.5, 0), self, {
            StopDistance = 4,
            MaxWaypoints = 2,
            WaypointTimeout = 0.75,
            MovementPriority = self.Config.MovementPriority or 70,
        })
        return moved, moved and "Walking to an observed-safe panel" or detail
    end)
end

local function startGlassESP(feature)
    feature.HighlightByTarget = {}
    feature:_Loop(feature.Config.Interval or 0.8, function(self)
        local count = 0
        for _, part in ipairs(glassParts()) do
            local safe = glassSafety(part)
            local color
            if safe == true then
                color = self.Config.SafeColor or Color3.fromRGB(60, 255, 126)
            elseif safe == false then
                color = self.Config.UnsafeColor or Color3.fromRGB(255, 80, 90)
            else
                color = self.Config.UnknownColor or Color3.fromRGB(255, 210, 70)
            end
            local highlight = self.HighlightByTarget[part]
            if not highlight or not highlight.Parent then
                highlight = Instance.new("Highlight")
                highlight.Name = "SquidNoMo_" .. self.Id
                highlight.Adornee = part
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillTransparency = 0.50
                highlight.OutlineTransparency = 0.02
                highlight.Parent = part
                self.HighlightByTarget[part] = highlight
                self:_TrackInstance(highlight)
            end
            highlight.FillColor = color
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            count = count + 1
        end
        return count > 0, count > 0 and ("Classified " .. count .. " bridge panel(s)") or "Waiting for bridge glass panels"
    end)
end

local function startTaskChain(feature)
    feature:_Loop(feature.Config.Interval or 0.55, function(self)
        local _, _, _, root = getCharacter()
        if not root then return false, "Waiting for the local character" end
        local movementAvailable, movementOwner = Runtime:CanUseMovement(self, self.Config.MovementPriority or 60)
        if not movementAvailable then return false, "Movement is currently controlled by " .. tostring(movementOwner) end

        local heldTool = Runtime:FindTool(self.Config.RequireToolTokens or {})
        local targetConfig
        local stageName
        local id = lower(self.Id)
        local forceDestination = false

        if string.find(id, "mapped.detective.boat_operations.boatdepositor", 1, true) then
            local detective = Runtime:GetDetectiveState()
            forceDestination = detective.Stage == "Deposit Evidence" or (detective.Evidence and detective.Evidence > 0)
            if not forceDestination and not heldTool then
                return false, "No carried evidence detected yet"
            end
        end

        if not forceDestination and self.Config.RequireToolTokens and #self.Config.RequireToolTokens > 0 and not heldTool then
            targetConfig = {
                TargetTokens = self.Config.SourceTokens,
                TargetNames = self.Config.SourceNames,
                ExcludeTokens = self.Config.SourceExcludeTokens,
            }
            stageName = self.Config.SourceLabel or "source item"
        else
            targetConfig = {
                TargetTokens = self.Config.DestinationTokens or self.Config.TargetTokens,
                TargetNames = self.Config.DestinationNames or self.Config.TargetNames,
                ExcludeTokens = self.Config.DestinationExcludeTokens,
            }
            stageName = self.Config.DestinationLabel or "destination"
            if heldTool then Runtime:EquipTool(heldTool) end
        end

        local target, distance = Runtime:FindBestTarget({
            Scope = self.Config.Scope or "Workspace",
            TargetTokens = targetConfig.TargetTokens,
            TargetNames = targetConfig.TargetNames,
            ExcludeTokens = targetConfig.ExcludeTokens,
            TargetClasses = {"Model", "BasePart", "ProximityPrompt", "ClickDetector", "Tool"},
            MaxTargets = 180,
            CacheTTL = 0.30,
            PreferInteractive = true,
        }, root.Position)

        if not target then return false, "Waiting for " .. stageName end
        if distance > (self.Config.InteractDistance or 12) then
            local moved, detail = Runtime:MoveTo(getPosition(target), self, {
                StopDistance = self.Config.InteractDistance or 10,
                MaxWaypoints = 4,
                WaypointTimeout = 1.0,
                MovementPriority = self.Config.MovementPriority or 60,
                RepathInterval = 0.75,
            })
            return moved, moved and ("Walking to " .. stageName) or detail
        end

        local cooldown = self.Config.ActionCooldown or 0.8
        if os.clock() - (self.LastAction or 0) < cooldown then
            return true, stageName .. " interaction cooling down"
        end
        local ok, detail = Runtime:Interact(target, self, {Priority = self.Config.ActionPriority or 55, Duration = cooldown})
        if heldTool and type(heldTool.Activate) == "function"
            and Runtime:ClaimAction(self, "Interaction", self.Config.ActionPriority or 55, cooldown)
        then
            pcall(heldTool.Activate, heldTool)
        end
        if ok then self.LastAction = os.clock() end
        return ok, ok and ("Completed " .. stageName .. " interaction") or detail
    end)
end

local function startRPSAutoPlay(feature)
    feature.ChoiceIndex = 0
    feature:_Loop(feature.Config.Interval or 0.35, function(self)
        local player = getLocalPlayer()
        local gui = player and player:FindFirstChildOfClass("PlayerGui")
        if not gui then return false, "Waiting for the RPS interface" end

        local visibleText = ""
        local buttons = {}
        forEachIndexed("Gui", {"GuiObject"}, function(instance)
            if isVisibleGui(instance) then
                if instance:IsA("TextLabel") or instance:IsA("TextButton") then
                    visibleText = visibleText .. " " .. lower(instance.Text)
                end
                if instance:IsA("GuiButton") and containsAny(instanceText(instance), {"rock", "paper", "scissors"}) then
                    table.insert(buttons, instance)
                end
            end
            return true
        end)
        if #buttons == 0 then return false, "Waiting for Rock/Paper/Scissors choice buttons" end

        local wanted
        if containsAny(visibleText, {"opponent: rock", "enemy rock", "picked rock"}) then
            wanted = "paper"
        elseif containsAny(visibleText, {"opponent: paper", "enemy paper", "picked paper"}) then
            wanted = "scissors"
        elseif containsAny(visibleText, {"opponent: scissors", "enemy scissors", "picked scissors"}) then
            wanted = "rock"
        else
            local choices = {"rock", "paper", "scissors"}
            self.ChoiceIndex = (self.ChoiceIndex % #choices) + 1
            wanted = choices[self.ChoiceIndex]
        end

        local selected
        for _, button in ipairs(buttons) do
            if containsAny(instanceText(button), {wanted}) then
                selected = button
                break
            end
        end
        selected = selected or buttons[1]
        local ok, detail = Runtime:ClickGui(selected, self, {
            Resource = "GuiAction",
            Priority = self.Config.ActionPriority or 75,
            Duration = 0.3,
        })
        if not ok then return false, detail end

        task.wait(0.08)
        local submit = findVisibleGui({"submit", "confirm", "play", "lock", "choose"}, {"GuiButton"})
        if submit then
            Runtime:ClickGui(submit, self, {
                Resource = "GuiAction",
                Priority = self.Config.ActionPriority or 75,
                Duration = 0.3,
            })
        end
        return true, "Selected " .. string.upper(wanted)
    end)
end

local GameProfiles = {
    {Name = "Red Light, Green Light", VisualTokens = {
        "red light green light", "red light, green light", "red light", "green light",
        "younghee", "young hee", "yeonghee", "mugunghwa", "robot doll",
        "do not move", "don't move", "stop moving", "move when the doll",
        "reach the finish line", "cross the finish line"
    }, WorldTokens = {
        "rlgl", "redlightgreenlight", "red light green light", "younghee", "young hee",
        "yeonghee", "mugunghwa", "robot doll", "doll head", "finishline", "finish line",
        "startingline", "start line", "redlightsignal", "greenlightsignal"
    }},
    {Name = "Dalgona", VisualTokens = {"honeycomb", "dalgona", "cut the shape", "trace the shape", "carve", "cookie shape"}, WorldTokens = {"dalgona", "honeycomb", "cookie", "needle"}},
    {Name = "Pentathlon", VisualTokens = {"pentathlon", "ddakji", "gonggi", "jegichagi", "paengi", "biseokchigi", "spinning top", "five legged"}, WorldTokens = {"pentathlon", "ddakji", "gonggi", "jegi", "biseok"}},
    {Name = "Hide & Seek", VisualTokens = {"hide & seek", "hide and seek", "hider", "seeker", "keys & knives", "find a key", "find the exit"}, WorldTokens = {"hide seek", "key room", "maze exit"}},
    {Name = "Jump Rope", VisualTokens = {"jump rope", "reach the other side", "make it to the other side", "cross the bridge", "swinging rope"}, WorldTokens = {"jump rope", "jumprope", "swinging bar"}},
    {Name = "Marbles", VisualTokens = {"marbles", "marble game", "throw the marble", "ring shooter"}, WorldTokens = {"marble", "marbles"}},
    {Name = "Mingle", VisualTokens = {"mingle", "find a room", "enter a room", "room with", "players per room", "group of"}, WorldTokens = {"mingle", "carousel room"}},
    {Name = "Fight Nights", VisualTokens = {"night brawl", "fight night", "lights out", "final dinner", "dinner fight"}, WorldTokens = {"night brawl", "lights out", "dinner arena"}},
    {Name = "Glass Bridge", VisualTokens = {"glass bridge", "choose a glass", "cross the glass", "glass stepping"}, WorldTokens = {"glass bridge", "glass panels", "bridge glass"}},
    {Name = "Rebellion", VisualTokens = {"rebellion", "uprising", "take the armory", "fight the guards"}, WorldTokens = {"rebellion", "armory", "uprising"}},
    {Name = "Rock, Paper, Scissors Minus One", VisualTokens = {"rock, paper, scissors", "rock paper scissors", "minus one", "remove one"}, WorldTokens = {"rps", "minus one"}},
    {Name = "Sky Squid", VisualTokens = {"sky squid", "push a player off", "floating platform", "platform round"}, WorldTokens = {"sky squid", "floating platform"}},
    {Name = "Squid Game", VisualTokens = {"attack the goal", "defend the goal", "squid court", "offense team", "defense team"}, WorldTokens = {"squid court", "squid game court"}},
    {Name = "Tug of War", VisualTokens = {"tug of war", "pull meter", "keep the marker", "team rope"}, WorldTokens = {"tugofwar", "tug of war", "rope team"}},
    {Name = "Escape", VisualTokens = {"island escape", "escape the island", "extraction boat", "escape route"}, WorldTokens = {"escape island", "extraction boat"}},
}

local ExpectedGameFragments = {
    {"mapped.games.red_light_green_light.", "Red Light, Green Light"},
    {"mapped.games.dalgona.", "Dalgona"},
    {"mapped.games.pentathlon.", "Pentathlon"},
    {"mapped.games.hide_seek.", "Hide & Seek"},
    {"mapped.games.jump_rope.", "Jump Rope"},
    {"mapped.games.marbles.", "Marbles"},
    {"mapped.games.mingle.", "Mingle"},
    {"mapped.games.fight_nights.", "Fight Nights"},
    {"mapped.games.glass_bridge.", "Glass Bridge"},
    {"mapped.games.rebellion.", "Rebellion"},
    {"mapped.games.rock_paper_scissors_minus_one.", "Rock, Paper, Scissors Minus One"},
    {"mapped.games.sky_squid.", "Sky Squid"},
    {"mapped.games.squid_game.", "Squid Game"},
    {"mapped.games.tug_of_war.", "Tug of War"},
    {"mapped.games.escape.", "Escape"},
}

local PentathlonStageFragments = {
    {".ddakji", "Ddakji"},
    {".gonggi", "Gonggi"},
    {".jegichagi", "Jegichagi"},
    {".paengi", "Paengi"},
    {".biseokchigi", "Biseokchigi"},
}

function Runtime:GetExpectedGame(feature)
    local config = feature and feature.Config or feature or {}
    if config.ExpectedGame then return config.ExpectedGame end
    local id = lower(feature and feature.Id or config.Id)
    for _, pair in ipairs(ExpectedGameFragments) do
        if string.find(id, pair[1], 1, true) then return pair[2] end
    end
    return nil
end

function Runtime:GetExpectedPentathlonStage(feature)
    local id = lower(feature and feature.Id or "")
    for _, pair in ipairs(PentathlonStageFragments) do
        if string.find(id, pair[1], 1, true) then return pair[2] end
    end
    return nil
end

local function addTableEvidence(addEvidence, value, prefix, depth, seen)
    if depth > 4 or type(value) ~= "table" or seen[value] then return end
    seen[value] = true
    for key, item in pairs(value) do
        local label = tostring(prefix or "") .. " " .. tostring(key)
        if type(item) == "table" then
            addTableEvidence(addEvidence, item, label, depth + 1, seen)
        elseif type(item) == "string" or type(item) == "number" or type(item) == "boolean" then
            addEvidence(label .. " " .. tostring(item), 34, "teleport data")
        end
    end
end

local function worldInstanceIsActive(instance, origin)
    if not instance or not instance.Parent then return false end
    if instance:IsA("ProximityPrompt") then return instance.Enabled end
    if instance:IsA("Sound") then return instance.Playing end
    local part = instance:IsA("BasePart") and instance or nil
    if not part and instance:IsA("Model") then
        part = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
    end
    if not part then
        return instance.Parent == Workspace
    end
    if part.Transparency >= 0.985 or part.Size.Magnitude < 0.25 then return false end
    if origin and (part.Position - origin).Magnitude > 900 then return false end
    return true
end

local function isGameStateValue(instance, context)
    if not instance or not instance:IsA("ValueBase") then return false end
    local name = lower(instance.Name)
    local exactNames = {
        currentgame = true, game = true, gamename = true, selectedgame = true,
        currentround = true, round = true, roundname = true,
        mode = true, gamemode = true, minigame = true,
        currentmap = true, mapname = true, selectedmap = true, stage = true,
    }
    if exactNames[string.gsub(name, "[%s_%-]", "")] then return true end
    return containsAny(context, {
        "current game", "current round", "game mode", "round name",
        "minigame", "selected game", "current map", "map name", "selected map"
    })
end

local function countEvidenceTokens(evidence, tokens, sourceFilter)
    local hits, best = 0, 0
    for _, token in ipairs(tokens) do
        local tokenHit = 0
        for _, item in ipairs(evidence) do
            if (not sourceFilter or sourceFilter[item.Source]) and string.find(item.Text, token, 1, true) then
                tokenHit = math.max(tokenHit, item.Weight)
            end
        end
        if tokenHit > 0 then hits, best = hits + 1, best + tokenHit end
    end
    return hits, best
end

function Runtime:SetManualGameHint(name, ttl)
    if type(name) ~= "string" or name == "" then return false end
    local now = os.clock()
    self._ManualGameHint = {Name = name, ExpiresAt = now + math.max(tonumber(ttl) or 14, 3)}
    Environment.__SquidNoMoManualGameHint = self._ManualGameHint
    return true
end

function Runtime:DetectGameCategory()
    local now = os.clock()
    if self._GameDetectionCache and now - self._GameDetectionCache.Time < 0.20 then
        return self._GameDetectionCache.Name, self._GameDetectionCache.Score
    end

    local evidence = {}
    local function addEvidence(value, weight, source)
        local valueText = lower(value)
        if valueText ~= "" then
            table.insert(evidence, {Text = valueText, Weight = tonumber(weight) or 1, Source = source})
        end
    end

    local snapshot = self:GetVisualSnapshot(true)
    for _, item in ipairs(snapshot.Items) do
        if item.Text ~= "" then
            local weight = item.TextSize >= 32 and 20 or (item.TextSize >= 22 and 15 or 10)
            addEvidence(item.Text .. " " .. item.Context, weight, "HUD")
        end
    end

    -- Teleport/join data is the best available source when the lobby sends the
    -- selected game to a destination server without leaving an objective label on
    -- screen. Read it recursively but never fail on executors that block the API.
    pcall(function()
        local data = TeleportService:GetLocalPlayerTeleportData()
        if type(data) == "table" then addTableEvidence(addEvidence, data, "teleport", 0, {}) end
    end)
    local player, character, _, root = getCharacter()
    if player then
        pcall(function()
            local joinData = player:GetJoinData()
            if type(joinData) == "table" then addTableEvidence(addEvidence, joinData, "join", 0, {}) end
        end)
        if player.Team then addEvidence(player.Team.Name, 4, "team") end
        for _, object in ipairs({player, character}) do
            if object then
                for _, attributeName in ipairs({"CurrentGame", "Game", "Round", "RoundName", "Mode", "CurrentRound", "Minigame", "SelectedGame", "CurrentMap", "MapName"}) do
                    local ok, value = pcall(object.GetAttribute, object, attributeName)
                    if ok and value ~= nil then addEvidence(attributeName .. " " .. tostring(value), 28, "player attribute") end
                end
            end
        end
        local descendantCount = 0
        for _, descendant in ipairs(player:GetDescendants()) do
            if descendantCount >= 320 then break end
            descendantCount = descendantCount + 1
            if descendant:IsA("ValueBase") then
                local context = instanceText(descendant)
                if isGameStateValue(descendant, context) then
                    addEvidence(context .. " " .. tostring(descendant.Value), 27, "player state")
                end
            end
        end
    end

    for _, rootObject in ipairs({Workspace, ReplicatedStorage}) do
        for attributeName, attributeValue in pairs(rootObject:GetAttributes()) do
            if containsAny(attributeName, {"game", "round", "mode", "phase", "state", "current", "minigame"}) then
                addEvidence(attributeName .. " " .. tostring(attributeValue), 24, "root attribute")
            end
        end
    end

    -- Read only explicit state values from ReplicatedStorage. Dormant map folders
    -- for Pentathlon/Dalgona/etc. are intentionally ignored because they exist
    -- while RLGL is active and were the main source of false game switching.
    forEachIndexed("ReplicatedStorage", {"ValueBase"}, function(instance)
        local context = instanceText(instance)
        local strong = isGameStateValue(instance, context)
        if strong then addEvidence(context .. " " .. tostring(instance.Value), 25, "replicated state") end
        return true
    end)

    local worldScanned = 0
    forEachIndexed("Workspace", {"ValueBase", "Model", "BasePart", "ProximityPrompt", "Sound"}, function(instance)
        if worldScanned >= 900 then return false end
        worldScanned = worldScanned + 1
        local context = instanceText(instance)
        if instance:IsA("ValueBase") then
            local strong = isGameStateValue(instance, context)
            if strong then addEvidence(context .. " " .. tostring(instance.Value), 25, "workspace state") end
        elseif worldInstanceIsActive(instance, root and root.Position or nil) then
            addEvidence(context, instance:IsA("ProximityPrompt") and 12 or (instance:IsA("Sound") and 11 or 6), "active world")
        end
        return true
    end)

    local ranked = {}
    for _, profile in ipairs(GameProfiles) do
        local score, strong, hits = 0, false, 0
        local function scoreTokens(tokens, visual)
            for _, token in ipairs(tokens) do
                local best = 0
                local phraseBonus = string.find(token, " ", 1, true) and 1.65 or 1.0
                for _, item in ipairs(evidence) do
                    if string.find(item.Text, token, 1, true) then
                        local sourceMultiplier = 1.0
                        if visual and item.Source == "HUD" then sourceMultiplier = 1.6 end
                        if item.Source == "teleport data" or item.Source == "player attribute"
                            or item.Source == "workspace state" or item.Source == "replicated state" or item.Source == "player state"
                        then
                            sourceMultiplier = 2.0
                        end
                        best = math.max(best, item.Weight * phraseBonus * sourceMultiplier)
                    end
                end
                if best > 0 then
                    score = score + best
                    hits = hits + 1
                    if best >= 15 then strong = true end
                end
            end
        end
        scoreTokens(profile.VisualTokens, true)
        scoreTokens(profile.WorldTokens, false)

        if profile.Name == "Red Light, Green Light" then
            local rlglState = findStatusText({"light", "status", "state"})
            if rlglState then score, hits, strong = score + 48, hits + 2, true end
            local dollHits = select(1, countEvidenceTokens(evidence, {"younghee", "young hee", "yeonghee", "robot doll", "doll head", "mugunghwa"}, {HUD=true, ["active world"]=true}))
            local lineHits = select(1, countEvidenceTokens(evidence, {"finishline", "finish line", "startingline", "start line", "safe zone"}, {["active world"]=true}))
            if dollHits > 0 and lineHits > 0 then score, hits, strong = score + 38, hits + 2, true end
        end

        table.insert(ranked, {Name = profile.Name, Score = score, Strong = strong, Hits = hits})
    end
    table.sort(ranked, function(a, b)
        if a.Score == b.Score then return a.Name < b.Name end
        return a.Score > b.Score
    end)

    local best, second = ranked[1], ranked[2]
    local candidate, candidateScore = nil, best and best.Score or 0
    if best and candidateScore >= 16 and best.Strong
        and (best.Hits >= 2 or candidateScore >= 38)
        and (not second or candidateScore - second.Score >= 7)
    then
        candidate = best.Name
    end

    local hint = self._ManualGameHint or Environment.__SquidNoMoManualGameHint
    if type(hint) == "table" and tonumber(hint.ExpiresAt or 0) > now then
        if not candidate or candidateScore < 30 then
            candidate, candidateScore = hint.Name, 29
        elseif candidate ~= hint.Name and candidateScore >= 44 then
            self._ManualGameHint = nil
            Environment.__SquidNoMoManualGameHint = nil
        end
    end

    local state = self._StableGameDetection or {Name = nil, Candidate = nil, Count = 0, ConfirmedAt = 0}
    if candidate and candidate == state.Candidate then
        state.Count = state.Count + 1
    elseif candidate then
        state.Candidate = candidate
        state.Count = 1
    else
        state.Candidate = nil
        state.Count = 0
    end

    if candidate and (state.Count >= 2 or candidateScore >= 44) then
        state.Name = candidate
        state.ConfirmedAt = now
    elseif not candidate and state.Name and now - (state.ConfirmedAt or 0) > 4.5 then
        state.Name = nil
    end
    self._StableGameDetection = state

    local confirmed = state.Name
    if confirmed then
        Environment.__SquidNoMoDetectedGame = confirmed
        Environment.__SquidNoMoDetectedGameAt = now
    elseif Environment.__SquidNoMoDetectedGameAt and now - Environment.__SquidNoMoDetectedGameAt > 5 then
        Environment.__SquidNoMoDetectedGame = nil
    end
    self._GameDetectionCache = {
        Time = now,
        Name = confirmed,
        Score = candidateScore,
        Candidate = candidate,
        RunnerUp = second and second.Name or nil,
        RunnerUpScore = second and second.Score or 0,
    }
    return confirmed, candidateScore
end

function Runtime:FeatureContextAllowed(feature)
    if not feature or not feature.Config then return true end
    if feature.Config.IgnoreVisualContext == true then return true end

    local expectedGame = self:GetExpectedGame(feature)
    if expectedGame then
        local detectedGame = Environment.__SquidNoMoDetectedGame or self:DetectGameCategory()
        local phase = self:GetRoundPhase()
        if phase == "Lobby" then
            return false, "Paused: waiting for the round to begin"
        elseif phase == "Ended" then
            return false, "Paused: the current round has ended"
        elseif detectedGame and detectedGame ~= expectedGame then
            return false, "Paused: " .. tostring(detectedGame) .. " is active; this feature is for " .. tostring(expectedGame)
        end
        if expectedGame == "Pentathlon" then
            local expectedStage = self:GetExpectedPentathlonStage(feature)
            local currentStage = self:GetPentathlonStage()
            if expectedStage and currentStage and expectedStage ~= currentStage then
                return false, "Paused: Pentathlon is currently on " .. currentStage
            end
        elseif expectedGame == "Mingle" and feature.Config.Kind == "RoomAssist" then
            local minglePhase = self:GetMinglePhase()
            if minglePhase == "Carousel" then
                return false, "Paused: waiting for the room number"
            elseif minglePhase == "Locked" then
                return false, "Paused: the selected Mingle room is already locked"
            end
        end
    end

    local id = lower(feature.Id)
    if string.find(id, "mapped.games.hide_seek.", 1, true) then
        local hideSeekRole = self:GetHideSeekRole()
        local hiderOnly = string.find(id, ".autograbkey", 1, true)
            or string.find(id, ".autopathtoexit", 1, true)
            or string.find(id, ".exitesp", 1, true)
            or string.find(id, ".huntertracker", 1, true)
        local seekerOnly = string.find(id, ".autograbknife", 1, true)
            or string.find(id, ".autoswing", 1, true)
        if hideSeekRole == "Hider" and seekerOnly then
            return false, "Paused: this Hide & Seek feature is for Seekers"
        elseif hideSeekRole == "Seeker" and hiderOnly then
            return false, "Paused: this Hide & Seek feature is for Hiders"
        end
    end
    local expectedRole
    if string.find(id, "mapped.guards.", 1, true) then expectedRole = "Guard"
    elseif string.find(id, "mapped.detective.", 1, true) then expectedRole = "Detective" end
    if expectedRole then
        local role = self:GetVisualRole()
        if role then
            local allowed = role == expectedRole or (expectedRole == "Guard" and role == "Frontman")
            if not allowed then
                return false, "Paused: local role appears to be " .. role .. "; this feature is for " .. expectedRole
            end
        end
    end

    if string.find(id, "mapped.guards.", 1, true) then
        local expectedDuty
        if string.find(id, ".kitchen_staff.", 1, true) then expectedDuty = "Kitchen"
        elseif string.find(id, ".morgue_staff.", 1, true) then expectedDuty = "Morgue"
        elseif string.find(id, ".game_moderation.", 1, true) then expectedDuty = "Moderation" end
        local duty = self:GetGuardDuty()
        if expectedDuty and duty and duty ~= expectedDuty then
            return false, "Paused: current guard duty appears to be " .. duty
        end
    end

    return true
end

function Runtime:GetFeatureVisualHint(feature)
    if not feature then return nil end
    local id = lower(feature.Id)
    if string.find(id, "mapped.games.red_light_green_light.", 1, true) then
        local state = self:GetRLGLState()
        return state and (state .. " light") or "signal uncertain"
    elseif string.find(id, "mapped.games.mingle.", 1, true) then
        local count = self:GetMingleRequiredCount()
        local phase = self:GetMinglePhase()
        local parts = {}
        if phase then table.insert(parts, phase) end
        if count then table.insert(parts, "room count " .. count) end
        return #parts > 0 and table.concat(parts, ", ") or nil
    elseif string.find(id, "mapped.games.hide_seek.", 1, true) then
        local role = self:GetHideSeekRole()
        return role and ("role " .. role) or nil
    elseif string.find(id, "mapped.games.pentathlon.", 1, true) then
        local stage = self:GetPentathlonStage()
        return stage and ("stage " .. stage) or nil
    elseif string.find(id, "mapped.detective.", 1, true) then
        local state = self:GetDetectiveState()
        local parts = {}
        if state.Stage then table.insert(parts, state.Stage) end
        if state.Evidence and state.Capacity then table.insert(parts, state.Evidence .. "/" .. state.Capacity .. " evidence") end
        if state.Detection then table.insert(parts, math.floor(state.Detection * 100 + 0.5) .. "% detection") end
        return #parts > 0 and table.concat(parts, ", ") or nil
    elseif string.find(id, "mapped.guards.", 1, true) then
        local duty = self:GetGuardDuty()
        return duty and ("duty " .. duty) or nil
    end
    local expected = self:GetExpectedGame(feature)
    local detected = expected and self:DetectGameCategory()
    return detected and ("visual cue " .. detected) or nil
end

function Runtime:GetCompatibilitySummary()
    local virtualInput
    pcall(function() virtualInput = game:GetService("VirtualInputManager") end)
    return {
        Prompt = type(fireproximityprompt) == "function" or virtualInput ~= nil,
        Click = type(fireclickdetector) == "function",
        Touch = type(firetouchinterest) == "function",
        Gui = type(firesignal) == "function" or type(getconnections) == "function" or virtualInput ~= nil,
        Pathfinding = PathfindingService ~= nil,
    }
end

function Runtime:ValidateFeatureConfig(config)
    if type(config) ~= "table" then return false, "feature config is missing" end
    if type(config.Kind) ~= "string" or config.Kind == "" then return false, "feature Kind is missing" end
    local targetKinds = {
        Highlight = true, ToolActivate = true, GuiHighlight = true, WalkTo = true,
        Interact = true, ToolAura = true, Timing = true, GuiAction = true,
        AutoJump = true, Boundary = true, RoomAssist = true,
        AimActivate = true, Radar = true, CourseAssist = true, SafeTileWalk = true,
        GlassESP = true, TaskChain = true, StateHUD = true, AntiStuck = true,
        JumpBoost = true, AntiFall = true, RLGLAutoMove = true, Evasion = true,
        Disguise = true, PositionKeeper = true, RPSAutoPlay = true,
    }
    if targetKinds[config.Kind] then
        local hasSelector = (type(config.TargetTokens) == "table" and #config.TargetTokens > 0)
            or (type(config.TargetNames) == "table" and #config.TargetNames > 0)
            or (type(config.ActionTokens) == "table" and #config.ActionTokens > 0)
            or (type(config.ToolTokens) == "table" and #config.ToolTokens > 0)
            or config.Kind == "RoomAssist" or config.Kind == "SafeTileWalk"
            or config.Kind == "GlassESP" or config.Kind == "Radar"
            or config.Kind == "TaskChain" or config.Kind == "StateHUD"
            or config.Kind == "AntiStuck" or config.Kind == "JumpBoost"
            or config.Kind == "AntiFall" or config.Kind == "RLGLAutoMove"
            or config.Kind == "Evasion" or config.Kind == "Disguise"
            or config.Kind == "PositionKeeper" or config.Kind == "RPSAutoPlay"
            or config.PlayerMode == true
        if not hasSelector then
            return false, "feature has no target, action, or tool selector"
        end
    end
    return true
end

local function startToolActivate(feature)
    feature:_Loop(feature.Config.Interval or 0.3, function(self)
        local tool = Runtime:FindTool(self.Config.ToolTokens or self.Config.TargetTokens or {})
        if not tool then return false, self.Config.WaitingMessage or "Waiting for the required tool" end
        local cooldown = self.Config.ActionCooldown or math.max(self.Config.Interval or 0.3, 0.3)
        if os.clock() - (self.LastAction or 0) < cooldown then
            return true, "Tool equipped — action cooling down"
        end
        local ok, detail = Runtime:ActivateTool(self.Config.ToolTokens or self.Config.TargetTokens or {}, self, {
            Resource = "ToolAction",
            Priority = self.Config.ActionPriority or 45,
            Duration = cooldown,
        })
        if ok then self.LastAction = os.clock() end
        return ok, ok and ("Activated " .. tostring(tool.Name)) or detail
    end)
end

local function startGuiHighlight(feature)
    feature.GuiTarget = nil
    feature.GuiStroke = nil

    local function clear(self)
        if self.GuiStroke then pcall(function() self.GuiStroke:Destroy() end) end
        self.GuiStroke = nil
        self.GuiTarget = nil
    end
    feature.OnContextBlocked = clear
    feature.Restore = clear

    feature:_Loop(feature.Config.Interval or 0.2, function(self)
        local target = findVisibleGui(self.Config.TargetTokens or {}, {"GuiObject"})
        if not target then
            clear(self)
            return false, self.Config.WaitingMessage or "Waiting for the matching interface"
        end
        if self.GuiTarget ~= target or not self.GuiStroke or not self.GuiStroke.Parent then
            clear(self)
            local stroke = Instance.new("UIStroke")
            stroke.Name = "SquidNoMoGuiHighlight"
            stroke.Color = self.Config.Color or Color3.fromRGB(60, 220, 255)
            stroke.Thickness = self.Config.Thickness or 3
            stroke.Transparency = self.Config.Transparency or 0.02
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Parent = target
            self.GuiTarget = target
            self.GuiStroke = stroke
            self:_TrackInstance(stroke)
        end
        return true, "Highlighting " .. tostring(target.Name)
    end)
end

local function startStateHUD(feature)
    local parent = getGuiParent()
    if not parent then error("no compatible GUI parent is available") end
    local gui = Instance.new("ScreenGui")
    gui.Name = "SquidNoMo_StateHUD_" .. feature.Id
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999986
    gui.Parent = parent
    feature:_TrackInstance(gui)

    local label = Instance.new("TextLabel")
    label.AnchorPoint = Vector2.new(0.5, 0)
    label.Position = UDim2.new(0.5, 0, 0, 76)
    label.Size = UDim2.fromOffset(220, 44)
    label.BackgroundColor3 = Color3.fromRGB(12, 14, 19)
    label.BackgroundTransparency = 0.08
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamBlack
    label.Text = "RLGL: WAITING"
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(255, 210, 80)
    label.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = label
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Transparency = 0.15
    stroke.Color = label.TextColor3
    stroke.Parent = label

    feature.OnContextBlocked = function(self, detail)
        label.Text = "RLGL: WAITING"
        label.TextColor3 = Color3.fromRGB(255, 210, 80)
        stroke.Color = label.TextColor3
    end
    feature:_Loop(feature.Config.Interval or 0.12, function(self)
        local state = Runtime:GetRLGLState()
        if state == "Green" then
            label.Text = "RLGL: GREEN — MOVE"
            label.TextColor3 = Color3.fromRGB(70, 255, 130)
            stroke.Color = label.TextColor3
            return true, "Green light visible"
        elseif state == "Red" then
            label.Text = "RLGL: RED — STOP"
            label.TextColor3 = Color3.fromRGB(255, 78, 92)
            stroke.Color = label.TextColor3
            return true, "Red light visible"
        end
        label.Text = "RLGL: SIGNAL UNCERTAIN"
        label.TextColor3 = Color3.fromRGB(255, 210, 80)
        stroke.Color = label.TextColor3
        return false, "Waiting for an unambiguous red/green signal"
    end)
end

local function startAntiStuck(feature)
    feature.LastPosition = nil
    feature.LastProgressAt = os.clock()
    feature.OnContextBlocked = function(self)
        self.LastPosition = nil
        self.LastProgressAt = os.clock()
    end
    feature:_Loop(feature.Config.Interval or 0.35, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        local state = Runtime:GetRLGLState()
        if state ~= "Green" then
            self.LastPosition = root.Position
            self.LastProgressAt = os.clock()
            return false, state == "Red" and "Red light — recovery paused" or "Waiting for a confirmed green light"
        end
        if humanoid.MoveDirection.Magnitude < 0.05 then
            self.LastPosition = root.Position
            self.LastProgressAt = os.clock()
            return true, "Green light — standing still by choice"
        end
        local current = root.Position
        if not self.LastPosition or (current - self.LastPosition).Magnitude >= (self.Config.MinimumMovement or 0.3) then
            self.LastPosition = current
            self.LastProgressAt = os.clock()
            return true, "Movement progress detected"
        end
        if os.clock() - (self.LastProgressAt or os.clock()) >= (self.Config.StuckSeconds or 2.2) then
            humanoid.Jump = true
            pcall(humanoid.ChangeState, humanoid, Enum.HumanoidStateType.Jumping)
            local direction = humanoid.MoveDirection.Magnitude > 0.05 and humanoid.MoveDirection.Unit or root.CFrame.LookVector
            local velocity = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(
                velocity.X + direction.X * (self.Config.RecoveryVelocity or 5),
                math.max(velocity.Y, 10),
                velocity.Z + direction.Z * (self.Config.RecoveryVelocity or 5)
            )
            self.LastPosition = current
            self.LastProgressAt = os.clock()
            return true, "Applied a one-time jump recovery"
        end
        return true, "Checking movement progress"
    end)
end

local function startJumpBoost(feature)
    feature.OriginalHumanoid = nil
    feature.OriginalUseJumpPower = nil
    feature.OriginalJumpPower = nil
    feature.OriginalJumpHeight = nil

    local function restore(self)
        local humanoid = self.OriginalHumanoid
        if humanoid and humanoid.Parent then
            pcall(function()
                if self.OriginalUseJumpPower ~= nil then humanoid.UseJumpPower = self.OriginalUseJumpPower end
                if self.OriginalJumpPower ~= nil then humanoid.JumpPower = self.OriginalJumpPower end
                if self.OriginalJumpHeight ~= nil then humanoid.JumpHeight = self.OriginalJumpHeight end
            end)
        end
        self.OriginalHumanoid = nil
        self.OriginalUseJumpPower = nil
        self.OriginalJumpPower = nil
        self.OriginalJumpHeight = nil
    end
    feature.Restore = restore
    feature.OnContextBlocked = restore

    feature:_Loop(feature.Config.Interval or 0.35, function(self)
        local _, _, humanoid = getCharacter()
        if not humanoid then return false, "Waiting for the local character" end
        if self.OriginalHumanoid ~= humanoid then
            restore(self)
            self.OriginalHumanoid = humanoid
            self.OriginalUseJumpPower = humanoid.UseJumpPower
            self.OriginalJumpPower = humanoid.JumpPower
            self.OriginalJumpHeight = humanoid.JumpHeight
        end
        if humanoid.UseJumpPower then
            humanoid.JumpPower = math.max(humanoid.JumpPower, self.Config.JumpPower or 78)
            return true, "Jump power boosted for Jump Rope"
        end
        humanoid.JumpHeight = math.max(humanoid.JumpHeight, self.Config.JumpHeight or 13)
        return true, "Jump height boosted for Jump Rope"
    end)
end

local starters = {
    Highlight = startHighlight,
    ToolActivate = startToolActivate,
    GuiHighlight = startGuiHighlight,
    StateHUD = startStateHUD,
    AntiStuck = startAntiStuck,
    JumpBoost = startJumpBoost,
    WalkTo = startWalkTo,
    Interact = startInteract,
    ToolAura = startToolAura,
    Timing = startTiming,
    GuiAction = startGuiAction,
    AntiFall = startAntiFall,
    RLGLAutoMove = startRLGLAutoMove,
    AutoJump = startAutoJump,
    Evasion = startEvasion,
    Boundary = startBoundary,
    RoomAssist = startRoomAssist,
    AimActivate = startAimActivate,
    Disguise = startDisguise,
    Radar = startRadar,
    CourseAssist = startCourseAssist,
    PositionKeeper = startPositionKeeper,
    SafeTileWalk = startSafeTileWalk,
    GlassESP = startGlassESP,
    TaskChain = startTaskChain,
    RPSAutoPlay = startRPSAutoPlay,
}

function FeatureMethods:Toggle(state)
    state = state == true
    if self.Enabled == state then return true end
    self:_Clear()
    self.Enabled = state
    self.LastError = nil
    if not state then
        self:_SetStatus("Off", "Disabled")
        return true
    end

    self:_SetStatus("Starting", "Initializing " .. self.Name)
    local configOk, configDetail = Runtime:ValidateFeatureConfig(self.Config)
    if not configOk then
        self.Enabled = false
        self.LastError = configDetail
        self:_SetStatus("Error", configDetail)
        return false, configDetail
    end
    local starter = starters[self.Config.Kind]
    if not starter then
        self.Enabled = false
        self.LastError = "unsupported feature kind: " .. tostring(self.Config.Kind)
        self:_SetStatus("Error", self.LastError)
        return false, self.LastError
    end
    local ok, err = xpcall(function() starter(self) end, debug.traceback)
    if not ok then
        self.Enabled = false
        self.LastError = tostring(err)
        self:_SetStatus("Error", self.LastError)
        return false, self.LastError
    end
    return true
end

function FeatureMethods:Enable()
    return self:Toggle(true)
end

function FeatureMethods:Disable()
    return self:Toggle(false)
end

function FeatureMethods:IsEnabled()
    return self.Enabled == true
end

function FeatureMethods:GetState()
    return self.Enabled and "on" or "off"
end

function Runtime:CreateFeature(config)
    assert(type(config) == "table", "feature config must be a table")
    assert(type(config.Kind) == "string" and config.Kind ~= "", "feature Kind is required")
    local feature = setmetatable({
        Id = tostring(config.Id or config.Name or "feature"),
        Name = tostring(config.Name or config.Id or "Feature"),
        Description = tostring(config.Description or ""),
        Config = config,
        Enabled = false,
        Status = "Off",
        StatusDetail = "Disabled",
        LastError = nil,
        LastAction = 0,
        Connections = {},
        Threads = {},
        Instances = {},
        StatusListeners = {},
        NextListenerId = 0,
    }, FeatureMethods)
    return feature
end

return Runtime
