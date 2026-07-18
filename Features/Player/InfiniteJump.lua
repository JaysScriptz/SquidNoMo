--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Player
--// InfiniteJump.lua
--//========================================================--

local InfiniteJump = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Enabled = false
local Connection

----------------------------------------------------------
-- Enable
----------------------------------------------------------

function InfiniteJump:Enable()

	if Enabled then
		return
	end

	Enabled = true

	Connection = UserInputService.JumpRequest:Connect(function()

		local Character = LocalPlayer.Character

		if not Character then
			return
		end

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")

		if Humanoid then

			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		end

	end)

end

----------------------------------------------------------
-- Disable
----------------------------------------------------------

function InfiniteJump:Disable()

	Enabled = false

	if Connection then

		Connection:Disconnect()

		Connection = nil

	end

end

----------------------------------------------------------
-- Status
----------------------------------------------------------

function InfiniteJump:IsEnabled()

	return Enabled

end

----------------------------------------------------------
-- Return
----------------------------------------------------------

return InfiniteJump
