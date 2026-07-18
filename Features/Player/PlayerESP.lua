--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// PlayerESP.lua
--//========================================================--

local PlayerESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Enabled = false
local Connection

local Highlights = {}

----------------------------------------------------------
-- Create Highlight
----------------------------------------------------------

local function AddCharacter(Character)

	if not Character then
		return
	end

	if Character == LocalPlayer.Character then
		return
	end

	if Highlights[Character] then
		return
	end

	local Highlight = Instance.new("Highlight")

	Highlight.Name = "SquidNoMo_PlayerESP"

	Highlight.FillTransparency = 0.5

	Highlight.OutlineTransparency = 0

	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	Highlight.FillColor = Color3.fromRGB(0,170,255)

	Highlight.OutlineColor = Color3.fromRGB(255,255,255)

	Highlight.Adornee = Character

	Highlight.Parent = Character

	Highlights[Character] = Highlight

end

----------------------------------------------------------
-- Remove Highlights
----------------------------------------------------------

local function Clear()

	for Character, Highlight in pairs(Highlights) do

		if Highlight then
			Highlight:Destroy()
		end

	end

	table.clear(Highlights)

end

----------------------------------------------------------
-- Refresh
----------------------------------------------------------

local function Refresh()

	Clear()

	for _, Player in ipairs(Players:GetPlayers()) do

		if Player ~= LocalPlayer then

			AddCharacter(Player.Character)

		end

	end

end

----------------------------------------------------------
-- Enable
----------------------------------------------------------

function PlayerESP:Enable()

	if Enabled then
		return
	end

	Enabled = true

	Refresh()

	Connection = RunService.Heartbeat:Connect(function()

		if Enabled then

			Refresh()

		end

	end)

end

----------------------------------------------------------
-- Disable
----------------------------------------------------------

function PlayerESP:Disable()

	Enabled = false

	if Connection then

		Connection:Disconnect()

		Connection = nil

	end

	Clear()

end

----------------------------------------------------------
-- Status
----------------------------------------------------------

function PlayerESP:IsEnabled()

	return Enabled

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return PlayerESP
