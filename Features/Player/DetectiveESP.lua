--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// DetectiveESP.lua
--//========================================================--

local DetectiveESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local RoleService

local Enabled = false
local Connection
local Highlights = {}

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function DetectiveESP:Initialize(Loader)
	RoleService = Loader.Features
		and Loader.Features.Shared
		and Loader.Features.Shared.RoleService
end

----------------------------------------------------------
-- Add Highlight
----------------------------------------------------------

local function Add(Player)

	if Player == LocalPlayer then
		return
	end

	if not RoleService or not RoleService:IsDetective(Player) then
		return
	end

	local Character = Player.Character

	if not Character then
		return
	end

	if Highlights[Character] then
		return
	end

	local Highlight = Instance.new("Highlight")

	Highlight.Name = "SquidNoMo_DetectiveESP"

	Highlight.Adornee = Character

	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	Highlight.FillColor = Color3.fromRGB(0,255,140)

	Highlight.OutlineColor = Color3.new(1,1,1)

	Highlight.FillTransparency = .45

	Highlight.Parent = Character

	Highlights[Character] = Highlight

end

----------------------------------------------------------
-- Clear
----------------------------------------------------------

local function Clear()

	for _, Highlight in pairs(Highlights) do

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

		Add(Player)

	end

end

----------------------------------------------------------
-- Enable
----------------------------------------------------------

function DetectiveESP:Enable()

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

function DetectiveESP:Disable()

	Enabled = false

	if Connection then

		Connection:Disconnect()

		Connection = nil

	end

	Clear()

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return DetectiveESP
