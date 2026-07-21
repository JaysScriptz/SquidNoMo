-- SquidNoMo player feature runtime
-- Shared implementation for every module under Features/Player.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

local Runtime = {
    Revision = "1.1b1-player-ultralight-r3",
}

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end
Environment.__SquidNoMoPlayerRuntime = Runtime


local Scheduler = Environment.__SquidNoMoScheduler
if type(Scheduler) ~= "table" or Scheduler.Revision ~= "1.1b1-ultralight-scheduler-r1" then
    -- Runtime.lua normally creates this first. The fallback is intentionally the
    -- same cooperative scheduler so PlayerRuntime remains safe when loaded alone.
    Scheduler = {
        Revision = "1.1b1-ultralight-scheduler-r1",
        Tasks = setmetatable({}, {__mode = "k"}),
        Running = false,
        Lightweight = true,
    }
    function Scheduler:SetLightweight(state) self.Lightweight = state ~= false end
    function Scheduler:Add(owner, interval, idleInterval, callback)
        interval = math.max(tonumber(interval) or 0.25, 0.03)
        self.Tasks[owner] = {
            Interval = interval,
            IdleInterval = math.max(tonumber(idleInterval) or math.max(interval * 4, 1), interval),
            Callback = callback,
            NextRun = os.clock(),
            Busy = false,
        }
        self:_Ensure()
    end
    function Scheduler:Remove(owner) self.Tasks[owner] = nil end
    function Scheduler:_Ensure()
        if self.Running then return end
        self.Running = true
        task.spawn(function()
            while next(self.Tasks) do
                local now, launched = os.clock(), 0
                local launchBudget = self.Lightweight and 3 or 8
                for owner, job in pairs(self.Tasks) do
                    if launched >= launchBudget then break end
                    if not owner or owner.Enabled ~= true then
                        self.Tasks[owner] = nil
                    elseif not job.Busy and now >= job.NextRun then
                        job.Busy = true
                        launched = launched + 1
                        task.spawn(function()
                            local ok, active = xpcall(function() return job.Callback(owner) end, debug.traceback)
                            if not ok and owner and owner.Enabled then
                                owner.LastError = tostring(active)
                                if type(owner._SetStatus) == "function" then owner:_SetStatus("Error", owner.LastError) end
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

local function getCharacter(player)
    player = player or LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return character, humanoid, root
end

local function roleText(player)
    local parts = {
        player and player.Name,
        player and player.DisplayName,
        player and player.Team and player.Team.Name,
    }
    if player then
        for _, attributeName in ipairs({"Role", "Class", "Team", "Job", "Rank"}) do
            local ok, value = pcall(player.GetAttribute, player, attributeName)
            if ok and value ~= nil then
                table.insert(parts, value)
            end
        end
        local character = player.Character
        if character then
            table.insert(parts, character.Name)
            for _, attributeName in ipairs({"Role", "Class", "Team", "Job", "Rank"}) do
                local ok, value = pcall(character.GetAttribute, character, attributeName)
                if ok and value ~= nil then
                    table.insert(parts, value)
                end
            end
        end
    end
    return lower(table.concat(parts, " "))
end

local function playerMatches(player, config)
    if not player or player == LocalPlayer then
        return false
    end
    local character, humanoid = getCharacter(player)
    if not character or not humanoid or humanoid.Health <= 0 then
        return false
    end
    local text = roleText(player)
    if config.RoleTokens and #config.RoleTokens > 0 and not containsAny(text, config.RoleTokens) then
        return false
    end
    if config.ExcludeRoleTokens and containsAny(text, config.ExcludeRoleTokens) then
        return false
    end
    return true
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
        if not ok then
            self.StatusListeners[id] = nil
        end
    end
end

function FeatureMethods:GetStatus()
    return self.Status, self.StatusDetail
end

function FeatureMethods:GetLastError()
    return self.LastError
end

function FeatureMethods:SubscribeStatus(callback)
    assert(type(callback) == "function", "status callback must be a function")
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
    if connection then
        table.insert(self.Connections, connection)
    end
    return connection
end

function FeatureMethods:_TrackInstance(instance)
    if instance then
        table.insert(self.Instances, instance)
    end
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
    interval = tonumber(interval) or tonumber(self.Config.Interval) or 0.2
    local idleInterval = tonumber(self.Config.IdleInterval) or math.max(interval * 4, 0.8)
    Scheduler:Add(self, interval, idleInterval, function(owner)
        local ok, active, detail = pcall(callback, owner)
        if not ok then error(active) end
        if active then
            owner:_SetStatus("Active", detail or "Working")
        else
            owner:_SetStatus("Waiting", detail or owner.Config.WaitingMessage or "Waiting for the local character")
        end
        return active == true
    end)
end

function FeatureMethods:_Clear()
    Scheduler:Remove(self)
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

    if type(self.Restore) == "function" then
        pcall(self.Restore, self)
    end
    self.Restore = nil
end

function FeatureMethods:Set(value)
    local number = tonumber(value)
    if number == nil then
        return false
    end
    if self.Config.Min ~= nil then
        number = math.max(number, self.Config.Min)
    end
    if self.Config.Max ~= nil then
        number = math.min(number, self.Config.Max)
    end

    self.Value = number

    local isValueFeature =
        self.Config.Kind == "HumanoidValue"
        or self.Config.Kind == "WorkspaceValue"

    if isValueFeature then
        local defaultValue = tonumber(
            self.Config.DefaultValue
        ) or 0
        local changed =
            math.abs(number - defaultValue) > 0.001

        if changed then
            self.PreferredValue = number
            if not self.Enabled then
                return self:Toggle(true)
            end
        elseif self.Enabled then
            return self:Toggle(false)
        end
    end

    if self.Enabled
        and type(self.ApplyNow) == "function"
    then
        local ok, active, detail = pcall(
            self.ApplyNow,
            self
        )
        if not ok or active == false then
            return false, tostring(detail or active)
        end
    end
    return true
end

function FeatureMethods:Get()
    return self.Value
end

function FeatureMethods:SetColor(color)
    if typeof(color) ~= "Color3" then
        return false
    end
    self.Color = color
    if self.Enabled and type(self.RefreshNow) == "function" then
        pcall(self.RefreshNow, self)
    end
    return true
end

function FeatureMethods:GetColor()
    return self.Color
end

function FeatureMethods:IsEnabled()
    return self.Enabled == true
end

function FeatureMethods:GetState()
    return self.Enabled and "on" or "off"
end

local function startHumanoidValue(feature)
    feature.OriginalByHumanoid = {}
    feature.BoundHumanoid = nil

    local function apply(self)
        local _, humanoid = getCharacter()
        if not humanoid then return false, "Waiting for the local humanoid" end
        local property = self.Config.Property
        if self.OriginalByHumanoid[humanoid] == nil then
            local ok, original = pcall(function() return humanoid[property] end)
            if ok then self.OriginalByHumanoid[humanoid] = original end
        end
        if property == "JumpPower" and humanoid.UseJumpPower == false then
            if self.OriginalUseJumpPower == nil then self.OriginalUseJumpPower = humanoid.UseJumpPower end
            humanoid.UseJumpPower = true
        end
        local ok, current = pcall(function() return humanoid[property] end)
        if ok and math.abs((tonumber(current) or 0) - (tonumber(self.Value) or 0)) <= 0.01 then
            return true, property .. " already set to " .. tostring(self.Value)
        end
        local applied, err = pcall(function() humanoid[property] = self.Value end)
        return applied, applied and (property .. " set to " .. tostring(math.floor(self.Value * 10 + 0.5) / 10)) or tostring(err)
    end

    local function bind(self)
        local _, humanoid = getCharacter()
        if not humanoid or humanoid == self.BoundHumanoid then return end
        self.BoundHumanoid = humanoid
        apply(self)
        self:_TrackConnection(humanoid:GetPropertyChangedSignal(self.Config.Property):Connect(function()
            if self.Enabled then task.defer(function() if self.Enabled then apply(self) end end) end
        end))
    end

    feature.ApplyNow = apply
    feature.Restore = function(self)
        for humanoid, value in pairs(self.OriginalByHumanoid or {}) do
            if humanoid.Parent then
                pcall(function() humanoid[self.Config.Property] = value end)
                if self.Config.Property == "JumpPower" and self.OriginalUseJumpPower ~= nil then
                    pcall(function() humanoid.UseJumpPower = self.OriginalUseJumpPower end)
                end
            end
        end
        self.OriginalByHumanoid = {}
        self.BoundHumanoid = nil
    end
    if LocalPlayer then
        feature:_TrackConnection(LocalPlayer.CharacterAdded:Connect(function()
            task.defer(function() if feature.Enabled then bind(feature) end end)
        end))
    end
    bind(feature)
    feature:_Loop(feature.Config.Interval or 1.25, function(self)
        bind(self)
        return apply(self)
    end)
end

local function startWorkspaceValue(feature)
    local property = feature.Config.Property
    local ok, original = pcall(function() return Workspace[property] end)
    if ok then
        feature.OriginalValue = original
    end
    feature.ApplyNow = function(self)
        local applied, err = pcall(function() Workspace[property] = self.Value end)
        return applied, applied and (property .. " set to " .. tostring(self.Value)) or tostring(err)
    end
    feature.Restore = function(self)
        if self.OriginalValue ~= nil then
            pcall(function() Workspace[property] = self.OriginalValue end)
        end
    end
    feature:_Loop(feature.Config.Interval or 1.0, feature.ApplyNow)
end

local function startInfiniteJump(feature)
    feature:_TrackConnection(UserInputService.JumpRequest:Connect(function()
        if not feature.Enabled then return end
        local _, humanoid = getCharacter()
        if humanoid and humanoid.Health > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            feature:_SetStatus("Active", "Air jump triggered")
        else
            feature:_SetStatus("Waiting", "Waiting for the local humanoid")
        end
    end))
    feature:_SetStatus("Active", "Listening for jump input")
end

local function startAutoJump(feature)
    feature:_Loop(feature.Config.Interval or 0.12, function()
        local _, humanoid = getCharacter()
        if not humanoid then
            return false, "Waiting for the local humanoid"
        end
        if humanoid.MoveDirection.Magnitude > 0.05 and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid.Jump = true
            return true, "Jumped while moving"
        end
        return true, "Monitoring movement"
    end)
end

local function startNoClip(feature)
    feature.OriginalCollision = {}
    feature.CollisionParts = setmetatable({}, {__mode = "k"})

    local function addPart(self, instance)
        if instance:IsA("BasePart") then
            if self.OriginalCollision[instance] == nil then self.OriginalCollision[instance] = instance.CanCollide end
            self.CollisionParts[instance] = true
        end
    end

    local function bindCharacter(self, character)
        if not character then return end
        for _, descendant in ipairs(character:GetDescendants()) do addPart(self, descendant) end
        self:_TrackConnection(character.DescendantAdded:Connect(function(instance) addPart(self, instance) end))
    end

    feature.Restore = function(self)
        for part, value in pairs(self.OriginalCollision or {}) do
            if part.Parent then pcall(function() part.CanCollide = value end) end
        end
        self.OriginalCollision = {}
        self.CollisionParts = setmetatable({}, {__mode = "k"})
    end
    local character = getCharacter()
    bindCharacter(feature, character)
    if LocalPlayer then
        feature:_TrackConnection(LocalPlayer.CharacterAdded:Connect(function(newCharacter)
            if feature.Enabled then bindCharacter(feature, newCharacter) end
        end))
    end
    feature:_Loop(feature.Config.Interval or 0.10, function(self)
        local count = 0
        for part in pairs(self.CollisionParts) do
            if part.Parent and part.CanCollide then part.CanCollide = false; count = count + 1 end
        end
        return next(self.CollisionParts) ~= nil, "Noclip active; corrected " .. tostring(count) .. " part(s)"
    end)
end

local function startForceThirdPerson(feature)
    feature.OriginalCameraMode = LocalPlayer and LocalPlayer.CameraMode
    feature.OriginalMinZoom = LocalPlayer and LocalPlayer.CameraMinZoomDistance
    feature.OriginalMaxZoom = LocalPlayer and LocalPlayer.CameraMaxZoomDistance
    feature.Restore = function(self)
        if LocalPlayer then
            if self.OriginalCameraMode then LocalPlayer.CameraMode = self.OriginalCameraMode end
            if self.OriginalMinZoom then LocalPlayer.CameraMinZoomDistance = self.OriginalMinZoom end
            if self.OriginalMaxZoom then LocalPlayer.CameraMaxZoomDistance = self.OriginalMaxZoom end
        end
    end
    feature:_Loop(0.85, function()
        if not LocalPlayer then return false, "Waiting for LocalPlayer" end
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = math.max(0.5, feature.Config.MinZoom or 6)
        LocalPlayer.CameraMaxZoomDistance = math.max(feature.Config.MaxZoom or 20, LocalPlayer.CameraMinZoomDistance)
        return true, "Third-person camera enforced"
    end)
end

local function startUnlockZoom(feature)
    feature.OriginalMaxZoom = LocalPlayer and LocalPlayer.CameraMaxZoomDistance
    feature.Restore = function(self)
        if LocalPlayer and self.OriginalMaxZoom then
            LocalPlayer.CameraMaxZoomDistance = self.OriginalMaxZoom
        end
    end
    feature:_Loop(1.0, function()
        if not LocalPlayer then return false, "Waiting for LocalPlayer" end
        LocalPlayer.CameraMaxZoomDistance = feature.Config.MaxZoom or 1000
        return true, "Camera zoom limit expanded"
    end)
end

local function startAutoStand(feature)
    feature:_Loop(0.18, function()
        local _, humanoid = getCharacter()
        if not humanoid then return false, "Waiting for the local humanoid" end
        if humanoid.Sit or humanoid.PlatformStand then
            humanoid.Sit = false
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            return true, "Recovered standing state"
        end
        return true, "Monitoring standing state"
    end)
end

local function createHighlight(feature, player, outlineOnly)
    local character = player.Character
    if not character then return nil end
    local existing = feature.Markers[character]
    if existing and existing.Parent then
        existing.FillColor = feature.Color
        existing.OutlineColor = feature.Config.OutlineColor or Color3.fromRGB(255, 255, 255)
        return existing
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "SquidNoMo_" .. feature.Id
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = feature.Color
    highlight.OutlineColor = feature.Config.OutlineColor or Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = outlineOnly and 1 or (feature.Config.FillTransparency or 0.48)
    highlight.OutlineTransparency = feature.Config.OutlineTransparency or 0.02
    highlight.Parent = character
    feature.Markers[character] = highlight
    feature:_TrackInstance(highlight)
    return highlight
end

local function startPlayerHighlight(feature)
    feature.Markers = {}
    feature.RefreshNow = function(self)
        local valid = {}
        local count = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if playerMatches(player, self.Config) then
                local character = player.Character
                valid[character] = true
                createHighlight(self, player, self.Config.OutlineOnly == true)
                count = count + 1
            end
        end
        for character, marker in pairs(self.Markers) do
            if not valid[character] or not character.Parent or not marker.Parent then
                if marker.Parent then marker:Destroy() end
                self.Markers[character] = nil
            end
        end
        return count
    end
    feature:_Loop(feature.Config.Interval or 0.65, function(self)
        local count = self:RefreshNow()
        return count > 0, count > 0 and ("Tracking " .. count .. " player(s)") or "Waiting for matching players"
    end)
end

local function createBillboard(feature, player)
    local character, humanoid, root = getCharacter(player)
    if not character or not humanoid or not root then return nil end
    local existing = feature.Markers[character]
    if existing and existing.Gui and existing.Gui.Parent then
        return existing
    end
    local gui = Instance.new("BillboardGui")
    gui.Name = "SquidNoMo_" .. feature.Id
    gui.Adornee = root
    gui.AlwaysOnTop = true
    gui.Size = UDim2.fromOffset(180, 34)
    local offsetY = feature.Config.Mode == "Health" and 4.5
        or (feature.Config.Mode == "Distance" and 3.8 or 3.1)
    gui.StudsOffset = Vector3.new(0, offsetY, 0)
    gui.Parent = root

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = feature.Color
    label.TextStrokeTransparency = 0.25
    label.Text = player.DisplayName
    label.Parent = gui

    local marker = {Gui = gui, Label = label, Player = player, Humanoid = humanoid, Root = root}
    feature.Markers[character] = marker
    feature:_TrackInstance(gui)
    return marker
end

local function startPlayerBillboard(feature)
    feature.Markers = {}
    feature.RefreshNow = function(self)
        local valid = {}
        local count = 0
        local _, _, localRoot = getCharacter()
        for _, player in ipairs(Players:GetPlayers()) do
            if playerMatches(player, self.Config) then
                local character = player.Character
                local marker = createBillboard(self, player)
                if marker then
                    valid[character] = true
                    count = count + 1
                    marker.Label.TextColor3 = self.Color
                    if self.Config.Mode == "Distance" then
                        local distance = localRoot and math.floor((marker.Root.Position - localRoot.Position).Magnitude + 0.5) or 0
                        marker.Label.Text = player.DisplayName .. " • " .. tostring(distance) .. "m"
                    elseif self.Config.Mode == "Health" then
                        local health = math.max(0, math.floor(marker.Humanoid.Health + 0.5))
                        local maximum = math.max(1, math.floor(marker.Humanoid.MaxHealth + 0.5))
                        marker.Label.Text = player.DisplayName .. " • " .. health .. "/" .. maximum .. " HP"
                    else
                        marker.Label.Text = player.DisplayName
                    end
                end
            end
        end
        for character, marker in pairs(self.Markers) do
            if not valid[character] or not character.Parent or not marker.Gui.Parent then
                if marker.Gui.Parent then marker.Gui:Destroy() end
                self.Markers[character] = nil
            end
        end
        return count
    end
    local updateInterval = feature.Config.Interval
        or (feature.Config.Mode == "Name" and 0.9 or 0.32)
    feature:_Loop(updateInterval, function(self)
        local count = self:RefreshNow()
        return count > 0, count > 0 and ("Displaying " .. self.Config.Mode .. " for " .. count .. " player(s)") or "Waiting for players"
    end)
end

local function startHideCharacters(feature)
    feature.OriginalTransparency = {}
    feature.BoundCharacters = setmetatable({}, {__mode = "k"})

    local function appliesToPlayer(self, player)
        if self.Config.Mode == "Self" then
            return player == LocalPlayer
        end
        return player ~= LocalPlayer
    end

    local function applyInstance(self, descendant)
        if descendant:IsA("BasePart") then
            if self.OriginalTransparency[descendant] == nil then
                self.OriginalTransparency[descendant] = descendant.LocalTransparencyModifier
            end
            if descendant.LocalTransparencyModifier ~= 1 then
                descendant.LocalTransparencyModifier = 1
            end
        elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
            if self.OriginalTransparency[descendant] == nil then
                self.OriginalTransparency[descendant] = descendant.Transparency
            end
            if descendant.Transparency ~= 1 then
                descendant.Transparency = 1
            end
        end
    end

    local function bindCharacter(self, player, character)
        if not character or self.BoundCharacters[character] or not appliesToPlayer(self, player) then
            return
        end
        self.BoundCharacters[character] = true
        for _, descendant in ipairs(character:GetDescendants()) do
            applyInstance(self, descendant)
        end
        self:_TrackConnection(character.DescendantAdded:Connect(function(instance)
            if self.Enabled then
                applyInstance(self, instance)
            end
        end))
    end

    local function bindPlayer(self, player)
        if not appliesToPlayer(self, player) then return end
        bindCharacter(self, player, player.Character)
        self:_TrackConnection(player.CharacterAdded:Connect(function(character)
            if self.Enabled then
                bindCharacter(self, player, character)
            end
        end))
    end

    feature.Restore = function(self)
        for instance, value in pairs(self.OriginalTransparency or {}) do
            if instance.Parent then
                if instance:IsA("BasePart") then
                    instance.LocalTransparencyModifier = value
                else
                    instance.Transparency = value
                end
            end
        end
        self.OriginalTransparency = {}
        self.BoundCharacters = setmetatable({}, {__mode = "k"})
    end

    for _, player in ipairs(Players:GetPlayers()) do
        bindPlayer(feature, player)
    end
    feature:_TrackConnection(Players.PlayerAdded:Connect(function(player)
        if feature.Enabled then
            bindPlayer(feature, player)
        end
    end))

    feature:_Loop(feature.Config.Interval or 1.25, function(self)
        local count = 0
        for character in pairs(self.BoundCharacters) do
            if character.Parent then count = count + 1 end
        end
        return count > 0, count > 0 and ("Hidden " .. count .. " character(s) locally") or "Waiting for character models"
    end)
end

local function targetAdornee(target)
    if not target then return nil end
    if target:IsA("BasePart") then return target end
    if target:IsA("Tool") or target:IsA("Model") then
        return target:FindFirstChild("Handle") or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
    end
    if target:IsA("ProximityPrompt") then
        local parent = target.Parent
        if parent and parent:IsA("Attachment") then parent = parent.Parent end
        return parent and (parent:IsA("BasePart") and parent or parent:FindFirstChildWhichIsA("BasePart", true))
    end
    return target:FindFirstAncestorWhichIsA("BasePart")
end

local function startToolESP(feature)
    feature.Markers = {}
    feature.Candidates = setmetatable({}, {__mode = "k"})

    local function resolve(instance)
        if instance:IsA("Tool") then return instance end
        local tool = instance:FindFirstAncestorWhichIsA("Tool")
        if tool then return tool end
        if instance:IsA("ProximityPrompt") then
            local context = lower(instance.Name .. " " .. instance.ActionText .. " " .. (instance.Parent and instance.Parent.Name or ""))
            if not containsAny(context, {"door", "seat", "sit", "talk", "dialog"}) then
                return instance
            end
        end
        return nil
    end

    local function addCandidate(self, instance)
        local target = resolve(instance)
        if target then self.Candidates[target] = true end
    end

    local function removeMarker(self, target)
        local marker = self.Markers[target]
        if not marker then return end
        if marker.Highlight and marker.Highlight.Parent then marker.Highlight:Destroy() end
        if marker.Billboard and marker.Billboard.Parent then marker.Billboard:Destroy() end
        self.Markers[target] = nil
    end

    local function ensureMarker(self, target, adornee)
        local marker = self.Markers[target]
        if marker and marker.Highlight and marker.Highlight.Parent and marker.Billboard and marker.Billboard.Parent then
            return marker
        end
        removeMarker(self, target)

        local highlight = Instance.new("Highlight")
        highlight.Name = "SquidNoMo_" .. self.Id
        highlight.Adornee = adornee
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.62
        highlight.OutlineTransparency = 0.05
        highlight.Parent = adornee

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "SquidNoMo_" .. self.Id .. "_Label"
        billboard.Adornee = adornee
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.fromOffset(170, 32)
        billboard.StudsOffset = Vector3.new(0, 1.8, 0)
        billboard.Parent = adornee

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0.25
        label.Text = target:IsA("ProximityPrompt") and (target.ActionText ~= "" and target.ActionText or (target.Parent and target.Parent.Name or target.Name)) or target.Name
        label.Parent = billboard

        marker = {Highlight = highlight, Billboard = billboard, Label = label, Adornee = adornee}
        self.Markers[target] = marker
        self:_TrackInstance(highlight)
        self:_TrackInstance(billboard)
        return marker
    end

    -- Reuse the shared object index when available so enabling Tool ESP never
    -- performs its own complete Workspace scan. The fallback walks in batches.
    local objectIndex = Environment.__SquidNoMoObjectIndex
    if type(objectIndex) == "table" and type(objectIndex.ForEach) == "function" then
        objectIndex:ForEach("workspace", {"Tool", "ProximityPrompt"}, function(instance)
            addCandidate(feature, instance)
            return true
        end)
    else
        feature:_Spawn(function()
            local queue = Workspace:GetChildren()
            local cursor = 1
            while feature.Enabled and cursor <= #queue do
                local instance = queue[cursor]
                cursor = cursor + 1
                addCandidate(feature, instance)
                for _, child in ipairs(instance:GetChildren()) do table.insert(queue, child) end
                if cursor % 220 == 0 then task.wait() end
            end
        end)
    end
    feature:_TrackConnection(Workspace.DescendantAdded:Connect(function(instance)
        if feature.Enabled then addCandidate(feature, instance) end
    end))
    feature:_TrackConnection(Workspace.DescendantRemoving:Connect(function(instance)
        if instance:IsA("Tool") or instance:IsA("ProximityPrompt") then
            feature.Candidates[instance] = nil
            removeMarker(feature, instance)
        end
    end))

    feature.RefreshNow = function(self)
        local valid = {}
        local count = 0
        local character = getCharacter()
        local backpack = LocalPlayer and LocalPlayer:FindFirstChildOfClass("Backpack")
        for target in pairs(self.Candidates) do
            if not target.Parent then
                self.Candidates[target] = nil
                removeMarker(self, target)
            elseif not (character and target:IsDescendantOf(character))
                and not (backpack and target:IsDescendantOf(backpack))
                and target:IsDescendantOf(Workspace)
            then
                local adornee = targetAdornee(target)
                if adornee and adornee.Parent then
                    valid[target] = true
                    local marker = ensureMarker(self, target, adornee)
                    if marker.Adornee ~= adornee then
                        marker.Adornee = adornee
                        marker.Highlight.Adornee = adornee
                        marker.Billboard.Adornee = adornee
                    end
                    marker.Highlight.FillColor = self.Color
                    marker.Highlight.OutlineColor = Color3.new(1, 1, 1)
                    marker.Label.TextColor3 = self.Color
                    count = count + 1
                end
            end
        end
        for target in pairs(self.Markers) do
            if not valid[target] then removeMarker(self, target) end
        end
        return count
    end

    feature:_Loop(feature.Config.Interval or 0.95, function(self)
        local count = self:RefreshNow()
        return count > 0, count > 0 and ("Tracking " .. count .. " tool/interactable target(s)") or "Waiting for tools or interactables"
    end)
end

local function startAntiAFK(feature)
    local virtualUser
    pcall(function() virtualUser = game:GetService("VirtualUser") end)
    if LocalPlayer then
        feature:_TrackConnection(LocalPlayer.Idled:Connect(function()
            if not feature.Enabled then return end
            local ok = false
            if virtualUser then
                ok = pcall(function()
                    virtualUser:CaptureController()
                    virtualUser:ClickButton2(Vector2.new(0, 0), Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame or CFrame.new())
                end)
            end
            feature:_SetStatus(ok and "Active" or "Waiting", ok and "Idle input prevented" or "Executor could not simulate anti-idle input")
        end))
        feature:_SetStatus("Active", "Anti-idle listener connected")
    else
        feature:_SetStatus("Waiting", "Waiting for LocalPlayer")
    end
end

local function startAntiLag(feature)
    feature.Originals = {}
    feature.OptimizedCount = 0
    local function optimize(self, instance)
        if instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam")
            or instance:IsA("Smoke") or instance:IsA("Fire") or instance:IsA("Sparkles")
            or instance:IsA("PostEffect")
        then
            if self.Originals[instance] == nil then
                self.Originals[instance] = instance.Enabled
                self.OptimizedCount = self.OptimizedCount + 1
            end
            instance.Enabled = false
            return true
        end
        return false
    end
    feature.Restore = function(self)
        for instance, value in pairs(self.Originals or {}) do
            if instance.Parent then pcall(function() instance.Enabled = value end) end
        end
        self.Originals = {}
        self.OptimizedCount = 0
    end
    feature.Scanning = true
    feature.PendingScans = 2
    for _, root in ipairs({Workspace, Lighting}) do
        feature:_TrackConnection(root.DescendantAdded:Connect(function(instance)
            if feature.Enabled then optimize(feature, instance) end
        end))
        feature:_Spawn(function()
            local queue = root:GetChildren()
            local cursor = 1
            while feature.Enabled and cursor <= #queue do
                local instance = queue[cursor]
                cursor = cursor + 1
                optimize(feature, instance)
                for _, child in ipairs(instance:GetChildren()) do table.insert(queue, child) end
                if cursor % 220 == 0 then task.wait() end
            end
            feature.PendingScans = math.max(0, (feature.PendingScans or 1) - 1)
            feature.Scanning = feature.PendingScans > 0
        end)
    end
    feature:_Loop(feature.Config.Interval or 2.0, function(self)
        if self.Scanning then
            return true, "Optimizing visual effects in small batches..."
        end
        return true, "Reduced " .. tostring(self.OptimizedCount) .. " expensive visual effect(s)"
    end)
end

local function startMuteSounds(feature)
    feature.OriginalVolumes = {}
    local function mute(self, sound)
        if not sound:IsA("Sound") then return end
        if self.OriginalVolumes[sound] == nil then self.OriginalVolumes[sound] = sound.Volume end
        sound.Volume = 0
    end
    local function bind(self, character)
        if not character then return end
        for _, descendant in ipairs(character:GetDescendants()) do mute(self, descendant) end
        self:_TrackConnection(character.DescendantAdded:Connect(function(instance)
            if self.Enabled then mute(self, instance) end
        end))
    end
    feature.Restore = function(self)
        for sound, volume in pairs(self.OriginalVolumes or {}) do
            if sound.Parent then sound.Volume = volume end
        end
        self.OriginalVolumes = {}
    end
    bind(feature, getCharacter())
    if LocalPlayer then
        feature:_TrackConnection(LocalPlayer.CharacterAdded:Connect(function(character)
            if feature.Enabled then bind(feature, character) end
        end))
    end
    feature:_Loop(feature.Config.Interval or 1.5, function(self)
        local count = 0
        for sound in pairs(self.OriginalVolumes) do if sound.Parent then count = count + 1 end end
        return true, "Muted " .. tostring(count) .. " character sound(s)"
    end)
end

local function executeAction(feature)
    local action = feature.Config.Action
    if action == "Reset" then
        local character = getCharacter()
        if not character then return false, "Local character is not ready" end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false, "Local humanoid is not ready" end
        humanoid.Health = 0
        return true, "Character reset requested"
    elseif action == "Rejoin" then
        if not LocalPlayer then return false, "LocalPlayer is not ready" end
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
        return ok, ok and "Rejoin requested" or tostring(err)
    end
    return false, "Unknown action: " .. tostring(action)
end

local starters = {
    HumanoidValue = startHumanoidValue,
    WorkspaceValue = startWorkspaceValue,
    InfiniteJump = startInfiniteJump,
    AutoJump = startAutoJump,
    NoClip = startNoClip,
    ForceThirdPerson = startForceThirdPerson,
    UnlockZoom = startUnlockZoom,
    AutoStand = startAutoStand,
    PlayerHighlight = startPlayerHighlight,
    PlayerBillboard = startPlayerBillboard,
    HideCharacters = startHideCharacters,
    ToolESP = startToolESP,
    AntiAFK = startAntiAFK,
    AntiLag = startAntiLag,
    MuteSounds = startMuteSounds,
}

function FeatureMethods:Toggle(state)
    state = state == true

    if self.Config.Kind == "Action" then
        if not state then
            self.Enabled = false
            self:_SetStatus("Off", "Ready")
            return true
        end
        local ok, detail = executeAction(self)
        self.Enabled = false
        self:_SetStatus(ok and "Complete" or "Error", detail)
        if not ok then self.LastError = detail end
        return ok, detail
    end

    if self.Enabled == state then
        return true
    end

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
        self.LastError = "Unsupported player feature kind: " .. tostring(self.Config.Kind)
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
    if self.Config.Kind == "HumanoidValue"
        or self.Config.Kind == "WorkspaceValue"
    then
        local defaultValue = tonumber(
            self.Config.DefaultValue
        ) or 0
        if math.abs(
            (tonumber(self.Value) or defaultValue)
            - defaultValue
        ) <= 0.001 then
            self.Value = tonumber(
                self.PreferredValue
                or self.Config.EnabledValue
            ) or defaultValue
        end
    end
    return self:Toggle(true)
end

function FeatureMethods:Disable()
    local result, detail = self:Toggle(false)
    if self.Config.Kind == "HumanoidValue"
        or self.Config.Kind == "WorkspaceValue"
    then
        self.Value = tonumber(
            self.Config.DefaultValue
        ) or self.Value
    end
    return result, detail
end

function FeatureMethods:Initialize(Loader)
    self.Loader = Loader
    return self
end

function Runtime:CreateFeature(config)
    assert(type(config) == "table", "player feature config must be a table")
    assert(type(config.Kind) == "string" and config.Kind ~= "", "player feature Kind is required")
    local defaultValue = tonumber(config.DefaultValue)
    local feature = setmetatable({
        Id = tostring(config.Id or config.Name or "player_feature"),
        Name = tostring(config.Name or config.Id or "Player Feature"),
        Description = tostring(config.Description or ""),
        Config = config,
        Enabled = false,
        Value = defaultValue,
        PreferredValue = tonumber(
            config.EnabledValue
        ) or defaultValue,
        Color = typeof(config.DefaultColor) == "Color3" and config.DefaultColor or Color3.fromRGB(0, 190, 255),
        Status = "Off",
        StatusDetail = "Disabled",
        LastError = nil,
        Connections = {},
        Threads = {},
        Instances = {},
        StatusListeners = {},
        NextListenerId = 0,
    }, FeatureMethods)
    return feature
end

return Runtime
