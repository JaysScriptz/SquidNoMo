--//========================================================--
--// SquidNoMo
--// v0.5.0 Beta
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
    self.FrameCount = 0
    self.FPS = 0
    self.LastFpsUpdate = os.clock()
    self.Connection = nil

    return self
end

function RuntimeStats:Start()
    if self.Connection then
        return
    end

    self.Connection = RunService.RenderStepped:Connect(function()
        self.FrameCount = self.FrameCount + 1

        local now = os.clock()
        local elapsed = now - self.LastFpsUpdate

        if elapsed >= 0.75 then
            self.FPS = math.floor((self.FrameCount / elapsed) + 0.5)
            self.FrameCount = 0
            self.LastFpsUpdate = now
        end
    end)
end

function RuntimeStats:Destroy()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
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
        FPS = self.FPS > 0 and tostring(self.FPS) or "--",
        Ping = string.format("%d ms", self:GetPing()),
        ServerAge = formatDuration(serverAge),
        Uptime = formatDuration(os.clock() - self.StartedAt),
        Connected = connected and "Yes" or "No",
        Players = string.format("%d / %d", playerCount, maxPlayers),
    }
end

return RuntimeStats
