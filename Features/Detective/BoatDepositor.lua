local Environment = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then
        Environment = result
    end
end

local Runtime = Environment.__SquidNoMoFeatureRuntime
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    local repository = "https://raw.githubusercontent.com/JaysScriptz/SquidNoMo/main/"
    local source = game:HttpGet(repository .. "Features/Shared/Runtime.lua?squidnomo_revision=1_1b1_ultralight_r4")
    Runtime = loadstring(source)()
end
if type(Runtime) ~= "table" or Runtime.Revision ~= "1.1b1-ultralight-r4" then
    error("SquidNoMo feature runtime revision mismatch; deploy the complete build")
end

return Runtime:CreateFeature({
    Id = "mapped.detective.boat_operations.boatdepositor",
    Name = "Boat Depositor",
    Description = "Walks evidence back to the boat and deposits supported evidence tools.",
    Kind = "TaskChain",
    RequireToolTokens = {"evidence", "clue", "file", "document", "keycard"},
    SourceTokens = {"evidence", "clue", "file", "document", "keycard"},
    DestinationTokens = {"boat", "deposit", "submit", "evidence box", "dock"},
    SourceLabel = "evidence",
    DestinationLabel = "boat evidence deposit",
    InteractDistance = 12,
    ActionCooldown = 0.9,
    MovementPriority = 90,
    ActionPriority = 85,
})
