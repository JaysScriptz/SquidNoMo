-- SquidNoMo feature runtime
-- SquidNoMo feature revision: 1.1b1-ultralight-r4

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Runtime = {
    Revision = "1.1b1-ultralight-r4",
}

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end
Environment.__SquidNoMoFeatureRuntime = Runtime


-- One cooperative scheduler is shared by every game, guard, detective, and player
-- feature. It prevents dozens of independent while-loops from waking on the same
-- frame and automatically backs off features that are waiting for a round.
local Scheduler = Environment.__SquidNoMoScheduler
if type(Scheduler) ~= "table" or Scheduler.Revision ~= "1.1b1-ultralight-scheduler-r1" then
    Scheduler = {
        Revision = "1.1b1-ultralight-scheduler-r1",
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
    local ok, actionText = pcall(function()
        return instance:IsA("ProximityPrompt") and instance.ActionText or nil
    end)
    if ok and actionText then table.insert(parts, actionText) end
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
local INDEX_REVISION = "1.1b1-object-index-r2"
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
        "RemoteEvent", "RemoteFunction", "BindableEvent", "BindableFunction",
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

    if cache and now - cache.Time <= ttl then
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
        self.QueryCache[signature] = {Time = now, Results = results}
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

    -- Resolve a supported interaction before reserving the shared interaction
    -- channel. A decorative object must not block a valid collector feature.
    local prompt = target:IsA("ProximityPrompt") and target
        or target:FindFirstChildWhichIsA("ProximityPrompt", true)
    local detector = target:IsA("ClickDetector") and target
        or target:FindFirstChildWhichIsA("ClickDetector", true)
    local touchPart = target:IsA("BasePart") and target
        or target:FindFirstChildWhichIsA("BasePart", true)
    local _, _, _, root = getCharacter()

    local supportedPrompt = prompt and prompt.Enabled
    local supportedDetector = detector and type(fireclickdetector) == "function"
    local supportedTouch = touchPart and root and type(firetouchinterest) == "function"
    if not supportedPrompt and not supportedDetector and not supportedTouch then
        return false, "no supported prompt, click detector, or touch target"
    end

    local claimed, ownerName = self:ClaimAction(
        feature,
        options.Resource or "Interaction",
        options.Priority,
        options.Duration or 0.4
    )
    if not claimed then return false, "interaction is currently controlled by " .. tostring(ownerName) end

    if supportedPrompt then
        if type(fireproximityprompt) == "function" then
            local ok, err = pcall(fireproximityprompt, prompt)
            return ok, ok and nil or tostring(err)
        end
        local ok = pcall(function()
            prompt:InputHoldBegin()
            task.wait(math.min(prompt.HoldDuration, 0.1))
            prompt:InputHoldEnd()
        end)
        return ok, ok and nil or "executor cannot trigger ProximityPrompt"
    end

    if supportedDetector then
        local ok, err = pcall(fireclickdetector, detector)
        return ok, ok and nil or tostring(err)
    end

    local ok, err = pcall(function()
        firetouchinterest(root, touchPart, 0)
        task.wait()
        firetouchinterest(root, touchPart, 1)
    end)
    return ok, ok and nil or tostring(err)
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
    local button = target:IsA("GuiButton") and target or target:FindFirstChildWhichIsA("GuiButton", true)
    if button and type(firesignal) == "function" then
        local ok = pcall(function()
            firesignal(button.Activated)
        end)
        if ok then return true end
    end

    local virtualInput
    pcall(function() virtualInput = game:GetService("VirtualInputManager") end)
    local guiObject = button or (target:IsA("GuiObject") and target)
    if virtualInput and guiObject then
        local center = guiObject.AbsolutePosition + guiObject.AbsoluteSize / 2
        local ok, err = pcall(function()
            virtualInput:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 1)
            virtualInput:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 1)
        end)
        return ok, ok and nil or tostring(err)
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
        local ok, active, detail = pcall(callback, owner)
        if not ok then error(active) end
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
        local target, distance = Runtime:FindNearest({
            Scope = self.Config.Scope or "Workspace",
            TargetNames = self.Config.TargetNames,
            TargetTokens = self.Config.TargetTokens,
            RequiredTokens = self.Config.RequiredTokens,
            ExcludeTokens = self.Config.ExcludeTokens,
            TargetClasses = self.Config.TargetClasses or {"Model", "BasePart", "ProximityPrompt"},
            ReturnAdornee = self.Config.ReturnAdornee,
            MaxTargets = self.Config.MaxTargets or 120,
        }, root.Position)
        if not target then return false, self.Config.WaitingMessage end
        local position = getPosition(target)
        local moved, moveDetail = Runtime:MoveTo(position, self, self.Config)
        if self.Enabled and self.Config.Interact and position then
            local _, _, _, currentRoot = getCharacter()
            if currentRoot and (currentRoot.Position - position).Magnitude <= (self.Config.InteractDistance or 12) then
                local cooldown = self.Config.ActionCooldown or 0.8
                if os.clock() - (self.LastAction or 0) < cooldown then
                    return true, "Reached " .. target.Name .. " — interaction cooling down"
                end
                local interacted, interactDetail = Runtime:Interact(target, self, {Priority = self.Config.ActionPriority or 55, Duration = self.Config.ActionCooldown or 0.8})
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
        local target, distance = Runtime:FindNearest({
            Scope = self.Config.Scope or "Workspace",
            TargetNames = self.Config.TargetNames,
            TargetTokens = self.Config.TargetTokens,
            RequiredTokens = self.Config.RequiredTokens,
            ExcludeTokens = self.Config.ExcludeTokens,
            TargetClasses = self.Config.TargetClasses or {"Model", "BasePart", "ProximityPrompt", "ClickDetector"},
            MaxTargets = self.Config.MaxTargets or 140,
        }, root.Position)
        if not target then return false, self.Config.WaitingMessage end
        if self.Config.MaxDistance and distance > self.Config.MaxDistance then
            if self.Config.Walk then
                Runtime:MoveTo(getPosition(target), self, self.Config)
                return true, "Walking to " .. target.Name
            end
            return false, "Nearest target is " .. math.floor(distance) .. " studs away"
        end
        if self.Config.ToolTokens then Runtime:EquipTool(Runtime:FindTool(self.Config.ToolTokens)) end
        local cooldown = self.Config.ActionCooldown or 0.45
        if os.clock() - (self.LastAction or 0) < cooldown then
            return true, "Target detected — interaction cooling down"
        end
        local ok, detail = Runtime:Interact(target, self, {Priority = self.Config.ActionPriority or 55, Duration = self.Config.ActionCooldown or 0.45})
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
    local found
    forEachIndexed("Gui", classes or {"GuiObject"}, function(instance)
        if classAllowed(instance, classes or {"GuiObject"}) and isVisibleGui(instance)
            and containsAny(instanceText(instance), tokens)
        then
            found = instance
            return false
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
        or string.find(text, "movement forbidden", 1, true)
    then
        return "Red"
    end
    if string.find(text, "green light", 1, true) or string.find(text, "you may move", 1, true)
        or string.find(text, "movement allowed", 1, true)
    then
        return "Green"
    end
    return nil
end

local function contextualStatusWord(value, context)
    local state = statusWord(value)
    if state then return state end
    if not containsAny(context, {"light", "rlgl", "doll", "younghee", "mugunghwa", "signal", "phase", "round state"}) then
        return nil
    end
    local text = lower(value)
    if text == "stop" or text == "freeze" or text == "false" or text == "0" then return "Red" end
    if text == "go" or text == "move" or text == "true" or text == "1" then return "Green" end
    return nil
end

local function discoverRLGLSignals()
    local candidates = {}
    local likelyNames = {"light", "status", "state", "phase", "signal", "current", "red", "green"}
    for _, scope in ipairs({"Workspace", "ReplicatedStorage"}) do
        forEachIndexed(scope, {"ValueBase"}, function(instance)
            if containsAny(instance.Name, likelyNames) then
                table.insert(candidates, instance)
            end
            return true
        end)
    end
    local player = getLocalPlayer()
    local gui = player and player:FindFirstChildOfClass("PlayerGui")
    if gui then
        forEachIndexed("Gui", {"TextLabel", "TextButton"}, function(instance)
            local context = instanceText(instance)
            if containsAny(context, likelyNames) or statusWord(instance.Text) then
                table.insert(candidates, instance)
            end
            return true
        end)
    end
    Runtime._RLGLSignalCandidates = candidates
    Runtime._RLGLSignalsScannedAt = os.clock()
    return candidates
end

local function findStatusText(tokens)
    local now = os.clock()
    local cached = Runtime._StatusTextCache
    if cached and now - cached.Time < 0.08 then return cached.Value, cached.Instance end

    local candidates = Runtime._RLGLSignalCandidates
    if not candidates or now - (Runtime._RLGLSignalsScannedAt or 0) > 2.0 then
        candidates = discoverRLGLSignals()
    end

    -- Vote across every live signal instead of trusting whichever object happens
    -- to be returned first. When old red/green labels are both still present, a
    -- tie becomes Unknown, which is safer than moving or applying recovery input.
    local scores = {Red = 0, Green = 0}
    local bestInstance = {Red = nil, Green = nil}
    local bestWeight = {Red = 0, Green = 0}
    local liveCount = 0
    for _, instance in ipairs(candidates) do
        if instance and instance.Parent then
            liveCount = liveCount + 1
            local state, weight
            if instance:IsA("ValueBase") then
                local context = instanceText(instance)
                state = statusWord(instance.Value)
                weight = state and 7 or 0
                if not state then
                    state = contextualStatusWord(instance.Value, context)
                    weight = state and 4 or 0
                end
                if instance:IsA("BoolValue") then
                    local name = lower(instance.Name)
                    if string.find(name, "red", 1, true) then
                        state, weight = instance.Value and "Red" or "Green", 8
                    elseif string.find(name, "green", 1, true) then
                        state, weight = instance.Value and "Green" or "Red", 8
                    end
                end
            elseif isVisibleGui(instance) then
                state = statusWord(instance.Text)
                weight = state and 6 or 0
                if not state then
                    state = contextualStatusWord(instance.Text, instanceText(instance))
                    weight = state and 3 or 0
                end
            end
            if state and weight and weight > 0 then
                scores[state] = scores[state] + weight
                if weight > bestWeight[state] then
                    bestWeight[state] = weight
                    bestInstance[state] = instance
                end
            end
        end
    end

    if liveCount == 0 or now - (Runtime._RLGLSignalsScannedAt or 0) > 0.75 then
        Runtime._RLGLSignalCandidates = nil
    end

    local value, instance
    local margin = math.abs(scores.Red - scores.Green)
    if scores.Red >= 4 and scores.Red > scores.Green and margin >= 2 then
        value, instance = "Red", bestInstance.Red
    elseif scores.Green >= 4 and scores.Green > scores.Red and margin >= 2 then
        value, instance = "Green", bestInstance.Green
    end
    Runtime._StatusTextCache = {Time = now, Value = value, Instance = instance}
    return value, instance
end

function Runtime:GetRLGLState()
    local candidate = findStatusText({"light", "status", "state"})
    local now = os.clock()
    if candidate ~= self._RLGLCandidate then
        self._RLGLCandidate = candidate
        self._RLGLCandidateAt = now
    end
    if candidate and now - (self._RLGLCandidateAt or now) >= 0.10 then
        self._RLGLStableState = candidate
    elseif not candidate and now - (self._RLGLCandidateAt or now) >= 0.35 then
        self._RLGLStableState = nil
    end
    return self._RLGLStableState
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

local function startAutoJump(feature)
    feature:_Loop(feature.Config.Interval or 0.06, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        local target, distance = Runtime:FindNearest({
            Scope = "Workspace",
            TargetTokens = self.Config.TargetTokens or {"rope", "bar", "swing"},
            TargetClasses = {"BasePart", "Model"},
            ReturnAdornee = true,
        }, root.Position)
        if target and distance <= (self.Config.TriggerDistance or 14) then
            humanoid.Jump = true
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            return true, "Jumped for the approaching obstacle"
        end
        return false, "Waiting for the rope or obstacle"
    end)
end

local function startRopeBypass(feature)
    feature.OriginalCanTouch = {}
    feature:_Loop(feature.Config.Interval or 0.8, function(self)
        local parts = Runtime:FindTargets({
            Scope = "Workspace",
            TargetTokens = self.Config.TargetTokens or {"rope", "swing", "bar"},
            TargetClasses = {"BasePart"},
            MaxTargets = 80,
        })
        for _, part in ipairs(parts) do
            if self.OriginalCanTouch[part] == nil then self.OriginalCanTouch[part] = part.CanTouch end
            part.CanTouch = false
        end
        self.Restore = function(current)
            for part, value in pairs(current.OriginalCanTouch or {}) do
                if part.Parent then part.CanTouch = value end
            end
            current.OriginalCanTouch = {}
        end
        return #parts > 0, #parts > 0 and ("Disabled touch on " .. #parts .. " rope part(s)") or "Waiting for rope collision parts"
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
    local player = getLocalPlayer()
    local gui = player and player:FindFirstChildOfClass("PlayerGui")
    if not gui then return nil end
    local required
    forEachIndexed("Gui", {"TextLabel", "TextButton"}, function(instance)
        if isVisibleGui(instance) then
            local context = instanceText(instance)
            if containsAny(context, {"required", "players", "group", "room", "mingle", "number"}) then
                local number = tonumber(string.match(instance.Text or "", "%d+"))
                if number and number >= 1 and number <= 20 then
                    required = number
                    return false
                end
            end
        end
        return true
    end)
    return required
end

local function startRoomAssist(feature)
    feature:_Loop(feature.Config.Interval or 0.45, function(self)
        local count = parseRequiredCount()
        if not count then return false, "Waiting for the required Mingle room count" end
        local _, _, _, root = getCharacter()
        if not root then return false, "Waiting for the local character" end
        local movementAvailable, movementOwner = Runtime:CanUseMovement(self, self.Config.MovementPriority or 60)
        if not movementAvailable then return false, "Movement is currently controlled by " .. tostring(movementOwner) end
        local candidates = Runtime:FindTargets({
            Scope = "Workspace",
            TargetTokens = {"room", "door", "mingle"},
            TargetClasses = {"Model", "BasePart", "ProximityPrompt"},
            MaxTargets = 160,
        })
        local best, bestDistance = nil, math.huge
        for _, target in ipairs(candidates) do
            local text = instanceText(target)
            local capacityMatch = string.find(text, tostring(count), 1, true)
            local capacity = target:FindFirstChild("Capacity", true)
            if capacity and tonumber(capacity.Value) == count then capacityMatch = true end
            local position = getPosition(target)
            if capacityMatch and position then
                local distance = (position - root.Position).Magnitude
                if distance < bestDistance then best, bestDistance = target, distance end
            end
        end
        if not best then return false, "No room matching capacity " .. count .. " was detected" end
        local position = getPosition(best)
        local moved, detail = Runtime:MoveTo(position, self, {
            StopDistance = 7,
            MaxWaypoints = 4,
            MovementPriority = self.Config.MovementPriority or 60,
            HoldLeaseAtTarget = 0.75,
        })
        local _, _, _, currentRoot = getCharacter()
        if self.Config.Interact and currentRoot and (currentRoot.Position - position).Magnitude <= 10 then
            Runtime:Interact(best, self, {Priority = self.Config.ActionPriority or 60, Duration = self.Config.ActionCooldown or 0.6})
        end
        return moved, moved and ("Heading to a room for " .. count .. " player(s)") or detail
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
        if not guardNearby then return false, "No nearby guard detected" end
        local tool = Runtime:FindTool(self.Config.ToolTokens or {"disguise", "uniform", "mask"})
        if not tool then return false, "Disguise tool not found" end
        Runtime:EquipTool(tool)
        local claimed = Runtime:ClaimAction(self, "ToolAction", self.Config.ActionPriority or 55, 0.6)
        if not claimed then return false, "Another tool action is active" end
        pcall(tool.Activate, tool)
        return true, "Disguise equipped because a guard is nearby"
    end)
end


local function startToolActivate(feature)
    feature:_Loop(feature.Config.Interval or 0.45, function(self)
        local ok, detail = Runtime:ActivateTool(self.Config.ToolTokens or {}, self, {
            Resource = "ToolAction",
            Priority = self.Config.ActionPriority or 45,
            Duration = math.max(self.Config.Interval or 0.45, 0.3),
        })
        return ok, ok and "Activated the matching tool" or detail
    end)
end

local function startGuiHighlight(feature)
    feature.GuiStrokes = {}
    feature:_Loop(feature.Config.Interval or 0.7, function(self)
        local player = getLocalPlayer()
        local gui = player and player:FindFirstChildOfClass("PlayerGui")
        if not gui then return false, "Waiting for PlayerGui" end
        local count = 0
        forEachIndexed("Gui", {"GuiObject"}, function(instance)
            if isVisibleGui(instance)
                and containsAny(instanceText(instance), self.Config.TargetTokens or {"shape", "cookie", "trace", "path"})
            then
                local stroke = self.GuiStrokes[instance]
                if not stroke or not stroke.Parent then
                    stroke = Instance.new("UIStroke")
                    stroke.Name = "SquidNoMo_" .. self.Id
                    stroke.Color = self.Config.Color or Color3.fromRGB(42, 255, 126)
                    stroke.Thickness = self.Config.Thickness or 3
                    stroke.Transparency = self.Config.Transparency or 0.05
                    stroke.Parent = instance
                    self.GuiStrokes[instance] = stroke
                    self:_TrackInstance(stroke)
                end
                count = count + 1
                if count >= (self.Config.MaxTargets or 12) then return false end
            end
            return true
        end)
        return count > 0, count > 0 and ("Highlighted " .. count .. " interface element(s)") or self.Config.WaitingMessage
    end)
end

local function startStateHUD(feature)
    local parent
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok then parent = result end
    end
    parent = parent or game:GetService("CoreGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "SquidNoMo_StateHUD_" .. feature.Id
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999990
    gui.Parent = parent
    feature:_TrackInstance(gui)

    local label = Instance.new("TextLabel")
    label.AnchorPoint = Vector2.new(0.5, 0)
    label.Position = UDim2.new(0.5, 0, 0, 78)
    label.Size = UDim2.fromOffset(260, 44)
    label.BackgroundColor3 = Color3.fromRGB(14, 18, 24)
    label.BackgroundTransparency = 0.12
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(235, 240, 245)
    label.TextSize = 18
    label.Text = "WAITING FOR GAME STATE"
    label.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = label

    feature:_Loop(feature.Config.Interval or 0.12, function(self)
        local value = Runtime:GetRLGLState()
        if not value then
            label.Text = "WAITING FOR CLEAR LIGHT SIGNAL"
            label.TextColor3 = Color3.fromRGB(210, 215, 220)
            return false, "Waiting for an unambiguous red/green signal"
        end
        label.Text = string.upper(value) .. " LIGHT"
        label.TextColor3 = value == "Red"
            and Color3.fromRGB(255, 94, 94)
            or Color3.fromRGB(65, 255, 126)
        return true, "Displaying verified " .. string.lower(value) .. " light state"
    end)
end

local function startAntiStuck(feature)
    feature.LastPosition = nil
    feature.StuckSince = os.clock()
    feature:_Loop(feature.Config.Interval or 0.35, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        local state = Runtime:GetRLGLState()
        if state ~= "Green" then
            Runtime:StopMovement(self)
            self.LastPosition = root.Position
            self.StuckSince = os.clock()
            return false, state == "Red" and "Paused during red light" or "Waiting for a verified green light"
        end

        local moving = humanoid.MoveDirection.Magnitude > 0.05
        if not self.LastPosition then
            self.LastPosition = root.Position
            self.StuckSince = os.clock()
            return true, "Monitoring green-light movement"
        end
        local moved = (root.Position - self.LastPosition).Magnitude
        if moving and moved < (self.Config.MinimumMovement or 0.25) then
            if os.clock() - self.StuckSince >= (self.Config.StuckSeconds or 2.2) then
                local claimed = Runtime:ClaimMovement(self, 80, 0.35)
                if claimed then
                    humanoid.Jump = true
                    pcall(humanoid.MoveTo, humanoid, root.Position + root.CFrame.LookVector * (self.Config.RecoveryDistance or 5))
                end
                self.StuckSince = os.clock()
                self.LastPosition = root.Position
                return true, claimed and "Applied one green-light recovery step" or "Auto Move currently owns movement"
            end
        else
            self.StuckSince = os.clock()
            self.LastPosition = root.Position
        end
        return true, "Monitoring green-light movement"
    end)
end

local function startJumpBoost(feature)
    local _, _, humanoid = getCharacter()
    if not humanoid then
        feature:_SetStatus("Waiting", "Waiting for the local character")
    end
    feature.OriginalJumpPower = humanoid and humanoid.JumpPower or nil
    feature.OriginalJumpHeight = humanoid and humanoid.JumpHeight or nil
    feature.Restore = function(self)
        local _, _, current = getCharacter()
        if current then
            if self.OriginalJumpPower then current.JumpPower = self.OriginalJumpPower end
            if self.OriginalJumpHeight then current.JumpHeight = self.OriginalJumpHeight end
        end
    end
    feature:_Loop(feature.Config.Interval or 0.5, function(self)
        local _, _, current = getCharacter()
        if not current then return false, "Waiting for the local character" end
        if current.UseJumpPower then
            local wanted = self.Config.JumpPower or 72
            if math.abs(current.JumpPower - wanted) > 0.01 then current.JumpPower = wanted end
        else
            local wanted = self.Config.JumpHeight or 12
            if math.abs(current.JumpHeight - wanted) > 0.01 then current.JumpHeight = wanted end
        end
        return true, "Jump strength increased"
    end)
end


local function getGuiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    return game:GetService("CoreGui")
end

local function startRadar(feature)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SquidNoMo_Radar_" .. feature.Id
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999985
    gui.Parent = getGuiParent()
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

        for target, dot in pairs(feature.RadarDots) do
            if not seen[target] or not target.Parent then
                dot.Visible = false
            end
        end
        return count > 0, count > 0 and ("Radar tracking " .. count .. " target(s)") or "Waiting for radar targets"
    end)
end

local function startCourseAssist(feature)
    feature:_Loop(feature.Config.Interval or 0.18, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        local movementAvailable, movementOwner = Runtime:CanUseMovement(self, self.Config.MovementPriority or 65)
        if not movementAvailable then return false, "Movement is currently controlled by " .. tostring(movementOwner) end

        local rope, ropeDistance = Runtime:FindNearest({
            Scope = "Workspace",
            TargetTokens = self.Config.ObstacleTokens or {"rope", "swing", "bar"},
            TargetClasses = {"BasePart", "Model"},
            ReturnAdornee = true,
            MaxTargets = 80,
        }, root.Position)

        if rope and ropeDistance <= (self.Config.JumpDistance or 16) then
            humanoid.Jump = true
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        local finish = Runtime:FindNearest({
            Scope = "Workspace",
            TargetTokens = self.Config.TargetTokens or {"finish", "end", "goal", "exit"},
            ExcludeTokens = {"start", "spawn"},
            TargetClasses = {"BasePart", "Model", "ProximityPrompt"},
            ReturnAdornee = true,
            MaxTargets = 100,
        }, root.Position)

        local position = getPosition(finish)
        if not position then
            return rope ~= nil, rope and "Jumping for the detected rope" or self.Config.WaitingMessage
        end

        local moved, detail = Runtime:MoveTo(position, self, {
            StopDistance = self.Config.StopDistance or 7,
            MaxWaypoints = self.Config.MaxWaypoints or 3,
            WaypointTimeout = self.Config.WaypointTimeout or 0.8,
            MovementPriority = self.Config.MovementPriority or 65,
        })
        return moved, moved and "Advancing toward the course finish" or detail
    end)
end

local function startPositionKeeper(feature)
    local _, _, _, initialRoot = getCharacter()
    feature.AnchorPosition = initialRoot and initialRoot.Position or nil
    feature:_Loop(feature.Config.Interval or 0.25, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        if not self.AnchorPosition then
            self.AnchorPosition = root.Position
            return true, "Saved the preferred position"
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

local function glassSafety(part)
    for _, attributeName in ipairs({"Safe", "IsSafe", "Correct", "Real", "CanStand"}) do
        local ok, value = pcall(part.GetAttribute, part, attributeName)
        if ok and type(value) == "boolean" then
            return value
        end
    end
    local parent = part.Parent
    if parent then
        for _, valueName in ipairs({"Safe", "IsSafe", "Correct", "Real"}) do
            local value = parent:FindFirstChild(valueName)
            if value and value:IsA("BoolValue") then
                return value.Value
            end
        end
    end
    if part.CanCollide == false then return false end
    if part.Transparency > 0.7 then return false end
    return nil
end

local function glassParts()
    local now = os.clock()
    local cache = Runtime._GlassPartsCache
    if cache and now - cache.Time < 2.0 then
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
        CacheTTL = 2.0,
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
        local best, bestDistance = nil, math.huge
        local fallback, fallbackDistance = nil, math.huge
        for _, part in ipairs(glassParts()) do
            local distance = (part.Position - root.Position).Magnitude
            if distance > (self.Config.MinimumDistance or 2) and distance < (self.Config.MaximumDistance or 55) then
                local safe = glassSafety(part)
                if safe == true and distance < bestDistance then
                    best, bestDistance = part, distance
                elseif safe == nil and distance < fallbackDistance then
                    fallback, fallbackDistance = part, distance
                end
            end
        end
        local target = best or fallback
        if not target then return false, self.Config.WaitingMessage or "Waiting for bridge glass panels" end
        local moved, detail = Runtime:MoveTo(target.Position + Vector3.new(0, 2.5, 0), self, {
            StopDistance = 4,
            MaxWaypoints = 2,
            WaypointTimeout = 0.75,
            MovementPriority = self.Config.MovementPriority or 70,
        })
        local confidence = best and "verified safe" or "best available"
        return moved, moved and ("Walking to " .. confidence .. " panel") or detail
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

        if self.Config.RequireToolTokens and #self.Config.RequireToolTokens > 0 and not heldTool then
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

        local target, distance = Runtime:FindNearest({
            Scope = self.Config.Scope or "Workspace",
            TargetTokens = targetConfig.TargetTokens,
            TargetNames = targetConfig.TargetNames,
            ExcludeTokens = targetConfig.ExcludeTokens,
            TargetClasses = {"Model", "BasePart", "ProximityPrompt", "ClickDetector"},
            MaxTargets = 160,
        }, root.Position)

        if not target then
            return false, "Waiting for " .. stageName
        end

        if distance > (self.Config.InteractDistance or 12) then
            local moved, detail = Runtime:MoveTo(getPosition(target), self, {
                StopDistance = self.Config.InteractDistance or 10,
                MaxWaypoints = 4,
                WaypointTimeout = 1.0,
                MovementPriority = self.Config.MovementPriority or 60,
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
    ["Red Light, Green Light"] = {"red light", "green light", "younghee", "mugunghwa", "rlgl"},
    ["Dalgona"] = {"dalgona", "honeycomb", "trace shape"},
    ["Pentathlon"] = {"pentathlon", "ddakji", "gonggi", "jegichagi", "paengi", "biseokchigi"},
    ["Hide & Seek"] = {"hide and seek", "hide & seek", "key room"},
    ["Jump Rope"] = {"jump rope", "jumprope", "swinging rope"},
    ["Marbles"] = {"marbles", "marble game", "ring shooter"},
    ["Mingle"] = {"mingle", "players per room", "find a room"},
    ["Fight Nights"] = {"night brawl", "fight night", "lights out"},
    ["Glass Bridge"] = {"glass bridge", "glass stepping", "bridge panels"},
    ["Rebellion"] = {"rebellion", "armory", "uprising"},
    ["Rock, Paper, Scissors Minus One"] = {"rock paper scissors", "minus one", "rps"},
    ["Sky Squid"] = {"sky squid", "sky game", "floating platform"},
    ["Squid Game"] = {"squid game court", "squid court", "final squid game"},
    ["Tug of War"] = {"tug of war", "tugofwar", "pull meter"},
    ["Escape"] = {"escape island", "escape route", "island escape", "extraction boat"},
}

function Runtime:DetectGameCategory()
    local now = os.clock()
    if self._GameDetectionCache and now - self._GameDetectionCache.Time < 1.5 then
        return self._GameDetectionCache.Name, self._GameDetectionCache.Score
    end

    local evidence = {}
    local function addEvidence(value, weight)
        local text = lower(value)
        if text ~= "" then
            table.insert(evidence, {Text = text, Weight = tonumber(weight) or 1})
        end
    end

    addEvidence(Workspace.Name, 1)
    addEvidence(ReplicatedStorage.Name, 1)

    for _, root in ipairs({Workspace, ReplicatedStorage}) do
        for attributeName, attributeValue in pairs(root:GetAttributes()) do
            if containsAny(attributeName, {"game", "round", "mode", "phase", "state", "current"}) then
                addEvidence(attributeName .. " " .. tostring(attributeValue), 7)
            end
        end

        local scanned = 0
        local scope = root == Workspace and "Workspace" or "ReplicatedStorage"
        forEachIndexed(scope, {"Folder", "Model", "ValueBase"}, function(instance)
            if scanned >= 240 then return false end
            if instance:IsA("ValueBase") then
                local context = instanceText(instance)
                local weight = containsAny(context, {"current game", "current round", "game mode", "round name", "phase", "round state"}) and 7 or 2
                addEvidence(context .. " " .. tostring(instance.Value), weight)
            else
                -- Static map folders are weak evidence because many experiences keep
                -- every minigame map loaded at the same time.
                addEvidence(instanceText(instance), 1)
            end
            for attributeName, attributeValue in pairs(instance:GetAttributes()) do
                if containsAny(attributeName, {"game", "round", "mode", "phase", "state", "current"}) then
                    addEvidence(attributeName .. " " .. tostring(attributeValue), 6)
                end
            end
            scanned = scanned + 1
            return true
        end)
    end

    local player = getLocalPlayer()
    local gui = player and player:FindFirstChildOfClass("PlayerGui")
    if gui then
        local added = 0
        forEachIndexed("Gui", {"TextLabel", "TextButton"}, function(instance)
            if added >= 100 then return false end
            if isVisibleGui(instance) then
                local text = lower(instance.Text)
                if text ~= "" then
                    addEvidence(text .. " " .. instanceText(instance), 5)
                    added = added + 1
                end
            end
            return true
        end)
    end

    local ranked = {}
    for name, tokens in pairs(GameProfiles) do
        local score, strong, hits = 0, false, 0
        for _, token in ipairs(tokens) do
            local best = 0
            local specificity = string.find(token, " ", 1, true) and 2 or 1
            for _, item in ipairs(evidence) do
                if string.find(item.Text, token, 1, true) then
                    best = math.max(best, item.Weight * specificity)
                end
            end
            if best > 0 then
                score = score + best
                hits = hits + 1
                if best >= 5 then strong = true end
            end
        end
        table.insert(ranked, {Name = name, Score = score, Strong = strong, Hits = hits})
    end
    table.sort(ranked, function(a, b)
        if a.Score == b.Score then return a.Name < b.Name end
        return a.Score > b.Score
    end)

    local best, second = ranked[1], ranked[2]
    local bestName, bestScore = nil, best and best.Score or 0
    if best and bestScore >= 5 and (best.Strong or best.Hits >= 3)
        and (not second or bestScore - second.Score >= 2)
    then
        bestName = best.Name
    end

    self._GameDetectionCache = {
        Time = now,
        Name = bestName,
        Score = bestScore,
        RunnerUp = second and second.Name or nil,
    }
    return bestName, bestScore
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
    RopeBypass = startRopeBypass,
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
