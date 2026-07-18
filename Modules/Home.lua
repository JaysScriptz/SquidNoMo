local HeroBanner = require(script.Home.HeroBanner)
local FeatureGroups = require(script.Home.FeatureGroups)
local ServerStatus = require(script.Home.ServerStatus)
local NOMOAI = require(script.Home.NOMOAI)
local SupportDevelopment = require(script.Home.SupportDevelopment)
local DevelopmentGoal = require(script.Home.DevelopmentGoal)
local Supporters = require(script.Home.Supporters)
local ImportantNotice = require(script.Home.ImportantNotice)
local Footer = require(script.Home.Footer)

local Home = {}

function Home:Create(Page, App)

	local Components = App.Components

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0,16)
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Parent = Page

	HeroBanner:Create(Page, App)

	local Row1 = Components:CreateHorizontalContainer(Page)

	FeatureGroups:Create(Row1, App)
	ServerStatus:Create(Row1, App)
	NOMOAI:Create(Row1, App)

	local Row2 = Components:CreateHorizontalContainer(Page)

	SupportDevelopment:Create(Row2, App)
	DevelopmentGoal:Create(Row2, App)
	Supporters:Create(Row2, App)

	ImportantNotice:Create(Page, App)

	Footer:Create(Page, App)

end

return Home
