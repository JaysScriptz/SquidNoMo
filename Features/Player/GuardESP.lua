local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoPlayerRuntime
if type(Runtime) ~= "table" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/PlayerRuntime.lua?squidnomo_revision=1_1b1_player_recode_r1")
    Runtime = loadstring(source)()
end

return Runtime:CreateFeature({
    Id = "player.guard_esp",
    Name = "Guard ESP",
    Description = "Highlights players whose team, role, attributes, or character identify them as guards or staff.",
    Kind = "PlayerHighlight",
    RoleTokens = {"guard", "staff", "soldier", "worker"},
    DefaultColor = Color3.fromRGB(235, 55, 70),
    FillTransparency = 0.48,
})
