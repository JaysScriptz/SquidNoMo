--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// FrontmanESP.lua
--//========================================================--

local FrontmanESP = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local RoleService = loadstring(game:HttpGet(

	App.Config.Repository ..
	"Features/Shared/RoleService.lua"

))()

local Enabled = false
local Connection
local Highlights = {}

----------------------------------------------------------
-- Add Highlight
----------------------------------------------------------

local function Add(Player)

	if Player == LocalPlayer then
		return
	end

	if not RoleService:IsFrontman(Player) then
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

	Highlight.Name = "SquidNoMo_FrontmanESP"

	Highlight.Adornee = Character

	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	Highlight.FillColor = Color3.fromRGB(170,0,255)

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

function FrontmanESP:Enable()

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

function FrontmanESP:Disable()

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

function FrontmanESP:IsEnabled()

	return Enabled

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return FrontmanESP
