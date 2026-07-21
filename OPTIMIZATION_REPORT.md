# SquidNoMo 1.1 beta 1 — Ultralight Stability Report

**Build revision:** `ultralight-stable-r4`  
**Feature runtime:** `1.1b1-ultralight-r4`  
**Player runtime:** `1.1b1-player-ultralight-r3`

## What changed

This pass rebuilds the hot execution path used by Games, Guard, Detective, and Player features. The goal is to keep many enabled options from competing for the same frame, movement input, tool input, or workspace scan.

### Shared scheduling

- Games, Guard, Detective, and Player features use one cooperative scheduler.
- Lightweight mode launches at most three due feature jobs per scheduler cycle.
- Features that are waiting for a map object automatically back off to a slower idle interval.
- Disabling a feature immediately removes its scheduler task, movement lease, action leases, connections, temporary instances, and recovery state.

### Incremental object index

- Repeated `Workspace:GetDescendants()` searches were replaced by a shared class index.
- The initial Workspace, ReplicatedStorage, and PlayerGui index is built in batches while the loader is still visible.
- `DescendantAdded` and `DescendantRemoving` maintain the index afterward.
- Feature searches are cached and usually inspect only relevant class buckets such as tools, prompts, parts, models, or GUI controls.

### Conflict prevention

- Movement features use a priority lease, so two enabled pathing features cannot repeatedly pull the character in opposite directions.
- GUI, combat, aim, tool, interaction, and recovery actions have separate priority leases.
- Glass Bridge recovery options share one recovery channel.
- Mingle, Hide & Seek, Detective, Guard kitchen, Guard morgue, and combat features have explicit priorities.
- Tool and interaction leases are claimed only after a usable tool or interaction has been found.

### Auto Apply per Game

The Settings page includes **Auto Apply per Game**. When enabled:

1. A game feature toggle becomes a remembered profile choice.
2. Only chosen features for the detected game are loaded and enabled.
3. Loaded features from other game categories are disabled.
4. If the round cannot be identified after a four-second grace period, game features are paused.
5. Guard and Detective tools remain manual because they are role-specific rather than minigame profiles.

Detection now gives high weight to visible round text and current-round values, while static map folders are weak evidence. Ambiguous detections fail closed instead of switching categories repeatedly.

## RLGL correction

The reported slow-walk problem was caused by overlapping movement behavior and unreliable state selection. The RLGL path was rewritten:

- RLGL code does **not** assign `Humanoid.WalkSpeed`.
- Auto Move only issues `Humanoid:MoveTo` while a verified green signal is stable.
- Red immediately stops the movement owner; unknown or conflicting state stops Auto Move and waits.
- Anti Stuck runs only during verified green and has lower movement priority than Auto Move.
- Hidden, transparent, zero-size, or disabled GUI labels are ignored.
- All live red/green candidates are scored. If old red and green labels remain visible together, the result becomes Unknown rather than choosing the first object.
- State changes use a short stabilization window to avoid flicker.

## Whole-build performance work

- Player ESP refresh rates are staggered and target lists are cached.
- Hide Character features are event-driven instead of repeatedly rescanning characters.
- Tool ESP reuses the shared object index.
- Anti Lag and Disable Particles process large trees in small batches.
- HUDs use timed refreshes instead of per-frame coordinate/speed/compass calculations.
- FPS displays share one global frame sampler.
- Feature dashboard polling is reduced; registry subscriptions still update immediately.

## Static verification

- Lua/Luau files parsed: **157**
- Syntax failures: **0**
- Catalog features: **65**
- Games modules: **53**
- Guard modules: **7**
- Detective modules: **5**
- Player modules: **25**
- Missing catalog files: **0**
- Duplicate feature IDs: **0**
- Unsupported implementation kinds: **0**
- Direct RLGL `WalkSpeed` writes: **0**
- Independent `while Enabled` loops under Games/Guard/Detective: **0**

## Required live checks

Static verification cannot reproduce private live-round object names, server-side validation, or executor APIs. In a live server, test in this order:

1. Enable RLGL State ESP alone and confirm it displays Red, Green, or Waiting correctly.
2. Enable RLGL Auto Move and confirm movement occurs only during Green.
3. Add Anti Stuck and confirm it does not move during Red or change walk speed.
4. Enable Auto Apply per Game, arm one harmless visual feature in two different game categories, and confirm only the current category activates.
5. Test each interaction feature in the correct role and round while watching its status line for Active, Waiting, or Error details.

A feature that reports **Waiting** is asleep and not consuming its active interval. A feature that reports **Error** exposes the failing runtime detail instead of silently doing nothing.
