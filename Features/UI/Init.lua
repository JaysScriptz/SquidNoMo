local UI = {}

function UI:Initialize(Loader)
    local function Load(name)
        return loadstring(game:HttpGet(
            Loader.Config.Repository .. "Features/UI/" .. name .. ".lua"
        ))()
    end

    local CoreGuiToggle = Load("CoreGuiToggle")

    self.Crosshair = Load("Crosshair")
    self.PerformanceHUD = Load("PerformanceHUD")
    self.RoleLegend = Load("RoleLegend")

    self.HideChat = CoreGuiToggle.new(Enum.CoreGuiType.Chat)
    self.HidePlayerList = CoreGuiToggle.new(Enum.CoreGuiType.PlayerList)
    self.HideBackpack = CoreGuiToggle.new(Enum.CoreGuiType.Backpack)

    self.RemoveBlur = Load("RemoveBlur")
    self.Fullbright = Load("Fullbright")
    self.ScreenEffects = Load("ScreenEffects")

    local manager = Loader.FeatureManager
    if manager and type(manager.RegisterFeature) == "function" then
        manager:RegisterFeature("ui.crosshair", self.Crosshair, {Name = "Crosshair", Category = "Safe"})
        manager:RegisterFeature("ui.performance_hud", self.PerformanceHUD, {Name = "Performance HUD", Category = "Safe"})
        manager:RegisterFeature("ui.role_legend", self.RoleLegend, {Name = "Role Legend", Category = "Safe"})
        manager:RegisterFeature("ui.hide_chat", self.HideChat, {Name = "Hide Chat", Category = "Safe"})
        manager:RegisterFeature("ui.hide_player_list", self.HidePlayerList, {Name = "Hide Player List", Category = "Safe"})
        manager:RegisterFeature("ui.hide_backpack", self.HideBackpack, {Name = "Hide Backpack", Category = "Safe"})
        manager:RegisterFeature("ui.remove_blur", self.RemoveBlur, {Name = "Remove Blur", Category = "Safe"})
        manager:RegisterFeature("ui.fullbright", self.Fullbright, {Name = "Fullbright", Category = "SemiSafe"})
        manager:RegisterFeature("ui.screen_effects", self.ScreenEffects, {Name = "Disable Screen Effects", Category = "SemiSafe"})
    end

    return self
end

return UI
