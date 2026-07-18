--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// Noclip.lua
--//========================================================--

local Noclip = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Enabled = false
local Connection

----------------------------------------------------------
-- Apply
----------------------------------------------------------

local function Apply()

	local Character = LocalPlayer.Character

	if not Character then
		return
	end

	for _, Object in ipairs(Character:GetDescendants()) do

		if Object:IsA("BasePart") then

			Object.CanCollide = false

		end

	end

end

----------------------------------------------------------
-- Enable
----------------------------------------------------------

function Noclip:Enable()

	if Enabled then
		return
	end

	Enabled = true

	Connection = RunService.Stepped:Connect(function()

		if Enabled then

			Apply()

		end

	end)

end

----------------------------------------------------------
-- Disable
----------------------------------------------------------

function Noclip:Disable()

	Enabled = false

	if Connection then

		Connection:Disconnect()

		Connection = nil

	end

	local Character = LocalPlayer.Character

	if Character then

		for _, Object in ipairs(Character:GetDescendants()) do

			if Object:IsA("BasePart") then

				Object.CanCollide = true

			end

		end

	end

end

----------------------------------------------------------
-- Status
----------------------------------------------------------

function Noclip:IsEnabled()

	return Enabled

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return Noclip
