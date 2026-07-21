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
    Id = "player.frontman_esp",
    Name = "Frontman ESP",
    Description = "Highlights players whose role data identifies them as the Frontman, host, or game master.",
    Kind = "PlayerHighlight",
    RoleTokens = {"frontman", "front man", "host", "gamemaster", "game master"},
    DefaultColor = Color3.fromRGB(172, 76, 255),
    FillTransparency = 0.45,
})
