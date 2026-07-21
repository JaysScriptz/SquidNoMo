-- SquidNoMo player feature runtime
-- Shared implementation for every module under Features/Player.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

local Runtime = {
    Revision = "1.1b1-player-recode-r1",
}

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end
Environment.__SquidNoMoPlayerRuntime = Runtime

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
    self.Status = tostring(state or "Unknown")
    self.StatusDetail = tostring(detail or "")
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
    self:_Spawn(function()
        while self.Enabled do
            local ok, active, detail = pcall(callback, self)
            if not ok then
                error(active)
            end
            if active then
                self:_SetStatus("Active", detail or "Working")
            else
                self:_SetStatus("Waiting", detail or self.Config.WaitingMessage or "Waiting for the local character")
            end
            task.wait(interval or self.Config.Interval or 0.2)
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

    local function apply(self)
        local _, humanoid = getCharacter()
        if not humanoid then
            return false, "Waiting for the local humanoid"
        end
        local property = self.Config.Property
        if self.OriginalByHumanoid[humanoid] == nil then
            local ok, original = pcall(function() return humanoid[property] end)
            if ok then
                self.OriginalByHumanoid[humanoid] = original
            end
        end

        if property == "JumpPower" and humanoid.UseJumpPower == false then
            if self.OriginalUseJumpPower == nil then
                self.OriginalUseJumpPower = humanoid.UseJumpPower
            end
            humanoid.UseJumpPower = true
        end

        local ok, err = pcall(function()
            humanoid[property] = self.Value
        end)
        if not ok then
            return false, tostring(err)
        end
        return true, property .. " set to " .. tostring(math.floor(self.Value * 10 + 0.5) / 10)
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
    end
    feature:_Loop(feature.Config.Interval or 0.1, apply)
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
    feature:_Loop(feature.Config.Interval or 0.2, feature.ApplyNow)
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
    feature:_Loop(feature.Config.Interval or 0.08, function()
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
    feature.Restore = function(self)
        for part, value in pairs(self.OriginalCollision or {}) do
            if part.Parent then
                pcall(function() part.CanCollide = value end)
            end
        end
        self.OriginalCollision = {}
    end
    feature:_TrackConnection(RunService.Stepped:Connect(function()
        if not feature.Enabled then return end
        local character = getCharacter()
        if not character then
            feature:_SetStatus("Waiting", "Waiting for the local character")
            return
        end
        local changed = 0
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if feature.OriginalCollision[descendant] == nil then
                    feature.OriginalCollision[descendant] = descendant.CanCollide
                end
                if descendant.CanCollide then
                    descendant.CanCollide = false
                    changed = changed + 1
                end
            end
        end
        feature:_SetStatus("Active", "Noclip active on " .. tostring(changed) .. " collidable part(s)")
    end))
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
    feature:_Loop(0.2, function()
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
    feature:_Loop(0.25, function()
        if not LocalPlayer then return false, "Waiting for LocalPlayer" end
        LocalPlayer.CameraMaxZoomDistance = feature.Config.MaxZoom or 1000
        return true, "Camera zoom limit expanded"
    end)
end

local function startAutoStand(feature)
    feature:_Loop(0.08, function()
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
    feature:_Loop(feature.Config.Interval or 0.35, function(self)
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
    gui.StudsOffset = Vector3.new(0, 3.1, 0)
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
    feature:_Loop(feature.Config.Interval or 0.15, function(self)
        local count = self:RefreshNow()
        return count > 0, count > 0 and ("Displaying " .. self.Config.Mode .. " for " .. count .. " player(s)") or "Waiting for players"
    end)
end

local function startHideCharacters(feature)
    feature.OriginalTransparency = {}
    feature.CharacterConnections = {}

    local function applyCharacter(self, character)
        if not character then return end
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if self.OriginalTransparency[descendant] == nil then
                    self.OriginalTransparency[descendant] = descendant.LocalTransparencyModifier
                end
                descendant.LocalTransparencyModifier = 1
            elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
                if self.OriginalTransparency[descendant] == nil then
                    self.OriginalTransparency[descendant] = descendant.Transparency
                end
                descendant.Transparency = 1
            end
        end
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
    end

    feature:_Loop(feature.Config.Interval or 0.35, function(self)
        local count = 0
        if self.Config.Mode == "Self" then
            local character = getCharacter()
            if character then
                applyCharacter(self, character)
                count = 1
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    applyCharacter(self, player.Character)
                    count = count + 1
                end
            end
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
    feature.RefreshNow = function(self)
        local valid = {}
        local count = 0
        local character = getCharacter()
        local backpack = LocalPlayer and LocalPlayer:FindFirstChildOfClass("Backpack")
        for _, instance in ipairs(Workspace:GetDescendants()) do
            local target = resolve(instance)
            if target and not valid[target]
                and not (character and target:IsDescendantOf(character))
                and not (backpack and target:IsDescendantOf(backpack))
            then
                valid[target] = true
                local marker = self.Markers[target]
                local adornee = targetAdornee(target)
                if adornee then
                    if not marker or not marker.Highlight.Parent then
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
                        label.Text = target:IsA("ProximityPrompt") and (target.ActionText ~= "" and target.ActionText or target.Parent.Name) or target.Name
                        label.Parent = billboard
                        marker = {Highlight = highlight, Billboard = billboard, Label = label}
                        self.Markers[target] = marker
                        self:_TrackInstance(highlight)
                        self:_TrackInstance(billboard)
                    end
                    marker.Highlight.FillColor = self.Color
                    marker.Highlight.OutlineColor = Color3.new(1, 1, 1)
                    marker.Label.TextColor3 = self.Color
                    count = count + 1
                end
            end
        end
        for target, marker in pairs(self.Markers) do
            if not valid[target] or not target.Parent then
                if marker.Highlight.Parent then marker.Highlight:Destroy() end
                if marker.Billboard.Parent then marker.Billboard:Destroy() end
                self.Markers[target] = nil
            end
        end
        return count
    end
    feature:_Loop(feature.Config.Interval or 0.8, function(self)
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
    local function optimize(self, instance)
        if instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Beam")
            or instance:IsA("Smoke") or instance:IsA("Fire") or instance:IsA("Sparkles")
        then
            if self.Originals[instance] == nil then self.Originals[instance] = instance.Enabled end
            instance.Enabled = false
            return true
        elseif instance:IsA("PostEffect") then
            if self.Originals[instance] == nil then self.Originals[instance] = instance.Enabled end
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
    end
    feature:_Loop(feature.Config.Interval or 1.2, function(self)
        local count = 0
        for _, root in ipairs({Workspace, Lighting}) do
            for _, instance in ipairs(root:GetDescendants()) do
                if optimize(self, instance) then count = count + 1 end
            end
        end
        return true, "Reduced " .. count .. " expensive visual effect(s)"
    end)
end

local function startMuteSounds(feature)
    feature.OriginalVolumes = {}
    feature.Restore = function(self)
        for sound, volume in pairs(self.OriginalVolumes or {}) do
            if sound.Parent then sound.Volume = volume end
        end
        self.OriginalVolumes = {}
    end
    feature:_Loop(feature.Config.Interval or 0.45, function(self)
        local character = getCharacter()
        if not character then return false, "Waiting for the local character" end
        local count = 0
        for _, sound in ipairs(character:GetDescendants()) do
            if sound:IsA("Sound") then
                if self.OriginalVolumes[sound] == nil then self.OriginalVolumes[sound] = sound.Volume end
                sound.Volume = 0
                count = count + 1
            end
        end
        return true, "Muted " .. count .. " character sound(s)"
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
