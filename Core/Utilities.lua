--//========================================================--
--// SquidNoMo
--// Beta 4.0
--// Utilities.lua
--//========================================================--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local Utilities = {}

----------------------------------------------------------
-- Number Formatting
----------------------------------------------------------

function Utilities:FormatNumber(Number)

	Number = tonumber(Number) or 0

	if Number >= 1000000 then
		return string.format("%.1fM", Number / 1000000)
	elseif Number >= 1000 then
		return string.format("%.1fK", Number / 1000)
	end

	return tostring(math.floor(Number))

end

----------------------------------------------------------
-- Time Formatting
----------------------------------------------------------

function Utilities:FormatTime(Seconds)

	Seconds = math.floor(Seconds)

	local Hours = math.floor(Seconds / 3600)
	local Minutes = math.floor((Seconds % 3600) / 60)
	local Secs = Seconds % 60

	if Hours > 0 then
		return string.format("%02d:%02d:%02d", Hours, Minutes, Secs)
	end

	return string.format("%02d:%02d", Minutes, Secs)

end

----------------------------------------------------------
-- Ping
----------------------------------------------------------

function Utilities:GetPing()

	local Ping = 0

	pcall(function()

		Ping = math.floor(
			Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		)

	end)

	return Ping

end

----------------------------------------------------------
-- FPS
----------------------------------------------------------

local FPS = 60

RunService.RenderStepped:Connect(function(dt)

	FPS = math.floor(1 / dt)

end)

function Utilities:GetFPS()

	return FPS

end

----------------------------------------------------------
-- Player Count
----------------------------------------------------------

function Utilities:GetPlayerCount()

	return #Players:GetPlayers()

end

----------------------------------------------------------
-- Server Age
----------------------------------------------------------

local StartTick = tick()

function Utilities:GetServerAge()

	return self:FormatTime(tick() - StartTick)

end

----------------------------------------------------------
-- Drag Window
----------------------------------------------------------

function Utilities:EnableDragging(Window, DragBar)

	local Dragging = false
	local DragInput
	local Start
	local Position

	local function Update(Input)

		local Delta = Input.Position - Start

		Window.Position = UDim2.new(

			Position.X.Scale,
			Position.X.Offset + Delta.X,

			Position.Y.Scale,
			Position.Y.Offset + Delta.Y

		)

	end

	DragBar.InputBegan:Connect(function(Input)

		if Input.UserInputType == Enum.UserInputType.MouseButton1 then

			Dragging = true

			Start = Input.Position

			Position = Window.Position

			Input.Changed:Connect(function()

				if Input.UserInputState == Enum.UserInputState.End then

					Dragging = false

				end

			end)

		end

	end)

	DragBar.InputChanged:Connect(function(Input)

		if Input.UserInputType == Enum.UserInputType.MouseMovement then

			DragInput = Input

		end

	end)

	UserInputService.InputChanged:Connect(function(Input)

		if Dragging and Input == DragInput then

			Update(Input)

		end

	end)

end

----------------------------------------------------------
-- Find Player
----------------------------------------------------------

function Utilities:FindPlayer(Name)

	Name = string.lower(Name)

	for _, Player in ipairs(Players:GetPlayers()) do

		if string.find(
			string.lower(Player.Name),
			Name,
			1,
			true
		) then

			return Player

		end

	end

	return nil

end

----------------------------------------------------------
-- Character
----------------------------------------------------------

function Utilities:GetCharacter(Player)

	Player = Player or Players.LocalPlayer

	return Player.Character
		or Player.CharacterAdded:Wait()

end

----------------------------------------------------------
-- Humanoid
----------------------------------------------------------

function Utilities:GetHumanoid(Player)

	local Character = self:GetCharacter(Player)

	return Character:WaitForChild("Humanoid")

end

----------------------------------------------------------
-- Root Part
----------------------------------------------------------

function Utilities:GetRoot(Player)

	local Character = self:GetCharacter(Player)

	return Character:WaitForChild("HumanoidRootPart")

end

----------------------------------------------------------
-- Teleport
----------------------------------------------------------

function Utilities:Teleport(CFramePosition)

	local Root = self:GetRoot()

	if Root then

		Root.CFrame = CFramePosition

	end

end

----------------------------------------------------------
-- Distance
----------------------------------------------------------

function Utilities:GetDistance(A, B)

	return (A - B).Magnitude

end

----------------------------------------------------------
-- Tween Wrapper
----------------------------------------------------------

function Utilities:Tween(Object, TweenInfoValue, Properties)

	return game:GetService("TweenService")
		:Create(Object, TweenInfoValue, Properties)

end

return Utilities
