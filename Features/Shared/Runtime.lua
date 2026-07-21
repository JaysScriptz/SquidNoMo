-- SquidNoMo feature runtime
-- SquidNoMo feature revision: 1.1b1-feature-recode-r2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Runtime = {
    Revision = "1.1b1-feature-recode-r2",
}

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end
Environment.__SquidNoMoFeatureRuntime = Runtime

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

local function instanceText(instance)
    if not instance then return "" end
    local parts = {instance.Name, instance.ClassName}
    local current = instance.Parent
    local depth = 0
    while current and depth < 3 do
        table.insert(parts, current.Name)
        current = current.Parent
        depth = depth + 1
    end
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        table.insert(parts, instance.Text)
    end
    local ok, actionText = pcall(function()
        return instance:IsA("ProximityPrompt") and instance.ActionText or nil
    end)
    if ok and actionText then table.insert(parts, actionText) end
    return lower(table.concat(parts, " "))
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

local function getScopeRoots(scope)
    local roots = {}
    scope = lower(scope)
    if scope == "gui" then
        local player = getLocalPlayer()
        if player then
            local gui = player:FindFirstChildOfClass("PlayerGui")
            if gui then table.insert(roots, gui) end
        end
    elseif scope == "replicatedstorage" or scope == "remotes" then
        table.insert(roots, ReplicatedStorage)
    elseif scope == "both" then
        table.insert(roots, Workspace)
        local player = getLocalPlayer()
        if player then
            local gui = player:FindFirstChildOfClass("PlayerGui")
            if gui then table.insert(roots, gui) end
        end
    else
        table.insert(roots, Workspace)
    end
    return roots
end

local function isVisibleGui(instance)
    if not instance:IsA("GuiObject") then return false end
    if not instance.Visible then return false end
    local current = instance.Parent
    while current do
        if current:IsA("GuiObject") and not current.Visible then return false end
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

function Runtime:FindTargets(config)
    local results = {}
    local seen = {}
    for _, root in ipairs(getScopeRoots(config.Scope)) do
        local candidates = root:GetDescendants()
        if self:Matches(root, config) then table.insert(candidates, 1, root) end
        for _, instance in ipairs(candidates) do
            if self:Matches(instance, config) then
                local target = config.ReturnAdornee and getAdornee(instance) or instance
                if target and not seen[target] then
                    seen[target] = true
                    table.insert(results, target)
                    if config.MaxTargets and #results >= config.MaxTargets then
                        return results
                    end
                end
            end
        end
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

function Runtime:ActivateTool(tokens)
    local tool = self:FindTool(tokens or {})
    if not tool then return false, "matching tool not found" end
    self:EquipTool(tool)
    local ok, err = pcall(tool.Activate, tool)
    return ok, ok and nil or tostring(err)
end

function Runtime:Interact(target)
    if not target then return false, "target not found" end
    local prompt = target:IsA("ProximityPrompt") and target
        or target:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and prompt.Enabled then
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

    local detector = target:IsA("ClickDetector") and target
        or target:FindFirstChildWhichIsA("ClickDetector", true)
    if detector and type(fireclickdetector) == "function" then
        local ok, err = pcall(fireclickdetector, detector)
        return ok, ok and nil or tostring(err)
    end

    local touchPart = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart", true)
    local _, _, _, root = getCharacter()
    if touchPart and root and type(firetouchinterest) == "function" then
        local ok, err = pcall(function()
            firetouchinterest(root, touchPart, 0)
            task.wait()
            firetouchinterest(root, touchPart, 1)
        end)
        return ok, ok and nil or tostring(err)
    end
    return false, "no supported prompt, click detector, or touch target"
end

function Runtime:MoveTo(position, feature, options)
    options = options or {}
    local _, _, humanoid, root = getCharacter()
    if not humanoid or not root then return false, "character is not ready" end
    if not position then return false, "target has no position" end

    local stopDistance = tonumber(options.StopDistance) or 5
    if (root.Position - position).Magnitude <= stopDistance then return true end

    local path = PathfindingService:CreatePath({
        AgentRadius = tonumber(options.AgentRadius) or 2,
        AgentHeight = tonumber(options.AgentHeight) or 5,
        AgentCanJump = true,
        WaypointSpacing = tonumber(options.WaypointSpacing) or 5,
    })
    local ok = pcall(path.ComputeAsync, path, root.Position, position)
    if ok and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        local limit = math.min(#waypoints, tonumber(options.MaxWaypoints) or 5)
        for index = 2, limit do
            if feature and not feature.Enabled then return false, "disabled" end
            local waypoint = waypoints[index]
            if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
            humanoid:MoveTo(waypoint.Position)
            local reached = false
            local connection
            connection = humanoid.MoveToFinished:Connect(function(value)
                reached = value
            end)
            local started = os.clock()
            while feature and feature.Enabled and os.clock() - started < (options.WaypointTimeout or 1.6) do
                if reached then break end
                task.wait(0.05)
            end
            if connection then connection:Disconnect() end
            if (root.Position - position).Magnitude <= stopDistance then return true end
        end
        return (root.Position - position).Magnitude <= stopDistance * 2
    end

    humanoid:MoveTo(position)
    task.wait(tonumber(options.FallbackWait) or 0.35)
    return (root.Position - position).Magnitude <= stopDistance * 2, "path unavailable; used MoveTo fallback"
end

function Runtime:ClickGui(target)
    if not target then return false, "GUI target not found" end
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
    self.Status = tostring(state or "Unknown")
    self.StatusDetail = tostring(detail or "")
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
    self:_Spawn(function()
        while self.Enabled do
            local ok, active, detail = pcall(callback, self)
            if not ok then
                error(active)
            elseif active then
                self:_SetStatus("Active", detail or "Working")
            else
                self:_SetStatus("Waiting", detail or self.Config.WaitingMessage or "Waiting for the matching game objects")
            end
            task.wait(interval or self.Config.Interval or 0.5)
        end
    end)
end

function FeatureMethods:_Clear()
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
        if self.Config.RequireToolTokens and not Runtime:FindTool(self.Config.RequireToolTokens) then
            return false, "Waiting for " .. table.concat(self.Config.RequireToolTokens, "/") .. " tool"
        end
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
                local interacted, interactDetail = Runtime:Interact(target)
                if interacted then
                    task.wait(self.Config.ActionCooldown or 0.8)
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
        if self.Config.ToolTokens and not Runtime:FindTool(self.Config.ToolTokens) then
            return false, "Waiting for " .. table.concat(self.Config.ToolTokens, "/") .. " tool"
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
        local ok, detail = Runtime:Interact(target)
        if ok then task.wait(self.Config.ActionCooldown or 0.45) end
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
        for _, instance in ipairs(Workspace:GetDescendants()) do
            if instance:IsA("Model") and not Players:GetPlayerFromCharacter(instance) then
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
        local ok, detail = Runtime:ActivateTool(self.Config.ToolTokens or {})
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
    for _, instance in ipairs(gui:GetDescendants()) do
        if classAllowed(instance, classes or {"GuiObject"}) and isVisibleGui(instance)
            and containsAny(instanceText(instance), tokens)
        then
            return instance
        end
    end
    return nil
end

local function startTiming(feature)
    feature:_Loop(feature.Config.Interval or 0.03, function(self)
        local indicator = findVisibleGui(self.Config.IndicatorTokens or {"indicator", "pointer", "cursor", "needle"})
        local zone = findVisibleGui(self.Config.ZoneTokens or {"sweetspot", "sweet spot", "safezone", "safe zone", "bluezone", "greenzone", "target"})
        if indicator and zone and rectsOverlap(indicator, zone) then
            if os.clock() - self.LastAction >= (self.Config.ActionCooldown or 0.35) then
                self.LastAction = os.clock()
                local action = findVisibleGui(self.Config.ActionTokens or {"pull", "throw", "hit", "play", "tap", "button"}, {"GuiButton"})
                local ok, detail = Runtime:ClickGui(action or indicator)
                return ok, ok and "Pressed at the target timing zone" or detail
            end
            return true, "Timing zone detected"
        end
        local action = findVisibleGui(self.Config.ActionTokens or {}, {"GuiButton"})
        if self.Config.ClickActionWhenVisible and action and os.clock() - self.LastAction >= (self.Config.ActionCooldown or 0.5) then
            self.LastAction = os.clock()
            local ok, detail = Runtime:ClickGui(action)
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
        self.LastAction = os.clock()
        local ok, detail = Runtime:ClickGui(action)
        return ok, ok and ("Pressed " .. action.Name) or detail
    end)
end

local function startAntiFall(feature)
    feature.SafeCFrame = nil
    feature:_TrackConnection(RunService.Heartbeat:Connect(function()
        if not feature.Enabled then return end
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then
            feature:_SetStatus("Waiting", "Waiting for the local character")
            return
        end
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local _, character = getCharacter()
        rayParams.FilterDescendantsInstances = character and {character} or {}
        local hit = Workspace:Raycast(root.Position, Vector3.new(0, -8, 0), rayParams)
        if hit and humanoid.FloorMaterial ~= Enum.Material.Air then
            feature.SafeCFrame = root.CFrame
            feature:_SetStatus("Active", "Safe position tracked")
        elseif feature.SafeCFrame and (root.Position.Y < feature.SafeCFrame.Position.Y - (feature.Config.DropDistance or 18)
            or root.AssemblyLinearVelocity.Y < -(feature.Config.FallVelocity or 75)) then
            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = feature.SafeCFrame + Vector3.new(0, 2.5, 0)
            feature:_SetStatus("Active", "Recovered from a fall")
        else
            feature:_SetStatus("Active", "Monitoring fall state")
        end
    end))
end

local function findStatusText(tokens)
    for _, root in ipairs({Workspace, ReplicatedStorage}) do
        for _, instance in ipairs(root:GetDescendants()) do
            if containsAny(instanceText(instance), tokens or {"status", "state", "light"}) then
                if instance:IsA("StringValue") or instance:IsA("BoolValue") or instance:IsA("IntValue") or instance:IsA("NumberValue") then
                    return tostring(instance.Value), instance
                end
            end
        end
    end
    local guiValue = findVisibleGui(tokens or {"red light", "green light", "stop", "go"}, {"TextLabel", "TextButton"})
    if guiValue then return guiValue.Text, guiValue end
    return nil, nil
end

local function isRedLight()
    local text = lower((findStatusText({"status", "light", "red", "green"})))
    return containsAny(text, {"red", "stop", "freeze"}) and not containsAny(text, {"green", "go"})
end

local function startRLGLAutoMove(feature)
    feature:_Loop(feature.Config.Interval or 0.16, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        if isRedLight() then
            humanoid:MoveTo(root.Position)
            return true, "Red light detected — stopped"
        end
        local target = Runtime:FindNearest({
            Scope = "Workspace",
            TargetTokens = self.Config.TargetTokens or {"finish", "end zone", "safe zone", "goal"},
            ExcludeTokens = {"start"},
            TargetClasses = {"BasePart", "Model"},
            ReturnAdornee = true,
        }, root.Position)
        if not target then
            target = Runtime:FindNearest({
                Scope = "Workspace",
                TargetTokens = {"doll", "mugunghwa", "killer"},
                TargetClasses = {"Model", "BasePart"},
                ReturnAdornee = true,
            }, root.Position)
        end
        local position = getPosition(target)
        if not position then return false, "Waiting for the RLGL finish area or doll" end
        local moved, detail = Runtime:MoveTo(position, self, {StopDistance = 8, MaxWaypoints = 3, WaypointTimeout = 0.7})
        return moved, moved and "Green light detected — advancing" or detail
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
        local target, distance = nearestCharacter(self.Config, root.Position)
        if not target or distance > (self.Config.Range or 20) then return false, "No nearby threat detected" end
        local targetRoot = target:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return false, "Threat has no root part" end
        local direction = root.Position - targetRoot.Position
        if direction.Magnitude < 0.1 then direction = root.CFrame.RightVector end
        humanoid:MoveTo(root.Position + direction.Unit * (self.Config.EvadeDistance or 18))
        return true, "Moving away from " .. target.Name
    end)
end

local function startBoundary(feature)
    feature:_Loop(feature.Config.Interval or 0.35, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
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
            humanoid:MoveTo(position)
            return true, "Returning to the active play area"
        end
        return true, "Inside the active play area"
    end)
end

local function parseRequiredCount()
    local player = getLocalPlayer()
    local gui = player and player:FindFirstChildOfClass("PlayerGui")
    if not gui then return nil end
    for _, instance in ipairs(gui:GetDescendants()) do
        if (instance:IsA("TextLabel") or instance:IsA("TextButton")) and isVisibleGui(instance) then
            local context = instanceText(instance)
            if containsAny(context, {"required", "players", "group", "room", "mingle", "number"}) then
                local number = tonumber(string.match(instance.Text or "", "%d+"))
                if number and number >= 1 and number <= 20 then return number end
            end
        end
    end
    return nil
end

local function startRoomAssist(feature)
    feature:_Loop(feature.Config.Interval or 0.45, function(self)
        local count = parseRequiredCount()
        if not count then return false, "Waiting for the required Mingle room count" end
        local _, _, _, root = getCharacter()
        if not root then return false, "Waiting for the local character" end
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
        local moved = Runtime:MoveTo(position, self, {StopDistance = 7, MaxWaypoints = 4})
        if self.Config.Interact and moved then Runtime:Interact(best) end
        return true, "Heading to a room for " .. count .. " player(s)"
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
        local ok, detail = Runtime:ActivateTool(self.Config.ToolTokens or {})
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
        pcall(tool.Activate, tool)
        return true, "Disguise equipped because a guard is nearby"
    end)
end


local function startToolActivate(feature)
    feature:_Loop(feature.Config.Interval or 0.45, function(self)
        local ok, detail = Runtime:ActivateTool(self.Config.ToolTokens or {})
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
        for _, instance in ipairs(gui:GetDescendants()) do
            if instance:IsA("GuiObject") and isVisibleGui(instance)
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
                if count >= (self.Config.MaxTargets or 12) then break end
            end
        end
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

    feature:_Loop(feature.Config.Interval or 0.15, function(self)
        local value = findStatusText(self.Config.TargetTokens or {"status", "light", "state"})
        if not value then
            label.Text = "WAITING FOR GAME STATE"
            label.TextColor3 = Color3.fromRGB(210, 215, 220)
            return false, "Waiting for a game state value"
        end
        local text = string.upper(tostring(value))
        label.Text = text
        if containsAny(text, {"red", "stop", "freeze"}) then
            label.TextColor3 = Color3.fromRGB(255, 94, 94)
        elseif containsAny(text, {"green", "go", "move"}) then
            label.TextColor3 = Color3.fromRGB(65, 255, 126)
        else
            label.TextColor3 = Color3.fromRGB(255, 225, 110)
        end
        return true, "Displaying current game state"
    end)
end

local function startAntiStuck(feature)
    feature.LastPosition = nil
    feature.StuckSince = os.clock()
    feature:_Loop(feature.Config.Interval or 0.25, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end
        local moving = humanoid.MoveDirection.Magnitude > 0.05
        if not self.LastPosition then
            self.LastPosition = root.Position
            self.StuckSince = os.clock()
            return true, "Monitoring movement"
        end
        local moved = (root.Position - self.LastPosition).Magnitude
        if moving and moved < (self.Config.MinimumMovement or 0.35) then
            if os.clock() - self.StuckSince >= (self.Config.StuckSeconds or 1.5) then
                humanoid.Jump = true
                humanoid:MoveTo(root.Position + root.CFrame.LookVector * (self.Config.RecoveryDistance or 6))
                self.StuckSince = os.clock()
                self.LastPosition = root.Position
                return true, "Recovery movement applied"
            end
        else
            self.StuckSince = os.clock()
            self.LastPosition = root.Position
        end
        return true, "Monitoring movement"
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
            current.JumpPower = self.Config.JumpPower or 72
        else
            current.JumpHeight = self.Config.JumpHeight or 12
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

    feature:_TrackConnection(RunService.RenderStepped:Connect(function()
        if not feature.Enabled then return end
        local _, _, _, root = getCharacter()
        if not root then
            feature:_SetStatus("Waiting", "Waiting for the local character")
            return
        end

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
        feature:_SetStatus(count > 0 and "Active" or "Waiting", count > 0 and ("Radar tracking " .. count .. " target(s)") or "Waiting for radar targets")
    end))
end

local function startCourseAssist(feature)
    feature:_Loop(feature.Config.Interval or 0.18, function(self)
        local _, _, humanoid, root = getCharacter()
        if not humanoid or not root then return false, "Waiting for the local character" end

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
            humanoid:MoveTo(self.AnchorPosition)
            return true, "Returning to the preferred position"
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
    local results = {}
    for _, instance in ipairs(Workspace:GetDescendants()) do
        if instance:IsA("BasePart") and containsAny(instanceText(instance), {"glass", "panel", "tile", "bridge"}) then
            table.insert(results, instance)
        end
    end
    return results
end

local function startSafeTileWalk(feature)
    feature:_Loop(feature.Config.Interval or 0.35, function(self)
        local _, _, _, root = getCharacter()
        if not root then return false, "Waiting for the local character" end
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
            })
            return moved, moved and ("Walking to " .. stageName) or detail
        end

        local ok, detail = Runtime:Interact(target)
        if heldTool and type(heldTool.Activate) == "function" then
            pcall(heldTool.Activate, heldTool)
        end
        if ok then task.wait(self.Config.ActionCooldown or 0.8) end
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
        for _, instance in ipairs(gui:GetDescendants()) do
            if isVisibleGui(instance) then
                if instance:IsA("TextLabel") or instance:IsA("TextButton") then
                    visibleText = visibleText .. " " .. lower(instance.Text)
                end
                if instance:IsA("GuiButton") and containsAny(instanceText(instance), {"rock", "paper", "scissors"}) then
                    table.insert(buttons, instance)
                end
            end
        end
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
        local ok, detail = Runtime:ClickGui(selected)
        if not ok then return false, detail end

        task.wait(0.08)
        local submit = findVisibleGui({"submit", "confirm", "play", "lock", "choose"}, {"GuiButton"})
        if submit then Runtime:ClickGui(submit) end
        return true, "Selected " .. string.upper(wanted)
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
