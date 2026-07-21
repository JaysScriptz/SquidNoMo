# Ultralight Module Stability Matrix

Build: **1.1 beta 1** / `ultralight-stable-r4`

Every module below returns the shared feature interface and is revision-locked to the matching runtime. “Static status” means the implementation shape, cleanup path, dependencies, and catalog wiring passed inspection; live game object names still require in-server validation.

## Games

| Module | Kind | Interval | Priority | Stability work |
|---|---:|---:|---:|---|
| `Features/Games/Dalgona/AutoCut.lua`<br>**Auto Cut** | `GuiAction` | 0.12s | action 55 | Shared GUI input lease and cooldown; timestamp updates only after a successful action. |
| `Features/Games/Dalgona/AutoLighter.lua`<br>**Auto Lighter** | `ToolActivate` | 0.3s | action 45 | Find/equip first, then claims the tool-action lease. |
| `Features/Games/Dalgona/HighlightESP.lua`<br>**Shape Highlight** | `GuiHighlight` | event | shared/default | Cached visible-GUI search; no per-frame scan. |
| `Features/Games/Dalgona/TaceHelper.lua`<br>**Trace Helper** | `GuiHighlight` | event | shared/default | Cached visible-GUI search; no per-frame scan. |
| `Features/Games/Escape/IslandNav.lua`<br>**Island Extraction Route** | `WalkTo` | event | move 70 | Cached target search and movement lease; path is recomputed only when needed. |
| `Features/Games/GlassBridge/AntiFall.lua`<br>**Anti Fall** | `AntiFall` | event | recover 85 | Shared ground sample and recovery lease prevent duplicate recovery loops. |
| `Features/Games/GlassBridge/AutoComplete.lua`<br>**Auto Complete** | `SafeTileWalk` | 0.32s | move 75 | Cached panel discovery and coordinated pathing. |
| `Features/Games/GlassBridge/AutoReset.lua`<br>**Auto Reset** | `AntiFall` | event | recover 60 | Shared ground sample and recovery lease prevent duplicate recovery loops. |
| `Features/Games/GlassBridge/GlassESP.lua`<br>**Glass ESP** | `GlassESP` | 0.75s | shared/default | Throttled indexed panel scan; markers are reused. |
| `Features/Games/HideSeek/AutoGrabKey.lua`<br>**Auto Grab Key** | `WalkTo` | event | move 70 | Cached target search and movement lease; path is recomputed only when needed. |
| `Features/Games/HideSeek/AutoGrabKnife.lua`<br>**Auto Grab Knife** | `WalkTo` | event | move 65 | Cached target search and movement lease; path is recomputed only when needed. |
| `Features/Games/HideSeek/AutoPathToExit.lua`<br>**Auto Path to Exit** | `WalkTo` | event | move 85 | Cached target search and movement lease; path is recomputed only when needed. |
| `Features/Games/HideSeek/AutoSwing.lua`<br>**Auto Swing** | `ToolAura` | 0.24s | action 70 | Cached nearby-player search and shared combat/tool action lease. |
| `Features/Games/HideSeek/EnemyESP.lua`<br>**Enemy ESP** | `Highlight` | event | shared/default | Cached target list; creates each highlight once and cleans dead targets. |
| `Features/Games/HideSeek/ExitESP.lua`<br>**Exit ESP** | `Highlight` | event | shared/default | Cached target list; creates each highlight once and cleans dead targets. |
| `Features/Games/HideSeek/HunterTracker.lua`<br>**Hunter Tracker** | `Highlight` | event | shared/default | Cached target list; creates each highlight once and cleans dead targets. |
| `Features/Games/HideSeek/MapRadar.lua`<br>**Map Radar** | `Radar` | event | shared/default | Timed refresh; no RenderStepped connection. |
| `Features/Games/JumpRope/AutoComplete.lua`<br>**Auto Complete** | `CourseAssist` | event | move 70 | Cached course objective discovery and movement lease. |
| `Features/Games/JumpRope/AutoJump.lua`<br>**Auto Jump** | `AutoJump` | 0.1s | shared/default | Timed state check; no per-frame connection. |
| `Features/Games/JumpRope/AutoPosition.lua`<br>**Auto Position** | `PositionKeeper` | 0.22s | move 25 | Low-priority correction that yields to objective movement. |
| `Features/Games/JumpRope/JumpBoost.lua`<br>**Jump Boost** | `JumpBoost` | 0.35s | shared/default | Writes only when the configured value differs. |
| `Features/Games/JumpRope/RopeBypass.lua`<br>**Rope Bypass** | `RopeBypass` | 0.8s | shared/default | Throttled indexed obstacle scan. |
| `Features/Games/Marbles/MarbleAimer.lua`<br>**Marble Aimer** | `AimActivate` | 0.2s | action 60 | Shared aim/tool lease prevents competing aim actions. |
| `Features/Games/Marbles/MarblesESP.lua`<br>**Marbles ESP** | `Highlight` | event | shared/default | Cached target list; creates each highlight once and cleans dead targets. |
| `Features/Games/Marbles/RecoveryAssist.lua`<br>**Recovery Assist** | `PositionKeeper` | 0.25s | shared/default | Low-priority correction that yields to objective movement. |
| `Features/Games/Marbles/RingShooter.lua`<br>**Ring Shooter** | `AimActivate` | 0.2s | action 75 | Shared aim/tool lease prevents competing aim actions. |
| `Features/Games/Mingle/AutoRoom.lua`<br>**Auto Room** | `RoomAssist` | 0.4s | move 55 | Coordinated room selection/pathing with category-specific priority. |
| `Features/Games/Mingle/RoomESP.lua`<br>**Room ESP** | `Highlight` | event | shared/default | Cached target list; creates each highlight once and cleans dead targets. |
| `Features/Games/Mingle/SmartRoom.lua`<br>**Smart Room** | `RoomAssist` | 0.32s | move 75 | Coordinated room selection/pathing with category-specific priority. |
| `Features/Games/NightBrawls/BrawlESP.lua`<br>**Brawl ESP** | `Highlight` | event | shared/default | Cached target list; creates each highlight once and cleans dead targets. |
| `Features/Games/NightBrawls/BrawlEvasion.lua`<br>**Brawl Evasion** | `Evasion` | 0.24s | move 75 | Movement lease prevents conflict with other route features. |
| `Features/Games/NightBrawls/CombatAura.lua`<br>**Combat Aura** | `ToolAura` | 0.22s | action 65 | Cached nearby-player search and shared combat/tool action lease. |
| `Features/Games/Pentathlon/Biseokchigi.lua`<br>**Biseokchigi Assist** | `Timing` | event | action 85 | Specialized timing lease blocks blind lower-priority GUI spam while a meter is active. |
| `Features/Games/Pentathlon/Ddakji.lua`<br>**Ddakji Assist** | `Timing` | event | action 85 | Specialized timing lease blocks blind lower-priority GUI spam while a meter is active. |
| `Features/Games/Pentathlon/Gonggi.lua`<br>**Gonggi Assist** | `GuiAction` | 0.12s | action 65 | Shared GUI input lease and cooldown; timestamp updates only after a successful action. |
| `Features/Games/Pentathlon/Jegichagi.lua`<br>**Jegichagi Assist** | `Timing` | event | action 85 | Specialized timing lease blocks blind lower-priority GUI spam while a meter is active. |
| `Features/Games/Pentathlon/Paengi.lua`<br>**Paengi Assist** | `Timing` | event | action 85 | Specialized timing lease blocks blind lower-priority GUI spam while a meter is active. |
| `Features/Games/RLGL/AntiStuck.lua`<br>**Anti Stuck** | `AntiStuck` | 0.35s | shared/default | Green-only recovery; lower priority than Auto Move; no speed mutation. |
| `Features/Games/RLGL/AutoMove.lua`<br>**Auto Move** | `RLGLAutoMove` | 0.1s | move 95 | Verified green-only movement; red/unknown fail closed; top RLGL movement priority. |
| `Features/Games/RLGL/DollESP.lua`<br>**Doll ESP** | `Highlight` | event | shared/default | Cached target list; creates each highlight once and cleans dead targets. |
| `Features/Games/RLGL/SafeZoneESP.lua`<br>**Safe Zone ESP** | `Highlight` | event | shared/default | Cached target list; creates each highlight once and cleans dead targets. |
| `Features/Games/RLGL/StateESP.lua`<br>**State ESP** | `StateHUD` | 0.12s | shared/default | Shared verified RLGL state source. |
| `Features/Games/Rebellion/FrontmanNavigator.lua`<br>**Frontman Navigator** | `WalkTo` | event | move 60 | Cached target search and movement lease; path is recomputed only when needed. |
| `Features/Games/Rebellion/GuardCombat.lua`<br>**Guard Combat** | `ToolAura` | 0.22s | action 70 | Cached nearby-player search and shared combat/tool action lease. |
| `Features/Games/RockPaperScissors/AutoPlay.lua`<br>**Auto Play** | `RPSAutoPlay` | 0.35s | shared/default | Throttled visible-button scan and GUI action lease. |
| `Features/Games/SkySquid/AntiFall.lua`<br>**Anti Fall** | `AntiFall` | event | recover 75 | Shared ground sample and recovery lease prevent duplicate recovery loops. |
| `Features/Games/SkySquid/AutoFight.lua`<br>**Auto Fight** | `ToolAura` | 0.22s | action 60 | Cached nearby-player search and shared combat/tool action lease. |
| `Features/Games/SkySquid/AutoPush.lua`<br>**Auto Push** | `ToolAura` | 0.24s | action 75 | Cached nearby-player search and shared combat/tool action lease. |
| `Features/Games/SkySquid/InstantGrab.lua`<br>**Instant Grab** | `Interact` | event | shared/default | Cached target search; claims the interaction channel only for a supported target. |
| `Features/Games/Squid game/CourtBoundaryKeeper.lua`<br>**Court Boundary Keeper** | `Boundary` | 0.28s | move 70 | Movement lease and cached boundary lookup. |
| `Features/Games/Squid game/SquidGamePush.lua`<br>**Squid Game Push** | `ToolAura` | 0.24s | action 70 | Cached nearby-player search and shared combat/tool action lease. |
| `Features/Games/TugOfWar/AutoPull.lua`<br>**Auto Pull** | `GuiAction` | 0.09s | action 40 | Shared GUI input lease and cooldown; timestamp updates only after a successful action. |
| `Features/Games/TugOfWar/Perfect timing.lua`<br>**Perfect Timing** | `Timing` | event | action 90 | Specialized timing lease blocks blind lower-priority GUI spam while a meter is active. |

## Guard

| Module | Kind | Interval | Priority | Stability work |
|---|---:|---:|---:|---|
| `Features/Guard/Coffin/CoffinDisposal.lua`<br>**Coffin Disposal** | `TaskChain` | event | move 80, action 75 | Source/destination pipeline with separate movement and interaction priorities. |
| `Features/Guard/Coffin/CoffinGrabber.lua`<br>**Coffin Grabber** | `Interact` | event | move 55, action 55 | Cached target search; claims the interaction channel only for a supported target. |
| `Features/Guard/Kitchen/AutoCooker.lua`<br>**Auto Cooker** | `TaskChain` | event | move 75, action 70 | Source/destination pipeline with separate movement and interaction priorities. |
| `Features/Guard/Kitchen/AutoStorage.lua`<br>**Auto Storage** | `TaskChain` | event | move 85, action 80 | Source/destination pipeline with separate movement and interaction priorities. |
| `Features/Guard/Kitchen/AutoSupply.lua`<br>**Auto Supply** | `Interact` | event | move 50, action 50 | Cached target search; claims the interaction channel only for a supported target. |
| `Features/Guard/Player Moderation/GuardLocalCleanup.lua`<br>**Guard Local Cleanup** | `Interact` | event | shared/default | Cached target search; claims the interaction channel only for a supported target. |
| `Features/Guard/Player Moderation/GuardLocalModerator.lua`<br>**Guard Local Moderator** | `ToolAura` | 0.22s | shared/default | Cached nearby-player search and shared combat/tool action lease. |

## Detective

| Module | Kind | Interval | Priority | Stability work |
|---|---:|---:|---:|---|
| `Features/Detective/BoatDepositor.lua`<br>**Boat Depositor** | `TaskChain` | event | move 90, action 85 | Source/destination pipeline with separate movement and interaction priorities. |
| `Features/Detective/DisguiseManager.lua`<br>**Disguise Manager** | `Disguise` | 0.5s | shared/default | Throttled target interaction with cleanup. |
| `Features/Detective/EvidenceCollector.lua`<br>**Evidence Collector** | `Interact` | event | move 70, action 70 | Cached target search; claims the interaction channel only for a supported target. |
| `Features/Detective/EvidenceESP.lua`<br>**Evidence ESP** | `Highlight` | event | shared/default | Cached target list; creates each highlight once and cleans dead targets. |
| `Features/Detective/IslandNavigator.lua`<br>**Island Navigator** | `WalkTo` | event | move 55 | Cached target search and movement lease; path is recomputed only when needed. |

## Player

| Module | Kind | Interval | Priority | Stability work |
|---|---:|---:|---:|---|
| `Features/Player/AntiAFK.lua`<br>**Anti AFK** | `AntiAFK` | event | shared/default | Single idle connection. |
| `Features/Player/AntiLag.lua`<br>**Anti Lag** | `AntiLag` | 1.2s | shared/default | Cooperative batch scan plus incremental updates. |
| `Features/Player/AutoJump.lua`<br>**Auto Jump** | `AutoJump` | 0.08s | shared/default | Timed state check; no per-frame connection. |
| `Features/Player/AutoStand.lua`<br>**Auto Stand** | `AutoStand` | event | shared/default | Timed state correction. |
| `Features/Player/BoxESP.lua`<br>**Box ESP** | `PlayerHighlight` | event | shared/default | Cached player target set and reused markers. |
| `Features/Player/DetectiveESP.lua`<br>**Detective ESP** | `PlayerHighlight` | event | shared/default | Cached player target set and reused markers. |
| `Features/Player/DistanceESP.lua`<br>**Distance ESP** | `PlayerBillboard` | 0.32s | shared/default | Staggered timed refresh and reused labels. |
| `Features/Player/ForceThirdPerson.lua`<br>**Force Third Person** | `ForceThirdPerson` | event | shared/default | Property restoration on disable. |
| `Features/Player/FrontmanESP.lua`<br>**Frontman ESP** | `PlayerHighlight` | event | shared/default | Cached player target set and reused markers. |
| `Features/Player/Gravity.lua`<br>**Gravity** | `WorkspaceValue` | 0.2s | shared/default | Changed-value writes only with restoration. |
| `Features/Player/GuardESP.lua`<br>**Guard ESP** | `PlayerHighlight` | event | shared/default | Cached player target set and reused markers. |
| `Features/Player/HealthESP.lua`<br>**Health ESP** | `PlayerBillboard` | 0.32s | shared/default | Staggered timed refresh and reused labels. |
| `Features/Player/HideOthers.lua`<br>**Hide Other Players** | `HideCharacters` | 0.35s | shared/default | Event-driven character/descendant updates. |
| `Features/Player/HideSelf.lua`<br>**Hide Local Character** | `HideCharacters` | 0.25s | shared/default | Event-driven character/descendant updates. |
| `Features/Player/InfiniteJump.lua`<br>**Infinite Jump** | `InfiniteJump` | event | shared/default | One input connection; disconnected on disable. |
| `Features/Player/JumpPower.lua`<br>**Jump Power** | `HumanoidValue` | 0.1s | shared/default | Event-driven character binding with slow fallback and changed-value writes only. |
| `Features/Player/MuteCharacterSounds.lua`<br>**Mute Character Sounds** | `MuteSounds` | 0.45s | shared/default | Event-driven character sound tracking. |
| `Features/Player/NameESP.lua`<br>**Name ESP** | `PlayerBillboard` | 0.9s | shared/default | Staggered timed refresh and reused labels. |
| `Features/Player/NoClip.lua`<br>**Noclip** | `NoClip` | event | shared/default | Character-part cache maintained by events. |
| `Features/Player/PlayerESP.lua`<br>**Player ESP** | `PlayerHighlight` | event | shared/default | Cached player target set and reused markers. |
| `Features/Player/Rejoin.lua`<br>**Rejoin Server** | `Action` | event | shared/default | One-shot action; does not leave a loop running. |
| `Features/Player/Reset.lua`<br>**Reset Character** | `Action` | event | shared/default | One-shot action; does not leave a loop running. |
| `Features/Player/ToolESP.lua`<br>**Tool ESP** | `ToolESP` | 0.95s | shared/default | Shared object index plus incremental workspace updates. |
| `Features/Player/UnlockZoom.lua`<br>**Unlock Camera Zoom** | `UnlockZoom` | event | shared/default | Property restoration on disable. |
| `Features/Player/WalkSpeed.lua`<br>**Walk Speed** | `HumanoidValue` | 0.1s | shared/default | Event-driven character binding with slow fallback and changed-value writes only. |

