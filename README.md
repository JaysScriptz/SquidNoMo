# SquidNoMo v0.5.0 Beta

This build is the visual-stability pass for the SquidNoMo interface. The dashboard has been rebuilt around the approved dark neon design while retaining the existing feature scripts and Players page callbacks.

## Current focus

- Exact dashboard composition
- Consistent triangle branding
- Touch-first responsive scaling
- Stable navigation and page mounting
- Live feature, server, and app diagnostics
- Existing feature code preserved

Feature behavior and the remaining category pages can be expanded after this shell is tested and approved.

## Structure

```text
SquidNoMo-main/
├── Main.lua
├── Loader.lua
├── Config.lua
├── Core/
│   ├── App.lua
│   ├── Theme.lua
│   ├── Icons.lua
│   ├── Components.lua
│   ├── FeatureRegistry.lua
│   ├── RuntimeStats.lua
│   ├── Navigation.lua
│   ├── Notifications.lua
│   └── Utilities.lua
├── Modules/
│   ├── Home.lua
│   ├── Home/
│   │   ├── Hero.lua
│   │   ├── FeatureStats.lua
│   │   └── StatusPanels.lua
│   ├── Games.lua
│   ├── Players.lua
│   ├── Guards.lua
│   ├── Detective.lua
│   ├── Farming.lua
│   ├── UI.lua
│   └── Settings.lua
└── Features/
    ├── FeatureManager.lua
    ├── Shared/
    └── Player/
```

## Dashboard behavior

- The corner triangle button is always available and toggles the window open or minimized.
- The same triangle mark is reused in the corner button, sidebar identity, hero banner, and hero minimize control.
- The Home page has no separate title bar.
- Games appears above Players in navigation.
- UI replaces VIP.
- Feature Stats reads the current state of the existing coded settings rather than using hardcoded numbers.
- The warning text is intentionally concise and makes no safety claim.

## Configuration

`Config.lua` contains the repository URL, version information, and optional support URL. Set `Config.SupportUrl` when a public project-support page is ready.

## Testing checklist

1. Upload the folder contents to the configured repository path.
2. Run `Main.lua` in the intended client environment.
3. Confirm the corner logo toggles the dashboard.
4. Drag the dashboard from the hero or sidebar brand area.
5. Test on landscape phone, tablet, and desktop sizes.
6. Open Players and confirm the existing sliders, toggles, and buttons still call their original feature objects.
7. Confirm Feature Stats updates after changing a tracked setting.
