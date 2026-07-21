-- SquidNoMo player module registry
-- Every file under Features/Player is loaded and registered here.

local Player = {}

function Player:Initialize(Loader)
    local function LoadPath(path)
        if type(Loader.LoadRemote) == "function" then
            return Loader:LoadRemote(path)
        end
        return loadstring(game:HttpGet(Loader.Config.Repository .. path))()
    end

    local function Load(name)
        return LoadPath("Features/Player/" .. name .. ".lua")
    end

    -- Load shared implementations first so every player wrapper resolves the
    -- same runtime instance instead of creating duplicate event loops.
    self.Runtime = Loader.Features
        and Loader.Features.Shared
        and Loader.Features.Shared.PlayerRuntime
        or LoadPath("Features/Shared/PlayerRuntime.lua")

    self.WalkSpeed = Load("WalkSpeed")
    self.JumpPower = Load("JumpPower")
    self.Gravity = Load("Gravity")
    self.InfiniteJump = Load("InfiniteJump")
    self.AutoJump = Load("AutoJump")
    self.Noclip = Load("NoClip")
    self.ForceThirdPerson = Load("ForceThirdPerson")
    self.UnlockZoom = Load("UnlockZoom")
    self.AutoStand = Load("AutoStand")

    self.PlayerESP = Load("PlayerESP")
    self.GuardESP = Load("GuardESP")
    self.DetectiveESP = Load("DetectiveESP")
    self.FrontmanESP = Load("FrontmanESP")
    self.DistanceESP = Load("DistanceESP")
    self.HealthESP = Load("HealthESP")
    self.NameESP = Load("NameESP")
    self.BoxESP = Load("BoxESP")

    self.AntiAFK = Load("AntiAFK")
    self.AntiLag = Load("AntiLag")
    self.HideOthers = Load("HideOthers")
    self.HideSelf = Load("HideSelf")
    self.ToolESP = Load("ToolESP")
    self.MuteCharacterSounds = Load("MuteCharacterSounds")
    self.Reset = Load("Reset")
    self.Rejoin = Load("Rejoin")

    for _, feature in pairs(self) do
        if type(feature) == "table" and type(feature.Initialize) == "function" then
            pcall(feature.Initialize, feature, Loader)
        end
    end

    local manager = Loader.FeatureManager
    if not manager or type(manager.RegisterFeature) ~= "function" then
        return self
    end

    local function Register(id, feature, options)
        options = options or {}
        options.Description = options.Description or feature.Description
        manager:RegisterFeature(id, feature, options)
    end

    Register("player.walk_speed", self.WalkSpeed, {
        Name = "Walk Speed", Category = "SemiSafe", DefaultValue = 16,
    })
    Register("player.jump_power", self.JumpPower, {
        Name = "Jump Power", Category = "SemiSafe", DefaultValue = 50,
    })
    Register("player.gravity", self.Gravity, {
        Name = "Gravity", Category = "SemiSafe", DefaultValue = 196.2,
    })
    Register("player.infinite_jump", self.InfiniteJump, {
        Name = "Infinite Jump", Category = "SemiSafe",
    })
    Register("player.auto_jump", self.AutoJump, {
        Name = "Auto Jump", Category = "SemiSafe",
    })
    Register("player.noclip", self.Noclip, {
        Name = "Noclip", Category = "Experimental",
    })
    Register("player.force_third_person", self.ForceThirdPerson, {
        Name = "Force Third Person", Category = "Safe",
    })
    Register("player.unlock_zoom", self.UnlockZoom, {
        Name = "Unlock Camera Zoom", Category = "Safe",
    })
    Register("player.auto_stand", self.AutoStand, {
        Name = "Auto Stand", Category = "Safe",
    })

    Register("player.player_esp", self.PlayerESP, {
        Name = "Player ESP", Category = "Safe", DefaultColor = Color3.fromRGB(0, 170, 255),
    })
    Register("player.guard_esp", self.GuardESP, {
        Name = "Guard ESP", Category = "Safe", DefaultColor = Color3.fromRGB(235, 55, 70),
    })
    Register("player.detective_esp", self.DetectiveESP, {
        Name = "Detective ESP", Category = "Safe", DefaultColor = Color3.fromRGB(0, 230, 150),
    })
    Register("player.frontman_esp", self.FrontmanESP, {
        Name = "Frontman ESP", Category = "Safe", DefaultColor = Color3.fromRGB(172, 76, 255),
    })
    Register("player.distance_esp", self.DistanceESP, {
        Name = "Distance ESP", Category = "Safe", DefaultColor = Color3.fromRGB(0, 205, 255),
    })
    Register("player.health_esp", self.HealthESP, {
        Name = "Health ESP", Category = "Safe", DefaultColor = Color3.fromRGB(255, 82, 82),
    })
    Register("player.name_esp", self.NameESP, {
        Name = "Name ESP", Category = "Safe", DefaultColor = Color3.fromRGB(245, 245, 255),
    })
    Register("player.box_esp", self.BoxESP, {
        Name = "Box ESP", Category = "Safe", DefaultColor = Color3.fromRGB(255, 210, 60),
    })

    Register("player.anti_afk", self.AntiAFK, {
        Name = "Anti AFK", Category = "Safe",
    })
    Register("player.anti_lag", self.AntiLag, {
        Name = "Anti Lag", Category = "Safe",
    })
    Register("player.hide_others", self.HideOthers, {
        Name = "Hide Other Players", Category = "Safe",
    })
    Register("player.hide_self", self.HideSelf, {
        Name = "Hide Local Character", Category = "Safe",
    })
    Register("player.tool_esp", self.ToolESP, {
        Name = "Tool ESP", Category = "Safe", DefaultColor = Color3.fromRGB(255, 210, 60),
    })
    Register("player.mute_character_sounds", self.MuteCharacterSounds, {
        Name = "Mute Character Sounds", Category = "Safe",
    })
    Register("player.reset", self.Reset, {
        Name = "Reset Character", Category = "Safe",
    })
    Register("player.rejoin", self.Rejoin, {
        Name = "Rejoin Server", Category = "Safe",
    })

    return self
end

return Player
