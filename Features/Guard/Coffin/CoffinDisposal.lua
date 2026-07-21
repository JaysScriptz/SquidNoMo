local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/Runtime.lua?squidnomo_revision=1_1b1_feature_recode_r2")
    Runtime = loadstring(source)()
end

return Runtime:CreateFeature({
    Id = "mapped.guards.morgue_staff.coffindisposal",
    Name = "Coffin Disposal",
    Description = "Carries detected coffin or body tools toward the disposal area.",
    Kind = "TaskChain",
    RequireToolTokens = {"coffin", "body", "corpse"},
    SourceTokens = {"coffin", "body", "corpse"},
    DestinationTokens = {"dispose", "disposal", "incinerator", "furnace", "burn", "drop"},
    SourceLabel = "coffin or body",
    DestinationLabel = "disposal area",
    InteractDistance = 12,
    ActionCooldown = 0.9,
})
