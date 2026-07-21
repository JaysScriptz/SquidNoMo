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
    Id = "player.gravity",
    Name = "Gravity",
    Description = "Applies the selected local Workspace gravity value while enabled and restores the previous value when disabled.",
    Kind = "WorkspaceValue",
    Property = "Gravity",
    EnabledValue = 120,
    DefaultValue = 196.2,
    Min = 20,
    Max = 300,
    Interval = 0.2,
})
