local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local Recorder = {
    Revision = "demonstration-recorder-r1",
    BuildNumber = 11,
    Active = false,
    Session = nil,
    Listeners = {},
    Connections = {},
}

local function environment()
    local value = _G
    if type(getgenv) == "function" then
        local ok, result = pcall(getgenv)
        if ok and type(result) == "table" then value = result end
    end
    return value
end

local function round(value, places)
    local factor = 10 ^ (places or 2)
    return math.floor((tonumber(value) or 0) * factor + 0.5) / factor
end

local function vector(value)
    if typeof(value) ~= "Vector3" then return nil end
    return {x = round(value.X, 2), y = round(value.Y, 2), z = round(value.Z, 2)}
end

local function color(value)
    if typeof(value) ~= "Color3" then return nil end
    return {r = round(value.R, 3), g = round(value.G, 3), b = round(value.B, 3)}
end

local function sanitizeName(value)
    value = string.lower(tostring(value or "game"))
    value = string.gsub(value, "[^%w]+", "_")
    value = string.gsub(value, "^_+", "")
    value = string.gsub(value, "_+$", "")
    return value ~= "" and value or "game"
end

local function safeValue(value)
    local valueType = typeof(value)
    if valueType == "Vector3" then return vector(value) end
    if valueType == "Color3" then return color(value) end
    if valueType == "CFrame" then
        return {position = vector(value.Position), look = vector(value.LookVector)}
    end
    if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
        return value
    end
    return tostring(value)
end

local function characterState()
    local character = LocalPlayer and LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return nil end
    return {
        position = vector(root.Position),
        velocity = vector(root.AssemblyLinearVelocity),
        look = vector(root.CFrame.LookVector),
        move = vector(humanoid.MoveDirection),
        state = tostring(humanoid:GetState()),
        floor = tostring(humanoid.FloorMaterial),
        jump = humanoid.Jump == true,
        health = round(humanoid.Health, 1),
    }
end


local function isFeatureEnabled(feature)
    if type(feature) ~= "table" then return false end
    if type(feature.IsEnabled) == "function" then
        local ok, value = pcall(feature.IsEnabled, feature)
        if ok then return value == true end
    end
    return feature.Enabled == true or feature.Active == true
end

local function setFeatureEnabled(feature, state)
    if type(feature) ~= "table" then return false end
    local method = state and feature.Enable or feature.Disable
    if type(method) == "function" then
        local ok, result = pcall(method, feature)
        return ok and result ~= false
    end
    if type(feature.Toggle) == "function" then
        local ok, result = pcall(feature.Toggle, feature, state)
        return ok and result ~= false
    end
    return false
end

local function appendUnique(list, seen, value, maximum)
    value = tostring(value or "")
    value = string.gsub(value, "%s+", " ")
    if value == "" or seen[value] or #list >= maximum then return end
    seen[value] = true
    table.insert(list, value)
end

function Recorder:_SuspendAutomation()
    local manager = self.Manager
    if type(manager) ~= "table" then return end
    self.Suspended = {
        AutoApply = manager.AutoApplyPerGameEnabled == true,
        Features = {},
    }
    manager.AutoApplyPerGameEnabled = false
    for id, entry in pairs(manager.Registry or {}) do
        if entry.PageName == "Games" or entry.PageName == "Farming" then
            local feature = entry.Feature
            if type(feature) == "table" and isFeatureEnabled(feature) then
                self.Suspended.Features[id] = true
                setFeatureEnabled(feature, false)
            end
        end
    end
end

function Recorder:_RestoreAutomation()
    local suspended = self.Suspended
    self.Suspended = nil
    local manager = self.Manager
    if type(suspended) ~= "table" or type(manager) ~= "table" then return end
    for id in pairs(suspended.Features or {}) do
        local entry = manager.Registry and manager.Registry[id]
        if entry and type(entry.Feature) == "table" then
            setFeatureEnabled(entry.Feature, true)
        end
    end
    manager.AutoApplyPerGameEnabled = suspended.AutoApply == true
    if manager.AutoApplyPerGameEnabled and type(manager._ApplyDetectedGame) == "function" then
        pcall(manager._ApplyDetectedGame, manager, true)
    end
end

function Recorder:_Notify()
    for _, callback in pairs(self.Listeners) do
        pcall(callback, self:GetStatus())
    end
end

function Recorder:Subscribe(callback)
    if type(callback) ~= "function" then return nil end
    local key = {}
    self.Listeners[key] = callback
    pcall(callback, self:GetStatus())
    return {
        Disconnect = function()
            self.Listeners[key] = nil
        end,
    }
end

function Recorder:Initialize(Loader, Manager)
    self.Loader = Loader
    self.Manager = Manager
    self.Runtime = Loader
        and Loader.Features
        and Loader.Features.Shared
        and Loader.Features.Shared.Runtime
    self.GameRuntime = Loader
        and Loader.Features
        and Loader.Features.Shared
        and Loader.Features.Shared.GameRuntime
    environment().__SquidNoMoLearningRecorder = self
    return self
end

function Recorder:GetStatus()
    local session = self.Session
    return {
        Active = self.Active == true,
        Game = session and session.game or nil,
        StartedAt = session and session.startedAtClock or nil,
        Samples = session and #session.samples or 0,
        Events = session and #session.events or 0,
        SavedPath = session and session.savedPath or nil,
        Success = session and session.success == true or false,
        Message = self.Message or "Ready to learn one demonstrated round.",
    }
end

function Recorder:_Event(kind, data)
    if not self.Session then return end
    local item = {
        t = round(os.clock() - self.Session.startedAtClock, 3),
        kind = tostring(kind),
        data = data,
    }
    table.insert(self.Session.events, item)
end

function Recorder:_Disconnect()
    for _, connection in ipairs(self.Connections) do
        pcall(function() connection:Disconnect() end)
    end
    self.Connections = {}
end

function Recorder:_VisibleSummary()
    local runtime = self.Runtime
    if type(runtime) ~= "table" or type(runtime.GetVisualSnapshot) ~= "function" then return {} end
    local ok, snapshot = pcall(runtime.GetVisualSnapshot, runtime, true)
    if not ok or type(snapshot) ~= "table" then return {} end
    local results, seen = {}, {}
    for _, item in ipairs(snapshot.Items or {}) do
        local text = tostring(item.RawText or "")
        if #text > 0 and #text <= 120 then appendUnique(results, seen, text, 36) end
    end
    table.sort(results)
    return results
end

function Recorder:_NearbySummary(root)
    local runtime = self.Runtime
    if type(runtime) ~= "table" or type(runtime.FindTargets) ~= "function" then return {} end
    local ok, targets = pcall(runtime.FindTargets, runtime, {
        Scope = "Workspace",
        TargetClasses = {"ProximityPrompt", "Tool", "Sound", "ValueBase", "ClickDetector"},
        MaxTargets = 320,
        CacheTTL = 0.25,
    })
    if not ok or type(targets) ~= "table" then return {} end

    local results = {}
    for _, target in ipairs(targets) do
        if #results >= 32 then break end
        local position
        pcall(function()
            local parent = (target:IsA("ProximityPrompt") or target:IsA("ClickDetector"))
                and target.Parent
                or target
            if parent:IsA("BasePart") then
                position = parent.Position
            elseif parent:IsA("Model") then
                position = parent:GetPivot().Position
            elseif parent.Parent and parent.Parent:IsA("BasePart") then
                position = parent.Parent.Position
            end
        end)
        local distance = root and position and (position - root.Position).Magnitude or nil
        local include = distance == nil or distance <= 140
        if target:IsA("Sound") then include = target.Playing == true end
        if target:IsA("ProximityPrompt") then include = target.Enabled == true and include end
        if include then
            local entry = {
                class = target.ClassName,
                name = target.Name,
                parent = target.Parent and target.Parent.Name or nil,
                distance = distance and round(distance, 1) or nil,
            }
            if target:IsA("ProximityPrompt") then
                entry.action = target.ActionText
                entry.object = target.ObjectText
            elseif target:IsA("ValueBase") then
                entry.value = safeValue(target.Value)
            elseif target:IsA("Sound") then
                entry.playing = target.Playing
                entry.soundId = target.SoundId
                entry.time = round(target.TimePosition, 2)
            end
            table.insert(results, entry)
        end
    end
    return results
end

function Recorder:_StateSummary()
    local result = {}
    local objects = {LocalPlayer, LocalPlayer and LocalPlayer.Character, Workspace}
    for _, object in ipairs(objects) do
        if object then
            local attributes = {}
            for name, value in pairs(object:GetAttributes()) do
                local key = string.lower(tostring(name))
                if string.find(key, "game", 1, true)
                    or string.find(key, "round", 1, true)
                    or string.find(key, "mode", 1, true)
                    or string.find(key, "stage", 1, true)
                    or string.find(key, "state", 1, true)
                    or string.find(key, "light", 1, true)
                then
                    attributes[name] = safeValue(value)
                end
            end
            if next(attributes) then
                result[object.Name] = attributes
            end
        end
    end
    return result
end

function Recorder:_Sample(force)
    if not self.Active or not self.Session then return end
    local character = LocalPlayer and LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local detected, score, detail
    if self.GameRuntime and type(self.GameRuntime.DetectGame) == "function" then
        pcall(function()
            detected, score, detail = self.GameRuntime:DetectGame(force == true)
        end)
    end

    local rlglState, rlglDetail
    if self.Session.game == "Red Light, Green Light"
        and self.Runtime
        and type(self.Runtime.GetRLGLStateDetail) == "function"
    then
        pcall(function()
            rlglState, rlglDetail = self.Runtime:GetRLGLStateDetail()
        end)
    end

    local movement = characterState()
    local sample = {
        t = round(os.clock() - self.Session.startedAtClock, 3),
        detectedGame = detected,
        detectionScore = round(score or 0, 1),
        detectionDetail = detail,
        rlglState = rlglState,
        rlglDetail = rlglDetail,
        movement = movement,
    }

    if force then
        local visible = self:_VisibleSummary()
        local visibleSignature = table.concat(visible, "|")
        sample.nearby = self:_NearbySummary(root)
        sample.state = self:_StateSummary()
        sample.timer = self.Runtime and type(self.Runtime.GetRoundTimerSeconds) == "function"
            and self.Runtime:GetRoundTimerSeconds()
            or nil
        sample.phase = self.Runtime and type(self.Runtime.GetRoundPhase) == "function"
            and self.Runtime:GetRoundPhase()
            or nil
        if visibleSignature ~= self.Session.lastVisibleSignature then
            sample.visibleText = visible
            self.Session.lastVisibleSignature = visibleSignature
        end
        self.Session.lastContext = {
            timer = sample.timer,
            phase = sample.phase,
        }
    elseif self.Session.lastContext then
        sample.timer = self.Session.lastContext.timer
        sample.phase = self.Session.lastContext.phase
    end

    table.insert(self.Session.samples, sample)
end

function Recorder:Start(gameName)
    if self.Active then return false, "A learning round is already active." end
    gameName = tostring(gameName or "")
    if gameName == "" then return false, "Select a game before learning." end

    self:_Disconnect()
    self:_SuspendAutomation()
    self.Active = true
    self.Message = "Learning " .. gameName .. " — play the round normally."
    self.Session = {
        schema = 1,
        build = self.Loader and self.Loader.BuildVersion or "1.1 beta 11",
        buildNumber = self.Loader and self.Loader.BuildNumber or 11,
        game = gameName,
        placeId = game.PlaceId,
        startedAtUnix = os.time(),
        startedAtClock = os.clock(),
        compatibility = self.Runtime and type(self.Runtime.GetCompatibilitySummary) == "function"
            and self.Runtime:GetCompatibilitySummary()
            or {},
        samples = {},
        events = {},
        success = false,
    }

    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, processed)
        if not self.Active then return end
        self:_Event("input_begin", {
            type = tostring(input.UserInputType),
            key = tostring(input.KeyCode),
            processed = processed == true,
            position = {x = round(input.Position.X, 1), y = round(input.Position.Y, 1)},
        })
    end))
    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input, processed)
        if not self.Active then return end
        self:_Event("input_end", {
            type = tostring(input.UserInputType),
            key = tostring(input.KeyCode),
            processed = processed == true,
        })
    end))
    if LocalPlayer then
        table.insert(self.Connections, LocalPlayer.CharacterAdded:Connect(function(character)
            self:_Event("character_added", {name = character.Name})
        end))
    end

    self:_Event("learning_started", {game = gameName})
    self:_Sample(true)
    local token = self.Session
    task.spawn(function()
        local lastHeavy = 0
        while self.Active and self.Session == token do
            local now = os.clock()
            local heavy = now - lastHeavy >= 0.75
            self:_Sample(heavy)
            if heavy then
                lastHeavy = now
                local text = self.Runtime and type(self.Runtime.GetVisibleText) == "function"
                    and string.lower(tostring(self.Runtime:GetVisibleText() or ""))
                    or ""
                if string.find(text, "you survived", 1, true)
                    or string.find(text, "qualified", 1, true)
                    or string.find(text, "victory", 1, true)
                    or string.find(text, "game complete", 1, true)
                then
                    task.defer(function()
                        if self.Active and self.Session == token then self:MarkSuccess() end
                    end)
                    break
                end
            end
            task.wait(0.22)
        end
    end)
    self:_Notify()
    return true
end

function Recorder:_Save()
    if not self.Session then return false, "No learning session is available." end
    self.Session.endedAtUnix = os.time()
    self.Session.duration = round(os.clock() - self.Session.startedAtClock, 3)
    self.Session.startedAtClock = nil
    self.Session.lastVisibleSignature = nil
    self.Session.lastContext = nil

    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, self.Session)
    if not ok then return false, tostring(encoded) end

    local fileName = string.format(
        "SquidNoMo_Learning_%s_%s.json",
        sanitizeName(self.Session.game),
        tostring(os.time())
    )
    local path = fileName
    if type(makefolder) == "function" and type(writefile) == "function" then
        pcall(function()
            if type(isfolder) ~= "function" or not isfolder("SquidNoMo") then makefolder("SquidNoMo") end
            if type(isfolder) ~= "function" or not isfolder("SquidNoMo/Learning") then makefolder("SquidNoMo/Learning") end
            path = "SquidNoMo/Learning/" .. fileName
        end)
    end

    if type(writefile) == "function" then
        local writeOk, writeError = pcall(writefile, path, encoded)
        if not writeOk then return false, tostring(writeError) end
        self.Session.savedPath = path
        return true, path
    end
    if type(setclipboard) == "function" then
        local copyOk, copyError = pcall(setclipboard, encoded)
        if copyOk then
            self.Session.savedPath = "clipboard"
            return true, "clipboard"
        end
        return false, tostring(copyError)
    end
    environment().__SquidNoMoLastLearningTrace = encoded
    self.Session.savedPath = "executor memory"
    return true, "executor memory"
end

function Recorder:Stop(success)
    if not self.Active or not self.Session then return false, "No learning round is active." end
    self:_Sample(true)
    self.Session.success = success == true
    self:_Event(success and "round_success" or "learning_stopped", {})
    self.Active = false
    self:_Disconnect()
    self:_RestoreAutomation()
    local ok, detail = self:_Save()
    if ok then
        self.Message = success
            and ("Successful round saved to " .. tostring(detail) .. ". Upload that JSON so the module can be rewritten.")
            or ("Learning trace saved to " .. tostring(detail) .. ".")
    else
        self.Message = "Could not save the learning trace: " .. tostring(detail)
    end
    self:_Notify()
    return ok, detail
end

function Recorder:MarkSuccess()
    return self:Stop(true)
end

return Recorder
