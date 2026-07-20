local RoleService = {}

RoleService.Roles = {
    Player = "Player",
    Guard = "Guard",
    Detective = "Detective",
    Frontman = "Frontman",
    Unknown = "Unknown",
}

local function normalize(value)
    local text = string.lower(tostring(value or ""))
    text = string.gsub(text, "[%s_%-]", "")

    if string.find(text, "frontman", 1, true) or string.find(text, "manager", 1, true) then
        return RoleService.Roles.Frontman
    elseif string.find(text, "detective", 1, true) or string.find(text, "police", 1, true) then
        return RoleService.Roles.Detective
    elseif string.find(text, "guard", 1, true) or string.find(text, "soldier", 1, true) or string.find(text, "staff", 1, true) then
        return RoleService.Roles.Guard
    elseif string.find(text, "player", 1, true) or string.find(text, "contestant", 1, true) then
        return RoleService.Roles.Player
    end

    return nil
end

function RoleService:GetRole(player)
    if not player then
        return self.Roles.Unknown
    end

    local candidates = {}
    for _, attributeName in ipairs({"Role", "role", "TeamRole", "PlayerRole", "Class"}) do
        local ok, value = pcall(function()
            return player:GetAttribute(attributeName)
        end)
        if ok and value ~= nil then
            table.insert(candidates, value)
        end
    end

    if player.Team then
        table.insert(candidates, player.Team.Name)
    end

    local character = player.Character
    if character then
        for _, attributeName in ipairs({"Role", "role", "TeamRole", "PlayerRole", "Class"}) do
            local ok, value = pcall(function()
                return character:GetAttribute(attributeName)
            end)
            if ok and value ~= nil then
                table.insert(candidates, value)
            end
        end

        for _, valueName in ipairs({"Role", "TeamRole", "PlayerRole", "Class"}) do
            local object = character:FindFirstChild(valueName)
            if object and object:IsA("ValueBase") then
                table.insert(candidates, object.Value)
            end
        end
    end

    for _, candidate in ipairs(candidates) do
        local role = normalize(candidate)
        if role then
            return role
        end
    end

    return self.Roles.Player
end

function RoleService:IsPlayer(player)
    return self:GetRole(player) == self.Roles.Player
end

function RoleService:IsGuard(player)
    return self:GetRole(player) == self.Roles.Guard
end

function RoleService:IsDetective(player)
    return self:GetRole(player) == self.Roles.Detective
end

function RoleService:IsFrontman(player)
    return self:GetRole(player) == self.Roles.Frontman
end

return RoleService
