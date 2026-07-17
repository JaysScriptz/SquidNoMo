--//========================================================--
--// SquidNoMo
--// Beta 4.0
--// Notifications.lua
--//========================================================--

local TweenService = game:GetService("TweenService")

local Notifications = {}

Notifications.Container = nil

----------------------------------------------------------
-- Initialize
----------------------------------------------------------

function Notifications:Init(ScreenGui, Theme)

	if self.Container then
		return
	end

	local Container = Instance.new("Frame")

	Container.Name = "Notifications"

	Container.AnchorPoint = Vector2.new(1,0)

	Container.Position = UDim2.new(1,-20,0,20)

	Container.Size = UDim2.fromOffset(320,500)

	Container.BackgroundTransparency = 1

	Container.Parent = ScreenGui

	local Layout = Instance.new("UIListLayout")

	Layout.Padding = UDim.new(0,10)

	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right

	Layout.VerticalAlignment = Enum.VerticalAlignment.Top

	Layout.Parent = Container

	self.Container = Container

	self.Theme = Theme

end

----------------------------------------------------------
-- Create Notification
----------------------------------------------------------

function Notifications:Notify(Title, Message, Type, Duration)

	if not self.Container then
		warn("Notifications not initialized.")
		return
	end

	Duration = Duration or 4

	local Theme = self.Theme

	local Colors = {

		Success = Theme.Success,

		Warning = Theme.Warning,

		Error = Theme.Error,

		Info = Theme.Info

	}

	local Color = Colors[Type] or Theme.Info

	local Card = Instance.new("Frame")

	Card.Size = UDim2.fromOffset(300,82)

	Card.BackgroundColor3 = Theme.Card

	Card.BorderSizePixel = 0

	Card.BackgroundTransparency = 1

	Card.Parent = self.Container

	local Corner = Instance.new("UICorner")

	Corner.CornerRadius = UDim.new(0,12)

	Corner.Parent = Card

	local Stroke = Instance.new("UIStroke")

	Stroke.Color = Color

	Stroke.Thickness = 1.2

	Stroke.Parent = Card

	local TitleLabel = Instance.new("TextLabel")

	TitleLabel.BackgroundTransparency = 1

	TitleLabel.Position = UDim2.fromOffset(14,10)

	TitleLabel.Size = UDim2.new(1,-28,0,20)

	TitleLabel.Font = Theme.FontBold

	TitleLabel.Text = Title

	TitleLabel.TextColor3 = Theme.Text

	TitleLabel.TextSize = 16

	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	TitleLabel.Parent = Card

	local MessageLabel = Instance.new("TextLabel")

	MessageLabel.BackgroundTransparency = 1

	MessageLabel.Position = UDim2.fromOffset(14,34)

	MessageLabel.Size = UDim2.new(1,-28,0,36)

	MessageLabel.Font = Theme.Font

	MessageLabel.TextWrapped = true

	MessageLabel.Text = Message

	MessageLabel.TextColor3 = Theme.SubText

	MessageLabel.TextSize = 13

	MessageLabel.TextXAlignment = Enum.TextXAlignment.Left

	MessageLabel.TextYAlignment = Enum.TextYAlignment.Top

	MessageLabel.Parent = Card

	Card.Position = UDim2.new(1,40,0,0)

	TweenService:Create(
		Card,
		TweenInfo.new(.25, Enum.EasingStyle.Quint),
		{
			BackgroundTransparency = 0
		}
	):Play()

	task.delay(Duration,function()

		TweenService:Create(
			Card,
			TweenInfo.new(.25, Enum.EasingStyle.Quint),
			{
				BackgroundTransparency = 1
			}
		):Play()

		task.wait(.3)

		Card:Destroy()

	end)

end

----------------------------------------------------------
-- Helper Functions
----------------------------------------------------------

function Notifications:Success(Title, Message, Duration)

	self:Notify(Title, Message, "Success", Duration)

end

function Notifications:Warning(Title, Message, Duration)

	self:Notify(Title, Message, "Warning", Duration)

end

function Notifications:Error(Title, Message, Duration)

	self:Notify(Title, Message, "Error", Duration)

end

function Notifications:Info(Title, Message, Duration)

	self:Notify(Title, Message, "Info", Duration)

end

return Notifications
