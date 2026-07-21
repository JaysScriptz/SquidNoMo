# SquidNoMo feature-recode deployment checklist

1. Replace the complete repository contents, including `BuildManifest.lua`, `Loader.lua`, `Main.lua`, `Features/Shared/Runtime.lua`, `Features/Shared/PlayerRuntime.lua`, and every rewritten feature wrapper.
2. Confirm the raw GitHub URL for `BuildManifest.lua` returns:
   - `Version = "1.1 beta 1"`
   - `Revision = "feature-recode-r2"`
3. Execute `Main.lua`, not an older cached copy of `Loader.lua`.
4. The loading screen must stop with a build-mismatch error when the repository is only partially updated. Do not bypass that check.
5. Test one round at a time. A feature card now shows `ACTIVE`, `WAITING`, or `ERROR` and explains the current target it found or is waiting for.
6. For Island Navigator, verify the character walks by pathfinding from the boat/start area toward evidence. It should not directly set the character position.
