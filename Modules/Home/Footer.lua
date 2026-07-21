local Footer = {}

function Footer:Create(Parent, App)

	local Theme = App.Theme

	local FooterFrame = Instance.new("Frame")
	FooterFrame.Name = "Footer"
	FooterFrame.Size = UDim2.new(1,0,0,36)
	FooterFrame.BackgroundTransparency = 1
	FooterFrame.LayoutOrder = 100
	FooterFrame.Parent = Parent

	local Left = Instance.new("TextLabel")
	Left.BackgroundTransparency = 1
	Left.Size = UDim2.new(.5,0,1,0)
	Left.Font = Theme.Font
	Left.Text = "SquidNoMo • " .. tostring(Theme.Version)
	Left.TextSize = 13
	Left.TextColor3 = Theme.SubText
	Left.TextXAlignment = Enum.TextXAlignment.Left
	Left.Parent = FooterFrame

	local Right = Instance.new("TextLabel")
	Right.BackgroundTransparency = 1
	Right.AnchorPoint = Vector2.new(1,0)
	Right.Position = UDim2.new(1,0,0,0)
	Right.Size = UDim2.new(.5,0,1,0)
	Right.Font = Theme.Font
	Right.Text = "github.com/JaysScriptz"
	Right.TextSize = 13
	Right.TextColor3 = Theme.SubText
	Right.TextXAlignment = Enum.TextXAlignment.Right
	Right.Parent = FooterFrame

	return FooterFrame

end

return Footer
