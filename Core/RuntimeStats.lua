--//========================================================--
--// SquidNoMo
--// 1.1 beta 1
--// Core/RuntimeStats.lua
--// Lightweight client/session diagnostics for the dashboard.
--//========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

local RuntimeStats = {}
RuntimeStats.__index = RuntimeStats

local LocalPlayer = Players.LocalPlayer

local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then Environment = result end
end
local FrameSampler = Environment.__SquidNoMoFrameSampler
if type(FrameSampler) ~= "table" or FrameSampler.Revision ~= "1.1b1-frame-sampler-r1" then
    FrameSampler = {Revision = "1.1b1-frame-sampler-r1", FPS = 60, Frames = 0, LastUpdate = os.clock()}
    FrameSampler.Connection = RunService.RenderStepped:Connect(function()
        FrameSampler.Frames = FrameSampler.Frames + 1
        local now = os.clock()
        local elapsed = now - FrameSampler.LastUpdate
        if elapsed >= 0.75 then
            FrameSampler.FPS = math.max(1, math.floor(FrameSampler.Frames / elapsed + 0.5))
            FrameSampler.Frames = 0
            FrameSampler.LastUpdate = now
        end
    end)
    Environment.__SquidNoMoFrameSampler = FrameSampler
end

local function formatDuration(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remaining = seconds % 60

    return string.format("%02d:%02d:%02d", hours, minutes, remaining)
end

function RuntimeStats.new()
    local self = setmetatable({}, RuntimeStats)

    self.StartedAt = os.clock()
    self.FPS = FrameSampler.FPS
    self.Connection = nil

    return self
end

function RuntimeStats:Start()
    self.FPS = FrameSampler.FPS
end

function RuntimeStats:Destroy()
    self.Connection = nil
end

function RuntimeStats:GetPing()
    local ping

    if LocalPlayer and type(LocalPlayer.GetNetworkPing) == "function" then
        local ok, value = pcall(function()
            return LocalPlayer:GetNetworkPing()
        end)

        if ok and type(value) == "number" then
            ping = math.floor((value * 1000) + 0.5)
        end
    end

    if ping == nil then
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
        end)
    end

    return ping or 0
end

function RuntimeStats:GetClientName()
    if UserInputService.TouchEnabled then
        return "Mobile"
    end

    return "Desktop"
end

function RuntimeStats:GetSnapshot()
    local serverAge = 0

    pcall(function()
        serverAge = workspace.DistributedGameTime
    end)

    local connected = game:IsLoaded() and LocalPlayer and LocalPlayer.Parent ~= nil
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers or 0

    return {
        Client = self:GetClientName(),
        FPS = FrameSampler.FPS > 0 and tostring(FrameSampler.FPS) or "--",
        Ping = string.format("%d ms", self:GetPing()),
        ServerAge = formatDuration(serverAge),
        Uptime = formatDuration(os.clock() - self.StartedAt),
        Connected = connected and "Yes" or "No",
        Players = string.format("%d / %d", playerCount, maxPlayers),
    }
end

return RuntimeStats
