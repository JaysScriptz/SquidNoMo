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
    Id = "player.mute_character_sounds",
    Name = "Mute Character Sounds",
    Description = "Mutes sounds inside the local character and restores their original volume values when disabled.",
    Kind = "MuteSounds",
    Interval = 0.45,
})
