--//========================================================--
--// SquidNoMo
--// Beta 5.0
--// Shared
--// RoleService.lua
--//========================================================--

local RoleService = {}

----------------------------------------------------------
-- Role Constants
----------------------------------------------------------

RoleService.Roles = {
	Player = "Player",
	Guard = "Guard",
	Detective = "Detective",
	Frontman = "Frontman",
	Unknown = "Unknown"
}

----------------------------------------------------------
-- Get Player Role
----------------------------------------------------------

function RoleService:GetRole(Player)

	------------------------------------------------------
	-- TODO:
	-- Replace this with Squid Game X role detection.
	------------------------------------------------------

	-- Examples:
	-- Player.Team
	-- Player:GetAttribute("Role")
	-- Character values
	-- Server role objects

	return self.Roles.Player

end

----------------------------------------------------------
-- Helper Functions
----------------------------------------------------------

function RoleService:IsPlayer(Player)
	return self:GetRole(Player) == self.Roles.Player
end

function RoleService:IsGuard(Player)
	return self:GetRole(Player) == self.Roles.Guard
end

function RoleService:IsDetective(Player)
	return self:GetRole(Player) == self.Roles.Detective
end

function RoleService:IsFrontman(Player)
	return self:GetRole(Player) == self.Roles.Frontman
end

return RoleService
