--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// AntiAFK.lua
--//========================================================--

local AntiAFK = {}

local Players = game:GetService("Players")

local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local Enabled = false
local Connection

----------------------------------------------------------
-- Enable
----------------------------------------------------------

function AntiAFK:Enable()

	if Enabled then
		return
	end

	Enabled = true

	Connection = LocalPlayer.Idled:Connect(function()

		VirtualUser:CaptureController()

		VirtualUser:ClickButton2(Vector2.new())

	end)

end

----------------------------------------------------------
-- Disable
----------------------------------------------------------

function AntiAFK:Disable()

	Enabled = false

	if Connection then

		Connection:Disconnect()

		Connection = nil

	end

end

----------------------------------------------------------
-- Status
----------------------------------------------------------

function AntiAFK:IsEnabled()

	return Enabled

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return AntiAFK
