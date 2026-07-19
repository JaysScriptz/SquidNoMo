local Home = {}

function Home:Create(Page, App)

	local Components = App.Components

	local HeroBanner = App.Loader.HeroBanner
	local FeatureGroups = App.Loader.FeatureGroups
	local ServerStatus = App.Loader.ServerStatus
	local NOMOAI = App.Loader.NOMOAI
	local SupportDevelopment = App.Loader.SupportDevelopment
	local DevelopmentGoal = App.Loader.DevelopmentGoal
	local Supporters = App.Loader.Supporters
	local ImportantNotice = App.Loader.ImportantNotice
	local Footer = App.Loader.Footer


	HeroBanner:Create(Page, App)

	local Row1 = Components:CreateHorizontalContainer(Page)
	Row1.LayoutOrder = 2

	FeatureGroups:Create(Row1, App)
	ServerStatus:Create(Row1, App)
	NOMOAI:Create(Row1, App)

	local Row2 = Components:CreateHorizontalContainer(Page)
	Row2.LayoutOrder = 3

	SupportDevelopment:Create(Row2, App)
	DevelopmentGoal:Create(Row2, App)
	Supporters:Create(Row2, App)

	ImportantNotice:Create(Page, App)
	Footer:Create(Page, App)

end

return Home
