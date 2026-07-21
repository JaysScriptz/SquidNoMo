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
    Id = "player.detective_esp",
    Name = "Detective ESP",
    Description = "Highlights players whose team, role, attributes, or character identify them as detectives or investigators.",
    Kind = "PlayerHighlight",
    RoleTokens = {"detective", "investigator", "police"},
    DefaultColor = Color3.fromRGB(0, 230, 150),
    FillTransparency = 0.48,
})
